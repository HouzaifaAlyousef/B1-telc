/**
 * تصحيح التعبير الكتابي (Schriftlicher Ausdruck) بـGemini.
 *
 * الطالب بيبعت معرّف المحاولة. الدالة بتفحص صلاحيته وحصّته بهويّته هو
 * (فالـRLS بتشتغل طبيعي)، بتبعت الرسالة للنموذج، وبتحفظ النتيجة
 * بمفتاح service_role — لأن حفظ الدرجة ممنوع على الطالب.
 *
 * النموذج بيعطي **حرف** لكل معيار (A/B/C/D) مو رقم. تحويل الحروف لنقاط
 * بيصير بـwriting_finish() من جدول الدرجات المخزّن مع القسم. هيك ما في
 * طريق يخلّي النموذج — ولا الطالب — يقرّر العلامة.
 *
 * ★ ليش Gemini: الطبقة المجانية بتغطّي ١٥٠٠ طلب باليوم، والتصحيح كان
 *   يكلّف ٩ سنت للرسالة. القرار قرار صاحب المشروع.
 *   ملاحظة مسجّلة: الطبقة المجانية بتسمح لـGoogle تستعمل النصوص
 *   المرسلة لتحسين نماذجها — يعني رسائل الطلاب. النسخة المدفوعة لأ.
 *
 * أسرار لازمة (Supabase ← Edge Functions ← Secrets):
 *   GEMINI_API_KEY   من Google AI Studio
 *   GEMINI_MODEL     اختياري؛ الافتراضي تحت
 *   SUPABASE_URL, SUPABASE_ANON_KEY, SUPABASE_SERVICE_ROLE_KEY  (بتنحط لحالها)
 *
 * النشر:  supabase functions deploy correct-writing
 */

const MODEL = Deno.env.get("GEMINI_MODEL") || "gemini-flash-latest";
const BASE  = Deno.env.get("GEMINI_BASE_URL")
           || "https://generativelanguage.googleapis.com/v1beta";

const CORS = {
  "access-control-allow-origin": "*",
  "access-control-allow-headers": "authorization, content-type, apikey",
  "access-control-allow-methods": "POST, OPTIONS",
};

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS, "content-type": "application/json" },
  });

/* ---- شكل الجواب: مفروض بالسكيما، مو مرجوّ بالتعليمات ----
   Gemini بياخد مجموعة فرعية من OpenAPI. enum بيمنع النموذج يخترع
   درجة خامسة، وrequired بتمنع حقل ناقص يوصل لـwriting_finish. */
const SCHEMA = {
  type: "object",
  properties: {
    grades: {
      type: "array",
      description: "Ein Eintrag pro vorgegebenem Kriterium, in derselben Reihenfolge",
      items: {
        type: "object",
        properties: {
          criterion: { type: "string", description: "Name des Kriteriums, wortgleich wie vorgegeben" },
          key:       { type: "string", enum: ["A", "B", "C", "D"], description: "Bewertungsstufe" },
          why:       { type: "string", description: "Ein bis zwei Sätze Begründung, auf Deutsch" },
        },
        required: ["criterion", "key", "why"],
      },
    },
    errors: {
      type: "array",
      items: {
        type: "object",
        properties: {
          type:       { type: "string", enum: ["Grammatik", "Wortschatz", "Rechtschreibung", "Struktur", "Register"] },
          original:   { type: "string", description: "Die fehlerhafte Stelle, wortgleich aus dem Text" },
          correction: { type: "string", description: "Die korrigierte Fassung" },
          why:        { type: "string", description: "Kurze Erklärung auf Deutsch, für B1-Niveau verständlich" },
        },
        required: ["type", "original", "correction", "why"],
      },
    },
    corrected: { type: "string", description: "Der vollständige Brief, korrigiert, sonst unverändert" },
    summary:   { type: "string", description: "Drei bis fünf Sätze: was gut war und was als Nächstes zu üben ist" },
  },
  required: ["grades", "errors", "corrected", "summary"],
};

const SYSTEM = `Du bist Prüfer für die telc Deutsch B1 Prüfung und bewertest den
Schriftlichen Ausdruck. Bewerte genau nach den vorgegebenen Kriterien und Stufen,
nicht nach eigenem Maßstab.

Regeln:
- Antworte ausschließlich auf Deutsch. Der Lernende liest die Rückmeldung.
- Bewerte jedes vorgegebene Kriterium genau einmal und übernimm seinen Namen wortgleich.
- Vergib nur die Stufen A, B, C oder D. Halte dich an die Beschreibung der Stufen.
- Liste Fehler einzeln auf, mit dem Originalwortlaut. Erfinde keine Stellen,
  die nicht im Text stehen.
- Bei sehr kurzen Texten unter der Mindestwortzahl wirkt sich das auf die
  Aufgabenbewältigung aus — das ist Teil der Bewertung, kein Grund zum Abbruch.
- Sei konkret und knapp. Keine Floskeln, keine Wiederholung der Aufgabe.`;

/* أسماء النماذج بتتغيّر، والمفاتيح المجانية ما كلها بتوصل لكل نموذج.
   بدل «404» صامتة، منجيب القائمة ومنقول شو المتاح فعلاً. */
async function availableModels(key: string): Promise<string> {
  try {
    const r = await fetch(`${BASE}/models?key=${key}`);
    const b = await r.json();
    return (b.models ?? [])
      .filter((m: { supportedGenerationMethods?: string[] }) =>
        (m.supportedGenerationMethods ?? []).includes("generateContent"))
      .map((m: { name: string }) => m.name.replace(/^models\//, ""))
      .slice(0, 12).join(", ");
  } catch { return "—"; }
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const auth = req.headers.get("authorization") ?? "";
  if (!auth.startsWith("Bearer ")) return json({ error: "no_session" }, 401);

  const SUPA = Deno.env.get("SUPABASE_URL")!;
  const ANON = Deno.env.get("SUPABASE_ANON_KEY")!;
  const SERVICE = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const KEY = Deno.env.get("GEMINI_API_KEY");
  if (!KEY) return json({ error: "not_configured" }, 500);

  let attemptId: string;
  try {
    attemptId = (await req.json()).attempt_id;
    if (!attemptId) throw new Error();
  } catch {
    return json({ error: "bad_request" }, 400);
  }

  /* نداء SQL بهويّة الطالب — الصلاحية والحصّة بتنفحصوا هناك */
  const rpc = async (fn: string, args: unknown, asService = false) => {
    const key = asService ? SERVICE : ANON;
    const bearer = asService ? SERVICE : auth.slice(7);
    const r = await fetch(`${SUPA}/rest/v1/rpc/${fn}`, {
      method: "POST",
      headers: {
        apikey: key,
        authorization: `Bearer ${bearer}`,
        "content-type": "application/json",
      },
      body: JSON.stringify(args),
    });
    const body = await r.json().catch(() => null);
    if (!r.ok) throw new Error(body?.message ?? `${fn} ${r.status}`);
    return body;
  };

  const start = await rpc("writing_start", { p_attempt_id: attemptId });
  if (!start?.ok) return json(start ?? { error: "start_failed" }, 400);

  const fid = start.feedback_id;

  try {
    const criteria = (start.criteria ?? []) as Array<{ title: string; hint: string }>;
    const grades = (start.grades ?? []) as Array<{ key: string; points: number }>;
    const points = (start.points ?? []) as string[];
    const brief = start.task as { intro?: string; paragraphs?: string[] } | null;

    const prompt = [
      `# Aufgabe`,
      start.instruction ?? "",
      points.length ? `\nLeitpunkte, die der Brief abdecken muss:\n` +
        points.map((p, i) => `${i + 1}. ${p}`).join("\n") : "",
      start.min_words ? `\nMindestens ${start.min_words} Wörter.` : "",
      brief?.paragraphs?.length
        ? `\n# Der Brief, auf den geantwortet wird\n${brief.paragraphs.join("\n")}`
        : "",
      `\n# Bewertungskriterien`,
      criteria.map((c) => `- **${c.title}**: ${c.hint}`).join("\n"),
      `\n# Stufen`,
      grades.map((g) => `- ${g.key} = ${g.points} Punkte`).join("\n"),
      `\n# Text des Lernenden (${start.word_count ?? "?"} Wörter)`,
      "```",
      start.text,
      "```",
      `\nBewerte jedes der ${criteria.length} Kriterien und korrigiere den Text.`,
    ].filter(Boolean).join("\n");

    const r = await fetch(`${BASE}/models/${MODEL}:generateContent?key=${KEY}`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({
        systemInstruction: { parts: [{ text: SYSTEM }] },
        contents: [{ role: "user", parts: [{ text: prompt }] }],
        generationConfig: {
          responseMimeType: "application/json",
          responseSchema: SCHEMA,
          temperature: 0.2,          // تقييم، مو كتابة إبداعية
          maxOutputTokens: 8192,
        },
      }),
    });

    const body = await r.json().catch(() => null);

    if (!r.ok) {
      // ★ الحصّة اليومية المجانية خلصت — رسالة مفهومة، مو «٤٢٩» عارية
      if (r.status === 429) {
        await rpc("writing_fail", { p_feedback_id: fid, p_error: "quota" }, true);
        return json({ ok: false, error: "ai_quota" }, 503);
      }
      // اسم نموذج غلط: منقول شو المتاح لهالمفتاح فعلاً
      if (r.status === 404) {
        const have = await availableModels(KEY);
        await rpc("writing_fail", { p_feedback_id: fid, p_error: `model ${MODEL}` }, true);
        return json({ ok: false, error: "bad_model",
                      detail: `GEMINI_MODEL=${MODEL} — verfügbar: ${have}` }, 502);
      }
      throw new Error(body?.error?.message ?? `gemini ${r.status}`);
    }

    // حجب لأسباب السلامة: ما في مرشّح، أو انقطع قبل ما يخلص
    const cand = body?.candidates?.[0];
    const blocked = body?.promptFeedback?.blockReason
                 || (cand && cand.finishReason && cand.finishReason !== "STOP");
    if (!cand || blocked) {
      await rpc("writing_fail", { p_feedback_id: fid, p_error: `blocked ${blocked}` }, true);
      return json({ ok: false, error: "refused" }, 502);
    }

    let out: {
      grades: Array<{ criterion: string; key: string; why: string }>;
      errors: Array<{ type: string; original: string; correction: string; why: string }>;
      corrected: string; summary: string;
    } | null = null;
    try {
      out = JSON.parse(cand.content?.parts?.map((p: { text?: string }) => p.text ?? "").join("") ?? "");
    } catch { out = null; }

    if (!out?.grades?.length) {
      await rpc("writing_fail", { p_feedback_id: fid, p_error: "unparsed" }, true);
      return json({ ok: false, error: "unparsed" }, 502);
    }

    /* الحفظ بـservice_role: النقاط بتنحسب بالسيرفر من الحروف */
    const saved = await rpc("writing_finish", {
      p_feedback_id: fid,
      p_grades: out.grades,
      p_errors: out.errors ?? [],
      p_summary: out.summary ?? "",
      p_corrected: out.corrected ?? "",
      p_model: body?.modelVersion ?? MODEL,
    }, true);

    return json({
      ok: true,
      feedback_id: fid,
      points: saved.points,
      max_points: saved.max_points,
      grades: out.grades,
      errors: out.errors ?? [],
      corrected: out.corrected ?? "",
      summary: out.summary ?? "",
      usage: { input: body?.usageMetadata?.promptTokenCount,
               output: body?.usageMetadata?.candidatesTokenCount },
    });
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    await rpc("writing_fail", { p_feedback_id: fid, p_error: msg.slice(0, 300) }, true)
      .catch(() => {});
    return json({ ok: false, error: "correction_failed", detail: msg.slice(0, 200) }, 502);
  }
});
