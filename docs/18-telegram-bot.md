# Telegram bot — demo codes without you

Every demo code used to be manual: open the panel, pick a level, generate,
copy, paste into a chat. That stops working at the tenth request, and it
stops working entirely when the requests come at 2 a.m.

The bot does it. A student picks their language, the exam provider and the
level, and gets a code plus the link — no admin involved.

## What it can and cannot do

The bot creates **demo codes only**, and that limit lives in the database,
not in the bot:

| | |
|---|---|
| Duration | 24 hours (fixed) |
| Scope | the first published Modelltest of that level (fixed) |
| Activations | 1 (fixed) |
| Per Telegram account | one code, ever |

`bot_demo_code()` takes no parameter that can change any of those. If the
bot token leaks, or the function is called a million times, the worst
outcome is a pile of 24-hour single-test codes. There is no path from the
bot to full access — that stays in the admin panel, with you.

Coming back gives the **same** code again, not a new one. Someone who lost
the message finds it; someone farming codes gets nothing.

## Before you point this at real students

The bot hands out practice material at whatever rate people ask for it.
That makes it the point where distribution stops being a handful of codes
you sent yourself. The content licence question in
[10-commercialisation.md](10-commercialisation.md) is parked until the app
is ready — it should be settled before this bot is public, not after.

## Setup — once, about ten minutes

### 1. Create the bot

In Telegram, message [@BotFather](https://t.me/BotFather):

```
/newbot
```

Give it a name and a username. BotFather replies with a token that looks
like `8123456789:AAH...`. **That token is a password** — it never goes in
git, in a chat, or in a file in this repo.

Optional but worth it, still in BotFather:

```
/setdescription   — what the bot does, in your students' language
/setabouttext     — short version
/setuserpic       — your logo
```

### 2. Invent a webhook secret

Any random string. Telegram sends it back with every update, and the
function rejects anything without it — otherwise anyone who guesses the
function URL could send fake updates.

```bash
openssl rand -hex 32
```

Keep the output; you need it twice.

### 3. Store the secrets in Supabase

Supabase → your project → **Edge Functions** → **Secrets**, or:

```bash
supabase secrets set \
  TELEGRAM_BOT_TOKEN='8123456789:AAH…' \
  TELEGRAM_WEBHOOK_SECRET='<the random string from step 2>' \
  APP_URL='https://b1-telc.b1-telc.workers.dev'
```

`SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` are injected automatically —
don't set them.

### 4. Deploy

```bash
supabase functions deploy telegram --no-verify-jwt
```

`--no-verify-jwt` is required: Telegram does not send a Supabase JWT. The
webhook secret from step 2 is what authenticates the caller instead.

### 5. Point Telegram at it

```bash
curl -sS "https://api.telegram.org/bot<TOKEN>/setWebhook" \
  -H 'content-type: application/json' \
  -d '{
    "url": "https://<project-ref>.supabase.co/functions/v1/telegram",
    "secret_token": "<the random string from step 2>",
    "allowed_updates": ["message", "callback_query"]
  }'
```

`<project-ref>` is the subdomain of your Supabase URL.

Check it took:

```bash
curl -sS "https://api.telegram.org/bot<TOKEN>/getWebhookInfo"
```

`pending_update_count` should be 0 and `last_error_message` absent. A
persistent `401` there means the token is wrong; a `403` means the secret
doesn't match what you deployed.

### 6. Try it

Message your bot `/start`. You should get four language buttons.

## What the student sees

```
/start
   → ع العربية   🇩🇪 Deutsch   🇺🇦 Українська   🇬🇧 English
   → telc   Goethe   ÖSD          (skipped if you only have one)
   → A1  A2  B1  B2 …
   → code + link + what it opens and for how long
```

The level list is built from the database: every published level that has
at least one published Modelltest. Add a level in the panel and it appears
in the bot on the next message — nothing to redeploy.

## Where things live

| | |
|---|---|
| Function | `supabase/functions/telegram/index.ts` |
| Database | `supabase/migrations/0022_telegram.sql` |
| Tests (database) | `supabase/tests/12_telegram.sql` |
| Tests (function) | `tests/edge/telegram.ts` |

The conversation keeps no state between messages: each button carries what
came before it in its `callback_data`. A chat left half-finished for two
days still works when the student comes back to it, and there is no session
table to grow or expire.

## Who used it

`telegram_users` holds one row per account: the Telegram id, the username,
the language they chose, and the code they got. Codes carry
`note = 'telegram:<id>'`, so the Codes page in the panel shows which came
from the bot.

## When it doesn't work

| Symptom | Cause |
|---|---|
| Bot silent, `getWebhookInfo` shows 403 | `TELEGRAM_WEBHOOK_SECRET` differs from the `secret_token` you passed to `setWebhook` |
| Bot silent, no error in Telegram | webhook URL wrong, or deployed without `--no-verify-jwt` |
| "Something went wrong" on every level | database behind — run `supabase/setup.sql` |
| No levels offered | no published level has a published Modelltest |
