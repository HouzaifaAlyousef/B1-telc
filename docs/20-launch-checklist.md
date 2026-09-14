# وين صرنا، وشو ضايل

**افتح بفحص واحد:**

```
Supabase → SQL Editor → الصق supabase/health.sql → Run
```

للقراءة فقط، بيشتغل حتى على قاعدة فاضية، وبيقول **شو ناقص وشو الأمر
يلي بيصلّحه** — مو بس «فيه مشكلة».

---

## اللي انعمل

| | |
|---|---|
| المحتوى | telc B1 (١٧) · telc B2 (٨) · ÖSD A1 (٨) |
| الأكواد | صيغة حرفين + ١٠ أرقام، بلا فراغات |
| البوت | تجريبي ذاتي · وصول كامل بموافقتك · حجز · «كودي» · تنبيه الانتهاء · مشاركة |
| قائمة الانتظار | جاهزة، والحدّ من اللوحة |
| التصحيح الآلي | Gemini — الدالة والواجهة جاهزين |
| بلّغ عن مشكلة | زرّ (ℹ) بكل امتحان ← اللوحة ← Meldungen · `docs/26-problem-melden.md` |
| الاختبارات | ٨٨ دالة · ١٢٢ متصفّح · ٨٠ لوحة · ٤٢ أدوات · ٣٨٩ SQL |

## اللي ضايل

### ١. تسجيلات Hörverstehen — الوحيدة الكبيرة

**ولا تسجيل بأي مستوى.** يعني **ربع الامتحان معطّل** بالمستويات
التلاتة.

`bot_sweep_expiring` وكل شي تاني شغّال بلاها، بس الطالب يلي بيفتح
Hörverstehen بيلاقي أسئلة بلا صوت.

الرفع: `python3 tools/upload_audio.py <مجلّد>` — نفس فكرة الصور.

الفحص بيقول لك: صفّ **الصوت**.

### ٢. Aufgabe 58 لـB2 (modell-01 … 07)

الترقيم بيوقف عند ٥٧. المادة مو بالـPDF — لازم مواضيع من التيليغرام.
`docs/23-b2-forumsbeitrag.md` فيه الصيغة الجاهزة.

modell-08 عنده Aufgabe 58 أصلاً.

### ٣. الـ٢٧ نقطة Grammatik بـB2

قرار مفتوح — `docs/22-b2-punkte-fix.md` الجزء ٤.

### ٤. ترخيص المحتوى

**قبل أوّل يورو، مو بعده.** `docs/10-commercialisation.md`.

---

## شغلات ما بيقدر الفحص يشوفها

القاعدة ما بتعرف شو منشور بـEdge Functions ولا شو بالأسرار. تفقّدهن
بالإيد — الفحص بيذكّرك فيهن بآخر الجدول:

| | وين | انتبه |
|---|---|---|
| دالة `telegram` | Edge Functions | **Verify JWT مطفيّة** |
| دالة `correct-writing` | Edge Functions | **Verify JWT مفعّلة** — عكس البوت |
| الأسرار الخمسة | Edge Functions → Secrets | `TELEGRAM_BOT_TOKEN` · `TELEGRAM_WEBHOOK_SECRET` · `APP_URL` · `ADMIN_CHAT_ID` · `GEMINI_API_KEY` |
| الدخول المجهول | Authentication → Providers | بلاه الكود بيفشل عند الطالب |
| فرع Cloudflare | Workers → b1-telc → Builds | لازم `kiko-branch` |

> **قرار مسجّل (٢٠٢٦-٠٩-٠٩):** `kiko-branch` هو فرع العمل، و`main` ما
> بينندمج فيه. مين بيفتح المستودع على GitHub بيشوف `main` الافتراضي
> وما بيلاقي الشغل الجديد — يستعمل مبدّل الفروع.

---

## لمّا تضيف محتوى جديد

```bash
node tools/check_content.mjs                       # فحص
node tools/content_to_seed.mjs <مؤسسة>/<درجة> supabase/seed/<درجة>.sql
./tools/split_seed.sh <درجة>                       # لو أكبر من ٢٠٠ ك.ب
python3 tools/upload_images.py content             # الصور كلها بأمر واحد
```

الأوّل والتاني عليهن فحص انحراف بـ`tests/tools.sh` — بيفشل لو نسيت
تعيد التوليد، وبيدور على كل مستوى لحاله فما بينسى مستوى جديد.

🔴 **`service_role` بجهازك بس.** ولا مرّة بغيت، ولا بالمتصفّح، ولا
بشات. لو انكشف: Project Settings → API → **Reset service_role key**.
