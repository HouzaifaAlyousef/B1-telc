"""قراءة ملف telc B1 من الـPDF: صفحات ← سطور بإحداثيات ← نماذج وأقسام."""
import re
import pdfplumber

ROW_TOL = 2.5           # فرق ارتفاع بيعتبر نفس السطر
COL_GAP = 12            # فراغ أفقي كبير = فاصل أعمدة
FOOTER  = re.compile(r'ABDELLAH\s*FARHAN|LANGUAGE\s*Test|^\d{1,3}$')
# التذييل أحياناً بيطلع بحروف مضاعفة من الطبقة المكررة (LANGUUAGE، LLAANNGGUUAAGGEE)،
# فمنشيل التكرار قبل المطابقة
_DEDUP = re.compile(r'(.)\1+')

SECTIONS = [
    (r'Leseverstehen,?Teil1',    'LV1'), (r'Leseverstehen,?Teil2', 'LV2'),
    (r'Leseverstehen,?Teil3',    'LV3'),
    (r'Sprach\w*austeine,?Teil1','SB1'), (r'Sprach\w*austeine,?Teil2','SB2'),
    (r'Hörverstehen,?Teil1',     'HV1'), (r'Hörverstehen,?Teil2', 'HV2'),
    (r'Hörverstehen,?Teil3',     'HV3'),
    (r'SchriftlicherAusdruck',   'SA'),  (r'Lösungen',             'KEY'),
]


def dedupe(chars):
    """الـPDF مرسوم بطبقتين متطابقتين — منشيل التكرار حسب الموقع."""
    seen, out = set(), []
    for c in chars:
        key = (round(c['x0'], 1), round(c['top'], 1), c['text'])
        if key not in seen:
            seen.add(key)
            out.append(c)
    return out


def rows_of(page):
    """يرجّع [(y, x0, نص)] مرتّبة من فوق لتحت، مع مسافات حسب الفراغات."""
    groups = []
    for c in sorted(dedupe(page.chars), key=lambda c: (round(c['top'], 1), c['x0'])):
        if groups and abs(groups[-1][0] - c['top']) <= ROW_TOL:
            groups[-1][1].append(c)
        else:
            groups.append([c['top'], [c]])

    rows = []
    for top, cs in groups:
        cs.sort(key=lambda c: c['x0'])
        buf, prev = [], None
        for c in cs:
            if prev is not None:
                gap = c['x0'] - prev['x1']
                if gap > COL_GAP:
                    buf.append('   ')
                elif gap > max(prev['x1'] - prev['x0'], 1) * 0.42:
                    buf.append(' ')
            buf.append(c['text'])
            prev = c
        text = ''.join(buf).strip()
        if text:
            rows.append((round(top, 1), round(cs[0]['x0'], 1), text))
    return rows


def words_of(page):
    """يرجّع [(x0, x1, y, نص)] لكل كلمة بعد حذف الطبقة المكررة."""
    groups = []
    for c in sorted(dedupe(page.chars), key=lambda c: (round(c['top'], 1), c['x0'])):
        if groups and abs(groups[-1][0] - c['top']) <= ROW_TOL:
            groups[-1][1].append(c)
        else:
            groups.append([c['top'], [c]])

    def push(acc, out, top):
        txt = ''.join(x['text'] for x in acc).replace('\xa0', ' ').strip()
        if txt:
            out.append((acc[0]['x0'], acc[-1]['x1'], round(top, 1), txt))

    words = []
    for top, cs in groups:
        cs.sort(key=lambda c: c['x0'])
        cur = []
        for c in cs:
            if cur and c['x0'] - cur[-1]['x1'] > max(cur[-1]['x1'] - cur[-1]['x0'], 1) * 0.42:
                push(cur, words, top)
                cur = []
            cur.append(c)
        if cur:
            push(cur, words, top)
    return words


def body_rows(rows):
    """يشيل الترويسة والتذييل وبقايا النص العربي المكتوب فوق الصفحة."""
    out = []
    for y, x, t in rows:
        flat = t.strip()
        if FOOTER.search(flat) or FOOTER.search(_DEDUP.sub(r'\1', flat)):
            continue
        if re.search(r'[؀-ۿ]', t):        # كتابة عربية دخيلة
            continue
        if re.match(r'|'.join(p for p, _ in SECTIONS[:-1]), re.sub(r'[\s.,]', '', t)):
            continue
        out.append((y, x, t))
    return out


def section_of(rows):
    flat = re.sub(r'[\s.,]', '', ' '.join(t for _, _, t in rows))[:4000]
    for pat, name in SECTIONS:
        if re.search(pat, flat):
            return name
    return None


def read(path):
    """يرجّع (pages, models) حيث pages[n] = صفوف الصفحة، models = قوائم أقسام."""
    pages = {}
    with pdfplumber.open(path) as pdf:
        for i, pg in enumerate(pdf.pages, 1):
            pages[i] = rows_of(pg)

    kind = {p: section_of(r) for p, r in pages.items()}
    keys = sorted(p for p, k in kind.items() if k == 'KEY')

    models, start = [], 1
    for k in keys:
        secs = {}
        for p in range(start, k):
            if kind[p] and kind[p] != 'KEY':
                secs.setdefault(kind[p], []).append(p)
        models.append({'key_page': k, 'pages': list(range(start, k + 1)), 'sections': secs})
        start = k + 1
    return pages, models


# ---------------- مفتاح الحلول ----------------
ANS_TOKEN = re.compile(r'^([A-Oa-oXx]|\+|-)$')
NUM_TOKEN = re.compile(r'^(\d{1,2})\.?$')


def parse_key(words):
    """صفحة الحلول: لكل رقم سؤال، الجواب هو أقرب رمز على يمينه.

    الأرقام والأجوبة مو دايماً بنفس السطر تماماً (فرق ٥-٨ نقاط)، فمنقارن
    بالإحداثيات مو بالنص. الرموز: حرف (LV/SB) أو + / - (HV).
    """
    tokens = sorted(words, key=lambda w: (w[2], w[0]))
    cands  = [w for w in tokens if ANS_TOKEN.match(w[3])]

    answers, words_for = {}, {}
    for i, (x0, x1, y, t) in enumerate(tokens):
        m = NUM_TOKEN.match(t)
        if not m:
            continue
        n = int(m.group(1))
        if not 1 <= n <= 60 or n in answers:
            continue
        if i and tokens[i - 1][3].rstrip('(').endswith('Teil'):   # "(Teil 1)"
            continue
        near = [c for c in cands
                if 0 < c[0] - x1 < 130 and abs(c[2] - y) <= 9]
        if not near:
            continue
        pick = min(near, key=lambda c: (c[0] - x1) + abs(c[2] - y))
        answers[n] = pick[3]
        # كلمة التوضيح للـSprachbausteine (مثال: "21 b Ihrem")
        after = [w for w in tokens
                 if 0 < w[0] - pick[1] < 120 and abs(w[2] - pick[2]) <= 9
                 and len(w[3]) > 1 and w[3][0].isalpha()]
        if after:
            words_for[n] = min(after, key=lambda w: w[0] - pick[1])[3]
    return answers, words_for


def rows_for(pages, page_nums):
    """يجمع صفوف عدة صفحات مع إزاحة الارتفاع، تا ما تتداخل صفحة بصفحة."""
    out = []
    for i, p in enumerate(sorted(page_nums)):
        for y, x, t in body_rows(pages.get(p, [])):
            out.append((i * 10000 + y, x, t))
    return out


def words_for(pdf, page_nums):
    """نفس الشي بس للكلمات بإحداثياتها."""
    out = []
    for i, p in enumerate(sorted(page_nums)):
        for x0, x1, y, t in words_of(pdf.pages[p - 1]):
            out.append((x0, x1, i * 10000 + y, t))
    return out
