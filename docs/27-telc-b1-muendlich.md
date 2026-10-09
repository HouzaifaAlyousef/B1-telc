# telc B1 Mündliche Prüfung (Speaking Module)

Closing the speaking gap documented in [01-overview.md](01-overview.md),
"The three exam parts, and one honest gap".

---

## 1. Context & The Honest Gap Resolved

Previously, `docs/01-overview.md` reported:
> *Mündliche Prüfung (speaking) | Not covered at all*  
> *The speaking part is simply absent — telc B1 has an oral exam and this app does not touch it.*

With the feed material supplied in `Doku/feed pdf/telc-b1 Mündlich/`, the
speaking component is now fully extracted, proofread, and organized into a
structured study and examination module under `Doku/telc-b1-muendlich/`.

---

## 2. Structure of the Oral Exam (75 Points)

| Part | Title | Format & Timing | Points | Target Skills |
| :--- | :--- | :--- | :--- | :--- |
| **Teil 1** | Kontaktaufnahme | Paired intro, ca. 3 min | **15 pts** | Personal profile (8 prompts), reciprocal questions, spontaneous examiner follow-ups. |
| **Teil 2** | Gespräch über ein Thema | Paired presentation & debate, ca. 5–6 min | **30 pts** | 5-step presentation: text summary, personal opinion, past experiences, home country contrast, partner Q&A. |
| **Teil 3** | Gemeinsam etwas planen | Interactive task planning, ca. 5–6 min | **30 pts** | Negotiating an event/task along 4–5 Leitpunkte: proposals, polite disagreement, counter-proposals, task assignment, agreement. |
| **Total** | | **ca. 15 min (pair)** | **75 pts** | **Pass mark: ≥ 45 pts (60 %)** |

---

## 3. Module Contents in `Doku/telc-b1-muendlich/`

```
Doku/telc-b1-muendlich/
├── README.md                           ← Master index & overview
├── 00-pruefungsablauf-und-bewertung.md ← Regulations, scoring matrix (4 criteria), time limits
├── 01-teil-1-kontaktaufnahme.md        ← 8 Leitpunkte, B1 profiles, partner Q&A dialogues
├── 02-teil-2-themenkatalog.md          ← 27 paired topics, prompt cards, B1 presentations, photos
├── 03-teil-3-gemeinsam-planen.md       ← Master Redemittel, 14 complete planning scenarios
├── _vorlage_muendlich.txt              ← Standardized text template for oral tests
└── img/                                ← 55 optimized portrait & topic images (< 300 KB each)
```

---

## 4. Linguistic Quality Review

The source scans in `feed pdf/telc-b1 Mündlich/` included student transcripts
with spelling and grammatical slips (*„Hauze“*, *„Geburstag“*, *„Geprächspartner“*,
*„schencken“*, *„an einem Arbeitstags“*, *„Freundin vo Ihnen“*).

All content underwent rigorous native German linguistic proofreading:
- Every typo and phonetic spelling error was corrected.
- Sentence structures were upgraded to authentic, CEFR B1-level German with appropriate connectors (*deshalb, obwohl, trotzdem, einerseits ... andererseits*).
- Complete model presentations and dialogues were provided for every single task and scenario.

---

## 5. Media Assets

55 images were extracted from the source PDF cards, converted from raw scans/PNGs into optimized JPEG files with `ffmpeg -q:v 3`, and stored under `Doku/telc-b1-muendlich/img/`:
- Every image is under 300 KB (well within the repo's 500 KB ceiling).
- Filenames follow the semantic pattern `t2-{topic_num}{a|b}-{topic}-{speaker}.jpg`.
- All images are directly referenced in the markdown cards for learner visual immersion.
