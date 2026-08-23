"""استخراج نص ملف telc B1 من الـPDF.

الـPDF مرسوم بطبقتين متطابقتين فوق بعض، فكل حرف موجود مرتين بنفس الإحداثيات
تماماً. منشيل التكرار حسب الموقع (x0, top, حرف)، وبعدين منجمّع الحروف بسطور
وكلمات حسب المسافات. هيك منحافظ على ترتيب الأعمدة بدون مسافات دخيلة.
"""
import collections, re, sys
import pdfplumber

LINE_TOL   = 2.2    # فرق ارتفاع بيعتبر نفس السطر
SPACE_GAP  = 1.2    # مضروب بعرض الحرف → فراغ = مسافة
COL_GAP    = 12     # فراغ كبير = فاصل أعمدة


def dedupe(chars):
    seen, out = set(), []
    for c in chars:
        key = (round(c['x0'], 1), round(c['top'], 1), c['text'])
        if key not in seen:
            seen.add(key)
            out.append(c)
    return out


def to_lines(chars):
    """يجمع الحروف بسطور مرتّبة، مع مسافات حسب الفراغات الأفقية."""
    rows = []
    for c in sorted(chars, key=lambda c: (round(c['top'], 1), c['x0'])):
        if rows and abs(rows[-1][0] - c['top']) <= LINE_TOL:
            rows[-1][1].append(c)
        else:
            rows.append([c['top'], [c]])

    lines = []
    for top, cs in rows:
        cs.sort(key=lambda c: c['x0'])
        buf, prev = [], None
        for c in cs:
            if prev is not None:
                gap = c['x0'] - prev['x1']
                width = max(prev['x1'] - prev['x0'], 1)
                if gap > COL_GAP:
                    buf.append('   ')            # فاصل أعمدة
                elif gap > width * SPACE_GAP * 0.35:
                    buf.append(' ')
            buf.append(c['text'])
            prev = c
        text = re.sub(r'[ \t]+\n', '\n', ''.join(buf)).rstrip()
        if text.strip():
            lines.append((round(top, 1), text))
    return lines


def page_lines(page):
    return to_lines(dedupe(page.chars))


def page_text(page):
    return '\n'.join(t for _, t in page_lines(page))


if __name__ == '__main__':
    src  = sys.argv[1] if len(sys.argv) > 1 else 'Doku/B1 Telc.pdf'
    dest = sys.argv[2] if len(sys.argv) > 2 else 'clean.txt'
    chunks, empty = [], []
    with pdfplumber.open(src) as pdf:
        for i, pg in enumerate(pdf.pages, 1):
            txt = page_text(pg)
            if len(txt) < 120:
                empty.append(i)
            chunks.append(f"\n\n=========== PAGE {i} ===========\n{txt}")
    open(dest, 'w', encoding='utf-8').write(''.join(chunks))
    print(f'wrote {dest}')
    print(f'صفحات شبه فاضية (صور): {empty}')
