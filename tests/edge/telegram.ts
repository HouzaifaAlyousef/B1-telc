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
const tgSrv = Deno.serve({ port: PORT_TG, onListen() {} }, async (req) => {
  const method = new URL(req.url).pathname.split("/").pop()!;
  sent.push({ method, body: await req.json().catch(() => ({})) });
  return new Response(JSON.stringify({ ok: true, result: {} }),
                      { headers: { "content-type": "application/json" } });
});

Deno.env.set("SUPABASE_URL", `http://127.0.0.1:${PORT_SUPA}`);
Deno.env.set("SUPABASE_SERVICE_ROLE_KEY", "SERVICE_KEY");
Deno.env.set("TELEGRAM_BOT_TOKEN", "T0KEN");
Deno.env.set("TELEGRAM_WEBHOOK_SECRET", "s3cret");
Deno.env.set("APP_URL", "https://b1-telc.example.dev");

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
const kb = () => last()?.reply_markup?.inline_keyboard ?? [];
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
const out = String(last()?.text ?? "");
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
const again = String(last()?.text ?? "");
check("★ الطلب التاني بيقول إنه تكرار",
      /أخدت نسختك/.test(again) && again.includes(code!));
check(`★ وما انولّد كود تاني`,
      psql(`select count(*) from access_codes where note like 'telegram:%';`) === "1");

/* ---- ٦) اللغة بتتبع الزرّ، مو الجهاز ---- */
sent.length = 0;
await post(click("l|de|b1", "ar"));
check("★ زرّ ألماني ← رسالة ألمانية حتى لو جهازه عربي",
      /Testversion|derselbe Code/.test(String(last()?.text)));
sent.length = 0;
await post(click("l|uk|b1", "ar"));
check("★ وأوكراني كمان", /пробн/i.test(String(last()?.text)));

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

await supa.shutdown(); await tgSrv.shutdown();
const bad = R.filter(x => !x[1]);
console.log(bad.length ? `\n✗ ${bad.length} فشل من ${R.length}` : `\n✓ كل الـ${R.length} اختبارات نجحت`);
Deno.exit(bad.length ? 1 : 0);
