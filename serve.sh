#!/bin/sh
set -e

PORT="${1:-8000}"
PYTHON="python3"

if [ -x "./.venv/bin/python" ]; then
    PYTHON="./.venv/bin/python"
fi

# Try to resolve the LAN IP address using Python
LAN_IP=$($PYTHON -c "import socket
try:
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.connect(('10.255.255.255', 1))
    print(s.getsockname()[0])
    s.close()
except Exception:
    print('localhost')
" 2>/dev/null || echo "localhost")

printf 'Serving on:\n'
printf '  Local:   http://localhost:%s/\n' "$PORT"
if [ "$LAN_IP" != "localhost" ]; then
    printf '  Network: http://%s:%s/\n' "$LAN_IP" "$PORT"
fi

exec "$PYTHON" -m http.server "$PORT" --bind 0.0.0.0