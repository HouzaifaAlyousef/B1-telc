# AI correction of the writing task

The `Schriftlicher Ausdruck` was self-assessed: the student read the criteria
and judged their own letter. That is the one part of the exam a PDF cannot help
with, and it is the single most valuable thing this product can offer.

## What it does

The student submits their letter. `supabase/functions/correct-writing` sends it
to Claude with the task, its four Leitpunkte, the three official criteria and
the grade bands, and gets back a grade per criterion with reasons, every error
with a correction and a short explanation, a corrected version of the letter,
and a summary of what to practise next. All in German — the student reads it.

The self-assessment stays on the screen next to it. Judging your own text
against the criteria is the exercise telc actually asks for; the correction
tells you what is really in the text.

## The model cannot decide the grade

This is the design point worth keeping.

The model returns a **letter** per criterion — A, B, C or D — and nothing else
numeric. `writing_finish()` converts letters to points using the `grades` table
stored with the section, sums them, and multiplies by the section's `factor`.
For B1 that is 3 criteria × 5 points × factor 3 = 45, which is the official
scheme. A letter that is not in the table scores zero rather than being
guessed at.

So neither the model nor the student can produce a number. `writing_finish`
and `writing_fail` are revoked from `authenticated` entirely — only the Edge
Function, holding the service role key, can write a result. The student's own
call is `writing_start()`, which runs as them and therefore goes through the
usual entitlement checks.

## Cost

Free, within a daily allowance.

The correction runs on **Gemini's free tier**: no card, no bill, and
[1,500 requests a day](https://ai.google.dev/gemini-api/docs/rate-limits) —
far more than this app will use. It replaced `claude-opus-5`, which was
correct but cost about **$0.09 per correction**; at a quota of 20 that was
$1.80 per subscriber, and the owner decided that was too much of the margin.

**Two things follow from choosing the free tier, and both are deliberate:**

1. **Google may use the text to improve their models.** That is the
   published condition of the free tier (the paid tier and Vertex AI do
   not). The text in question is a student's letter. The owner was told and
   chose the free tier, and chose not to show students a notice.
2. **The daily allowance can run out.** When it does the function returns
   `ai_quota` and the student sees "try again tomorrow", not a stack trace.
   The correction is marked `failed`, so it does not eat their quota.

`subscriptions.writing_quota` (default 20) still caps corrections per
subscription period, checked in `writing_start()` before anything is sent —
it is now about pacing rather than money. Raise or lower it per student:

```sql
update subscriptions set writing_quota = 50 where user_id = '…';
```

A failed correction does not consume quota; the row is marked `failed` and
excluded from the count.

## Setup

1. **Get an API key** — [Google AI Studio](https://aistudio.google.com/apikey)
   → Create API key. Free, no credit card.
2. **Store it as a secret**, never in `assets/config.js`:
   ```bash
   supabase secrets set GEMINI_API_KEY=…
   ```
3. **Deploy the function:**
   ```bash
   supabase functions deploy correct-writing
   ```
   `SUPABASE_URL`, `SUPABASE_ANON_KEY` and `SUPABASE_SERVICE_ROLE_KEY` are set
   by the platform.

### Picking the model

Model names change, and not every key reaches every model. The default is
`gemini-flash-latest`. If that name is wrong for your key, the function does
not fail silently — it returns `bad_model` **and lists the models your key
can actually use**. Set whichever one you want:

```bash
supabase secrets set GEMINI_MODEL=gemini-3.7-flash
```

You can also list them yourself:

```bash
curl "https://generativelanguage.googleapis.com/v1beta/models?key=$GEMINI_API_KEY"
```

Prefer a Flash model: this is grading against fixed criteria, not open-ended
reasoning, and Flash models are what the free tier is generous with.

Without step 2 the feature reports `not_configured` and the rest of the app is
unaffected — the button simply says the correction is not set up yet.

## Testing

`tests/edge/run.ts` runs the **actual function** under Deno against the local
Postgres, with Supabase and Claude stubbed at the HTTP boundary. It checks the
whole path: a request with no session is refused, the prompt carries the
student's text, the three criteria and the grade ladder, `writing_start` runs
as the student while `writing_finish` runs as the service role, 39 points is
what lands in the database for A/B/A, an exhausted quota is refused, and a
model refusal marks the row failed instead of leaving it pending forever.

One assertion is there to catch a specific mistake: the prompt must not ask the
model to compute a score. If someone later adds "calculate the total" to the
system prompt, that test fails.

```bash
deno run --allow-all tests/edge/run.ts     # or ./tests/run.sh
```

## What it does not do

It does not mark the exam. The points it produces are stored in
`writing_feedback`, not in `attempts` — a student's official result for the
writing block stays their own self-assessment, as telc intends. Treat the AI
score as feedback, not as a grade.
