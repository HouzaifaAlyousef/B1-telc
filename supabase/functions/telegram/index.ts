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
  },
};

const t = (lang: Lang, key: string, vars?: Record<string, string | number>) =>
  (T[lang]?.[key] ?? T.de[key] ?? key).replace(
    /\{(\w+)\}/g, (_, k) => String(vars?.[k] ?? ""));

/* ---------------- تلغرام ---------------- */
type Btn = { text: string; callback_data?: string; url?: string };

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
const MKEYS = ["mTrial", "mFull", "mLang", "mShare"] as const;
const menu = (lang: Lang) => ({
  reply_markup: {
    keyboard: [
      [{ text: t(lang, "mTrial") }, { text: t(lang, "mFull") }],
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
    ar: [["start", "من الأول"], ["sprache", "غيّر اللغة"], ["id", "رقمي بتلغرام"]],
    de: [["start", "Von vorn"], ["sprache", "Sprache ändern"], ["id", "Meine Telegram-ID"]],
    uk: [["start", "Спочатку"], ["sprache", "Змінити мову"], ["id", "Мій Telegram ID"]],
    en: [["start", "Start over"], ["sprache", "Change language"], ["id", "My Telegram ID"]],
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
    `${t(lang, "codeIs")} <code>${res.code}</code>`,
    `${t(lang, "linkIs")} ${APP_URL}`,
    "",
    t(lang, "what", { test: res.test ?? "", h: res.hours }),
    "",
    spent ? t(lang, "used") : t(lang, "how"),
  ];
  await send(chat, lines.join("\n"), undefined, menu(lang));

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
async function shareLink(lang: Lang) {
  const u = await botUsername();
  return `https://t.me/share/url?url=${encodeURIComponent(`https://t.me/${u}`)}`
       + `&text=${encodeURIComponent(t(lang, "shareText"))}`;
}

const who = (from: any) =>
  `${from.first_name ?? ""} ${from.username ? "@" + from.username : ""}`.trim()
  + ` · <code>${from.id}</code>`;
const levelLine = (r: any) =>
  r.provider && r.stufe ? `${r.provider} · ${r.stufe}` : (r.level_id ?? "");

/* قناتك الخاصة. بلا ADMIN_CHAT_ID الوظيفة بتضل تشتغل بلا إشعارات
   بدل ما تطيح — الطالب ما إله ذنب إنّك ما ظبّطت السرّ. */
async function toAdmin(text: string, keyboard?: Btn[][]) {
  if (!ADMIN) return;
  await send(Number(ADMIN), text, keyboard).catch(
    (e) => console.error("toAdmin:", String(e)));
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
      { p_telegram_id: from.id, p_months: months });
  } catch (e) {
    // ما أخد تجريبي بعد: منقلّه بلغته بدل رسالة خطأ عامّة
    if (String(e).includes("no_demo_yet"))
      return void await send(chat, t(lang, "needDemo"), undefined, menu(lang));
    throw e;
  }

  await send(chat, t(lang, res.again ? "pending" : "sent"), undefined, menu(lang));
  if (res.again) return;          // ما منزعجك مرّتين بنفس الطلب

  await toAdmin(
    `🔓 <b>طلب وصول كامل</b>\n` +
    `${who(from)}\n` +
    `${levelLine(res)} · <b>${res.months}</b> شهر`,
    [[{ text: "✅ وافق", callback_data: `A|${res.request_id}` },
      { text: "✖️ ارفض", callback_data: `R|${res.request_id}` }]]);
}

/* ---------------- قرارك ---------------- */
const REASONS = ["soon", "demo", "contact", "no"];
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

async function adminAction(cb: any, kind: string, id: string, reason: string) {
  const from = cb.from;
  const pop = (text: string, alert = true) =>
    tg("answerCallbackQuery", { callback_query_id: cb.id, text, show_alert: alert });

  // «ارفض» بيبدّل الأزرار بأسباب — بنفس الرسالة مو برسالة جديدة
  if (kind === "R") {
    await tg("answerCallbackQuery", { callback_query_id: cb.id });
    return void await tg("editMessageReplyMarkup", {
      chat_id: cb.message?.chat?.id, message_id: cb.message?.message_id,
      reply_markup: { inline_keyboard: rows(
        REASONS.map((k) => ({ text: REASON_LABEL[k], callback_data: `X|${id}|${k}` }))) },
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
    await pop(`سبق وانبتّ فيه: ${res.already}`);
    return void await seal(cb, `— انبتّ فيه سابقاً (${res.already})`);
  }

  const lang = (T[res.lang as Lang] ? res.lang : "de") as Lang;
  const stud = Number(res.chat_id);

  if (approve) {
    await send(stud, [
      `<b>${t(lang, "okFull")}</b>`, "",
      `${t(lang, "codeIs")} <code>${res.code}</code>`,
      `${t(lang, "linkIs")} ${APP_URL}`, "",
      t(lang, "fullWhat", { lvl: "", m: res.months }),
      "", t(lang, "how"),
    ].join("\n"));
    await pop("✅ انبعت الكود", false);
    await seal(cb, `✅ وافق ${nameOf(from)} · الكود ${res.code}`);
  } else {
    await send(stud, `${t(lang, "noFull")}\n\n${t(lang, "rj_" + reason)}`);
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
      if (kind === "A" || kind === "R" || kind === "X") {
        await adminAction(cb, kind, a, b);
        return new Response("ok");
      }

      await tg("answerCallbackQuery", { callback_query_id: cb.id });
      const lang = (T[a as Lang] ? a : fallback) as Lang;

      if (kind === "g" || kind === "b")
        await stepProvider(chat, (T[a as Lang] ? a : lang) as Lang,
                           await rpc("bot_levels"));
      else if (kind === "p") await stepStufe(chat, lang, await rpc("bot_levels"), b);
      else if (kind === "l") await stepCode(chat, lang, from, b);
      else if (kind === "f") await stepMonths(chat, lang);
      else if (kind === "m") await stepRequest(chat, lang, from, Number(b));
      return new Response("ok");
    }

    const text = String(update.message?.text ?? "").trim();
    // الأرقام يلي بدّك ياها: رقمك لجدول bot_admins، ورقم المجموعة
    // لـADMIN_CHAT_ID. بمجموعة الاتنين بيطلعوا سوا — أوفر من رحلة
    // getUpdates وقراءة JSON بالإيد.
    if (/^\/id\b/.test(text)) {
      const mine = `🙋 رقمك: <code>${from.id}</code>`;
      const here = chat !== from.id
        ? `\n👥 رقم هالمجموعة: <code>${chat}</code>` : "";
      return void await send(chat, mine + here), new Response("ok");
    }

    // ★ زرّ من اللوحة الثابتة: نصّه بيقول الفعل واللغة سوا
    const hit = LABEL[text];
    if (hit) {
      const L = hit.lang;
      if (hit.act === "mTrial")
        await stepProvider(chat, L, await rpc("bot_levels"));
      else if (hit.act === "mFull")  await stepMonths(chat, L);
      else if (hit.act === "mLang")  await stepLang(chat, L);
      else if (hit.act === "mShare")
        // اللوحة الثابتة ما بتحمل روابط — فالمشاركة بزرّ مدمج برسالتها
        await send(chat, t(L, "shareText"),
                   [[{ text: t(L, "share"), url: await shareLink(L) }]]);
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
