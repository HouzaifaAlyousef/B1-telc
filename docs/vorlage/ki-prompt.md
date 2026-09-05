# Ein telc-PDF von einer KI ausfüllen lassen

Ziel: Sie geben einer KI die PDF einer telc-Prüfung und diese Vorlage,
und bekommen fertigen Text zurück, den Sie im Adminpanel unter **Import**
einfügen können.

## So gehen Sie vor

1. `docs/vorlage/b1-leer.txt` öffnen und **den ganzen Inhalt kopieren**
2. Bei der KI (Claude, ChatGPT …) einen neuen Chat öffnen
3. Die **PDF hochladen**
4. Den Prompt unten einfügen, darunter die kopierte Vorlage
5. Die Antwort ins Adminpanel → **Import** → **Prüfen**
6. Warnungen lesen, Vorschau ansehen, dann veröffentlichen

---

## Der Prompt

> Du bekommst die PDF einer telc-Deutsch-B1-Prüfung und darunter eine
> leere Vorlage in einem Textformat.
>
> **Aufgabe:** Füll die Vorlage mit dem Inhalt der PDF aus und gib sie
> vollständig zurück.
>
> **Regeln:**
>
> 1. Ersetze **jede** Stelle in spitzen Klammern `<…>` durch den echten
>    Inhalt aus der PDF. Es darf am Ende **kein einziges `<`** übrig sein.
> 2. Ändere **nichts** anderes: nicht die Zeilen `Format:`, `Punkte:`,
>    `Maximum:`, `Minuten:`, `Teile:`, nicht die Aufgabennummern `[1]`
>    bis `[61]`, nicht die Reihenfolge der Teile.
> 3. Übernimm den deutschen Text **wortwörtlich** aus der PDF, mit
>    Rechtschreibfehlern und Eigenheiten. Nichts umformulieren, nichts
>    korrigieren, nichts kürzen, nichts erfinden.
> 4. Die Lösungen stehen im Lösungsschlüssel am Ende der PDF. Trag sie
>    hinter `Lösung:` ein — bei Hörverstehen genau `richtig` oder
>    `falsch`, sonst nur den Buchstaben (`A`, `B`, `C` …).
> 5. Wenn ein Teil in der PDF **fehlt** (typisch: die Hörtexte), lösch
>    die betroffenen Aufgaben **nicht**. Lass ihren Text leer und schreib
>    die Lösung trotzdem hinein, falls der Schlüssel sie nennt.
> 6. Bei `Extra:` ist alles zwischen `{` und `}` JSON. Es muss gültig
>    bleiben: jeder Text in Anführungszeichen, Komma zwischen Einträgen,
>    kein Komma vor `}` oder `]`.
> 7. Zeilen, die mit `//` beginnen, sind Kommentare für dich. Du darfst
>    sie stehen lassen oder löschen — beides ist in Ordnung.
> 8. Antworte **nur** mit der ausgefüllten Vorlage. Keine Erklärung
>    davor oder danach, kein ```-Block.
>
> Hier die Vorlage:
>
> ```
> [Vorlage aus docs/vorlage/b1-leer.txt hier einfügen]
> ```

---

## Was die KI *nicht* kann

**Bilder.** Leseverstehen Teil 3 sind Anzeigen als Bild. Die KI kann sie
nicht liefern. Sie schneiden die Seite selbst aus der PDF aus, speichern
sie als `img/<name>-lv3.jpg` und laden sie hoch:

```
export SUPABASE_URL=https://ejwzvgabqoevhaimbvik.supabase.co
export SUPABASE_SERVICE_KEY=<Ihr service_role-Schlüssel>
python3 tools/upload_images.py img/
```

Der Dateiname im Bucket muss **genau** dem entsprechen, was hinter
`Bild:` steht.

**Audio.** telc-PDFs enthalten keine Hörtexte. Ohne MP3 bleibt der
Hörverstehen-Teil zum Lesen und Vergleichen da, aber nicht zum Hören.
Wenn Sie Aufnahmen haben:

```
python3 tools/upload_audio.py audio/
```

Danach im Adminpanel → **Hörtexte** jede Datei ihrem Teil zuordnen.

> ⚠️ Der `service_role`-Schlüssel umgeht jeden Schutz. Nur in Ihrer
> eigenen Shell, nie im Browser, nie in git.

---

## Nach dem Import prüfen

Der Prüfen-Knopf meldet unter anderem:

| Meldung | Bedeutung |
|---|---|
| `… Stellen noch nicht ausgefüllt (<…>)` | Die KI hat Lücken gelassen — **nicht veröffentlichen** |
| `Aufgabe X hat keine Lösung` | Lösungsschlüssel unvollständig |
| `Teil X hat kein Format` | Eine `Format:`-Zeile wurde gelöscht |
| `Extra-JSON ist ungültig` | Komma oder Anführungszeichen im JSON kaputt |

Die Vorschau zeigt jede Aufgabe so, wie der Prüfling sie sieht. **Erst
ansehen, dann veröffentlichen** — ein veröffentlichter Test ist sofort
für alle Abonnenten der Stufe sichtbar.

---

## Andere Stufen (A1, A2, B2 …)

Die Vorlage ist auf telc B1 zugeschnitten: 61 Aufgaben, 225 Punkte,
drei Blöcke. Andere Stufen haben andere Teile und andere Punktzahlen.

Vorgehen: Vorlage kopieren, und die Zeilen `Punkte:` (pro Aufgabe),
`Maximum:` (pro Teil) und `Punkte:` im Block an die echte Prüfung
anpassen, Aufgaben hinzufügen oder streichen. Die fünf Formate
(`matching`, `mc`, `wordbank`, `truefalse`, `writing`) decken auch die
anderen Stufen ab.

Vorher im Adminpanel → **Inhalte → Stufen** die Stufe anlegen, sonst
erscheint sie im Import nicht.
