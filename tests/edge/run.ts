/* تشغيل حقيقي للـEdge Function بـDeno.
   الـSupabase مزيّف (بيترجم النداءات لـpsql على القاعدة المحلية) وClaude
   مزيّف كمان — بس **الدالة نفسها** يلي بتنشتغل هي كود الإنتاج بالحرف. */
const PORT_SUPA = 54321;
const PORT_GEM = 54322;

const psql = async (q: string) => {
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
  : typeof v === "object" ? `'${JSON.stringify(v).replaceAll("'", "''")}'::jsonb`
  : typeof v === "number" || typeof v === "boolean" ? String(v)
  : `'${String(v).replaceAll("'", "''")}'`;

/* ---- Supabase مزيّف ---- */
const calls: string[] = [];
const supa = Deno.serve({ port: PORT_SUPA, onListen() {} }, async (req) => {
  const fn = new URL(req.url).pathname.split("/").pop()!;
  const args = await req.json();
  const bearer = (req.headers.get("authorization") ?? "").slice(7);
  const asService = bearer === "SERVICE_KEY";
  calls.push(`${fn}${asService ? " (service)" : " (user)"}`);
  const named = Object.entries(args).map(([k, v]) => `${k} => ${lit(v)}`).join(", ");
  try {
    const q = asService
      ? `select coalesce(to_jsonb(${fn}(${named})),'null'::jsonb);`
      : `set local role authenticated;
         select set_config('request.jwt.claim.sub','${bearer}',true);
         select coalesce(to_jsonb(${fn}(${named})),'null'::jsonb);`;
    return new Response(await psql(q), { headers: { "content-type": "application/json" } });
  } catch (e) {
    return new Response(JSON.stringify({ message: String(e).slice(0, 200) }), { status: 400 });
  }
});

/* ---- Gemini مزيّف: بيرجّع شكل الجواب المفروض بالسكيما ---- */
let geminiSaw: any = null;
let geminiPath = "";
const REPLY = {
  grades: [
    { criterion: "Aufgabenbewältigung",      key: "A", why: "Alle vier Leitpunkte bearbeitet." },
    { criterion: "Kommunikative Gestaltung", key: "B", why: "Anrede vorhanden, Gruß knapp." },
    { criterion: "Formale Richtigkeit",      key: "A", why: "Wenige Fehler." },
  ],
  errors: [{ type: "Grammatik", original: "Ich fliege", correction: "Ich fliege am liebsten",
             why: "Adverb fehlt." }],
  corrected: "Liebe Anna, …",
  summary: "Guter Brief, achte auf den Gruß.",
};
const gem = Deno.serve({ port: PORT_GEM, onListen() {} }, async (req) => {
  geminiPath = new URL(req.url).pathname + new URL(req.url).search;
  if (geminiPath.includes("/models?")) {            // قائمة النماذج
    return Response.json({ models: [
      { name: "models/gemini-flash-latest", supportedGenerationMethods: ["generateContent"] },
      { name: "models/gemini-embed", supportedGenerationMethods: ["embedContent"] }] });
  }
  geminiSaw = await req.json();
  return Response.json({
    candidates: [{ finishReason: "STOP",
      content: { role: "model", parts: [{ text: JSON.stringify(REPLY) }] } }],
    modelVersion: "gemini-flash-latest",
    usageMetadata: { promptTokenCount: 1200, candidatesTokenCount: 900 },
  });
});

/* ---- تشغيل الدالة ---- */
Deno.env.set("SUPABASE_URL", `http://127.0.0.1:${PORT_SUPA}`);
Deno.env.set("SUPABASE_ANON_KEY", "ANON_KEY");
Deno.env.set("SUPABASE_SERVICE_ROLE_KEY", "SERVICE_KEY");
Deno.env.set("GEMINI_API_KEY", "gk-test");
Deno.env.set("GEMINI_MODEL", "gemini-flash-latest");
Deno.env.set("GEMINI_BASE_URL", `http://127.0.0.1:${PORT_GEM}/v1beta`);

const R: [string, boolean][] = [];
const check = (l: string, c: unknown) => { R.push([l, !!c]); console.log(`  ${c ? "✓" : "✗"} ${l}`); };

/* الدالة بتنادي Deno.serve — منلقطه بدل ما نشغّل سيرفر */
let handler!: (r: Request) => Promise<Response> | Response;
const realServe = Deno.serve;
// @ts-ignore: نستبدل مؤقّتاً
Deno.serve = ((h: any) => { handler = h; return { finished: Promise.resolve(), shutdown(){}, addr:{} } as any; }) as any;
await import("../../supabase/functions/correct-writing/index.ts");
Deno.serve = realServe;

console.log("\n=== Edge Function: تصحيح التعبير الكتابي (Gemini) ===");

/* بيانات: مستخدم ومحاولة */
const U = "eeeeeeee-0000-0000-0000-000000000005";
const brief = "Liebe Anna, danke fuer deinen Brief. Ich moechte gern nach Deutschland kommen.";
await psql(`
  delete from writing_feedback;
  delete from attempts; delete from subscriptions; delete from devices;
  delete from profiles where id='${U}'; delete from auth.users where id='${U}';
  insert into auth.users (id) values ('${U}');
  insert into profiles (id) values ('${U}');
  insert into subscriptions (user_id, levels, current_period_end, writing_quota)
  values ('${U}', array['b1'], now() + interval '30 days', 5);
`);
const tid = await psql(`select id from tests where slug='modell-01';`);
const sid = await psql(`select s.id from sections s where s.test_id='${tid}' and s.format='writing';`);
const iid = await psql(`select id from items where section_id='${sid}' limit 1;`);
const aid = await psql(`insert into attempts (user_id,test_id,block_id,answers,submitted_at)
  values ('${U}','${tid}','block-sa', jsonb_build_object('${iid}', ${lit(brief)}), now()) returning id;`);

const call = (body: unknown, token = U) => handler(new Request("http://x/correct-writing", {
  method: "POST",
  headers: { authorization: `Bearer ${token}`, "content-type": "application/json" },
  body: JSON.stringify(body),
}));

/* ---- ١) بلا توكن ---- */
let r = await handler(new Request("http://x/", { method: "POST", body: "{}" }));
check("بلا جلسة ← 401", r.status === 401);

/* ---- ٢) طلب ناقص ---- */
r = await call({});
check("بلا attempt_id ← 400", r.status === 400);

/* ---- ٣) المسار الكامل ---- */
r = await call({ attempt_id: aid });
const body = await r.json();
check(`التصحيح نجح (${r.status})`, r.status === 200 && body.ok === true);
check(`النقاط ٣٩ من ٤٥ (طلع ${body.points}/${body.max_points})`,
      Number(body.points) === 39 && Number(body.max_points) === 45);
check("رجّع ٣ درجات وخطأ واحد",
      body.grades?.length === 3 && body.errors?.length === 1);

/* ---- ٤) شو انبعت للنموذج ---- */
check(`النموذج المطلوب بالمسار (${geminiPath.split("?")[0]})`,
      geminiPath.includes("models/gemini-flash-latest:generateContent"));
check("★ سكيما مفروضة، مو مرجوّة بالتعليمات",
      geminiSaw?.generationConfig?.responseMimeType === "application/json"
      && !!geminiSaw?.generationConfig?.responseSchema?.properties?.grades);
check("★ والدرجة محصورة بـA–D بالسكيما نفسها",
      JSON.stringify(geminiSaw?.generationConfig?.responseSchema)
        .includes('"enum":["A","B","C","D"]'));
check("تعليمات النظام انبعتت", 
      (geminiSaw?.systemInstruction?.parts?.[0]?.text ?? "").includes("telc Deutsch B1"));
const p = geminiSaw?.contents?.[0]?.parts?.[0]?.text ?? "";
check("نص الطالب انبعت", p.includes("Liebe Anna"));
check("المعايير الثلاثة انبعتوا",
      p.includes("Aufgabenbewältigung") && p.includes("Kommunikative Gestaltung")
      && p.includes("Formale Richtigkeit"));
check("سلّم الدرجات انبعت (A = 5)", p.includes("A = 5"));
check("الليتبونكته الأربعة انبعتوا", (p.match(/^\d\. /gm) ?? []).length === 4);
check("★ ما انبعت شي عن الحساب — النموذج بيعطي حروف بس",
      !p.includes("45 Punkte") && !/berechne|calculate/i.test(p));

/* ---- ٥) الفصل بالصلاحيات ---- */
check("★ writing_start بهويّة الطالب، writing_finish بـservice_role",
      calls.includes("writing_start (user)") && calls.includes("writing_finish (service)"));

/* ---- ٦) انحفظ فعلاً ---- */
const saved = await psql(`select status || '|' || points from writing_feedback
  where id = '${body.feedback_id}';`);
check(`انحفظ بقاعدة البيانات (${saved})`, saved === "done|39.0");

/* ---- ٧) الحصّة ---- */
await psql(`update subscriptions set writing_quota = 1 where user_id='${U}';`);
r = await call({ attempt_id: aid });
const q = await r.json();
check(`الحصّة الممتلئة بترفض (${q.error})`, q.error === "quota_exceeded");

/* ---- ٨) الحجب لأسباب السلامة ---- */
await psql(`update subscriptions set writing_quota = 9 where user_id='${U}';`);
const realFetch = globalThis.fetch;
const fake = (payload: unknown, status = 200) => {
  globalThis.fetch = (async (u: any, o: any) =>
    String(u).includes(`:${PORT_GEM}`)
      ? new Response(JSON.stringify(payload), { status,
          headers: { "content-type": "application/json" } })
      : realFetch(u, o)) as any;
};

fake({ candidates: [{ finishReason: "SAFETY", content: { parts: [] } }] });
r = await call({ attempt_id: aid });
let e = await r.json();
check(`الحجب بينتعامل معه (${e.error})`, e.error === "refused" && r.status === 502);
check("الصفّ انعلّم failed مو معلّق للأبد",
      await psql(`select status from writing_feedback where user_id='${U}'
                  order by created_at desc limit 1;`) === "failed");

/* ---- ٩) ★ الحصّة اليومية المجانية خلصت ---- */
// ١٥٠٠ طلب باليوم بتخلص. «٤٢٩» عارية ما بتقول للمستخدم شي.
fake({ error: { message: "quota" } }, 429);
r = await call({ attempt_id: aid });
e = await r.json();
check(`★ نفاد الحصّة إله رمز خاص (${e.error}/${r.status})`,
      e.error === "ai_quota" && r.status === 503);

/* ---- ١٠) ★ اسم نموذج غلط بيقول شو المتاح ---- */
// أسماء نماذج Gemini بتتغيّر، والمفاتيح المجانية ما كلها بتوصل لكلهن.
// «٤٠٤» صامتة بتضيّع نص ساعة؛ القائمة بتحلّها بسطر.
globalThis.fetch = (async (u: any, o: any) => {
  const s = String(u);
  if (s.includes(`:${PORT_GEM}`) && s.includes(":generateContent"))
    return new Response(JSON.stringify({ error: { message: "model not found" } }),
                        { status: 404, headers: { "content-type": "application/json" } });
  return realFetch(u, o);            // نداء قائمة النماذج بيمرق للمزيّف
}) as any;
r = await call({ attempt_id: aid });
e = await r.json();
globalThis.fetch = realFetch;
check(`★ نموذج غلط بيرجّع القائمة المتاحة (${String(e.detail ?? "").slice(0, 52)})`,
      e.error === "bad_model" && String(e.detail).includes("gemini-flash-latest"));
check("★ وما بيعرض نماذج ما بتصلح للتوليد",
      !String(e.detail).includes("gemini-embed"));

await supa.shutdown(); await gem.shutdown();
const bad = R.filter(x => !x[1]);
console.log(bad.length ? `\n✗ ${bad.length} فشل من ${R.length}` : `\n✓ كل الـ${R.length} اختبارات نجحت`);
Deno.exit(bad.length ? 1 : 0);
