"""GOLD, happy, unhappy and boundary checks of the actual genetic solver."""

from dataclasses import replace
import math
import unittest

from app.services.genetic import (
    Delivery,
    Team,
    Rules,
    Parameters,
    Sampling,
    NoFeasiblePlan,
    crossover,
    evaluate_route,
    solve,
)


class GeneticCases(unittest.TestCase):
    def setUp(self):
        self.distance = [[0, 1, 2], [1, 0, 1], [2, 1, 0]]
        self.duration = self.distance
        self.deliveries = [Delivery("a", 1, 5, 0, 60), Delivery("b", 2, 5, 0, 60)]
        self.teams = [Team("t1", 0, 10, 10, 0.2, 0, 120)]
        self.parameters = Parameters(population=8, generations=8, seconds=2)

    def verify(self, plan, deliveries, teams, distance, duration, rules):
        self.assertFalse(plan.unassigned)
        ids = [item for route in plan.routes for item in route.deliveries]
        self.assertCountEqual(ids, [d.identifier for d in deliveries])
        self.assertEqual(len(ids), len(set(ids)))
        by_id = {d.identifier: d for d in deliveries}
        by_team = {t.identifier: t for t in teams}
        for route in plan.routes:
            team = by_team[route.team]
            self.assertLessEqual(route.weight, team.capacity)
            self.assertLessEqual(route.end, team.ends)
            for stop in route.stops:
                request = by_id[stop.delivery]
                self.assertGreaterEqual(stop.service_start, request.opens)
                self.assertLessEqual(stop.finish, request.closes)
            recomputed = evaluate_route(
                team,
                [by_id[key] for key in route.deliveries],
                distance,
                duration,
                rules,
            )
            self.assertEqual(route, recomputed)

    def test_gold_exact_capacity_plan_has_every_order_and_valid_metrics(self):
        plan, meta = solve(
            self.deliveries,
            self.teams,
            self.distance,
            self.duration,
            parameters=self.parameters,
        )
        self.verify(
            plan, self.deliveries, self.teams, self.distance, self.duration, Rules()
        )
        self.assertEqual(plan.routes[0].weight, 10)
        self.assertAlmostEqual(plan.routes[0].fuel, plan.routes[0].distance / 10)
        self.assertAlmostEqual(plan.routes[0].carbon, plan.routes[0].distance * 0.2)
        self.assertGreater(meta["evaluations"], 0)

    def test_happy_waiting_and_time_zone_independent_offsets(self):
        deliveries = [replace(self.deliveries[0], opens=30)]
        plan, _ = solve(
            deliveries,
            self.teams,
            self.distance,
            self.duration,
            parameters=self.parameters,
        )
        self.assertEqual(plan.routes[0].stops[0].service_start, 30)
        self.assertEqual(plan.routes[0].waiting, 29)

    def test_unhappy_capacity_no_false_feasible_route(self):
        with self.assertRaises(NoFeasiblePlan) as error:
            solve(
                [replace(self.deliveries[0], weight=11)],
                self.teams,
                self.distance,
                self.duration,
                parameters=self.parameters,
            )
        self.assertEqual(error.exception.unassigned, ("a",))

    def test_unhappy_window_or_busy_team(self):
        for deliveries, teams in [
            ([replace(self.deliveries[0], closes=2)], self.teams),
            (self.deliveries, [replace(self.teams[0], busy=((0, 120),))]),
        ]:
            with self.assertRaises(NoFeasiblePlan):
                solve(
                    deliveries,
                    teams,
                    self.distance,
                    self.duration,
                    parameters=self.parameters,
                )

    def test_boundaries_empty_missing_teams_duplicates_nonfinite(self):
        for deliveries, teams in [
            ([], self.teams),
            (self.deliveries, []),
            ([self.deliveries[0]] * 2, self.teams),
            ([replace(self.deliveries[0], weight=math.nan)], self.teams),
        ]:
            with self.assertRaises(ValueError):
                solve(
                    deliveries,
                    teams,
                    self.distance,
                    self.duration,
                    parameters=self.parameters,
                )
        invalid = [[0, math.inf, 2], [1, 0, 1], [2, 1, 0]]
        with self.assertRaises(ValueError):
            solve(
                self.deliveries,
                self.teams,
                invalid,
                self.duration,
                parameters=self.parameters,
            )

    def test_boundary_exact_window_and_shift_are_inclusive(self):
        route = evaluate_route(
            replace(self.teams[0], ends=7),
            [replace(self.deliveries[0], closes=6)],
            self.distance,
            self.duration,
            Rules(),
        )
        self.assertIsNotNone(route)
        self.assertEqual(route.end, 7)
        self.assertIsNone(
            evaluate_route(
                replace(self.teams[0], ends=6.9),
                [self.deliveries[0]],
                self.distance,
                self.duration,
                Rules(),
            )
        )

    def test_boundary_rest_and_total_work_are_hard_constraints(self):
        matrix = [[0, 2, 2], [2, 0, 2], [2, 2, 0]]
        rules = Rules(service=1, break_after=5, break_minutes=3)
        route = evaluate_route(self.teams[0], self.deliveries, matrix, matrix, rules)
        self.assertEqual(route.rest, 3)
        self.assertIsNone(
            evaluate_route(
                replace(self.teams[0], assigned_minutes=479),
                self.deliveries,
                matrix,
                matrix,
                rules,
            )
        )

    def test_reproducible_single_order_and_small_search_space(self):
        first, meta1 = solve(
            self.deliveries[:1],
            self.teams,
            self.distance,
            self.duration,
            parameters=self.parameters,
        )
        second, meta2 = solve(
            self.deliveries[:1],
            self.teams,
            self.distance,
            self.duration,
            parameters=self.parameters,
        )
        self.assertEqual(first, second)
        self.assertEqual(meta1["evaluations"], meta2["evaluations"])
        self.assertFalse(meta1["global_optimum_guaranteed"])

    def test_crossover_preserves_permutation(self):
        sampling = Sampling(1)
        for _ in range(40):
            self.assertCountEqual(
                crossover((0, 1, 2, 3), (3, 2, 1, 0), sampling), (0, 1, 2, 3)
            )

    def test_genetic_search_improves_sequential_baseline(self):
        coordinates = [(0, 0), (10, 0), (0, 10), (10, 10), (1, 0)]
        matrix = [[math.dist(a, b) for b in coordinates] for a in coordinates]
        deliveries = [Delivery(str(i), i, 1, 0, 400) for i in range(1, 5)]
        teams = [replace(self.teams[0], ends=480)]
        plan, meta = solve(
            deliveries,
            teams,
            matrix,
            matrix,
            parameters=Parameters(seed=42, population=24, generations=20, seconds=3),
        )
        self.verify(plan, deliveries, teams, matrix, matrix, Rules())
        self.assertLess(meta["objective"], meta["baseline_objective"])


if __name__ == "__main__":
    unittest.main(verbosity=2)
