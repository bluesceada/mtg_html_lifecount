#!/bin/sh
set -e

GRADLE_VERSION="8.5"
GRADLE_DIR=".tools/gradle-${GRADLE_VERSION}"

python3 -m venv .venv
.venv/bin/python -m pip install nodeenv
if [ ! -x ".nodeenv/bin/node" ]; then
	.venv/bin/nodeenv --node=22.14.0 .nodeenv
fi

if [ ! -x "${GRADLE_DIR}/bin/gradle" ]; then
	.venv/bin/python - "$GRADLE_VERSION" <<'PY'
import os
import sys
import urllib.request
import zipfile

version = sys.argv[1]
archive = os.path.join(".tools", "gradle-" + version + ".zip")
url = "https://services.gradle.org/distributions/gradle-" + version + "-bin.zip"
os.makedirs(".tools", exist_ok=True)
print("Downloading Gradle " + version)
urllib.request.urlretrieve(url, archive)
with zipfile.ZipFile(archive) as package:
	package.extractall(".tools")
os.remove(archive)
PY
fi
chmod +x "${GRADLE_DIR}/bin/gradle"

printf 'Environment ready: %s\n' "$PWD/.nodeenv/bin/node"
printf 'Gradle ready: %s\n' "$PWD/${GRADLE_DIR}/bin/gradle"
