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
 *   SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY  (بتنحط لحالها)
 *
 * النشر:  supabase functions deploy telegram --no-verify-jwt
 *   (--no-verify-jwt لأن تلغرام ما بيبعت JWT؛ الحماية بالترويسة السرّية)
 */

const TOKEN   = Deno.env.get("TELEGRAM_BOT_TOKEN") ?? "";
const SECRET  = Deno.env.get("TELEGRAM_WEBHOOK_SECRET") ?? "";
const APP_URL = Deno.env.get("APP_URL") ?? "";
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
  },
};

const t = (lang: Lang, key: string, vars?: Record<string, string | number>) =>
  (T[lang]?.[key] ?? T.de[key] ?? key).replace(
    /\{(\w+)\}/g, (_, k) => String(vars?.[k] ?? ""));

/* ---------------- تلغرام ---------------- */
type Btn = { text: string; callback_data: string };

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

const send = (chat: number, text: string, keyboard?: Btn[][]) =>
  tg("sendMessage", {
    chat_id: chat, text, parse_mode: "HTML",
    disable_web_page_preview: true,
    ...(keyboard ? { reply_markup: { inline_keyboard: keyboard } } : {}),
  });

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
  await send(chat, lines.join("\n"));
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
      await tg("answerCallbackQuery", { callback_query_id: cb.id });
      // اسم المؤسسة نصّ حرّ، وممكن يجي فيه «|» — فآخر جزء بينلمّ سوا
      const [kind, a, ...rest] = String(cb.data ?? "").split("|");
      const b = rest.join("|");
      const lang = (T[a as Lang] ? a : fallback) as Lang;

      if (kind === "g" || kind === "b")
        await stepProvider(chat, (T[a as Lang] ? a : lang) as Lang,
                           await rpc("bot_levels"));
      else if (kind === "p") await stepStufe(chat, lang, await rpc("bot_levels"), b);
      else if (kind === "l") await stepCode(chat, lang, from, b);
      return new Response("ok");
    }

    const text = String(update.message?.text ?? "");
    if (/^\/(start|sprache|language|lang)\b/.test(text))
      await stepLang(chat, fallback);
    else
      await stepLang(chat, fallback);      // أي شي تاني: منرجّعه للبداية
  } catch (e) {
    console.error("telegram:", String(e));
    await send(chat, t(fallback, "err")).catch(() => {});
  }
  return new Response("ok");
});
