# Marketing — Facebook-Gruppen für telc B1 finden und bespielen

Dieser Ordner ist **kein Modul**, sondern nur die Konfiguration dieses
Projekts. Der Code liegt in `K:\Markting.agent` und bleibt allgemein — hier
steht ausschließlich, was für telc-B1 gilt: Zielgruppe, Orte, Sprachen,
Beitragstexte.

Nichts davon gehört zur Web-App. Der Ordner lässt sich löschen, ohne dass
`index.html`, `admin/` oder `tools/build_dist.sh` etwas merken.

## Einrichten

```powershell
py -m venv .venv                              # im Repo-Wurzelverzeichnis
.venv\Scripts\pip install -e "K:\Markting.agent[all]"
```

Der Pfad ist absolut, weil `Markting.agent` noch kein Git-Remote hat. Sobald
es eins hat, wird daraus `pip install "marketing @ git+…"` — dann ist die
Einrichtung auch auf einem anderen Rechner reproduzierbar.

## Laufen lassen

Offline, ohne Konto, ohne Kosten — der Provider `fixture` liest die vier
Dateien in `fixtures/`:

```powershell
..\.venv\Scripts\python.exe finde_gruppen.py --plan   # nur planen
..\.venv\Scripts\python.exe finde_gruppen.py          # Suche, Chancen, Export
```

Dasselbe über die Kommandozeile:

```powershell
..\.venv\Scripts\marketing.exe check    -c config
..\.venv\Scripts\marketing.exe plan     -c config -b brief.yaml
..\.venv\Scripts\marketing.exe discover -c config -b brief.yaml
..\.venv\Scripts\marketing.exe list     -c config -b b1-telc-2026 --reason
```

## Echt suchen statt offline

`fixture` findet nichts Neues — er gibt vier aufgezeichnete Antworten zurück
und beweist damit nur, dass die Kette läuft. Für echte Treffer:

```yaml
# config/providers.yaml
active: serper
```

```powershell
$env:SERPER_API_KEY = "..."
```

`marketing plan` sagt **vorher**, wie viele Credits ein Lauf verbraucht. Ein
Lauf, den niemand geplant hat, ist der teuerste Fehler des Moduls.

## Das Dashboard

```bash
pip install -e "K:\Markting.agent[web]"
..\.venv\Scripts\marketing.exe serve -c config          # http://127.0.0.1:8000
```

Unter `/` liegt die Übersicht: Kacheln, Datenabdeckung, Trichter, die
sortierbare Chancentabelle mit Filtern und der Kampagnenblock. **Diese Seite
gehört zum Modul.** Kein Projekt baut sie nach, keines kopiert sie — was sich
unterscheidet, kommt aus der Konfiguration:

| Was sich ändert | Woher |
|---|---|
| Überschrift | `project.name` |
| Trichterspalten | `analytics.events` |
| Score-Balken | `scoring.weights` |
| Filterwerte | Orte, Zielgruppen, Kategorien, Sprachen aus dem Bestand |
| Kampagnen, Handlung, Auswahlregel | der Bestand |
| Angebot, Link, Tracking an/aus | das Briefing |
| Credits | `plan()` — was der nächste Lauf kosten würde |

**Nur über localhost.** Der Dienst steht öffentlich, weil die Tracking-Links
auf ihn zeigen; die Übersicht gehört nicht ins offene Netz. Es gibt keine
Anmeldung, also gäbe es auch nichts, was sie schützen würde. Wer sie von außen
sehen will, stellt einen Proxy mit Passwortschutz davor.

**Nur lesend.** Geändert wird an der Kommandozeile, wo jeder Schritt eine Spur
hinterlässt.

## Beiträge veröffentlichen

Braucht `pip install -e "K:\Markting.agent[facebook]"` und
`playwright install chromium`, und vorher zwei Dinge:

```powershell
$env:APP_BASE_URL = "https://<die-öffentliche-Domain>"   # sonst kein Text
..\.venv\Scripts\marketing.exe campaign login -c config  # einmalig, von Hand
```

Für Kommentare statt Beiträgen: `--action comment`. Die Kampagne merkt sich
ihre Handlung, und die Textauswahl folgt ihr.

**Es gibt keinen Freigabe-Schritt.** `campaign run` veröffentlicht. Begrenzt
wird der Ablauf vom Takt in `config/marketing.yaml`: 25 Beiträge am Tag, vier
Minuten Abstand. Ohne Link und ohne Vorlage in der erkannten Sprache entsteht
kein Text — beides ist Absicht, nicht Bequemlichkeit.

## Wohin der Beitrag führt

Steht in `brief.yaml`, nicht in `config/`. Dieses Projekt bewirbt die eigene
App, also wird gemessen:

```yaml
tracking: true      # {link} = APP_BASE_URL + Code, je Gruppe verschieden
```

Ein Projekt ohne eigene Anwendung schriebe stattdessen:

```yaml
tracking: false
link: https://t.me/mein-kanal      # unverändert im Text, kein Code
```

Ein Telegram-Kanal lässt sich nicht mit einem eigenen Code versehen — deshalb
zwingt das Modul niemanden zu Tracking, das er nicht auswerten kann.

## Die Texte kommen nicht von hier

`config/marketing.yaml` → `templates` ist **global**. Derselbe Block läuft
unter jedem Projekt; was diesen Beitrag zu einem telc-B1-Beitrag macht, ist
die eine Zeile `offering` in `brief.yaml`.

Ausgewählt wird nach Handlung (Beitrag/Kommentar), Sprache der Gruppe und
Genauigkeit — eine Vorlage mit `categories: [deutschkurs]` gewinnt in einer
Sprachkurs-Gruppe. Bei Gleichstand entscheidet die Kennung der Gruppe: fest
über Läufe hinweg, gestreut über die Gruppen, damit nicht dreihundert Gruppen
wortgleiche Beiträge sehen.

`{place_in}` setzt den Ortsnamen in den Fall, den die Sprache verlangt —
„у Берліні", nicht „у Берлін". Die Formen stehen in `config/locations.yaml`
unter `forms`. Fehlt eine, kommt die nächste Vorlage zum Zug.

## Ohne eigene Domain

Posten und Kommentieren braucht keine. Facebook wird über einen angemeldeten
Browser bedient — Domain, Server und Dienst spielen dabei keine Rolle. Eine
Adresse braucht nur der **Link im Text**, denn `{link}` darf nicht leer sein.

```yaml
# brief.yaml — sofort einsatzbereit, ohne alles
tracking: false
link: https://t.me/dein-kanal
```

Damit läuft alles außer der Klickzählung: Suche, Bewertung, Kampagnen,
Beiträge, Kommentare, Dashboard. Der Trichter bleibt leer, weil niemand die
Klicks sieht.

**Die Falle:** Der Link wird beim `campaign fill` berechnet und im Ziel
eingefroren; danach steht er im veröffentlichten Beitrag. Eine Adresse, die
sich morgen ändert — eine ngrok- oder Tunnel-URL etwa — tötet jeden schon
veröffentlichten Link. Nimm etwas, das bleibt.

### Später eine Domain

```bash
..\.venv\Scripts\marketing.exe campaign relink -c config --id herbst --dry-run   # was würde sich ändern?
..\.venv\Scripts\marketing.exe campaign relink -c config --id herbst
```

`fill` hilft hier nicht — es legt nur **neue** Ziele an. `relink` zieht die
noch **unveröffentlichten** nach, vergibt fehlende Tracking-Codes und verwirft
deren vorbereiteten Text, weil er den alten Link trug.

**Veröffentlichte Ziele bleiben unberührt.** Ihr Link steht in einem Beitrag,
den niemand mehr anfassen kann; ob er weiter funktioniert, entscheidet allein,
ob der alte Vorspann weiter antwortet.

### Klicks zählen ohne eigenen Server

Die Weiterleitung muss nicht dieser Dienst sein. Wer nur statisches Hosting
hat, stellt `/r/{code}` als kleine Funktion dort hin und meldet den Klick:

```bash
curl -X POST https://dein-dienst/events \
  -H "x-marketing-token: $MARKETING_EVENTS_TOKEN" \
  -d '{"code":"FB-UKR-BER-001","event":"click","visitor":"<undurchsichtige Kennung>"}'
```

`click` nimmt `/events` **nur mit gesetztem Token** an. Ohne Token melden nur
Aufrufe vom eigenen Rechner, und dort erzeugt der Dienst den Klick selbst —
ihn zusätzlich entgegenzunehmen zählte jeden doppelt.

## Wo die Daten liegen

Alles lokal, nichts auf einem fremden Server:

| | |
|---|---|
| `data/marketing.sqlite` | Quellen, Chancen, Briefings, Kampagnen, Ziele, Ereignisse, Protokoll |
| `data/query_cache.sqlite` | Provider-Antworten — eigene Datei, damit ein gelöschter Bestand kein bezahltes Guthaben kostet |
| `data/browser_profile/` | **die Facebook-Anmeldung** |
| `out/` | Exporte |

`data/browser_profile/` ist der empfindlichste Ordner: Wer ihn kopiert, ist
dein Konto. Er ist von `.gitignore` erfasst — er gehört in kein Repo und in
kein Backup, das jemand anders sieht.

Was den Rechner verlässt: die Suchanfragen an den Provider und die Beiträge an
Facebook. Sonst nichts — `tracking_events` speichert weder IP-Adressen noch
Kopfzeilen, nur den täglich wechselnden Prüfwert.

## Wo Daten landen

`data/` und `out/` **innerhalb dieses Ordners** — nicht im `data/` des Repos.
Das ist der Grund für den Unterordner: Das Modul löst `paths:` gegen das
Elternverzeichnis von `config/` auf. Läge die Konfiguration im
Wurzelverzeichnis, schriebe es in `data/` neben die 896 Lösungen, die
`tools/build_dist.sh` nie ins Dist lassen darf.

Beides steht in `.gitignore`: Gruppen-URLs und Kampagnenstand gehören nicht
ins Repo.
