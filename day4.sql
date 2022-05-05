--
-- PostgreSQL database dump
--

-- Dumped from database version 14.2
-- Dumped by pg_dump version 14.2

-- Started on 2022-05-06 00:35:48

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
-- TOC entry 4 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO postgres;

--
-- TOC entry 3395 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- TOC entry 839 (class 1247 OID 16465)
-- Name: person_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.person_type AS ENUM (
    'actor',
    'director',
    'actress'
);


ALTER TYPE public.person_type OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 215 (class 1259 OID 16481)
-- Name: characters; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.characters (
    id integer NOT NULL,
    name text,
    people_id integer NOT NULL,
    movies_id integer NOT NULL,
    profession public.person_type NOT NULL
);


ALTER TABLE public.characters OWNER TO postgres;

--
-- TOC entry 214 (class 1259 OID 16480)
-- Name: characters_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.characters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.characters_id_seq OWNER TO postgres;

--
-- TOC entry 3396 (class 0 OID 0)
-- Dependencies: 214
-- Name: characters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.characters_id_seq OWNED BY public.characters.id;


--
-- TOC entry 217 (class 1259 OID 16502)
-- Name: genres; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.genres (
    id integer NOT NULL,
    name text NOT NULL
);


ALTER TABLE public.genres OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 16501)
-- Name: genres_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.genres_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.genres_id_seq OWNER TO postgres;

--
-- TOC entry 3397 (class 0 OID 0)
-- Dependencies: 216
-- Name: genres_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.genres_id_seq OWNED BY public.genres.id;


--
-- TOC entry 219 (class 1259 OID 16511)
-- Name: movie_genres; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.movie_genres (
    id integer NOT NULL,
    genres_id integer NOT NULL,
    movies_id integer NOT NULL
);


ALTER TABLE public.movie_genres OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 16510)
-- Name: movie_genres_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.movie_genres_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.movie_genres_id_seq OWNER TO postgres;

--
-- TOC entry 3398 (class 0 OID 0)
-- Dependencies: 218
-- Name: movie_genres_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.movie_genres_id_seq OWNED BY public.movie_genres.id;


--
-- TOC entry 211 (class 1259 OID 16442)
-- Name: movies; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.movies (
    id integer NOT NULL,
    name text NOT NULL,
    year integer,
    duration integer,
    studio text,
    language text,
    age_rating text,
    imdb_score numeric(2,1),
    short_description text
);


ALTER TABLE public.movies OWNER TO postgres;

--
-- TOC entry 210 (class 1259 OID 16441)
-- Name: movies_movie_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.movies_movie_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.movies_movie_id_seq OWNER TO postgres;

--
-- TOC entry 3399 (class 0 OID 0)
-- Dependencies: 210
-- Name: movies_movie_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.movies_movie_id_seq OWNED BY public.movies.id;


--
-- TOC entry 213 (class 1259 OID 16472)
-- Name: people; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.people (
    id integer NOT NULL,
    name text NOT NULL,
    nationality text
);


ALTER TABLE public.people OWNER TO postgres;

--
-- TOC entry 212 (class 1259 OID 16471)
-- Name: people_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.people_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.people_id_seq OWNER TO postgres;

--
-- TOC entry 3400 (class 0 OID 0)
-- Dependencies: 212
-- Name: people_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.people_id_seq OWNED BY public.people.id;


--
-- TOC entry 223 (class 1259 OID 16539)
-- Name: review; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.review (
    id integer NOT NULL,
    movies_id integer NOT NULL,
    reviewer_id integer NOT NULL,
    text_review text,
    grade numeric(2,1) NOT NULL
);


ALTER TABLE public.review OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 16538)
-- Name: review_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.review_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.review_id_seq OWNER TO postgres;

--
-- TOC entry 3401 (class 0 OID 0)
-- Dependencies: 222
-- Name: review_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.review_id_seq OWNED BY public.review.id;


--
-- TOC entry 221 (class 1259 OID 16530)
-- Name: reviewer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reviewer (
    id integer NOT NULL,
    name text NOT NULL,
    publication text
);


ALTER TABLE public.reviewer OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 16529)
-- Name: reviewer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reviewer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.reviewer_id_seq OWNER TO postgres;

--
-- TOC entry 3402 (class 0 OID 0)
-- Dependencies: 220
-- Name: reviewer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reviewer_id_seq OWNED BY public.reviewer.id;


--
-- TOC entry 3200 (class 2604 OID 16484)
-- Name: characters id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.characters ALTER COLUMN id SET DEFAULT nextval('public.characters_id_seq'::regclass);


--
-- TOC entry 3201 (class 2604 OID 16505)
-- Name: genres id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.genres ALTER COLUMN id SET DEFAULT nextval('public.genres_id_seq'::regclass);


--
-- TOC entry 3202 (class 2604 OID 16514)
-- Name: movie_genres id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.movie_genres ALTER COLUMN id SET DEFAULT nextval('public.movie_genres_id_seq'::regclass);


--
-- TOC entry 3198 (class 2604 OID 16445)
-- Name: movies id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.movies ALTER COLUMN id SET DEFAULT nextval('public.movies_movie_id_seq'::regclass);


--
-- TOC entry 3199 (class 2604 OID 16475)
-- Name: people id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.people ALTER COLUMN id SET DEFAULT nextval('public.people_id_seq'::regclass);


--
-- TOC entry 3204 (class 2604 OID 16542)
-- Name: review id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.review ALTER COLUMN id SET DEFAULT nextval('public.review_id_seq'::regclass);


--
-- TOC entry 3203 (class 2604 OID 16533)
-- Name: reviewer id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reviewer ALTER COLUMN id SET DEFAULT nextval('public.reviewer_id_seq'::regclass);


--
-- TOC entry 3381 (class 0 OID 16481)
-- Dependencies: 215
-- Data for Name: characters; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.characters (id, name, people_id, movies_id, profession) FROM stdin;
1	Bruce Wayne / Batman	1	1	actor
3	Lt. James Gordon	2	1	actor
4	\N	3	1	director
\.


--
-- TOC entry 3383 (class 0 OID 16502)
-- Dependencies: 217
-- Data for Name: genres; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.genres (id, name) FROM stdin;
3	Action
4	Adventure
5	Animation
6	Biography
7	Comedy
8	Crime
9	Documentary
10	Drama
11	Family
12	Fantasy
13	Film Noir
14	History
15	Horror
16	Music
17	Musical
18	Mystery
19	Romance
20	Sci-Fi
21	Short Film
22	Sport
23	Superhero
24	Thriller
25	War
26	Western
\.


--
-- TOC entry 3385 (class 0 OID 16511)
-- Dependencies: 219
-- Data for Name: movie_genres; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.movie_genres (id, genres_id, movies_id) FROM stdin;
1	3	1
2	8	1
3	10	1
\.


--
-- TOC entry 3377 (class 0 OID 16442)
-- Dependencies: 211
-- Data for Name: movies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.movies (id, name, year, duration, studio, language, age_rating, imdb_score, short_description) FROM stdin;
1	The Batman	2022	176	Warner Bros. Pictures	English	PG-13	8.0	When a sadistic serial killer begins murdering key political figures in Gotham, Batman is forced to investigate the city's hidden corruption and question his family's involvement.
10	test movie	2001	0	\N	\N	\N	\N	\N
\.


--
-- TOC entry 3379 (class 0 OID 16472)
-- Dependencies: 213
-- Data for Name: people; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.people (id, name, nationality) FROM stdin;
2	Jeffrey Wright	American
3	Matt Reeves	American
1	Robert Pattison	British
4	Kristjan Henri Roots	\N
10	Tester McTestface	\N
12	Testname	Estonian
13	test	eesti
\.


--
-- TOC entry 3389 (class 0 OID 16539)
-- Dependencies: 223
-- Data for Name: review; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.review (id, movies_id, reviewer_id, text_review, grade) FROM stdin;
1	1	2	The try-hard Batman movie: Everything about this movie is trying too hard - the over dramatic score, the long shots on characters faces, the overacting, the complex crime story - it all feels it's trying to get an Oscar in every moment. It's overly long, drawn out, and the story feels like a generic crime saga that has the Batman universe shoehorned into it.This movie is not a masterpiece, but it spends a lot of effort making you think it is!	5.0
2	1	1	Overlong but quite strong as an origin story that works on an emotional level by the end. The cast handles this material well, making it more of a detective yarn with hints of commentary about privilege by the end that could''ve been fleshed out more.	8.0
3	1	3	\N	8.7
9	1	7		4.0
13	1	4		9.0
14	10	4		9.0
\.


--
-- TOC entry 3387 (class 0 OID 16530)
-- Dependencies: 221
-- Data for Name: reviewer; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reviewer (id, name, publication) FROM stdin;
1	Jim Laczkowski	Director's Club
2	tloader-1	\N
3	Kristjan Henri Roots	\N
4	tester	\N
7	Average Tester	Director's Club
\.


--
-- TOC entry 3403 (class 0 OID 0)
-- Dependencies: 214
-- Name: characters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.characters_id_seq', 15, true);


--
-- TOC entry 3404 (class 0 OID 0)
-- Dependencies: 216
-- Name: genres_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.genres_id_seq', 26, true);


--
-- TOC entry 3405 (class 0 OID 0)
-- Dependencies: 218
-- Name: movie_genres_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.movie_genres_id_seq', 8, true);


--
-- TOC entry 3406 (class 0 OID 0)
-- Dependencies: 210
-- Name: movies_movie_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.movies_movie_id_seq', 10, true);


--
-- TOC entry 3407 (class 0 OID 0)
-- Dependencies: 212
-- Name: people_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.people_id_seq', 13, true);


--
-- TOC entry 3408 (class 0 OID 0)
-- Dependencies: 222
-- Name: review_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.review_id_seq', 14, true);


--
-- TOC entry 3409 (class 0 OID 0)
-- Dependencies: 220
-- Name: reviewer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reviewer_id_seq', 7, true);


--
-- TOC entry 3216 (class 2606 OID 16567)
-- Name: genres all_genres_are_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.genres
    ADD CONSTRAINT all_genres_are_unique UNIQUE (name);


--
-- TOC entry 3212 (class 2606 OID 16488)
-- Name: characters characters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.characters
    ADD CONSTRAINT characters_pkey PRIMARY KEY (id);


--
-- TOC entry 3224 (class 2606 OID 16569)
-- Name: reviewer every_reviewer_is_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reviewer
    ADD CONSTRAINT every_reviewer_is_unique UNIQUE (name);


--
-- TOC entry 3218 (class 2606 OID 16509)
-- Name: genres genres_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.genres
    ADD CONSTRAINT genres_pkey PRIMARY KEY (id);


--
-- TOC entry 3228 (class 2606 OID 16572)
-- Name: review link; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.review
    ADD CONSTRAINT link UNIQUE (movies_id, reviewer_id);


--
-- TOC entry 3220 (class 2606 OID 16516)
-- Name: movie_genres movie_genres_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.movie_genres
    ADD CONSTRAINT movie_genres_pkey PRIMARY KEY (id);


--
-- TOC entry 3206 (class 2606 OID 16450)
-- Name: movies movies_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.movies
    ADD CONSTRAINT movies_pkey PRIMARY KEY (id);


--
-- TOC entry 3208 (class 2606 OID 16470)
-- Name: movies name_is_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.movies
    ADD CONSTRAINT name_is_unique UNIQUE (name);


--
-- TOC entry 3210 (class 2606 OID 16479)
-- Name: people people_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.people
    ADD CONSTRAINT people_pkey PRIMARY KEY (id);


--
-- TOC entry 3230 (class 2606 OID 16546)
-- Name: review review_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.review
    ADD CONSTRAINT review_pkey PRIMARY KEY (id);


--
-- TOC entry 3226 (class 2606 OID 16537)
-- Name: reviewer reviewer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reviewer
    ADD CONSTRAINT reviewer_pkey PRIMARY KEY (id);


--
-- TOC entry 3214 (class 2606 OID 16597)
-- Name: characters unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.characters
    ADD CONSTRAINT "unique" UNIQUE (people_id, movies_id);


--
-- TOC entry 3222 (class 2606 OID 16518)
-- Name: movie_genres unique_genre_to_movie; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.movie_genres
    ADD CONSTRAINT unique_genre_to_movie UNIQUE (genres_id, movies_id);


--
-- TOC entry 3234 (class 2606 OID 16586)
-- Name: movie_genres genre; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.movie_genres
    ADD CONSTRAINT genre FOREIGN KEY (genres_id) REFERENCES public.genres(id) ON DELETE CASCADE NOT VALID;


--
-- TOC entry 3233 (class 2606 OID 16581)
-- Name: movie_genres movie; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.movie_genres
    ADD CONSTRAINT movie FOREIGN KEY (movies_id) REFERENCES public.movies(id) ON DELETE CASCADE NOT VALID;


--
-- TOC entry 3235 (class 2606 OID 16598)
-- Name: review movie; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.review
    ADD CONSTRAINT movie FOREIGN KEY (movies_id) REFERENCES public.movies(id) ON DELETE CASCADE NOT VALID;


--
-- TOC entry 3231 (class 2606 OID 16576)
-- Name: characters movie_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.characters
    ADD CONSTRAINT movie_id FOREIGN KEY (movies_id) REFERENCES public.movies(id) ON DELETE CASCADE NOT VALID;


--
-- TOC entry 3236 (class 2606 OID 16603)
-- Name: review person; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.review
    ADD CONSTRAINT person FOREIGN KEY (reviewer_id) REFERENCES public.reviewer(id) ON DELETE CASCADE NOT VALID;


--
-- TOC entry 3232 (class 2606 OID 16591)
-- Name: characters person_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.characters
    ADD CONSTRAINT person_id FOREIGN KEY (people_id) REFERENCES public.people(id) ON DELETE CASCADE NOT VALID;


-- Completed on 2022-05-06 00:35:48

--
-- PostgreSQL database dump complete
--

