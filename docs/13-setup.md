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

## 3. Create the schema — one paste

**SQL Editor → New query.** Paste the whole of `supabase/setup.sql` and Run.

It is every migration in order, in one file, and it is safe to run again:
tables, indexes and policies all use `if not exists` / `drop … if exists`, so a
paste that half-succeeded can simply be re-run rather than leaving you stuck.

## 4. Load the B1 content

Paste `supabase/seed/b1.sql` and Run. It is ~430 KB, which the SQL editor
often chokes on. Pre-split copies are in `supabase/seed/parts/` — paste
`b1-1.sql` … `b1-4.sql` one after the other instead. Both routes load the same
16 exams, 912 questions and 896 answers; each part is safe to re-run.

Regenerate it first only if you changed `data/`:

```bash
python3 tools/export_sql.py data supabase/seed/b1.sql --level b1
```

## 5. Upload the exam images

The buckets and their read policy come from `0013_storage.sql`, which
`setup.sql` already applied in step 3. Nothing to create by hand.

> Storage enforces its own RLS on `storage.objects`, separate from the table
> policies. Without that migration every signing request returns 403 and the
> image simply never appears — no error anywhere. The policy also ties each
> file to the level that references it, so a B1 image is unreachable for an
> A1 subscriber.

**The panel can do this for you.** Adminpanel → **Dateien** lists every file
an exam needs, marks what is missing, and uploads straight from the browser
under your admin session — no `service_role` key on your machine, no script.
It also names the file for you, so it always matches what the exam expects.

The script below still works and is faster for the initial 16 at once:

```bash
export SUPABASE_URL=https://xxxxxxxx.supabase.co
export SUPABASE_SERVICE_KEY=eyJ…        # service_role, from your machine only
python3 tools/upload_images.py data/img
```

**Check:** Storage → `exam-images` shows 16 files under `img/`, and the bucket
is marked **Private**. `verify.sql` (step 7) checks both, plus that every
section needing an image has one uploaded.

If you have no terminal, the dashboard works too: Storage → `exam-images` →
create a folder `img` → drag the 16 files from `data/img/` into it. The name in
the bucket must match `bankImage` exactly, or the policy will not find the row
that authorises it.

## 6. Create your admin account

**Authentication → Users → Add user** with an email and password. Copy the
user's UID, then in the SQL Editor:

```sql
insert into profiles (id, is_admin, display_name)
values ('<the UID>', true, 'Admin')
on conflict (id) do update set is_admin = true;
```

**Check:** `select is_admin from profiles where id = '<UID>';` → `t`

## 7. Check the install

**SQL Editor → New query → paste `supabase/verify.sql` → Run.**

Sixteen checks with a ✓ or ✗ each, and for anything that failed, the exact
thing to do about it. The important ones: that `item_answers` has RLS with no
policy and no privilege (the answer keys), that `items` has no answer column at
all, that `writing_finish` is out of reach of students, and that the content
actually landed.

Do not go further while anything is ✗.

## 8. Point the app at the project

Edit `assets/config.js`:

```js
window.TELC_CONFIG = {
  supabaseUrl: 'https://xxxxxxxx.supabase.co',
  supabaseAnonKey: 'eyJ…',
};
```

## 9. Try it locally

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

## 10. Deploy

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

## 11. Optional: AI correction of the writing task

Not required to launch. See
[14-writing-correction.md](14-writing-correction.md) — it needs an Anthropic
API key stored as a Supabase secret and one `supabase functions deploy`.
Without it the app works exactly as described above; the correction button
just says it is not set up.

## The panel, tab by tab

| Tab | What it is for |
|---|---|
| **Übersicht** | Numbers at a glance, and recent failed code attempts. |
| **Nutzer** | Every account: which codes they redeemed, every subscription, lengthen or shorten each one on its own. |
| **Codes** | Generate access codes. *Vollzugang* opens a whole level for days; *Demo* opens the tests you pick for hours. |
| **Inhalte** | Levels, model tests, reading material. Filter by level; **bearbeiten** opens a test back in the import editor. |
| **Dateien** | Every image and audio file an exam needs, what is missing, upload straight from the browser. |
| **Import** | Paste a new exam. **Beispiel einfügen** for a worked example, **Leere Vorlage** for the blank 61-slot template. Once the test is published, its own files appear at the bottom of the same page — upload them there, no tab switch. |
| **Protokoll** | Every admin action, who did it and when. |

**Lesematerial** (under Inhalte) is not a test: free text your students can read
any time — vocabulary lists, grammar notes, exam tips. No clock, no points, no
answer key. Anyone subscribed to that level sees it.

**Editing a published test:** Inhalte → pick the level → **bearbeiten**. The
test comes back as the same template language you paste in, you change what you
need, and saving replaces it. Verified lossless: questions, answers and
explanations come back byte-identical through a full read-edit-save cycle.

### A "level" is provider + stufe

`A1` on its own is not a product. There is a telc A1, a Goethe A1, an ÖSD A1 —
different exams, different structure. So one row in `levels` is one **exam
product**:

| id | provider | stufe | what it sells |
|---|---|---|---|
| `b1` | telc | B1 | the 16 exams in this repo |
| `goethe-b1` | Goethe | B1 | a separate product |
| `oesd-a2` | ÖSD | A2 | a separate product |

A code for telc·B1 does **not** open Goethe·B1. Everything that already guarded
access — subscriptions, codes, RLS, storage — hangs off this one id and did not
have to change; `provider` and `stufe` are two descriptive columns on top.

Create one under **Inhalte → Prüfungen** (Anbieter + Stufe; id and title are
generated), or from the level selector in Import or Codes — last entry,
*+ neue Stufe anlegen*. It starts hidden, because a published product with no
exams in it is what the student would see.

Everywhere you choose an exam, it is **two fields**: Anbieter, then Stufe. One
grouped dropdown was tried first and rejected — a closed `<select>` shows only
`B1`, hiding the provider, which is half the decision.

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
