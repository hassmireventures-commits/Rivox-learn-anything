"""Launch mlc_llm package with Windows nightly TVM compatibility shims.

Importing `mlc_llm` is assumed stubbed (no native serve DLL). Call after a working
`mlc-ai-nightly` + `mlc-llm-nightly` install. See docs/MLC_ANDROID_SETUP.md.
"""
from __future__ import annotations

import os
import sys
from pathlib import Path


def _dll_dirs() -> None:
    roots = [
        Path(sys.prefix) / "Lib" / "site-packages" / "tvm_ffi" / "lib",
        Path(sys.prefix) / "Lib" / "site-packages" / "tvm" / "lib",
        Path(sys.prefix) / "Lib" / "site-packages" / "mlc_llm" / "bin",
    ]
    for d in roots:
        if d.is_dir():
            os.add_dll_directory(str(d))


def main(argv: list[str] | None = None) -> int:
    os.environ.pop("TVM_USE_RUNTIME_LIB", None)
    _dll_dirs()

    print("import tvm (cold start can take several minutes)...", flush=True)
    import tvm  # noqa: F401

    # Local shim next to this script, or C:\src\mlc_tvm_compat.py during DIY installs.
    here = Path(__file__).resolve().parent
    for cand in (here / "mlc_tvm_compat.py", Path(r"C:\src\mlc_tvm_compat.py")):
        if cand.is_file():
            sys.path.insert(0, str(cand.parent))
            import mlc_tvm_compat

            mlc_tvm_compat.apply()
            print(f"applied compat shim from {cand}", flush=True)
            break

    from mlc_llm.cli import package as pkg

    pkg.main([] if argv is None else argv)
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
