# Setup — from an empty Supabase project to a working app

Follow this once. Every step says how to check it worked, because a mistake in
step 3 shows up as a confusing error in step 8.

Nothing here needs a paid plan.

## 1. Create the project

[supabase.com](https://supabase.com) → **New project**. Pick a region near your
students. Save the database password somewhere — you will not be shown it again.

Then **Project Settings → API** and copy two values:

- **Project URL** — `https://xxxxxxxx.supabase.co`
- **anon public** key — a long `eyJ…` string

The anon key is *meant* to be public; it identifies the project, and RLS is what
protects the data. The **service_role** key on the same page is the opposite —
it bypasses RLS entirely. Never put it in the frontend, in git, or in a browser.

## 2. Enable anonymous sign-in

**Authentication → Providers → Anonymous sign-ins → enable.**

Students have no email and no password. Redeeming a code creates an anonymous
account and binds the code to it. Without this the code screen fails with
`Signups not allowed`.

## 3. Run the migrations

**SQL Editor → New query.** Paste and run each file in order, one at a time:

```
supabase/migrations/0001_init.sql     tables
supabase/migrations/0002_rls.sql      access rules and grants
supabase/migrations/0003_functions.sql  redeem, devices, grading
supabase/migrations/0004_admin.sql    admin actions
supabase/migrations/0005_content.sql  import, resources, levels
```

**Check:** Table Editor should list 14 tables. `item_answers` should be there
and should be empty.

## 4. Load the B1 content

```bash
python3 tools/export_sql.py data supabase/seed/b1.sql --level b1
```

Then paste `supabase/seed/b1.sql` into the SQL Editor and run it. It is about
430 KB — if the editor struggles, split it at a `-- =====` comment.

**Check:**

```sql
select
  (select count(*) from tests)        as tests,        -- 16
  (select count(*) from sections)     as sections,     -- 141
  (select count(*) from items)        as items,        -- 912
  (select count(*) from item_answers) as answers;      -- 896
```

The 16 items without answers are the writing tasks. That is correct.

## 5. Upload the exam images

The Leseverstehen 3 pages are exam content, so they go in a **private** bucket:

```bash
export SUPABASE_URL=https://xxxxxxxx.supabase.co
export SUPABASE_SERVICE_KEY=eyJ…        # service_role, from your machine only
python3 tools/upload_images.py data/img
```

**Check:** Storage → `exam-images` shows 16 files under `img/`, and the bucket
is marked **Private**. If it says Public, fix it — a public bucket hands out the
exam pages to anyone with the URL.

## 6. Create your admin account

**Authentication → Users → Add user** with an email and password. Copy the
user's UID, then in the SQL Editor:

```sql
insert into profiles (id, is_admin, display_name)
values ('<the UID>', true, 'Admin')
on conflict (id) do update set is_admin = true;
```

**Check:** `select is_admin from profiles where id = '<UID>';` → `t`

## 7. Point the app at the project

Edit `assets/config.js`:

```js
window.TELC_CONFIG = {
  supabaseUrl: 'https://xxxxxxxx.supabase.co',
  supabaseAnonKey: 'eyJ…',
};
```

## 8. Try it locally

```bash
./run.sh
```

- `http://127.0.0.1:8000/admin/` — sign in with the admin account from step 6.
  The dashboard should show 16 tests online.
- Generate a code: **Codes → Erzeugen**, 1 code, 30 days.
- `http://127.0.0.1:8000/` — enter that code. The 16 Modelltests should appear.
- Open one, start Leseverstehen, submit. You should get a score and the
  solutions.

If all of that works, the whole chain works: auth, entitlement, content,
server-side grading and the audit log.

## 9. Deploy

```bash
./tools/build_dist.sh
```

This is the only supported way to build for deployment. It copies what belongs
online and **refuses to finish** if `data/` — or any file containing answer
keys — ends up in the output. Upload `dist/` to any static host: Cloudflare
Pages, Netlify, GitHub Pages, an Nginx root.

The student app is at the root, the panel at `/admin/`. Both are protected by
`profiles.is_admin` in the database, not by the URL.

The result is about 200 KB. Everything else — questions, answers, images — comes
from Supabase, per request, only for people with an active subscription.

## 10. Optional: AI correction of the writing task

Not required to launch. See
[14-writing-correction.md](14-writing-correction.md) — it needs an Anthropic
API key stored as a Supabase secret and one `supabase functions deploy`.
Without it the app works exactly as described above; the correction button
just says it is not set up.

## Day-to-day

| Task | Where |
|---|---|
| A student paid | Codes → Erzeugen → send them the code |
| Extend a subscription | Nutzer → **+30** |
| Student changed phone | Nutzer → … → Geräte zurücksetzen |
| Add an exam | Import → paste → check the preview → Veröffentlichen |
| Add reading material | Inhalte → Lesematerial |
| Add a level | Inhalte → Stufen |
| Who changed what | Protokoll |

## When something breaks

| Symptom | Cause |
|---|---|
| `Signups not allowed` on the code screen | step 2 not done |
| Code accepted, but no tests appear | tests not `published`, or the code's level does not match `tests.level_id` |
| `permission denied for table …` | 0002 not run, or only partly |
| Panel says "kein Administrator" | step 6 not done for the account you signed in with |
| Reading texts show, images do not | bucket missing, or `bankImage` does not match the uploaded path |
| Grading returns `not_entitled` | subscription expired, or covers a different level |

## Before taking money

Two things are unresolved and neither is technical:

1. **Licensing.** The 16 tests are derived from telc's material and all come
   from one source, so a single complaint reaches all of them at once. See
   [10-commercialisation.md](10-commercialisation.md).
2. **Hörverstehen has no audio.** A third of every exam currently shows the
   transcript instead of being listened to. Selling an exam trainer with that
   gap is a product problem before it is a technical one.
