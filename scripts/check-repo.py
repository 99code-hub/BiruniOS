#!/usr/bin/env python3
"""Small, dependency-free structural checks for the BiruniOS source tree."""
from pathlib import Path
import re
import subprocess
import sys
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
required = [
    "README.md",
    "ROADMAP.md",
    "SECURITY.md",
    "kickstarts/birunios-live.ks",
    "ci/Fedora45.Dockerfile",
    "scripts/build-iso.sh",
    "scripts/build-rpms.sh",
    "scripts/build-local.sh",
    "packages/birunios-release/birunios-release.spec",
    "packages/birunios-branding/birunios-branding.spec",
    "packages/birunios-default-settings/birunios-default-settings.spec",
    "packages/birunios-welcome/birunios-welcome.spec",
    "applications/welcome/CMakeLists.txt",
    "applications/welcome/src/main.cpp",
    ".github/workflows/validate.yml",
    ".github/workflows/build-rpms.yml",
    ".github/workflows/build-iso.yml",
]
errors = []
for item in required:
    if not (ROOT / item).is_file():
        errors.append(f"Missing required file: {item}")

ks = ROOT / "kickstarts/birunios-live.ks"
if ks.exists():
    content = ks.read_text(encoding="utf-8")
    for marker in ("#version=F45", "@^kde-desktop-environment", "anaconda-live", "dracut-live", "birunios-release", "shutdown", "%packages", "%post"):
        if marker not in content:
            errors.append(f"Kickstart is missing expected marker: {marker}")

for script in (ROOT / "scripts").glob("*.sh"):
    result = subprocess.run(["bash", "-n", str(script)], capture_output=True, text=True)
    if result.returncode:
        errors.append(f"Shell syntax error in {script.relative_to(ROOT)}: {result.stderr.strip()}")

for svg in (ROOT / "branding").rglob("*.svg"):
    try:
        ET.parse(svg)
    except ET.ParseError as exc:
        errors.append(f"Invalid SVG {svg.relative_to(ROOT)}: {exc}")

for workflow in (ROOT / ".github/workflows").glob("*.yml"):
    text = workflow.read_text(encoding="utf-8")
    if "permissions:" not in text:
        errors.append(f"Workflow must declare minimal permissions: {workflow.name}")
    if "write-all" in text:
        errors.append(f"Avoid write-all permissions: {workflow.name}")

if errors:
    print("BiruniOS repository checks FAILED:", file=sys.stderr)
    for error in errors:
        print(f" - {error}", file=sys.stderr)
    sys.exit(1)

print("BiruniOS source structure checks passed.")
print("Note: package solving, ISO composition, boot, installation, and hardware behavior require separate tests.")
