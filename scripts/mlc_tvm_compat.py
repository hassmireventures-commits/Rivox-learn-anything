"""Compatibility shims for mlc-llm-nightly vs mlc-ai-nightly on Windows."""

from __future__ import annotations


def apply() -> None:
    import tvm.tirx as tirx
    from tvm.ir import Expr

    if not hasattr(tirx, "PrimExpr"):
        tirx.PrimExpr = Expr

    # Wheel code still uses tirx.SizeVar; current TVM only exposes Var.
    if not hasattr(tirx, "SizeVar"):
        tirx.SizeVar = tirx.Var

    # mlc_llm wheels call T.int32(is_size_var=True); current DtypeConstructor dropped that kwarg.
    try:
        from tvm.tirx.script.builder import ir as tirx_ir

        ctor = tirx_ir.DtypeConstructor
        if getattr(ctor, "_mlc_is_size_var_patched", False):
            return
        _orig_call = ctor.__call__

        def _call(self, expr=None, *args, is_size_var: bool = False, **kwargs):
            # Newer TVM treats dynamic shape symbols as plain Vars; is_size_var is ignored.
            kwargs.pop("is_size_var", None)
            if args:
                # Defensive: positional leftover after expr
                pass
            return _orig_call(self, expr)

        ctor.__call__ = _call  # type: ignore[method-assign]
        ctor._mlc_is_size_var_patched = True
    except Exception as exc:  # noqa: BLE001 — packaging bootstrap; continue with other shims
        print(f"warn: could not patch DtypeConstructor: {exc}", flush=True)
