# What is still open, in the order it has to be done

Everything in the repository is written, tested and green. What follows is
work that only you can do — keys, uploads, and one branch decision.

Each step says what breaks if you skip it, and how to check it worked.

---

## 0. Which branch does Cloudflare deploy? — do this first

`main` is **52 commits behind** `kiko-branch` and was last touched on
30 August. Every change since then — the new code format, the settings bar,
the waiting list, the Telegram bot, the free correction — lives only on
`kiko-branch`.

So one of two things is true, and you need to know which:

- **Cloudflare builds `kiko-branch`** → nothing to do, skip to step 1.
- **Cloudflare builds `main`** (the repository default) → **none of the
  recent work is live**, no matter what else you do below.

Check it: Cloudflare dashboard → Workers → `b1-telc` → Settings → Builds →
*Branch*.

If it says `main`, pick one:

```bash
# أ) merge the work into main (a pull request, or directly)
git checkout main && git merge kiko-branch && git push origin main

# ب) or point Cloudflare at kiko-branch in that same settings page
```

Verify: open `https://b1-telc.b1-telc.workers.dev` and check that the
settings bar (🇩🇪 🇸🇦 🇺🇦 ☀ 🌙 A− A+) is at the top of the start page. If it
isn't, the deploy is old.

---

## 1. Update the database — blocks everything below

Your database is at version 21. The code needs **23**. Until you do this,
the waiting list and the Telegram bot do not exist as far as Postgres is
concerned, and the panel shows a red banner on every screen.

1. Open [`supabase/setup.sql`](../supabase/setup.sql), click **Raw**,
   select all, copy.
2. Supabase → SQL Editor → New query → paste → **Run**.

Yellow `already exists, skipping` messages are normal. The file is safe to
re-run — a test runs it three times in a row.

**Verify:**

```sql
select schema_version();     -- must return 23
```

Then paste [`supabase/verify.sql`](../supabase/verify.sql) for a fuller
check of tables, policies and functions.

---

## 2. Set the capacity limits — 2 minutes

Both limits ship as `0`, which means *no limit*. The waiting list exists but
never triggers until you set a number.

Panel → **Übersicht** → Warteliste → two fields → Speichern.

Suggested start: **50** active users, **10** new per day. Reasoning and the
numbers behind it: [19-capacity.md](19-capacity.md).

**Verify:** the counters above the fields show `0 / 50` and `0 / 10`.

---

## 3. Deploy the writing correction — 45 of 225 points

Without it the student still gets the automatic checks (word count, greeting,
closing, spelling) and grades themselves. With it they get a full correction.

```bash
# ١) free key, no credit card: https://aistudio.google.com/apikey
supabase secrets set GEMINI_API_KEY=…

# ٢) deploy
supabase functions deploy correct-writing
```

**Verify:** do a Schriftlicher Ausdruck in the app and press
*Korrektur anfordern*.

If you see "noch nicht eingerichtet", the model name is wrong for your key —
the error carries the list of models you *can* use:

```bash
supabase secrets set GEMINI_MODEL=…      # one from that list
```

Details: [14-writing-correction.md](14-writing-correction.md).

---

## 4. Deploy the Telegram bot — hands out demo codes on its own

Without it every demo code stays manual work for you.

```bash
# ١) @BotFather → /newbot → copy the token
# ٢) invent a webhook secret
openssl rand -hex 32

# ٣) three secrets
supabase secrets set \
  TELEGRAM_BOT_TOKEN='…' \
  TELEGRAM_WEBHOOK_SECRET='…' \
  APP_URL='https://b1-telc.b1-telc.workers.dev'

# ٤) deploy — the flag is required, Telegram sends no Supabase JWT
supabase functions deploy telegram --no-verify-jwt

# ٥) point Telegram at it
curl -sS "https://api.telegram.org/bot<TOKEN>/setWebhook" \
  -H 'content-type: application/json' \
  -d '{"url":"https://<project-ref>.supabase.co/functions/v1/telegram",
       "secret_token":"<the secret from step 2>",
       "allowed_updates":["message","callback_query"]}'
```

**Verify:** message your bot `/start` — four language buttons should appear.

Full walkthrough and troubleshooting: [18-telegram-bot.md](18-telegram-bot.md).

---

## 5. Upload 17 images — Leseverstehen Teil 3 is blank without them

17 sections reference an advertisement image. Until they are uploaded, that
part of the exam shows nothing.

Panel → **Dateien** → filter by level → upload each. The filename is taken
from the test, so it does not matter what the file is called on your
computer.

**Verify:** the Dateien page counter says `0 fehlen` for images.

---

## 6. Record 50 Hörverstehen recordings — the largest gap

50 listening sections have no audio. Right now students can only *read* the
listening transcripts, which is not the exam.

This is recording work, not development. Options and the naming scheme:
[16-audio.md](16-audio.md). The panel suggests the correct filename for each
section.

**When the recordings exist, come back to storage.** 5 GB of Supabase egress
is about 400 listening sittings a month. The decision at that point is
Cloudflare R2 (free egress) — the design is written up in
[19-capacity.md](19-capacity.md). Do not do it before the files exist.

---

## 7. Content licensing — before the first euro

Deferred on purpose, not forgotten. The trigger is **taking payment or
making the bot public**, not the first user. Read
[10-commercialisation.md](10-commercialisation.md) before either happens.

---

## Deliberately not built

| | Why |
|---|---|
| Human correction queue | You chose Gemini only. Half a day of work if the grades turn out unreliable. |
| Cloudflare R2 | Nothing to move until the recordings exist. |
| Privacy notice about Gemini | You chose not to show one. Recorded in [15-security.md](15-security.md). |
