# Capacity and the waiting list

Two numbers in the admin panel decide how many people the app lets in.
When either is reached, new users land on a waiting list and see their
place in the queue.

| Setting | What it caps |
|---|---|
| `Aktive Nutzer max.` | how many people hold a live subscription at once |
| `Neue pro Tag max.` | how many *new* people get in on a given day |

`0` means no limit. Both are enforced in `redeem_code()` — the one place a
subscription can be created — so there is no path around them.

**A waitlisted code is not spent.** Someone who arrives at a busy moment
keeps their code and redeems it when a place opens. Anything else would
punish a paying customer for the timing of their arrival.

## What each number actually costs

Everything below is on the free tiers. Ranked by which runs out first.

### 1. Writing correction — the only thing that costs real money

Each correction is one Claude request. With `claude-opus-5` at
[$5 / $25 per million tokens](https://docs.claude.com/en/docs/about-claude/pricing),
a B1 letter (~2.2K input, ~3K output including thinking) works out to
roughly **$0.09 per correction**.

`subscriptions.writing_quota` defaults to **20**, so one subscriber can
cost at most **≈ $1.80** in Claude spend — and most will use far fewer.

| Active users | Worst case (all 20 used) | Realistic (~5 used) |
|---|---|---|
| 50 | $90 | $23 |
| 150 | $270 | $68 |
| 500 | $900 | $225 |

This is the number to watch. It scales with people, and nothing else on
the stack does at this size.

*If it gets uncomfortable:* lower `output_config.effort` in
`supabase/functions/correct-writing/index.ts` from `high` before switching
models — grading against fixed criteria is a bounded task, not a hard
reasoning problem. Measure the grades before and after; don't assume.

### 2. Supabase egress — 5 GB/month, and audio will eat it

[Supabase Free](https://supabase.com/pricing) gives 500 MB database,
5 GB egress, 50,000 MAU, and pauses a project after 7 days of inactivity.

Today, without recordings, one exam sitting moves ~0.4 MB (≈30 KB of JSON
plus images). That is roughly **12,000 sittings a month** — not a
constraint.

**Once the Hörverstehen recordings exist, this becomes the binding limit.**
A full listening part is ~25 minutes of audio; at 64 kbps that is ~12 MB
per sitting, which is about **400 sittings a month** on the free plan.

Two ways out when that day comes, in order of preference:

1. **Serve the audio from Cloudflare R2**, which has no egress charge.
   Supabase Storage keeps the images; the mp3s move. This is the real fix.
2. Encode speech at 48 kbps mono and re-measure.

### 3. Cloudflare Workers — not a constraint

100,000 requests/day on the free plan, and the app is a cached PWA: a
returning student costs a handful of requests. At any user count that
Supabase can serve, this is nowhere near the limit. The
[paid plan](https://developers.cloudflare.com/workers/platform/pricing/)
is $5/month if it ever matters.

### 4. Database size, MAU — not a constraint

Attempts and mistakes are small rows. 500 MB and 50,000 MAU are far away.

## Recommended starting point

**`Aktive Nutzer max. = 50`, `Neue pro Tag max. = 10`.**

Not because 50 is where anything breaks — it isn't. Because:

- worst-case Claude spend stays under $90 while you learn what usage
  actually looks like;
- the waiting list is *visible* from day one, which is half the point of
  having one;
- the daily cap turns a sudden rush into a queue you can watch instead of
  a bill you find later.

Raising a limit takes one field and a click. Explaining to paying
customers why the app got slow does not.

Raise it once you have a week of real numbers — the Übersicht page shows
active users, new today, and how many are waiting.

**Revisit before the recordings ship.** At that point either move audio to
R2 or drop the active cap to ~60, whichever comes first.
