"""Bounded, reproducible GA for capacitated routes with hard time windows.

The search returns a feasible candidate, not a proof of global optimality.
This module performs no HTTP or database operations.
"""

import hashlib
import math
from dataclasses import dataclass
from time import perf_counter

EPS = 1e-7


@dataclass(frozen=True)
class Delivery:
    identifier: str
    node: int
    weight: float
    opens: float
    closes: float


@dataclass(frozen=True)
class Team:
    identifier: str
    origin: int
    capacity: float
    consumption: float
    emission: float
    starts: float
    ends: float
    busy: tuple = ()
    assigned_minutes: float = 0


@dataclass(frozen=True)
class Rules:
    service: float = 5
    max_work: float = 480
    break_after: float = 240
    break_minutes: float = 30
    return_to_origin: bool = True


@dataclass(frozen=True)
class Parameters:
    seed: int = 42
    population: int = 24
    generations: int = 40
    mutation: float = 0.2
    seconds: float = 8
    distance_weight: float = 0.35
    fuel_weight: float = 0.15
    carbon_weight: float = 0.35
    time_weight: float = 0.15


@dataclass(frozen=True)
class StopTime:
    delivery: str
    arrival: float
    service_start: float
    finish: float


@dataclass(frozen=True)
class Route:
    team: str
    deliveries: tuple
    stops: tuple
    start: float
    end: float
    distance: float
    travel: float
    waiting: float
    rest: float
    weight: float
    fuel: float
    carbon: float


@dataclass(frozen=True)
class Plan:
    routes: tuple
    unassigned: tuple
    objective: float

    @property
    def rank(self):
        return len(self.unassigned), self.objective


class NoFeasiblePlan(ValueError):
    def __init__(
        self,
        unassigned,
        message="No se encontró un plan factible dentro de la búsqueda configurada.",
    ):
        super().__init__(message)
        self.unassigned = tuple(unassigned)


class Sampling:
    """SHA-256 counter stream used only for deterministic genetic sampling."""

    def __init__(self, seed):
        self.seed = str(seed).encode("ascii")
        self.counter = 0

    def index(self, count):
        if count <= 0:
            raise ValueError("Empty sampling range")
        self.counter += 1
        digest = hashlib.sha256(self.seed + self.counter.to_bytes(8, "big")).digest()
        return int.from_bytes(digest[:8], "big") % count

    def shuffle(self, values):
        items = list(values)
        for i in range(len(items) - 1, 0, -1):
            j = self.index(i + 1)
            items[i], items[j] = items[j], items[i]
        return tuple(items)


def validate_inputs(deliveries, teams, distance, duration, rules, parameters):
    if not deliveries or not teams or len(deliveries) > 150 or len(teams) > 15:
        raise ValueError("Se requieren 1–150 pedidos y 1–15 equipos.")
    if len({d.identifier for d in deliveries}) != len(deliveries):
        raise ValueError("Pedidos duplicados.")
    if len({t.identifier for t in teams}) != len(teams):
        raise ValueError("Equipos duplicados.")
    size = len(distance)
    if size == 0 or len(duration) != size:
        raise ValueError("Matriz inválida.")
    for matrix in (distance, duration):
        for row in matrix:
            if len(row) != size or any(not math.isfinite(x) or x < 0 for x in row):
                raise ValueError("Matriz incompleta o con valores inválidos.")
    if any(
        not all(math.isfinite(x) for x in (d.weight, d.opens, d.closes))
        or d.node not in range(size)
        or d.weight <= 0
        or d.opens >= d.closes
        for d in deliveries
    ):
        raise ValueError("Pedido inválido.")
    if any(
        not all(
            math.isfinite(x)
            for x in (
                t.capacity,
                t.consumption,
                t.emission,
                t.starts,
                t.ends,
                t.assigned_minutes,
            )
        )
        or t.origin not in range(size)
        or t.capacity <= 0
        or t.consumption <= 0
        or t.emission < 0
        or t.starts >= t.ends
        or t.assigned_minutes < 0
        for t in teams
    ):
        raise ValueError("Equipo inválido.")
    if (
        rules.service <= 0
        or rules.max_work <= 0
        or rules.break_after <= 0
        or rules.break_minutes < 0
    ):
        raise ValueError("Restricciones operativas inválidas.")
    if not 4 <= parameters.population <= 64 or not 1 <= parameters.generations <= 150:
        raise ValueError("Población o generaciones fuera de rango.")
    if not 0 <= parameters.mutation <= 1 or not 0 < parameters.seconds <= 30:
        raise ValueError("Parámetros de búsqueda inválidos.")
    weights = (
        parameters.distance_weight,
        parameters.fuel_weight,
        parameters.carbon_weight,
        parameters.time_weight,
    )
    if (
        any(not math.isfinite(weight) or weight < 0 for weight in weights)
        or sum(weights) <= 0
    ):
        raise ValueError("Pesos de objetivo inválidos.")


def evaluate_route(team, deliveries, distance, duration, rules):
    weight = sum(d.weight for d in deliveries)
    if not deliveries or weight > team.capacity + EPS:
        return None
    clock = team.starts
    node = team.origin
    km = travel = waiting = rest = driving = 0.0
    stops = []
    for delivery in deliveries:
        leg = duration[node][delivery.node]
        if leg > rules.break_after + EPS:
            return None  # No safe intermediate rest point is present in the input.
        if driving + leg > rules.break_after + EPS:
            clock += rules.break_minutes
            rest += rules.break_minutes
            driving = 0
        clock += leg
        driving += leg
        travel += leg
        km += distance[node][delivery.node]
        arrival = clock
        waiting += max(0, delivery.opens - clock)
        clock = max(clock, delivery.opens)
        finish = clock + rules.service
        if finish > delivery.closes + EPS:
            return None
        stops.append(StopTime(delivery.identifier, arrival, clock, finish))
        clock = finish
        node = delivery.node
    if rules.return_to_origin:
        leg = duration[node][team.origin]
        if leg > rules.break_after + EPS:
            return None
        if driving + leg > rules.break_after + EPS:
            clock += rules.break_minutes
            rest += rules.break_minutes
        clock += leg
        travel += leg
        km += distance[node][team.origin]
    if (
        clock > team.ends + EPS
        or clock - team.starts + team.assigned_minutes > rules.max_work + EPS
    ):
        return None
    if any(team.starts < end and start < clock for start, end in team.busy):
        return None
    return Route(
        team.identifier,
        tuple(d.identifier for d in deliveries),
        tuple(stops),
        team.starts,
        clock,
        km,
        travel,
        waiting,
        rest,
        weight,
        km / team.consumption,
        km * team.emission,
    )


def objective(routes, parameters):
    # Fixed reference units make the heterogeneous quantities comparable.
    return sum(
        parameters.distance_weight * r.distance / 100
        + parameters.fuel_weight * r.fuel / 10
        + parameters.carbon_weight * r.carbon / 20
        + parameters.time_weight * (r.end - r.start) / 480
        for r in routes
    )


def decode(chromosome, deliveries, teams, distance, duration, rules, parameters):
    order, team_order = chromosome
    assigned = {team.identifier: [] for team in teams}
    routes = {}
    unassigned = []
    for index in order:
        delivery = deliveries[index]
        options = []
        for team_index in team_order:
            team = teams[team_index]
            trial = evaluate_route(
                team, assigned[team.identifier] + [delivery], distance, duration, rules
            )
            if trial is not None:
                previous = (
                    objective((routes[team.identifier],), parameters)
                    if team.identifier in routes
                    else 0
                )
                options.append(
                    (objective((trial,), parameters) - previous, team_index, trial)
                )
        if not options:
            unassigned.append(delivery.identifier)
            continue
        _, team_index, route = min(options, key=lambda item: item[0])
        team = teams[team_index]
        assigned[team.identifier].append(delivery)
        routes[team.identifier] = route
    values = tuple(routes[key] for key in sorted(routes))
    return Plan(values, tuple(unassigned), objective(values, parameters))


def crossover(first, second, sampling):
    if len(first) < 2:
        return first
    left, right = sorted((sampling.index(len(first)), sampling.index(len(first))))
    selected = first[left : right + 1]
    remainder = tuple(value for value in second if value not in selected)
    return remainder[:left] + selected + remainder[left:]


def mutate(values, sampling, rate):
    if len(values) < 2 or sampling.index(1_000_000) >= rate * 1_000_000:
        return values
    first, second = sampling.index(len(values)), sampling.index(len(values))
    result = list(values)
    result[first], result[second] = result[second], result[first]
    return tuple(result)


def solve(
    deliveries, teams, distance, duration, rules=Rules(), parameters=Parameters()
):
    validate_inputs(deliveries, teams, distance, duration, rules, parameters)
    impossible = tuple(
        d.identifier
        for d in deliveries
        if d.weight > max(t.capacity for t in teams) + EPS
    )
    if impossible:
        raise NoFeasiblePlan(
            impossible,
            "Hay pedidos cuyo peso supera la capacidad de todos los equipos.",
        )
    clock = perf_counter()
    sampling = Sampling(parameters.seed)
    natural = tuple(range(len(deliveries)))
    team_order = tuple(range(len(teams)))
    baseline = decode(
        (natural, team_order), deliveries, teams, distance, duration, rules, parameters
    )
    candidates = [
        (natural, team_order),
        (tuple(sorted(natural, key=lambda i: deliveries[i].closes)), team_order),
        (tuple(sorted(natural, key=lambda i: deliveries[i].opens)), team_order),
        (tuple(reversed(natural)), team_order),
    ]
    while len(candidates) < parameters.population:
        candidates.append((sampling.shuffle(natural), sampling.shuffle(team_order)))
    best = baseline
    evaluations = generations = 0
    for generation in range(parameters.generations):
        memo = {}
        ranked = []
        for candidate in candidates:
            if perf_counter() - clock >= parameters.seconds and evaluations:
                break
            plan = memo.get(candidate)
            if plan is None:
                plan = decode(
                    candidate, deliveries, teams, distance, duration, rules, parameters
                )
                memo[candidate] = plan
                evaluations += 1
            ranked.append((plan.rank, candidate))
            if plan.rank < best.rank:
                best = plan
        if not ranked:
            break
        generations = generation + 1
        ranked.sort(key=lambda item: item[0])
        if perf_counter() - clock >= parameters.seconds:
            break
        candidates = [item[1] for item in ranked[:2]]
        while len(candidates) < parameters.population:
            parent_a = min(
                (ranked[sampling.index(len(ranked))] for _ in range(3)),
                key=lambda x: x[0],
            )[1]
            parent_b = min(
                (ranked[sampling.index(len(ranked))] for _ in range(3)),
                key=lambda x: x[0],
            )[1]
            candidates.append(
                tuple(
                    mutate(crossover(a, b, sampling), sampling, parameters.mutation)
                    for a, b in zip(parent_a, parent_b)
                )
            )
    if best.unassigned:
        raise NoFeasiblePlan(best.unassigned)
    return best, {
        "seed": parameters.seed,
        "generations": generations,
        "evaluations": evaluations,
        "elapsed_ms": round(1000 * (perf_counter() - clock), 2),
        "baseline_feasible": not baseline.unassigned,
        "baseline_objective": baseline.objective if not baseline.unassigned else None,
        "objective": best.objective,
        "algorithm": "GA_VRPTW_1",
        "global_optimum_guaranteed": False,
    }
