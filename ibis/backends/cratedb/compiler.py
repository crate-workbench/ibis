from __future__ import annotations

import ibis.expr.operations as ops
import ibis.expr.rules as rlz
from ibis.backends.base.sql.alchemy import AlchemyCompiler, AlchemyExprTranslator
from ibis.backends.cratedb.datatypes import CrateDBType
from ibis.backends.postgres.compiler import PostgreSQLExprTranslator
from ibis.backends.postgres.datatypes import PostgresType
from ibis.backends.postgres.registry import operation_registry


#class PostgresUDFNode(ops.Value):
#    shape = rlz.shape_like("args")


class CrateDBExprTranslator(AlchemyExprTranslator):
    _registry = operation_registry.copy()
    _rewrites = AlchemyExprTranslator._rewrites.copy()
    _has_reduction_filter_syntax = True
    _supports_tuple_syntax = True
    _dialect_name = "crate"

    # it does support it, but we can't use it because of support for pivot
    supports_unnest_in_select = False

    type_mapper = CrateDBType


rewrites = CrateDBExprTranslator.rewrites


@rewrites(ops.Any)
@rewrites(ops.All)
@rewrites(ops.NotAny)
@rewrites(ops.NotAll)
def _any_all_no_op(expr):
    return expr


class CrateDBCompiler(AlchemyCompiler):
    translator_class = CrateDBExprTranslator
