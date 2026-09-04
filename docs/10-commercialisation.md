# From project to paid product

> **Status — partly superseded.** Decisions now taken: Supabase, manual access codes, full content protection.
> See [11-online-architecture.md](11-online-architecture.md) for the new design.
> What follows describes the code as it stands today.

Written against the stated goal: **sell this to students, with an admin panel
that controls payments and subscriptions and gives a view of the data.**

Short version: the exam-simulation engine is genuinely good and worth building
on. Three things stand between it and a sellable product, in this order —
**content you are allowed to sell**, **the features free competitors already
have**, and **a backend**. The third is the easiest of the three.

---

## The blocking issue: content licensing

`Doku/B1 Telc.pdf` is a scan of published telc practice material. The build
pipeline itself carries the evidence — `tools/telcpdf.py:9` strips a third
party's watermark out of the page footer:

```python
FOOTER = re.compile(r'ABDELLAH\s*FARHAN|LANGUAGE\s*Test|^\d{1,3}$')
```

telc's own terms are explicit that their exam and practice materials are
copyright-protected, that reproduction, storage and distribution require written
permission, and that use outside a licensed exam is prohibited. All 912
questions in `data/` are derived works of that material.

What this means practically:

- **Free and private** — a personal study tool — is a low-risk situation.
- **Public and free** on GitHub Pages is already redistribution, including the
  11 MB PDF itself, which is currently downloadable straight from the deployed
  site (see [09-code-review.md](09-code-review.md), finding #7).
- **Charging money for it** turns that into commercial infringement of a rights
  holder that licenses this material for a living. A takedown would remove your
  entire product catalogue at once, because every one of the 16 tests comes from
  the same source.

This is not a reason to abandon the project — it is a reason to separate the
*engine* from the *content*, which is a good idea anyway. Three routes:

1. **License it.** telc runs a partner and licensing programme. Ask what digital
   practice-material licensing costs. If it is affordable, you get the strongest
   position available: legitimately licensed official content.
2. **Commission original content.** Hire a *Deutschlehrer*/telc examiner to write
   telc-*format* tests. The format — 5+5+10 reading, 10+10 Sprachbausteine,
   5+10+5 listening, one letter, that point table — is not protected; the
   specific texts and questions are. Budget roughly €150–400 per complete
   original Modelltest. Ten tests is a real but one-time cost, and the result is
   an asset you own outright and can also license to others.
3. **Generate and have it reviewed.** Draft texts and items with an LLM against
   the telc format, then pay a qualified teacher to review and correct. Much
   cheaper per test; quality depends entirely on the reviewer being real.

The pipeline in `tools/` keeps its value under all three routes — it is a
PDF-to-structured-data converter, and `data/*.json` is a clean, documented
contract ([04-data-format.md](04-data-format.md)). Point it at content you own
and nothing else in the codebase changes.

**Do this before building payments.** Otherwise you build a shop for goods you
cannot sell.

---

## Where the product stands against the market

Researched September 2026. Prices are as advertised and move around.

| | This project | DeutschExam | ExamDeutsch | Sprachprep | LevelKraft | SmarterGerman |
|---|---|---|---|---|---|---|
| Price | — | from €6.99 one-time | €29.99 / 3 months | free tier + premium | free | $29.90 / month |
| telc B1 mock tests | **16** | 100 across A1/B1/B2 | yes | 1/month free, unlimited paid | yes | course-based |
| Real exam timing & weighting | **yes** | yes | yes | yes | partial | n/a |
| **Listening audio** | **no** | yes | yes | yes | **yes, free** | yes |
| **AI writing correction** | **no — self-assessed** | yes, telc rubrics + handwriting OCR | yes | yes | free "exam check" | — |
| **Speaking practice** | **no** | yes — live AI conversation, 250 topics | — | — | **yes, free** | — |
| Mistake-based drilling | **yes** | — | — | readiness score | — | — |
| Works offline / installable | **yes** (once fixed) | no | no | no | no | no |
| Accounts / cross-device | **no** | yes | yes | yes | partial | yes |

Read the bold entries together and the picture is uncomfortable but clear:

**Free competitors currently offer more than this app does.** LevelKraft gives
away telc B1 model tests *with audio and speaking practice* and a free writing
check, with no login. Today a student choosing between them and this app has no
reason to pay.

The three columns where this project wins are real, though, and none of the
competitors have all three: **a faithful full-length exam simulation** (correct
blocks, correct 90/30/30 timing, correct point weighting, correct pass mark),
**mistake-driven drilling that rebuilds the context a question needs**, and
**a genuinely offline, installable app**. That last one matters more for this
audience than it looks — many telc B1 candidates are studying on prepaid mobile
data, in Wohnheime with bad wifi, on the U-Bahn.

That is a defensible position, but only once the table stops having "no" in the
rows everyone else has "yes" in.

---

## The feature gaps that have to close

Ranked by how much each blocks a paid launch.

### 1. Listening audio — **blocking**
Hörverstehen is 75 of 225 points, a third of the written exam, and the app
cannot train it at all. The section currently shows the statements next to their
answers, which is honest but is not practice. Competitors give this away free.

Options: record the transcripts with native speakers (best, and reusable),
or use high-quality German TTS (adequate for B1 comprehension, near-zero cost,
but the exam's dialogues have overlapping speakers and background noise that TTS
will not reproduce). Either way `data/*.json` needs an `audio` field per section
and the app needs a player with the exam's one-play-through convention.

### 2. AI writing correction — **the biggest single upgrade**
Today the student grades their own letter against three telc criteria. A B1
learner cannot reliably judge their own *Formale Richtigkeit* — the errors they
can see are not the ones costing them points. This is the weakest link in the
app ([07-scoring.md](07-scoring.md)).

An LLM does this well and it is the clearest thing to charge for: submit the
letter, get a score against each telc criterion with the reasoning, inline error
marking, a corrected version, and a note on which of the four required content
bullets were missed. Cost per correction is cents; students perceive it as the
main paid feature. Competitors have already made it table stakes — one of them
even accepts a photo of a handwritten letter and OCRs it, which is worth copying
because the real exam is handwritten.

### 3. Speaking — **large, and it is where the money is**
telc B1 has an oral exam this app does not touch. It is also the part students
fear most and the hardest to self-study. A voice-based practice partner —
present yourself, discuss a topic, plan something together, all in the telc B1
oral format, with feedback on fluency and vocabulary — is the feature students
will actually pay for. It is a bigger build than the other two, but it is the
strongest differentiator available.

### 4. Accounts and sync — **required by the business model, not the student**
Everything lives in `localStorage`. Clear your browser and months of progress
are gone; switch from phone to laptop and it does not follow. Neither is
acceptable once someone is paying, and there is no way to gate content without
identity.

### 5. Explanations — **cheap, high perceived value**
160 of 912 questions have an `explain`, and those are one generated line
("Das Wort lautet: AUF"). Students want to know *why* B is right and C is wrong.
Generating these once with an LLM and having them reviewed is a one-off job that
lifts every question in the catalogue.

---

## What the backend has to do

There is no backend today. The app is static files plus `localStorage`
([02-architecture.md](02-architecture.md)). Four jobs force one to exist:

1. **Identity** — one account, many devices.
2. **Entitlement** — decide whether this user may open test 7 right now.
3. **Money** — subscriptions, renewals, failed payments, refunds, invoices, VAT.
4. **Truth** — progress that survives a cleared browser, and the aggregate data
   the admin panel exists to show.

### The architectural consequence, stated plainly

Right now every question and every answer is in files the browser downloads. If
you gate content, **it cannot stay in the static bundle** — anyone can open
DevTools and take `data/modell-07.json`. Paid tests have to be served per
request against a valid session, with the answer key withheld until submission.

That is a real change to the app's shape and the main reason to do it *before*
adding features, not after. Offline then needs a deliberate design: cache paid
content for entitled users only, and re-check entitlement when the connection
returns.

### Recommended stack

For a solo developer who wants this running in weeks rather than months:

| Need | Choice | Why |
|---|---|---|
| Auth, DB, storage, API | **Supabase** (Postgres + Row Level Security) | Keeps the frontend static; RLS expresses "you may read this test if you have an active subscription" as a database policy instead of an API layer |
| Payments | **Stripe** (Checkout + Customer Portal + Billing) | Handles SCA, EU VAT, dunning, invoices, and cancellations without you writing any of it |
| Server logic | Supabase Edge Functions | Stripe webhooks, serving gated content, LLM calls |
| AI features | Claude API | Writing correction, explanations, speaking feedback |
| Admin panel | A separate small app | See below |

Firebase is a reasonable substitute. Rolling your own auth and billing is not —
that is the part where mistakes cost real money and real trust.

### Schema sketch

```sql
profiles            id ▸auth.users, email, display_name, locale,
                    target_exam_date, created_at

plans               id, name, stripe_price_id, amount_cents, currency,
                    interval, features jsonb, active

subscriptions       id, user_id ▸profiles, plan_id ▸plans,
                    stripe_subscription_id, status,       -- trialing|active|past_due|canceled
                    current_period_end, cancel_at_period_end, created_at

payments            id, user_id, stripe_payment_intent, amount_cents,
                    currency, status, refunded_cents, created_at

tests               id, slug, title, level, is_free, published,
                    content jsonb            -- the modell-NN.json shape
                                             -- answer keys live in a separate
                                             -- table or column, never sent
                                             -- with the questions

attempts            id, user_id, test_id, block_id,
                    started_at, submitted_at,
                    points, max_points, pct, answers jsonb

mistakes            id, user_id, test_id, section_id, item_id,
                    wrong_count, last_seen_at

writing_submissions id, attempt_id, text, ai_feedback jsonb,
                    criteria_scores jsonb, reviewed_by

admin_audit_log     id, admin_id, action, target_type, target_id,
                    detail jsonb, created_at
```

Two notes. `attempts` and `mistakes` are the same shapes already in
`localStorage` — the migration is mostly moving `load`/`save` behind an async
client, so keep those four functions as the seam. And `admin_audit_log` is not
optional: the moment a human can grant free access or issue a refund, you need a
record of who did what.

---

## The admin panel

A separate application, not a route inside the student app. Different auth,
different risk profile, and it must never ship in the bundle a student
downloads.

### Views

**Dashboard** — MRR and its change, active / trialing / past-due / cancelled
counts, new signups, conversion from free to paid, churn, failed payments needing
attention, daily and weekly active users.

**Users** — search by email or name; per user: profile, subscription status and
history, payments, every attempt with scores, mistake list, writing submissions.
Actions: grant or revoke access manually (teachers, testers, complaints), reset
progress, extend a period, issue a refund, add an internal support note.

**Subscriptions** — filter by status; cancel, comp a free period, change plan,
see which are about to renew and which are in dunning.

**Payments** — transactions, refunds, failed charges with the retry state,
export for accounting. Stripe holds the truth; this reads it back so you are not
living in the Stripe dashboard.

**Content** — the tests: create, edit, publish/unpublish, mark free or paid,
order them. This is where you upload a newly built `modell-NN.json`. Being able
to unpublish a broken test in one click is worth building early.

**Analytics — the view that only a backend can give you.** Per question: how
many students answered it, what fraction got it right, which wrong option they
chose. That tells you which questions are broken, which are too easy to be worth
keeping, and which distractor is doing the work. It also tells you where students
abandon a test. Nothing in the current localStorage-only design can produce this,
and it is the data that makes the *content* better over time — the thing you are
actually selling.

**Support** — a queue of writing submissions flagged for human review, if you
offer teacher feedback as a higher tier.

### Build it with

Given Supabase: **Retool**, **Appsmith**, or Supabase Studio with SQL views will
get you a working panel in days rather than weeks, and an admin panel is a place
where "boring and fast" beats "custom". Move to a hand-built Next.js panel only
when a workflow genuinely needs it. Whatever you pick: separate login, MFA, a
role check on every query, and every mutating action written to
`admin_audit_log`.

---

## Pricing

Competitors sit between €6.99 one-time and €29.90/month, with the most relevant
data point being **€29.99 for three months** — pitched explicitly at one
preparation cycle, which is how this audience actually buys. They are not
subscribing to a habit; they are buying a pass for one exam on one date.

A structure that fits that:

| Tier | Price | Contents |
|---|---|---|
| Free | €0 | 2 full Modelltests, mistake drilling, offline. No account needed |
| Exam pass | **€24.99 / 3 months** | Everything: all tests, audio, AI writing correction, speaking practice |
| Monthly | €11.99 / month | Same, for people who want one month |
| Teacher / school | per seat, annual | Class dashboard, assign tests, see student results |

Make the free tier genuinely good. It is what beats LevelKraft's free offering
into a comparison you win, and the mistake-drill is the feature students will
tell each other about.

The teacher tier is worth more attention than it usually gets. *Integrationskurs*
and *Sprachschule* teachers prepare groups of students for exactly this exam,
they have budget, they buy per class, and they churn far less than individuals.
The admin panel you are already building is most of a teacher dashboard.

---

## Sequence

Do not build in the order of what is fun.

**Phase 0 — before anything else.** Resolve the content question. Talk to telc
about licensing, or commission the first three original Modelltests. In
parallel, take `Doku/` out of the deployed tree. Nothing below matters until
this is settled.

**Phase 1 — make what exists correct.** Fix offline (findings #1, #2), fix the
plural, fix the README's dependency list, add the data validator to CI. About a
day's work. It is also the point to split `app.js` into modules
([09-code-review.md](09-code-review.md)) — cheaper now than after the backend
lands.

**Phase 2 — identity and money.** Supabase auth, move progress off
`localStorage` behind the same `load`/`save` seam, Stripe Checkout, gated content
served per request, admin panel v1 (users, subscriptions, payments, manual
grant). This is the phase that turns it into a business.

**Phase 3 — the features people pay for.** AI writing correction first — best
ratio of value to effort. Then listening audio. Then explanations for all 912
questions.

**Phase 4 — the differentiator.** Speaking practice. Teacher tier and class
dashboard.

The engine you have is a real asset and Phase 1 is a day. The order above exists
because Phase 0 can invalidate everything built on top of it, and Phase 2 changes
the app's shape enough that features built before it get rewritten.

---

## Sources

- [telc Prüfungsregularien (PDF)](https://www.telc.net/fileadmin/user_upload/pdfs/AGB_Pruefungsordnung/9994-P00-150010.pdf)
- [telc Training AGB (PDF)](https://www.telc.net/fileadmin/user_upload/pdfs/AGB_Pruefungsordnung/Training_AGB.pdf)
- [DeutschExam — telc/Goethe AI mock tests](https://deutschexam.ai/)
- [ExamDeutsch](https://examdeutsch.com/)
- [Sprachprep](https://sprachprep.com/)
- [LevelKraft — telc B1 Modelltest kostenlos](https://levelkraft.de/blog/telc-b1-modelltest-kostenlos-alle-pruefungsteile)
- [telc-trainer.de](https://telc-trainer.de/telc-b1-modelltest)
- [SmarterGerman](https://smartergerman.com/courses/)
- [DeutschAkademie — exam preparation courses](https://www.deutschakademie.de/en/online-courses/exam-preparation-courses/)
