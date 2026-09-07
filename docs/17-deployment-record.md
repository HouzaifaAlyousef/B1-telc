# How this got deployed — the actual record

Written down because it was done once, by hand, and none of it is obvious a
month later. This is what exists, where, and how to redo it.

Setup instructions for a *fresh* project live in [`13-setup.md`](13-setup.md).
This file is the record of **the real deployment** and the decisions behind it.

---

## The two halves

```
   Browser                Cloudflare Workers          Supabase
 ┌──────────┐            ┌──────────────────┐      ┌─────────────────┐
 │ student  │──static────│  b1-telc         │      │  Postgres + RLS │
 │  /       │  files     │  (assets only,   │      │  Auth (anon)    │
 │          │            │   no server code)│      │  Storage        │
 │ admin    │──API───────┼──────────────────┼──────│  Edge Functions │
 │ /kmh…/   │  calls     └──────────────────┘      └─────────────────┘
 └──────────┘                                              ▲
                                              service_role │ only from
                                                           │ your own shell
```

Cloudflare serves **files only**. Every read, write and permission check
happens in Supabase. That is why the JavaScript being readable in the browser
does not matter — see [`15-security.md`](15-security.md).

---

## Supabase

**Project:** `ejwzvgabqoevhaimbvik` · region West EU (Ireland) · Free plan.

What was done, in order:

1. **API keys.** Project Settings → API. The **anon** key went into
   `assets/config.js` and is committed — it is public by design; RLS is what
   protects the data. The **service_role** key was never committed and is only
   used from a personal shell for bulk uploads.

2. **Anonymous sign-ins enabled.** Authentication → Sign In / Providers →
   *Allow anonymous sign-ins*. Students never create an account; the app signs
   them in anonymously and the access code attaches a subscription to that
   anonymous user.

3. **Schema.** `supabase/setup.sql` pasted into the SQL Editor and run. That
   file is generated from `supabase/migrations/*.sql` by
   `tools/build_setup.sh` and is safe to re-run — a test executes it three
   times in a row and fails if anything errors.

4. **Content.** `supabase/seed/b1.sql` is 436 KB and the SQL editor struggles
   with it, so `supabase/seed/parts/b1-1.sql` … `b1-4.sql` were pasted one
   after another instead. Both routes load the same 16 exams, 912 questions,
   896 answers.

5. **Admin account.** Authentication → Users → *Add user* with
   **Auto Confirm User** ticked (email confirmation is on), then:

   ```sql
   insert into profiles (id, is_admin, display_name)
   select id, true, 'Admin' from auth.users where email = '<your email>'
   on conflict (id) do update set is_admin = true;
   ```

6. **Verification.** `supabase/verify.sql` — read-only, 19 checks, prints a
   verdict row at the end. Run it after any schema change.

### Keeping the database current

This is the part that bit us repeatedly. **Cloudflare redeploys within a
minute of a push; the database does not update itself.** A new interface then
calls functions that do not exist yet, and every feature fails in its own
silent way.

`schema_version()` exists for exactly this. The admin panel compares it
against `SCHEMA_MIN` in `admin/admin.js` and shows a banner on every screen
when the database is behind.

> **After pulling changes that touch `supabase/`: paste `setup.sql` again.**

---

## Cloudflare

**Worker:** `b1-telc` → `https://b1-telc.b1-telc.workers.dev`

Connected to the Git repository, so every push to the production branch
rebuilds. Settings:

| Setting | Value |
|---|---|
| Build command | `./tools/build_dist.sh` |
| Deploy command | `npx wrangler deploy` (default) |
| Root directory | `/` |
| Config file | `wrangler.jsonc` (`assets.directory = ./dist`) |

### Why the build command is not optional

`data/` in the repository holds all 896 answer keys as JSON. Deploying the
repository as-is would publish every answer. `tools/build_dist.sh` copies only
what belongs on a public site, and **fails the build** if any answer key
reaches the output. A test plants a leak on purpose and checks the guard
catches it.

The build also:

- strips developer comments from every JS and CSS file
- puts the admin panel on a non-obvious path (`ADMIN_PATH`, default
  `kmh123475674`) and rewrites the `_headers` noindex rule to match

The secret admin path is **not** the guard — `profiles.is_admin` in the
database is. It just keeps a login form off `/admin/`.

### Storage buckets

`exam-images` and `exam-audio`, both **private**, created by
`0013_storage.sql`. The app fetches files through signed URLs that expire.
Supabase Storage enforces its own RLS on `storage.objects`, separate from the
table policies — without `0013` every signing request returns 403 and images
simply never appear, with no error anywhere.

Upload from the admin panel (**Dateien** tab, or the box under Import). The
Python scripts in `tools/` still work and are faster for the first bulk load:

```bash
export SUPABASE_URL=https://ejwzvgabqoevhaimbvik.supabase.co
export SUPABASE_SERVICE_KEY=<service_role key>   # your own shell only
python3 tools/upload_images.py data/img
```

---

## Local development

```bash
./run.sh          # serves the app, opens student + admin in the browser
./run.sh --dist   # serves the published build instead (no comments)
```

The local pages talk to the **same Supabase project** — there is only one.
So the local admin panel edits live data: codes you generate and exams you
import land in the real database. That is a deliberate choice (one project,
one source of truth), so remember to clean up test codes and test imports
afterwards — both are deletable from the panel.

Note: locally the admin panel is at `/admin/`; in production it is at the
`ADMIN_PATH` directory.

---

## If it has to be rebuilt from nothing

1. New Supabase project → keys into `assets/config.js`
2. Enable anonymous sign-ins
3. Run `supabase/setup.sql`
4. Run `supabase/seed/parts/b1-*.sql`
5. Create the admin user, flip `is_admin`
6. Run `supabase/verify.sql` — expect a green verdict row
7. Cloudflare → connect the repo, build command `./tools/build_dist.sh`
8. Upload images from the panel's **Dateien** tab
9. Optional: deploy the writing-correction Edge Function
   ([`14-writing-correction.md`](14-writing-correction.md))
