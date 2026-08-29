"""Run `mlc_llm compile` with Windows TVM compat shims (same as package launcher)."""
from __future__ import annotations

import os
import sys
from pathlib import Path


def _dll_dirs() -> None:
    for d in (
        Path(sys.prefix) / "Lib" / "site-packages" / "tvm_ffi" / "lib",
        Path(sys.prefix) / "Lib" / "site-packages" / "tvm" / "lib",
        Path(sys.prefix) / "Lib" / "site-packages" / "mlc_llm" / "bin",
    ):
        if d.is_dir():
            os.add_dll_directory(str(d))


def main() -> int:
    os.environ.pop("TVM_USE_RUNTIME_LIB", None)
    os.environ.setdefault("TVM_BACKTRACE", "1")
    _dll_dirs()
    print("import tvm...", flush=True)
    import tvm  # noqa: F401

    here = Path(__file__).resolve().parent
    for cand in (here / "mlc_tvm_compat.py", Path(r"C:\src\mlc_tvm_compat.py")):
        if cand.is_file():
            sys.path.insert(0, str(cand.parent))
            import mlc_tvm_compat

            mlc_tvm_compat.apply()
            print(f"shim {cand}", flush=True)
            break

    # Smoke: importing compile pulls compiler_pass (prior is_size_var crash site).
    print("import mlc_llm.cli.compile...", flush=True)
    from mlc_llm.cli import compile as cli

    print("compile CLI ready", flush=True)
    cli.main(sys.argv[1:])
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
