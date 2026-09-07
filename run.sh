#!/usr/bin/env bash
# التشغيل المحلّي — تشوف تعديلاتك فوراً بلا ما تدفع لـgit وتستنى Cloudflare.
#
#   ./run.sh                 بيشغّل ويفتح نافذتين: الطالب واللوحة
#   ./run.sh 9000            منفذ محدّد
#   ./run.sh --no-open       بلا فتح متصفّح
#   ./run.sh --dist          يخدم الناتج المنشور (بلا تعليقات) بدل المصدر
#
# ★ البيانات بتجي من Supabase متل ما هي. يعني اللوحة المحلّية بتعدّل على
#   نفس قاعدة بياناتك الحقيقية. لو بدك تجرّب بأمان (تولّد أكواد، تستورد
#   امتحانات تجريبية) اعمل مشروع Supabase تاني وحطّ مفاتيحه بـ
#   assets/config.local.js — الملف مستثنى من git وبيغلب config.js محلياً.
#   التفاصيل بـdocs/14-deploy.md.
set -euo pipefail
cd "$(dirname "$0")"

PORT=""; OPEN=1; ROOT="."
for a in "$@"; do
  case "$a" in
    --no-open) OPEN=0 ;;
    --dist)    ROOT="dist" ;;
    --help|-h) sed -n '2,17p' "$0" | sed 's/^# \?//'; exit 0 ;;
    [0-9]*)    PORT="$a" ;;
    *) echo "خيار مو معروف: $a" >&2; exit 1 ;;
  esac
done

PY=$(command -v python3 || command -v python || true)
[ -n "$PY" ] || { echo "python3 ناقص" >&2; exit 1; }
[ -f index.html ] || { echo "شغّله من مجلد المشروع" >&2; exit 1; }

if [ "$ROOT" = dist ]; then
  ./tools/build_dist.sh >/dev/null
  ADMIN_DIR=$(ls dist | grep -v -E '^(assets|index.html|manifest|sw.js|_headers)$' | head -1)
else
  ADMIN_DIR="admin"
  # ملف فاضي بيمنع خطأ 404 بالكونسول لما ما يكون في إعداد محلّي
  [ -f assets/config.local.js ] || echo "/* إعداد محلّي اختياري — شوف run.sh */" \
    > assets/config.local.js
fi

# بلا مفاتيح التطبيق ما بيشتغل — أحسن نقولها هلق مو بالمتصفّح
if grep -q 'YOUR-PROJECT' assets/config.js 2>/dev/null; then
  echo "⚠  assets/config.js لسا فيه قيم نائبة."
  echo "   Supabase ← Project Settings ← API ← URL والمفتاح anon."
  echo
fi

free_port(){ "$PY" -c "import socket,sys; s=socket.socket();
sys.exit(0 if s.connect_ex(('127.0.0.1',$1))==0 else 1)" 2>/dev/null; }

if [ -z "$PORT" ]; then
  PORT=8000
  while free_port "$PORT"; do PORT=$((PORT+1)); done
fi

( cd "$ROOT" && "$PY" -m http.server "$PORT" --bind 127.0.0.1 >/dev/null 2>&1 ) &
SRV=$!
trap 'kill $SRV 2>/dev/null || true' EXIT

for _ in $(seq 60); do free_port "$PORT" && break; sleep 0.1; done

URL="http://127.0.0.1:$PORT"
echo "▸ الطالب: $URL/"
echo "▸ اللوحة: $URL/$ADMIN_DIR/"
echo "  (Ctrl-C للإيقاف)"
echo

# فتح المتصفّح — ويندوز وماك ولينكس وWSL
open_url(){
  if   command -v xdg-open  >/dev/null 2>&1; then xdg-open  "$1" >/dev/null 2>&1 &
  elif command -v wslview   >/dev/null 2>&1; then wslview   "$1" >/dev/null 2>&1 &
  elif command -v open      >/dev/null 2>&1; then open      "$1" >/dev/null 2>&1 &
  elif command -v cmd.exe   >/dev/null 2>&1; then cmd.exe /c start "" "$1" >/dev/null 2>&1 &
  elif command -v powershell.exe >/dev/null 2>&1; then
    powershell.exe -NoProfile -Command "Start-Process '$1'" >/dev/null 2>&1 &
  elif command -v start     >/dev/null 2>&1; then start "" "$1" >/dev/null 2>&1 &
  else return 1; fi
}

if [ "$OPEN" = 1 ]; then
  # نافذتين: الطالب واللوحة سوا — أغلب التعديلات بتلمس الاتنين
  if open_url "$URL/"; then
    sleep 1                       # المتصفّح لازم يفتح قبل التاني
    open_url "$URL/$ADMIN_DIR/" || true
  else
    echo "  (ما قدرت أفتح المتصفّح — افتح الرابطين بالإيد)"
  fi
fi
wait $SRV
