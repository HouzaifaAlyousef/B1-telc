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

Each correction is roughly 1,200 input and 900 output tokens. On
`claude-opus-5` at $5 / $25 per million tokens that is about **$0.03 per
correction** — call it $0.04 with the thinking tokens.

That is per request, so it needs a ceiling. `subscriptions.writing_quota`
(default 20) caps corrections per subscription period, checked in
`writing_start()` before anything is sent. Twenty corrections is about $0.80
per student per month — set it against what you charge.

Raise or lower it per student in SQL:

```sql
update subscriptions set writing_quota = 50 where user_id = '…';
```

A failed correction does not consume quota; the row is marked `failed` and
excluded from the count.

## Setup

1. **Get an API key** — [console.anthropic.com](https://console.anthropic.com)
   → API Keys. Put credit on the account.
2. **Store it as a secret**, never in `assets/config.js`:
   ```bash
   supabase secrets set ANTHROPIC_API_KEY=sk-ant-…
   ```
3. **Deploy the function:**
   ```bash
   supabase functions deploy correct-writing
   ```
   `SUPABASE_URL`, `SUPABASE_ANON_KEY` and `SUPABASE_SERVICE_ROLE_KEY` are set
   by the platform.

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
