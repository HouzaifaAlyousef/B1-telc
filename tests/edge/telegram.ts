/* تشغيل حقيقي لدالة البوت بـDeno.
   تلغرام مزيّف (منسجّل شو انبعت) وSupabase مزيّف (بيترجم لـpsql على
   القاعدة المحلية) — بس **الدالة نفسها** هي كود الإنتاج بالحرف. */
const PORT_SUPA = 54331;
const PORT_TG   = 54332;

const psql = (q: string) => {
  const p = new Deno.Command("psql", {
    args: ["-h","/tmp","-p","5433","-U","postgres","-d","telc","-tAq","-v","ON_ERROR_STOP=1","-c", q],
    stdout: "piped", stderr: "piped",
  }).outputSync();
  const out = new TextDecoder().decode(p.stdout).trim();
  if (p.code !== 0) throw new Error(new TextDecoder().decode(p.stderr));
  return out.split("\n").map(l => l.trim()).filter(Boolean).pop() ?? "";
};

const lit = (v: unknown): string =>
  v === null || v === undefined ? "null"
  : typeof v === "number" || typeof v === "boolean" ? String(v)
  : `'${String(v).replaceAll("'", "''")}'`;

/* ---- Supabase مزيّف: service_role بس، متل الإنتاج ---- */
const supa = Deno.serve({ port: PORT_SUPA, onListen() {} }, async (req) => {
  const fn = new URL(req.url).pathname.split("/").pop()!;
  const args = await req.json();
  const named = Object.entries(args).map(([k, v]) => `${k} => ${lit(v)}`).join(", ");
  try {
    return new Response(
      psql(`select coalesce(to_jsonb(${fn}(${named})),'null'::jsonb);`),
      { headers: { "content-type": "application/json" } });
  } catch (e) {
    const m = String(e).split("\n").find(l => l.includes("ERROR")) ?? String(e);
    return new Response(JSON.stringify({ message: m.slice(0, 200) }), { status: 400 });
  }
});

/* ---- تلغرام مزيّف ---- */
type Sent = { method: string; body: any };
const sent: Sent[] = [];
// ★ بيرجّع message_id متل تلغرام الحقيقي: الدالة بتحفظه لتعرف وين
//   البطاقة، وبلاه التنبيه ما بيلاقي شو يعدّل
let mid = 1000;
const tgSrv = Deno.serve({ port: PORT_TG, onListen() {} }, async (req) => {
  const method = new URL(req.url).pathname.split("/").pop()!;
  const body = await req.json().catch(() => ({}));
  sent.push({ method, body });
  const result = method === "sendMessage"
    ? { message_id: ++mid, chat: { id: body?.chat_id } } : {};
  return new Response(JSON.stringify({ ok: true, result }),
                      { headers: { "content-type": "application/json" } });
});

Deno.env.set("SUPABASE_URL", `http://127.0.0.1:${PORT_SUPA}`);
Deno.env.set("SUPABASE_SERVICE_ROLE_KEY", "SERVICE_KEY");
Deno.env.set("TELEGRAM_BOT_TOKEN", "T0KEN");
Deno.env.set("TELEGRAM_WEBHOOK_SECRET", "s3cret");
Deno.env.set("APP_URL", "https://b1-telc.example.dev");
Deno.env.set("ADMIN_CHAT_ID", "-1004242");   // مجموعة، مو شخص

/* نداءات api.telegram.org بتتحوّل للسيرفر المزيّف */
const realFetch = globalThis.fetch;
globalThis.fetch = ((u: any, o?: any) => {
  const s = String(u);
  if (s.startsWith("https://api.telegram.org/"))
    return realFetch(s.replace("https://api.telegram.org", `http://127.0.0.1:${PORT_TG}`), o);
  return realFetch(u, o);
}) as any;

const R: [string, boolean][] = [];
const check = (l: string, c: unknown) => { R.push([l, !!c]); console.log(`  ${c ? "✓" : "✗"} ${l}`); };

let handler!: (r: Request) => Promise<Response> | Response;
const realServe = Deno.serve;
// @ts-ignore: منلقط المعالج بدل ما نشغّل سيرفر
Deno.serve = ((h: any) => { handler = h; return { finished: Promise.resolve(), shutdown(){}, addr:{} } as any; }) as any;
await import("../../supabase/functions/telegram/index.ts");
Deno.serve = realServe;

console.log("\n=== Edge Function: بوت تلغرام ===");

/* حالة معروفة: b1 لحاله.
   ★ عدد المؤسسات بيغيّر أول خطوة بالبوت (مؤسسة وحدة = قفزة للدرجات)،
   والمراحل يلي قبلنا بتخلّف مستويات — اختبارات SQL، وimport.mjs.
   فمنبلّش من حالة منعرفها، متل ما بيعمل admin.mjs بعدنا بالضبط. */
psql(`delete from telegram_users;
      delete from writing_feedback; delete from mistakes;
      delete from attempts; delete from imports; delete from resources;
      delete from tests  where level_id <> 'b1';
      delete from levels where id       <> 'b1';
      delete from code_redemptions; delete from devices;
      delete from subscriptions; delete from access_codes;`);

const post = (update: unknown, secret: string | null = "s3cret") =>
  handler(new Request("http://x/telegram", {
    method: "POST",
    headers: {
      "content-type": "application/json",
      ...(secret ? { "x-telegram-bot-api-secret-token": secret } : {}),
    },
    body: JSON.stringify(update),
  }));

const last = (m = "sendMessage") => [...sent].reverse().find(s => s.method === m)?.body;
/* ★ صار في شاتين: الطالب وقناتك. «آخر رسالة» لحالها صارت ملتبسة —
   إشعارك بيوصل بعد رسالة الطالب فبيسرق last(). منسأل عن شات بعينه. */
const toChat = (id: number) =>
  [...sent].reverse().find(x => x.method === "sendMessage" && x.body?.chat_id === id)?.body;
const kb = () => last()?.reply_markup?.inline_keyboard ?? [];
const lastOf = (m: string) => [...sent].reverse().find(x => x.method === m)?.body;
/* اللوحة الثابتة: reply_markup.keyboard مو inline_keyboard */
const perm = (id: number) =>
  (toChat(id)?.reply_markup?.keyboard ?? []).flat().map((b: any) => b.text);
const flat = () => kb().flat();

const TG_ID = 987654321;
const msg = (text: string, lc = "ar") => ({
  message: { chat: { id: TG_ID }, from: { id: TG_ID, username: "kiko", language_code: lc }, text },
});
const click = (data: string, lc = "ar") => ({
  callback_query: { id: "cb1", data,
    from: { id: TG_ID, username: "kiko", language_code: lc },
    message: { chat: { id: TG_ID } } },
});

/* ---- ١) ★ بلا الترويسة السرّية ما في شي بيصير ---- */
sent.length = 0;
let r = await post(msg("/start"), null);
check("★ بلا الترويسة السرّية ← 403", r.status === 403);
check("★ وما انبعت ولا رسالة", sent.length === 0);
r = await post(msg("/start"), "wrong");
check("★ وبترويسة غلط كمان ← 403", r.status === 403);

/* ---- ٢) /start بيعرض اللغات ---- */
sent.length = 0;
await post(msg("/start"));
check(`اللغات الأربعة ظهرت (${flat().length})`, flat().length === 4);
check("★ وفيهن العربي والأوكراني والإنكليزي",
      ["g|ar","g|uk","g|en","g|de"].every(d => flat().some((b: any) => b.callback_data === d)));

/* ---- ٣) اختيار اللغة ← الدرجات ----
   مؤسسة وحدة معناها ما في شي تختار — السؤال وقتها ضغطة بلا معنى. */
sent.length = 0;
await post(click("g|ar"));
const stufen = flat().filter((b: any) => String(b.callback_data).startsWith("l|"));
check(`★ مؤسسة وحدة ← بيقفز للدرجات مباشرة (${stufen.length})`, stufen.length >= 1);
check("★ والنص بالعربي", /اختار المستوى/.test(String(last()?.text)));

/* ---- ٣ب) مؤسستين ← بيسأل عن المؤسسة أول ---- */
// اسم مؤسسة ما بيتصادم مع يلي بتخلّفه اختبارات SQL —
// (provider, stufe) عليها فهرس فريد
psql(`insert into levels (id,title,provider,stufe,published)
        values ('bot-x-b1','BotPruefung B1','BotPruefung','B1',true);
      insert into tests (level_id,slug,title,blocks,aufgaben,published,sort)
        values ('bot-x-b1','bot-x-01','X Modell 1','[]'::jsonb,0,true,1);`);
sent.length = 0;
await post(click("g|ar"));
const provs = flat().filter((b: any) => String(b.callback_data).startsWith("p|"));
check(`★ مؤسستين ← بيسأل عن المؤسسة أول (${provs.map((b:any)=>b.text).join(', ')})`,
      provs.length === 2);
sent.length = 0;
await post(click("p|ar|BotPruefung"));
check("★ واختيار المؤسسة بيعرض درجاتها هي بس",
      flat().some((b: any) => b.callback_data === "l|ar|bot-x-b1")
      && !flat().some((b: any) => b.callback_data === "l|ar|b1"));
check("★ ومعها زرّ رجوع", flat().some((b: any) => b.callback_data === "b|ar"));
psql(`delete from tests where level_id='bot-x-b1';
      delete from levels where id='bot-x-b1';`);

/* ---- ٤) اختيار الدرجة ← الكود ---- */
sent.length = 0;
await post(click("l|ar|b1"));
const out = String(toChat(TG_ID)?.text ?? "");
const code = (out.match(/<code>([A-Z0-9]+)<\/code>/) ?? [])[1];
check(`★ رجّع كود (${code})`, !!code && /^B1[0-9]{10}$/.test(code));
check("★ ومعه الرابط", out.includes("https://b1-telc.example.dev"));
check("★ والنص بالعربي مو بالألماني",
      /تفضّل|الرمز/.test(out) && !/Willkommen/.test(out));

const saved = psql(`select count(*) from access_codes where note = 'telegram:${TG_ID}';`);
check(`الكود انحفظ بالقاعدة (${saved})`, saved === "1");
const shape = psql(`select duration_days || '/' || duration_hours || '/' || max_uses
                    || '/' || array_length(test_slugs,1)
                    from access_codes where note='telegram:${TG_ID}';`);
check(`★ تجريبي فعلاً: ٠ يوم/٢٤ ساعة/تفعيل واحد/امتحان واحد (${shape})`,
      shape === "0/24/1/1");

/* ---- ٥) ★ نفس الحساب بيرجع ← نفس الكود ---- */
sent.length = 0;
await post(click("l|ar|b1"));
const again = String(toChat(TG_ID)?.text ?? "");
check("★ الطلب التاني بيقول إنه تكرار",
      /أخدت نسختك/.test(again) && again.includes(code!));
check(`★ وما انولّد كود تاني`,
      psql(`select count(*) from access_codes where note like 'telegram:%';`) === "1");

/* ---- ٦) اللغة بتتبع الزرّ، مو الجهاز ---- */
sent.length = 0;
await post(click("l|de|b1", "ar"));
check("★ زرّ ألماني ← رسالة ألمانية حتى لو جهازه عربي",
      /Testversion|derselbe Code/.test(String(toChat(TG_ID)?.text)));
sent.length = 0;
await post(click("l|uk|b1", "ar"));
check("★ وأوكراني كمان", /пробн/i.test(String(toChat(TG_ID)?.text)));

/* ---- ٧) مستوى مو موجود ← رسالة خطأ مو انهيار ----
   بحساب جديد: مين عنده كود بياخد كوده بلا ما يتفحص المستوى أصلاً. */
sent.length = 0;
r = await post({ callback_query: { id: "cb9", data: "l|ar|nope",
  from: { id: 55501, username: "neu", language_code: "ar" },
  message: { chat: { id: 55501 } } } });
check("مستوى مو موجود: بيرد ٢٠٠ ما بينهار", r.status === 200);
check(`★ وبيبعت رسالة خطأ مفهومة (${String(last()?.text).slice(0,24)})`,
      /خطأ/.test(String(last()?.text)));
check("★ وما انولّد ولا كود",
      psql(`select count(*) from access_codes where note='telegram:55501';`) === "0");

/* ---- ٨) أي نص تاني بيرجّعه للبداية ---- */
sent.length = 0;
await post(msg("مرحبا"));
check("نص عادي بيرجّعه لاختيار اللغة", flat().length === 4);

/* ---- ٩) تحديث ناقص ما بينهار ---- */
r = await post({ update_id: 1 });
check("تحديث بلا رسالة بيرد ٢٠٠", r.status === 200);
r = await post("not json" as any);
check("جسم مو JSON بيرد ٢٠٠", r.status === 200);

/* ---- ١٠) الوصول الكامل: الطلب ---- */
psql(`delete from access_requests; delete from bot_admins;`);
const GROUP = -1004242;           // مجموعة الموافقات
const BOSS  = 700001;             // إنت — عضو فيها
const MATE  = 700002;             // شريكك — عضو كمان، وما هو مسجّل لحاله
sent.length = 0;
await post(click("l|ar|b1"));     // كوده التجريبي (تكرار)
check(`★ مع الكود بتطلع لوحة ثابتة بأربع أزرار (${perm(TG_ID).length})`,
      perm(TG_ID).length === 4);
check("★ وهي بالعربي",
      perm(TG_ID).includes("🎁 نسختي التجريبية") && perm(TG_ID).includes("🔓 وصول كامل"));
check("★ وبتضل ظاهرة (is_persistent)",
      toChat(TG_ID)?.reply_markup?.is_persistent === true);

/* ★ ضغطة زرّ بتوصل كنصّ — والنصّ لحاله بيقول اللغة، بلا جدول جلسات */
sent.length = 0;
await post(msg("🌐 اللغة"));
check("★ زرّ «اللغة» بيعرض اللغات بلا ما يكتب /sprache", flat().length === 4);

sent.length = 0;
await post(msg("📣 Bot teilen", "ar"));
check("★ زرّ ألماني ← رسالة ألمانية حتى لو جهازه عربي",
      flat().some((b: any) => typeof b.url === "string" && b.url.includes("t.me/share"))
      && /kostenlos/.test(String(last()?.text)));

sent.length = 0;
await post(msg("🔓 وصول كامل"));
check("★ بيسأل لكم شهر",
      ["m|ar|1","m|ar|2","m|ar|3"].every(d => flat().some((b: any) => b.callback_data === d)));

sent.length = 0;
await post(click("m|ar|3"));
check("★ الطالب بيوصله «استنى»", /طلبك وصل/.test(String(toChat(TG_ID)?.text)));
const adminMsg = toChat(GROUP);
check("★★ والطلب بيوصل المجموعة",
      !!adminMsg && /طلب وصول كامل/.test(String(adminMsg.text)) && /3/.test(String(adminMsg.text)));
const cardKb = adminMsg?.reply_markup?.inline_keyboard?.flat() ?? [];
const reqId = String(cardKb[0]?.callback_data ?? "").split("|")[1] ?? "";
check(`★ وأوّل شي زرّ حجز لحاله (${cardKb.map((b:any)=>b.text).join()})`,
      cardKb.length === 1 && String(cardKb[0].callback_data).startsWith("V|"));
check(`★ ومعه رقم الطلب (${reqId.slice(0, 8)}…)`, /^[0-9a-f-]{36}$/.test(reqId));

/* ---- ١٠ب) ★ الحجز ---- */
const clickAs = (id: number, data: string, msgId = 22) => post({ callback_query: {
  id: "r" + msgId, data, from: { id, username: id === BOSS ? "boss" : "mate" },
  message: { chat: { id: GROUP }, message_id: msgId, text: "طلب" } } });

psql(`insert into bot_admins (telegram_id, label) values (${GROUP}, 'المجموعة')
      on conflict do nothing;`);
sent.length = 0;
await clickAs(BOSS, `V|${reqId}`);
check("★ الحجز بيكتب مين حجزه وكم دقيقة",
      /محجوز لـ@boss/.test(String(lastOf("editMessageText")?.text))
      && /15 دقيقة/.test(String(lastOf("editMessageText")?.text)));
const afterRes = lastOf("editMessageText")?.reply_markup?.inline_keyboard?.flat() ?? [];
check("★ وبعدها بس بتطلع أزرار القرار",
      afterRes.length === 2 && String(afterRes[0].callback_data).startsWith("A|"));
check("★★ واسم الحاجز مكتوب جوّا الأزرار — ما حدا يضغط غلط",
      afterRes.every((b: any) => String(b.text).includes("@boss")));

sent.length = 0;
await clickAs(MATE, `V|${reqId}`);
check("★★ التاني ما بيقدر يحجزه — تنبيه إله لحاله",
      /محجوز لـ@boss/.test(String(lastOf("answerCallbackQuery")?.text)));
sent.length = 0;
await clickAs(MATE, `A|${reqId}`);
check("★★ ولا بيقدر يوافق بدله",
      /محجوز لـ@boss/.test(String(lastOf("answerCallbackQuery")?.text)));
check("★★ وما انعمل كود",
      psql(`select count(*) from access_codes where note like 'telegram-full:%';`) === "0");

/* ---- ١٠ج) ★ انتهى الوقت ---- */
psql(`update access_requests set reserve_until = now() - interval '1 min'
       where id = '${reqId}';`);
sent.length = 0;
await post(msg("شي عادي"));          // أي تحديث بيكنس
await new Promise((r) => setTimeout(r, 250));
check("★★ بعد الانتهاء البوت بينبّه بالمجموعة",
      sent.some(x => x.method === "sendMessage" && x.body?.chat_id === GROUP
                && /انتهى وقت الحجز/.test(String(x.body?.text))));
check("★★ والبطاقة بترجع لزرّ الحجز",
      String(lastOf("editMessageReplyMarkup")?.reply_markup
             ?.inline_keyboard?.[0]?.[0]?.callback_data).startsWith("V|"));
sent.length = 0;
await post(msg("مرّة تانية"));
await new Promise((r) => setTimeout(r, 250));
check("★★ والتنبيه ما بينبعت مرّتين",
      !sent.some(x => /انتهى وقت الحجز/.test(String(x.body?.text))));

/* ---- ١١) ★★ الحدّ: حدا مو أدمن بيضغط «وافق» ---- */
sent.length = 0;
await post({ callback_query: { id: "cbX", data: `A|${reqId}`,
  from: { id: 777001, username: "liar", language_code: "ar" },
  message: { chat: { id: 777001 }, message_id: 11 } } });
check("★★ غريب ضغط «وافق» ← تنبيه إله لحاله مو رسالة بالمجموعة",
      /ما عندك صلاحية/.test(String(lastOf("answerCallbackQuery")?.text))
      && !sent.some(x => x.method === "sendMessage"));
check("★★ وما انعمل ولا كود كامل",
      psql(`select count(*) from access_codes where note like 'telegram-full:%';`) === "0");
check("★★ والطلب لسا معلّق",
      psql(`select status from access_requests where id='${reqId}';`) === "pending");

/* ---- ١٢) إنت بتوافق ---- */
// ★ منسجّل **المجموعة** مو الأشخاص — العضوية هي الصلاحية
psql(`insert into bot_admins (telegram_id, label) values (${GROUP}, 'المجموعة')
      on conflict (telegram_id) do nothing;`);
sent.length = 0;
await post({ callback_query: { id: "cbA", data: `A|${reqId}`,
  from: { id: BOSS, username: "boss", language_code: "de" },
  message: { chat: { id: GROUP }, message_id: 22, text: "طلب" } } });
const full = psql(`select code || '/' || duration_days || '/' ||
                     coalesce(array_length(test_slugs,1)::text,'كل')
                   from access_codes where note like 'telegram-full:%';`);
check(`★ انعمل كود كامل: ٩٠ يوم وكل الامتحانات (${full})`, /\/90\/كل$/.test(full));
check("★ والطالب وصله الكود",
      /تمّت الموافقة/.test(String(toChat(TG_ID)?.text)));
check("★★ ورسالة الطلب انختمت: مين وافق مكتوب",
      /وافق @boss/.test(String(lastOf("editMessageText")?.text)));
check("★★ وBOSS نفسه مو مسجّل — مرق بالعضوية بس",
      psql(`select count(*) from bot_admins where telegram_id = ${BOSS};`) === "0");
check("★★ وأزرارها راحت — ما حدا بيقدر يغيّر القرار",
      lastOf("editMessageText") !== undefined
      && lastOf("editMessageText").reply_markup === undefined);

/* ---- ١٣) ★ ضغطة تانية على نفس الطلب ---- */
sent.length = 0;
await post({ callback_query: { id: "cbA2", data: `A|${reqId}`,
  from: { id: BOSS, username: "boss", language_code: "de" },
  message: { chat: { id: GROUP }, message_id: 22, text: "طلب" } } });
check("★ الموافقة التانية بتقول «سبق وانبتّ فيه»",
      /سبق وانبتّ/.test(String(lastOf("answerCallbackQuery")?.text)));
check("★ وضلّ كود كامل واحد",
      psql(`select count(*) from access_codes where note like 'telegram-full:%';`) === "1");

/* ---- ١٤) الرفض بسبب مختار ---- */
psql(`delete from telegram_users where telegram_id = 55502;`);
await post({ callback_query: { id: "c1", data: "l|de|b1",
  from: { id: 55502, username: "zwei", language_code: "de" },
  message: { chat: { id: 55502 } } } });
await post({ callback_query: { id: "c2", data: "m|de|1",
  from: { id: 55502, username: "zwei", language_code: "de" },
  message: { chat: { id: 55502 } } } });
const req2 = psql(`select id from access_requests where telegram_id=55502 and status='pending';`);
sent.length = 0;
await post({ callback_query: { id: "c3", data: `R|${req2}`,
  from: { id: MATE }, message: { chat: { id: GROUP }, message_id: 33, text: "طلب" } } });
const rk = lastOf("editMessageReplyMarkup")?.reply_markup?.inline_keyboard?.flat() ?? [];
check(`★ «ارفض» بيبدّل الأزرار بأسباب بنفس الرسالة (${rk.length})`,
      rk.length === 5 && rk.filter((b: any) =>
        String(b.callback_data).startsWith("X|")).length === 4);
check("★ ومعهن زرّ سبب بخطّ إيدك",
      rk.some((b: any) => String(b.callback_data).startsWith("W|")));
sent.length = 0;
await post({ callback_query: { id: "c4", data: `X|${req2}|soon`,
  from: { id: MATE }, message: { chat: { id: GROUP }, message_id: 33, text: "طلب" } } });
check("★ الطالب وصله سبب الرفض بلغته هو (ألماني)",
      /nicht bewilligt/.test(String(toChat(55502)?.text))
      && /später/.test(String(toChat(55502)?.text)));
check("★★ وشريكك (عضو تاني، مو مسجّل) قدر يرفض كمان",
      psql(`select decided_by from access_requests where id='${req2}';`) === String(MATE));
check("★★ ورسالة الطلب انختمت بالرفض وبلا أزرار",
      /رفض/.test(String(lastOf("editMessageText")?.text))
      && lastOf("editMessageText").reply_markup === undefined);
check("★ والسبب انحفظ",
      psql(`select reason from access_requests where id='${req2}';`) === "soon");
check("★ ورفض ما بيعمل كود",
      psql(`select count(*) from access_codes where note like 'telegram-full:%';`) === "1");

/* ---- ١٤ب) ★ سبب رفض بخطّ إيدك ---- */
psql(`delete from telegram_users where telegram_id = 55503;`);
await post({ callback_query: { id: "d1", data: "l|de|b1",
  from: { id: 55503, username: "drei", language_code: "de" },
  message: { chat: { id: 55503 } } } });
await post({ callback_query: { id: "d2", data: "m|de|2",
  from: { id: 55503, username: "drei", language_code: "de" },
  message: { chat: { id: 55503 } } } });
const req3 = psql(`select id from access_requests where telegram_id=55503 and status='pending';`);

sent.length = 0;
await post({ callback_query: { id: "d3", data: `W|${req3}|77`,
  from: { id: MATE }, message: { chat: { id: GROUP }, message_id: 77, text: "طلب" } } });
const ask = last();
check("★ زرّ الكتابة بيطلب ردّ (force_reply)",
      ask?.reply_markup?.force_reply === true);
check(`★ والوسم فيه رقم الطلب ورقم الرسالة`,
      String(ask?.text).includes(req3) && /:77/.test(String(ask?.text)));

sent.length = 0;
await post({ message: { chat: { id: GROUP }, from: { id: MATE, username: "mate" },
  text: "Bitte zuerst die Testversion nutzen, danke!",
  reply_to_message: { text: String(ask?.text).replace(/<[^>]+>/g, "") } } });
check("★★ ردّك انبعت للطالب متل ما كتبته",
      /Bitte zuerst die Testversion/.test(String(toChat(55503)?.text)));
check("★★ وبلغته: العنوان ألماني مو عربي",
      /nicht bewilligt/.test(String(toChat(55503)?.text)));
check("★ وانحفظ كامل بالقاعدة",
      psql(`select reason from access_requests where id='${req3}';`)
        === "Bitte zuerst die Testversion nutzen, danke!");
check("★ وبطاقة الطلب انختمت بنفس النص",
      /Bitte zuerst/.test(String(lastOf("editMessageText")?.text))
      && lastOf("editMessageText").message_id === 77);

/* ---- ١٤ج) ★ اللغة بتتحدّث مع الطلب ---- */
psql(`delete from access_requests; delete from telegram_users where telegram_id = 55504;`);
await post({ callback_query: { id: "e1", data: "l|ar|b1",
  from: { id: 55504, username: "vier", language_code: "ar" },
  message: { chat: { id: 55504 } } } });
check("الطالب أخد التجريبي بالعربي",
      psql(`select lang from telegram_users where telegram_id=55504;`) === "ar");
await post({ callback_query: { id: "e2", data: "m|de|1",
  from: { id: 55504, username: "vier", language_code: "ar" },
  message: { chat: { id: 55504 } } } });
check("★★ وطلب الوصول بالألماني ← لغته المحفوظة صارت de",
      psql(`select lang from telegram_users where telegram_id=55504;`) === "de");

/* ---- ١٥) ★ /id انشال ---- */
sent.length = 0;
await post(msg("/id"));
check("★ /id ما عاد يكشف أرقام — بيرجّع لاختيار اللغة", flat().length === 4);
sent.length = 0;
await post({ message: { chat: { id: -1001234567890 },
  from: { id: TG_ID, username: "kiko" }, text: "/id" } });
check("★ ولا بالمجموعة كمان",
      !/-1001234567890<\/code>/.test(String(last()?.text ?? "")));

await supa.shutdown(); await tgSrv.shutdown();
const bad = R.filter(x => !x[1]);
console.log(bad.length ? `\n✗ ${bad.length} فشل من ${R.length}` : `\n✓ كل الـ${R.length} اختبارات نجحت`);
Deno.exit(bad.length ? 1 : 0);
