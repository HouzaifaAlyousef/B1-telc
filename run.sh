#!/usr/bin/env bash
# التشغيل المحلّي للواجهة.
#
# التطبيق صار بيقرا محتواه من Supabase، فما عاد بده مجلد data — بس بده
# سيرفر حقيقي: fetch من file:// ممنوع، وخدمة العامل ما بتشتغل إلا على
# أصل آمن (localhost بينحسب آمن).
#
#   ./run.sh              أول منفذ فاضي من 8000
#   ./run.sh 9000         منفذ محدّد
#   ./run.sh --no-open    بلا فتح متصفّح
set -euo pipefail
cd "$(dirname "$0")"

PORT=""; OPEN=1
for a in "$@"; do
  case "$a" in
    --no-open) OPEN=0 ;;
    --help|-h) sed -n '3,13p' "$0" | sed 's/^# \?//'; exit 0 ;;
    [0-9]*)    PORT="$a" ;;
    *) echo "unbekannte Option: $a" >&2; exit 1 ;;
  esac
done

PY=$(command -v python3 || true)
[ -n "$PY" ] || { echo "python3 fehlt (apt install python3)" >&2; exit 1; }
[ -f index.html ] || { echo "bitte im Projektordner ausführen" >&2; exit 1; }

# ohne Zugangsdaten startet die App nicht — lieber jetzt sagen als im Browser
if grep -q 'YOUR-PROJECT' assets/config.js 2>/dev/null; then
  echo "⚠  assets/config.js enthält noch Platzhalter."
  echo "   Supabase → Project Settings → API → URL und anon key eintragen."
  echo
fi

if [ -z "$PORT" ]; then
  PORT=8000
  while "$PY" -c "import socket,sys; s=socket.socket();
sys.exit(0 if s.connect_ex(('127.0.0.1',$PORT))==0 else 1)" 2>/dev/null; do
    PORT=$((PORT+1))
  done
fi

"$PY" -m http.server "$PORT" --bind 127.0.0.1 >/dev/null 2>&1 &
SRV=$!
trap 'kill $SRV 2>/dev/null || true' EXIT

for _ in $(seq 40); do
  "$PY" -c "import socket,sys; s=socket.socket();
sys.exit(0 if s.connect_ex(('127.0.0.1',$PORT))==0 else 1)" 2>/dev/null && break
  sleep 0.1
done

URL="http://127.0.0.1:$PORT"
echo "▸ App:   $URL"
echo "▸ Admin: $URL/admin/"
echo "  (Strg-C zum Beenden)"

if [ "$OPEN" = 1 ]; then
  for o in xdg-open open sensible-browser; do
    command -v "$o" >/dev/null 2>&1 && { "$o" "$URL" >/dev/null 2>&1 & break; }
  done
fi
wait $SRV
