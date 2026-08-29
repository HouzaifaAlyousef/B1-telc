"""تصحيح أخطاء الإملاء الناتجة عن نسخ/تصوير الـPDF.

نص المصدر فيه أخطاء متكررة من الطباعة: حروف مضاعفة (`wwie`، `LLeuten`)،
أوملاوت ضايع (`wunderschon`)، كلمتين ملزوقات (`passendeReihenfolge`)، وكلمة
مقطوعة على توكنين (`Prak tikantinnen`).

الطريقة: منقترح تصحيح بقاعدة، وما منقبله إلا إذا الناتج كلمة موجودة بقاموس
ألماني والأصل مو موجود فيه. هيك ما منلمس الكلمات المركّبة السليمة (`Deutschkurs`)
ولا أسماء العلم. وفوق هيك في قائمة استثناءات وقائمة تصحيحات يدوية للحالات
اللي القاعدة بتغلط فيها.
"""
import functools
import re

# كلمات صح رغم إنها مو بالقاموس — ممنوع تنلمس
KEEP = {
    'Bess',            # Porgy and Bess (اسم أوبرا)
    'CFF', 'FF', 'SBB',  # SBB CFF — سكك حديد سويسرا
    'Mall',            # Pall Mall - Initiative
    'Maus', 'Oleum',   # "Maus Oleum" — تورية باسم معرض، ممنوع تنلزق
    'aon',             # Krapfi@aon.at — جزء من بريد إلكتروني
    'Joint', 'Venture',  # "Joint Venture" — بتنكتب منفصلة
    'Buschhaus',       # اسم شخص (Matthias Buschhaus)
    'Mathematiknachhilfe',   # كلمة مركّبة سليمة
}

# حالات القاعدة بتقترح فيها تصحيح غلط
OVERRIDE = {
    'Unterlangen': 'Unterlagen',   # القاعدة بتقترح "Unterlängen"
    # حروف مضاعفة بكلمات مركّبة — القاموس ما بيعرف الناتج فالقاعدة بتعجز
    'Einfühhrungsseminars': 'Einführungsseminars',
    'Elektroniikwerkk': 'Elektronikwerk',
    'Sprachhaufenhalt': 'Sprachaufenthalt',
    # كلمات ملزوقة والقاعدة ما بتفكّها لأن أحد الطرفين مو بالقاموس
    'GrüßeSSaskia': 'Grüße Saskia',
    'LesenimZug': 'Lesen im Zug',
    'PlaudernundFreunden': 'Plaudern und Freunden',
    'BefragtenGrundfür': 'Befragten Grund für',
    'BildungsDidacta': 'Bildungs-Didacta',
}

WORD = re.compile(r"[A-Za-zÄÖÜäöüßẞ]+")
UMLAUT = (('u', 'ü'), ('o', 'ö'), ('a', 'ä'), ('U', 'Ü'), ('O', 'Ö'), ('A', 'Ä'))


@functools.lru_cache(maxsize=1)
def _dict():
    from spellchecker import SpellChecker
    return SpellChecker(language='de').word_frequency.dictionary


# مفردات من الملف نفسه — الألماني بيركّب كلمات كتير مو موجودة بالقاموس
# (Sprachkurs, Deutschkurs...). منستعملها بس تا نسمح بلزق كلمة مقطوعة،
# مو تا نمنع تصحيح — هيك الخطأ المتكرر بيضل ينتصحّح.
_CORPUS = set()


def learn(counter, min_count=2):
    """يسجّل الكلمات اللي ظهرت بالملف أكتر من مرة كمفردات معروفة."""
    _CORPUS.clear()
    _CORPUS.update(w.lower() for w, c in counter.items() if c >= min_count and len(w) > 3)


def known(w):
    return bool(w) and w.lower() in _dict()


def standalone(w):
    """كلمة قائمة بذاتها. القاموس فيه حروف مفردة، وهي مو كلمات هون —
    غالباً بتكون علامة مدخل ببنك الكلمات أو بقية كلمة مقطوعة."""
    return len(w) >= 2 and known(w)


def plausible(w):
    """كلمة معروفة بالقاموس أو متكررة بالملف."""
    return known(w) or (bool(w) and w.lower() in _CORPUS)


@functools.lru_cache(maxsize=None)
def fix_word(w):
    """يصلّح كلمة وحدة، أو يرجّعها كما هي إذا ما في تصحيح موثوق."""
    if w in OVERRIDE:
        return OVERRIDE[w]
    if w in KEEP or len(w) < 3 or known(w):
        return w

    # حرف مضاعف: wwie → wie
    for i in range(len(w) - 1):
        if w[i].lower() == w[i + 1].lower() and known(w[:i] + w[i + 1:]):
            return w[:i] + w[i + 1:]
    # أوملاوت ضايع: wunderschon → wunderschön
    for i, ch in enumerate(w):
        for a, b in UMLAUT:
            if ch == a and known(w[:i] + b + w[i + 1:]):
                return w[:i] + b + w[i + 1:]
    # كلمتين ملزوقات بحرف كبير: passendeReihenfolge → passende Reihenfolge
    for m in re.finditer(r'(?<=[a-zäöüß])(?=[A-ZÄÖÜ])', w):
        i = m.start()
        if known(w[:i]) and known(w[i:]):
            return w[:i] + ' ' + w[i:]
    return w


def repair(text):
    """يصلّح نص كامل: كلمة كلمة، وبعدين الكلمات المقطوعة على توكنين."""
    if not text:
        return text

    # قسّم لكلمات وفواصل، تا نقدر نمرّ مرّة وحدة من اليسار لليمين
    parts = re.split(r'([A-Za-zÄÖÜäöüßẞ]+)', text)   # فردي = كلمة
    words = [(i, parts[i]) for i in range(1, len(parts), 2)]

    for i, w in words:
        parts[i] = fix_word(w)

    # كلمة مقطوعة على توكنين: "Prak tikantinnen" → "Praktikantinnen"
    # لازم الطرفين التنين يكونوا مو كلمات قائمة بذاتها — وإلا منلزق كلمة
    # سليمة بحرف بعدها (متل "TAGE n" ببنك الكلمات → "TAGEn").
    idx, k = [i for i, _ in words], 0
    while k < len(idx) - 1:
        i, j = idx[k], idx[k + 1]
        a, b = parts[i], parts[j]
        if parts[i + 1] == ' ' and a and b and a not in KEEP and b not in KEEP \
                and not standalone(a) and not standalone(b) and plausible(a + b):
            parts[i], parts[i + 1], parts[j] = a + b, '', ''
            k += 2                       # التنتين انلزقوا
        else:
            k += 1
    return ''.join(parts)
