# Security review

What was checked before launch, how, and what came out of it. Re-run it with
`./supabase/tests/run.sh && ./tests/run.sh` — the checks below are tests, not a
one-time report.

## Method

Two audits, both empirical. Reading policies tells you what was intended;
running as an attacker tells you what is true.

### Permissions — `supabase/tests/05_permissions.sql`

Acts as an ordinary student with a valid session and tries 23 things they
should not be able to do, then checks **the resulting state** rather than
whether an error was raised.

That distinction matters and it caught a false alarm. An `UPDATE` blocked by
RLS does not raise — it matches zero rows and returns success. A first pass
that treated "no exception" as "breach" reported six holes that did not exist.
Every assertion now verifies the data afterwards.

What is verified as blocked: reading `item_answers`; reading another student's
subscription, profile, devices, attempts or writing feedback; reading access
codes, the audit log or import drafts; writing a score into `attempts`;
inserting an attempt that already carries points; extending one's own
subscription; setting `is_admin` on oneself; publishing or freeing tests;
editing question text; deleting tests; touching the audit log; minting an
access code; writing one's own writing feedback; and calling
`admin_create_codes`, `admin_users`, `admin_log` or `writing_finish`.

### XSS — `tests/xss.mjs`

Injects `<img src=x onerror=…>` and a `"><script>` breakout into **every**
string that reaches a screen, then loads the real pages in Chromium and checks
whether anything executed.

Student app: test and level titles, block titles and hints, instructions,
section notes, question text, options, the answer bank, resource titles and
bodies, the answers and explanations returned after grading, and the whole AI
correction — criterion names, reasons, error text, corrections, summary.

Admin panel: display names, notes, access codes, resource titles and bodies,
and audit log entries, injected into the real Postgres and read back through
the panel's own queries.

Nothing executed anywhere. The payload renders as visible text.

## Design properties the tests confirm

**Answer keys are unreachable.** `item_answers` has RLS on and no policy, and
its privileges are revoked from `authenticated` and `anon`. There is no query
that reaches it. Grading is `submit_attempt()`, which returns the answers only
after writing the attempt.

**Scores cannot be self-issued.** The insert policy on `attempts` requires
`points is null`, and no update policy exists for a non-admin. The only writer
of a score is `submit_attempt()`.

**Writing grades cannot be self-issued.** `writing_finish` and `writing_fail`
are revoked from `authenticated` outright — only the Edge Function's service
role can write a correction result. The model returns letters, never numbers,
and the letter-to-points conversion happens in SQL from the section's stored
grade table.

**Admin actions cannot happen silently.** Every `admin_*` function calls
`admin_guard()` and writes `admin_audit_log` in the same transaction. The panel
never writes to a table directly.

## Known and accepted

**Device binding is friction, not a lock.** The fingerprint lives in the
browser. Someone determined can clear it and re-register, consuming a device
slot. `max_devices` makes casual code-sharing inconvenient, which is its
purpose. Watch the device counts in the panel.

**The anon key is public.** It is designed to be. Everything above holds with
an attacker who has it — that is what these tests assume.

**A subscriber can copy what they paid for.** Content protection stops
non-subscribers and casual extraction; it cannot stop a paying student from
screenshotting 16 tests. No design can.

**The service_role key must never leave the server.** It bypasses RLS
entirely. It belongs in Supabase secrets for the Edge Function and in your
shell for `tools/upload_images.py` — never in `assets/config.js`, never in git,
never in a browser.

**`data/` must never be deployed.** `tools/build_dist.sh` refuses to build if
it, or any file containing answer keys, reaches the output. Deploy only through
that script.

## Not covered

- No penetration testing of Supabase itself.
- The tests run in CI on every push (`.github/workflows/tests.yml`), but CI has
  never executed against a hosted Supabase project — only the local Postgres.
- Rate limiting on `redeem_code` stops hammering from one client, not a
  distributed attack. Eight failed attempts within fifteen minutes lock the
  entry — counted per account *and* per device fingerprint, so clearing one is
  not enough — and even a correct code is refused while locked, so an attacker
  cannot grind until they hit. Someone creating fresh anonymous accounts and
  rotating fingerprints gets past it; that is Supabase's own request limits to
  handle, not ours. `07_rate_limit.sql` covers the lockout, that a second
  student is unaffected, that repeated *successful* entries never lock anyone
  out, and that the window expires on its own.
- Nothing about payment handling, because there is none yet.
