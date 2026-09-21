#!/bin/sh
set -e

python3 -m venv .venv
.venv/bin/python -m pip install nodeenv
.venv/bin/nodeenv --node=22.14.0 .nodeenv

printf 'Environment ready: %s\n' "$PWD/.nodeenv/bin/node"
