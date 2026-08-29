"""يبني نسخة بملف HTML واحد — كل البيانات والصور مدمجة جوّاته.

مفيدة للمشاركة كرابط واحد أو فتحها بدون سيرفر. التطبيق العادي (index.html)
بيقرا البيانات بـfetch، فهون منحقن نفس البيانات كمتغيّر ومنستبدل نداءات fetch.
"""
import base64
import glob
import json
import os
import sys

OUT = sys.argv[1] if len(sys.argv) > 1 else 'telc-b1-standalone.html'

css = open('assets/style.css', encoding='utf-8').read()
js = open('assets/app.js', encoding='utf-8').read()

# اجمع كل النماذج، وحوّل مسارات الصور لـdata: URI
data = {'index': json.load(open('data/index.json', encoding='utf-8')), 'modelle': {}}
for path in sorted(glob.glob('data/modell-*.json')):
    model = json.load(open(path, encoding='utf-8'))
    for sec in model['sections']:
        src = sec.get('bankImage')
        if src:
            raw = open(os.path.join('data', src), 'rb').read()
            sec['bankImage'] = 'data:image/jpeg;base64,' + base64.b64encode(raw).decode()
    data['modelle'][os.path.basename(path)] = model

# اقرأ من الكائن المدموج بدل الشبكة
js = js.replace(
    "S.index = await (await fetch('data/index.json?v=' + Date.now())).json();",
    "S.index = DATA.index;")
js = js.replace(
    "  await (await fetch(`data/${file}?v=` + Date.now())).json();",
    "  DATA.modelle[file];")

# "</" جوّا وسم script بينهي الوسم بدري، فلازم ينهرب
blob = json.dumps(data, ensure_ascii=False).replace('</', '<\\/')

html = """<!doctype html>
<html lang="de" dir="ltr">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<title>telc B1 Training</title>
<meta name="theme-color" content="#2f6bed">
<style>__CSS__</style>
</head>
<body>
<header class="topbar">
  <button id="btnBack" class="icon-btn" hidden>&lsaquo; Zur&uuml;ck</button>
  <div class="brand">telc <span>B1</span></div>
  <div id="timer" class="timer" hidden><span id="timerText">00:00</span></div>
</header>
<main id="app"></main>
<div id="toast" class="toast" hidden></div>
<script id="telc-data" type="application/json">__DATA__</script>
<script>
const DATA = JSON.parse(document.getElementById('telc-data').textContent);
__JS__
</script>
</body>
</html>
"""
html = html.replace('__CSS__', css).replace('__DATA__', blob).replace('__JS__', js)
open(OUT, 'w', encoding='utf-8').write(html)
print(f'{OUT} — {os.path.getsize(OUT) / 1024 / 1024:.2f} MB')
