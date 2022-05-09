--
-- PostgreSQL database dump
--

-- Dumped from database version 14.2
-- Dumped by pg_dump version 14.2

-- Started on 2022-05-08 16:19:00

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
    grade numeric(3,1) NOT NULL
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
25	Selina Kyle / Catwoman	18	1	actress
26	\N	20	15	director
27	Marty McFly	19	15	actor
28	\N	20	16	director
29	Marty McFly	19	16	actor
30	Dr. Emmet Brown	21	15	actor
31	Dr. Emmet Brown	21	16	actor
32	\N	20	17	director
33	Dr. Emmet Brown	21	17	actor
34	Marty McFly	19	17	actor
35	\N	22	18	director
36	Cooper	23	18	actor
37	\N	24	19	director
38	Valdis	25	19	actor
39	\N	27	20	director
40	Truman Burbank	26	20	actor
41	\N	28	21	director
42	Johnny	28	21	actor
43	\N	29	22	director
44	Carl	26	22	actor
45	\N	30	23	director
46	Jesse Pinkman	31	23	actor
47	\N	32	24	director
49	Tina Carlyle	33	24	actress
48	Stanley Ipkiss / The Mask	26	24	actor
50	\N	34	25	director
51	Ace Ventura	26	25	actor
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
11	4	15
12	20	15
13	7	15
14	7	16
15	4	16
16	20	16
17	4	17
18	7	17
19	20	17
20	4	18
21	10	18
22	20	18
23	3	19
24	18	19
25	21	19
26	7	19
27	7	20
28	10	20
29	10	21
30	19	21
31	7	22
32	19	22
33	3	23
34	8	23
35	10	23
36	3	24
37	12	24
38	7	24
39	19	24
40	8	24
41	3	25
42	18	25
43	24	25
44	7	25
\.


--
-- TOC entry 3377 (class 0 OID 16442)
-- Dependencies: 211
-- Data for Name: movies; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.movies (id, name, year, duration, studio, language, age_rating, imdb_score, short_description) FROM stdin;
1	The Batman	2022	176	Warner Bros. Pictures	English	PG-13	8.0	When a sadistic serial killer begins murdering key political figures in Gotham, Batman is forced to investigate the city's hidden corruption and question his family's involvement.
15	Back to the Future	1985	116	Universal Pictures	English	PG	8.5	Marty McFly, a typical American teenager of the Eighties, is accidentally sent back to 1955 in a plutonium-powered DeLorean "time machine" invented by a slightly mad scientist. During his often hysterical, always amazing trip back in time, Marty must make certain his teenage parents-to-be meet and fall in love - so he can get back to the future.
16	Back to the Future Part II	1989	108	Universal Pictures	English	PG	7.8	After visiting 2015, Marty McFly must repeat his visit to 1955 to prevent disastrous changes to 1985...without interfering with his first trip.
17	Back to the Future Part III	1990	118	Universal Pictures	English	PG	7.4	Stranded in 1955, Marty McFly learns about the death of Doc Brown in 1885 and must travel back in time to save him. With no fuel readily available for the DeLorean, the two must figure how to escape the Old West before Emmett is murdered.
18	Interstellar	2014	169	Paramount Pictures	English	PG-13	8.6	With our time on Earth coming to an end, a team of explorers undertakes the most important mission in human history, traveling beyond this galaxy to discover whether mankind has a future among the stars.
19	Tulnukas	2006	21	Parunid ja Vonid	Estonian	Mature	\N	Saanud tüli käigus labidaga löögi pähe, unustab rullnokk Valdis ära kõik, mis tema igapäevases jõmmielus normaalne oli. Kuigi sõbrad üritavad Valdise mälu virgutada, muutub mõistmatu noormees erinevusi vihkavas ühiskonnas peagi häirivalt üleliigseks ning tema pääsemine ei ole sugugi lihtne.
20	The Truman Show	1998	103	Paramount Pictures	English	PG	8.2	An insurance salesman discovers his whole life is actually a reality TV show.
21	The Room	2003	99	\N	English	R	3.6	Johnny is a successful bank executive who lives quietly in a San Francisco townhouse with his fiancée, Lisa. One day, putting aside any scruple, she seduces Johnnys best friend, Mark. From there, nothing will be the same again.
22	Yes Man	2008	104	Warner Bros. Pictures	English	PG-13	6.8	A man challenges himself to say "yes" to everything.
23	El Camino	2019	122	Netflix	English	TV-MA	7.3	In the wake of his dramatic escape from captivity, Jesse must come to terms with his past in order to forge some kind of future.
24	The Mask	1994	101	New Line Cinema	English	TV-PG	6.9	An ancient mask transforms a mild-mannered bank clerk (Carrey) into a manic Superdude.
25	Ace Ventura: Pet Detective	1994	86	Warner Bros. Pictures	English	PG-13	6.9	A goofy detective specializing in animals goes in search of the missing mascot of the Miami Dolphins.
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
18	Zoë Kravitz	American
19	Michael J. Fox	Canadian
20	Robert Zemeckis	American
21	Christopher Lloyd	American
22	Christopher Nolan	British
23	Matthew McConaughey	American
24	Rasmus Merivoo	Estonian
25	Märt Avandi	Estonian
27	Peter Weir	Australian
26	Jim Carrey	American / Canadian
28	Tommy Wiseau	American
29	Peyton Reed	American
30	Vince Gilligan	American
31	Aaron Paul	American
32	Chuck Russell	American
33	Cameron Diaz	American
34	Tom Shadyac	American
\.


--
-- TOC entry 3389 (class 0 OID 16539)
-- Dependencies: 223
-- Data for Name: review; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.review (id, movies_id, reviewer_id, text_review, grade) FROM stdin;
1	1	2	The try-hard Batman movie: Everything about this movie is trying too hard - the over dramatic score, the long shots on characters faces, the overacting, the complex crime story - it all feels it's trying to get an Oscar in every moment. It's overly long, drawn out, and the story feels like a generic crime saga that has the Batman universe shoehorned into it.This movie is not a masterpiece, but it spends a lot of effort making you think it is!	5.0
2	1	1	Overlong but quite strong as an origin story that works on an emotional level by the end. The cast handles this material well, making it more of a detective yarn with hints of commentary about privilege by the end that could''ve been fleshed out more.	8.0
40	23	3		8.2
41	24	22	This showcase for the talents of Jim Carrey is adroitly directed, viscerally and visually dynamic and just plain fun.	8.0
42	24	23	This is without doubt one of Jim Carreys best movies.	10.0
43	24	3		7.9
44	25	3		8.5
45	25	24	Seemingly clueless as to how best to utilize Carrey, or make humorous hay out of its pet-loving shamus central character, Ventura fails to place either Carrey or Ace in the winners circle of memorable screen crazies.	4.0
19	15	12	Back To The Future is such an inventive and exciting piece of filmmaking that it is impossible to forget about it. The casting of every character involved was absolutely perfect, and the performances were spectacular. I first saw this film when I was six years old, and it is the only movie that I know of that I dont think I could ever get sick of.	10.0
20	15	13	There arent many films we would describe as perfect, but Robert Zemeckis oh-so-80s time travel tale fits the bill.	10.0
23	16	14	It twists it, shakes it and stands it on its ear. But as before, the films technical brilliance is the least of its appeals. Satirically acute, intricately structured and deftly paced, it is at heart stout, good and untainted by easy sentiment.	9.0
24	16	15	While not as good as the original, this sequel still maintains the feel and charm of it predessor and is a worthy follow up.	8.0
25	17	14	Future III is all smiles, nostalgically respectful of the western genre, serenely sure of the strength of its own more immediate heritage and of our affection for it.	8.0
26	17	16	It too has no particular reason for being (except, of course, to complete the series and cash in). Its sprightly and inoffensive, though. And, for those who care, it satisfyingly ties up the various plot strands that were flapping in the breeze from the last installment. Back to the Future futurists will feel complete.	5.0
28	18	17	Interstellar turns out to be the rarest beast in the Hollywood jungle. Its a mass audience picture thats intelligent as well as epic, with a sophisticated script thats as interested in emotional moments as immerisive visuals. Which is saying a lot.	9.0
29	18	18	With Interstellar, Nolans reach occasionally exceeds his grasp. Thats fine, these days, few other filmmakers dare reach so high to strech our mids so wide.	8.0
46	25	25	He is so over-energized from the start you keep thinking he will wear out his welcome pronto, an hour and a half later, his lunacy is still hard to take your eyes off.	8.0
21	15	3	One of my favorite trilogies ever, timeless.	10.0
22	16	3	Loved the movie, still no hoverboards :(	10.0
27	18	3	Great movie, greater soundtrack by Hans Zimmer.	9.2
3	1	3	Pretty good, I liked it :)	8.4
31	20	18	Hollywoods smartest media satire in years - and a breathrough for Jim Carrey.	9.0
32	20	17	Adventurous, provocative, even daring.	10.0
33	20	3		7.4
34	21	19	A movie that prompts most of its viewers to ask for their money back — before even 30 minutes have passed. Maybe that has something to do with the extreme unpleasantness of watching Wiseau (as banker Johnny) and actress Juliette Danielle (as his fiancee) engage in a series of soft-core sex scenes, or with the overall ludicrousness of a film whose primary goal, apparently, is to convince us that the freakish Wiseau is actually a normal, everyday sort of guy.	1.0
35	22	18	Though the movie is no more than agreeable, it does provide a swell showcase for New Zealand wundercomic Rhys Darby ()[and gives the astrally adorable Zooey Deschanel a rare shot at a lead role in a big Hollywood movie.	5.0
36	22	20	Genial but slim, picture is certainly a light-hearted alternative to weighty year-end awards bait, but the conceit is not realized fully enough.	6.0
30	19	3	National classic.	10.1
37	22	3		6.4
38	23	16	El Camino is not horrible, but it is not commendable either, and given the legacy of Breaking Bad, mildly enteraining is not good enough.	5.0
39	23	21	Its a true movie, with the taut pacing, satisfying conclusion and grand visual scale that distinction implies.	8.0
\.


--
-- TOC entry 3387 (class 0 OID 16530)
-- Dependencies: 221
-- Data for Name: reviewer; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reviewer (id, name, publication) FROM stdin;
1	Jim Laczkowski	Director's Club
2	tloader-1	\N
12	Anonymous_Maxine	\N
13	Tom Huddleston	TimeOut
14	Richard Schickel	TIME
15	geewah	\N
16	Peter Rainer	Los Angeles Times
17	Kenneth Turan	Los Angeles Times
18	Richard Corliss	TIME
19	Scott Foundas	Variety
20	Brian Lowry	Variety
21	Judy Berman	TIME
22	Leonard Klady	Variety
23	danielb1982	\N
3	Kristjan Henri Roots	admin
24	Steven Gaydos	Variety
25	Chris Willman	Los Angeles Times
\.


--
-- TOC entry 3403 (class 0 OID 0)
-- Dependencies: 214
-- Name: characters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.characters_id_seq', 51, true);


--
-- TOC entry 3404 (class 0 OID 0)
-- Dependencies: 216
-- Name: genres_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.genres_id_seq', 27, true);


--
-- TOC entry 3405 (class 0 OID 0)
-- Dependencies: 218
-- Name: movie_genres_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.movie_genres_id_seq', 44, true);


--
-- TOC entry 3406 (class 0 OID 0)
-- Dependencies: 210
-- Name: movies_movie_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.movies_movie_id_seq', 25, true);


--
-- TOC entry 3407 (class 0 OID 0)
-- Dependencies: 212
-- Name: people_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.people_id_seq', 34, true);


--
-- TOC entry 3408 (class 0 OID 0)
-- Dependencies: 222
-- Name: review_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.review_id_seq', 46, true);


--
-- TOC entry 3409 (class 0 OID 0)
-- Dependencies: 220
-- Name: reviewer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reviewer_id_seq', 25, true);


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
-- TOC entry 3214 (class 2606 OID 16609)
-- Name: characters unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.characters
    ADD CONSTRAINT "unique" UNIQUE (name, people_id, movies_id, profession);


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


-- Completed on 2022-05-08 16:19:00

--
-- PostgreSQL database dump complete
--

