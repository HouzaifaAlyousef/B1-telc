/**
 * بوت تلغرام: بيوزّع أكواد تجريبية بلا تدخّل.
 *
 * المسار: /start ← لغة ← مؤسسة ← درجة ← كود + رابط.
 *
 * ★ ما في حالة محفوظة بين الرسائل. كل خطوة بتحمل يلي قبلها جوّا
 *   callback_data («l|ar|telc|telc-b1»). محادثة نصّها ضايع أو رسالة قديمة
 *   بينضغط عليها بعد يومين بتشتغل متل ما هي — وبلا جدول جلسات.
 *
 * ★ الصلاحية محدودة بالقاعدة مو هون: bot_demo_code ما بتعرف تعمل غير
 *   تجريبي. حتى لو انسرق التوكن، أقصى ضرر أكواد تجريبية.
 *
 * أسرار لازمة (Supabase ← Edge Functions ← Secrets):
 *   TELEGRAM_BOT_TOKEN        من BotFather
 *   TELEGRAM_WEBHOOK_SECRET   نص عشوائي، منمرّره لـsetWebhook ومنقارنه هون
 *   APP_URL                   رابط التطبيق يلي بينبعت للطالب
 *   ADMIN_CHAT_ID             قناة/مجموعة خاصة بتوصلها الطلبات
 *   SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY  (بتنحط لحالها)
 *
 * النشر:  supabase functions deploy telegram --no-verify-jwt
 *   (--no-verify-jwt لأن تلغرام ما بيبعت JWT؛ الحماية بالترويسة السرّية)
 */

const TOKEN   = Deno.env.get("TELEGRAM_BOT_TOKEN") ?? "";
const SECRET  = Deno.env.get("TELEGRAM_WEBHOOK_SECRET") ?? "";
const APP_URL = Deno.env.get("APP_URL") ?? "";
const ADMIN   = Deno.env.get("ADMIN_CHAT_ID") ?? "";   // قناتك الخاصة
const SUPA    = Deno.env.get("SUPABASE_URL") ?? "";
const SVC     = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

const TG = (m: string) => `https://api.telegram.org/bot${TOKEN}/${m}`;

/* ---------------- النصوص ---------------- */
type Lang = "ar" | "de" | "uk" | "en";
const LANGS: { id: Lang; label: string }[] = [
  { id: "ar", label: "ع  العربية" },
  { id: "de", label: "🇩🇪 Deutsch" },
  { id: "uk", label: "🇺🇦 Українська" },
  { id: "en", label: "🇬🇧 English" },
];

const T: Record<Lang, Record<string, string>> = {
  ar: {
    hello: "أهلاً! 👋\nاختار لغتك:",
    pickProvider: "اختار نوع الامتحان:",
    pickStufe: "اختار المستوى:",
    none: "ما في امتحانات متاحة هلق. جرّب بعدين.",
    got: "تفضّل نسختك التجريبية 🎁",
    codeIs: "الرمز:",
    linkIs: "الرابط:",
    what: "بيفتحلك: {test}\nلمدّة {h} ساعة، على جهاز واحد.",
    how: "افتح الرابط، واكتب الرمز بصفحة الدخول.",
    again: "أخدت نسختك التجريبية من قبل — هيدا نفس الرمز:",
    used: "⚠️ هالرمز انستعمل. للوصول الكامل احكي معنا.",
    err: "صار خطأ. جرّب بعد شوي.",
    back: "‹ رجوع",
    full: "🔓 بدّي الوصول الكامل",
    share: "📣 خبّر رفقاتك",
    shareText: "امتحانات telc تجريبية مجاناً 👇",
    pickMonths: "لكم شهر بدّك الوصول الكامل؟",
    mon: "{n} شهر",
    sent: "طلبك وصل ✅\nاستنى شوي — رح يوصلك ردّ قريباً.",
    pending: "عندك طلب معلّق ⏳\nاستنى الردّ عليه.",
    needDemo: "خد نسختك التجريبية أوّلاً، بعدها فيك تطلب الوصول الكامل.",
    okFull: "تمّت الموافقة! 🎉",
    fullWhat: "بيفتحلك كل امتحانات {lvl} لمدّة {m} شهر، على جهازين.",
    noFull: "طلبك للأسف ما انقبل.",
    rj_soon: "مو متاح هلق — جرّب بعد فترة.",
    rj_demo: "استفد من نسختك التجريبية أوّلاً.",
    rj_contact: "احكي معنا مباشرةً منشان نرتّبلك ياه.",
    rj_no: "الطلب مرفوض.",
    mTrial: "🎁 نسختي التجريبية",
    mFull: "🔓 وصول كامل",
    mLang: "🌐 اللغة",
    mShare: "📣 شارك البوت",
    copyCode: "📋 انسخ الرمز",
    intro: "أهلاً فيك! 👋\n\nهون بتاخد <b>رمز مجّاني</b> بيفتحلك امتحان نموذجي كامل — قراءة، سماع، وكتابة — لمدّة <b>٢٤ ساعة</b>.\n\n• بلا تسجيل وبلا دفع\n• كل مستوى فيك تجرّبه مرّة\n• بتقدر تطلب وصول كامل بضغطة",
    mMine: "🎟 كودي",
    noCodes: "لسا ما أخدت ولا كود. اضغط «🎁 نسختي التجريبية».",
    myTitle: "أكوادك:",
    kDemo: "تجريبي",
    kFull: "وصول كامل",
    leftH: "باقي {h} ساعة",
    leftM: "باقي {m} دقيقة",
    endedX: "انتهى",
    notUsed: "ما انفعّل بعد",
    tryOther: "🎓 جرّب مستوى تاني",
    allTried: "جرّبت كل المستويات المتاحة 👏",
    warnTitle: "⏰ باقي أقلّ من ساعة على تجريبي {lvl}",
    warnBody: "خلّص يلي بدّك ياه، أو اضغط «🔓 وصول كامل» لتكمّل بلا وقت.",
    waShare: "💬 واتساب",
    tgShare: "📲 تلغرام",
    copyHint: "أو انسخ الرابط وابعته لوين ما بدّك:",
  },
  de: {
    hello: "Willkommen! 👋\nBitte Sprache wählen:",
    pickProvider: "Welche Prüfung?",
    pickStufe: "Welche Stufe?",
    none: "Zurzeit sind keine Prüfungen verfügbar. Bitte später noch einmal.",
    got: "Hier ist Ihre kostenlose Testversion 🎁",
    codeIs: "Code:",
    linkIs: "Link:",
    what: "Damit öffnen Sie: {test}\n{h} Stunden lang, auf einem Gerät.",
    how: "Link öffnen und den Code auf der Startseite eingeben.",
    again: "Sie haben Ihre Testversion schon erhalten — das ist derselbe Code:",
    used: "⚠️ Dieser Code wurde bereits eingelöst. Für den vollen Zugang melden Sie sich bei uns.",
    err: "Es ist ein Fehler aufgetreten. Bitte später noch einmal.",
    back: "‹ Zurück",
    full: "🔓 Vollzugang anfragen",
    share: "📣 Bot weiterempfehlen",
    shareText: "telc-Modelltests kostenlos testen 👇",
    pickMonths: "Für wie viele Monate?",
    mon: "{n} Monate",
    sent: "Anfrage eingegangen ✅\nBitte kurz warten — Sie bekommen bald eine Antwort.",
    pending: "Sie haben eine offene Anfrage ⏳\nBitte warten Sie auf die Antwort.",
    needDemo: "Holen Sie sich zuerst Ihre Testversion, danach können Sie Vollzugang anfragen.",
    okFull: "Freigegeben! 🎉",
    fullWhat: "Öffnet alle Modelltests von {lvl} für {m} Monate, auf zwei Geräten.",
    noFull: "Ihre Anfrage wurde leider nicht bewilligt.",
    rj_soon: "Zurzeit nicht möglich — bitte später noch einmal.",
    rj_demo: "Nutzen Sie bitte zuerst Ihre Testversion.",
    rj_contact: "Melden Sie sich bitte direkt bei uns.",
    rj_no: "Anfrage abgelehnt.",
    mTrial: "🎁 Meine Testversion",
    mFull: "🔓 Vollzugang",
    mLang: "🌐 Sprache",
    mShare: "📣 Bot teilen",
    copyCode: "📋 Code kopieren",
    intro: "Willkommen! 👋\n\nHier bekommen Sie einen <b>kostenlosen Code</b> für einen kompletten Modelltest — Lesen, Hören und Schreiben — <b>24 Stunden</b> lang.\n\n• Ohne Anmeldung, ohne Bezahlung\n• Jede Stufe einmal testen\n• Vollzugang auf Anfrage, ein Tippen",
    mMine: "🎟 Mein Code",
    noCodes: "Noch kein Code. Tippen Sie auf „🎁 Meine Testversion“.",
    myTitle: "Ihre Codes:",
    kDemo: "Test",
    kFull: "Vollzugang",
    leftH: "noch {h} Std.",
    leftM: "noch {m} Min.",
    endedX: "abgelaufen",
    notUsed: "noch nicht eingelöst",
    tryOther: "🎓 Andere Stufe testen",
    allTried: "Sie haben alle Stufen getestet 👏",
    warnTitle: "⏰ Weniger als eine Stunde für {lvl}",
    warnBody: "Machen Sie fertig, was Sie wollen — oder „🔓 Vollzugang“ für unbegrenzt.",
    waShare: "💬 WhatsApp",
    tgShare: "📲 Telegram",
    copyHint: "Oder Link kopieren und überall teilen:",
  },
  uk: {
    hello: "Вітаємо! 👋\nОберіть мову:",
    pickProvider: "Який іспит?",
    pickStufe: "Який рівень?",
    none: "Наразі немає доступних іспитів. Спробуйте пізніше.",
    got: "Ось ваша безкоштовна пробна версія 🎁",
    codeIs: "Код:",
    linkIs: "Посилання:",
    what: "Відкриє: {test}\nна {h} годин, на одному пристрої.",
    how: "Відкрийте посилання та введіть код на початковій сторінці.",
    again: "Ви вже отримали пробну версію — це той самий код:",
    used: "⚠️ Цей код уже використано. Щодо повного доступу — напишіть нам.",
    err: "Сталася помилка. Спробуйте пізніше.",
    back: "‹ Назад",
    full: "🔓 Повний доступ",
    share: "📣 Поділитися ботом",
    shareText: "Безкоштовні пробні іспити telc 👇",
    pickMonths: "На скільки місяців?",
    mon: "{n} міс.",
    sent: "Запит надіслано ✅\nЗачекайте — скоро отримаєте відповідь.",
    pending: "У вас є відкритий запит ⏳\nЗачекайте на відповідь.",
    needDemo: "Спочатку отримайте пробну версію, потім зможете запросити повний доступ.",
    okFull: "Схвалено! 🎉",
    fullWhat: "Відкриє всі іспити {lvl} на {m} міс., на двох пристроях.",
    noFull: "На жаль, ваш запит не схвалено.",
    rj_soon: "Зараз недоступно — спробуйте пізніше.",
    rj_demo: "Спершу скористайтеся пробною версією.",
    rj_contact: "Напишіть нам напряму.",
    rj_no: "Запит відхилено.",
    mTrial: "🎁 Моя пробна версія",
    mFull: "🔓 Повний доступ",
    mLang: "🌐 Мова",
    mShare: "📣 Поділитися",
    copyCode: "📋 Копіювати код",
    intro: "Вітаємо! 👋\n\nТут ви отримаєте <b>безкоштовний код</b> до повного пробного іспиту — читання, аудіювання та письмо — на <b>24 години</b>.\n\n• Без реєстрації та оплати\n• Кожен рівень можна спробувати раз\n• Повний доступ — одним дотиком",
    mMine: "🎟 Мій код",
    noCodes: "Ще немає коду. Натисніть «🎁 Моя пробна версія».",
    myTitle: "Ваші коди:",
    kDemo: "Пробний",
    kFull: "Повний доступ",
    leftH: "лишилось {h} год.",
    leftM: "лишилось {m} хв.",
    endedX: "завершився",
    notUsed: "ще не активований",
    tryOther: "🎓 Спробувати інший рівень",
    allTried: "Ви спробували всі рівні 👏",
    warnTitle: "⏰ Менше години для {lvl}",
    warnBody: "Завершіть потрібне — або «🔓 Повний доступ» без обмежень.",
    waShare: "💬 WhatsApp",
    tgShare: "📲 Telegram",
    copyHint: "Або скопіюйте посилання й надішліть будь-де:",
  },
  en: {
    hello: "Welcome! 👋\nChoose your language:",
    pickProvider: "Which exam?",
    pickStufe: "Which level?",
    none: "No exams available right now. Please try again later.",
    got: "Here is your free trial 🎁",
    codeIs: "Code:",
    linkIs: "Link:",
    what: "It opens: {test}\nfor {h} hours, on one device.",
    how: "Open the link and enter the code on the start page.",
    again: "You already got your trial — this is the same code:",
    used: "⚠️ This code has been used. Contact us for full access.",
    err: "Something went wrong. Please try again later.",
    back: "‹ Back",
    full: "🔓 Request full access",
    share: "📣 Share this bot",
    shareText: "Free telc practice exams 👇",
    pickMonths: "For how many months?",
    mon: "{n} months",
    sent: "Request received ✅\nPlease wait — you’ll get a reply shortly.",
    pending: "You have an open request ⏳\nPlease wait for the reply.",
    needDemo: "Get your free trial first, then you can request full access.",
    okFull: "Approved! 🎉",
    fullWhat: "Opens every exam in {lvl} for {m} months, on two devices.",
    noFull: "Your request was not approved.",
    rj_soon: "Not available right now — please try again later.",
    rj_demo: "Please use your free trial first.",
    rj_contact: "Please contact us directly.",
    rj_no: "Request declined.",
    mTrial: "🎁 My free trial",
    mFull: "🔓 Full access",
    mLang: "🌐 Language",
    mShare: "📣 Share bot",
    copyCode: "📋 Copy code",
    intro: "Welcome! 👋\n\nHere you get a <b>free code</b> for a complete practice exam — reading, listening and writing — for <b>24 hours</b>.\n\n• No sign-up, no payment\n• One trial per level\n• Full access on request, one tap",
    mMine: "🎟 My code",
    noCodes: "No code yet. Tap “🎁 My free trial”.",
    myTitle: "Your codes:",
    kDemo: "Trial",
    kFull: "Full access",
    leftH: "{h}h left",
    leftM: "{m} min left",
    endedX: "expired",
    notUsed: "not used yet",
    tryOther: "🎓 Try another level",
    allTried: "You have tried every level 👏",
    warnTitle: "⏰ Less than an hour left for {lvl}",
    warnBody: "Finish what you need — or tap “🔓 Full access” for unlimited.",
    waShare: "💬 WhatsApp",
    tgShare: "📲 Telegram",
    copyHint: "Or copy the link and share it anywhere:",
  },
};

const t = (lang: Lang, key: string, vars?: Record<string, string | number>) =>
  (T[lang]?.[key] ?? T.de[key] ?? key).replace(
    /\{(\w+)\}/g, (_, k) => String(vars?.[k] ?? ""));

/* ---------------- تلغرام ---------------- */
type Btn = { text: string; callback_data?: string; url?: string;
              copy_text?: { text: string } };

/* ★ الرمز: كتلة مميّزة + زرّ نسخ بضغطة.
   تلغرام ما بيسمح بألوان مخصّصة برسائل البوتات، بس <blockquote> بيرسم
   شريط جانبي ملوّن من ثيمة المستخدم، و<code> بيطلع بخطّ وخلفية
   مختلفين — فالرمز بينفرز عن باقي النصّ بلا ما نخترع لون.
   وcopy_text (Bot API 8.0) بينسخ بضغطة وحدة بلا «مطوّل واختار». */
const codeBlock = (code: string) =>
  `<blockquote><code>${code}</code></blockquote>`;
const copyBtn = (lang: Lang, code: string): Btn =>
  ({ text: t(lang, "copyCode"), copy_text: { text: code } });

async function tg(method: string, body: unknown) {
  const r = await fetch(TG(method), {
    method: "POST",
    headers: { "content-type": "application/json" },
    body: JSON.stringify(body),
  });
  if (!r.ok) console.error(`telegram ${method}: ${r.status} ${await r.text()}`);
  return r;
}

const rows = (btns: Btn[], perRow = 2) => {
  const out: Btn[][] = [];
  for (let i = 0; i < btns.length; i += perRow) out.push(btns.slice(i, i + perRow));
  return out;
};

const send = (chat: number, text: string, keyboard?: Btn[][],
              extra?: Record<string, unknown>) =>
  tg("sendMessage", {
    chat_id: chat, text, parse_mode: "HTML",
    disable_web_page_preview: true,
    ...(keyboard ? { reply_markup: { inline_keyboard: keyboard } } : {}),
    ...(extra ?? {}),
  });

/* ---------------- اللوحة الثابتة ----------------
   أزرار بتضل تحت الشاشة — الطالب ما بده يكتب /start ولا /sprache.
   بترسل نصّ عادي، والنصّ نفسه بيقول شو الفعل **وشو اللغة** سوا:
   «🌐 اللغة» عربي و«🌐 Sprache» ألماني. فما منحتاج نحفظ لغة حدا بين
   الرسايل — نفس مبدأ callback_data يلي حامل حاله. */
const MKEYS = ["mTrial", "mFull", "mMine", "mLang", "mShare"] as const;
const menu = (lang: Lang) => ({
  reply_markup: {
    keyboard: [
      [{ text: t(lang, "mTrial") }, { text: t(lang, "mFull") }],
      [{ text: t(lang, "mMine") }],
      [{ text: t(lang, "mLang") }, { text: t(lang, "mShare") }],
    ],
    is_persistent: true, resize_keyboard: true,
  },
});

const LABEL: Record<string, { act: string; lang: Lang }> = {};
for (const l of Object.keys(T) as Lang[])
  for (const k of MKEYS) LABEL[T[l][k]] = { act: k, lang: l };

/* قائمة الأوامر بزرّ ☰ — مرّة وحدة بكل تشغيل بارد */
let cmdsDone = false;
async function ensureCommands() {
  if (cmdsDone) return;
  cmdsDone = true;
  const D: Record<Lang, [string, string][]> = {
    ar: [["start", "من الأول"], ["sprache", "غيّر اللغة"]],
    de: [["start", "Von vorn"], ["sprache", "Sprache ändern"]],
    uk: [["start", "Спочатку"], ["sprache", "Змінити мову"]],
    en: [["start", "Start over"], ["sprache", "Change language"]],
  };
  for (const [lang, list] of Object.entries(D)) {
    await tg("setMyCommands", {
      commands: list.map(([command, description]) => ({ command, description }),),
      ...(lang === "de" ? {} : { language_code: lang }),
    }).catch(() => {});
  }
}

/* ---------------- القاعدة ---------------- */
async function rpc(fn: string, args: Record<string, unknown> = {}) {
  const r = await fetch(`${SUPA}/rest/v1/rpc/${fn}`, {
    method: "POST",
    headers: {
      "content-type": "application/json",
      apikey: SVC,
      authorization: `Bearer ${SVC}`,
    },
    body: JSON.stringify(args),
  });
  const body = await r.json().catch(() => null);
  if (!r.ok) throw new Error(body?.message || `rpc ${fn} ${r.status}`);
  return body;
}

type Level = { id: string; provider: string | null; stufe: string | null; title: string };

/* الاسم يلي بينعرض: «telc · B1». مستوى قديم بلا مؤسسة بيضل بعنوانه. */
const levelName = (l: Level) =>
  l.provider && l.stufe ? `${l.provider} · ${l.stufe}` : l.title;

/* ---------------- الخطوات ---------------- */
async function stepLang(chat: number, lang: Lang) {
  await send(chat, t(lang, "hello"),
    rows(LANGS.map(l => ({ text: l.label, callback_data: `g|${l.id}` }))));
}

async function stepProvider(chat: number, lang: Lang, levels: Level[]) {
  if (!levels.length) return void await send(chat, t(lang, "none"));
  const provs = [...new Set(levels.map(l => l.provider || "—"))];

  // مؤسسة وحدة بس: ما في معنى نسأل — منقفز للدرجات
  if (provs.length === 1) return stepStufe(chat, lang, levels, provs[0]);

  await send(chat, t(lang, "pickProvider"),
    rows(provs.map(p => ({ text: p, callback_data: `p|${lang}|${p}` }))));
}

async function stepStufe(chat: number, lang: Lang, levels: Level[], prov: string) {
  const mine = levels.filter(l => (l.provider || "—") === prov);
  if (!mine.length) return void await send(chat, t(lang, "none"));
  await send(chat, t(lang, "pickStufe"), [
    ...rows(mine.map(l => ({
      text: l.stufe || l.title, callback_data: `l|${lang}|${l.id}` })), 3),
    [{ text: t(lang, "back"), callback_data: `b|${lang}` }],
  ]);
}

async function stepCode(chat: number, lang: Lang, from: any, levelId: string) {
  const res = await rpc("bot_demo_code", {
    p_telegram_id: from.id,
    p_chat_id: chat,
    p_username: from.username ?? null,
    p_lang: lang,
    p_level_id: levelId,
  });

  const head = res.again ? t(lang, "again") : t(lang, "got");
  const spent = Number(res.used) >= Number(res.max_uses);
  const lines = [
    `<b>${head}</b>`,
    "",
    t(lang, "codeIs"),
    codeBlock(res.code),
    `${t(lang, "linkIs")} ${APP_URL}`,
    "",
    t(lang, "what", { test: res.test ?? "", h: res.hours }),
  ];
  if (spent) lines.push("", t(lang, "used"));
  // زرّ النسخ مدمج، فالرسالة ما بتحمل اللوحة الثابتة معه
  await send(chat, lines.join("\n"), [[copyBtn(lang, res.code)]]);
  // والخطوة التالية هي يلي بتحمل اللوحة — رسالة قصيرة إلها معنى،
  // مو «👇» فاضية
  if (!spent) await send(chat, t(lang, "how"), undefined, menu(lang));

  // ★ صار عنده تجريبي لهالمستوى — والباب مفتوح لغيره. بلا هالزرّ
  //   الطالب ما بيعرف إنّه بيقدر يجرّب مستوى تاني أصلاً.
  const other: Level[] = await rpc("bot_untried_levels", { p_telegram_id: from.id })
    .catch(() => []);
  if (other.length) await send(chat, t(lang, "tryOther"),
    rows(other.map((l) => ({
      text: levelName(l), callback_data: `l|${lang}|${l.id}` })), 2));

  // ★ خبر إلك بس أوّل مرّة. الرجعات ما بتنبّهك — وإلا كل من فتح
  //   الرسالة القديمة بيرنّ عندك.
  if (!res.again) await toAdmin(
    `🆕 <b>تجريبي جديد</b>\n` +
    `${who(from)}\n${levelLine(res)} · ${res.test ?? ""}`);
}

/* رابط مشاركة البوت. اسم البوت بيجي من getMe مرّة وحدة بكل تشغيل
   بارد — أحسن من سرّ زيادة بتنسى تحدّثه لو بدّلت البوت. */
let uname = "";
async function botUsername() {
  if (uname) return uname;
  try {
    const r = await (await fetch(TG("getMe"))).json();
    uname = r?.result?.username ?? "";
  } catch { /* بيرجع فاضي، والزرّ بينشال تحت */ }
  return uname;
}
/* ★ زرّ t.me/share بيفتح تلغرام وبس. الطالب بدّه يبعت لرفقاته على
   واتساب وإنستغرام كمان — فمنعطيه تلاتة بنفس الرسالة: زرّ تلغرام،
   زرّ واتساب، والرابط بـ<code> يلي ضغطة عليه بتنسخه لأي مطرح. */
async function shareMsg(chat: number, lang: Lang) {
  const u = await botUsername();
  // ★ بلا اسم البوت الرابط بيطلع «https://t.me/» — مكسور. أحسن نبعت
  //   النصّ لحاله من نبعت رابط ما بيفتح. وbotUsername ما بتخزّن الفشل،
  //   فالرسالة الجاي بتجرّب من جديد.
  if (!u) return void await send(chat, t(lang, "shareText"));
  const link = `https://t.me/${u}`;
  const text = t(lang, "shareText");
  const enc = encodeURIComponent(`${text}\n${link}`);

  await send(chat,
    `${text}\n\n${t(lang, "copyHint")}\n<code>${link}</code>`,
    [[{ text: t(lang, "tgShare"),
        url: `https://t.me/share/url?url=${encodeURIComponent(link)}`
           + `&text=${encodeURIComponent(text)}` },
      { text: t(lang, "waShare"), url: `https://wa.me/?text=${enc}` }]]);
}

const who = (from: any) =>
  `${from.first_name ?? ""} ${from.username ? "@" + from.username : ""}`.trim()
  + ` · <code>${from.id}</code>`;
const levelLine = (r: any) =>
  r.provider && r.stufe ? `${r.provider} · ${r.stufe}` : (r.level_id ?? "");

/* قناتك الخاصة. بلا ADMIN_CHAT_ID الوظيفة بتضل تشتغل بلا إشعارات
   بدل ما تطيح — الطالب ما إله ذنب إنّك ما ظبّطت السرّ. */
async function toAdmin(text: string, keyboard?: Btn[][]) {
  if (!ADMIN) return null;
  try {
    return await (await send(Number(ADMIN), text, keyboard)).json();
  } catch (e) { console.error("toAdmin:", String(e)); return null; }
}

/* ---------------- كودي ----------------
   الطالب بيضيّع الرسالة وبيسأل. زرّ بيرجّعله كل أكواده وكم باقي لكل
   واحد — أرخص من رسالة إلك. */
const leftText = (lang: Lang, ends: string | null) => {
  if (!ends) return t(lang, "notUsed");
  const ms = new Date(ends).getTime() - Date.now();
  if (ms <= 0) return t(lang, "endedX");
  const h = Math.floor(ms / 3600000);
  return h >= 1 ? t(lang, "leftH", { h }) : t(lang, "leftM", { m: Math.ceil(ms / 60000) });
};

const lvlOf = (c: any) =>
  c.provider && c.stufe ? `${c.provider} · ${c.stufe}` : (c.level_id ?? "");

async function stepMine(chat: number, lang: Lang, from: any) {
  const list: any[] = await rpc("bot_my_codes", { p_telegram_id: from.id });
  if (!list.length) return void await send(chat, t(lang, "noCodes"), undefined, menu(lang));

  const lines = [`<b>${t(lang, "myTitle")}</b>`, ""];
  for (const c of list) {
    lines.push(`<code>${c.code}</code> — ${lvlOf(c)}`);
    lines.push(`   ${t(lang, c.kind === "full" ? "kFull" : "kDemo")}`
             + `${c.test ? " · " + c.test : ""} · ${leftText(lang, c.ends)}`);
  }
  lines.push("", `${t(lang, "linkIs")} ${APP_URL}`);
  await send(chat, lines.join("\n"), undefined, menu(lang));
}

/* «جرّب مستوى تاني» — صار ممكن بعد 0028، والطالب ما بيعرف */
async function stepOther(chat: number, lang: Lang, from: any) {
  const levels: Level[] = await rpc("bot_untried_levels", { p_telegram_id: from.id });
  if (!levels.length) return void await send(chat, t(lang, "allTried"), undefined, menu(lang));
  await send(chat, t(lang, "pickStufe"),
    rows(levels.map((l) => ({
      text: levelName(l), callback_data: `l|${lang}|${l.id}` })), 2));
}

/* ---------------- الوصول الكامل ---------------- */
async function stepMonths(chat: number, lang: Lang) {
  await send(chat, t(lang, "pickMonths"), [
    [1, 2, 3].map((n) => ({
      text: t(lang, "mon", { n }), callback_data: `m|${lang}|${n}` })),
    [{ text: t(lang, "back"), callback_data: `b|${lang}` }],
  ]);
}

async function stepRequest(chat: number, lang: Lang, from: any, months: number) {
  let res: any;
  try {
    res = await rpc("bot_request_access",
      // ★ آخر لغة اختارها هي لغته — بلاها بياخد الردّ بلغة تجريبيّه القديم
      { p_telegram_id: from.id, p_months: months, p_lang: lang });
  } catch (e) {
    // ما أخد تجريبي بعد: منقلّه بلغته بدل رسالة خطأ عامّة
    if (String(e).includes("no_demo_yet"))
      return void await send(chat, t(lang, "needDemo"), undefined, menu(lang));
    throw e;
  }

  await send(chat, t(lang, res.again ? "pending" : "sent"), undefined, menu(lang));
  if (res.again) return;          // ما منزعجك مرّتين بنفس الطلب

  // ★ الحجز أوّلاً: بمجموعة فيها أكتر من شخص، تنين بيفتحوا نفس الطلب
  //   وتنين بيردّوا. مين بياخده بيصير إله وحده ربع ساعة.
  const card = await toAdmin(
    `🔓 <b>طلب وصول كامل</b>\n` +
    `${who(from)}\n` +
    `${levelLine(res)} · <b>${res.months}</b> شهر`,
    [[{ text: "🖐 احجزه", callback_data: `V|${res.request_id}` }]]);

  // وين البطاقة: منحتاجها للتنبيه بعد ما ينتهي الحجز
  const mid = card?.result?.message_id;
  if (mid) await rpc("bot_set_card",
    { p_request_id: res.request_id, p_chat: Number(ADMIN), p_msg: mid })
    .catch((e: unknown) => console.error("set_card:", String(e)));
}

/* ---------------- قرارك ---------------- */
const RESERVE_MIN = 15;

/* الحجز المنتهي: منبّه مرّة وحدة ومنرجّع الطلب حرّ.
   ★ بينندى من مطرحين — أي تحديث بيوصل للبوت، وpg_cron لو ظبّطتها.
     القاعدة هي يلي بتضمن إنّه ما ينبعت مرّتين (nudged_at بنفس
     الاستعلام)، فنداء زيادة ما بيضرّ. */
async function sweep() {
  let due: any[] = [];
  try { due = await rpc("bot_sweep_reservations"); }
  catch (e) { return void console.error("sweep:", String(e)); }

  for (const r of due) {
    const txt = `⏰ انتهى وقت الحجز و${r.reserved_name} ما قرّر.\n`
              + `الطلب صار حرّ — أي حدا فيه ياخده.`;
    await tg("sendMessage", {
      chat_id: r.card_chat ?? Number(ADMIN), text: txt,
      ...(r.card_msg ? { reply_to_message_id: r.card_msg } : {}),
    }).catch((e) => console.error("nudge:", String(e)));
    // البطاقة بترجع لزرّ الحجز: الحجز راح فالأزرار لازم ترجع للبداية
    if (r.card_chat && r.card_msg) await tg("editMessageReplyMarkup", {
      chat_id: r.card_chat, message_id: r.card_msg,
      reply_markup: { inline_keyboard: [[
        { text: "🖐 احجزه", callback_data: `V|${r.id}` }]] },
    }).catch(() => {});
  }

  await sweepExpiring();
}

/* ★ «باقي أقلّ من ساعة». أقوى لحظة بيع بالرحلة كلها: الطالب لسا
   بالنصّ، وعارف شو عم ياخد، وبيحسّ بالوقت عم يخلص.
   بينبعت مرّة وحدة لكل كود (warned_at بالقاعدة)، ولمين فعّل كوده بس —
   تنبيه «باقي ساعة» لواحد ما فتح التطبيق بيربكه مو بيساعده. */
async function sweepExpiring() {
  let due: any[] = [];
  try { due = await rpc("bot_sweep_expiring"); }
  catch (e) { return void console.error("expiring:", String(e)); }

  for (const d of due) {
    const lang = (T[d.lang as Lang] ? d.lang : "de") as Lang;
    const lvl = d.provider && d.stufe ? `${d.provider} · ${d.stufe}` : "";
    await send(Number(d.chat_id),
      `<b>${t(lang, "warnTitle", { lvl })}</b>\n\n${t(lang, "warnBody")}`,
      [[{ text: t(lang, "full"), callback_data: `f|${lang}` }]],
    ).catch((e) => console.error("warn:", String(e)));
  }
}

const REASONS = ["soon", "demo", "contact", "no"];
/* وسم بيربط ردّك بالطلب. بتنكتب بنصّ رسالة الطلب منك، وردّك بيرجّعها
   جوّا reply_to_message — فما منحتاج نخزّن «مين عم يكتب لأي طلب». */
const TAG = (id: string, msg: number) => `#${id}:${msg}`;
const TAG_RE = /#([0-9a-f-]{36}):(\d+)/i;
const REASON_LABEL: Record<string, string> = {
  soon: "مو هلق", demo: "جرّب التجريبي", contact: "احكي معنا", no: "مرفوض",
};

/* ★ رسالة الطلب وحدة، وأزرارها بتتبدّل جوّاها.
   بمجموعة فيها أكتر من شخص، لو تركنا الأزرار بعد القرار، التاني
   بيضغط ويلاقي «سبق وانبتّ فيه» — أو أسوأ، بيفتكر إنّه هو يلي قرّر.
   منشيل الأزرار ومنكتب مين قرّر بنفس الرسالة، فالمجموعة بتشوف الحالة
   النهائية وبس. */
async function seal(cb: any, verdict: string) {
  await tg("editMessageText", {
    chat_id: cb.message?.chat?.id,
    message_id: cb.message?.message_id,
    text: `${cb.message?.text ?? ""}\n\n${verdict}`,
    // بلا reply_markup = الأزرار بتنشال
  });
}

const nameOf = (from: any) =>
  from?.username ? "@" + from.username : (from?.first_name ?? String(from?.id ?? ""));

/* رفض بسبب مكتوب. منختم بطاقة الطلب الأصلية بـmsgId يلي حملناه بالوسم. */
async function rejectFree(chat: number, from: any, id: string,
                          msgId: number, why: string) {
  let res: any;
  try {
    res = await rpc("bot_decide_request", {
      p_admin_telegram_id: from.id, p_request_id: id,
      p_approve: false, p_reason: why, p_chat_id: chat });
  } catch (e) {
    if (String(e).includes("not_bot_admin"))
      return void await send(chat, "⛔ ما عندك صلاحية.");
    throw e;
  }
  if (!res.ok) return void await send(chat, `سبق وانبتّ فيه: ${res.already}`);

  const lang = (T[res.lang as Lang] ? res.lang : "de") as Lang;
  await send(Number(res.chat_id), `${t(lang, "noFull")}\n\n${why}`);
  await tg("editMessageText", {
    chat_id: chat, message_id: msgId,
    text: `✖️ رفض ${nameOf(from)} · ${why}`,
  });
  await send(chat, "✖️ انبعت السبب للطالب.");
}

async function adminAction(cb: any, kind: string, id: string, reason: string) {
  const from = cb.from;
  const pop = (text: string, alert = true) =>
    tg("answerCallbackQuery", { callback_query_id: cb.id, text, show_alert: alert });

  // «ارفض» بيبدّل الأزرار بأسباب — بنفس الرسالة مو برسالة جديدة
  if (kind === "R") {
    await tg("answerCallbackQuery", { callback_query_id: cb.id });
    return void await tg("editMessageReplyMarkup", {
      chat_id: cb.message?.chat?.id, message_id: cb.message?.message_id,
      reply_markup: { inline_keyboard: [
        ...rows(REASONS.map((k) =>
          ({ text: REASON_LABEL[k], callback_data: `X|${id}|${k}` }))),
        [{ text: "✏️ سبب بخطّ إيدك",
           callback_data: `W|${id}|${cb.message?.message_id}` }],
      ] },
    });
  }

  // الحجز: بيقفل الطلب على الضاغط ربع ساعة، وبيطلّع أزرار القرار
  if (kind === "V") {
    const res = await rpc("bot_reserve_request", {
      p_admin_telegram_id: from.id, p_request_id: id,
      p_name: nameOf(from), p_minutes: RESERVE_MIN,
      p_chat_id: cb.message?.chat?.id ?? null });
    if (!res.ok) {
      if (res.taken)
        return void await pop(`🖐 محجوز لـ${res.by} — استنى لحتى ينتهي وقته.`);
      return void await pop(`سبق وانبتّ فيه: ${res.already}`);
    }
    await tg("answerCallbackQuery", { callback_query_id: cb.id });
    // ★ اسم الحاجز جوّا الأزرار نفسها. تلغرام ما بيلوّن الأزرار، وكلهم
    //   بيشوفوا نفس البطاقة — فالاسم على الزرّ هو الشي الوحيد يلي
    //   بيوقّف الضغطة الغلط قبل ما تصير.
    //   والمدّة بالدقايق مو بالساعة: البطاقة عليها وقتها من تلغرام،
    //   وساعة UTC بتربك مين ساعته غيرها.
    return void await tg("editMessageText", {
      chat_id: cb.message?.chat?.id, message_id: cb.message?.message_id,
      text: `${cb.message?.text ?? ""}\n\n`
          + `🔒 محجوز لـ${res.by} · ${res.minutes} دقيقة\n`
          + `غيره لا يضغط.`,
      reply_markup: { inline_keyboard: [[
        { text: `✅ وافق · ${res.by}`, callback_data: `A|${id}` },
        { text: `✖️ ارفض · ${res.by}`, callback_data: `R|${id}` }]] },
    });
  }

  // «سبب بخطّ إيدك»: منبعت طلب ردّ، وردّك بيحمل وسم الطلب معه
  if (kind === "W") {
    await tg("answerCallbackQuery", { callback_query_id: cb.id });
    return void await tg("sendMessage", {
      chat_id: cb.message?.chat?.id,
      text: `✏️ اكتب سبب الرفض — ردّ على هالرسالة.\n<code>${TAG(id, Number(reason))}</code>`,
      parse_mode: "HTML",
      reply_markup: { force_reply: true, selective: true },
    });
  }

  const approve = kind === "A";
  let res: any;
  try {
    res = await rpc("bot_decide_request", {
      p_admin_telegram_id: from.id, p_request_id: id,
      p_approve: approve, p_reason: approve ? null : reason,
      // ★ وين انضغط الزرّ: عضويّة المجموعة لحالها بتكفي صلاحية
      p_chat_id: cb.message?.chat?.id ?? null });
  } catch (e) {
    // ★ مين مو بـbot_admins بيوصل لهون بس القاعدة بترفضه.
    //   تنبيه إله لحاله — ما منوسّخ المجموعة برسالة بيشوفها الكل.
    if (String(e).includes("not_bot_admin"))
      return void await pop("⛔ ما عندك صلاحية.");
    throw e;
  }

  if (!res.ok) {
    if (res.taken)
      return void await pop(`🖐 محجوز لـ${res.by} — استنى لحتى ينتهي وقته.`);
    await pop(`سبق وانبتّ فيه: ${res.already}`);
    return void await seal(cb, `— انبتّ فيه سابقاً (${res.already})`);
  }

  const lang = (T[res.lang as Lang] ? res.lang : "de") as Lang;
  const stud = Number(res.chat_id);

  if (approve) {
    await send(stud, [
      `<b>${t(lang, "okFull")}</b>`, "",
      t(lang, "codeIs"), codeBlock(res.code),
      `${t(lang, "linkIs")} ${APP_URL}`, "",
      t(lang, "fullWhat", { lvl: "", m: res.months }),
      "", t(lang, "how"),
    ].join("\n"), [[copyBtn(lang, res.code)]]);
    await pop("✅ انبعت الكود", false);
    await seal(cb, `✅ وافق ${nameOf(from)} · الكود ${res.code}`);
  } else {
    const why = REASONS.includes(reason) ? t(lang, "rj_" + reason) : reason;
    await send(stud, `${t(lang, "noFull")}\n\n${why}`);
    await pop("✖️ انرفض", false);
    await seal(cb, `✖️ رفض ${nameOf(from)} · ${REASON_LABEL[reason] ?? reason}`);
  }
}

/* ---------------- المدخل ---------------- */
Deno.serve(async (req) => {
  if (req.method !== "POST") return new Response("ok");

  // ★ بلا هالفحص أي حدا بيعرف الرابط بيقدر يبعت تحديثات مزوّرة
  //   ويطلب أكواد باسم أي مستخدم. تلغرام بيبعت الترويسة مع كل تحديث.
  if (!SECRET || req.headers.get("x-telegram-bot-api-secret-token") !== SECRET)
    return new Response("forbidden", { status: 403 });

  let update: any;
  try { update = await req.json(); } catch { return new Response("ok"); }

  // pg_cron بتنده هون كل دقيقة لتكنس الحجوزات المنتهية
  if (update?.cron === "sweep") { await sweep(); return new Response("ok"); }

  // وبلا cron كمان: أي تحديث بيوصل بيكنس. استعلام واحد على فهرس
  // جزئي — أرخص من إنّ طلب يضل محجوز لأنّ ما حدا حرّك البوت.
  sweep().catch(() => {});

  const cb  = update.callback_query;
  const msg = cb?.message ?? update.message;
  const from = cb?.from ?? update.message?.from;
  const chat = msg?.chat?.id;
  if (!chat || !from) return new Response("ok");

  // لغة الجهاز أول اقتراح؛ اختياره بيغلب وبينحمل بكل زرّ بعدها
  const guess = String(from.language_code ?? "").slice(0, 2) as Lang;
  const fallback: Lang = T[guess] ? guess : "de";

  try {
    if (cb) {
      // اسم المؤسسة نصّ حرّ، وممكن يجي فيه «|» — فآخر جزء بينلمّ سوا
      const [kind, a, ...rest] = String(cb.data ?? "").split("|");
      const b = rest.join("|");

      // أزرارك إنت: بتردّ على الضغطة لحالها (التنبيه لازم يطلع للضاغط
      // وحده)، فما منمرقها عالردّ العام تحت
      if (["A", "R", "X", "W", "V"].includes(kind)) {
        await adminAction(cb, kind, a, b);
        return new Response("ok");
      }

      await tg("answerCallbackQuery", { callback_query_id: cb.id });
      const lang = (T[a as Lang] ? a : fallback) as Lang;

      if (kind === "g" || kind === "b") {
        const L = (T[a as Lang] ? a : lang) as Lang;
        // ★ الشرح بعد اختيار اللغة بس — مو مع «رجوع».
        //   الطالب لازم يعرف شو رح ياخد قبل ما يختار، وبلغته.
        if (kind === "g") await send(chat, t(L, "intro"));
        await stepProvider(chat, L, await rpc("bot_levels"));
      }
      else if (kind === "p") await stepStufe(chat, lang, await rpc("bot_levels"), b);
      else if (kind === "l") await stepCode(chat, lang, from, b);
      else if (kind === "f") await stepMonths(chat, lang);
      else if (kind === "m") await stepRequest(chat, lang, from, Number(b));
      return new Response("ok");
    }

    const text = String(update.message?.text ?? "").trim();
    // /id كان هون لجلب رقمك ورقم المجموعة وقت التركيب. انشال بعد ما
    // خلص شغله: أمر بيكشف أرقام ما إله داعي يضل مفتوح للطلاب.
    //
    // لو احتجته مرّة تانية (مجموعة جديدة مثلاً): ابعت رسالة بالمجموعة
    // وافتح https://api.telegram.org/bot<التوكن>/getUpdates
    //   ودوّر على "chat":{"id":  — رقم المجموعة سالب.

    // ردّ على «اكتب سبب الرفض»: الوسم بالرسالة الأصلية بيقول لأي طلب
    const tag = TAG_RE.exec(String(update.message?.reply_to_message?.text ?? ""));
    if (tag && text) {
      await rejectFree(chat, from, tag[1], Number(tag[2]), text);
      return new Response("ok");
    }

    // ★ زرّ من اللوحة الثابتة: نصّه بيقول الفعل واللغة سوا
    const hit = LABEL[text];
    if (hit) {
      const L = hit.lang;
      if (hit.act === "mTrial")
        await stepProvider(chat, L, await rpc("bot_levels"));
      else if (hit.act === "mFull")  await stepMonths(chat, L);
      else if (hit.act === "mMine")  await stepMine(chat, L, from);
      else if (hit.act === "mLang")  await stepLang(chat, L);
      // اللوحة الثابتة ما بتحمل روابط — فالمشاركة برسالتها هي
      else if (hit.act === "mShare") await shareMsg(chat, L);
      return new Response("ok");
    }

    await ensureCommands();
    await stepLang(chat, fallback);        // /start أو أي شي تاني
  } catch (e) {
    console.error("telegram:", String(e));
    await send(chat, t(fallback, "err")).catch(() => {});
  }
  return new Response("ok");
});
