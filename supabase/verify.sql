-- =====================================================================
-- فحص التركيب — الصقيه بـ SQL Editor بعد setup.sql والبذور
--
-- بيرجّع جدول: كل سطر فحص، مع ✓ أو ✗ وشو لازم تعملي إذا فشل.
-- ما بيعدّل ولا شي — قراءة بس.
-- =====================================================================

with checks as (

  -- ---------- الجداول ----------
  select 1::numeric as ord, 'الجداول' as المجموعة,
    format('%s جدول من ١٦', count(*)) as الفحص,
    (count(*) >= 16) as تمام,
    'شغّلي supabase/setup.sql كامل' as الحل
  from information_schema.tables
   where table_schema = 'public' and table_type = 'BASE TABLE'

  -- ---------- ★ الحلول مقفولة ----------
  union all
  select 2, 'الحماية',
    'item_answers عليه RLS وما إله ولا سياسة قراءة',
    (select relrowsecurity from pg_class where relname = 'item_answers')
      and not exists (select 1 from pg_policy p
                       where p.polrelid = 'item_answers'::regclass),
    'خطر: شغّلي 0002_rls.sql — الحلول مكشوفة'

  union all
  select 3, 'الحماية',
    'item_answers ممنوع على authenticated',
    not has_table_privilege('authenticated', 'item_answers', 'SELECT'),
    'خطر: revoke all on table item_answers from authenticated, anon;'

  union all
  select 4, 'الحماية',
    'items ما فيه عمود answer',
    not exists (select 1 from information_schema.columns
                 where table_name = 'items' and column_name = 'answer'),
    'المخطط غلط — أعيدي setup.sql على قاعدة نظيفة'

  -- ---------- الصلاحيات ----------
  union all
  select 5, 'الصلاحيات',
    format('%s جدول عليه RLS', count(*) filter (where relrowsecurity)),
    count(*) filter (where not relrowsecurity) = 0,
    'في جدول بلا RLS — شغّلي 0002_rls.sql'
  from pg_class
   where relnamespace = 'public'::regnamespace and relkind = 'r'

  union all
  select 6, 'الصلاحيات',
    'authenticated بيقدر يقرا tests',
    has_table_privilege('authenticated', 'tests', 'SELECT'),
    'ناقص GRANT — شغّلي آخر قسم من 0002_rls.sql'

  -- ---------- الدوال ----------
  union all
  select 7, 'الدوال',
    format('%s دالة من ٢٦', count(*)),
    count(*) >= 26,
    'ناقص ترحيلات — شغّلي setup.sql كامل'
  from pg_proc p join pg_namespace n on n.oid = p.pronamespace
   where n.nspname = 'public'

  union all
  select 8, 'الدوال',
    'admin_create_codes نسخة وحدة بس',
    (select count(*) from pg_proc where proname = 'admin_create_codes') = 1,
    'نسختين = نداء ملتبس. شغّلي 0010_code_uses.sql'

  union all
  select 9, 'الدوال',
    'writing_finish ممنوعة على authenticated',
    not has_function_privilege('authenticated',
      'writing_finish(uuid,jsonb,jsonb,text,text,text)', 'execute'),
    'خطر: الطالب بيقدر يكتب علامته. شغّلي 0007_writing.sql'

  -- ---------- المحتوى ----------
  union all
  select 10, 'المحتوى',
    format('%s امتحان منشور', count(*) filter (where published)),
    count(*) > 0,
    'شغّلي supabase/seed/b1.sql'
  from tests

  union all
  select 11, 'المحتوى',
    format('%s سؤال · %s حل', (select count(*) from items),
           (select count(*) from item_answers)),
    (select count(*) from items) > 0
      and (select count(*) from item_answers) > 0,
    'البذور ما انحمّلت — شغّلي supabase/seed/b1.sql'

  union all
  select 12, 'المحتوى',
    'كل سؤال (غير التعبير الكتابي) إله حل',
    (select count(*) from items i
       join sections s on s.id = i.section_id
       left join item_answers a on a.item_id = i.id
      where s.format <> 'writing' and a.item_id is null) = 0,
    'في أسئلة بلا حلول — ما رح تنصحّح'

  union all
  select 13, 'المحتوى',
    format('%s مستوى منشور', count(*) filter (where published)),
    count(*) filter (where published) > 0,
    'المستوى مخفي — اللوحة ← Inhalte ← Stufen ← online stellen'
  from levels

  -- ---------- الأدمن ----------
  union all
  select 14, 'الأدمن',
    format('%s حساب أدمن', count(*)),
    count(*) > 0,
    'اعملي مستخدم بـAuthentication ثم: update profiles set is_admin=true where id=''<UID>'';'
  from profiles where is_admin

  -- ---------- التخزين ----------
  union all
  select 14.1, 'التخزين',
    'الدلوان موجودان وخاصّان',
    (select count(*) from storage.buckets
      where id in ('exam-images','exam-audio') and not public) = 2,
    'شغّلي 0013_storage.sql. دلو عام = أي حدا معه الرابط بيفوت'

  union all
  select 14.2, 'التخزين',
    'سياسة قراءة الملفات موجودة',
    exists (select 1 from pg_policy
             where polrelid = 'storage.objects'::regclass
               and polname = 'exam_assets_read'),
    'بلا سياسة، كل طلب توقيع بيرجع 403 والصور ما بتظهر بلا خطأ ظاهر'

  union all
  select 14.3, 'التخزين',
    format('%s صورة مرفوعة من %s لازمة',
      (select count(*) from storage.objects where bucket_id = 'exam-images'),
      (select count(*) from sections where config ? 'bankImage')),
    (select count(*) from storage.objects where bucket_id = 'exam-images')
      >= (select count(*) from sections where config ? 'bankImage'),
    'ارفعي الصور: python3 tools/upload_images.py data/img/'

  -- ---------- Supabase نفسها ----------
  union all
  select 15, 'Supabase',
    'دالة auth.uid() موجودة',
    exists (select 1 from pg_proc p join pg_namespace n on n.oid = p.pronamespace
             where n.nspname = 'auth' and p.proname = 'uid'),
    'مو مشروع Supabase؟'

  union all
  select 16, 'Supabase',
    'الأدوار anon و authenticated موجودة',
    (select count(*) from pg_roles where rolname in ('anon','authenticated')) = 2,
    'مو مشروع Supabase؟'
)

-- الملخّص بينحسب من نفس الفحوص فوق، مو من قائمة شروط منسوخة: النسخة
-- المكرّرة بتنسى الفحوص الجديدة وبتقول «كل شي تمام» وفي فحص فاشل.
select "حالة", المجموعة, الفحص, "شو تعملي"
from (
  select ord,
    case when تمام then '✓' else '✗' end as "حالة",
    المجموعة, الفحص,
    case when تمام then '' else الحل end as "شو تعملي"
  from checks

  union all
  select 999,
    case when (select count(*) from checks where not تمام) = 0 then '✓' else '✗' end,
    '—', 'النتيجة',
    case when (select count(*) from checks where not تمام) = 0
      then 'كل الفحوص نجحت — التركيب تمام'
      else format('%s فحص فشل — شوفي العمود الأخير',
                  (select count(*) from checks where not تمام)) end
) x
order by ord;
