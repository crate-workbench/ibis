from __future__ import annotations

# Copyright 2015 Cloudera Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
import os
from typing import TYPE_CHECKING, Any

import pytest
import sqlalchemy as sa

import ibis
from ibis import util
from ibis.backends.conftest import recreate_database
from ibis.backends.tests.base import RoundHalfToEven, ServiceBackendTest

if TYPE_CHECKING:
    from collections.abc import Iterable
    from pathlib import Path

CRATEDB_USER = os.environ.get("IBIS_TEST_CRATEDB_USER", "crate")
CRATEDB_PASS = os.environ.get("IBIS_TEST_CRATEDB_PASSWORD", "")
CRATEDB_HOST = os.environ.get("IBIS_TEST_CRATEDB_HOST", "localhost")
CRATEDB_PORT = os.environ.get("IBIS_TEST_CRATEDB_PORT", 4200)
IBIS_TEST_CRATEDB_DB = os.environ.get("IBIS_TEST_CRATEDB_DATABASE", "ibis_testing")


class TestConf(ServiceBackendTest, RoundHalfToEven):
    # postgres rounds half to even for double precision and half away from zero
    # for numeric and decimal

    returned_timestamp_unit = "s"
    supports_structs = False
    service_name = "cratedb"
    deps = "crate", "sqlalchemy"

    @property
    def test_files(self) -> Iterable[Path]:
        return self.data_dir.joinpath("csv").glob("*.csv")

    def _load_data(
        self,
        *,
        user: str = CRATEDB_USER,
        password: str = CRATEDB_PASS,
        host: str = CRATEDB_HOST,
        port: int = CRATEDB_PORT,
        database: str = IBIS_TEST_CRATEDB_DB,
        **_: Any,
    ) -> None:
        """Load test data into a CrateDB backend instance.

        Parameters
        ----------
        data_dir
            Location of test data
        script_dir
            Location of scripts defining schemas
        """
        init_database(
            url=sa.engine.make_url(
                #f"crate://{user}:{password}@{host}:{port:d}/{database}"
                f"crate://{user}:{password}@{host}:{port:d}/"
            ),
            database=database,
            schema=self.ddl_script,
            isolation_level=None,
            recreate=False,
            echo=True,
        )

    @staticmethod
    def connect(*, tmpdir, worker_id, port: int | None = None, **kw):
        return ibis.cratedb.connect(
            host=CRATEDB_HOST,
            port=port or CRATEDB_PORT,
            user=CRATEDB_USER,
            password=CRATEDB_PASS,
            database=IBIS_TEST_CRATEDB_DB,
            **kw,
        )


@pytest.fixture(scope="session")
def con(tmp_path_factory, data_dir, worker_id):
    return TestConf.load_data(data_dir, tmp_path_factory, worker_id).connection


@pytest.fixture(scope="module")
def db(con):
    print("con")
    return con.database()


@pytest.fixture(scope="module")
def alltypes(db):
    print("alltypes-local")
    return db.functional_alltypes


@pytest.fixture(scope="module")
def geotable(con):
    return con.table("geo")


@pytest.fixture(scope="module")
def df(alltypes):
    return alltypes.execute()


@pytest.fixture(scope="module")
def gdf(geotable):
    return geotable.execute()


@pytest.fixture(scope="module")
def alltypes_sqla(con, alltypes):
    name = alltypes.op().name
    return con._get_sqla_table(name)


@pytest.fixture(scope="module")
def intervals(con):
    return con.table("intervals")


@pytest.fixture
def translate():
    from ibis.backends.cratedb import Backend

    context = Backend.compiler.make_context()
    return lambda expr: Backend.compiler.translator_class(expr, context).get_result()


def init_database(
    url: sa.engine.url.URL,
    database: str,
    schema: Iterable[str] | None = None,
    recreate: bool = True,
    isolation_level: str | None = "AUTOCOMMIT",
    **kwargs: Any,
) -> sa.engine.Engine:
    """Initialise `database` at `url` with `schema`.

    If `recreate`, drop the `database` at `url`, if it exists.

    Parameters
    ----------
    url : url.sa.engine.url.URL
        Connection url to the database
    database : str
        Name of the database to be dropped
    schema : TextIO
        File object containing schema to use
    recreate : bool
        If true, drop the database if it exists
    isolation_level : str
        Transaction isolation_level

    Returns
    -------
    sa.engine.Engine
        SQLAlchemy engine object
    """
    #if isolation_level is not None:
    #    kwargs["isolation_level"] = isolation_level

    if recreate:
        recreate_database(url, database, **kwargs)

    #try:
    #    url.database = database
    #except AttributeError:
    #    url = url.set(database=database)

    engine = sa.create_engine(url, **kwargs)

    if schema:
        with engine.begin() as conn:
            util.consume(map(conn.exec_driver_sql, schema))

    return engine
