#!/usr/bin/env python3
"""فحص نحوي للترحيلات — بلا قاعدة بيانات.

★ ليش مو كفاية نشغّل الاختبارات على Postgres حيّ؟
  لأنّ Postgres بيقبل أشياء المحلّل السكوني ما بيقبلها، والعكس. مثال
  وقعنا فيه: الإسناد لحقل جوّا %rowtype (v_u.lang := …) بيمرق على
  قاعدة حيّة وبيفشل هون، لأنّ المحلّل ما بيقدر يحلّ نوع الصفّ بلا
  قاعدة. فالاتنين لازم يشتغلوا.

★ ومصدر واحد: البايبلاين والاختبارات المحلية بينادوا هالملف. نسختين
  معناها إنّ وحدة بتتحدّث والتانية لأ، وبيرجع خطأ يمرق محلياً ويوقف
  البايبلاين بعد الدفع.

    python3 tools/check_sql.py          # كل الترحيلات
"""
import glob, re, sys

try:
    import pglast
except ImportError:
    print("· pglast مو مثبّت — تخطّي (pip install pglast)")
    sys.exit(0)

bad = 0
for f in sorted(glob.glob('supabase/migrations/*.sql')):
    s = open(f).read()
    try:
        pglast.parse_sql(s)
        # أجسام plpgsql بتنفحص لحالها: parse_sql بيشوفها نصّ وبس
        for m in re.finditer(r'(create or replace function (\w+).*?\$\$;)', s, re.S):
            if 'language sql' in m.group(1)[:300]:
                continue
            pglast.parse_plpgsql(m.group(1)[:-1])
        print(f'  ✓ {f}')
    except Exception as e:
        bad += 1
        print(f'  ✗ {f}: {e}')

sys.exit(1 if bad else 0)
