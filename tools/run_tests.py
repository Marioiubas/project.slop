#!/usr/bin/env python3
"""Run source compilation, pure invariants, and the engine-double acceptance tests."""
from pathlib import Path
import argparse
import os
import subprocess
import tempfile
from build_command_bar import ROOT, literal, build

parser = argparse.ArgumentParser()
parser.add_argument("--luau", default=os.environ.get("LUAU_BIN", "luau"))
parser.add_argument("--compiler", default=os.environ.get("LUAU_COMPILER", "luau-compile"))
parser.add_argument("--analyzer", help="Run strict analysis on the engine-independent modules")
args = parser.parse_args()
subprocess.run(["python3", str(ROOT / "tools/build_command_bar.py"), "--check"], check=True)
files = sorted((ROOT / "src").rglob("*.lua")) + [ROOT / "dist/OddvaultCommandBar.lua"] + sorted((ROOT / "tests").glob("*.luau"))
subprocess.run([args.compiler, "--null", *map(str, files)], check=True)
if args.analyzer:
    pure = sorted((ROOT / "src/world/shared").glob("*.lua")) + [ROOT / "src/world/server/RiftCellAllocator.lua"]
    subprocess.run([args.analyzer, *(str(path.relative_to(ROOT)) for path in pure)], cwd=ROOT, check=True)
subprocess.run([args.luau, str(ROOT / "tests/invariants.luau")], check=True)
bundle, _ = build()
# Temporary runner sits next to the tests for Luau's relative require resolution.
with tempfile.NamedTemporaryFile(mode="w", suffix=".luau", dir=ROOT / "tests", prefix=".acceptance-", delete=False) as handle:
    runner = Path(handle.name)
    handle.write('local Mock = require("./engine_mock")\nlocal env = Mock.new()\n')
    handle.write("local installer = assert(loadstring(" + literal(bundle) + ', "OddvaultCommandBar"))\nsetfenv(installer, env)\ninstaller()\n')
    handle.write((ROOT / "tests/acceptance_body.luau").read_text())
try:
    subprocess.run([args.luau, str(runner)], check=True)
finally:
    runner.unlink(missing_ok=True)
