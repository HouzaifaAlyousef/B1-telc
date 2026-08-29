"""تحليل محتوى أقسام امتحان telc B1 من صفوف الصفحات."""
import collections
import re
import statistics

import spelling

NUM_RE   = re.compile(r'^(\d{1,2})\s*[.)]?\s*(.*)$')
DOTS_RE  = re.compile(r'^[.…·\s]{6,}$')
OPT_RE   = re.compile(r'^([A-Ca-c])\s*[.)]?\s+(.{2,})$')
BANK_RE  = re.compile(r'^([A-Ja-j])\s*\)\s*(.+)$')


def clean(t):
    t = t.replace('\xa0', ' ')
    t = re.sub(r'\s+', ' ', t).strip()
    return spelling.repair(t)      # أخطاء الإملاء الناتجة عن نسخ الـPDF


def paragraphs(rows, gap_factor=1.4, head_factor=1.12):
    """يقسّم صفوف نص لفقرات، ويميّز العناوين.

    المسافة بين سطور الفقرة الوحدة ثابتة تقريباً (~١٩٫٥ نقطة) وبين الفقرات
    بتكبر (~٣٢). فمنحسب المسافة الشائعة ومنعتبر أي قفزة أكبر منها بمقدار
    معيّن بداية فقرة جديدة. والسطر المزحزح لليمين كمان بيبدأ فقرة.

    العناوين: الـPDF ما بيسمّي الخط العريض، بس العنوان دايماً أكبر حجماً من
    النص. فمنقارن حجم كل سطر بالحجم الشائع بالنص.

    بيرجّع [{'t': النص, 'b': عنوان؟}].
    """
    rs = [(y, x, clean(t), (r[3] if len(r) > 3 else 0))
          for r in rows for y, x, t in [r[:3]] if not is_noise(t)]
    if not rs:
        return []
    gaps = sorted(rs[i][0] - rs[i - 1][0] for i in range(1, len(rs)))
    line = gaps[len(gaps) // 2] if gaps else 0        # المسافة الشائعة
    base = min(x for _, x, _, _ in rs)

    # حجم النص العادي بينحسب لكل صفحة لحالها — الصفحات ممسوحة بمقاسات
    # مختلفة شوي، فوسيط المجموع بيخلّي صفحة كاملة تبان عناوين.
    per_page = {}
    for y, _, _, sz in rs:
        if sz:
            per_page.setdefault(int(y // 10000), []).append(sz)
    body = {pg: statistics.median(v) for pg, v in per_page.items()}
    # حجم بيتكرر بسطور كتير = كتلة نص، مو عنوان (بيصير لما تكملة نص من
    # صفحة سابقة تطلع بحجم أكبر من نص الصفحة الحالية)
    common = {pg: {sz for sz, n in collections.Counter(v).items() if n >= 4}
              for pg, v in per_page.items()}

    out, cur, cur_head, cur_sz = [], [], False, 0
    def flush():
        if cur:
            out.append({'t': clean(' '.join(cur)), 'b': cur_head, 'z': cur_sz})
    for i, (y, x, t, sz) in enumerate(rs):
        pg = int(y // 10000)
        ref = body.get(pg, 0)
        head = bool(ref) and sz > ref * head_factor and sz not in common.get(pg, ())
        newp = cur and ((line and y - rs[i - 1][0] > line * gap_factor)
                        or x > base + 2 or head != cur_head)
        if newp:
            flush()
            cur = []
        if not cur:
            cur_head, cur_sz = head, sz
        cur.append(t)
    flush()

    # عنوان فرعي بينلف على سطرين بيطلع فقرتين — منرجّعهم وحدة
    merged = []
    for p in out:
        if merged and p['b'] and merged[-1]['b'] and p['z'] == merged[-1]['z']:
            merged[-1]['t'] = clean(merged[-1]['t'] + ' ' + p['t'])
        else:
            merged.append(p)

    # العنوان قصير بطبعه — الفقرة الطويلة نص عادي حتى لو طلع حجمها أكبر
    for p in merged:
        p['b'] = p['b'] and 2 < len(p['t']) <= 120 and any(c.isalpha() for c in p['t'])
        p.pop('z', None)
    return [p for p in merged if p['t']]


def is_noise(t):
    t = clean(t)
    return (not t or DOTS_RE.match(t) or len(t) < 2
            or re.match(r'^\(?\s*\)?$', t))


def strip_instructions(rows):
    """يشيل سطور التعليمات (Lesen Sie…، Markieren Sie…) من أول القسم."""
    out = []
    for r in rows:
        c = clean(r[2])
        if re.match(r'^(Lesen|Markieren|Entscheiden|Sie hören|Antwortbogen|Benutzen|'
                    r'Schreiben Sie mindestens|Bevor Sie)', c):
            continue
        if re.search(r'auf dem Antwortbogen|Sie haben dazu \d+ Sekunden', c):
            continue
        if re.match(r'^(Lücken|Aufgaben)\s*\d', c) or re.match(r'^\(a,\s*o\)', c):
            continue
        if re.search(r'Jedes Wort passt nur einmal|Welche Lösung.*richtig', c):
            continue
        out.append(r)                       # الحجم لازم يوصل لكشف العناوين
    return out


def windows(rows, lo, hi, tol=15.0):
    """يقسّم الصفوف على أرقام الأسئلة.

    رقم السؤال ممكن يكون بنفس سطر النص أو بسطر لحاله فوقه/تحته بشوي نقاط،
    فمنقسّم حسب الارتفاع: السؤال n بياخد كل شي بين علامته وعلامة n+1.
    """
    marks = []
    for y, x, t, *_ in rows:
        m = NUM_RE.match(clean(t))
        if not m:
            continue
        n = int(m.group(1))
        if lo <= n <= hi and (not marks or n > marks[-1][0]):
            marks.append((n, y))
    if not marks:
        return {}

    out = {}
    for i, (n, y) in enumerate(marks):
        top = y - tol
        bot = marks[i + 1][1] - tol if i + 1 < len(marks) else float('inf')
        chunk = [r for r in rows if top <= r[0] < bot]
        out[n] = chunk
    return out


def join_rows(chunk, drop_num=None):
    """يجمع صفوف سؤال بنص واحد، مع شيل رقم السؤال من البداية."""
    parts = []
    for _, _, t, *_r in chunk:
        c = clean(t)
        if is_noise(c):
            continue
        parts.append(c)
    text = ' '.join(parts)
    if drop_num is not None:
        text = re.sub(rf'^\s*{drop_num}\s*[.)]?\s*', '', text)
        text = re.sub(rf'\s*\b{drop_num}\s*[.)]\s*', ' ', text, count=1)
    text = re.sub(r'\s+([,.;:!?])', r'\1', text)
    return clean(text)


# ---------------- أقسام بسيطة: صح / خطأ ----------------
def parse_truefalse(rows, lo, hi):
    items = []
    for n, chunk in sorted(windows(strip_instructions(rows), lo, hi).items()):
        text = join_rows(chunk, n)
        if text:
            items.append({'id': str(n), 'text': text})
    return items


# ---------------- Leseverstehen Teil 1 ----------------
LETTERS = 'abcdefghij'


def parse_bank_letters(rows, n=10, tol=12.0, xmax=105):
    """بنك خيارات مرقّم بحروف a)-j).

    أحياناً الحرف بيكون بسطر لحاله والنص بسطر تاني (فرق بسيط بالارتفاع)،
    فمنقسّم حسب الارتفاع متل أرقام الأسئلة، ومنشترط تسلسل الحروف.
    """
    want, marks = 0, []
    for y, x, t, *_ in rows:
        c = clean(t)
        m = re.match(r'^([A-Za-z])\s*\)?\s*(.*)$', c)
        if not m or x > xmax or want >= n:
            continue
        if m.group(1).lower() != LETTERS[want]:
            continue
        marks.append((LETTERS[want], y))
        want += 1

    bank = []
    for i, (k, y) in enumerate(marks):
        bot = marks[i + 1][1] - tol if i + 1 < len(marks) else y + 30
        txt = join_rows([r for r in rows if y - tol <= r[0] < bot])
        txt = re.sub(r'^\s*[A-Za-z]?\s*\)\s*', '', txt)
        txt = re.sub(r'^\s*[A-Za-z]\s+', '', txt) if len(txt) > 2 and txt[1] in ' )' else txt
        if txt:
            bank.append({'key': k, 'text': clean(txt)})
    return bank


def parse_lv1(rows_first, rows_rest):
    """عناوين a)-j) بالصفحة الأولى، والنصوص 1-5 بالباقي."""
    bank = parse_bank_letters(strip_instructions(rows_first))
    items = []
    for n, chunk in sorted(windows(strip_instructions(rows_rest), 1, 5).items()):
        text = join_rows(chunk, n)
        if len(text) > 40:
            items.append({'id': str(n), 'text': text})
    return bank, items


# ---------------- Leseverstehen Teil 3 ----------------
def parse_lv3(rows):
    items = []
    for n, chunk in sorted(windows(strip_instructions(rows), 11, 20).items()):
        text = join_rows(chunk, n)
        if len(text) > 15:
            items.append({'id': str(n), 'text': text})
    return items


# ---------------- Sprachbausteine Teil 2 ----------------
BANK_MARK = re.compile(r'(?:^|\s)([a-o])\s+(?=[A-ZÄÖÜẞ])')


def bank_line(text):
    """يفكّ سطر بنك الكلمات: "a AM   d FÜR   g MICH" ← أزواج (حرف، كلمة)."""
    marks = list(BANK_MARK.finditer(text))
    if len(marks) < 2:
        return []
    out = []
    for i, m in enumerate(marks):
        end = marks[i + 1].start() if i + 1 < len(marks) else len(text)
        word = clean(text[m.end():end])
        if word and word.isupper():
            out.append((m.group(1), word))
    return out


def parse_sb2(rows, extra_rows=()):
    """نص الرسالة + بنك كلمات a-o (أحياناً البنك بيكمّل على الصفحة التالية)."""
    bank, body, seen = [], [], set()

    def take_bank(rs):
        for _, _, t, *_r in rs:
            for k, w in bank_line(clean(t)):
                if k not in seen:
                    seen.add(k)
                    bank.append({'key': k, 'text': w})

    body = paragraphs([r for r in strip_instructions(rows) if not bank_line(clean(r[2]))])
    take_bank(strip_instructions(rows))
    take_bank(extra_rows)
    bank.sort(key=lambda b: b['key'])
    return bank, body


# ---------------- خيارات A/B/C ----------------
def parse_options(chunk, xmax=130, xtext=90, n=3):
    """يرجّع خيارات السؤال مرتّبة A/B/C.

    أحياناً حرف الخيار مو موجود بطبقة النص بالـPDF أصلاً، وأحياناً بيكون
    بسطر لحاله فوق أو تحت نصّه. بس عدد الخيارات ثابت (٣) وترتيبها العمودي
    هو ترتيب الحروف، فمنعتمد على الترتيب ومنستعمل الحروف الموجودة للتأكيد.
    """
    slots, letters = [], []
    for y, x, t, *_ in chunk:
        c = clean(t)
        m = re.fullmatch(r'([A-Ca-c])\s*\)?', c)
        if m and x <= xmax:
            letters.append((y, m.group(1).upper()))
            continue
        m = re.match(r'^([A-Ca-c])\s*\)?\s+(.{3,})$', c)
        if m and x <= xmax:
            slots.append((y, clean(m.group(2)), m.group(1).upper()))
            continue
        if x >= xtext and len(c) > 3 and not is_noise(c):
            slots.append((y, c, None))

    slots.sort()
    if len(slots) != n:
        return []

    keys = [chr(ord('A') + i) for i in range(n)]
    for i, (y, text, key) in enumerate(slots):
        if key and key != keys[i]:            # الحروف الموجودة ما بتطابق الترتيب
            return []
    return [{'key': keys[i], 'text': slots[i][1]} for i in range(n)]


# ---------------- Leseverstehen Teil 2 ----------------
def parse_lv2(rows):
    """نص طويل + أسئلة 6-10 كل واحد بثلاث خيارات A/B/C."""
    rows = strip_instructions(rows)
    win = windows(rows, 6, 10)
    if not win:
        return '', []
    stems = {n: min(r[0] for r in c if re.match(rf'^{n}\s*[.)]', clean(r[2])))
             for n, c in win.items()
             if any(re.match(rf'^{n}\s*[.)]', clean(r[2])) for r in c)}
    first = min(stems.values()) if stems else min(min(r[0] for r in c) for c in win.values())
    passage = paragraphs([r for r in rows if r[0] < first - 4])

    items = []
    for n, chunk in sorted(win.items()):
        opts = parse_options(chunk)
        opt_ys = [r[0] for r in chunk if re.match(r'^[A-Ca-c]\s*\)?(\s|$)', clean(r[2]))]
        cut = min(opt_ys) - 4 if opt_ys else float('inf')
        stem = join_rows([r for r in chunk if r[0] < cut and r[1] < 90], n)
        if stem and len(opts) == 3:
            items.append({'id': str(n), 'text': stem, 'options': opts})
    return passage, items


# ---------------- Sprachbausteine Teil 1 ----------------
def parse_sb1(rows, words, lo=21, hi=30):
    """رسالة فيها فراغات (21)-(30)، والخيارات بشبكة أعمدة تحتها.

    الشبكة ٣-٤ أعمدة، كل خلية فيها رقم الفراغ وتحته ٣ خيارات. حروف
    الخيارات (A/B/C) أحياناً مو موجودة بطبقة النص، فمنعتمد على الترتيب
    العمودي: أول نص = A، والتاني = B، والتالت = C.
    """
    # الرقم أحياناً منفصل عن نقطته ("26 ."). والشبكة تحت الرسالة دايماً،
    # فإذا الرقم تكرر (مرة بالنص ومرة بالشبكة) مناخد الأسفل.
    best = {}
    for x0, x1, y, t in words:
        if not re.fullmatch(r'\d{1,2}\s*\.?', t):
            continue
        n = int(t.rstrip(' .'))
        if lo <= n <= hi and (n not in best or y > best[n][1]):
            best[n] = (x0, y, n)
    marks = sorted(best.values())
    if not marks:
        return '', []

    grid_top = min(y for _, y, _ in marks) - 12
    passage = paragraphs([r for r in strip_instructions(rows) if r[0] < grid_top])

    items = []
    for mx, my, n in marks:
        below = [m for m in marks if abs(m[0] - mx) < 25 and m[1] > my + 20]
        bottom = min((m[1] for m in below), default=my + 135) - 12
        cell = [w for w in words
                if mx + 3 < w[0] < mx + 148 and my - 12 <= w[2] < bottom]

        # موقع عمود حروف الخيارات — منستعمله تا نفرق بين حرف الخيار
        # الملزوق بنصّه ("Aim") وبين كلمة بتبلّش بنفس الحرف ("Aber")
        letter_x = [w[0] for w in cell if re.fullmatch(r'[A-Ca-c]\s*\)?', w[3])]
        lx = min(letter_x) if letter_x else None

        lines = []                       # جمّع كلمات الخلية بسطور
        for w in sorted(cell, key=lambda w: (w[2], w[0])):
            if re.fullmatch(r'[A-Ca-c]\s*\)?', w[3]):     # حرف الخيار نفسه
                continue
            if re.fullmatch(r'\d{1,2}\s*\.?|[.)\u2026]+', w[3]):   # رقم/نقطة زحفت من خلية جارة
                continue
            if lx is not None and abs(w[0] - lx) <= 5 and len(w[3]) > 1 \
                    and w[3][0] in 'ABCabc':
                w = (w[0], w[1], w[2], w[3][1:].lstrip())   # شيل الحرف الملزوق
            if lines and abs(lines[-1][0] - w[2]) <= 7:
                lines[-1][1].append(w)
            else:
                lines.append([w[2], [w]])

        texts = [clean(' '.join(x[3] for x in sorted(ws, key=lambda w: w[0])))
                 for _, ws in lines]
        texts = [re.sub(r'^[.)\s\u2026]+', '', t) for t in texts]
        texts = [t for t in texts if t and not is_noise(t)]
        if len(texts) == 3:
            items.append({'id': str(n), 'text': f'Lücke ({n})',
                          'options': [{'key': k, 'text': t}
                                      for k, t in zip('ABC', texts)]})
    return passage, items


# ---------------- Schriftlicher Ausdruck ----------------
GREETING = re.compile(r'^(Liebe|Lieber|Hallo|Sehr geehrte)', re.I)
TASKLINE = re.compile(r'^(Schreiben|Antworten)\s+Sie\b', re.I)
BULLET   = re.compile(r'^[.\u2022\u00b7\u2013-]\s*(.{4,})$')
HINTLINE = re.compile(r'^(Bevor Sie|Überlegen Sie|Schreiben Sie mindestens)', re.I)


def parse_sa(rows):
    """رسالة + النقاط المطلوبة، مبنيّة متل النموذج الرسمي.

    ترتيب الصفحة: سطر تمهيدي، خط منقّط، الرسالة (تحية + فقرات + اسم)،
    سطر المهمة، النقاط المطلوبة، ملاحظات، والحد الأدنى للكلمات.

    صيغ الخاتمة بتختلف كتير («Herzliche Grüße»، «Alles Liebe»،
    «Hoffentlich bis bald»...)، فبدل ما نلاحقها منبلّش من النقاط المطلوبة
    ومنرجع للورا: سطر المهمة قبلها، والاسم قبل سطر المهمة.
    """
    rs = [(y, x, clean(t)) for y, x, t, *_ in rows if not is_noise(t)]
    rs = [r for r in rs if not DOTS_RE.match(r[2])]
    if not rs:
        return None
    text = ' '.join(r[2] for r in rs)

    g = next((i for i, r in enumerate(rs) if GREETING.match(r[2])), -1)
    b0 = next((i for i, r in enumerate(rs) if i > g and BULLET.match(r[2])), -1)
    if g < 0 or b0 < 0:
        return None

    t0 = next((i for i in range(b0 - 1, g, -1) if TASKLINE.match(rs[i][2])), -1)
    if t0 < 0:
        return None
    task = ' '.join(r[2] for r in rs[t0:b0])

    sig = ''
    end = t0                                    # آخر سطر بجسم الرسالة + ١
    if t0 - 1 > g and len(rs[t0 - 1][2]) < 40:
        sig = rs[t0 - 1][2]
        end = t0 - 1

    body = rs[g + 1:end]
    base = min((x for _, x, _ in body), default=0)
    paras, cur = [], []
    for i, (_, x, t) in enumerate(body):
        # سطر مزحزح لليمين = فقرة جديدة. والسطر القصير بآخر الرسالة (الخاتمة)
        # بينحط لحاله — بس بشرط إنه السطر اللي قبله خلّص جملة، وإلا بيكون
        # بقية سطر ملفوف (متل "traumhaft schön!") ولازم ينضم لفقرته.
        starts_new = i == 0 or body[i - 1][2].rstrip().endswith(('.', '!', '?'))
        tail = i >= len(body) - 3 and len(t) < 45 and starts_new
        if cur and (x > base + 2 or tail):
            paras.append(' '.join(cur))
            cur = []
        cur.append(t)
        if tail:
            paras.append(' '.join(cur))
            cur = []
    if cur:
        paras.append(' '.join(cur))

    points, hints = [], []
    for _, _, t, *_r in rs[b0:]:
        if HINTLINE.match(t):
            hints.append(t)
            continue
        m = BULLET.match(t)
        if m and not hints:
            points.append(clean(m.group(1).rstrip(' .')))

    m = re.search(r'mindestens\s*(\d{2,3})\s*W', text)
    return {
        'intro': clean(' '.join(r[2] for r in rs[:g])),
        'greeting': rs[g][2],
        'paragraphs': [p for p in paras if p],
        'signature': sig,
        'task': clean(task),
        'points': points,
        'hints': hints,
        'minWords': int(m.group(1)) if m else 100,
    }
