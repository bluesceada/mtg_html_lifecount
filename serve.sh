#!/bin/sh
set -e

PORT="${1:-8000}"
PYTHON="python3"

if [ -x "./.venv/bin/python" ]; then
    PYTHON="./.venv/bin/python"
fi

printf 'Serving on http://0.0.0.0:%s/\n' "$PORT"
exec "$PYTHON" -m http.server "$PORT" --bind 0.0.0.0
