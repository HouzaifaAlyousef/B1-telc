# Going online — architecture

This document supersedes the "no backend" decision in
[01-overview.md](01-overview.md). It describes the shape of the app once it has
accounts, paid access, multiple exam levels, and admin-managed content.

Read [10-commercialisation.md](10-commercialisation.md) first — it argues *why*
a backend becomes necessary. This document decides *what* it looks like.

## The decision that shapes this one

Content protection was chosen at the strongest setting: **questions are served
without answer keys, and grading happens on the server**. Everything below
follows from that, including the parts that hurt.

### What it costs: offline

The current headline feature is that the app works with no network. Full
protection contradicts it directly — if the questions and their answers never
reach the device, there is no exam to sit on a plane.

The resolution is to split the two things the app does:

| Activity | Network | Why |
|---|---|---|
| Sitting an exam | **required** | Questions are fetched per attempt; grading is a server call |
| Reviewing a finished attempt | offline | The result, with correct answers, is already on the device |
| Reading resources | offline | Cached after first read |
| Free sample tests | offline | Nothing to protect |

This is an honest trade, not a regression: offline exams are currently broken
anyway (findings #1 and #2 in [09-code-review.md](09-code-review.md)), and a
student sitting a timed 90-minute mock exam is almost always at home.

## Stack

| Need | Choice |
|---|---|
| Auth, DB, storage, API | Supabase (Postgres + RLS) |
| Server logic | Postgres functions (`security definer`), Edge Functions where an external call is needed |
| Payments | none for now — access codes are issued by hand |
| Frontend | the existing static app, plus an async data layer |
| Admin panel | a separate small static app against the same database |

## Access without accounts

There are no emails and no passwords. The flow is:

1. A student pays you, by whatever means, outside the app.
2. You generate an **access code** in the admin panel: which levels it opens,
   how many days, how many devices.
3. The student enters it once. The app signs in anonymously (a real
   `auth.users` row), calls `redeem_code()`, and gets a session.
4. From then on the session refreshes itself. The code is never needed again.

The code is a **redemption token, not a credential** — this matters. If the
code were the credential, revoking it would be the only lever you had, every
device would hold your secret, and you could never tell two students apart.

### The sharing problem

One student can hand their code to twenty friends. This is the single largest
threat to the revenue model, and it is why `access_codes.max_devices` exists:

- A code is redeemable **once**. It binds to the first account that uses it.
- That account may register at most `max_devices` devices (default 2).
- `register_device()` refuses the third and returns `device_limit`.
- The admin panel shows the device count per user, so a code being passed
  around is visible rather than silent.

Device identity is a fingerprint stored in the browser. It is not
tamper-proof — someone determined will clear it and re-register. The cap makes
casual sharing inconvenient, which is what it is for. Treat it as friction, not
as a lock.

### Losing access

A student who clears their browser loses the session and consumes a device
slot on the next one. When the slots run out they contact you and you reset
their devices from the panel. That is a support burden proportional to how
many students you have, and it is the price of not collecting emails. Adding
optional email recovery later is a small change; the schema does not prevent it.

## Where the protection actually lives

Not in the frontend. In two places in the database:

**`item_answers` has row-level security enabled and no policy.** There is no
combination of client calls, valid token, or crafted query that reads it.
Answer keys are simply not reachable from outside the server. Compare with
today, where all 896 answer keys sit in `data/modell-*.json`, downloadable by
anyone.

**`submit_attempt()` is the only way to be graded.** It re-checks entitlement
server-side, computes the score from `item_answers`, writes the attempt, and
only then returns the correct answers alongside the results. The client cannot
write its own score: the insert policy on `attempts` requires `points is null`.

Everything else — which tests are visible, which resources, which sections —
is an RLS policy calling `has_access(user, level)`. Entitlement is expressed
once, as data, rather than being re-checked in every code path.

## Multiple levels

The existing data format turned out to be level-agnostic, which is lucky. The
five section formats (`matching`, `mc`, `wordbank`, `truefalse`, `writing`) are
primitives, not B1 concepts, and per-test `blocks` already carry their own
timings — so an A1 exam with different parts and a different clock needs no new
machinery.

What is new is a `levels` table and `tests.level_id`. Entitlement is per level:
a code opens `{'b1'}` or `{'a1','a2'}`, and every content policy checks
membership.

New formats may still be needed for level-specific task types. Adding one means
a renderer in the frontend and a `format` value — it does not touch the schema.

## Content: paste, review, publish

Exams arrive as raw text pasted into the admin panel, not as PDFs. That is a
considerably better position than the current pipeline, which reverse-engineers
a specific scanned layout in `tools/telcpdf.py` and would need rewriting for
every new source.

The `imports` table holds the pipeline as data:

```
raw_text  →  parsed (jsonb)  →  you review and correct  →  applied
 draft          parsed              needs_review            applied
```

Parsing happens in the browser, deterministically, against a documented paste
format — no API key, no cost, and no invented questions. Unstructured source
text is converted to that format outside the app, which is where an LLM belongs;
what reaches the database is only what you saw in the preview. Keeping
`raw_text` means a bad parse is re-runnable without re-pasting. The format is
proven against all 16 existing tests by a round-trip test.

`resources` is the simpler sibling: text you paste, published per level, read
inside the app at any time.

## Admin panel

A separate static app, not a route in the student app — different audience,
different risk, and it should be deployable somewhere else entirely.

It needs:

- **Users** — who they are, when they were last seen, devices, attempts, scores
- **Subscriptions** — extend, shorten, revoke; the panel writes
  `current_period_end` directly
- **Codes** — generate, print, see which are unused, revoke
- **Content** — imports, review queue, publish/unpublish, resources
- **Audit** — `admin_audit_log`, written on every privileged action

Access is `profiles.is_admin`, enforced by RLS, not by hiding a URL. Supabase
Studio is not a substitute: it grants full table access with no audit trail and
no concept of "extend this subscription by 30 days".

Reads go straight through PostgREST — the `admin_all` policy allows them and
reading needs no audit. **Writes never do.** Every change goes through an
`admin_*` function that checks `is_admin()` and writes `admin_audit_log` in the
same transaction. If the panel wrote to `subscriptions` directly, an action
could happen with no trace; routing writes through functions makes the trail
impossible to skip rather than merely expected.

Admins sign in with email and password, not an access code — a separate path
from students, using an account you create in the Supabase dashboard. Promote
it once by hand:

```sql
update profiles set is_admin = true where id = '<the auth.users id>';
```

The panel lives in `admin/` and is deployed separately from the student app.

## What is not in the schema yet, and should be considered

**Audio for Hörverstehen.** One third of every telc exam is listening, and the
app currently shows the transcript with the answer because the source PDF has
no audio (see the README). Selling an exam trainer where a third of the exam
cannot be practised is a real product gap — larger, arguably, than anything
else in this document. Text-to-speech is the cheap path.

**AI writing correction.** `writing` sections are self-assessed today. A
submitted `Schriftlicher Ausdruck` returned with a graded correction against
the official criteria is the highest-value thing this product could offer, and
it is the one feature a PDF genuinely cannot do.

**Spaced repetition over `mistakes`.** The data is already being collected and
is currently only counted. Drilling what a student got wrong, on a schedule, is
a small feature on top of an existing table.

**Stripe.** `subscriptions.source` distinguishes `manual` from `stripe` so that
adding automated billing later does not require a migration of live data. Until
then, every renewal is a message you answer by hand — fine at twenty students,
a part-time job at two hundred.

## Content licensing — unresolved

[10-commercialisation.md](10-commercialisation.md) states the problem and it
has not changed: the existing 16 tests are derived from telc's material, and
charging for them is commercial infringement of a rights holder that licenses
this material for a living. The chosen path is to start with what exists and
replace it with original content over time.

The architecture supports that: content is rows, not files, and swapping a test
is an admin action rather than a rebuild. The risk is concentrated rather than
removed — a takedown reaches every test at once, because they share one source.
This should be resolved before the first payment, not after.

## Deploying

The frontend is still a folder of static files, but **`data/` must never be
deployed again**. It holds all 896 answer keys, and shipping it would defeat
the entire protection design regardless of what the database does. It stays in
the repository as the source the exporter reads, and nothing more.

What ships: `index.html`, `manifest.webmanifest`, `sw.js`, `assets/`. What does
not: `data/`, `Doku/`, `tools/`, `docs/`, `supabase/`, `tests/`.

`assets/config.js` carries the Supabase URL and anon key. Neither is a secret —
the anon key is designed to be public and RLS is what protects the data — but
they are per-project, so the deployed copy needs your own values.

The page images (`data/img/`) belong in a **private** Supabase Storage bucket
named `exam-images`. They are exam content: `sections.config.bankImage` holds
the object path, and the app fetches a signed URL at render time.

## Order of work

1. **Schema and functions** — `supabase/migrations/`. Done.
2. **Migrate the existing 16 tests** into `tests`/`sections`/`items`, with the
   896 answer keys landing in `item_answers` and nowhere else.
3. **Data layer in the app** — `load`/`save` in `assets/app.js:46-52` become
   async and talk to Supabase. Keep those two functions as the seam.
4. **Code redemption screen** — the app's new entry point.
5. **Server-side grading** — replace the client comparison at
   `assets/app.js:247` and `:574` with `submit_attempt()`.
6. **Admin panel** — users, subscriptions, codes first; content later.
7. **Levels** — add A1/A2 rows and the level picker.
8. **Import pipeline** — paste, parse, review, publish.

Steps 2, 3 and 5 are one change in practice: the moment answer keys leave the
JSON files, the client can no longer grade, and the app must already have a
session to ask the server. They were done together.

### Status

Steps 1, 2, 3 and 5 are done and tested. `supabase/tests/run.sh` builds a
Postgres from the migrations and asserts the access rules and grading against
it; `tests/run.sh` drives the real app in Chromium against a stub API built
from that same database.

Not yet verified against a live Supabase project: the PostgREST query strings
in `assets/api.js`, anonymous sign-in, and Storage signing. Those are the parts
that depend on the hosted service rather than on Postgres, and they are the
first thing to exercise once a project exists.

Steps 6, 7 and 8 are done too: the admin panel is in `admin/`, the student app
switches between the levels a subscription covers and remembers the choice, and
pasted text becomes an exam through `admin/parse.js` and `admin_apply_import()`
— see [12-import-format.md](12-import-format.md).

Still open: audio for Hörverstehen, AI correction of the writing task, spaced
repetition over `mistakes`, and Stripe.
