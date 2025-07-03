--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2 (Debian 17.2-1.pgdg120+1)
-- Dumped by pg_dump version 17.5 (Ubuntu 17.5-1.pgdg24.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: climat_type; Type: TABLE; Schema: public; Owner: mspr502
--

CREATE TABLE public.climat_type (
    id_climat_type integer NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255)
);


ALTER TABLE public.climat_type OWNER TO mspr502;

--
-- Name: climat_type_id_climat_type_seq; Type: SEQUENCE; Schema: public; Owner: mspr502
--

CREATE SEQUENCE public.climat_type_id_climat_type_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.climat_type_id_climat_type_seq OWNER TO mspr502;

--
-- Name: climat_type_id_climat_type_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mspr502
--

ALTER SEQUENCE public.climat_type_id_climat_type_seq OWNED BY public.climat_type.id_climat_type;


--
-- Name: continent; Type: TABLE; Schema: public; Owner: mspr502
--

CREATE TABLE public.continent (
    id_continent integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.continent OWNER TO mspr502;

--
-- Name: continent_id_continent_seq; Type: SEQUENCE; Schema: public; Owner: mspr502
--

CREATE SEQUENCE public.continent_id_continent_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.continent_id_continent_seq OWNER TO mspr502;

--
-- Name: continent_id_continent_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mspr502
--

ALTER SEQUENCE public.continent_id_continent_seq OWNED BY public.continent.id_continent;


--
-- Name: country; Type: TABLE; Schema: public; Owner: mspr502
--

CREATE TABLE public.country (
    id_country integer NOT NULL,
    name character varying(50) NOT NULL,
    iso_code character varying(5) NOT NULL,
    population bigint NOT NULL,
    pib numeric(18,2),
    latitude double precision,
    longitude double precision,
    id_continent integer NOT NULL,
    id_region integer
);


ALTER TABLE public.country OWNER TO mspr502;

--
-- Name: country_climat_type; Type: TABLE; Schema: public; Owner: mspr502
--

CREATE TABLE public.country_climat_type (
    id_climat_type integer NOT NULL,
    id_country integer NOT NULL
);


ALTER TABLE public.country_climat_type OWNER TO mspr502;

--
-- Name: country_id_country_seq; Type: SEQUENCE; Schema: public; Owner: mspr502
--

CREATE SEQUENCE public.country_id_country_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.country_id_country_seq OWNER TO mspr502;

--
-- Name: country_id_country_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mspr502
--

ALTER SEQUENCE public.country_id_country_seq OWNED BY public.country.id_country;


--
-- Name: disease; Type: TABLE; Schema: public; Owner: mspr502
--

CREATE TABLE public.disease (
    id_disease integer NOT NULL,
    name character varying(50) NOT NULL,
    is_pandemic boolean NOT NULL
);


ALTER TABLE public.disease OWNER TO mspr502;

--
-- Name: disease_id_disease_seq; Type: SEQUENCE; Schema: public; Owner: mspr502
--

CREATE SEQUENCE public.disease_id_disease_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.disease_id_disease_seq OWNER TO mspr502;

--
-- Name: disease_id_disease_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mspr502
--

ALTER SEQUENCE public.disease_id_disease_seq OWNED BY public.disease.id_disease;


--
-- Name: log; Type: TABLE; Schema: public; Owner: mspr502
--

CREATE TABLE public.log (
    id_log integer NOT NULL,
    _date timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    is_success boolean NOT NULL,
    error_string text,
    id_country integer NOT NULL
);


ALTER TABLE public.log OWNER TO mspr502;

--
-- Name: log_id_log_seq; Type: SEQUENCE; Schema: public; Owner: mspr502
--

CREATE SEQUENCE public.log_id_log_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.log_id_log_seq OWNER TO mspr502;

--
-- Name: log_id_log_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mspr502
--

ALTER SEQUENCE public.log_id_log_seq OWNED BY public.log.id_log;


--
-- Name: metrics; Type: TABLE; Schema: public; Owner: mspr502
--

CREATE TABLE public.metrics (
    id_metrics integer NOT NULL,
    _date date NOT NULL,
    rmse numeric(20,2) NOT NULL,
    mae numeric(20,2) NOT NULL,
    r2 numeric(20,2) NOT NULL,
    id_country integer,
    r2_bis numeric(20,2),
    rmse_bis numeric(20,2),
    mae_bis numeric(20,2)
);


ALTER TABLE public.metrics OWNER TO mspr502;

--
-- Name: metrics_id_metrics_seq; Type: SEQUENCE; Schema: public; Owner: mspr502
--

CREATE SEQUENCE public.metrics_id_metrics_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.metrics_id_metrics_seq OWNER TO mspr502;

--
-- Name: metrics_id_metrics_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mspr502
--

ALTER SEQUENCE public.metrics_id_metrics_seq OWNED BY public.metrics.id_metrics;


--
-- Name: prediction; Type: TABLE; Schema: public; Owner: mspr502
--

CREATE TABLE public.prediction (
    id_prediction integer NOT NULL,
    id_country integer NOT NULL,
    id_disease integer NOT NULL,
    ds date DEFAULT CURRENT_DATE NOT NULL,
    yhat double precision,
    yhat_lower double precision,
    yhat_upper double precision,
    trend double precision,
    trend_lower double precision,
    trend_upper double precision,
    deaths double precision,
    deaths_lower double precision,
    deaths_upper double precision,
    pib double precision,
    pib_lower double precision,
    pib_upper double precision,
    population double precision,
    population_lower double precision,
    population_upper double precision
);


ALTER TABLE public.prediction OWNER TO mspr502;

--
-- Name: prediction_id_prediction_seq; Type: SEQUENCE; Schema: public; Owner: mspr502
--

CREATE SEQUENCE public.prediction_id_prediction_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.prediction_id_prediction_seq OWNER TO mspr502;

--
-- Name: prediction_id_prediction_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mspr502
--

ALTER SEQUENCE public.prediction_id_prediction_seq OWNED BY public.prediction.id_prediction;


--
-- Name: region; Type: TABLE; Schema: public; Owner: mspr502
--

CREATE TABLE public.region (
    id_region integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.region OWNER TO mspr502;

--
-- Name: region_id_region_seq; Type: SEQUENCE; Schema: public; Owner: mspr502
--

CREATE SEQUENCE public.region_id_region_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.region_id_region_seq OWNER TO mspr502;

--
-- Name: region_id_region_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mspr502
--

ALTER SEQUENCE public.region_id_region_seq OWNED BY public.region.id_region;


--
-- Name: statement; Type: TABLE; Schema: public; Owner: mspr502
--

CREATE TABLE public.statement (
    id_statement integer NOT NULL,
    _date date NOT NULL,
    confirmed numeric(20,0) NOT NULL,
    deaths numeric(20,0) NOT NULL,
    recovered numeric(20,0),
    active numeric(20,0),
    total_tests numeric(20,0),
    id_disease integer NOT NULL,
    id_country integer
);


ALTER TABLE public.statement OWNER TO mspr502;

--
-- Name: statement_id_statement_seq; Type: SEQUENCE; Schema: public; Owner: mspr502
--

CREATE SEQUENCE public.statement_id_statement_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.statement_id_statement_seq OWNER TO mspr502;

--
-- Name: statement_id_statement_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mspr502
--

ALTER SEQUENCE public.statement_id_statement_seq OWNED BY public.statement.id_statement;


--
-- Name: users; Type: TABLE; Schema: public; Owner: mspr502
--

CREATE TABLE public.users (
    id_user integer NOT NULL,
    firstname character varying(255) NOT NULL,
    lastname character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    password character varying(255) NOT NULL,
    isadmin boolean DEFAULT false
);


ALTER TABLE public.users OWNER TO mspr502;

--
-- Name: users_id_user_seq; Type: SEQUENCE; Schema: public; Owner: mspr502
--

CREATE SEQUENCE public.users_id_user_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_user_seq OWNER TO mspr502;

--
-- Name: users_id_user_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mspr502
--

ALTER SEQUENCE public.users_id_user_seq OWNED BY public.users.id_user;


--
-- Name: climat_type id_climat_type; Type: DEFAULT; Schema: public; Owner: mspr502
--

ALTER TABLE ONLY public.climat_type ALTER COLUMN id_climat_type SET DEFAULT nextval('public.climat_type_id_climat_type_seq'::regclass);


--
-- Name: continent id_continent; Type: DEFAULT; Schema: public; Owner: mspr502
--

ALTER TABLE ONLY public.continent ALTER COLUMN id_continent SET DEFAULT nextval('public.continent_id_continent_seq'::regclass);


--
-- Name: country id_country; Type: DEFAULT; Schema: public; Owner: mspr502
--

ALTER TABLE ONLY public.country ALTER COLUMN id_country SET DEFAULT nextval('public.country_id_country_seq'::regclass);


--
-- Name: disease id_disease; Type: DEFAULT; Schema: public; Owner: mspr502
--

ALTER TABLE ONLY public.disease ALTER COLUMN id_disease SET DEFAULT nextval('public.disease_id_disease_seq'::regclass);


--
-- Name: log id_log; Type: DEFAULT; Schema: public; Owner: mspr502
--

ALTER TABLE ONLY public.log ALTER COLUMN id_log SET DEFAULT nextval('public.log_id_log_seq'::regclass);


--
-- Name: metrics id_metrics; Type: DEFAULT; Schema: public; Owner: mspr502
--

ALTER TABLE ONLY public.metrics ALTER COLUMN id_metrics SET DEFAULT nextval('public.metrics_id_metrics_seq'::regclass);


--
-- Name: prediction id_prediction; Type: DEFAULT; Schema: public; Owner: mspr502
--

ALTER TABLE ONLY public.prediction ALTER COLUMN id_prediction SET DEFAULT nextval('public.prediction_id_prediction_seq'::regclass);


--
-- Name: region id_region; Type: DEFAULT; Schema: public; Owner: mspr502
--

ALTER TABLE ONLY public.region ALTER COLUMN id_region SET DEFAULT nextval('public.region_id_region_seq'::regclass);


--
-- Name: statement id_statement; Type: DEFAULT; Schema: public; Owner: mspr502
--

ALTER TABLE ONLY public.statement ALTER COLUMN id_statement SET DEFAULT nextval('public.statement_id_statement_seq'::regclass);


--
-- Name: users id_user; Type: DEFAULT; Schema: public; Owner: mspr502
--

ALTER TABLE ONLY public.users ALTER COLUMN id_user SET DEFAULT nextval('public.users_id_user_seq'::regclass);


--
-- Name: climat_type climat_type_name_key; Type: CONSTRAINT; Schema: public; Owner: mspr502
--

ALTER TABLE ONLY public.climat_type
    ADD CONSTRAINT climat_type_name_key UNIQUE (name);


--
-- Name: climat_type climat_type_pkey; Type: CONSTRAINT; Schema: public; Owner: mspr502
--

ALTER TABLE ONLY public.climat_type
    ADD CONSTRAINT climat_type_pkey PRIMARY KEY (id_climat_type);


--
-- Name: continent continent_name_key; Type: CONSTRAINT; Schema: public; Owner: mspr502
--

ALTER TABLE ONLY public.continent
    ADD CONSTRAINT continent_name_key UNIQUE (name);


--
-- Name: continent continent_pkey; Type: CONSTRAINT; Schema: public; Owner: mspr502
--

ALTER TABLE ONLY public.continent
    ADD CONSTRAINT continent_pkey PRIMARY KEY (id_continent);


--
-- Name: country_climat_type country_climat_type_pkey; Type: CONSTRAINT; Schema: public; Owner: mspr502
--

ALTER TABLE ONLY public.country_climat_type
    ADD CONSTRAINT country_climat_type_pkey PRIMARY KEY (id_climat_type, id_country);


--
-- Name: country country_pkey; Type: CONSTRAINT; Schema: public; Owner: mspr502
--

ALTER TABLE ONLY public.country
    ADD CONSTRAINT country_pkey PRIMARY KEY (id_country);


--
-- Name: disease disease_pkey; Type: CONSTRAINT; Schema: public; Owner: mspr502
--

ALTER TABLE ONLY public.disease
    ADD CONSTRAINT disease_pkey PRIMARY KEY (id_disease);


--
-- Name: prediction prediction_pkey; Type: CONSTRAINT; Schema: public; Owner: mspr502
--

ALTER TABLE ONLY public.prediction
    ADD CONSTRAINT prediction_pkey PRIMARY KEY (id_prediction);


--
-- Name: region region_pkey; Type: CONSTRAINT; Schema: public; Owner: mspr502
--

ALTER TABLE ONLY public.region
    ADD CONSTRAINT region_pkey PRIMARY KEY (id_region);


--
-- Name: statement statement_pkey; Type: CONSTRAINT; Schema: public; Owner: mspr502
--

ALTER TABLE ONLY public.statement
    ADD CONSTRAINT statement_pkey PRIMARY KEY (id_statement);


--
-- Name: users user_pkey; Type: CONSTRAINT; Schema: public; Owner: mspr502
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT user_pkey PRIMARY KEY (id_user);


--
-- Name: country_climat_type country_climat_type_id_climat_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mspr502
--

ALTER TABLE ONLY public.country_climat_type
    ADD CONSTRAINT country_climat_type_id_climat_type_fkey FOREIGN KEY (id_climat_type) REFERENCES public.climat_type(id_climat_type);


--
-- Name: country_climat_type country_climat_type_id_country_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mspr502
--

ALTER TABLE ONLY public.country_climat_type
    ADD CONSTRAINT country_climat_type_id_country_fkey FOREIGN KEY (id_country) REFERENCES public.country(id_country);


--
-- Name: country country_id_continent_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mspr502
--

ALTER TABLE ONLY public.country
    ADD CONSTRAINT country_id_continent_fkey FOREIGN KEY (id_continent) REFERENCES public.continent(id_continent);


--
-- Name: country country_id_region_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mspr502
--

ALTER TABLE ONLY public.country
    ADD CONSTRAINT country_id_region_fkey FOREIGN KEY (id_region) REFERENCES public.region(id_region);


--
-- Name: metrics metrics_id_country_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mspr502
--

ALTER TABLE ONLY public.metrics
    ADD CONSTRAINT metrics_id_country_fkey FOREIGN KEY (id_country) REFERENCES public.country(id_country);


--
-- Name: prediction prediction_id_country_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mspr502
--

ALTER TABLE ONLY public.prediction
    ADD CONSTRAINT prediction_id_country_fkey FOREIGN KEY (id_country) REFERENCES public.country(id_country);


--
-- Name: prediction prediction_id_disease_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mspr502
--

ALTER TABLE ONLY public.prediction
    ADD CONSTRAINT prediction_id_disease_fkey FOREIGN KEY (id_disease) REFERENCES public.disease(id_disease);


--
-- Name: statement statement_id_country_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mspr502
--

ALTER TABLE ONLY public.statement
    ADD CONSTRAINT statement_id_country_fkey FOREIGN KEY (id_country) REFERENCES public.country(id_country);


--
-- Name: statement statement_id_disease_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mspr502
--

ALTER TABLE ONLY public.statement
    ADD CONSTRAINT statement_id_disease_fkey FOREIGN KEY (id_disease) REFERENCES public.disease(id_disease);


ALTER TABLE ONLY public.log
    ADD CONSTRAINT log_id_country_fkey FOREIGN KEY (id_country) REFERENCES public.country(id_country);


--
-- PostgreSQL database dump complete
--

