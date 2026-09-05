/**
 * تصحيح التعبير الكتابي (Schriftlicher Ausdruck) بـClaude.
 *
 * الطالب بيبعت معرّف المحاولة. الدالة بتفحص صلاحيته وحصّته بهويّته هو
 * (فالـRLS بتشتغل طبيعي)، بتبعت الرسالة لـClaude، وبتحفظ النتيجة
 * بمفتاح service_role — لأن حفظ الدرجة ممنوع على الطالب.
 *
 * النموذج بيعطي **حرف** لكل معيار (A/B/C/D) مو رقم. تحويل الحروف لنقاط
 * بيصير بـwriting_finish() من جدول الدرجات المخزّن مع القسم. هيك ما في
 * طريق يخلّي النموذج — ولا الطالب — يقرّر العلامة.
 *
 * أسرار لازمة (Supabase → Edge Functions → Secrets):
 *   ANTHROPIC_API_KEY
 *   SUPABASE_URL, SUPABASE_ANON_KEY, SUPABASE_SERVICE_ROLE_KEY  (بتنحط لحالها)
 *
 * النشر:  supabase functions deploy correct-writing
 */
import Anthropic from "npm:@anthropic-ai/sdk@^0.123.0";
import { z } from "npm:zod@^4.0.0";
import { zodOutputFormat } from "npm:@anthropic-ai/sdk@^0.123.0/helpers/zod";

const MODEL = "claude-opus-5";

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

/* ---- شكل الجواب: مفروض بالسكيما، مو مرجوّ بالتعليمات ---- */
const Feedback = z.object({
  grades: z.array(z.object({
    criterion: z.string().describe("Name des Kriteriums, wortgleich wie vorgegeben"),
    key: z.enum(["A", "B", "C", "D"]).describe("Bewertungsstufe"),
    why: z.string().describe("Ein bis zwei Sätze Begründung, auf Deutsch"),
  })),
  errors: z.array(z.object({
    type: z.enum(["Grammatik", "Wortschatz", "Rechtschreibung", "Struktur", "Register"]),
    original: z.string().describe("Die fehlerhafte Stelle, wortgleich aus dem Text"),
    correction: z.string().describe("Die korrigierte Fassung"),
    why: z.string().describe("Kurze Erklärung auf Deutsch, für B1-Niveau verständlich"),
  })),
  corrected: z.string().describe("Der vollständige Brief, korrigiert, sonst unverändert"),
  summary: z.string().describe("Drei bis fünf Sätze: was gut war und was als Nächstes zu üben ist"),
});

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

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return json({ error: "method_not_allowed" }, 405);

  const auth = req.headers.get("authorization") ?? "";
  if (!auth.startsWith("Bearer ")) return json({ error: "no_session" }, 401);

  const SUPA = Deno.env.get("SUPABASE_URL")!;
  const ANON = Deno.env.get("SUPABASE_ANON_KEY")!;
  const SERVICE = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
  const KEY = Deno.env.get("ANTHROPIC_API_KEY");
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
    const client = new Anthropic({ apiKey: KEY });

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

    const res = await client.messages.parse({
      model: MODEL,
      max_tokens: 16000,
      system: SYSTEM,
      thinking: { type: "adaptive" },
      output_config: { format: zodOutputFormat(Feedback), effort: "high" },
      messages: [{ role: "user", content: prompt }],
    });

    if (res.stop_reason === "refusal") {
      await rpc("writing_fail", { p_feedback_id: fid, p_error: "refusal" }, true);
      return json({ ok: false, error: "refused" }, 502);
    }
    const out = res.parsed_output;
    if (!out) {
      await rpc("writing_fail", { p_feedback_id: fid, p_error: "unparsed" }, true);
      return json({ ok: false, error: "unparsed" }, 502);
    }

    /* الحفظ بـservice_role: النقاط بتنحسب بالسيرفر من الحروف */
    const saved = await rpc("writing_finish", {
      p_feedback_id: fid,
      p_grades: out.grades,
      p_errors: out.errors,
      p_summary: out.summary,
      p_corrected: out.corrected,
      p_model: res.model ?? MODEL,
    }, true);

    return json({
      ok: true,
      feedback_id: fid,
      points: saved.points,
      max_points: saved.max_points,
      grades: out.grades,
      errors: out.errors,
      corrected: out.corrected,
      summary: out.summary,
      usage: { input: res.usage?.input_tokens, output: res.usage?.output_tokens },
    });
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    await rpc("writing_fail", { p_feedback_id: fid, p_error: msg.slice(0, 300) }, true)
      .catch(() => {});
    return json({ ok: false, error: "correction_failed", detail: msg.slice(0, 200) }, 502);
  }
});
