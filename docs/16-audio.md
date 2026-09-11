# Audio for Hörverstehen

A third of every telc exam is listening. The source PDF has no audio, so the
section showed the transcript next to the answer — useful for reading, useless
for practising. This is the plumbing for real audio. **The recordings
themselves are the one part still missing.**

## How it behaves

With a file attached, the section shows a player instead of the transcript:

- A single **Hörtext abspielen** button, no scrub bar, no seeking.
- A play counter — `audioPlays`, default 1. telc plays some parts once and
  some twice; set it per section.
- When the plays are used up the button locks.
- The transcript is hidden during the exam and **appears in the result
  screen** afterwards, where reading it is the point.

Without a file nothing changes: the old behaviour and the "no audio in this
template" note stay exactly as they were, so adding audio one section at a time
is safe.

## Attaching a file

1. **Put the recordings somewhere** — one file per section:
   ```
   audio/m01-hv1.mp3
   audio/m01-hv2.mp3
   …
   ```
2. **Upload to the private bucket:**
   ```bash
   export SUPABASE_URL=https://xxxxxxxx.supabase.co
   export SUPABASE_SERVICE_KEY=eyJ…
   python3 tools/upload_audio.py audio/
   ```
   The bucket `exam-audio` is created **private**. Audio is exam content, like
   the questions — a public bucket hands it to anyone with the URL.
3. **Link each file to its section** — the panel's **Hörtexte** tab lists every
   Hörverstehen section with its test, how many questions it has, and whether a
   file is attached. Type the filename, set the number of plays, save.

   Or from SQL:
   ```sql
   select admin_set_section_audio('<section uuid>', 'm01-hv1.mp3', 1);
   ```

In the paste format, a section can carry it directly:

```
Hörtext: m01-hv1.mp3
Wiedergaben: 2
```

## Where the recordings come from

Not solved here, and it is a real decision:

| Option | Notes |
|---|---|
| **Text to speech** | Cheapest and fastest. Modern German TTS is good enough for B1 practice. Multi-speaker dialogues need one voice per speaker to be worth anything. |
| **Record them** | Native speakers reading the transcripts. Better and more expensive; the right answer if you sell this seriously. |
| **License** | If you resolve the content licensing question with telc, the official audio comes with it. |

There are 47 Hörverstehen sections across the 16 tests. Whatever the route, it
is a content project, not a code one — the app is ready for the files.

## Protection

Same as the page images: a private bucket and a signed URL that expires,
fetched per playback. A subscriber can still capture the stream — nothing
prevents that — but the files are not reachable without an active subscription.

## Tested

`tests/browser.mjs` drives the real player in Chromium against a real sound
file: the player appears, it says how many plays are left, the transcript is
hidden during the exam, the button locks after the configured number of plays,
and the transcript appears in the result screen afterwards.
