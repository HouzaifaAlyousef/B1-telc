-- جزء 3 من 4 — نماذج modell-08–modell-10
-- مولّد من supabase/seed/dtz-b1.sql بـtools/split_seed.sh — لا تعدّله بالإيد
-- آمن للإعادة: شغّله مرتين ما بيغيّر شي.

begin;

-- مولّد من content/dtz/b1 بـtools/export_sql.py — لا تعدّله بالإيد

insert into levels (id, title, sort, published, provider, stufe) values ('dtz-b1', 'Deutsch-Test für Zuwanderer B1', 0, true, 'DTZ', 'B1')
on conflict (id) do update set title = excluded.title,
  provider = coalesce(levels.provider, excluded.provider),
  stufe    = coalesce(levels.stufe,    excluded.stufe);

-- ================= modell-08 · ASLAN =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('dtz-b1', 'modell-08', 'ASLAN', '46 Aufgaben · 100 Minuten',
        '[{"id": "block-hoeren", "parts": ["hv1", "hv2", "hv3", "hv4"], "title": "Hören", "minutes": 25, "hint": "Aufgaben 1–20", "maxPoints": 20, "availablePoints": 20, "missing": 0}, {"id": "block-lesen", "parts": ["lv1", "lv2", "lv3", "lv4", "lv5"], "title": "Lesen", "minutes": 45, "hint": "Aufgaben 21–45", "maxPoints": 25, "availablePoints": 25, "missing": 0}, {"id": "block-schreiben", "parts": ["s1"], "title": "Schreiben", "minutes": 30, "hint": "Aufgabe 46", "maxPoints": 20, "availablePoints": 20, "missing": 0}]'::jsonb, 46, true, 7)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('hv1', 'Hören', 'Hören, Teil 1', 6, 'Sie hören vier Ansagen. Zu jeder Ansage gibt es eine Aufgabe. Welche Lösung (a, b oder c) passt am besten?', 'mc', '{"maxPoints": 4, "availablePoints": 4, "missing": 0, "pointsPerItem": 1, "audioPlays": 1}'::jsonb, 0),
    ('hv2', 'Hören', 'Hören, Teil 2', 5, 'Sie hören fünf Ansagen aus dem Radio. Zu jeder Ansage gibt es eine Aufgabe. Welche Lösung (a, b oder c) passt am besten?', 'mc', '{"maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1, "audioPlays": 1}'::jsonb, 1),
    ('hv3', 'Hören', 'Hören, Teil 3', 8, 'Sie hören vier Gespräche. Zu jedem Gespräch gibt es zwei Aufgaben. Entscheiden Sie bei jedem Gespräch, ob die Aussage dazu richtig oder falsch ist und welche Antwort (a, b oder c) am besten passt.', 'mc', '{"maxPoints": 8, "availablePoints": 8, "missing": 0, "pointsPerItem": 1, "audioPlays": 2}'::jsonb, 2),
    ('hv4', 'Hören', 'Hören, Teil 4', 6, 'Sie hören Aussagen zu einem Thema. Welcher der Sätze a–f passt zu den Aussagen 18–20?', 'matching', '{"bank": [{"key": "A", "text": "Wenn die Geschäfte sonntags geöffnet haben, führt das für alle zu mehr Stress."}, {"key": "B", "text": "Sonntagsarbeit ist beliebt, weil sie besser bezahlt wird."}, {"key": "C", "text": "Sonntagsarbeit ist gut für die Wirtschaft."}, {"key": "D", "text": "Warum sollen vor Weihnachten andere Regeln gelten als sonst im Jahr."}, {"key": "E", "text": "Sonntagsarbeit ist kein Problem, weil man dafür einen anderen Tag in der Woche frei bekommt."}, {"key": "F", "text": "Die Angestellten wollen nicht gerne am Sonntag arbeiten."}], "bankTitle": "Meinungen zur Sonntagsarbeit", "maxPoints": 3, "availablePoints": 3, "missing": 0, "pointsPerItem": 1, "audioPlays": 2}'::jsonb, 3),
    ('lv1', 'Lesen', 'Lesen, Teil 1', 10, 'Sie sind im Bürgerbüro Ihrer Stadt. Lesen Sie die Aufgaben 21–25 und den Wegweiser. In welches Zimmer (a, b oder c) gehen Sie?', 'mc', '{"bankImage": "img/dtz-b1-m08-lv1.jpg", "maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1}'::jsonb, 4),
    ('lv2', 'Lesen', 'Lesen, Teil 2', 10, 'Finden Sie zu jeder Situation (26–30) die passende Anzeige (a–h). Für eine Aufgabe gibt es keine passende Anzeige. Markieren Sie in diesem Fall ein x.', 'matching', '{"bank": [{"key": "A", "text": "Anzeige a"}, {"key": "B", "text": "Anzeige b"}, {"key": "C", "text": "Anzeige c"}, {"key": "D", "text": "Anzeige d"}, {"key": "E", "text": "Anzeige e"}, {"key": "F", "text": "Anzeige f"}, {"key": "G", "text": "Anzeige g"}, {"key": "H", "text": "Anzeige h"}, {"key": "X", "text": "Keine Anzeige passt"}], "bankTitle": "Anzeigen", "bankImage": "img/dtz-b1-m08-lv2.jpg", "maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1}'::jsonb, 5),
    ('lv3', 'Lesen', 'Lesen, Teil 3', 10, 'Lesen Sie die drei Texte. Zu jedem Text gibt es zwei Aufgaben. Entscheiden Sie bei jedem Text, ob die Aussage richtig oder falsch ist und welche Antwort (a, b oder c) am besten passt.', 'mc', '{"passages": [{"paragraphs": [{"t": "An die Mieter des Hauses Sandweg 12", "b": false}, {"t": "Liebe Mieterinnen und Mieter,", "b": false}, {"t": "immer wieder beschweren sich Bewohner des Hauses, dass die Mülltonnen zu voll sind und dass der Müll oft neben die Tonnen gestellt wird. Im Hof ist es dann schmutzig und es riecht schlecht.", "b": false}, {"t": "Die Hausverwaltung möchte dieses Problem lösen: Ab dem 1. August werden wir zwei zusätzliche Mülltonnen bei der Stadt bestellen.", "b": false}, {"t": "Wir müssen Sie aber darauf hinweisen, dass für diese Mülltonnen Kosten entstehen, die wir auf alle Mieter umlegen müssen. Ihren Beitrag finden Sie am Jahresende in Ihrer Nebenkostenabrechnung.", "b": false}, {"t": "Wir hoffen und erwarten, dass alle Seiten mit dieser Lösung zufrieden sein werden.", "b": false}, {"t": "Mit freundlichen Grüßen", "b": false}, {"t": "Ihre Hausverwaltung", "b": false}]}, {"paragraphs": [{"t": "Liebe Eltern,", "b": false}, {"t": "zur Vorbereitung der Klassenfahrt in diesem Schuljahr lade ich Sie herzlich zu einem Elternabend ein. Dieser findet am 1. September um 18 Uhr in Raum 120 statt.", "b": false}, {"t": "Auf dem Elternabend wollen wir über das Ziel der Klassenfahrt, ihre Dauer und die Kosten sprechen.", "b": false}, {"t": "Falls Sie Probleme haben sollten, die Reise zu finanzieren, nehmen Sie bitte in den nächsten Tagen, auf jeden Fall aber vor dem Elternabend, Kontakt mit mir auf. Wir werden bestimmt eine Lösung finden.", "b": false}, {"t": "Wichtig:", "b": false}, {"t": "Alles, was an diesem Abend beschlossen wird, gilt für alle Schüler, also auch für die Schüler, deren Eltern nicht anwesend waren. Deshalb ist es in Ihrem Interesse, dass von jedem Schüler ein Elternteil zum Elternabend kommt.", "b": false}, {"t": "Mit freundlichen Grüßen", "b": false}, {"t": "Ihre Schulleitung", "b": false}]}, {"paragraphs": [{"t": "INFORMATIONEN DER GEZ", "b": false}, {"t": "Im Moment werden ältere Mitbürger häufig von Personen angerufen, die sagen, dass sie im Auftrag der GEZ telefonieren. Sie behaupten, dass Rentner ab sofort keine Rundfunkgebühren mehr zahlen müssten. Dann bitten sie die Angerufenen, ihre Bankverbindung zu nennen, angeblich, damit sie die zu viel gezahlten Rundfunkgebühren zurückzahlen können.", "b": false}, {"t": "Die GEZ warnt vor diesen Anrufen. Diese Anrufe kommen nicht von der GEZ.", "b": false}, {"t": "Hier sind Betrüger unterwegs. Die Anrufer wollen die Kontodaten von GEZ-Kunden haben. Die GEZ hat bereits bei der Polizei Anzeige erstattet und bittet jeden, der von den Betrügern angerufen wird, um schnelle Mitteilung: www.gez.de.", "b": false}]}], "maxPoints": 6, "availablePoints": 6, "missing": 0, "pointsPerItem": 1}'::jsonb, 6),
    ('lv4', 'Lesen', 'Lesen, Teil 4', 9, 'Lesen Sie den Text. Entscheiden Sie, ob die Aussagen 37–39 richtig oder falsch sind.', 'mc', '{"passages": [{"paragraphs": [{"t": "ProBank Telefon-Banking", "b": false}, {"t": "Schneller, einfacher und bequemer geht es nicht!", "b": false}, {"t": "Mit dem ProBank Telefon-Banking können Sie Ihr ProBank Girokonto bequem von jedem Telefon aus führen. Egal, ob Sie von zu Hause, vom Arbeitsplatz oder von unterwegs aus anrufen – Sie benötigen nur Ihre persönliche Telefon-Geheimzahl. Diese erhalten Sie mit separater Post.", "b": false}, {"t": "Unser Telefon-Banking arbeitet mit einem Sprachcomputer und ist 24 Stunden am Tag für Sie erreichbar. Das Telefon-Banking ist für Sie kostenlos, Sie müssen nur die Telefonkosten bezahlen. Bitte wählen Sie die Telefonnummer 0180/256760200 (9 Cent/Minute aus dem Festnetz der Deutschen Telekom; ggf. abweichende Mobilfunktarife).", "b": false}, {"t": "Die folgenden Leistungen stehen Ihnen zur Verfügung:", "b": false}, {"t": "► Kontoinformationen, Kontostand abfragen", "b": false}, {"t": "Ihr aktueller Kontostand wird Ihnen nach Eingabe Ihrer Kontonummer und Telefon-Geheimzahl genannt. Sie können außerdem einen Kontoauszug über den Sprachcomputer bestellen.", "b": false}, {"t": "► Buchungsaufträge", "b": false}, {"t": "Überweisungen sind ebenfalls direkt über den Sprachcomputer möglich. Inlands-Überweisungsaufträge sind bis maximal 10.000 EUR pro Tag möglich. Überweisungen ins Ausland können im Moment telefonisch leider noch nicht in Auftrag gegeben werden.", "b": false}, {"t": "► Daueraufträge einrichten", "b": false}, {"t": "Für die Einrichtung eines Dauerauftrags lassen Sie sich zu einem Mitarbeiter der Bank verbinden (Direkt-Service).", "b": false}, {"t": "► Bestellservice", "b": false}, {"t": "Auf Wunsch können Sie über unseren Sprachcomputer alle wichtigen Formulare, zum Beispiel Girobriefumschläge und Überweisungsvordrucke bestellen. Fünf Vordrucke pro Monat sind kostenlos.", "b": false}]}], "maxPoints": 3, "availablePoints": 3, "missing": 0, "pointsPerItem": 1}'::jsonb, 7),
    ('lv5', 'Lesen', 'Lesen, Teil 5', 6, 'Lesen Sie den Text und schließen Sie die Lücken 40–45. Welche Lösung (a, b oder c) passt am besten?', 'mc', '{"passages": [{"paragraphs": [{"t": "Köln, den 1. Oktober 2010", "b": false}, {"t": "Kündigung meines Mobilfunkvertrags", "b": false}, {"t": "Kundennummer 245 333 22, Vertragsnummer MFV6674X", "b": false}, {"t": "Sehr geehrte Damen und Herren,", "b": false}, {"t": "Hiermit kündige ich meinen Mobilfunkvertrag zum nächstmöglichen (40).", "b": false}, {"t": "Es handelt sich um den zwischen Ihnen und mir bestehenden (41) mit der oben angegebenen Nummer.", "b": false}, {"t": "Könnten Sie mir bitte mitteilen, ab wann ich meinen Vertrag beenden (42)?", "b": false}, {"t": "Bitte schicken Sie mir außerdem eine schriftliche (43) über den Eingang der Kündigung zu.", "b": false}, {"t": "Weiter möchte ich Sie (44), mich aus Ihrer Adressenkartei zu nehmen und mir in Zukunft keine Werbung mehr zuzusenden.", "b": false}, {"t": "Mit freundlichen (45)", "b": false}, {"t": "Karsten Wissman", "b": false}]}], "maxPoints": 6, "availablePoints": 6, "missing": 0, "pointsPerItem": 1}'::jsonb, 8),
    ('s1', 'Schreiben', 'Schreiben', 30, 'Wählen Sie Aufgabe A oder Aufgabe B. Zeigen Sie, was Sie können. Schreiben Sie möglichst viel. Schreiben Sie Ihren Text auf den Antwortbogen.', 'writing', '{"maxPoints": 20, "availablePoints": 20, "missing": 0, "pointsPerItem": 20}'::jsonb, 9)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'dtz-b1' and t.slug = 'modell-08'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('hv1', '1', 'Wie können Sie heute zum Südbahnhof fahren?', '[{"key": "A", "text": "Mit der U 1."}, {"key": "B", "text": "Mit der U-Bahn und dem Bus."}, {"key": "C", "text": "Überhaupt nicht."}]'::jsonb, 1, null::jsonb, 0),
    ('hv1', '2', 'Was soll Frau Aslan tun?', '[{"key": "A", "text": "Am Freitag vorbeikommen."}, {"key": "B", "text": "Eine Fortbildung machen."}, {"key": "C", "text": "Im Sekretariat anrufen."}]'::jsonb, 1, null::jsonb, 1),
    ('hv1', '3', 'Was kann man mit der Kundenkarte machen?', '[{"key": "A", "text": "Einkaufen und später bezahlen."}, {"key": "B", "text": "Billiger einkaufen."}, {"key": "C", "text": "Auch im Ausland einkaufen."}]'::jsonb, 1, null::jsonb, 2),
    ('hv1', '4', 'Was ist heute im Angebot?', '[{"key": "A", "text": "Gemüse."}, {"key": "B", "text": "Fleisch."}, {"key": "C", "text": "Obst."}]'::jsonb, 1, null::jsonb, 3),
    ('hv2', '5', 'Wie wird das Wetter in Süddeutschland?', '[{"key": "A", "text": "Die Sonne scheint."}, {"key": "B", "text": "Es gibt viele Wolken."}, {"key": "C", "text": "Es regnet und schneit."}]'::jsonb, 1, null::jsonb, 0),
    ('hv2', '6', 'Wann hören Sie Tipps zur Arbeitssuche?', '[{"key": "A", "text": "Am Montag."}, {"key": "B", "text": "Am Mittwoch."}, {"key": "C", "text": "Am Wochenende."}]'::jsonb, 1, null::jsonb, 1),
    ('hv2', '7', 'Wo muss man sehr vorsichtig fahren?', '[{"key": "A", "text": "Auf der A 1."}, {"key": "B", "text": "Auf der A 3."}, {"key": "C", "text": "Auf der A 31."}]'::jsonb, 1, null::jsonb, 2),
    ('hv2', '8', 'Was kann man gewinnen?', '[{"key": "A", "text": "CDs."}, {"key": "B", "text": "Eine Reise."}, {"key": "C", "text": "Bargeld."}]'::jsonb, 1, null::jsonb, 3),
    ('hv2', '9', 'Herr Lohmann', '[{"key": "A", "text": "wird von der Polizei gesucht."}, {"key": "B", "text": "hatte einen Unfall."}, {"key": "C", "text": "wird seit Tagen vermisst."}]'::jsonb, 1, null::jsonb, 4),
    ('hv3', '10', 'Frau Brodsky telefoniert mit dem Deutschlehrer.', '[{"key": "A", "text": "richtig"}, {"key": "B", "text": "falsch"}]'::jsonb, 1, null::jsonb, 0),
    ('hv3', '11', 'Was soll Frau Brodsky machen?', '[{"key": "A", "text": "Ihrem Sohn mehr bei den Hausaufgaben helfen."}, {"key": "B", "text": "Einen Nachhilfelehrer suchen."}, {"key": "C", "text": "Ihren Sohn mittags länger in der Schule lassen."}]'::jsonb, 1, null::jsonb, 1),
    ('hv3', '12', 'Herr Kowalski hat ein Gespräch beim JobCenter.', '[{"key": "A", "text": "richtig"}, {"key": "B", "text": "falsch"}]'::jsonb, 1, null::jsonb, 2),
    ('hv3', '13', 'Was muss Herr Kowalski noch tun?', '[{"key": "A", "text": "Verschiedene Unterlagen mitbringen."}, {"key": "B", "text": "Den Antrag unterschreiben."}, {"key": "C", "text": "In vier Wochen den Antrag abgeben."}]'::jsonb, 1, null::jsonb, 3),
    ('hv3', '14', 'Frau Mavinga bewirbt sich.', '[{"key": "A", "text": "richtig"}, {"key": "B", "text": "falsch"}]'::jsonb, 1, null::jsonb, 4),
    ('hv3', '15', 'Was ist richtig?', '[{"key": "A", "text": "Frau Mavinga möchte 20 Stunden pro Woche arbeiten."}, {"key": "B", "text": "Frau Mavinga möchte nicht am Samstag arbeiten."}, {"key": "C", "text": "Frau Mavinga hat Berufserfahrung."}]'::jsonb, 1, null::jsonb, 5),
    ('hv3', '16', 'Die Frau kauft eine neue Waschmaschine.', '[{"key": "A", "text": "richtig"}, {"key": "B", "text": "falsch"}]'::jsonb, 1, null::jsonb, 6),
    ('hv3', '17', 'Wann findet die Lieferung statt?', '[{"key": "A", "text": "Am Donnerstagmorgen."}, {"key": "B", "text": "Spätestens Ende der Woche."}, {"key": "C", "text": "Am Nachmittag."}]'::jsonb, 1, null::jsonb, 7),
    ('hv4', '18', 'Sprecher 1', null::jsonb, 1, null::jsonb, 0),
    ('hv4', '19', 'Sprecher 2', null::jsonb, 1, null::jsonb, 1),
    ('hv4', '20', 'Sprecher 3', null::jsonb, 1, null::jsonb, 2),
    ('lv1', '21', 'Ihr Bekannter spricht nur wenig Deutsch und sucht einen Deutschkurs. Er will wissen, welcher Kurs für ihn der richtige ist.', '[{"key": "A", "text": "Zimmer 106–107"}, {"key": "B", "text": "Zimmer 304–306"}, {"key": "C", "text": "anderes Zimmer"}]'::jsonb, 1, null::jsonb, 0),
    ('lv1', '22', 'Sie haben Fragen zu Ihrem Mietvertrag. Wo bekommen Sie Informationen?', '[{"key": "A", "text": "Zimmer 001–005"}, {"key": "B", "text": "Zimmer 215"}, {"key": "C", "text": "anderes Zimmer"}]'::jsonb, 1, null::jsonb, 1),
    ('lv1', '23', 'Sie haben Ihre Schlüssel verloren. Wo können Sie sie vielleicht wiederbekommen?', '[{"key": "A", "text": "Zimmer 006–007"}, {"key": "B", "text": "Zimmer 206–208"}, {"key": "C", "text": "anderes Zimmer"}]'::jsonb, 1, null::jsonb, 2),
    ('lv1', '24', 'Sie haben eine Stelle im Krankenhaus gefunden und müssen sich vom Arzt untersuchen lassen. Wohin gehen Sie?', '[{"key": "A", "text": "Zimmer 008–015"}, {"key": "B", "text": "Zimmer 307–309"}, {"key": "C", "text": "anderes Zimmer"}]'::jsonb, 1, null::jsonb, 3),
    ('lv1', '25', 'Sie heiraten heute. Wohin gehen Sie?', '[{"key": "A", "text": "Zimmer 001–005"}, {"key": "B", "text": "Zimmer 201–203"}, {"key": "C", "text": "anderes Zimmer"}]'::jsonb, 1, null::jsonb, 4),
    ('lv2', '26', 'Ihr Sohn zieht in seine erste Wohnung. Sie suchen billige Möbel für sein Wohnzimmer.', null::jsonb, 1, null::jsonb, 0),
    ('lv2', '27', 'Sie ziehen nächstes Wochenende um. Sie suchen eine Firma, die Ihre Möbel transportiert.', null::jsonb, 1, null::jsonb, 1),
    ('lv2', '28', 'Sie suchen eine ruhige, helle 3-Zimmer-Wohnung mit guten Verkehrsverbindungen in die Innenstadt. Sie möchten keine Wohnung im Erdgeschoss.', null::jsonb, 1, null::jsonb, 2),
    ('lv2', '29', 'Sie suchen für sich und Ihre Familie eine 4-Zimmer-Wohnung im Zentrum. Ihre Eltern haben Probleme mit dem Treppensteigen.', null::jsonb, 1, null::jsonb, 3),
    ('lv2', '30', 'Ein Kollege kommt im September für drei Monate nach Deutschland. Sie suchen für ihn ein Zimmer oder eine kleine Wohnung.', null::jsonb, 1, null::jsonb, 4),
    ('lv3', '31', 'Viele Mieter sind unzufrieden.', null::jsonb, 1, null::jsonb, 0),
    ('lv3', '32', 'Die Hausverwaltung', '[{"key": "A", "text": "möchte die Mülltonnen nicht mehr in den Hof stellen."}, {"key": "B", "text": "möchte, dass die Mieter weniger Müll wegwerfen."}, {"key": "C", "text": "möchte weitere Mülltonnen besorgen."}]'::jsonb, 1, null::jsonb, 1),
    ('lv3', '33', 'Es ist wichtig, dass Eltern aller Schüler zum Elternabend kommen.', null::jsonb, 1, null::jsonb, 2),
    ('lv3', '34', 'Wenn Eltern nicht kommen können,', '[{"key": "A", "text": "sollen sie den Klassenlehrer vor dem Elternabend anrufen."}, {"key": "B", "text": "müssen sie akzeptieren, was an diesem Abend besprochen wurde."}, {"key": "C", "text": "können ihre Kinder nicht an der Klassenfahrt teilnehmen."}]'::jsonb, 1, null::jsonb, 3),
    ('lv3', '35', 'Durch diese Pressemitteilung will die GEZ die Verbraucher warnen.', null::jsonb, 1, null::jsonb, 4),
    ('lv3', '36', 'Die GEZ möchte, dass die Kunden', '[{"key": "A", "text": "weniger bezahlen."}, {"key": "B", "text": "die GEZ über bestimmte Anrufe informieren."}, {"key": "C", "text": "ihre Bankverbindung angeben."}]'::jsonb, 1, null::jsonb, 5),
    ('lv4', '37', 'Für das Telefonbanking muss der Kunde außer den Telefonkosten nichts bezahlen.', null::jsonb, 1, null::jsonb, 0),
    ('lv4', '38', 'Nicht jede Überweisung ist mit dem Telefonbanking möglich.', null::jsonb, 1, null::jsonb, 1),
    ('lv4', '39', 'Der Kunde bekommt jeden Monat Vordrucke und Formulare zugeschickt.', null::jsonb, 1, null::jsonb, 2),
    ('lv5', '40', 'Lücke 40', '[{"key": "A", "text": "Datum"}, {"key": "B", "text": "Frist"}, {"key": "C", "text": "Zeit"}]'::jsonb, 1, null::jsonb, 0),
    ('lv5', '41', 'Lücke 41', '[{"key": "A", "text": "Antrag"}, {"key": "B", "text": "Beitrag"}, {"key": "C", "text": "Vertrag"}]'::jsonb, 1, null::jsonb, 1),
    ('lv5', '42', 'Lücke 42', '[{"key": "A", "text": "will"}, {"key": "B", "text": "kann"}, {"key": "C", "text": "muss"}]'::jsonb, 1, null::jsonb, 2),
    ('lv5', '43', 'Lücke 43', '[{"key": "A", "text": "Anmeldung"}, {"key": "B", "text": "Aufnahme"}, {"key": "C", "text": "Bestätigung"}]'::jsonb, 1, null::jsonb, 3),
    ('lv5', '44', 'Lücke 44', '[{"key": "A", "text": "fordern"}, {"key": "B", "text": "bitten"}, {"key": "C", "text": "wünschen"}]'::jsonb, 1, null::jsonb, 4),
    ('lv5', '45', 'Lücke 45', '[{"key": "A", "text": "Grüßen"}, {"key": "B", "text": "Wiedersehen"}, {"key": "C", "text": "Dank"}]'::jsonb, 1, null::jsonb, 5),
    ('s1', '46', 'Aufgabe A: Sie finden an Ihrem Arbeitsplatz eine Nachricht von Ihrem Chef. In der Firma ist im Moment viel zu tun, darum fragt er Sie, ob Sie diese Woche auch am Samstag arbeiten könnten. Sie schreiben Ihrem Chef eine kurze Mitteilung. Schreiben Sie etwas zu folgenden Punkten: - Samstag arbeiten ist okay. - Wie viele Stunden arbeiten? - Ist um 10 Uhr anfangen in Ordnung? - Für den Samstag nächste Woche einen Tag frei nehmen? oder Aufgabe B: Ihr Sohn kann morgen nicht an einem Ausflug teilnehmen, weil er krank geworden ist. Sie schreiben eine kurze Mitteilung an die Lehrerin, Frau Krüger. Schreiben Sie etwas zu folgenden Punkten: - Grund für Ihr Schreiben - Was fehlt Ihrem Sohn? - Was hat der Arzt gesagt? - Wann wieder in der Schule?', null::jsonb, 0, null::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'dtz-b1' and t.slug = 'modell-08'
join sections s on s.test_id = t.id and s.section_id = v.section_id
on conflict (section_id, item_id) do update set text = excluded.text, options = excluded.options, points = excluded.points, meta = excluded.meta, sort = excluded.sort;

insert into item_answers (item_id, answer, explanation)
select i.id, v.answer, v.explanation
from (values
    ('hv1', '1', 'B', null),
    ('hv1', '2', 'C', null),
    ('hv1', '3', 'A', null),
    ('hv1', '4', 'C', null),
    ('hv2', '5', 'A', null),
    ('hv2', '6', 'B', null),
    ('hv2', '7', 'C', null),
    ('hv2', '8', 'B', null),
    ('hv2', '9', 'A', null),
    ('hv3', '10', 'B', null),
    ('hv3', '11', 'C', null),
    ('hv3', '12', 'B', null),
    ('hv3', '13', 'B', null),
    ('hv3', '14', 'A', null),
    ('hv3', '15', 'C', null),
    ('hv3', '16', 'B', null),
    ('hv3', '17', 'B', null),
    ('hv4', '18', 'f', null),
    ('hv4', '19', 'a', null),
    ('hv4', '20', 'c', null),
    ('lv1', '21', 'A', null),
    ('lv1', '22', 'B', null),
    ('lv1', '23', 'A', null),
    ('lv1', '24', 'C', null),
    ('lv1', '25', 'B', null),
    ('lv2', '26', 'c', null),
    ('lv2', '27', 'h', null),
    ('lv2', '28', 'e', null),
    ('lv2', '29', 'x', null),
    ('lv2', '30', 'd', null),
    ('lv3', '31', 'richtig', null),
    ('lv3', '32', 'C', null),
    ('lv3', '33', 'richtig', null),
    ('lv3', '34', 'B', null),
    ('lv3', '35', 'richtig', null),
    ('lv3', '36', 'B', null),
    ('lv4', '37', 'richtig', null),
    ('lv4', '38', 'richtig', null),
    ('lv4', '39', 'falsch', null),
    ('lv5', '40', 'A', null),
    ('lv5', '41', 'C', null),
    ('lv5', '42', 'B', null),
    ('lv5', '43', 'C', null),
    ('lv5', '44', 'B', null),
    ('lv5', '45', 'A', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'dtz-b1' and t.slug = 'modell-08'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;

-- ================= modell-09 · SCHMIDT =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('dtz-b1', 'modell-09', 'SCHMIDT', '46 Aufgaben · 100 Minuten',
        '[{"id": "block-hoeren", "parts": ["hv1", "hv2", "hv3", "hv4"], "title": "Hören", "minutes": 25, "hint": "Aufgaben 1–20", "maxPoints": 20, "availablePoints": 20, "missing": 0}, {"id": "block-lesen", "parts": ["lv1", "lv2", "lv3", "lv4", "lv5"], "title": "Lesen", "minutes": 45, "hint": "Aufgaben 21–45", "maxPoints": 25, "availablePoints": 25, "missing": 0}, {"id": "block-schreiben", "parts": ["s1"], "title": "Schreiben", "minutes": 30, "hint": "Aufgabe 46", "maxPoints": 20, "availablePoints": 20, "missing": 0}]'::jsonb, 46, true, 8)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('hv1', 'Hören', 'Hören, Teil 1', 6, 'Sie hören vier Ansagen. Zu jeder Ansage gibt es eine Aufgabe. Welche Lösung (a, b oder c) passt am besten?', 'mc', '{"maxPoints": 4, "availablePoints": 4, "missing": 0, "pointsPerItem": 1, "audioPlays": 1}'::jsonb, 0),
    ('hv2', 'Hören', 'Hören, Teil 2', 5, 'Sie hören fünf Ansagen aus dem Radio. Zu jeder Ansage gibt es eine Aufgabe. Welche Lösung (a, b oder c) passt am besten?', 'mc', '{"maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1, "audioPlays": 1}'::jsonb, 1),
    ('hv3', 'Hören', 'Hören, Teil 3', 8, 'Sie hören vier Gespräche. Zu jedem Gespräch gibt es zwei Aufgaben. Entscheiden Sie bei jedem Gespräch, ob die Aussage dazu richtig oder falsch ist und welche Antwort (a, b oder c) am besten passt.', 'mc', '{"maxPoints": 8, "availablePoints": 8, "missing": 0, "pointsPerItem": 1, "audioPlays": 2}'::jsonb, 2),
    ('hv4', 'Hören', 'Hören, Teil 4', 6, 'Sie hören Aussagen zu einem Thema. Welcher der Sätze a–f passt zu den Aussagen 18–20?', 'matching', '{"bank": [{"key": "A", "text": "Die Sprecherin hat ihren Fernseher verkauft, nachdem sie ein Kind bekam."}, {"key": "B", "text": "Wichtig sind eindeutige Regeln beim Fernsehen."}, {"key": "C", "text": "Es hängt vom Alter ab, wie viel Kinder fernsehen sollten."}, {"key": "D", "text": "Man soll die Kinder nicht alleine fernsehen lassen."}, {"key": "E", "text": "Ohne Fernsehen würde es keine Probleme mehr geben."}, {"key": "F", "text": "Eltern müssen ihr eigenes Fernsehverhalten ändern."}], "bankTitle": "Meinungen zum Fernsehen bei Kindern", "maxPoints": 3, "availablePoints": 3, "missing": 0, "pointsPerItem": 1, "audioPlays": 2}'::jsonb, 3),
    ('lv1', 'Lesen', 'Lesen, Teil 1', 10, 'Sie wollen etwas einkaufen. Lesen Sie die Aufgaben 21–25 und die Internetseite. Wo (a, b oder c) finden Sie etwas Passendes?', 'mc', '{"bankImage": "img/dtz-b1-m09-lv1.jpg", "maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1}'::jsonb, 4),
    ('lv2', 'Lesen', 'Lesen, Teil 2', 10, 'Finden Sie zu jeder Situation (26–30) die passende Anzeige (a–h). Für eine Aufgabe gibt es keine passende Anzeige. Markieren Sie in diesem Fall ein x.', 'matching', '{"bank": [{"key": "A", "text": "Anzeige a"}, {"key": "B", "text": "Anzeige b"}, {"key": "C", "text": "Anzeige c"}, {"key": "D", "text": "Anzeige d"}, {"key": "E", "text": "Anzeige e"}, {"key": "F", "text": "Anzeige f"}, {"key": "G", "text": "Anzeige g"}, {"key": "H", "text": "Anzeige h"}, {"key": "X", "text": "Keine Anzeige passt"}], "bankTitle": "Anzeigen", "bankImage": "img/dtz-b1-m09-lv2.jpg", "maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1}'::jsonb, 5),
    ('lv3', 'Lesen', 'Lesen, Teil 3', 10, 'Lesen Sie die drei Texte. Zu jedem Text gibt es zwei Aufgaben. Entscheiden Sie bei jedem Text, ob die Aussage richtig oder falsch ist und welche Antwort (a, b oder c) am besten passt.', 'mc', '{"passages": [{"paragraphs": [{"t": "Liebe Eltern", "b": false}, {"t": "gut erhaltene Kleidung für Kinder und Jugendliche, Spielzeug, Bücher und vieles mehr bietet der Flohmarkt der Peter Petersen Grundschule, Kaiserstraße 20.", "b": false}, {"t": "Am Samstag 24. April können Eltern dort einkaufen, während ihre Kinder betreut werden.", "b": false}, {"t": "Der Markt ist von 14 bis 17 Uhr geöffnet. Der Verkauf findet auf dem Schulhof statt.", "b": false}, {"t": "Wer etwas verkaufen möchte und einen eigenen Tapeziertisch mitbringt, zahlt sechs Euro. Ein Leihtisch ist für vier Euro zu haben. Tischreservierung unter Telefon 089 – 23 76 33 (16 bis 21 Uhr). Für Getränke und einen kleinen Imbiss wird gesorgt.", "b": false}, {"t": "Bitte geben Sie uns Bescheid, ob Sie kommen möchten und ob Sie einen Leihtisch benötigen.", "b": false}, {"t": "Mit freundlichen Grüßen", "b": false}, {"t": "Die Schulleitung", "b": false}]}, {"paragraphs": [{"t": "Sehr geehrte Familie Gonzales,", "b": false}, {"t": "aus Gründen der Sicherheit muss auch dieses Jahr Ihre Gasheizung wieder überprüft und gereinigt werden. Dazu wird sich die Firma Bauer – Sanitärinstallation in den nächsten Tagen telefonisch mit Ihnen in Verbindung setzen, um einen Termin auszumachen.", "b": false}, {"t": "Die Kosten für diese Wartung sind laut Mietvertrag von Ihnen zu zahlen. Wir weisen Sie aber darauf hin, dass Sie einen Teil der Kosten als sogenannte „haushaltsnahe Dienstleistung“ beim Finanzamt von Ihrer Steuer abziehen können.", "b": false}, {"t": "Mit freundlichen Grüßen", "b": false}, {"t": "Ihr Hausverwaltung", "b": false}]}, {"paragraphs": [{"t": "Berufsbezogene Sprachförderung", "b": false}, {"t": "Kursangebot für Migranten", "b": false}, {"t": "Diese Kurse richten sich an Migrantinnen und Migranten, die sich beruflich und sprachlich weiterbilden möchten. Ziel ist es, den Teilnehmerinnen und Teilnehmern zu helfen, einen Arbeitsplatz zu finden.", "b": false}, {"t": "Migranten/Migrantinnen können an einer berufsbezogenen Sprachförderung teilnehmen, wenn sie Arbeit suchen und eine sprachliche und fachliche Qualifizierung für den Arbeitsmarkt benötigen, aber auch wenn sie bereits in einem Beschäftigungsverhältnis stehen.", "b": false}, {"t": "Sie müssen einen Integrationskurs abgeschlossen haben. Wenn sie nachweisen können, dass sie ein Sprachniveau von mindestens B1 haben, gilt diese Bedingung jedoch nicht.", "b": false}, {"t": "In den Kursen lernen die Teilnehmerinnen und Teilnehmer nicht nur Deutsch für den Beruf, sie besuchen auch Betriebe und machen ein Praktikum.", "b": false}, {"t": "Die Kurse sind kostenlos. Haben Sie Kinder, können die Kosten für Kinderbetreuung eventuell übernommen werden.", "b": false}]}], "maxPoints": 6, "availablePoints": 6, "missing": 0, "pointsPerItem": 1}'::jsonb, 6),
    ('lv4', 'Lesen', 'Lesen, Teil 4', 9, 'Lesen Sie den Text. Entscheiden Sie, ob die Aussagen 37–39 richtig oder falsch sind.', 'mc', '{"passages": [{"paragraphs": [{"t": "Auszug aus den Allgemeinen Geschäftsbedingungen der Volkshochschule", "b": false}, {"t": "Allgemeines", "b": false}, {"t": "(1) Wer sich zu einem der Kurse der Volkshochschule, nachfolgend VHS genannt, anmeldet, erkennt die AGB und die Hausordnungen der jeweiligen Veranstaltungsorte an.", "b": false}, {"t": "Kündigung durch den/die Teilnehmer/in", "b": false}, {"t": "(1) Bei Abmeldung/Kündigung bis 10 Tage vor Kursbeginn werden die bereits gezahlten Kursgebühren und besondere Kosten in voller Höhe zurückgezahlt.", "b": false}, {"t": "(2) Bei späterer Abmeldung bis einen Werktag vor Kursbeginn sind 30% der Kursgebühr, mindestens jedoch 10 Euro zu zahlen. Besondere Kosten sind in voller Höhe zu zahlen.", "b": false}, {"t": "(3) Ab dem Tag des Kursbeginns besteht kein Anspruch auf Rückzahlung der Kursgebühr und der besonderen Kosten.", "b": false}, {"t": "(4) Rückzahlungen können in der Regel nur unbar erfolgen.", "b": false}, {"t": "Ummeldung", "b": false}, {"t": "Eine Ummeldung von einem Kurs in einen vergleichbaren anderen Kurs im laufenden Programm kann nur vor Kursbeginn und mit Zustimmung der VHS erfolgen. Bereits gezahlte Kursgebühren und besondere Kosten werden verrechnet.", "b": false}, {"t": "Teilnahmebescheinigungen", "b": false}, {"t": "Die Teilnahme an einem Kurs kann unter der Voraussetzung regelmäßiger Teilnahme auf Wunsch bescheinigt werden. Die Ausstellung einer Teilnahmebescheinigung ist bis spätestens zwei Jahre nach Ablauf des Jahres, in dem der Kurs beendet ist, möglich.", "b": false}]}], "maxPoints": 3, "availablePoints": 3, "missing": 0, "pointsPerItem": 1}'::jsonb, 7),
    ('lv5', 'Lesen', 'Lesen, Teil 5', 6, 'Lesen Sie den Text und schließen Sie die Lücken 40–45. Welche Lösung (a, b oder c) passt am besten?', 'mc', '{"passages": [{"paragraphs": [{"t": "Versandhaus", "b": false}, {"t": "Mode für Sie", "b": false}, {"t": "Postfach", "b": false}, {"t": "50100 Köln", "b": false}, {"t": "Berlin, den 5. Oktober 2010", "b": false}, {"t": "REKLAMATION", "b": false}, {"t": "Sehr geehrte Damen und Herren,", "b": false}, {"t": "am 20. November habe ich bei Ihnen eine Hose bestellt (Levis Jeans 501 31/32). Die Jeans ist am 27. November (40) mir angekommen. Leider musste ich (41), dass die Hose zu klein ist (29!/32). Ich bitte Sie, mir die Hose in der von mir bestellten (42) zuzusenden.", "b": false}, {"t": "Ich werde Ihnen die zu kleine Jeans (43). Auch bitte ich Sie, die Gebühren für die Rücksendung (Porto) zu (44).", "b": false}, {"t": "Vielen Dank für Ihre (45).", "b": false}, {"t": "Mit freundlichen Grüßen", "b": false}, {"t": "Sergej Naumenkow", "b": false}]}], "maxPoints": 6, "availablePoints": 6, "missing": 0, "pointsPerItem": 1}'::jsonb, 8),
    ('s1', 'Schreiben', 'Schreiben', 30, 'Wählen Sie Aufgabe A oder Aufgabe B. Zeigen Sie, was Sie können. Schreiben Sie möglichst viel. Schreiben Sie Ihren Text auf den Antwortbogen.', 'writing', '{"maxPoints": 20, "availablePoints": 20, "missing": 0, "pointsPerItem": 20}'::jsonb, 9)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'dtz-b1' and t.slug = 'modell-09'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('hv1', '1', 'Was soll Frau Schmidt machen?', '[{"key": "A", "text": "An die Schule schreiben."}, {"key": "B", "text": "Am Samstag in die Schule kommen."}, {"key": "C", "text": "Auf einen Brief warten."}]'::jsonb, 1, null::jsonb, 0),
    ('hv1', '2', 'Wann soll Svetlana am Kino sein?', '[{"key": "A", "text": "Um 20 Uhr."}, {"key": "B", "text": "Um kurz vor halb neun."}, {"key": "C", "text": "Um 20 Uhr 30."}]'::jsonb, 1, null::jsonb, 1),
    ('hv1', '3', 'Wann hat das Bürgeramt geöffnet?', '[{"key": "A", "text": "Täglich bis 18 Uhr."}, {"key": "B", "text": "Auch samstagmittags."}, {"key": "C", "text": "Auch samstagabends."}]'::jsonb, 1, null::jsonb, 2),
    ('hv1', '4', 'Sie müssen dringend zum Orthopäden. Was sollen Sie tun?', '[{"key": "A", "text": "Am 1. März vorbeikommen."}, {"key": "B", "text": "Am 1. März anrufen."}, {"key": "C", "text": "Eine andere Nummer anrufen."}]'::jsonb, 1, null::jsonb, 3),
    ('hv2', '5', 'Wo liegen Gegenstände auf der Straße?', '[{"key": "A", "text": "Auf der A 3."}, {"key": "B", "text": "Auf der A 5."}, {"key": "C", "text": "Auf der A 45."}]'::jsonb, 1, null::jsonb, 0),
    ('hv2', '6', 'Wie wird das Wetter am Sonntag?', '[{"key": "A", "text": "Es wird wärmer."}, {"key": "B", "text": "Es gibt Regen."}, {"key": "C", "text": "Es wird sehr windig."}]'::jsonb, 1, null::jsonb, 1),
    ('hv2', '7', 'Was hören Sie?', '[{"key": "A", "text": "Verkehrsmeldungen."}, {"key": "B", "text": "Die Nachrichten."}, {"key": "C", "text": "Tipps für Autobesitzer."}]'::jsonb, 1, null::jsonb, 2),
    ('hv2', '8', 'Wann kann man den Krimi sehen?', '[{"key": "A", "text": "Heute um 20.15 Uhr."}, {"key": "B", "text": "Es gibt noch keinen neuen Termin."}, {"key": "C", "text": "Morgen."}]'::jsonb, 1, null::jsonb, 3),
    ('hv2', '9', 'Die Bewohner des Stadtteils sollen', '[{"key": "A", "text": "die Feuerwehr anrufen."}, {"key": "B", "text": "die Löscharbeiten nicht stören."}, {"key": "C", "text": "ihre Wohnungen verlassen."}]'::jsonb, 1, null::jsonb, 4),
    ('hv3', '10', 'Die Kundin beschwert sich über eine Reparatur.', '[{"key": "A", "text": "richtig"}, {"key": "B", "text": "falsch"}]'::jsonb, 1, null::jsonb, 0),
    ('hv3', '11', 'Was bietet der Verkäufer an?', '[{"key": "A", "text": "Ein neues Fahrrad."}, {"key": "B", "text": "Ein Ersatzrad."}, {"key": "C", "text": "Geld für das alte Rad."}]'::jsonb, 1, null::jsonb, 1),
    ('hv3', '12', 'Der Sprecher will verreisen.', '[{"key": "A", "text": "richtig"}, {"key": "B", "text": "falsch"}]'::jsonb, 1, null::jsonb, 2),
    ('hv3', '13', 'Worum bittet der Mann Frau Scholz?', '[{"key": "A", "text": "Sie soll ihn im Urlaub anrufen."}, {"key": "B", "text": "Sie soll nach den Blumen sehen."}, {"key": "C", "text": "Sie soll wichtige Post an seine Adresse schicken."}]'::jsonb, 1, null::jsonb, 3),
    ('hv3', '14', 'Sie hören ein Gespräch zwischen einer Patientin und einer Apothekerin.', '[{"key": "A", "text": "richtig"}, {"key": "B", "text": "falsch"}]'::jsonb, 1, null::jsonb, 4),
    ('hv3', '15', 'Was ist richtig?', '[{"key": "A", "text": "Das Medikament kostet nichts."}, {"key": "B", "text": "Das Medikament kann man nicht mehr bekommen."}, {"key": "C", "text": "Das Medikament ist rezeptfrei."}]'::jsonb, 1, null::jsonb, 5),
    ('hv3', '16', 'Herr Braun und Herr Martin sind Kollegen.', '[{"key": "A", "text": "richtig"}, {"key": "B", "text": "falsch"}]'::jsonb, 1, null::jsonb, 6),
    ('hv3', '17', 'Kommt Herr Braun zur Versammlung?', '[{"key": "A", "text": "Nein, er muss arbeiten."}, {"key": "B", "text": "Nein, er hat Urlaub."}, {"key": "C", "text": "Er weiß es noch nicht genau."}]'::jsonb, 1, null::jsonb, 7),
    ('hv4', '18', 'Sprecher 1', null::jsonb, 1, null::jsonb, 0),
    ('hv4', '19', 'Sprecher 2', null::jsonb, 1, null::jsonb, 1),
    ('hv4', '20', 'Sprecher 3', null::jsonb, 1, null::jsonb, 2),
    ('lv1', '21', 'Sie interessieren sich für eine Kaffeemaschine.', '[{"key": "A", "text": "Feinschmecker"}, {"key": "B", "text": "Haushaltsgeräte"}, {"key": "C", "text": "andere Seite"}]'::jsonb, 1, null::jsonb, 0),
    ('lv1', '22', 'Sie suchen einen neuen Teppich.', '[{"key": "A", "text": "Wohnen"}, {"key": "B", "text": "Mode"}, {"key": "C", "text": "andere Seite"}]'::jsonb, 1, null::jsonb, 1),
    ('lv1', '23', 'Sie wollen Ihre Wohnung streichen und tapezieren.', '[{"key": "A", "text": "Wohnen"}, {"key": "B", "text": "Heimwerken & Garten"}, {"key": "C", "text": "andere Seite"}]'::jsonb, 1, null::jsonb, 2),
    ('lv1', '24', 'Sie möchten Ihrer Tochter eine Eintrittskarte für ein Konzert schenken.', '[{"key": "A", "text": "Audio & HiFi"}, {"key": "B", "text": "Geschenkartikel"}, {"key": "C", "text": "andere Seite"}]'::jsonb, 1, null::jsonb, 3),
    ('lv1', '25', 'Sie wollen mit dem Auto in den Urlaub fahren und brauchen Tabletten, weil Ihnen im Auto immer schlecht wird.', '[{"key": "A", "text": "Fit, Schön & Gesund"}, {"key": "B", "text": "Freizeit, Urlaub & Reise"}, {"key": "C", "text": "andere Seite"}]'::jsonb, 1, null::jsonb, 4),
    ('lv2', '26', 'Es ist Sonntagabend. Ihre Tochter hat plötzlich starke Kopfschmerzen und Sie brauchen ein Medikament für sie.', null::jsonb, 1, null::jsonb, 0),
    ('lv2', '27', 'Sie können schlecht schlafen und suchen Hilfe.', null::jsonb, 1, null::jsonb, 1),
    ('lv2', '28', 'Sie arbeiten viel am Computer und brauchen eine neue Brille.', null::jsonb, 1, null::jsonb, 2),
    ('lv2', '29', 'Sie möchten wissen, wie Sie Ihre Krankenkasse wechseln können.', null::jsonb, 1, null::jsonb, 3),
    ('lv2', '30', 'Sie haben jeden Morgen starke Rückenschmerzen. Sie suchen Hilfe.', null::jsonb, 1, null::jsonb, 4),
    ('lv3', '31', 'Am 24. April kann man in der Peter Petersen Grundschule günstig Sachen kaufen.', null::jsonb, 1, null::jsonb, 0),
    ('lv3', '32', 'Die Schulleitung möchte,', '[{"key": "A", "text": "dass die Eltern etwas zu essen und zu trinken mitbringen."}, {"key": "B", "text": "dass die Eltern eigene Tische mitbringen."}, {"key": "C", "text": "dass die Eltern eine kleine Gebühr bezahlen, wenn sie etwas verkaufen."}]'::jsonb, 1, null::jsonb, 1),
    ('lv3', '33', 'Im Haus werden alle Gasöfen ausgetauscht. Die Firma Bauer kommt in den nächsten Tagen vorbei.', null::jsonb, 1, null::jsonb, 2),
    ('lv3', '34', 'Die Kosten für Überprüfung und Reinigung', '[{"key": "A", "text": "zahlt der Vermieter."}, {"key": "B", "text": "muss der Mieter bezahlen."}, {"key": "C", "text": "sind dieses Jahr 20 Prozent geringer."}]'::jsonb, 1, null::jsonb, 3),
    ('lv3', '35', 'Die Kurse kann man auch besuchen, wenn man schon eine Arbeit hat.', null::jsonb, 1, null::jsonb, 4),
    ('lv3', '36', 'Wenn man an den Kursen teilnehmen möchte,', '[{"key": "A", "text": "muss man gleichzeitig einen Integrationskurs machen"}, {"key": "B", "text": "muss man gute Deutschkenntnisse (Niveau B1) haben."}, {"key": "C", "text": "kann man seine Kinder zum Unterricht mitnehmen."}]'::jsonb, 1, null::jsonb, 5),
    ('lv4', '37', 'Wenn ein Teilnehmer seine Anmeldung zurücknehmen möchte, muss er immer mindestens zehn Euro bezahlen.', null::jsonb, 1, null::jsonb, 0),
    ('lv4', '38', 'Man kann sich nicht mehr ummelden, wenn ein Kurs angefangen hat.', null::jsonb, 1, null::jsonb, 1),
    ('lv4', '39', 'Die VHS stellt für ihre Kurse automatisch Teilnahmebescheinigungen aus.', null::jsonb, 1, null::jsonb, 2),
    ('lv5', '40', 'Lücke 40', '[{"key": "A", "text": "an"}, {"key": "B", "text": "bei"}, {"key": "C", "text": "zu"}]'::jsonb, 1, null::jsonb, 0),
    ('lv5', '41', 'Lücke 41', '[{"key": "A", "text": "bestätigen"}, {"key": "B", "text": "festsetzen"}, {"key": "C", "text": "feststellen"}]'::jsonb, 1, null::jsonb, 1),
    ('lv5', '42', 'Lücke 42', '[{"key": "A", "text": "Größe"}, {"key": "B", "text": "Form"}, {"key": "C", "text": "Menge"}]'::jsonb, 1, null::jsonb, 2),
    ('lv5', '43', 'Lücke 43', '[{"key": "A", "text": "bestellen"}, {"key": "B", "text": "bezahlen"}, {"key": "C", "text": "zurückschicken"}]'::jsonb, 1, null::jsonb, 3),
    ('lv5', '44', 'Lücke 44', '[{"key": "A", "text": "überlegen"}, {"key": "B", "text": "übernehmen"}, {"key": "C", "text": "überprüfen"}]'::jsonb, 1, null::jsonb, 4),
    ('lv5', '45', 'Lücke 45', '[{"key": "A", "text": "Mühe"}, {"key": "B", "text": "Bestellung"}, {"key": "C", "text": "Auftrag"}]'::jsonb, 1, null::jsonb, 5),
    ('s1', '46', 'Aufgabe A: Sie haben die Fernsehzeitschrift „TV aktuell“ abonniert. Die Zeitschrift gefällt Ihnen nicht mehr und Sie möchten das Abonnement kündigen. Schreiben Sie an TV aktuell. Schreiben Sie etwas zu folgenden Punkten: - Grund für Ihr Schreiben - Was hat Ihnen nicht gefallen? - Zu welchem Termin können Sie kündigen? - Bitte um Bestätigung oder Aufgabe B: Sie möchten am nächsten Samstag im Baumarkt einkaufen. Jetzt ist Ihr Auto kaputt gegangen. Sie möchten das Auto Ihres Nachbarn, Herrn Scholz, für diesen Tag leihen. Schreiben Sie Herrn Scholz eine kurze Nachricht. Schreiben Sie etwas zu folgenden Punkten: - Grund für Ihr Schreiben - Wie lange Sie das Auto brauchen - Auch etwas für Herrn Scholz holen? - Als Dankeschön Einladung zum Essen', null::jsonb, 0, null::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'dtz-b1' and t.slug = 'modell-09'
join sections s on s.test_id = t.id and s.section_id = v.section_id
on conflict (section_id, item_id) do update set text = excluded.text, options = excluded.options, points = excluded.points, meta = excluded.meta, sort = excluded.sort;

insert into item_answers (item_id, answer, explanation)
select i.id, v.answer, v.explanation
from (values
    ('hv1', '1', 'C', null),
    ('hv1', '2', 'A', null),
    ('hv1', '3', 'B', null),
    ('hv1', '4', 'C', null),
    ('hv2', '5', 'B', null),
    ('hv2', '6', 'A', null),
    ('hv2', '7', 'C', null),
    ('hv2', '8', 'B', null),
    ('hv2', '9', 'B', null),
    ('hv3', '10', 'B', null),
    ('hv3', '11', 'B', null),
    ('hv3', '12', 'A', null),
    ('hv3', '13', 'B', null),
    ('hv3', '14', 'A', null),
    ('hv3', '15', 'A', null),
    ('hv3', '16', 'A', null),
    ('hv3', '17', 'C', null),
    ('hv4', '18', 'f', null),
    ('hv4', '19', 'c', null),
    ('hv4', '20', 'd', null),
    ('lv1', '21', 'B', null),
    ('lv1', '22', 'A', null),
    ('lv1', '23', 'B', null),
    ('lv1', '24', 'C', null),
    ('lv1', '25', 'A', null),
    ('lv2', '26', 'c', null),
    ('lv2', '27', 'b', null),
    ('lv2', '28', 'h', null),
    ('lv2', '29', 'x', null),
    ('lv2', '30', 'g', null),
    ('lv3', '31', 'richtig', null),
    ('lv3', '32', 'C', null),
    ('lv3', '33', 'falsch', null),
    ('lv3', '34', 'B', null),
    ('lv3', '35', 'richtig', null),
    ('lv3', '36', 'B', null),
    ('lv4', '37', 'falsch', null),
    ('lv4', '38', 'richtig', null),
    ('lv4', '39', 'falsch', null),
    ('lv5', '40', 'B', null),
    ('lv5', '41', 'C', null),
    ('lv5', '42', 'A', null),
    ('lv5', '43', 'C', null),
    ('lv5', '44', 'B', null),
    ('lv5', '45', 'A', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'dtz-b1' and t.slug = 'modell-09'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;

-- ================= modell-10 · BOUZIDI =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('dtz-b1', 'modell-10', 'BOUZIDI', '46 Aufgaben · 100 Minuten',
        '[{"id": "block-hoeren", "parts": ["hv1", "hv2", "hv3", "hv4"], "title": "Hören", "minutes": 25, "hint": "Aufgaben 1–20", "maxPoints": 20, "availablePoints": 20, "missing": 0}, {"id": "block-lesen", "parts": ["lv1", "lv2", "lv3", "lv4", "lv5"], "title": "Lesen", "minutes": 45, "hint": "Aufgaben 21–45", "maxPoints": 25, "availablePoints": 25, "missing": 0}, {"id": "block-schreiben", "parts": ["s1"], "title": "Schreiben", "minutes": 30, "hint": "Aufgabe 46", "maxPoints": 20, "availablePoints": 20, "missing": 0}]'::jsonb, 46, true, 9)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('hv1', 'Hören', 'Hören, Teil 1', 6, 'Sie hören vier Ansagen. Zu jeder Ansage gibt es eine Aufgabe. Welche Lösung (a, b oder c) passt am besten?', 'mc', '{"maxPoints": 4, "availablePoints": 4, "missing": 0, "pointsPerItem": 1, "audioPlays": 1}'::jsonb, 0),
    ('hv2', 'Hören', 'Hören, Teil 2', 5, 'Sie hören fünf Ansagen aus dem Radio. Zu jeder Ansage gibt es eine Aufgabe. Welche Lösung (a, b oder c) passt am besten?', 'mc', '{"maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1, "audioPlays": 1}'::jsonb, 1),
    ('hv3', 'Hören', 'Hören, Teil 3', 8, 'Sie hören vier Gespräche. Zu jedem Gespräch gibt es zwei Aufgaben. Entscheiden Sie bei jedem Gespräch, ob die Aussage dazu richtig oder falsch ist und welche Antwort (a, b oder c) am besten passt.', 'mc', '{"maxPoints": 8, "availablePoints": 8, "missing": 0, "pointsPerItem": 1, "audioPlays": 2}'::jsonb, 2),
    ('hv4', 'Hören', 'Hören, Teil 4', 6, 'Sie hören Aussagen zu einem Thema. Welcher der Sätze a–f passt zu den Aussagen 18–20?', 'matching', '{"bank": [{"key": "A", "text": "Die Politik müsste die Parkgebühren erhöhen."}, {"key": "B", "text": "Die Fahrpreise für Busse, Straßenbahnen, S- und U-Bahnen sollten niedriger sein."}, {"key": "C", "text": "Beim Umweltschutz müssten alle Länder zusammenarbeiten."}, {"key": "D", "text": "Man sollte weniger Verpackung herstellen."}, {"key": "E", "text": "Um die Umwelt zu schützen, sollte man weniger einkaufen."}, {"key": "F", "text": "Jeder Müll müsste kostenlos abgeholt werden."}], "bankTitle": "Aussagen zum Umweltschutz", "maxPoints": 3, "availablePoints": 3, "missing": 0, "pointsPerItem": 1, "audioPlays": 2}'::jsonb, 3),
    ('lv1', 'Lesen', 'Lesen, Teil 1', 10, 'Sie suchen Adressen, Telefonnummern und Tipps in Ihrem Stadtmagazin. Lesen Sie die Aufgaben 21–25 und das Inhaltsverzeichnis aus dem Stadtmagazin. In welcher Rubrik (a, b oder c) finden Sie die passende Information?', 'mc', '{"bankImage": "img/dtz-b1-m10-lv1.jpg", "maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1}'::jsonb, 4),
    ('lv2', 'Lesen', 'Lesen, Teil 2', 10, 'Lesen Sie die Situationen 26–30 und die Anzeigen a–h. Finden Sie für jede Situation die passende Anzeige. Für eine Aufgabe gibt es keine Lösung. Markieren Sie in diesem Fall ein x.', 'matching', '{"bank": [{"key": "A", "text": "Anzeige a"}, {"key": "B", "text": "Anzeige b"}, {"key": "C", "text": "Anzeige c"}, {"key": "D", "text": "Anzeige d"}, {"key": "E", "text": "Anzeige e"}, {"key": "F", "text": "Anzeige f"}, {"key": "G", "text": "Anzeige g"}, {"key": "H", "text": "Anzeige h"}, {"key": "X", "text": "Keine Anzeige passt"}], "bankTitle": "Anzeigen", "bankImage": "img/dtz-b1-m10-lv2.jpg", "maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1}'::jsonb, 5),
    ('lv3', 'Lesen', 'Lesen, Teil 3', 10, 'Lesen Sie die drei Texte. Zu jedem Text gibt es zwei Aufgaben. Entscheiden Sie bei jedem Text, ob die Aussage richtig oder falsch ist und welche Antwort (a, b oder c) am besten passt.', 'mc', '{"passages": [{"paragraphs": [{"t": "Sehr geehrte Familie Kowalski,", "b": false}, {"t": "aus dem Jahresabschluss für das letzte Jahr ergeben sich für Ihren Haushalt die folgenden Rechnungsbeträge:", "b": false}, {"t": "Strom Brutto: 623,58 €,", "b": false}, {"t": "Erdgas Brutto: 1 798,35 €,", "b": false}, {"t": "Gesamtbetrag: 2 421,93 €.", "b": false}, {"t": "Einzelheiten zur Berechnung entnehmen Sie bitte der beigefügten Aufstellung.", "b": false}, {"t": "Die Jahresabrechnung weist für Sie ein Guthaben von 252,20 € auf. Dieses haben wir in den monatlichen Abschlagzahlungen für dieses Jahr berücksichtigt, die sich deshalb auf 180 € monatlich reduzieren.", "b": false}, {"t": "Wir möchten Sie nochmals auf unser Aktionsangebot SuperSpar aufmerksam machen. Wenn Sie sich für eine Vertragslaufzeit bis zum Ende dieses Jahres verpflichten, können Sie 126,33 € Energiekosten pro Jahr sparen. Sie erhalten für diesen Zeitraum eine Preisgarantie.", "b": false}, {"t": "Das Angebot ist noch 14 Tage gültig.", "b": false}, {"t": "Vielen Dank für Ihr Vertrauen in uns, den Energieversorger Mainstrom.", "b": false}, {"t": "Mit freundlichen Grüßen", "b": false}, {"t": "Ihre Mainstrom AG", "b": false}]}, {"paragraphs": [{"t": "Liebe Eltern,", "b": false}, {"t": "für das nächste Schuljahr suchen wir wieder engagierte Eltern für unsere", "b": false}, {"t": "Hausaufgabenbetreuung.", "b": false}, {"t": "Haben Sie Lust, Schülern der Klassenstufe 5–7 zu helfen und Ihr Wissen und Ihre Erfahrungen weiterzugeben? Dann machen Sie mit!", "b": false}, {"t": "• Sie betreuen Kinder der Klassenstufen 5–7 in einer Gruppe von fünf bis zehn Schülern.", "b": false}, {"t": "• Sie verpflichten sich, an einem bestimmten Tag in der Woche bei der Hausaufgabenbetreuung mitzuhelfen.", "b": false}, {"t": "• Für Ihre Mitarbeit zahlen wir 8,00 Euro je abgehaltener Hausaufgabenbetreuung.", "b": false}, {"t": "• Die Betreuung wird mindestens an einem Tag in der Woche angeboten. Wenn die Nachfrage sehr groß ist und genügend Eltern mithelfen, kann das Angebot auch täglich stattfinden.", "b": false}, {"t": "Die Schule plant einen Info-Abend, an dem wir Ihnen Ihre Aufgaben näher vorstellen und Ihre Fragen beantworten wollen. Über den Termin informieren wir Sie rechtzeitig.", "b": false}]}, {"paragraphs": [{"t": "INTEGRATION UND BERUFSORIENTIERUNG", "b": false}, {"t": "Die neue interkulturelle Internet-Seite Mixopolis ist ein Projekt des Vereins Schulen ans Netz. Mit diesem Projekt soll ein Beitrag zur Integration geleistet werden. Mixopolis will gezielt junge Menschen mit Migrationshintergrund ansprechen, weil diese häufig das Internet als Kommunikationsmedium nutzen.", "b": false}, {"t": "Bei Mixopolis können Jugendliche ihre Ideen und Gedanken austauschen, dabei spielt es keine Rolle, woher sie kommen: aus Deutschland oder aus anderen Ländern. Man kann hier Ideen und Ratschläge zu den Themen Schule und Studium, Ausbildung und Bewerbung finden. Auch Fragen zum Medienalltag oder zum Studentenleben werden angesprochen.", "b": false}, {"t": "Nach kostenloser Anmeldung bekommen Jugendliche wichtige Informationen zu Wettbewerben, Aktionen und Messen. Besucher der Website, die sich in neuer Software auskennen, können hierzu Berichte schreiben. Außerdem werden aktuelle Kinofilme vorgestellt, Berufe präsentiert und berühmte Persönlichkeiten interviewt. Junge Menschen vor allem mit Migrationshintergrund beantworten online Fragen zu den verschiedensten Bereichen, unter anderem zum Berufsleben und zu gesellschaftlichen Problemen.", "b": false}]}], "maxPoints": 6, "availablePoints": 6, "missing": 0, "pointsPerItem": 1}'::jsonb, 6),
    ('lv4', 'Lesen', 'Lesen, Teil 4', 9, 'Lesen Sie den Text. Entscheiden Sie, ob die Aussagen 37–39 richtig oder falsch sind.', 'mc', '{"passages": [{"paragraphs": [{"t": "PATIENTENINFORMATION", "b": false}, {"t": "Was tun, wenn Ihnen hohe Kosten für eine Zahnbehandlung entstehen?", "b": false}, {"t": "Die Lösung: Teilzahlung! Zahlen Sie in monatlichen Raten.", "b": false}, {"t": "Sie selbst bestimmen nicht nur die Höhe der monatlichen Raten, sondern auch, wann jeden Monat die Zahlung von Ihrem Konto abgebucht wird.", "b": false}, {"t": "Teilzahlungsmodell A", "b": false}, {"t": "Wenn Sie Ihre Zahnarztrechnung in maximal sechs gleich hohen Monatsraten bezahlen, entstehen Ihnen aus der Teilzahlung keine zusätzlichen Kosten. Achten Sie bitte unbedingt darauf, dass Ihr schriftlicher Teilzahlungswunsch und die erste Zahlung innerhalb von 30 Tagen nach Rechnungsdatum bei uns eingehen. Sie müssen den Rechnungsbetrag innerhalb von sechs Monaten ab Rechnungsdatum vollständig bezahlen.", "b": false}, {"t": "Teilzahlungsmodell B", "b": false}, {"t": "Sie möchten den Rechnungsbetrag über einen längeren Zeitraum als sechs Monate aufteilen. Wenn Sie sich für Teilzahlungen mit einer Gesamtlaufzeit von mehr als sechs Monaten ab Rechnungsdatum entscheiden, berechnen wir Zinsen von 0,5 % monatlich. Außerdem berechnen wir eine einmalige Bearbeitungsgebühr von 1 % aus der Forderung, mindestens jedoch € 10.", "b": false}, {"t": "Stellen Sie heute noch Ihren Antrag.", "b": false}, {"t": "Ihre Abrechnungsstelle für Zahnärzte", "b": false}]}], "maxPoints": 3, "availablePoints": 3, "missing": 0, "pointsPerItem": 1}'::jsonb, 7),
    ('lv5', 'Lesen', 'Lesen, Teil 5', 6, 'Lesen Sie den Text und schließen Sie die Lücken 40–45. Welche Lösung (a, b oder c) passt am besten?', 'mc', '{"passages": [{"paragraphs": [{"t": "SCHNEIDER TECHNIK", "b": false}, {"t": "Hauptstraße 12 · 70563 Stuttgart · Telefon: 0711-5422132", "b": false}, {"t": "Frau", "b": false}, {"t": "Ilona Lanz", "b": false}, {"t": "Mauserstraße 4", "b": false}, {"t": "70468 Stuttgart", "b": false}, {"t": "Stuttgart, 30. November 2010", "b": false}, {"t": "Zahlungserinnerung – Unsere Rechnung vom 8. Oktober 2010", "b": false}, {"t": "Sehr geehrte Frau Lanz,", "b": false}, {"t": "Leider (40) wir Sie daran erinnern, dass unsere Rechnung vom 8. Oktober 2010 bereits vor einem Monat (41) war. Bis heute konnten wir keine Überweisung von Ihnen feststellen.", "b": false}, {"t": "Wir bitten Sie, den zu zahlenden (42) spätestens bis zum 10. Dezember 2010 auf unser Konto bei der Postbank Stuttgart Kontonummer 31928-707 BLZ 760 100 85 zu überweisen.", "b": false}, {"t": "(43) Sie die Rechnung inzwischen bezahlt haben, betrachten Sie bitte dieses Schreiben als gegenstandslos.", "b": false}, {"t": "Haben Sie Fragen? Unser Mitarbeiter Herr Groß gibt (44) unter der oben angegebenen Telefonnummer gerne Auskunft.", "b": false}, {"t": "Mit freundlichen (45)", "b": false}, {"t": "i. A. Schneider", "b": false}]}], "maxPoints": 6, "availablePoints": 6, "missing": 0, "pointsPerItem": 1}'::jsonb, 8),
    ('s1', 'Schreiben', 'Schreiben', 30, 'Wählen Sie Aufgabe A oder Aufgabe B. Zeigen Sie, was Sie können. Schreiben Sie möglichst viel. Schreiben Sie Ihren Text auf den Antwortbogen.', 'writing', '{"maxPoints": 20, "availablePoints": 20, "missing": 0, "pointsPerItem": 20}'::jsonb, 9)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'dtz-b1' and t.slug = 'modell-10'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('hv1', '1', 'Sie müssen heute noch zum Arzt. Welche Nummer müssen Sie anrufen?', '[{"key": "A", "text": "19292."}, {"key": "B", "text": "457732."}, {"key": "C", "text": "0160 3221320."}]'::jsonb, 1, null::jsonb, 0),
    ('hv1', '2', 'Sie möchten sich für einen Deutschkurs anmelden. Was sollen Sie tun?', '[{"key": "A", "text": "Sich im Kurs anmelden."}, {"key": "B", "text": "Montags oder mittwochs vorbeikommen."}, {"key": "C", "text": "Die Nummer 21271555 wählen."}]'::jsonb, 1, null::jsonb, 1),
    ('hv1', '3', 'Was für eine Wohnung kann Familie Kim bekommen?', '[{"key": "A", "text": "Eine 3-Zimmer-Wohnung."}, {"key": "B", "text": "Eine Wohnung mit Balkon."}, {"key": "C", "text": "Eine 2-Zimmer-Wohnung."}]'::jsonb, 1, null::jsonb, 2),
    ('hv1', '4', 'Was soll Herr Bouzidi tun?', '[{"key": "A", "text": "Die Firma Thor anrufen."}, {"key": "B", "text": "Zwischen 17 und 19 Uhr bei der Firma Thor vorbeikommen."}, {"key": "C", "text": "Den Gasherd anschließen."}]'::jsonb, 1, null::jsonb, 3),
    ('hv2', '5', 'Was hören Sie?', '[{"key": "A", "text": "Den Wetterbericht."}, {"key": "B", "text": "Eine Verkehrsmeldung."}, {"key": "C", "text": "Die Nachrichten."}]'::jsonb, 1, null::jsonb, 0),
    ('hv2', '6', 'Wie wird das Wetter im Norden?', '[{"key": "A", "text": "Es wird wärmer."}, {"key": "B", "text": "Es wird kühl."}, {"key": "C", "text": "Es regnet."}]'::jsonb, 1, null::jsonb, 1),
    ('hv2', '7', 'Wo gibt es einen Stau?', '[{"key": "A", "text": "Auf der A 3."}, {"key": "B", "text": "Auf der A 8."}, {"key": "C", "text": "Auf der A 9."}]'::jsonb, 1, null::jsonb, 2),
    ('hv2', '8', 'Auf der Silvesterparty', '[{"key": "A", "text": "treten Gruppen aus verschiedenen Ländern auf."}, {"key": "B", "text": "gibt es nur Musik in deutscher Sprache."}, {"key": "C", "text": "kann man Preise gewinnen."}]'::jsonb, 1, null::jsonb, 3),
    ('hv2', '9', 'Bis wann müssen Sie Ihre Versicherung kündigen?', '[{"key": "A", "text": "Bis Ende November."}, {"key": "B", "text": "Bis zum Jahresende."}, {"key": "C", "text": "Es gibt keinen festen Termin."}]'::jsonb, 1, null::jsonb, 4),
    ('hv3', '10', 'Die Kundin bringt ihren Computer zur Reparatur.', '[{"key": "A", "text": "richtig"}, {"key": "B", "text": "falsch"}]'::jsonb, 1, null::jsonb, 0),
    ('hv3', '11', 'Die Kundin', '[{"key": "A", "text": "braucht den Computer erst am Donnerstag."}, {"key": "B", "text": "braucht den Computer für die Arbeit."}, {"key": "C", "text": "möchte am liebsten einen Laptop kaufen."}]'::jsonb, 1, null::jsonb, 1),
    ('hv3', '12', 'Herr Tsegai ist zurzeit arbeitslos.', '[{"key": "A", "text": "richtig"}, {"key": "B", "text": "falsch"}]'::jsonb, 1, null::jsonb, 2),
    ('hv3', '13', 'Welche Pläne hat Herr Tsegai?', '[{"key": "A", "text": "Er möchte einen Deutschkurs machen."}, {"key": "B", "text": "Er sucht eine Ausbildung als Verkäufer."}, {"key": "C", "text": "Er möchte als Bäcker arbeiten."}]'::jsonb, 1, null::jsonb, 3),
    ('hv3', '14', 'Das Gespräch findet in der Kinderbibliothek statt.', '[{"key": "A", "text": "richtig"}, {"key": "B", "text": "falsch"}]'::jsonb, 1, null::jsonb, 4),
    ('hv3', '15', 'In der Kinderbibliothek', '[{"key": "A", "text": "werden auch Filme gezeigt."}, {"key": "B", "text": "kann man Filme für zwei Euro ausleihen."}, {"key": "C", "text": "kann man sehr günstig alte Bücher kaufen."}]'::jsonb, 1, null::jsonb, 5),
    ('hv3', '16', 'Die Kundin möchte eine Ware zurückgeben.', '[{"key": "A", "text": "richtig"}, {"key": "B", "text": "falsch"}]'::jsonb, 1, null::jsonb, 6),
    ('hv3', '17', 'Was ist das Problem?', '[{"key": "A", "text": "Die Kundin hat den Kassenzettel verloren."}, {"key": "B", "text": "Die Ware ist nicht frisch."}, {"key": "C", "text": "Die Kasse ist geschlossen."}]'::jsonb, 1, null::jsonb, 7),
    ('hv4', '18', 'Sprecher 1', null::jsonb, 1, null::jsonb, 0),
    ('hv4', '19', 'Sprecher 2', null::jsonb, 1, null::jsonb, 1),
    ('hv4', '20', 'Sprecher 3', null::jsonb, 1, null::jsonb, 2),
    ('lv1', '21', 'Ihr Kind hat etwas Schlechtes gegessen und ist sehr krank.', '[{"key": "A", "text": "Hilfe"}, {"key": "B", "text": "Kinder & Jugend"}, {"key": "C", "text": "andere Rubrik"}]'::jsonb, 1, null::jsonb, 0),
    ('lv1', '22', 'Sie möchten wissen, ob in Ihrer Stadt Ihr alter Fernseher kostenlos abgeholt wird.', '[{"key": "A", "text": "Kommunikation & Medien"}, {"key": "B", "text": "Wohnen"}, {"key": "C", "text": "andere Rubrik"}]'::jsonb, 1, null::jsonb, 1),
    ('lv1', '23', 'Sie suchen Adressen, wo Ihre Kinder nachmittags betreut werden können.', '[{"key": "A", "text": "Kinder & Jugend"}, {"key": "B", "text": "Wohnen"}, {"key": "C", "text": "andere Rubrik"}]'::jsonb, 1, null::jsonb, 2),
    ('lv1', '24', 'Ein Kollege besucht Sie. Er sucht ein Zimmer für zwei Monate in einer Wohngemeinschaft.', '[{"key": "A", "text": "Soziale Einrichtungen"}, {"key": "B", "text": "Besucher"}, {"key": "C", "text": "andere Rubrik"}]'::jsonb, 1, null::jsonb, 3),
    ('lv1', '25', 'Sie möchten ein Abendessen machen und suchen ein Kochbuch mit Tipps für ein Essen aus der Region.', '[{"key": "A", "text": "Besucher"}, {"key": "B", "text": "Einkaufen"}, {"key": "C", "text": "andere Rubrik"}]'::jsonb, 1, null::jsonb, 4),
    ('lv2', '26', 'Ihr Bruder hat gerade angefangen, Deutsch zu lernen. Er möchte als KfZ-Mechaniker oder Schlosser arbeiten.', null::jsonb, 1, null::jsonb, 0),
    ('lv2', '27', 'Sie möchten sich selbstständig machen, wissen aber noch nicht, ob das das Richtige für Sie ist, und suchen Informationen.', null::jsonb, 1, null::jsonb, 1),
    ('lv2', '28', 'Sie arbeiten in einem Büro und möchten sich weiterbilden. Sie möchten besser mit dem Computer arbeiten können.', null::jsonb, 1, null::jsonb, 2),
    ('lv2', '29', 'Sie suchen einen Job in einem Restaurant. Sie haben den ganzen Juli über Zeit für den Job.', null::jsonb, 1, null::jsonb, 3),
    ('lv2', '30', 'Nach Ihrem Integrationskurs möchten Sie Deutsch für den Beruf lernen, mündlich und schriftlich. Ihr Berufswunsch ist die Arbeit in einem Restaurant. In Ihrer Heimat haben Sie Koch/Köchin gelernt.', null::jsonb, 1, null::jsonb, 4),
    ('lv3', '31', 'Familie Kowalski hat im letzten Jahr zu viel an die Mainstrom AG gezahlt.', null::jsonb, 1, null::jsonb, 0),
    ('lv3', '32', 'Familie Kowalski kann Geld sparen,', '[{"key": "A", "text": "wenn sie monatlich 180 € überweist."}, {"key": "B", "text": "wenn sie bis Ende des Jahres den Energieanbieter nicht wechselt."}, {"key": "C", "text": "wenn sie sich bis Ende des Jahres für den Tarif SuperSpar entscheidet."}]'::jsonb, 1, null::jsonb, 1),
    ('lv3', '33', 'Die Schule sucht Kinder für die Hausaufgabenbetreuung.', null::jsonb, 1, null::jsonb, 2),
    ('lv3', '34', 'Die Hausaufgabenbetreuung', '[{"key": "A", "text": "gibt es täglich."}, {"key": "B", "text": "kostet 8,00 € pro Stunde."}, {"key": "C", "text": "wird auf einer Veranstaltung der Schule genauer vorgestellt."}]'::jsonb, 1, null::jsonb, 3),
    ('lv3', '35', 'Beim Projekt Mixopolis haben Jugendliche die Möglichkeit, sich im Internet gegenseitig von ihren Erfahrungen und Problemen zu berichten.', null::jsonb, 1, null::jsonb, 4),
    ('lv3', '36', 'Auf der Internet-Seite Mixopolis können Jugendliche', '[{"key": "A", "text": "kostenlos Filme und Software bekommen."}, {"key": "B", "text": "sich beraten lassen."}, {"key": "C", "text": "Sachen kaufen und verkaufen."}]'::jsonb, 1, null::jsonb, 5),
    ('lv4', '37', 'Die Teilzahlungen sind nur zinsfrei, wenn Sie Ihre Zahnarztrechnung innerhalb von 30 Tagen bezahlen.', null::jsonb, 1, null::jsonb, 0),
    ('lv4', '38', 'Wenn Sie länger als sechs Monate bezahlen, entstehen Ihnen neben den Zinsen noch weitere Kosten.', null::jsonb, 1, null::jsonb, 1),
    ('lv4', '39', 'Sie können selbst festlegen, an welchem Tag im Monat Sie die Raten zahlen möchten.', null::jsonb, 1, null::jsonb, 2),
    ('lv5', '40', 'Lücke 40', '[{"key": "A", "text": "können"}, {"key": "B", "text": "sollen"}, {"key": "C", "text": "müssen"}]'::jsonb, 1, null::jsonb, 0),
    ('lv5', '41', 'Lücke 41', '[{"key": "A", "text": "bezahlt"}, {"key": "B", "text": "fällig"}, {"key": "C", "text": "gefallen"}]'::jsonb, 1, null::jsonb, 1),
    ('lv5', '42', 'Lücke 42', '[{"key": "A", "text": "Betrag"}, {"key": "B", "text": "Rechnung"}, {"key": "C", "text": "Zahlung"}]'::jsonb, 1, null::jsonb, 2),
    ('lv5', '43', 'Lücke 43', '[{"key": "A", "text": "Als"}, {"key": "B", "text": "Wann"}, {"key": "C", "text": "Wenn"}]'::jsonb, 1, null::jsonb, 3),
    ('lv5', '44', 'Lücke 44', '[{"key": "A", "text": "euch"}, {"key": "B", "text": "Ihnen"}, {"key": "C", "text": "Sie"}]'::jsonb, 1, null::jsonb, 4),
    ('lv5', '45', 'Lücke 45', '[{"key": "A", "text": "Gruß"}, {"key": "B", "text": "Grüße"}, {"key": "C", "text": "Grüßen"}]'::jsonb, 1, null::jsonb, 5),
    ('s1', '46', 'Aufgabe A: Sie haben seit einiger Zeit einen Telefon- und Internetanschluss bei der Firma Internet & Telefon. Seit einiger Zeit funktionieren Ihr Telefon und Internet nicht mehr gut. Sie schreiben deshalb einen Brief. Schreiben Sie etwas zu folgenden Punkten: - Grund für Ihr Schreiben - Was schlagen Sie vor? - Wenn keine Lösung, dann Vertrag kündigen - Bitte um schnelle Antwort oder Aufgabe B: Sie haben in Ihrer Tageszeitung eine Wohnungsanzeige gesehen, die Sie interessiert. Schreiben Sie einen Brief an die zuständige Mitarbeiterin der Hausverwaltung Hausmann & Gärtner, Frau Busch. Schreiben Sie etwas zu folgenden Punkten: - Grund für Ihr Schreiben - Angaben zu Ihrer Person - Fragen zur Wohnung - Besichtigungstermin?', null::jsonb, 0, null::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'dtz-b1' and t.slug = 'modell-10'
join sections s on s.test_id = t.id and s.section_id = v.section_id
on conflict (section_id, item_id) do update set text = excluded.text, options = excluded.options, points = excluded.points, meta = excluded.meta, sort = excluded.sort;

insert into item_answers (item_id, answer, explanation)
select i.id, v.answer, v.explanation
from (values
    ('hv1', '1', 'B', null),
    ('hv1', '2', 'B', null),
    ('hv1', '3', 'C', null),
    ('hv1', '4', 'B', null),
    ('hv2', '5', 'B', null),
    ('hv2', '6', 'B', null),
    ('hv2', '7', 'B', null),
    ('hv2', '8', 'A', null),
    ('hv2', '9', 'A', null),
    ('hv3', '10', 'A', null),
    ('hv3', '11', 'B', null),
    ('hv3', '12', 'A', null),
    ('hv3', '13', 'B', null),
    ('hv3', '14', 'A', null),
    ('hv3', '15', 'A', null),
    ('hv3', '16', 'A', null),
    ('hv3', '17', 'A', null),
    ('hv4', '18', 'b', null),
    ('hv4', '19', 'd', null),
    ('hv4', '20', 'a', null),
    ('lv1', '21', 'A', null),
    ('lv1', '22', 'B', null),
    ('lv1', '23', 'A', null),
    ('lv1', '24', 'C', null),
    ('lv1', '25', 'A', null),
    ('lv2', '26', 'x', null),
    ('lv2', '27', 'b', null),
    ('lv2', '28', 'f', null),
    ('lv2', '29', 'e', null),
    ('lv2', '30', 'd', null),
    ('lv3', '31', 'richtig', null),
    ('lv3', '32', 'C', null),
    ('lv3', '33', 'falsch', null),
    ('lv3', '34', 'C', null),
    ('lv3', '35', 'richtig', null),
    ('lv3', '36', 'B', null),
    ('lv4', '37', 'falsch', null),
    ('lv4', '38', 'richtig', null),
    ('lv4', '39', 'richtig', null),
    ('lv5', '40', 'C', null),
    ('lv5', '41', 'B', null),
    ('lv5', '42', 'A', null),
    ('lv5', '43', 'C', null),
    ('lv5', '44', 'B', null),
    ('lv5', '45', 'C', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'dtz-b1' and t.slug = 'modell-10'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;


commit;
