--
-- PostgreSQL database dump
--

\restrict d33dwg5N6cziM92a24sIOFd8LxL7J1WY9edOFycYWAZ18KUim0ndI7YfVoAYDxG

-- Dumped from database version 16.15
-- Dumped by pg_dump version 16.15

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


--
-- Name: cliente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cliente (
    cliente_id uuid NOT NULL,
    nombre character varying(160) NOT NULL,
    contacto character varying(80),
    estado character varying(20) NOT NULL
);


--
-- Name: compensacion_carbono; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.compensacion_carbono (
    compensacion_id uuid NOT NULL,
    reporte_id uuid NOT NULL,
    co2_objetivo_kg numeric(14,3) NOT NULL,
    descripcion_plan text NOT NULL
);


--
-- Name: control_acceso; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.control_acceso (
    identificador_hmac character varying(64) NOT NULL,
    intentos_fallidos integer DEFAULT 0 NOT NULL,
    bloqueo_hasta timestamp with time zone,
    actualizado_en timestamp with time zone NOT NULL,
    CONSTRAINT ck_access_attempts CHECK (((intentos_fallidos >= 0) AND (intentos_fallidos <= 5)))
);


--
-- Name: incidente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.incidente (
    incidente_id uuid NOT NULL,
    ruta_id uuid NOT NULL,
    repartidor_id uuid NOT NULL,
    tipo character varying(30) NOT NULL,
    descripcion text,
    latitud numeric(9,6),
    longitud numeric(9,6),
    ocurrido_en timestamp with time zone NOT NULL,
    demora_min integer,
    afectacion character varying(20) DEFAULT 'NO_INDICADA'::character varying NOT NULL,
    registrado_en timestamp with time zone DEFAULT now() NOT NULL,
    resuelto_en timestamp with time zone,
    resolucion text,
    CONSTRAINT ck_incident_delay CHECK (((demora_min IS NULL) OR ((demora_min >= 0) AND (demora_min <= 240))))
);


--
-- Name: lectura_notificacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.lectura_notificacion (
    notificacion_id uuid NOT NULL,
    usuario_id uuid NOT NULL,
    leido_en timestamp with time zone NOT NULL
);


--
-- Name: notificacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notificacion (
    notificacion_id uuid NOT NULL,
    usuario_id uuid,
    rol character varying(30),
    ruta_id uuid NOT NULL,
    tipo character varying(40) NOT NULL,
    referencia_id uuid NOT NULL,
    creado_en timestamp with time zone NOT NULL,
    CONSTRAINT ck_notification_recipient CHECK ((((usuario_id IS NOT NULL) AND (rol IS NULL)) OR ((usuario_id IS NULL) AND ((rol)::text = 'ADMIN'::text))))
);


--
-- Name: pedido; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pedido (
    pedido_id uuid NOT NULL,
    cliente_id uuid NOT NULL,
    direccion text NOT NULL,
    punto_referencia text,
    latitud numeric(9,6),
    longitud numeric(9,6),
    peso_kg numeric(10,2) NOT NULL,
    volumen_m3 numeric(10,3),
    ventana_inicio timestamp with time zone NOT NULL,
    ventana_fin timestamp with time zone NOT NULL,
    prioridad character varying(20) NOT NULL,
    tipo_producto character varying(30) NOT NULL,
    estado character varying(20) NOT NULL
);


--
-- Name: plan_optimizacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plan_optimizacion (
    plan_id uuid NOT NULL,
    usuario_id uuid NOT NULL,
    estado character varying(30) NOT NULL,
    creado_en timestamp with time zone NOT NULL,
    vence_en timestamp with time zone NOT NULL,
    solicitud jsonb NOT NULL,
    solucion jsonb NOT NULL,
    huella_datos character varying(64) NOT NULL,
    CONSTRAINT ck_plan_estado CHECK (((estado)::text = ANY ((ARRAY['PREVISUALIZADO'::character varying, 'CONFIRMADO'::character varying, 'CANCELADO'::character varying])::text[])))
);


--
-- Name: politica_trafico; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.politica_trafico (
    politica_id integer NOT NULL,
    revision integer NOT NULL,
    reglas jsonb NOT NULL,
    actualizado_en timestamp with time zone NOT NULL,
    usuario_id uuid NOT NULL
);


--
-- Name: politica_trafico_politica_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.politica_trafico_politica_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: politica_trafico_politica_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.politica_trafico_politica_id_seq OWNED BY public.politica_trafico.politica_id;


--
-- Name: preferencia_entrega; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.preferencia_entrega (
    preferencia_id uuid NOT NULL,
    cliente_id uuid NOT NULL,
    hora_preferida_inicio time without time zone,
    hora_preferida_fin time without time zone,
    punto_referencia text,
    restriccion_acceso text
);


--
-- Name: repartidor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.repartidor (
    repartidor_id uuid NOT NULL,
    usuario_id uuid NOT NULL,
    nombre character varying(160) NOT NULL,
    dni character varying(20) NOT NULL,
    licencia character varying(30) NOT NULL,
    categoria_licencia character varying(20) NOT NULL,
    anios_experiencia integer,
    disponible_desde time without time zone,
    disponible_hasta time without time zone,
    contacto character varying(50),
    origen_latitud numeric(9,6),
    origen_longitud numeric(9,6),
    estado character varying(20) DEFAULT 'ACTIVO'::character varying NOT NULL
);


--
-- Name: reporte_sostenibilidad; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reporte_sostenibilidad (
    reporte_id uuid NOT NULL,
    ruta_id uuid,
    periodo_inicio date NOT NULL,
    periodo_fin date NOT NULL,
    co2_kg numeric(14,3) NOT NULL,
    combustible_l numeric(14,3) NOT NULL,
    ahorro_estimado numeric(14,2) NOT NULL,
    archivo_url text
);


--
-- Name: revision_ruta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.revision_ruta (
    revision_id uuid NOT NULL,
    ruta_id uuid NOT NULL,
    version_base integer NOT NULL,
    estado character varying(20) NOT NULL,
    autor_id uuid NOT NULL,
    aprobado_por uuid,
    creado_en timestamp with time zone NOT NULL,
    vence_en timestamp with time zone NOT NULL,
    aprobado_en timestamp with time zone,
    recibido_en timestamp with time zone,
    motivo text NOT NULL,
    huella character varying(64) NOT NULL,
    anterior jsonb NOT NULL,
    propuesta jsonb NOT NULL,
    CONSTRAINT ck_revision_estado CHECK (((estado)::text = ANY ((ARRAY['PROPUESTA'::character varying, 'APROBADA'::character varying, 'RECHAZADA'::character varying])::text[])))
);


--
-- Name: ruta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ruta (
    ruta_id uuid NOT NULL,
    vehiculo_id uuid NOT NULL,
    repartidor_id uuid NOT NULL,
    estado character varying(20) NOT NULL,
    algoritmo character varying(50) NOT NULL,
    distancia_km numeric(12,3),
    tiempo_min numeric(12,2),
    combustible_l numeric(12,3),
    co2_kg numeric(12,3),
    penalizacion_total numeric(14,2) NOT NULL,
    creado_en timestamp with time zone NOT NULL,
    origen_latitud numeric(9,6),
    origen_longitud numeric(9,6),
    geometria jsonb,
    inicio_planificado timestamp with time zone,
    fin_planificado timestamp with time zone,
    servicio_min_por_entrega integer,
    plan_optimizacion_id uuid,
    iniciado_en timestamp with time zone,
    finalizado_en timestamp with time zone,
    version integer DEFAULT 1 NOT NULL,
    version_recibida integer DEFAULT 0 NOT NULL,
    CONSTRAINT ck_ruta_horario CHECK ((((inicio_planificado IS NULL) AND (fin_planificado IS NULL) AND (servicio_min_por_entrega IS NULL)) OR ((inicio_planificado IS NOT NULL) AND (fin_planificado IS NOT NULL) AND (fin_planificado > inicio_planificado) AND ((servicio_min_por_entrega >= 0) AND (servicio_min_por_entrega <= 120))))),
    CONSTRAINT ck_ruta_version CHECK (((version >= 1) AND (version_recibida >= 0) AND (version_recibida <= version)))
);


--
-- Name: ruta_detalle; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ruta_detalle (
    ruta_detalle_id uuid NOT NULL,
    ruta_id uuid NOT NULL,
    pedido_id uuid NOT NULL,
    secuencia integer NOT NULL,
    eta timestamp with time zone,
    estado_entrega character varying(20) NOT NULL,
    entregado_en timestamp with time zone,
    entregado_por uuid
);


--
-- Name: usuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usuario (
    usuario_id uuid NOT NULL,
    email character varying(255) NOT NULL,
    password_hash character varying(255) NOT NULL,
    rol character varying(30) NOT NULL,
    estado character varying(20) NOT NULL,
    creado_en timestamp with time zone NOT NULL
);


--
-- Name: vehiculo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vehiculo (
    vehiculo_id uuid NOT NULL,
    placa character varying(15) NOT NULL,
    tipo character varying(30) NOT NULL,
    capacidad_kg numeric(10,2) NOT NULL,
    consumo_km_l numeric(8,3) NOT NULL,
    factor_emision_kg_km numeric(10,4) NOT NULL,
    anio_fabricacion integer NOT NULL,
    estado character varying(20) NOT NULL
);


--
-- Name: politica_trafico politica_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.politica_trafico ALTER COLUMN politica_id SET DEFAULT nextval('public.politica_trafico_politica_id_seq'::regclass);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: repartidor ck_driver_hours; Type: CHECK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.repartidor
    ADD CONSTRAINT ck_driver_hours CHECK (((disponible_desde IS NULL) OR (disponible_hasta IS NULL) OR (disponible_desde < disponible_hasta))) NOT VALID;


--
-- Name: repartidor ck_driver_lat; Type: CHECK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.repartidor
    ADD CONSTRAINT ck_driver_lat CHECK (((origen_latitud >= ('-90'::integer)::numeric) AND (origen_latitud <= (90)::numeric))) NOT VALID;


--
-- Name: repartidor ck_driver_lon; Type: CHECK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.repartidor
    ADD CONSTRAINT ck_driver_lon CHECK (((origen_longitud >= ('-180'::integer)::numeric) AND (origen_longitud <= (180)::numeric))) NOT VALID;


--
-- Name: repartidor ck_driver_origin; Type: CHECK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.repartidor
    ADD CONSTRAINT ck_driver_origin CHECK (((origen_latitud IS NULL) = (origen_longitud IS NULL))) NOT VALID;


--
-- Name: vehiculo ck_vehicle_capacity; Type: CHECK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.vehiculo
    ADD CONSTRAINT ck_vehicle_capacity CHECK ((capacidad_kg > (0)::numeric)) NOT VALID;


--
-- Name: vehiculo ck_vehicle_consumption; Type: CHECK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.vehiculo
    ADD CONSTRAINT ck_vehicle_consumption CHECK ((consumo_km_l > (0)::numeric)) NOT VALID;


--
-- Name: vehiculo ck_vehicle_emissions; Type: CHECK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.vehiculo
    ADD CONSTRAINT ck_vehicle_emissions CHECK ((factor_emision_kg_km >= (0)::numeric)) NOT VALID;


--
-- Name: cliente cliente_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cliente
    ADD CONSTRAINT cliente_pkey PRIMARY KEY (cliente_id);


--
-- Name: compensacion_carbono compensacion_carbono_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.compensacion_carbono
    ADD CONSTRAINT compensacion_carbono_pkey PRIMARY KEY (compensacion_id);


--
-- Name: control_acceso control_acceso_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.control_acceso
    ADD CONSTRAINT control_acceso_pkey PRIMARY KEY (identificador_hmac);


--
-- Name: incidente incidente_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incidente
    ADD CONSTRAINT incidente_pkey PRIMARY KEY (incidente_id);


--
-- Name: lectura_notificacion lectura_notificacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lectura_notificacion
    ADD CONSTRAINT lectura_notificacion_pkey PRIMARY KEY (notificacion_id, usuario_id);


--
-- Name: notificacion notificacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notificacion
    ADD CONSTRAINT notificacion_pkey PRIMARY KEY (notificacion_id);


--
-- Name: pedido pedido_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pedido
    ADD CONSTRAINT pedido_pkey PRIMARY KEY (pedido_id);


--
-- Name: plan_optimizacion plan_optimizacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plan_optimizacion
    ADD CONSTRAINT plan_optimizacion_pkey PRIMARY KEY (plan_id);


--
-- Name: politica_trafico politica_trafico_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.politica_trafico
    ADD CONSTRAINT politica_trafico_pkey PRIMARY KEY (politica_id);


--
-- Name: preferencia_entrega preferencia_entrega_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.preferencia_entrega
    ADD CONSTRAINT preferencia_entrega_pkey PRIMARY KEY (preferencia_id);


--
-- Name: repartidor repartidor_dni_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repartidor
    ADD CONSTRAINT repartidor_dni_key UNIQUE (dni);


--
-- Name: repartidor repartidor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repartidor
    ADD CONSTRAINT repartidor_pkey PRIMARY KEY (repartidor_id);


--
-- Name: repartidor repartidor_usuario_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repartidor
    ADD CONSTRAINT repartidor_usuario_id_key UNIQUE (usuario_id);


--
-- Name: reporte_sostenibilidad reporte_sostenibilidad_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reporte_sostenibilidad
    ADD CONSTRAINT reporte_sostenibilidad_pkey PRIMARY KEY (reporte_id);


--
-- Name: revision_ruta revision_ruta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.revision_ruta
    ADD CONSTRAINT revision_ruta_pkey PRIMARY KEY (revision_id);


--
-- Name: ruta_detalle ruta_detalle_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ruta_detalle
    ADD CONSTRAINT ruta_detalle_pkey PRIMARY KEY (ruta_detalle_id);


--
-- Name: ruta ruta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ruta
    ADD CONSTRAINT ruta_pkey PRIMARY KEY (ruta_id);


--
-- Name: usuario usuario_email_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_email_key UNIQUE (email);


--
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (usuario_id);


--
-- Name: vehiculo vehiculo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehiculo
    ADD CONSTRAINT vehiculo_pkey PRIMARY KEY (vehiculo_id);


--
-- Name: vehiculo vehiculo_placa_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehiculo
    ADD CONSTRAINT vehiculo_placa_key UNIQUE (placa);


--
-- Name: ix_notificacion_usuario_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_notificacion_usuario_id ON public.notificacion USING btree (usuario_id);


--
-- Name: ix_revision_ruta_ruta_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_revision_ruta_ruta_id ON public.revision_ruta USING btree (ruta_id);


--
-- Name: ix_ruta_detalle_pedido; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_ruta_detalle_pedido ON public.ruta_detalle USING btree (pedido_id);


--
-- Name: ix_ruta_plan_optimizacion_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_ruta_plan_optimizacion_id ON public.ruta USING btree (plan_optimizacion_id);


--
-- Name: ix_ruta_repartidor_inicio; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_ruta_repartidor_inicio ON public.ruta USING btree (repartidor_id, inicio_planificado);


--
-- Name: ix_ruta_vehiculo_inicio; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_ruta_vehiculo_inicio ON public.ruta USING btree (vehiculo_id, inicio_planificado);


--
-- Name: ix_usuario_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_usuario_email ON public.usuario USING btree (email);


--
-- Name: ix_vehiculo_placa; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_vehiculo_placa ON public.vehiculo USING btree (placa);


--
-- Name: compensacion_carbono compensacion_carbono_reporte_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.compensacion_carbono
    ADD CONSTRAINT compensacion_carbono_reporte_id_fkey FOREIGN KEY (reporte_id) REFERENCES public.reporte_sostenibilidad(reporte_id);


--
-- Name: ruta_detalle fk_entrega_autor; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ruta_detalle
    ADD CONSTRAINT fk_entrega_autor FOREIGN KEY (entregado_por) REFERENCES public.usuario(usuario_id);


--
-- Name: ruta fk_ruta_plan; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ruta
    ADD CONSTRAINT fk_ruta_plan FOREIGN KEY (plan_optimizacion_id) REFERENCES public.plan_optimizacion(plan_id);


--
-- Name: incidente incidente_repartidor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incidente
    ADD CONSTRAINT incidente_repartidor_id_fkey FOREIGN KEY (repartidor_id) REFERENCES public.repartidor(repartidor_id);


--
-- Name: incidente incidente_ruta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incidente
    ADD CONSTRAINT incidente_ruta_id_fkey FOREIGN KEY (ruta_id) REFERENCES public.ruta(ruta_id);


--
-- Name: lectura_notificacion lectura_notificacion_notificacion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lectura_notificacion
    ADD CONSTRAINT lectura_notificacion_notificacion_id_fkey FOREIGN KEY (notificacion_id) REFERENCES public.notificacion(notificacion_id);


--
-- Name: lectura_notificacion lectura_notificacion_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.lectura_notificacion
    ADD CONSTRAINT lectura_notificacion_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuario(usuario_id);


--
-- Name: notificacion notificacion_ruta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notificacion
    ADD CONSTRAINT notificacion_ruta_id_fkey FOREIGN KEY (ruta_id) REFERENCES public.ruta(ruta_id);


--
-- Name: notificacion notificacion_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notificacion
    ADD CONSTRAINT notificacion_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuario(usuario_id);


--
-- Name: pedido pedido_cliente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pedido
    ADD CONSTRAINT pedido_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.cliente(cliente_id);


--
-- Name: plan_optimizacion plan_optimizacion_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plan_optimizacion
    ADD CONSTRAINT plan_optimizacion_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuario(usuario_id);


--
-- Name: politica_trafico politica_trafico_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.politica_trafico
    ADD CONSTRAINT politica_trafico_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuario(usuario_id);


--
-- Name: preferencia_entrega preferencia_entrega_cliente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.preferencia_entrega
    ADD CONSTRAINT preferencia_entrega_cliente_id_fkey FOREIGN KEY (cliente_id) REFERENCES public.cliente(cliente_id);


--
-- Name: repartidor repartidor_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.repartidor
    ADD CONSTRAINT repartidor_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuario(usuario_id);


--
-- Name: reporte_sostenibilidad reporte_sostenibilidad_ruta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reporte_sostenibilidad
    ADD CONSTRAINT reporte_sostenibilidad_ruta_id_fkey FOREIGN KEY (ruta_id) REFERENCES public.ruta(ruta_id);


--
-- Name: revision_ruta revision_ruta_aprobado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.revision_ruta
    ADD CONSTRAINT revision_ruta_aprobado_por_fkey FOREIGN KEY (aprobado_por) REFERENCES public.usuario(usuario_id);


--
-- Name: revision_ruta revision_ruta_autor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.revision_ruta
    ADD CONSTRAINT revision_ruta_autor_id_fkey FOREIGN KEY (autor_id) REFERENCES public.usuario(usuario_id);


--
-- Name: revision_ruta revision_ruta_ruta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.revision_ruta
    ADD CONSTRAINT revision_ruta_ruta_id_fkey FOREIGN KEY (ruta_id) REFERENCES public.ruta(ruta_id);


--
-- Name: ruta_detalle ruta_detalle_pedido_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ruta_detalle
    ADD CONSTRAINT ruta_detalle_pedido_id_fkey FOREIGN KEY (pedido_id) REFERENCES public.pedido(pedido_id);


--
-- Name: ruta_detalle ruta_detalle_ruta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ruta_detalle
    ADD CONSTRAINT ruta_detalle_ruta_id_fkey FOREIGN KEY (ruta_id) REFERENCES public.ruta(ruta_id);


--
-- Name: ruta ruta_repartidor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ruta
    ADD CONSTRAINT ruta_repartidor_id_fkey FOREIGN KEY (repartidor_id) REFERENCES public.repartidor(repartidor_id);


--
-- Name: ruta ruta_vehiculo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ruta
    ADD CONSTRAINT ruta_vehiculo_id_fkey FOREIGN KEY (vehiculo_id) REFERENCES public.vehiculo(vehiculo_id);


--
-- PostgreSQL database dump complete
--

\unrestrict d33dwg5N6cziM92a24sIOFd8LxL7J1WY9edOFycYWAZ18KUim0ndI7YfVoAYDxG
