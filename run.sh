#!/usr/bin/env bash
# telc B1 Training — startet die App lokal und öffnet sie im Browser.
#
#   ./run.sh              Server auf dem ersten freien Port ab 8000
#   ./run.sh 9000         fester Port
#   ./run.sh --no-open    ohne Browser (z. B. auf einem Server)
#   ./run.sh --bundle     baut zusätzlich die Einzeldatei-Version
#
# Die App ist reines HTML/CSS/JS — es wird nichts installiert und nichts
# gebaut. Ein Server ist trotzdem nötig: über file:// verweigert der
# Browser fetch() und den Service Worker, die App bliebe leer.

set -euo pipefail
cd "$(dirname "$0")"

PORT=""
OPEN=1
BUNDLE=0

for arg in "$@"; do
  case "$arg" in
    --no-open) OPEN=0 ;;
    --bundle)  BUNDLE=1 ;;
    -h|--help) sed -n '2,11p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    ''|*[!0-9]*) echo "Unbekannte Option: $arg" >&2; exit 1 ;;
    *) PORT="$arg" ;;
  esac
done

PY=$(command -v python3 || command -v python || true)
if [ -z "$PY" ]; then
  echo "python3 wird gebraucht, ist aber nicht installiert." >&2
  echo "  Debian/Ubuntu/Pop!_OS:  sudo apt install python3" >&2
  exit 1
fi

# Sanity-Check: ohne data/index.json startet die App nicht.
if [ ! -f data/index.json ]; then
  echo "data/index.json fehlt — bitte im Projektordner ausführen." >&2
  exit 1
fi

# Freien Port suchen, damit ein zweiter Start nicht an "Address already
# in use" scheitert.
free_port() {
  "$PY" - "$1" <<'EOF'
import socket, sys
start = int(sys.argv[1])
for p in range(start, start + 50):
    with socket.socket() as s:
        try:
            s.bind(('127.0.0.1', p))
        except OSError:
            continue
        print(p)
        break
else:
    sys.exit(1)
EOF
}

if [ -n "$PORT" ]; then
  PICKED="$PORT"
else
  PICKED=$(free_port 8000) || { echo "Kein freier Port ab 8000 gefunden." >&2; exit 1; }
fi

URL="http://localhost:$PICKED/"

if [ "$BUNDLE" = 1 ]; then
  echo "Baue Einzeldatei-Version …"
  "$PY" tools/bundle.py telc-b1-standalone.html
fi

# Server im Hintergrund, damit wir danach den Browser öffnen können.
"$PY" -m http.server "$PICKED" --bind 127.0.0.1 >/dev/null 2>&1 &
SRV=$!
trap 'kill $SRV 2>/dev/null || true' EXIT INT TERM

# Warten bis der Port wirklich antwortet (max. 5 s).
for _ in $(seq 1 50); do
  if "$PY" -c "import socket,sys; s=socket.socket(); s.settimeout(.2); sys.exit(s.connect_ex(('127.0.0.1',$PICKED)))" 2>/dev/null; then
    break
  fi
  sleep 0.1
done

if ! kill -0 "$SRV" 2>/dev/null; then
  echo "Server konnte nicht starten — Port $PICKED evtl. belegt." >&2
  exit 1
fi

echo "telc B1 Training läuft auf  $URL"
echo "Zum Beenden: Strg-C"

if [ "$OPEN" = 1 ]; then
  # Erstbeste vorhandene Methode; scheitert sie, ist das kein Fehler —
  # der Link steht ja oben.
  ( xdg-open "$URL" || open "$URL" || sensible-browser "$URL" ) >/dev/null 2>&1 || true
fi

wait "$SRV"
