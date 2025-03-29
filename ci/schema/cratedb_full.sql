DROP TABLE IF EXISTS diamonds;

CREATE TABLE diamonds (
    carat FLOAT,
    cut TEXT,
    color TEXT,
    clarity TEXT,
    depth FLOAT,
    "table" FLOAT,
    price BIGINT,
    x FLOAT,
    y FLOAT,
    z FLOAT
);

COPY diamonds FROM '/data/diamonds.csv' WITH (FORMAT='CSV', HEADER=TRUE, DELIMITER=',');

DROP TABLE IF EXISTS astronauts;

CREATE TABLE astronauts (
    "id" BIGINT,
    "number" BIGINT,
    "nationwide_number" BIGINT,
    "name" VARCHAR,
    "original_name" VARCHAR,
    "sex" VARCHAR,
    "year_of_birth" BIGINT,
    "nationality" VARCHAR,
    "military_civilian" VARCHAR,
    "selection" VARCHAR,
    "year_of_selection" BIGINT,
    "mission_number" BIGINT,
    "total_number_of_missions" BIGINT,
    "occupation" VARCHAR,
    "year_of_mission" BIGINT,
    "mission_title" VARCHAR,
    "ascend_shuttle" VARCHAR,
    "in_orbit" VARCHAR,
    "descend_shuttle" VARCHAR,
    "hours_mission" DOUBLE PRECISION,
    "total_hrs_sum" DOUBLE PRECISION,
    "field21" BIGINT,
    "eva_hrs_mission" DOUBLE PRECISION,
    "total_eva_hrs" DOUBLE PRECISION
);

COPY astronauts FROM '/data/astronauts.csv' WITH (FORMAT='CSV', HEADER=TRUE, DELIMITER=',');

DROP TABLE IF EXISTS batting;

CREATE TABLE batting (
    "playerID" TEXT,
    "yearID" BIGINT,
    stint BIGINT,
    "teamID" TEXT,
    "lgID" TEXT,
    "G" BIGINT,
    "AB" BIGINT,
    "R" BIGINT,
    "H" BIGINT,
    "X2B" BIGINT,
    "X3B" BIGINT,
    "HR" BIGINT,
    "RBI" BIGINT,
    "SB" BIGINT,
    "CS" BIGINT,
    "BB" BIGINT,
    "SO" BIGINT,
    "IBB" BIGINT,
    "HBP" BIGINT,
    "SH" BIGINT,
    "SF" BIGINT,
    "GIDP" BIGINT
);

COPY batting FROM '/data/batting.csv' WITH (FORMAT='csv', HEADER=TRUE, DELIMITER=',');

DROP TABLE IF EXISTS awards_players;

CREATE TABLE awards_players (
    "playerID" TEXT,
    "awardID" TEXT,
    "yearID" BIGINT,
    "lgID" TEXT,
    tie TEXT,
    notes TEXT
);

COPY awards_players FROM '/data/awards_players.csv' WITH (FORMAT='csv', HEADER=TRUE, DELIMITER=',');

DROP VIEW IF EXISTS awards_players_special_types;
CREATE VIEW awards_players_special_types AS
SELECT
    "playerID", "awardID", "yearID"
FROM
    awards_players
WHERE
    "awardID" = 'Triple Crown';

DROP TABLE IF EXISTS functional_alltypes;

CREATE TABLE functional_alltypes (
    id INTEGER,
    bool_col BOOLEAN,
    tinyint_col SMALLINT,
    smallint_col SMALLINT,
    int_col INTEGER,
    bigint_col BIGINT,
    float_col REAL,
    double_col DOUBLE PRECISION,
    date_string_col TEXT,
    string_col TEXT,
    timestamp_col TIMESTAMP WITHOUT TIME ZONE,
    year INTEGER,
    month INTEGER
);

COPY functional_alltypes FROM '/data/functional_alltypes.csv' WITH (FORMAT='csv', HEADER=TRUE, DELIMITER=',');

DROP TABLE IF EXISTS tzone;

CREATE TABLE tzone (
    ts TIMESTAMP WITH TIME ZONE,
    key TEXT,
    value DOUBLE PRECISION
);

-- A few adjustments had to be made compared to the original function.
INSERT INTO tzone
    SELECT
	CAST('2017-05-28 11:01:31.000400' AS TIMESTAMP WITH TIME ZONE) +
	    t + INTERVAL '1 day 1 second' AS ts,
	CHR(97 + t) AS key,
	t + t / 10.0 AS value
    FROM generate_series(0, 9) AS t;

DROP TABLE IF EXISTS array_types;

-- Nested arrays are not supported.
-- The types of the columns within VALUES lists must match. Found `bigint_array` and `bigint_array_array` at position: 5
CREATE TABLE IF NOT EXISTS array_types (
    x BIGINT[],
    y TEXT[],
    z DOUBLE PRECISION[],
    grouper TEXT,
    scalar_column DOUBLE PRECISION,
    multi_dim BIGINT[]
);

INSERT INTO array_types VALUES
    (ARRAY[1, 2, 3], ARRAY['a', 'b', 'c'], ARRAY[1.0, 2.0, 3.0], 'a', 1.0, ARRAY[NULL::BIGINT, NULL, NULL, 1, 2, 3]),
    (ARRAY[4, 5], ARRAY['d', 'e'], ARRAY[4.0, 5.0], 'a', 2.0, NULL),
    (ARRAY[6, NULL], ARRAY['f', NULL], ARRAY[6.0, NULL], 'a', 3.0, ARRAY[NULL, 42, NULL]),
    (ARRAY[NULL, 1, NULL], ARRAY[NULL, 'a', NULL], ARRAY[]::DOUBLE PRECISION[], 'b', 4.0, ARRAY[]),
    (ARRAY[2, NULL, 3], ARRAY['b', NULL, 'c'], NULL, 'b', 5.0, NULL),
    (ARRAY[4, NULL, NULL, 5], ARRAY['d', NULL, NULL, 'e'], ARRAY[4.0, NULL, NULL, 5.0], 'c', 6.0, ARRAY[]);

DROP TABLE IF EXISTS films;

-- CrateDB cannot store INTERVAL and DATE types.
CREATE TABLE IF NOT EXISTS films (
    code CHAR(5) PRIMARY KEY,
    title VARCHAR(40) NOT NULL,
    did INTEGER NOT NULL,
    date_prod TIMESTAMPTZ,
    kind VARCHAR(10),
    -- extraneous input 'HOUR' expecting
    -- len INTERVAL HOUR TO MINUTE
    len TIMESTAMPTZ
);

INSERT INTO films VALUES
    ('A', 'Avengers', 1, DATE '2018-01-01', 'Action', '2018-01-01T02:35:00'::TIMESTAMPTZ),
    ('B', 'Ghostbusters', 2, DATE '2018-01-02', 'Ghost', '2018-01-02T01:30:00'::TIMESTAMPTZ);

DROP TABLE IF EXISTS geo;

CREATE TABLE geo (
    id BIGINT PRIMARY KEY,
    geo_point GEO_POINT,        -- GEOMETRY(POINT)
    geo_linestring GEO_SHAPE,   -- GEOMETRY(LINESTRING)
    geo_polygon GEO_SHAPE,      -- GEOMETRY(POLYGON)
    geo_multipolygon GEO_SHAPE  -- GEOMETRY(MULTIPOLYGON)
);

-- Use `OBJECT` instead of `JSON`.
DROP TABLE IF EXISTS json_t;
CREATE TABLE IF NOT EXISTS json_t (js OBJECT);
INSERT INTO json_t VALUES
    ('{"a": [1,2,3,4], "b": 1}'),
    ('{"a":null,"b":2}'),
    ('{"a":"foo", "c":null}'),
    ('null'),
    ('[42,47,55]'),
    ('[]');

DROP TABLE IF EXISTS win;
CREATE TABLE win (g TEXT, x BIGINT, y BIGINT);
INSERT INTO win VALUES
    ('a', 0, 3),
    ('a', 1, 2),
    ('a', 2, 0),
    ('a', 3, 1),
    ('a', 4, 1);

-- Use `OBJECT` instead of `HSTORE`.
DROP TABLE IF EXISTS map;
CREATE TABLE map (kv OBJECT);
INSERT INTO map VALUES
    ({"a" = 1, "b" = 2, "c" = 3}),
    ({"d" = 4, "e" = 5, "c" = 6});
