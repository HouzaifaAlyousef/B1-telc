/* تشغيل حقيقي للـEdge Function بـDeno.
   الـSupabase مزيّف (بيترجم النداءات لـpsql على القاعدة المحلية) وClaude
   مزيّف كمان — بس **الدالة نفسها** يلي بتنشتغل هي كود الإنتاج بالحرف. */
const PORT_SUPA = 54321;
const PORT_ANTH = 54322;

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

/* ---- Claude مزيّف: بيرجّع شكل الجواب المفروض بالسكيما ---- */
let anthropicSaw: any = null;
const anth = Deno.serve({ port: PORT_ANTH, onListen() {} }, async (req) => {
  anthropicSaw = await req.json();
  const body = {
    id: "msg_test", type: "message", role: "assistant", model: "claude-opus-5",
    stop_reason: "end_turn", stop_sequence: null,
    usage: { input_tokens: 1200, output_tokens: 900 },
    content: [{ type: "text", text: JSON.stringify({
      grades: [
        { criterion: "Aufgabenbewältigung",    key: "A", why: "Alle vier Leitpunkte bearbeitet." },
        { criterion: "Kommunikative Gestaltung", key: "B", why: "Anrede vorhanden, Gruß knapp." },
        { criterion: "Formale Richtigkeit",    key: "A", why: "Wenige Fehler." },
      ],
      errors: [{ type: "Grammatik", original: "Ich fliege", correction: "Ich fliege am liebsten",
                 why: "Adverb fehlt." }],
      corrected: "Liebe Anna, …",
      summary: "Guter Brief, achte auf den Gruß.",
    })}],
  };
  return new Response(JSON.stringify(body), { headers: { "content-type": "application/json" } });
});

/* ---- تشغيل الدالة ---- */
Deno.env.set("SUPABASE_URL", `http://127.0.0.1:${PORT_SUPA}`);
Deno.env.set("SUPABASE_ANON_KEY", "ANON_KEY");
Deno.env.set("SUPABASE_SERVICE_ROLE_KEY", "SERVICE_KEY");
Deno.env.set("ANTHROPIC_API_KEY", "sk-test");
Deno.env.set("ANTHROPIC_BASE_URL", `http://127.0.0.1:${PORT_ANTH}`);

const R: [string, boolean][] = [];
const check = (l: string, c: unknown) => { R.push([l, !!c]); console.log(`  ${c ? "✓" : "✗"} ${l}`); };

/* الدالة بتنادي Deno.serve — منلقطه بدل ما نشغّل سيرفر */
let handler: (r: Request) => Promise<Response> | Response;
const realServe = Deno.serve;
// @ts-ignore: نستبدل مؤقّتاً
Deno.serve = ((h: any) => { handler = h; return { finished: Promise.resolve(), shutdown(){}, addr:{} } as any; }) as any;
await import("../../supabase/functions/correct-writing/index.ts");
Deno.serve = realServe;

console.log("\n=== Edge Function: تصحيح التعبير الكتابي ===");

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

/* ---- ٤) شو انبعت لـClaude ---- */
check("النموذج المطلوب claude-opus-5", anthropicSaw?.model === "claude-opus-5");
check("تفكير adaptive", anthropicSaw?.thinking?.type === "adaptive");
check("سكيما مفروضة (output_config.format)", !!anthropicSaw?.output_config?.format);
const p = anthropicSaw?.messages?.[0]?.content ?? "";
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

/* ---- ٨) رفض Claude ---- */
await psql(`update subscriptions set writing_quota = 9 where user_id='${U}';`);
const realFetch = globalThis.fetch;
globalThis.fetch = (async (u: any, o: any) => {
  if (String(u).includes(`:${PORT_ANTH}`))
    return new Response(JSON.stringify({
      id:"m", type:"message", role:"assistant", model:"claude-opus-5",
      stop_reason:"refusal", stop_details:{type:"refusal",category:"other"},
      usage:{input_tokens:10,output_tokens:0}, content:[] }),
      { headers:{ "content-type":"application/json" } });
  return realFetch(u, o);
}) as any;
r = await call({ attempt_id: aid });
const ref = await r.json();
globalThis.fetch = realFetch;
check(`رفض النموذج بينتعامل معه (${ref.error})`, ref.error === "refused" && r.status === 502);
const failed = await psql(`select status from writing_feedback where user_id='${U}'
  order by created_at desc limit 1;`);
check("الصفّ انعلّم failed مو معلّق للأبد", failed === "failed");

await supa.shutdown(); await anth.shutdown();
const bad = R.filter(x => !x[1]);
console.log(bad.length ? `\n✗ ${bad.length} فشل من ${R.length}` : `\n✓ كل الـ${R.length} اختبارات نجحت`);
Deno.exit(bad.length ? 1 : 0);
