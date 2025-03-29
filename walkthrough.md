## About

Todo.

## Development Sandbox
```shell
python3 -m venv .venv
source .venv/bin/activate
poetry install --with=dev,test,docs --extras=duckdb --extras=postgres --extras=cratedb
```

### Tests for DuckDB
```shell
pytest ibis/backends/duckdb/
```

### Tests for PostgreSQL
```shell
#docker run --rm -it --publish=5432:5432 --env "POSTGRES_HOST_AUTH_METHOD=trust" postgres:15 postgres -c log_statement=all

docker compose up postgres
pytest ibis/backends/postgres
```



## Errors

CASCADE

COPY batting FROM '/data/batting.csv' WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',');
sqlalchemy.exc.ProgrammingError: (crate.client.exceptions.ProgrammingError) SQLParseException[line 1:58: missing '=' at 'CSV']


INSERT INTO tzone
    SELECT
	CAST('2017-05-28 11:01:31.000400' AS TIMESTAMP WITH TIME ZONE) +
	    t * INTERVAL '1 day 1 microsecond' AS ts,
	CHR(97 + t) AS key,
	t + t / 10.0 AS value
    FROM generate_series(0, 9) AS t;

UnsupportedFunctionException[Unknown function: (t.t * cast('1 day 1 microsecond' AS interval)), no overload found for matching argument types: (integer, interval)


-- FIXME: Freezes CrateDB
-- COPY geo FROM '/data/geo.csv' WITH (FORMAT='csv', HEADER=TRUE, DELIMITER=',');


    @sa.event.listens_for(engine, "connect")
    def connect(dbapi_connection, connection_record):
>       with dbapi_connection.cursor() as cur:
E       TypeError: 'Cursor' object does not support the context manager protocol


AttributeError: type object 'CrateCompiler' has no attribute 'translator_class'
