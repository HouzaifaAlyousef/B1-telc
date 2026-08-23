"""يبني ملفات data/*.json للتطبيق من ملف telc B1 PDF."""
import io, json, os, re, sys
import pdfplumber, pypdfium2
from pypdf import PdfReader
from PIL import Image

sys.path.insert(0, os.path.dirname(__file__))
import telcpdf, sections as S

PDF  = sys.argv[1] if len(sys.argv) > 1 else 'Doku/B1 Telc.pdf'
OUT  = sys.argv[2] if len(sys.argv) > 2 else 'data'
IMGS = os.path.join(OUT, 'img')

# Prüfungsteil: (Gruppe, Titel, Minuten)
META = {
  'LV1': ('Leseverstehen', 'Leseverstehen, Teil 1', 15),
  'LV2': ('Leseverstehen', 'Leseverstehen, Teil 2', 20),
  'LV3': ('Leseverstehen', 'Leseverstehen, Teil 3', 20),
  'SB1': ('Sprachbausteine', 'Sprachbausteine, Teil 1', 20),
  'SB2': ('Sprachbausteine', 'Sprachbausteine, Teil 2', 15),
  'HV1': ('Hörverstehen', 'Hörverstehen, Teil 1', 8),
  'HV2': ('Hörverstehen', 'Hörverstehen, Teil 2', 14),
  'HV3': ('Hörverstehen', 'Hörverstehen, Teil 3', 8),
  'SA':  ('Schriftlicher Ausdruck', 'Schriftlicher Ausdruck', 30),
}

# التقسيم الرسمي حسب صفحة Testformat بنموذج telc:
# Leseverstehen + Sprachbausteine بلوك واحد ٩٠ دقيقة (أسئلة ١-٤٠)،
# Hörverstehen ~٣٠ دقيقة (٤١-٦٠)، Schriftlicher Ausdruck ٣٠ دقيقة.
# أوقات الأجزاء المفردة فوق مجموعها بيساوي وقت البلوك اللي بينتمولو.
BLOCKS = [
  ('block-lv-sb', 'Leseverstehen und Sprachbausteine',
   ['lv1', 'lv2', 'lv3', 'sb1', 'sb2'], 90, 'Aufgaben 1–40'),
  ('block-hv', 'Hörverstehen', ['hv1', 'hv2', 'hv3'], 30, 'Aufgaben 41–60'),
  ('block-sa', 'Schriftlicher Ausdruck', ['sa'], 30, ''),
]
RANGE = {'LV1': (1, 5), 'LV2': (6, 10), 'LV3': (11, 20), 'SB1': (21, 30),
         'SB2': (31, 40), 'HV1': (41, 45), 'HV2': (46, 55), 'HV3': (56, 60)}

INSTR = {
  'LV1': 'Lesen Sie die Überschriften a–j und die Texte 1–5. Finden Sie für jeden Text '
         'die passende Überschrift. Jede Überschrift passt nur einmal.',
  'LV2': 'Lesen Sie den Text und die Aufgaben 6–10. Welche Lösung (A, B oder C) '
         'ist jeweils richtig?',
  'LV3': 'Lesen Sie die Situationen 11–20 und die Anzeigen im Bild. Finden Sie für jede '
         'Situation die passende Anzeige. Wenn Sie keine passende Anzeige finden, '
         'wählen Sie X.',
  'SB1': 'Lesen Sie den Text und schließen Sie die Lücken 21–30. Welche Lösung '
         '(A, B oder C) ist jeweils richtig?',
  'SB2': 'Lesen Sie den Text und schließen Sie die Lücken 31–40. Benutzen Sie die Wörter '
         'aus der Liste. Jedes Wort passt nur einmal.',
  'SA':  'Antworten Sie auf den Brief. Schreiben Sie etwas zu allen Inhaltspunkten. '
         'Denken Sie an Datum, Anrede, Einleitung und Schluss.',
}
HV_INSTR = 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.'
HV_NOTE  = ('Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. '
            'Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich '
            'mit der Lösung — nicht zum Hörtraining.')
LV3_KEYS = list('ABCDEFGHIJKL') + ['X']


def gap_context(passage, n, span=60):
    """جملة مختصرة حوالين الفراغ، تا تبيّن السياق بدون ما ترجع تقرا كل النص."""
    m = re.search(rf'\(\s*{n}\s*\)', passage)
    if not m:
        return f'Lücke {n}'
    a, b = max(0, m.start() - span), min(len(passage), m.end() + span)
    out = passage[a:b].strip()
    if a > 0:
        out = '… ' + out.split(' ', 1)[-1]
    if b < len(passage):
        out = out.rsplit(' ', 1)[0] + ' …'
    return out


def norm(ans, fmt):
    if fmt == 'truefalse':
        return {'+': 'r', '-': 'f'}.get(ans)
    return ans.upper() if ans and ans.isalpha() else None


def build_section(kind, model_no, pages, words_by, key, keyword, pdfdoc):
    grp, title, minutes = META[kind]
    sec = {'id': kind.lower(), 'group': grp, 'title': title, 'minutes': minutes}
    sec['instruction'] = INSTR.get(kind, HV_INSTR)
    lo, hi = RANGE.get(kind, (0, 0))
    rows, words = pages, words_by
    items, passages, bank, fmt = [], [], None, None

    if kind == 'LV1':
        fmt = 'matching'
        first = [r for r in rows if r[0] < 10000]
        bank, raw = S.parse_lv1(first, rows)
        bank = [{'key': b['key'].upper(), 'text': b['text']} for b in bank]
        items = raw
        sec['bankTitle'] = 'Überschriften'
    elif kind == 'LV2':
        fmt = 'mc'
        body, items = S.parse_lv2(rows)
        if body:
            passages = [{'body': body}]
    elif kind == 'LV3':
        fmt = 'matching'
        items = S.parse_lv3(rows)
        bank = [{'key': k, 'text': ''} for k in LV3_KEYS]
        sec['bankTitle'] = 'Anzeigen'
    elif kind == 'SB1':
        fmt = 'mc'
        body, items = S.parse_sb1(rows, words)
        if body:
            passages = [{'body': body}]
        for it in items:
            it['text'] = gap_context(body, it['id'])
    elif kind == 'SB2':
        fmt = 'wordbank'
        bank, body = S.parse_sb2(rows)
        bank = [{'key': b['key'].upper(), 'text': b['text']} for b in bank]
        if body:
            passages = [{'body': body}]
        # الفراغات ٣١-٤٠ مرقّمة بالنص نفسه، فمنولّدها من مدى الأرقام
        items = [{'id': str(n), 'text': gap_context(body, n)} for n in range(lo, hi + 1)]
        sec['bankTitle'] = 'Wörterliste'
    elif kind.startswith('HV'):
        fmt = 'truefalse'
        items = S.parse_truefalse(rows, lo, hi)
        sec['note'] = HV_NOTE
    elif kind == 'SA':
        fmt = 'writing'
        letter, points, minw = S.parse_sa(rows)
        if not points:
            return None
        passages = [{'title': 'Brief', 'body': letter}]
        items = [{'id': 'A', 'text': 'Antworten Sie auf diesen Brief.',
                  'minWords': minw, 'points': points}]

    sec['format'] = fmt
    if passages:
        sec['passages'] = passages
    if bank:
        sec['bank'] = bank

    if kind == 'SB1':
        # مفتاح الحلول بيعطي الكلمة الصحيحة لكل فراغ — منستعمله للتأكد
        # من ربط الخيار بحرفه، ومنحذف السؤال إذا الكلمة مو موجودة بالخيارات
        def key_norm(t):
            return re.sub(r'[^a-zäöüß]', '', t.lower())
        checked = []
        for it in items:
            w = keyword.get(int(it['id']))
            a = norm(key.get(int(it['id'])), 'mc')
            if not w or not a:
                continue
            match = [o['key'] for o in it['options'] if key_norm(o['text']) == key_norm(w)]
            if not match:
                continue                       # التحليل مو موثوق — احذف السؤال
            if match[0] != a:
                key[int(it['id'])] = match[0]  # صحّح الحرف حسب الكلمة
            checked.append(it)
        items = checked

    if fmt != 'writing':                      # اربط كل سؤال بجوابه، واحذف اللي بلا جواب
        keep = []
        for it in items:
            a = norm(key.get(int(it['id'])), fmt)
            if not a:
                continue
            if fmt in ('mc',) and a not in [o['key'] for o in it.get('options', [])]:
                continue
            if bank and fmt in ('matching', 'wordbank') and a not in [b['key'] for b in bank]:
                continue
            it['answer'] = a
            w = keyword.get(int(it['id']))
            if w and fmt == 'wordbank':
                it['explain'] = f'Das Wort lautet: {w}'
            keep.append(it)
        items = keep

    items.sort(key=lambda it: int(it['id']) if it['id'].isdigit() else 0)
    sec['items'] = items
    return sec if items else None


def export_ads(doc, reader, pages_lv3, model_no):
    """يصدّر صفحة إعلانات Leseverstehen Teil 3 كصورة بأعلى دقّة متاحة.

    الصفحة بالـPDF صورة مو نص. أحياناً صفحة الإعلانات ما إلها عنوان نصّي
    فما بتنربط بالقسم، فمنفتّش كمان بالصفحة اللي بعدها. منختار أكبر صورة
    بالمساحة (مو بالحجم) تا ما ناخد زخرفة صغيرة بالغلط.

    إذا الصورة أصلاً JPEG منسخها كما هي — صفر خسارة جودة وأصغر حجم.
    غير هيك (PNG أو JPEG2000) منحوّلها بدقّتها الأصلية بدون أي تصغير.
    """
    name = f'm{model_no:02d}-lv3.jpg'
    dest = os.path.join(IMGS, name)
    scan = sorted(set(pages_lv3) | {max(pages_lv3) + 1})

    best = None                      # (مساحة، صفحة، صورة)
    for pno in scan:
        if pno > len(reader.pages):
            continue
        for im in reader.pages[pno - 1].images:
            try:
                pil = Image.open(io.BytesIO(im.data))
            except Exception:
                continue
            area = pil.size[0] * pil.size[1]
            if area > 200_000 and (best is None or area > best[0]):
                best = (area, pno, im, pil)

    if best:
        _, _, im, pil = best
        if im.name.lower().endswith(('.jpg', '.jpeg')):
            with open(dest, 'wb') as f:
                f.write(im.data)          # نسخة طبق الأصل
        else:
            pil.convert('L').save(dest, 'JPEG', quality=88,
                                  optimize=True, progressive=True)
        return name

    doc[max(pages_lv3) - 1].render(scale=2.0).to_pil().convert('L').save(
        dest, 'JPEG', quality=85, optimize=True, progressive=True)
    return name


def main():
    os.makedirs(IMGS, exist_ok=True)
    pages, models = telcpdf.read(PDF)
    doc = pypdfium2.PdfDocument(PDF)
    reader = PdfReader(PDF)
    index = []

    with pdfplumber.open(PDF) as pdf:
        for i, m in enumerate(models, 1):
            secs = []
            key, keyword = telcpdf.parse_key(telcpdf.words_of(pdf.pages[m['key_page'] - 1]))
            for kind in ['LV1', 'LV2', 'LV3', 'SB1', 'SB2', 'HV1', 'HV2', 'HV3', 'SA']:
                ps = m['sections'].get(kind)
                if not ps:
                    continue
                rows = telcpdf.rows_for(pages, ps)
                if kind == 'SB2':                      # البنك بيكمّل على الصفحة التالية
                    nxt = max(ps) + 1
                    rows_extra = telcpdf.body_rows(pages.get(nxt, []))
                    bank, body = S.parse_sb2(rows, rows_extra)
                    bank = [{'key': b['key'].upper(), 'text': b['text']} for b in bank]
                    sec = build_section(kind, i, rows, [], key, keyword, doc)
                    if sec:
                        sec['bank'] = bank
                        sec['passages'] = [{'body': body}] if body else []
                        sec['items'] = [it for it in sec['items']
                                        if it['answer'] in [b['key'] for b in bank]]
                        if not sec['items']:
                            sec = None
                else:
                    words = telcpdf.words_for(pdf, ps) if kind == 'SB1' else []
                    sec = build_section(kind, i, rows, words, key, keyword, doc)

                if kind == 'LV3' and sec:
                    sec['bankImage'] = f'img/{export_ads(doc, reader, ps, i)}'
                if sec:
                    secs.append(sec)

            have = {s['id'] for s in secs}
            blocks = [{'id': bid, 'title': t, 'minutes': mins, 'hint': hint,
                       'parts': [p for p in parts if p in have]}
                      for bid, t, parts, mins, hint in BLOCKS
                      if any(p in have for p in parts)]

            data = {'id': f'modell-{i:02d}', 'title': f'Modelltest {i}',
                    'blocks': blocks,
                    'subtitle': f'{sum(len(s["items"]) for s in secs)} Aufgaben · '
                                f'{sum(b["minutes"] for b in blocks)} Minuten',
                    'sections': secs}
            with open(os.path.join(OUT, f'modell-{i:02d}.json'), 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=1)
            index.append({'id': data['id'], 'file': f'modell-{i:02d}.json',
                          'title': data['title'], 'sections': len(secs),
                          'aufgaben': sum(len(s['items']) for s in secs),
                          'minutes': sum(b['minutes'] for b in blocks)})
            print(f"Modell {i:2}: " + '  '.join(
                f"{s['id']}={len(s['items'])}" for s in secs))

    with open(os.path.join(OUT, 'index.json'), 'w', encoding='utf-8') as f:
        json.dump({'modelle': index}, f, ensure_ascii=False, indent=1)
    print('\nAufgaben gesamt:', sum(
        len(s['items']) for e in index
        for s in json.load(open(os.path.join(OUT, e['file']), encoding='utf-8'))['sections']))


if __name__ == '__main__':
    main()
