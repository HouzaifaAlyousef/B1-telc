#!/usr/bin/env python3
"""شيل التعليقات من JS/CSS قبل النشر.

الطالب بيقدر يفتح أدوات المطوّر ويقرا كل ملف بينزل لمتصفّحه — هيك كل
تطبيق ويب، وما في سرّ بالكود (المفتاح العام عام بالتصميم، والحلول
بالسيرفر). بس تعليقات التطوير ما إلها شغل بمنتج بيدفع فيه ناس.

★ ليش ماسح بدل regex: `//` جوّا نص، و`/*` جوّا template literal، و`//`
  جوّا تعبير نمطي — كلهن بينخدعوا بأي regex. الماسح بيتبع الحالة:
  نص عادي، نص بعلامة، template literal (مع ${} متداخل)، تعبير نمطي.
  والفحص النهائي `node --check` على الناتج.

    python3 tools/strip_comments.py in.js out.js
"""
import sys, re


def strip_js(src: str) -> str:
    """ماسح بمكدّس حالات.

    النسخة الأولى كانت بتكسر عند template فيه نص جوّا ${}: كانت تخرج من
    حلقة الـtemplate وترجع للحلقة الرئيسية، والباك-تِك الأخير كان يبلّش
    template جديد فيبلع كود حقيقي — وتوقف التنقية من هونيك لآخر الملف.

    المكدّس بيحلّها: كل `${` بيدفع حالة «كود» فوق الـtemplate، و`}` عند
    عمق صفر بيرجّع للـtemplate. التداخل بيشتغل لأي عمق.
    """
    out = []
    i, n = 0, len(src)
    # كل عنصر: ['code', عمق الأقواس] أو ['tmpl', 0]
    stack = [['code', 0]]

    def last_significant():
        for ch in reversed(out):
            if not ch.isspace():
                return ch
        return ''

    while i < n:
        top = stack[-1]
        c = src[i]
        nxt = src[i + 1] if i + 1 < n else ''

        # ---------- جوّا template literal ----------
        if top[0] == 'tmpl':
            if c == '\\':
                out.append(src[i:i + 2]); i += 2; continue
            if c == '`':
                out.append(c); i += 1; stack.pop(); continue
            if c == '$' and nxt == '{':
                out.append('${'); i += 2; stack.append(['code', 0]); continue
            out.append(c); i += 1; continue

        # ---------- حالة كود ----------
        # `}` بعمق صفر جوّا ${} بيرجّع للـtemplate يلي فوقه
        if c == '}' and len(stack) > 1 and top[1] == 0:
            out.append(c); i += 1; stack.pop(); continue
        if c == '{':
            top[1] += 1; out.append(c); i += 1; continue
        if c == '}':
            top[1] -= 1; out.append(c); i += 1; continue

        if c == '/' and nxt == '/':
            while i < n and src[i] != '\n':
                i += 1
            continue

        if c == '/' and nxt == '*':
            i += 2
            while i < n and not (src[i] == '*' and i + 1 < n and src[i + 1] == '/'):
                i += 1
            i += 2
            out.append(' ')          # ما منلصق الرمزين ببعض
            continue

        if c in '"\'':
            q = c
            out.append(c); i += 1
            while i < n:
                if src[i] == '\\':
                    out.append(src[i:i + 2]); i += 2; continue
                out.append(src[i])
                if src[i] == q:
                    i += 1; break
                i += 1
            continue

        if c == '`':
            out.append(c); i += 1; stack.append(['tmpl', 0]); continue

        # `/` بيبدأ تعبير نمطي إذا آخر رمز مهم مو قيمة
        if c == '/':
            ls = last_significant()
            if ls == '' or ls in '(,=:[!&|?{};+-*%~^<>':
                out.append(c); i += 1
                in_class = False
                while i < n:
                    if src[i] == '\\':
                        out.append(src[i:i + 2]); i += 2; continue
                    if src[i] == '[': in_class = True
                    elif src[i] == ']': in_class = False
                    elif src[i] == '/' and not in_class:
                        out.append('/'); i += 1
                        while i < n and src[i].isalpha():   # الرايات
                            out.append(src[i]); i += 1
                        break
                    elif src[i] == '\n':
                        break
                    out.append(src[i]); i += 1
                continue

        out.append(c); i += 1

    txt = ''.join(out)
    txt = re.sub(r'[ \t]+\n', '\n', txt)
    txt = re.sub(r'\n{3,}', '\n\n', txt)
    return txt.strip() + '\n'


def strip_css(src: str) -> str:
    out, i, n = [], 0, len(src)
    while i < n:
        if src[i] == '/' and i + 1 < n and src[i + 1] == '*':
            i += 2
            while i < n and not (src[i] == '*' and i + 1 < n and src[i + 1] == '/'):
                i += 1
            i += 2
            continue
        if src[i] in '"\'':
            q = src[i]; out.append(src[i]); i += 1
            while i < n:
                if src[i] == '\\':
                    out.append(src[i:i + 2]); i += 2; continue
                out.append(src[i])
                if src[i] == q:
                    i += 1; break
                i += 1
            continue
        out.append(src[i]); i += 1
    txt = ''.join(out)
    txt = re.sub(r'[ \t]+\n', '\n', txt)
    txt = re.sub(r'\n{3,}', '\n\n', txt)
    return txt.strip() + '\n'


def main():
    if len(sys.argv) != 3:
        print(__doc__); sys.exit(2)
    src = open(sys.argv[1], encoding='utf-8').read()
    fn = strip_css if sys.argv[1].endswith('.css') else strip_js
    open(sys.argv[2], 'w', encoding='utf-8').write(fn(src))


if __name__ == '__main__':
    main()
