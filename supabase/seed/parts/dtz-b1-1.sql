-- جزء 1 من 4 — نماذج modell-01–modell-03
-- مولّد من supabase/seed/dtz-b1.sql بـtools/split_seed.sh — لا تعدّله بالإيد
-- آمن للإعادة: شغّله مرتين ما بيغيّر شي.

begin;

-- مولّد من content/dtz/b1 بـtools/export_sql.py — لا تعدّله بالإيد

insert into levels (id, title, sort, published, provider, stufe) values ('dtz-b1', 'Deutsch-Test für Zuwanderer B1', 0, true, 'DTZ', 'B1')
on conflict (id) do update set title = excluded.title,
  provider = coalesce(levels.provider, excluded.provider),
  stufe    = coalesce(levels.stufe,    excluded.stufe);

-- ================= modell-01 · HANSEN =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('dtz-b1', 'modell-01', 'HANSEN', '46 Aufgaben · 100 Minuten',
        '[{"id": "block-hoeren", "parts": ["hv1", "hv2", "hv3", "hv4"], "title": "Hören", "minutes": 25, "hint": "Aufgaben 1–20", "maxPoints": 20, "availablePoints": 20, "missing": 0}, {"id": "block-lesen", "parts": ["lv1", "lv2", "lv3", "lv4", "lv5"], "title": "Lesen", "minutes": 45, "hint": "Aufgaben 21–45", "maxPoints": 25, "availablePoints": 25, "missing": 0}, {"id": "block-schreiben", "parts": ["s1"], "title": "Schreiben", "minutes": 30, "hint": "Aufgabe 46", "maxPoints": 20, "availablePoints": 20, "missing": 0}]'::jsonb, 46, true, 1)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('hv1', 'Hören', 'Hören, Teil 1', 6, 'Sie hören vier Ansagen. Zu jeder Ansage gibt es eine Aufgabe. Welche Lösung (a, b oder c) passt am besten?', 'mc', '{"maxPoints": 4, "availablePoints": 4, "missing": 0, "pointsPerItem": 1, "audioPlays": 1}'::jsonb, 0),
    ('hv2', 'Hören', 'Hören, Teil 2', 7, 'Sie hören fünf Ansagen aus dem Radio. Zu jeder Ansage gibt es eine Aufgabe. Welche Lösung (a, b oder c) passt am besten?', 'mc', '{"maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1, "audioPlays": 1}'::jsonb, 1),
    ('hv3', 'Hören', 'Hören, Teil 3', 8, 'Sie hören vier Gespräche. Zu jedem Gespräch gibt es zwei Aufgaben. Entscheiden Sie bei jedem Gespräch, ob die Aussage dazu richtig oder falsch ist und welche Antwort (a, b oder c) am besten passt.', 'mc', '{"maxPoints": 8, "availablePoints": 8, "missing": 0, "pointsPerItem": 1, "audioPlays": 1}'::jsonb, 2),
    ('hv4', 'Hören', 'Hören, Teil 4', 4, 'Sie hören Aussagen zu einem Thema. Welcher der Sätze a–f passt zu den Aussagen 18–20?', 'matching', '{"bank": [{"key": "A", "text": "Für die Erziehung sind nur die Eltern verantwortlich."}, {"key": "B", "text": "Kinder lernen auch im Kindergarten sehr viel."}, {"key": "C", "text": "Kinder unter drei Jahren sollten zu Hause bleiben."}, {"key": "D", "text": "Kleinkinder lernen am besten von ihren Müttern."}, {"key": "E", "text": "Nicht jedes Kind braucht einen Kindergartenplatz."}, {"key": "F", "text": "Schon kleine Kinder brauchen Kontakt zu anderen Kindern."}], "bankTitle": "Aussagen", "maxPoints": 3, "availablePoints": 3, "missing": 0, "pointsPerItem": 1, "audioPlays": 1}'::jsonb, 3),
    ('lv1', 'Lesen', 'Lesen, Teil 1', 10, 'Sie suchen im Internet Informationen. Wo klicken Sie an?', 'mc', '{"bankImage": "img/dtz-b1-m01-lv1.jpg", "maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1}'::jsonb, 4),
    ('lv2', 'Lesen', 'Lesen, Teil 2', 10, 'Finden Sie zu jeder Situation (26–30) die passende Anzeige (a–h). Für eine Aufgabe gibt es keine passende Anzeige. Markieren Sie in diesem Fall ein x.', 'matching', '{"bank": [{"key": "A", "text": "Anzeige a"}, {"key": "B", "text": "Anzeige b"}, {"key": "C", "text": "Anzeige c"}, {"key": "D", "text": "Anzeige d"}, {"key": "E", "text": "Anzeige e"}, {"key": "F", "text": "Anzeige f"}, {"key": "G", "text": "Anzeige g"}, {"key": "H", "text": "Anzeige h"}, {"key": "X", "text": "Keine Anzeige passt"}], "bankTitle": "Anzeigen", "bankImage": "img/dtz-b1-m01-lv2.jpg", "maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1}'::jsonb, 5),
    ('lv3', 'Lesen', 'Lesen, Teil 3', 10, 'Lesen Sie die drei Texte. Zu jedem Text gibt es zwei Aufgaben. Entscheiden Sie, ob die Aussage richtig oder falsch ist und welche Antwort (a, b oder c) am besten passt.', 'mc', '{"passages": [{"paragraphs": [{"t": "Hilfe für Zuwanderer", "b": true}, {"t": "Die Regierung des Landes Hessen will dafür sorgen, dass alle Personen, die Migranten bei der Integration helfen, besser zusammenarbeiten. Zwischen den Projekten in den verschiedenen Orten des Landes gab es bisher kaum Kommunikation. Bis heute haben in hessischen Gemeinden mehr als 800 Helfer Zuwanderer bei der Integration in die deutsche Gesellschaft unterstützt, ohne dafür Geld zu bekommen. Ab Januar wird das Land Hessen die Arbeit der Helfer erstmalig mit 500.000 Euro fördern. Zur Verteilung dieses Geldes wird eine Geschäftsstelle eröffnet. „Damit werden wir zwar die Arbeit der Integrationshelfer nicht ganz bezahlen können. Die Zusammenarbeit der zahlreichen örtlichen Hilfsprojekte wird aber sicher besser werden“, sagte Staatssekretärin Silvia Plassmann am Montag in Kassel.", "b": false}]}, {"paragraphs": [{"t": "Liebe Eltern,", "b": true}, {"t": "am kommenden Samstag, dem 18. Juli, findet in der Villa Kunterbunt das alljährliche Kindergartensommerfest statt.", "b": false}, {"t": "Die verschiedenen Kindergruppen zeigen ein buntes Programm, das in diesem Jahr unter dem Thema „Sommerblumen“ steht. Die Kinder haben dazu Kostüme gebastelt und Lieder einstudiert. Nach den Aufführungen gibt es Spiel und Spaß im Hof mit Kaffee und Kuchen für Alt und Jung. Dazu möchten wir alle Eltern ganz herzlich einladen.", "b": false}, {"t": "Wir bitten Sie außerdem, zu unserem Kuchenbuffet etwas beizutragen oder uns mit einer kleinen Geldspende zu unterstützen.", "b": false}, {"t": "Bitte teilen Sie uns auf dem Formular mit, mit wie vielen Personen Sie kommen und was Sie für das Buffet mitbringen.", "b": false}, {"t": "Ihr Kindergartenteam", "b": false}]}, {"paragraphs": [{"t": "Sehr geehrte Familie Müller,", "b": true}, {"t": "wir haben die Nebenkosten für die Zeit vom 1.1. bis 31.12. des vergangenen Jahres abgerechnet. Die Abrechnung schließt mit einem Guthaben in Höhe von 150 Euro ab. Damit reduziert sich Ihre monatliche Nebenkostenvorauszahlung zukünftig um 12 Euro, so dass die Gesamtmiete ab 1. Februar nur noch 612,50 Euro beträgt.", "b": false}, {"t": "Die genaue Zusammensetzung der Nebenkostenabrechnung entnehmen Sie bitte den folgenden Seiten.", "b": false}, {"t": "Mit freundlichen Grüßen", "b": false}, {"t": "Ihre Hausverwaltung", "b": false}]}], "maxPoints": 6, "availablePoints": 6, "missing": 0, "pointsPerItem": 1}'::jsonb, 6),
    ('lv4', 'Lesen', 'Lesen, Teil 4', 7, 'Lesen Sie den Text und die Aufgaben 37 bis 39. Kreuzen Sie an: Richtig oder Falsch.', 'truefalse', '{"passages": [{"paragraphs": [{"t": "KOPFSCHMERZFREI plus", "b": true}, {"t": "Produktinformation", "b": false}, {"t": "Kopfschmerzfrei plus 400 mg Dragees – schmerzstillendes, entzündungshemmendes und fiebersenkendes Mittel.", "b": false}, {"t": "Hinweise zur Einnahme", "b": false}, {"t": "Die Tabletten sollten mit ausreichend Flüssigkeit (z. B. ein Glas Wasser) während der Mahlzeiten oder nach den Mahlzeiten eingenommen werden.", "b": false}, {"t": "Weitere Informationen", "b": false}, {"t": "Vor der Einnahme ist der Arzt über bestehende Krankheiten und Überempfindlichkeitsreaktionen zu informieren, da es unter Umständen zu Wechselwirkungen bzw. Erhöhung oder Senkung der Wirksamkeit anderer Arzneimittel kommen kann. Während der Frühschwangerschaft, Stillzeit und bei Leberfunktionsstörungen, vorgeschädigter Niere, Magen-Darm-Beschwerden, Magen-Darm-Geschwüren, Bluthochdruck oder Herzleistungsschwäche und Allergieleiden sollte das Mittel nur unter ärztlicher Aufsicht bzw. nach Rücksprache angewendet werden. Die aktive Teilnahme am Straßenverkehr und die Bedienung von Maschinen ist uneingeschränkt möglich.", "b": false}, {"t": "Gegenanzeigen von Kopfschmerzfrei plus 400 mg Dragees", "b": false}, {"t": "Kopfschmerzfrei plus darf nicht angewandt werden: bei bekannter Überempfindlichkeit gegenüber einem der Bestandteile, ungeklärten Blutbildungsstörungen, Magen-Darm-Geschwüren, im letzten Drittel der Schwangerschaft, bei Kindern unter 14 Jahren.", "b": false}]}], "maxPoints": 3, "availablePoints": 3, "missing": 0, "pointsPerItem": 1}'::jsonb, 7),
    ('lv5', 'Lesen', 'Lesen, Teil 5 (Sprachbausteine)', 8, 'Wählen Sie für jede Lücke (40–45) das richtige Wort (a, b oder c).', 'mc', '{"passages": [{"paragraphs": [{"t": "Norddeutsche Zeitung (NZ)", "b": true}, {"t": "Leseservice", "b": false}, {"t": "Tietjenstr. 33", "b": false}, {"t": "20546 Hamburg", "b": false}, {"t": "Hamburg, 20.5. ...", "b": false}, {"t": "Kündigung des Probeabonnements", "b": false}, {"t": "Kundennummer 522543786", "b": false}, {"t": "(40) Damen und Herren,", "b": false}, {"t": "die zwei Wochen Probelesen Ihrer Tageszeitung enden für (41) am 17.5.2008. Hiermit (42) ich mein Probeabonnement fristgerecht kündigen. Leider (43) ich feststellen, dass ich nicht genug Zeit für regelmäßiges Zeitung lesen habe. (44) möchte ich die Norddeutsche Zeitung nicht weiter abonnieren.", "b": false}, {"t": "Mit (45) Grüßen", "b": false}, {"t": "Norbert Schultze", "b": false}]}], "maxPoints": 6, "availablePoints": 6, "missing": 0, "pointsPerItem": 1}'::jsonb, 8),
    ('s1', 'Schreiben', 'Schreiben', 30, 'Wählen Sie eine Aufgabe (Aufgabe A oder Aufgabe B). Schreiben Sie einen kurzen Brief oder eine E-Mail (ca. 80 Wörter). Schreiben Sie zu allen vier Leitpunkten.', 'writing', '{"passages": [{"paragraphs": [{"t": "Aufgabe A", "b": true}, {"t": "Sie besuchen einen Deutschkurs. Sie können diese Woche nicht mehr in den Kurs kommen. Deshalb schreiben Sie einen Brief an Ihre Lehrerin, Frau Meinert.", "b": false}, {"t": "Schreiben Sie etwas zu folgenden Punkten:", "b": false}, {"t": "• Grund für Ihr Schreiben", "b": false}, {"t": "• Entschuldigung", "b": false}, {"t": "• Hausaufgaben", "b": false}, {"t": "• Rückkehr in den Kurs", "b": false}, {"t": "Aufgabe B", "b": true}, {"t": "Ihre frühere Deutschlehrerin, Frau Berg, hat bald Geburtstag. Sie möchte eine Geburtstagsparty feiern und hat Ihnen eine Einladung geschickt. Antworten Sie auf diese Einladung mit einem Brief.", "b": false}, {"t": "Schreiben Sie etwas zu folgenden Punkten:", "b": false}, {"t": "• Grund für Ihr Schreiben", "b": false}, {"t": "• Was Sie im Moment tun", "b": false}, {"t": "• Kommen Sie?", "b": false}, {"t": "• Bitte um Wegbeschreibung", "b": false}]}], "maxPoints": 20, "availablePoints": 20, "missing": 0, "pointsPerItem": 20}'::jsonb, 9)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'dtz-b1' and t.slug = 'modell-01'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('hv1', '1', 'Wer ruft an?', '[{"key": "A", "text": "Ein Arzt."}, {"key": "B", "text": "Eine Kollegin."}, {"key": "C", "text": "Eine Kundin."}]'::jsonb, 1, null::jsonb, 0),
    ('hv1', '2', 'Was soll Herr Gerber machen?', '[{"key": "A", "text": "Das Formular unterschreiben."}, {"key": "B", "text": "Das Geld überweisen."}, {"key": "C", "text": "Zur Wohngeldstelle kommen."}]'::jsonb, 1, null::jsonb, 1),
    ('hv1', '3', 'Sie wollen nach Lübeck fahren. Was sollen Sie tun?', '[{"key": "A", "text": "Auf Gleis 2 warten."}, {"key": "B", "text": "Den ICE nehmen."}, {"key": "C", "text": "In den Bus steigen."}]'::jsonb, 1, null::jsonb, 2),
    ('hv1', '4', 'Frau Wagner soll', '[{"key": "A", "text": "am Donnerstag um 8.30 Uhr kommen."}, {"key": "B", "text": "am Freitag um 8.30 Uhr anrufen."}, {"key": "C", "text": "ihren Termin absagen."}]'::jsonb, 1, null::jsonb, 3),
    ('hv2', '5', 'Am Nachmittag', '[{"key": "A", "text": "gibt es Gewitter."}, {"key": "B", "text": "scheint meistens die Sonne."}, {"key": "C", "text": "sinken die Temperaturen."}]'::jsonb, 1, null::jsonb, 0),
    ('hv2', '6', 'Wer in den Urlaub fahren will,', '[{"key": "A", "text": "braucht keinen Regenschirm."}, {"key": "B", "text": "muss mit Regen rechnen."}, {"key": "C", "text": "sollte im Norden bleiben."}]'::jsonb, 1, null::jsonb, 1),
    ('hv2', '7', 'Auf der Autobahn', '[{"key": "A", "text": "fahren viele LKWs."}, {"key": "B", "text": "gibt es Stau in Richtung München."}, {"key": "C", "text": "sollten Autofahrer vorsichtig sein."}]'::jsonb, 1, null::jsonb, 2),
    ('hv2', '8', 'Die Eintrittskarten', '[{"key": "A", "text": "gibt es an der Theaterkasse."}, {"key": "B", "text": "kosten heute weniger."}, {"key": "C", "text": "werden verlost."}]'::jsonb, 1, null::jsonb, 3),
    ('hv2', '9', 'Autofahrer sollten', '[{"key": "A", "text": "das Radio anlassen."}, {"key": "B", "text": "das Tempo drosseln."}, {"key": "C", "text": "von der Autobahn abfahren."}]'::jsonb, 1, null::jsonb, 4),
    ('hv3', '10', 'Herr Hansen ist heute Nachmittag im Büro.', '[{"key": "A", "text": "Richtig"}, {"key": "B", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 0),
    ('hv3', '11', 'Wann kann Herr Hansen die Unterlagen abgeben?', '[{"key": "A", "text": "Heute vor 16.00 Uhr."}, {"key": "B", "text": "Heute nach 16.00 Uhr."}, {"key": "C", "text": "Morgen Vormittag."}]'::jsonb, 1, null::jsonb, 1),
    ('hv3', '12', 'Die Frau findet das Geschenk zu teuer.', '[{"key": "A", "text": "Richtig"}, {"key": "B", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 2),
    ('hv3', '13', 'Was schenken sie dem Paar?', '[{"key": "A", "text": "Gläser."}, {"key": "B", "text": "Handtücher."}, {"key": "C", "text": "Kaffeetassen."}]'::jsonb, 1, null::jsonb, 3),
    ('hv3', '14', 'Die Frau hat ein Vorstellungsgespräch.', '[{"key": "A", "text": "Richtig"}, {"key": "B", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 4),
    ('hv3', '15', 'Um welche Stelle bewirbt sich die Frau?', '[{"key": "A", "text": "Altenpflegerin."}, {"key": "B", "text": "Arzthelferin."}, {"key": "C", "text": "Krankenschwester."}]'::jsonb, 1, null::jsonb, 5),
    ('hv3', '16', 'Die Mutter möchte, dass Fabian mehr lernt.', '[{"key": "A", "text": "Richtig"}, {"key": "B", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 6),
    ('hv3', '17', 'Wie kann Fabian eine bessere Note in Deutsch bekommen?', '[{"key": "A", "text": "Er soll mehr Hausaufgaben machen."}, {"key": "B", "text": "Er soll mehr im Unterricht mitarbeiten."}, {"key": "C", "text": "Er soll mehr Texte auf Deutsch lesen."}]'::jsonb, 1, null::jsonb, 7),
    ('hv4', '18', 'Sprecher 1', null::jsonb, 1, null::jsonb, 0),
    ('hv4', '19', 'Sprecher 2', null::jsonb, 1, null::jsonb, 1),
    ('hv4', '20', 'Sprecher 3', null::jsonb, 1, null::jsonb, 2),
    ('lv1', '21', 'Sie möchten ein gebrauchtes Auto kaufen.', '[{"key": "A", "text": "Audio"}, {"key": "B", "text": "Reise"}, {"key": "C", "text": "andere Seite"}]'::jsonb, 1, null::jsonb, 0),
    ('lv1', '22', 'Eine Bekannte hört gerne Geschichten. Wo finden Sie ein passendes Geschenk?', '[{"key": "A", "text": "Filme & DVDs"}, {"key": "B", "text": "Bücher"}, {"key": "C", "text": "andere Seite"}]'::jsonb, 1, null::jsonb, 1),
    ('lv1', '23', 'Sie ziehen in zwei Wochen in eine neue Wohnung und suchen dafür Kartons.', '[{"key": "A", "text": "Möbel & Wohnen"}, {"key": "B", "text": "Heimwerker"}, {"key": "C", "text": "andere Seite"}]'::jsonb, 1, null::jsonb, 2),
    ('lv1', '24', 'Sie brauchen am Arbeitsplatz eine Kaffeemaschine.', '[{"key": "A", "text": "Feinschmecker"}, {"key": "B", "text": "Heimwerker"}, {"key": "C", "text": "andere Seite"}]'::jsonb, 1, null::jsonb, 3),
    ('lv1', '25', 'Sie arbeiten abends zu Hause und suchen eine Schreibtischlampe.', '[{"key": "A", "text": "Büro"}, {"key": "B", "text": "Möbel & Wohnen"}, {"key": "C", "text": "andere Seite"}]'::jsonb, 1, null::jsonb, 4),
    ('lv2', '26', 'Frau Seifert ist Friseurin und möchte stundenweise arbeiten. Sie wohnt in Berlin.', null::jsonb, 1, null::jsonb, 0),
    ('lv2', '27', 'Frau Richter sucht eine Ausbildungsstelle als Köchin ab September.', null::jsonb, 1, null::jsonb, 1),
    ('lv2', '28', 'Herr Seibold sucht einen Job als Maler und Tapezierer.', null::jsonb, 1, null::jsonb, 2),
    ('lv2', '29', 'Herr Kindler sucht Arbeit in einer Kfz-Werkstatt. Er will auch junge Menschen ausbilden.', null::jsonb, 1, null::jsonb, 3),
    ('lv2', '30', 'Frau Kerschel möchte sich ein Auto kaufen und braucht dafür Geld. Deshalb will sie während des Sommers zusätzlich etwas verdienen.', null::jsonb, 1, null::jsonb, 4),
    ('lv3', '31', 'Das Land Hessen gibt zukünftig eine halbe Million Euro für Integrationshelfer aus.', '[{"key": "A", "text": "Richtig"}, {"key": "B", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 0),
    ('lv3', '32', 'Das Ministerium möchte, dass', '[{"key": "A", "text": "800 Helfer mehr eingestellt werden."}, {"key": "B", "text": "die Arbeit der Helfer mehr Wirkung hat."}, {"key": "C", "text": "die Helfer für ihre Arbeit mehr Geld verdienen."}]'::jsonb, 1, null::jsonb, 1),
    ('lv3', '33', 'Die Eltern sollen den Kindergarten putzen.', '[{"key": "A", "text": "Richtig"}, {"key": "B", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 2),
    ('lv3', '34', 'Das Kindergartenteam möchte, dass die Eltern', '[{"key": "A", "text": "das Programm planen und organisieren."}, {"key": "B", "text": "etwas mitbringen oder bezahlen."}, {"key": "C", "text": "Lieder singen oder Sommerblumen basteln."}]'::jsonb, 1, null::jsonb, 3),
    ('lv3', '35', 'Ab 1. Februar muss Familie Müller mehr Miete zahlen.', '[{"key": "A", "text": "Richtig"}, {"key": "B", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 4),
    ('lv3', '36', 'Familie Müller', '[{"key": "A", "text": "braucht ab Februar nichts mehr für die Nebenkosten auszugeben."}, {"key": "B", "text": "hat zuviel an Nebenkosten bezahlt."}, {"key": "C", "text": "muss im kommenden Jahr 150 Euro Nebenkosten bezahlen."}]'::jsonb, 1, null::jsonb, 5),
    ('lv4', '37', 'Man soll die Tabletten nicht vor dem Essen nehmen.', null::jsonb, 1, null::jsonb, 0),
    ('lv4', '38', 'Nachdem man die Tabletten genommen hat, darf man nicht selbst Auto fahren.', null::jsonb, 1, null::jsonb, 1),
    ('lv4', '39', 'Während der gesamten Schwangerschaft darf das Medikament auf keinen Fall eingenommen werden.', null::jsonb, 1, null::jsonb, 2),
    ('lv5', '40', 'Lücke 40:', '[{"key": "A", "text": "Sehr geehrte"}, {"key": "B", "text": "Sehr geehrten"}, {"key": "C", "text": "Viele geehrte"}]'::jsonb, 1, null::jsonb, 0),
    ('lv5', '41', 'Lücke 41:', '[{"key": "A", "text": "mein"}, {"key": "B", "text": "mich"}, {"key": "C", "text": "mir"}]'::jsonb, 1, null::jsonb, 1),
    ('lv5', '42', 'Lücke 42:', '[{"key": "A", "text": "kann"}, {"key": "B", "text": "möchte"}, {"key": "C", "text": "soll"}]'::jsonb, 1, null::jsonb, 2),
    ('lv5', '43', 'Lücke 43:', '[{"key": "A", "text": "konnte"}, {"key": "B", "text": "musste"}, {"key": "C", "text": "sollte"}]'::jsonb, 1, null::jsonb, 3),
    ('lv5', '44', 'Lücke 44:', '[{"key": "A", "text": "Denn"}, {"key": "B", "text": "Deshalb"}, {"key": "C", "text": "Weil"}]'::jsonb, 1, null::jsonb, 4),
    ('lv5', '45', 'Lücke 45:', '[{"key": "A", "text": "freundlichen"}, {"key": "B", "text": "lieben"}, {"key": "C", "text": "vielen"}]'::jsonb, 1, null::jsonb, 5),
    ('s1', '46', 'Wählen Sie Aufgabe A oder B und schreiben Sie einen Text:', null::jsonb, 0, '{"minWords": 80, "points": ["Grund für Ihr Schreiben", "Entschuldigung / Was Sie im Moment tun", "Hausaufgaben / Kommen Sie?", "Rückkehr in den Kurs / Bitte um Wegbeschreibung"]}'::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'dtz-b1' and t.slug = 'modell-01'
join sections s on s.test_id = t.id and s.section_id = v.section_id
on conflict (section_id, item_id) do update set text = excluded.text, options = excluded.options, points = excluded.points, meta = excluded.meta, sort = excluded.sort;

insert into item_answers (item_id, answer, explanation)
select i.id, v.answer, v.explanation
from (values
    ('hv1', '1', 'A', null),
    ('hv1', '2', 'C', null),
    ('hv1', '3', 'C', null),
    ('hv1', '4', 'A', null),
    ('hv2', '5', 'B', null),
    ('hv2', '6', 'B', null),
    ('hv2', '7', 'C', null),
    ('hv2', '8', 'C', null),
    ('hv2', '9', 'B', null),
    ('hv3', '10', 'B', null),
    ('hv3', '11', 'A', null),
    ('hv3', '12', 'B', null),
    ('hv3', '13', 'A', null),
    ('hv3', '14', 'A', null),
    ('hv3', '15', 'A', null),
    ('hv3', '16', 'B', null),
    ('hv3', '17', 'C', null),
    ('hv4', '18', 'D', null),
    ('hv4', '19', 'F', null),
    ('hv4', '20', 'E', null),
    ('lv1', '21', 'C', null),
    ('lv1', '22', 'B', null),
    ('lv1', '23', 'B', null),
    ('lv1', '24', 'C', null),
    ('lv1', '25', 'B', null),
    ('lv2', '26', 'C', null),
    ('lv2', '27', 'A', null),
    ('lv2', '28', 'X', null),
    ('lv2', '29', 'F', null),
    ('lv2', '30', 'E', null),
    ('lv3', '31', 'A', null),
    ('lv3', '32', 'B', null),
    ('lv3', '33', 'B', null),
    ('lv3', '34', 'B', null),
    ('lv3', '35', 'B', null),
    ('lv3', '36', 'B', null),
    ('lv4', '37', 'r', null),
    ('lv4', '38', 'f', null),
    ('lv4', '39', 'f', null),
    ('lv5', '40', 'A', null),
    ('lv5', '41', 'B', null),
    ('lv5', '42', 'B', null),
    ('lv5', '43', 'B', null),
    ('lv5', '44', 'B', null),
    ('lv5', '45', 'A', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'dtz-b1' and t.slug = 'modell-01'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;

-- ================= modell-02 · MEYBOHM =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('dtz-b1', 'modell-02', 'MEYBOHM', '46 Aufgaben · 100 Minuten',
        '[{"id": "block-hoeren", "parts": ["hv1", "hv2", "hv3", "hv4"], "title": "Hören", "minutes": 25, "hint": "Aufgaben 1–20", "maxPoints": 20, "availablePoints": 20, "missing": 0}, {"id": "block-lesen", "parts": ["lv1", "lv2", "lv3", "lv4", "lv5"], "title": "Lesen", "minutes": 45, "hint": "Aufgaben 21–45", "maxPoints": 25, "availablePoints": 25, "missing": 0}, {"id": "block-schreiben", "parts": ["s1"], "title": "Schreiben", "minutes": 30, "hint": "Aufgabe 46", "maxPoints": 20, "availablePoints": 20, "missing": 0}]'::jsonb, 46, true, 2)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('hv1', 'Hören', 'Hören, Teil 1', 6, 'Sie hören vier Ansagen. Zu jeder Ansage gibt es eine Aufgabe. Welche Lösung (a, b oder c) passt am besten?', 'mc', '{"maxPoints": 4, "availablePoints": 4, "missing": 0, "pointsPerItem": 1, "audioPlays": 1}'::jsonb, 0),
    ('hv2', 'Hören', 'Hören, Teil 2', 5, 'Sie hören fünf Ansagen aus dem Radio. Zu jeder Ansage gibt es eine Aufgabe. Welche Lösung (a, b oder c) passt am besten?', 'mc', '{"maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1, "audioPlays": 1}'::jsonb, 1),
    ('hv3', 'Hören', 'Hören, Teil 3', 9, 'Sie hören vier Gespräche. Zu jedem Gespräch gibt es zwei Aufgaben. Entscheiden Sie bei jedem Gespräch, ob die Aussage dazu richtig oder falsch ist und welche Antwort (a, b oder c) am besten passt.', 'mc', '{"maxPoints": 8, "availablePoints": 8, "missing": 0, "pointsPerItem": 1, "audioPlays": 2}'::jsonb, 2),
    ('hv4', 'Hören', 'Hören, Teil 4', 4, 'Sie hören Aussagen zu einem Thema. Welcher der Sätze a–f passt zu den Aussagen 18–20?', 'matching', '{"bank": [{"key": "A", "text": "Das Leben in einer Wohngemeinschaft bringt nur Probleme."}, {"key": "B", "text": "Die meisten Menschen leben heute lieber alleine."}, {"key": "C", "text": "Ein Leben in der Großfamilie ist heute eher selten."}, {"key": "D", "text": "In einer Wohngemeinschaft fühlen sich junge Leute nicht einsam."}, {"key": "E", "text": "Wenn Alt und Jung zusammenwohnen, hat das viele Vorteile."}, {"key": "F", "text": "Wenn man mit anderen zusammenlebt, kann man viel voneinander lernen."}], "bankTitle": "Aussagen", "maxPoints": 3, "availablePoints": 3, "missing": 0, "pointsPerItem": 1, "audioPlays": 1}'::jsonb, 3),
    ('lv1', 'Lesen', 'Lesen, Teil 1', 10, 'Sie wollen etwas einkaufen. Lesen Sie die Aufgaben 21–25 und die Internetseite. Wo (a, b oder c) finden Sie etwas Passendes?', 'mc', '{"bankImage": "img/dtz-b1-m02-lv1.jpg", "maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1}'::jsonb, 4),
    ('lv2', 'Lesen', 'Lesen, Teil 2', 10, 'Finden Sie zu jeder Situation (26–30) die passende Anzeige (a–h). Für eine Aufgabe gibt es keine passende Anzeige. Markieren Sie in diesem Fall ein x.', 'matching', '{"bank": [{"key": "A", "text": "Anzeige a"}, {"key": "B", "text": "Anzeige b"}, {"key": "C", "text": "Anzeige c"}, {"key": "D", "text": "Anzeige d"}, {"key": "E", "text": "Anzeige e"}, {"key": "F", "text": "Anzeige f"}, {"key": "G", "text": "Anzeige g"}, {"key": "H", "text": "Anzeige h"}, {"key": "X", "text": "Keine Anzeige passt"}], "bankTitle": "Anzeigen", "bankImage": "img/dtz-b1-m02-lv2.jpg", "maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1}'::jsonb, 5),
    ('lv3', 'Lesen', 'Lesen, Teil 3', 12, 'Lesen Sie die drei Texte. Zu jedem Text gibt es zwei Aufgaben. Entscheiden Sie bei jedem Text, ob die Aussage richtig oder falsch ist und welche Antwort (a, b oder c) am besten passt.', 'mc', '{"passages": [{"paragraphs": [{"t": "Sprachunterricht auf der Bühne", "b": false}, {"t": "„The Flying Fish Theatre“ besuchte in dieser Woche die Kaiserpfalz-Realschule. Das englische Schauspiel-Team bringt Schülerinnen und Schülern die englische Sprache durch Theater näher. Aufgeführt wurden an diesem Vormittag zwei Stücke. Die siebten Klassen sahen das Musical „Mc Vamp“. Für die achten und neunten Klassen stand das Stück „Furious Games“ auf dem Stundenplan. Nach den Stücken konnten die Schüler die Schauspieler befragen. Natürlich auf Englisch.", "b": false}, {"t": "Bereits zum dritten Mal war „The Flying Fish Theatre“ an der Realschule zu Gast und hat gute Erfahrungen gemacht. Das sei besser, als Grammatik zu büffeln oder Vokabeln zu pauken, meinten natürlich auch die Schüler.", "b": false}]}, {"paragraphs": [{"t": "Führerschein mit 17 ist eine gute Sache", "b": false}, {"t": "Die Fahrprüfung zum begleiteten Fahren mit 17 kann inzwischen in vielen Bundesländern abgelegt werden. Seit dem 1. September 2005 können sich Jugendliche, die mindestens 16,5 Jahre alt sind, bei einer Fahrschule zur Führerscheinausbildung anmelden. Wenn die Fahranfänger die Fahrprüfung bestanden haben und 17 Jahre alt sind, dürfen sie dann selbst fahren, wenn ein geübter älterer Fahrer mit im Auto sitzt. Sie erhalten eine Prüfungsbescheinigung, in der die Begleitpersonen mit Namen eingetragen sind. Nach Einschätzung vieler Experten ist der Führerschein mit 17 ein wichtiger Baustein für mehr Sicherheit bei Fahranfängern, da die jungen Fahrer später 40 Prozent weniger Unfälle verursachen.", "b": false}]}, {"paragraphs": [{"t": "Liebe junge Kunden,", "b": false}, {"t": "wir möchten euch heute unser gebührenfreies Girokonto vorstellen. Das XL-Konto ist speziell für Schüler, Studenten und Auszubildende bis zum 27. Lebensjahr.", "b": false}, {"t": "Es gibt Zinsen wie auf einem Sparbuch. Mit der XL-BankCard könnt ihr Kontoauszüge drucken und Geld am Geldautomaten abheben.", "b": false}, {"t": "Außerdem könnt ihr das Taschengeld der Eltern oder das erste Gehalt überweisen lassen und Rechnungen selber bezahlen. Auch Handyrechnungen könnt ihr problemlos abbuchen lassen. Die Teilnahme am Online-Banking ist mit diesem Konto ebenfalls möglich.", "b": false}, {"t": "Ab dem nächsten Jahr haben wir dann etwas Besonderes für euch: Mit eurer XL-BankCard spart ihr 20 Euro beim Kauf eines neuen Handys bei Elektro Schmidt.", "b": false}, {"t": "Euer Volksbank-Team", "b": false}]}], "maxPoints": 6, "availablePoints": 6, "missing": 0, "pointsPerItem": 1}'::jsonb, 6),
    ('lv4', 'Lesen', 'Lesen, Teil 4', 7, 'Lesen Sie den Text. Entscheiden Sie, ob die Aussagen 37–39 richtig oder falsch sind.', 'truefalse', '{"passages": [{"paragraphs": [{"t": "Ausbildung im Lebensmitteleinzelhandel", "b": false}, {"t": "Cent Supermärkte sind ein Teil der Cent Group, einem der bedeutendsten Handelskonzerne in Europa. Mit rund 2000 Märkten gilt Cent als Frische-Spezialist.", "b": false}, {"t": "Werden auch Sie Azubi", "b": false}, {"t": "Die Berufswahl ist eine Entscheidung fürs Leben. Jetzt kommt es darauf an, den Beruf zu wählen, der Ihnen Spaß macht. Prüfen Sie deshalb genau, ob unser Angebot Ihren Zukunftsvorstellungen entspricht.", "b": false}, {"t": "Erst einmal reinschnuppern", "b": false}, {"t": "Die richtige Berufswahl zu treffen ist eine schwere Entscheidung. Wir unterstützen Sie dabei mit unserem Angebot, für einige Tage die Praxis in einem unserer Märkte kennenzulernen.", "b": false}, {"t": "Schülerpraktikum", "b": false}, {"t": "Ein Praktikum bei uns gibt Ihnen die Möglichkeit, unser Unternehmen und Ihren zukünftigen Beruf einmal so richtig „unter die Lupe“ zu nehmen.", "b": false}, {"t": "Vor Ort werden Sie mehrere Wochen lang alles Wichtige über die Organisation eines Marktes hautnah miterleben.", "b": false}, {"t": "Wenn Sie sich dann für eine Ausbildung bei uns entscheiden, profitieren Sie von zahlreichen Vorteilen.", "b": false}, {"t": "Wir bieten:", "b": false}, {"t": "- Eine je nach Berufswunsch zwei- oder dreijährige Ausbildung, die Spaß macht", "b": false}, {"t": "- Abwechslungsreiche Tätigkeiten", "b": false}, {"t": "- 5-Tage-Woche", "b": false}, {"t": "- Seminare", "b": false}, {"t": "Und nach der Ausbildung", "b": false}, {"t": "- Sicherer Arbeitsplatz", "b": false}, {"t": "- Perspektiven", "b": false}, {"t": "- Schnelle Übernahme von ersten Fach- und Führungsaufgaben", "b": false}, {"t": "- Weiterbildung", "b": false}, {"t": "Interessante Berufe warten auf Sie!", "b": false}, {"t": "Bitte senden Sie uns Ihre vollständigen Bewerbungsunterlagen.", "b": false}, {"t": "Wir freuen uns auf Ihre Zuschrift.", "b": false}]}], "maxPoints": 3, "availablePoints": 3, "missing": 0, "pointsPerItem": 1}'::jsonb, 7),
    ('lv5', 'Lesen', 'Lesen, Teil 5', 6, 'Lesen Sie den Text und schließen Sie die Lücken 40–45. Welche Lösung (a, b oder c) passt am besten?', 'mc', '{"passages": [{"paragraphs": [{"t": "Delmenhorst, den 12.09.20..", "b": false}, {"t": "Spaß am Unterrichten?", "b": false}, {"t": "Vielleicht können Sie (0) helfen? Ich bin 19 Jahre alt und (40) im Herbst eine Lehre bei einer Bank. Deshalb (41) ich mein Deutsch verbessern. (42) Sie fließend Deutsch sprechen und zweimal in der Woche Zeit haben, dann wäre das perfekt (43) mich. Die Stunden kann ich (44) bezahlen oder Ihnen im Haushalt und Garten helfen.", "b": false}, {"t": "Sie (45) mich telefonisch unter 0341/41 41 41.", "b": false}]}], "maxPoints": 6, "availablePoints": 6, "missing": 0, "pointsPerItem": 1}'::jsonb, 8),
    ('s1', 'Schreiben', 'Schreiben', 30, 'Wählen Sie Aufgabe A oder Aufgabe B. Zeigen Sie, was Sie können. Schreiben Sie möglichst viel. Schreiben Sie Ihren Text auf den Antwortbogen.', 'writing', '{"maxPoints": 20, "availablePoints": 20, "missing": 0, "pointsPerItem": 20}'::jsonb, 9)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'dtz-b1' and t.slug = 'modell-02'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('hv1', '1', 'Sie brauchen einen Termin bei Ihrer Versicherung? Was sollen Sie tun?', '[{"key": "A", "text": "Am Montag um acht Uhr anrufen."}, {"key": "B", "text": "Eine Nachricht auf den Anrufbeantworter sprechen."}, {"key": "C", "text": "Persönlich vorbeikommen."}]'::jsonb, 1, null::jsonb, 0),
    ('hv1', '2', 'Sie möchten Mitglied werden. Wo kann man sich informieren?', '[{"key": "A", "text": "Am Empfang."}, {"key": "B", "text": "Im Erdgeschoss."}, {"key": "C", "text": "Im Untergeschoss."}]'::jsonb, 1, null::jsonb, 1),
    ('hv1', '3', 'Was kostet das Stück Kuchen?', '[{"key": "A", "text": "Für alle 50 Cent."}, {"key": "B", "text": "Für Kursteilnehmer 50 Cent."}, {"key": "C", "text": "Für Lehrer 50 Cent."}]'::jsonb, 1, null::jsonb, 2),
    ('hv1', '4', 'Was soll Felix tun?', '[{"key": "A", "text": "Mit dem Jobcenter telefonieren."}, {"key": "B", "text": "Seinen Lebenslauf ins Jobcenter bringen."}, {"key": "C", "text": "Seine Zeugnisse ins Jobcenter bringen."}]'::jsonb, 1, null::jsonb, 3),
    ('hv2', '5', 'Wie wird das Wetter am Nachmittag?', '[{"key": "A", "text": "Die Sonne scheint."}, {"key": "B", "text": "Es kann regnen."}, {"key": "C", "text": "Es regnet nicht."}]'::jsonb, 1, null::jsonb, 0),
    ('hv2', '6', 'Auf der A 8 gibt es', '[{"key": "A", "text": "einen Stau."}, {"key": "B", "text": "einen Unfall."}, {"key": "C", "text": "eine Umleitung."}]'::jsonb, 1, null::jsonb, 1),
    ('hv2', '7', 'Wann kann man frühstücken gehen?', '[{"key": "A", "text": "Am Freitag."}, {"key": "B", "text": "Am Samstag."}, {"key": "C", "text": "Am Sonntag."}]'::jsonb, 1, null::jsonb, 2),
    ('hv2', '8', 'Was für eine Sendung kann man um 18:10 Uhr im Radio hören?', '[{"key": "A", "text": "Eine Kindersendung."}, {"key": "B", "text": "Ein Gespräch mit Forschern."}, {"key": "C", "text": "Ein Gewinnspiel."}]'::jsonb, 1, null::jsonb, 3),
    ('hv2', '9', 'Was hören Sie?', '[{"key": "A", "text": "Den Wetterbericht."}, {"key": "B", "text": "Einen Gesundheitstipp."}, {"key": "C", "text": "Tipps für das Wochenende."}]'::jsonb, 1, null::jsonb, 4),
    ('hv3', '10', 'Frau Meybohm spricht mit ihrem Lehrer. richtig falsch', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 0),
    ('hv3', '11', 'Ihr Problem bei technischen Berufen ist, dass', '[{"key": "A", "text": "das Männerberufe sind."}, {"key": "B", "text": "sie dafür nicht gut genug ist."}, {"key": "C", "text": "Technik sie nicht interessiert."}]'::jsonb, 1, null::jsonb, 1),
    ('hv3', '12', 'Frau Bathily möchte ein Konto eröffnen. richtig falsch', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 2),
    ('hv3', '13', 'Was ist das Problem?', '[{"key": "A", "text": "Beide Eltern müssen unterschreiben."}, {"key": "B", "text": "Sie verdient noch kein Geld."}, {"key": "C", "text": "Sie weiß nicht, wo ihr Vater wohnt."}]'::jsonb, 1, null::jsonb, 3),
    ('hv3', '14', 'Tanja möchte einen Computer kaufen. richtig falsch', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 4),
    ('hv3', '15', 'Wann treffen sich Julia und Tanja?', '[{"key": "A", "text": "Heute Nachmittag."}, {"key": "B", "text": "Morgen Nachmittag."}, {"key": "C", "text": "Morgen Vormittag."}]'::jsonb, 1, null::jsonb, 5),
    ('hv3', '16', 'Michael lädt Jasmin ins Kino ein. richtig falsch', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 6),
    ('hv3', '17', 'Wie viel muss Michael bezahlen?', '[{"key": "A", "text": "30 Euro."}, {"key": "B", "text": "Mehr als 30 Euro."}, {"key": "C", "text": "Nichts."}]'::jsonb, 1, null::jsonb, 7),
    ('hv4', '18', 'Sprecher 1', null::jsonb, 1, null::jsonb, 0),
    ('hv4', '19', 'Sprecher 2', null::jsonb, 1, null::jsonb, 1),
    ('hv4', '20', 'Sprecher 3', null::jsonb, 1, null::jsonb, 2),
    ('lv1', '21', 'Sie möchten tanzen gehen.', '[{"key": "A", "text": "Aula"}, {"key": "B", "text": "Musiksaal"}, {"key": "C", "text": "anderer Ort"}]'::jsonb, 1, null::jsonb, 0),
    ('lv1', '22', 'Sie möchten wissen, wie die VHS früher war.', '[{"key": "A", "text": "Pausenhalle"}, {"key": "B", "text": "Schulhof"}, {"key": "C", "text": "anderer Ort"}]'::jsonb, 1, null::jsonb, 1),
    ('lv1', '23', 'Sie wollen ein paar chinesische Wörter lernen.', '[{"key": "A", "text": "Musiksaal"}, {"key": "B", "text": "Pausenhalle"}, {"key": "C", "text": "anderer Ort"}]'::jsonb, 1, null::jsonb, 2),
    ('lv1', '24', 'Sie möchten fotografieren lernen.', '[{"key": "A", "text": "Pausenhalle"}, {"key": "B", "text": "Schulhof"}, {"key": "C", "text": "anderer Ort"}]'::jsonb, 1, null::jsonb, 3),
    ('lv1', '25', 'Sie möchten Speisen aus anderen Ländern probieren.', '[{"key": "A", "text": "Musiksaal"}, {"key": "B", "text": "Pausenhalle"}, {"key": "C", "text": "anderer Ort"}]'::jsonb, 1, null::jsonb, 4),
    ('lv2', '26', 'Marisa ist gerade 20 Jahre alt geworden und will in den Sommerferien etwas für den Schutz der Natur und der Tiere tun.', null::jsonb, 1, null::jsonb, 0),
    ('lv2', '27', 'Sandra ist gerne im Internet und möchte damit etwas Geld verdienen.', null::jsonb, 1, null::jsonb, 1),
    ('lv2', '28', 'Peter sucht eine Ausbildung, bei der er viel mit Menschen zu tun hat.', null::jsonb, 1, null::jsonb, 2),
    ('lv2', '29', 'Eva interessiert sich für Pflegeberufe.', null::jsonb, 1, null::jsonb, 3),
    ('lv2', '30', 'Niko möchte regelmäßig etwas Geld verdienen und hat dafür am Wochenende Zeit.', null::jsonb, 1, null::jsonb, 4),
    ('lv3', '31', 'In der Kaiserpfalz-Realschule lernen die Schüler Englisch nur über das Theaterspielen. richtig falsch', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 0),
    ('lv3', '32', 'Die Schüler', '[{"key": "A", "text": "lernen so am liebsten Englisch."}, {"key": "B", "text": "sehen alle dasselbe Stück."}, {"key": "C", "text": "spielen selbst Theater."}]'::jsonb, 1, null::jsonb, 1),
    ('lv3', '33', 'Den Führerschein mit 17 kann man in ganz Deutschland machen. richtig falsch', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 2),
    ('lv3', '34', '17-Jährige', '[{"key": "A", "text": "dürfen auch ohne Fahrschule einen Führerschein machen."}, {"key": "B", "text": "dürfen nur zusammen mit Erwachsenen fahren."}, {"key": "C", "text": "müssen mehr auf ältere Personen im Straßenverkehr achten."}]'::jsonb, 1, null::jsonb, 3),
    ('lv3', '35', 'Die Bank bietet jungen Leuten ein kostenloses Konto an. richtig falsch', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 4),
    ('lv3', '36', 'Ab nächstem Jahr kann man', '[{"key": "A", "text": "Rechnungen bezahlen."}, {"key": "B", "text": "eine Bankkarte bekommen."}, {"key": "C", "text": "ein neues Mobiltelefon günstiger kaufen."}]'::jsonb, 1, null::jsonb, 5),
    ('lv4', '37', 'Auszubildende müssen bei Cent erst eine Prüfung machen.', null::jsonb, 1, null::jsonb, 0),
    ('lv4', '38', 'Die Ausbildung bei Cent dauert mehrere Wochen.', null::jsonb, 1, null::jsonb, 1),
    ('lv4', '39', 'Cent bietet außer einer Ausbildung auch die Möglichkeit für ein Praktikum.', null::jsonb, 1, null::jsonb, 2),
    ('lv5', '40', 'Lücke 40', '[{"key": "A", "text": "anfange"}, {"key": "B", "text": "beginne"}, {"key": "C", "text": "werde"}]'::jsonb, 1, null::jsonb, 0),
    ('lv5', '41', 'Lücke 41', '[{"key": "A", "text": "mag"}, {"key": "B", "text": "möchte"}, {"key": "C", "text": "mochte"}]'::jsonb, 1, null::jsonb, 1),
    ('lv5', '42', 'Lücke 42', '[{"key": "A", "text": "Wann"}, {"key": "B", "text": "Wenn"}, {"key": "C", "text": "Wie"}]'::jsonb, 1, null::jsonb, 2),
    ('lv5', '43', 'Lücke 43', '[{"key": "A", "text": "für"}, {"key": "B", "text": "um"}, {"key": "C", "text": "vor"}]'::jsonb, 1, null::jsonb, 3),
    ('lv5', '44', 'Lücke 44', '[{"key": "A", "text": "entweder"}, {"key": "B", "text": "oder"}, {"key": "C", "text": "sowohl"}]'::jsonb, 1, null::jsonb, 4),
    ('lv5', '45', 'Lücke 45', '[{"key": "A", "text": "erreichen"}, {"key": "B", "text": "rufen"}, {"key": "C", "text": "telefonieren"}]'::jsonb, 1, null::jsonb, 5),
    ('s1', '46', 'Aufgabe A: Sie haben im Internet die Werbung für einen Kurs „Deutsche Sprache und Kultur für junge Leute“ gesehen. Sie interessieren sich dafür, haben aber noch einige Fragen. Sie schreiben einen Brief an Frau Pfeiffer vom Sprachinstitut. Schreiben Sie etwas zu folgenden Punkten: - Grund für Ihr Schreiben - Unterrichtsprogramm / Lehrbuch - Kontakte zu Vereinen - Freizeitprogramm oder Aufgabe B: Sie möchten einen Ausbildungsplatz finden. In der Zeitung haben Sie gelesen, dass eine Firma in einem für Sie interessanten Beruf Auszubildende sucht. Sie schreiben eine Bewerbung an Herrn Schmitz von der Personalabteilung. Schreiben Sie etwas zu folgenden Punkten: - Grund für Ihr Schreiben - Schule - Hobbys / Interessen - Sprachkenntnisse', null::jsonb, 0, null::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'dtz-b1' and t.slug = 'modell-02'
join sections s on s.test_id = t.id and s.section_id = v.section_id
on conflict (section_id, item_id) do update set text = excluded.text, options = excluded.options, points = excluded.points, meta = excluded.meta, sort = excluded.sort;

insert into item_answers (item_id, answer, explanation)
select i.id, v.answer, v.explanation
from (values
    ('hv1', '1', 'B', null),
    ('hv1', '2', 'A', null),
    ('hv1', '3', 'B', null),
    ('hv1', '4', 'C', null),
    ('hv2', '5', 'B', null),
    ('hv2', '6', 'A', null),
    ('hv2', '7', 'C', null),
    ('hv2', '8', 'B', null),
    ('hv2', '9', 'B', null),
    ('hv3', '10', 'f', null),
    ('hv3', '11', 'A', null),
    ('hv3', '12', 'r', null),
    ('hv3', '13', 'A', null),
    ('hv3', '14', 'f', null),
    ('hv3', '15', 'B', null),
    ('hv3', '16', 'f', null),
    ('hv3', '17', 'C', null),
    ('hv4', '18', 'D', null),
    ('hv4', '19', 'E', null),
    ('hv4', '20', 'C', null),
    ('lv1', '21', 'B', null),
    ('lv1', '22', 'B', null),
    ('lv1', '23', 'C', null),
    ('lv1', '24', 'B', null),
    ('lv1', '25', 'B', null),
    ('lv2', '26', 'C', null),
    ('lv2', '27', 'A', null),
    ('lv2', '28', 'F', null),
    ('lv2', '29', 'X', null),
    ('lv2', '30', 'E', null),
    ('lv3', '31', 'f', null),
    ('lv3', '32', 'A', null),
    ('lv3', '33', 'f', null),
    ('lv3', '34', 'B', null),
    ('lv3', '35', 'r', null),
    ('lv3', '36', 'C', null),
    ('lv4', '37', 'f', null),
    ('lv4', '38', 'f', null),
    ('lv4', '39', 'r', null),
    ('lv5', '40', 'B', null),
    ('lv5', '41', 'B', null),
    ('lv5', '42', 'B', null),
    ('lv5', '43', 'A', null),
    ('lv5', '44', 'A', null),
    ('lv5', '45', 'A', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'dtz-b1' and t.slug = 'modell-02'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;

-- ================= modell-03 · MATUSCHEK =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('dtz-b1', 'modell-03', 'MATUSCHEK', '46 Aufgaben · 100 Minuten',
        '[{"id": "block-hoeren", "parts": ["hv1", "hv2", "hv3", "hv4"], "title": "Hören", "minutes": 25, "hint": "Aufgaben 1–20", "maxPoints": 20, "availablePoints": 20, "missing": 0}, {"id": "block-lesen", "parts": ["lv1", "lv2", "lv3", "lv4", "lv5"], "title": "Lesen", "minutes": 45, "hint": "Aufgaben 21–45", "maxPoints": 25, "availablePoints": 25, "missing": 0}, {"id": "block-schreiben", "parts": ["s1"], "title": "Schreiben", "minutes": 30, "hint": "Aufgabe 46", "maxPoints": 20, "availablePoints": 20, "missing": 0}]'::jsonb, 46, true, 3)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('hv1', 'Hören', 'Hören, Teil 1', 6, 'Sie hören vier Ansagen. Zu jeder Ansage gibt es eine Aufgabe. Welche Lösung (a, b oder c) passt am besten?', 'mc', '{"maxPoints": 4, "availablePoints": 4, "missing": 0, "pointsPerItem": 1, "audioPlays": 1}'::jsonb, 0),
    ('hv2', 'Hören', 'Hören, Teil 2', 5, 'Sie hören fünf Ansagen aus dem Radio. Zu jeder Ansage gibt es eine Aufgabe. Welche Lösung (a, b oder c) passt am besten?', 'mc', '{"maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1, "audioPlays": 1}'::jsonb, 1),
    ('hv3', 'Hören', 'Hören, Teil 3', 7, 'Sie hören vier Gespräche. Zu jedem Gespräch gibt es zwei Aufgaben. Entscheiden Sie bei jedem Gespräch, ob die Aussage dazu richtig oder falsch ist und welche Antwort (a, b oder c) am besten passt.', 'mc', '{"maxPoints": 8, "availablePoints": 8, "missing": 0, "pointsPerItem": 1, "audioPlays": 1}'::jsonb, 2),
    ('hv4', 'Hören', 'Hören, Teil 4', 7, 'Sie hören die Meinungen von drei Personen zu einem Thema. Wählen Sie für die Aufgaben 18–20 die passende Aussage (a–f).', 'matching', '{"bank": [{"key": "A", "text": "Es ist gut, wenn Kinder ihre Hausaufgaben in der Schule machen können."}, {"key": "B", "text": "Die ganztägige Grundschule ist zu teuer."}, {"key": "C", "text": "Es ist schade, dass Kinder dann keine Freizeit mehr haben."}, {"key": "D", "text": "Kinder sollen nachmittags nicht allein am Computer sitzen."}, {"key": "E", "text": "Kinder haben nachmittags in der Ganztagsschule interessante Beschäftigung."}, {"key": "F", "text": "In der ganztägigen Grundschule machen die Kinder Lernspiele am Computer."}], "bankTitle": "Aussagen", "maxPoints": 3, "availablePoints": 3, "missing": 0, "pointsPerItem": 1, "audioPlays": 1}'::jsonb, 3),
    ('lv1', 'Lesen', 'Lesen, Teil 1', 10, 'Sie sind im Bürgerbüro. Lesen Sie die Aufgaben 21–25 und den Wegweiser. Welches Zimmer (a, b oder c) passt am besten?', 'mc', '{"bankImage": "img/dtz-b1-m03-lv1.jpg", "maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1}'::jsonb, 4),
    ('lv2', 'Lesen', 'Lesen, Teil 2', 10, 'Finden Sie zu jeder Situation (26–30) die passende Anzeige (a–h). Für eine Aufgabe gibt es keine passende Anzeige. Markieren Sie in diesem Fall ein x.', 'matching', '{"bank": [{"key": "A", "text": "Anzeige a"}, {"key": "B", "text": "Anzeige b"}, {"key": "C", "text": "Anzeige c"}, {"key": "D", "text": "Anzeige d"}, {"key": "E", "text": "Anzeige e"}, {"key": "F", "text": "Anzeige f"}, {"key": "G", "text": "Anzeige g"}, {"key": "H", "text": "Anzeige h"}, {"key": "X", "text": "Keine Anzeige passt"}], "bankTitle": "Anzeigen", "bankImage": "img/dtz-b1-m03-lv2.jpg", "maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1}'::jsonb, 5),
    ('lv3', 'Lesen', 'Lesen, Teil 3', 10, 'Lesen Sie die drei Texte. Zu jedem Text gibt es zwei Aufgaben. Entscheiden Sie bei jedem Text, ob die Aussage richtig oder falsch ist und welche Antwort (a, b oder c) am besten passt.', 'mc', '{"passages": [{"paragraphs": [{"t": "Neuer Fitness- und Gesundheitsspezialist", "b": false}, {"t": "Fitness ist der Schlüssel zu mehr Wohlbefinden. Weil der KKB Krankenkasse die Gesundheit ihrer Mitglieder wichtig ist, hat sie Trainer Tom engagiert. Als echter Alleskönner für Fitness und Gesundheit hat er ein abwechslungsreiches Trainingsprogramm zusammengestellt, von dem ab sofort jedes Mitglied profitieren kann. Um einen erkennbaren Trainingseffekt zu erhalten, spielen Regelmäßigkeit des Trainings, Kraft und Beweglichkeit eine große Rolle. Die ausgewählten Übungen sind einfach zu erlernen, kosten kaum Zeit und lassen sich fast überall durchführen. So werden selbst untrainierte „Bewegungsmuffel“ nach wenigen Trainingseinheiten feststellen, dass sich kleine Sportübungen lohnen. Und das Schöne ist: Man muss weder einen Fitness-Club noch eine Sporthalle aufsuchen. Alle Übungen sind auf der Internet-Seite der KKB Krankenkasse ausführlich mit Bildern beschrieben und können durch Eingabe der Mitgliedsnummer aufgerufen werden.", "b": false}]}, {"paragraphs": [{"t": "Liebe Eltern,", "b": false}, {"t": "damit alle Kinder sicher zur Schule kommen, bitten wir Sie um Ihre Mitarbeit. Wenn Ihr Kind zu Fuß zur Schule geht, wählen Sie nicht den kürzesten Weg, sondern den sichersten. Gehen Sie am Anfang den Weg mehrmals mit Ihrem Kind gemeinsam und üben Sie an kritischen Stellen das richtige Verhalten im Straßenverkehr.", "b": false}, {"t": "Wenn Sie Ihr Kind mit dem Auto zur Schule bringen, achten Sie bitte darauf, dass es auf einem entsprechenden Kindersitz sitzt und angeschnallt ist. Fahren Sie im Umkreis der Schule unbedingt langsam und vorsichtig, da es immer wieder vorkommt, dass Kinder plötzlich über die Straße rennen und dabei nicht auf den Verkehr achten.", "b": false}, {"t": "Ihre Schulleitung", "b": false}]}, {"paragraphs": [{"t": "Sehr geehrter Herr Demir,", "b": false}, {"t": "die Kabelanlagen für TV- und Radioempfang werden in der Stettenstraße 19 von unserer Firma neu installiert. Im Rahmen dieser Installationsarbeiten müssen wir", "b": false}, {"t": "am 30.11. zwischen 09:00 und 16:00 Uhr", "b": false}, {"t": "in Ihre Wohnung / Ihre privaten Kellerräume und auf den Dachboden.", "b": false}, {"t": "Sollten Sie zu dem geplanten Termin nicht zu Hause sein können, vereinbaren Sie bitte unbedingt frühzeitig einen neuen Termin mit uns unter 0233/67177632.", "b": false}, {"t": "Um die Einhaltung des Termins bzw. um seine rechtzeitige Verschiebung wird dringend gebeten. Sollten wir an dem genannten Termin keinen Zugang zu Ihren Räumlichkeiten erhalten, kann es sein, dass wir Ihren Anschluss aus technischen Gründen abschalten müssen.", "b": false}, {"t": "Mit freundlichen Grüßen", "b": false}, {"t": "Teletronica GmbH", "b": false}]}], "maxPoints": 6, "availablePoints": 6, "missing": 0, "pointsPerItem": 1}'::jsonb, 6),
    ('lv4', 'Lesen', 'Lesen, Teil 4', 9, 'Lesen Sie den Text. Entscheiden Sie, ob die Aussagen 37–39 richtig oder falsch sind.', 'mc', '{"passages": [{"paragraphs": [{"t": "Allgemeine Geschäftsbedingungen Trendmoden GmbH", "b": false}, {"t": "Vertragsabschluss", "b": false}, {"t": "Ihr Vertragspartner ist die Trendmoden GmbH. Nachdem uns Ihre Bestellung erreicht hat, erhalten Sie eine Eingangsbestätigung. Anschließend erfolgt der Versand der Ware.", "b": false}, {"t": "Versand", "b": false}, {"t": "Sie erhalten Ihre Bestellung nach Möglichkeit in einer einzelnen Sendung, es sei denn, Ihre Bestellung enthält Artikel, die getrennt verpackt befördert werden müssen oder erst zu einem späteren Zeitpunkt lieferbar sind. Wenn die Ware im Lager ist, liefern wir in der Regel in zwei bis fünf Werktagen, in jedem Fall jedoch schnellstmöglich.", "b": false}, {"t": "Wir versenden nur an Lieferadressen innerhalb Deutschlands, Österreichs und der Schweiz. Bitte beachten Sie, dass die Rechnungsanschrift ebenfalls in Deutschland, Österreich oder der Schweiz sein muss.", "b": false}, {"t": "Versandkosten", "b": false}, {"t": "Deutschland: € 4,95 für Porto und Verpackung, entfällt ab einem Bestellwert von € 125,00.", "b": false}, {"t": "Österreich und Schweiz: € 7,95 für Porto und Verpackung.", "b": false}, {"t": "Zahlungsart", "b": false}, {"t": "Deutschland: Kreditkarte (Master-/Eurocard und VISA) oder Rechnung", "b": false}, {"t": "Österreich und Schweiz: Kreditkarte (Master-/Eurocard und VISA)", "b": false}, {"t": "Wir behalten uns vor, die Zahlungsart gegebenenfalls zu ändern.", "b": false}, {"t": "Alle Preise beinhalten die gesetzliche Mehrwertsteuer. Die Ware bleibt bis zur vollständigen Bezahlung Eigentum der Trendmoden GmbH.", "b": false}, {"t": "Rückgabebelehrungen und Rückgaberecht", "b": false}, {"t": "Sie können die erhaltene Ware ohne Angabe von Gründen innerhalb von einem Monat zurücksenden. Die Frist beginnt frühestens mit Erhalt der Ware. Zur Wahrung der Frist genügt die rechtzeitige Absendung der Ware. Bei einer Rücksendung von Waren bis zu einem Bestellwert von 40,00 € (Bruttopreis) zahlen Sie die Kosten der Rücksendung selbst. Anderenfalls ist die Rücksendung für Sie kostenfrei. Bitte schicken Sie nur ausreichend frankierte Pakete zurück, da wir ansonsten Strafporto zahlen müssen und uns hierfür einen Abzug vom Rückerstattungsbetrag vorbehalten.", "b": false}, {"t": "Datenschutz und Sicherheit", "b": false}, {"t": "Ihre Daten werden ausschließlich im Rahmen der geltenden Datenschutzgesetze genutzt und verarbeitet.", "b": false}]}], "maxPoints": 3, "availablePoints": 3, "missing": 0, "pointsPerItem": 1}'::jsonb, 7),
    ('lv5', 'Lesen', 'Lesen, Teil 5', 6, 'Lesen Sie den Text und schließen Sie die Lücken 40–45. Welche Lösung (a, b oder c) passt am besten?', 'mc', '{"passages": [{"paragraphs": [{"t": "GUTE KLEIDER – Bahnstraße 1 – 06886 Lutherstadt Wittenberg", "b": false}, {"t": "Frau", "b": false}, {"t": "Barbara Schnied", "b": false}, {"t": "Blumenstraße 5", "b": false}, {"t": "06889 Reinsdorf", "b": false}, {"t": "Kundennummer: 123456", "b": false}, {"t": "Wittenberg, d. 16.04.20..", "b": false}, {"t": "ZAHLUNGSERINNERUNG", "b": false}, {"t": "Sehr geehrte Frau Schnied,", "b": false}, {"t": "bitte helfen Sie (40): Unsere Buchhaltung hat den Betrag von 59,65 € vom 10.03. noch nicht als Zahlungseingang feststellen (41).", "b": false}, {"t": "(42) Sie in der Hektik des Alltags vergessen, den Rechnungsbetrag zu überweisen? Wir bitten Sie in diesem Fall um Zahlung innerhalb der (43) 14 Tage. Oder haben Sie den Betrag (44) bezahlt, und wir konnten das Geld nicht richtig zuordnen? (45) bitten wir um Zusendung des Zahlungsbelegs.", "b": false}, {"t": "Wir bedanken uns für Ihre Mithilfe.", "b": false}, {"t": "Mit freundlichem Gruß", "b": false}, {"t": "Maria Kleidermann", "b": false}]}], "maxPoints": 6, "availablePoints": 6, "missing": 0, "pointsPerItem": 1}'::jsonb, 8),
    ('s1', 'Schreiben', 'Schreiben', 30, 'Wählen Sie Aufgabe A oder Aufgabe B. Zeigen Sie, was Sie können. Schreiben Sie möglichst viel. Schreiben Sie Ihren Text auf den Antwortbogen.', 'writing', '{"maxPoints": 20, "availablePoints": 20, "missing": 0, "pointsPerItem": 20}'::jsonb, 9)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'dtz-b1' and t.slug = 'modell-03'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('hv1', '1', 'Was soll Herr Matuschek machen?', '[{"key": "A", "text": "Den Stromzähler ablesen."}, {"key": "B", "text": "Die Stromrechnung bezahlen."}, {"key": "C", "text": "Einen neuen Termin machen."}]'::jsonb, 1, null::jsonb, 0),
    ('hv1', '2', 'Wohin soll Frau Böhmer kommen?', '[{"key": "A", "text": "In den Kindergarten."}, {"key": "B", "text": "Zur Agentur für Arbeit."}, {"key": "C", "text": "Zur Schule."}]'::jsonb, 1, null::jsonb, 1),
    ('hv1', '3', 'Wohin soll Herr Holstein mit seinem Sohn gehen?', '[{"key": "A", "text": "Ins Krankenhaus."}, {"key": "B", "text": "Zum Arzt."}, {"key": "C", "text": "Zum Gesundheitsamt."}]'::jsonb, 1, null::jsonb, 2),
    ('hv1', '4', 'Wo soll Herr Lee sein Auto abholen?', '[{"key": "A", "text": "Bei der Polizei."}, {"key": "B", "text": "Bei einem Autohändler."}, {"key": "C", "text": "In der Werkstatt."}]'::jsonb, 1, null::jsonb, 3),
    ('hv2', '5', 'Was hören Sie?', '[{"key": "A", "text": "Das Horoskop."}, {"key": "B", "text": "Den Wetterbericht."}, {"key": "C", "text": "Die Sportnachrichten."}]'::jsonb, 1, null::jsonb, 0),
    ('hv2', '6', 'Die Züge ...', '[{"key": "A", "text": "fahren mit Verspätung."}, {"key": "B", "text": "fahren wie immer."}, {"key": "C", "text": "werden durch Busse ersetzt."}]'::jsonb, 1, null::jsonb, 1),
    ('hv2', '7', 'Wie macht man bei dem Gewinnspiel mit?', '[{"key": "A", "text": "Man muss beim Sender anrufen."}, {"key": "B", "text": "Man muss sich auf der Internetseite anmelden."}, {"key": "C", "text": "Man schreibt eine Postkarte."}]'::jsonb, 1, null::jsonb, 2),
    ('hv2', '8', 'Wo fährt der Falschfahrer?', '[{"key": "A", "text": "Auf der A 7."}, {"key": "B", "text": "Auf der A 8."}, {"key": "C", "text": "Auf der A 96."}]'::jsonb, 1, null::jsonb, 3),
    ('hv2', '9', 'Wie wird das Wetter in Westdeutschland?', '[{"key": "A", "text": "Es gibt Regen."}, {"key": "B", "text": "Es gibt Schnee."}, {"key": "C", "text": "Es wird sonnig."}]'::jsonb, 1, null::jsonb, 4),
    ('hv3', '10', 'Das Gespräch findet in Norwegen statt.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 0),
    ('hv3', '11', 'Worum bittet Herr Jansen Frau Samsonov?', '[{"key": "A", "text": "Sie soll auf das Haus von Familie Jansen aufpassen."}, {"key": "B", "text": "Sie soll Herrn Jansen den Schlüssel geben."}, {"key": "C", "text": "Sie soll sich um die Katzen von Familie Jansen kümmern."}]'::jsonb, 1, null::jsonb, 1),
    ('hv3', '12', 'Frau Baier und Herr Steiner sind Kollegen.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 2),
    ('hv3', '13', 'Was macht Frau Baier?', '[{"key": "A", "text": "Sie kauft die Wohnung."}, {"key": "B", "text": "Sie mietet die Wohnung."}, {"key": "C", "text": "Sie will ihrem Mann von der Wohnung erzählen."}]'::jsonb, 1, null::jsonb, 3),
    ('hv3', '14', 'Frau Melnik telefoniert mit dem Lehrer ihrer Tochter.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 4),
    ('hv3', '15', 'Was kann Frau Melnik nicht so gut?', '[{"key": "A", "text": "Einladungen schreiben."}, {"key": "B", "text": "Getränke verkaufen."}, {"key": "C", "text": "Kuchen backen."}]'::jsonb, 1, null::jsonb, 5),
    ('hv3', '16', 'Frau Keller ist in einem Lebensmittelgeschäft.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 6),
    ('hv3', '17', 'Wie viel kosten die Medikamente?', '[{"key": "A", "text": "20,00 €"}, {"key": "B", "text": "18,50 €"}, {"key": "C", "text": "1,50 €"}]'::jsonb, 1, null::jsonb, 7),
    ('hv4', '18', 'Sprecher 1', null::jsonb, 1, null::jsonb, 0),
    ('hv4', '19', 'Sprecher 2', null::jsonb, 1, null::jsonb, 1),
    ('hv4', '20', 'Sprecher 3', null::jsonb, 1, null::jsonb, 2),
    ('lv1', '21', 'Sie wollen heiraten. Wohin gehen Sie?', '[{"key": "A", "text": "210"}, {"key": "B", "text": "211"}, {"key": "C", "text": "anderes Zimmer"}]'::jsonb, 1, null::jsonb, 0),
    ('lv1', '22', 'Sie wollen sich beim Chef des Bürgerbüros über etwas beschweren.', '[{"key": "A", "text": "111"}, {"key": "B", "text": "112"}, {"key": "C", "text": "anderes Zimmer"}]'::jsonb, 1, null::jsonb, 1),
    ('lv1', '23', 'Sie haben gestern Ihr Handy verloren und hoffen, dass es jemand abgegeben hat.', '[{"key": "A", "text": "113"}, {"key": "B", "text": "115"}, {"key": "C", "text": "anderes Zimmer"}]'::jsonb, 1, null::jsonb, 2),
    ('lv1', '24', 'Sie sind umgezogen und möchten Ihre neue Adresse melden.', '[{"key": "A", "text": "111"}, {"key": "B", "text": "211"}, {"key": "C", "text": "anderes Zimmer"}]'::jsonb, 1, null::jsonb, 3),
    ('lv1', '25', 'Sie möchten einen Anwohnerparkausweis beantragen.', '[{"key": "A", "text": "111"}, {"key": "B", "text": "112"}, {"key": "C", "text": "anderes Zimmer"}]'::jsonb, 1, null::jsonb, 4),
    ('lv2', '26', 'Sie möchten Ihren Vater zum Essen einladen. Ihr Vater liebt die asiatische Küche und kann nicht alleine laufen.', null::jsonb, 1, null::jsonb, 0),
    ('lv2', '27', 'Für eine Hochzeitsfeier mit über hundert Gästen suchen Sie ein passendes Restaurant.', null::jsonb, 1, null::jsonb, 1),
    ('lv2', '28', 'Sie möchten Ihren Geburtstag zu Hause feiern, aber das Essen nicht selbst kochen. Sie erwarten zwölf Gäste.', null::jsonb, 1, null::jsonb, 2),
    ('lv2', '29', 'Sie möchten mit Ihren Kindern (2 und 6 Jahre alt) am Samstagabend essen gehen. Sie wollen im Freien sitzen, aber trotzdem bei Regen nicht nass werden.', null::jsonb, 1, null::jsonb, 3),
    ('lv2', '30', 'Sie haben Ihren Kindern versprochen, sie am Sonntag in ein Eiscafé zu einem großen Becher Eis einzuladen.', null::jsonb, 1, null::jsonb, 4),
    ('lv3', '31', 'Die KKB Krankenkasse bezahlt ihren Mitgliedern einen Kurs im Fitness-Club.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 0),
    ('lv3', '32', 'Um am Trainingsprogramm von Trainer Tom teilzunehmen,', '[{"key": "A", "text": "braucht man viel Zeit."}, {"key": "B", "text": "muss man ins Internet gehen."}, {"key": "C", "text": "muss man sehr sportlich sein."}]'::jsonb, 1, null::jsonb, 1),
    ('lv3', '33', 'Kinder sollen immer den kürzesten Weg zur Schule nehmen.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 2),
    ('lv3', '34', 'Eltern sollen', '[{"key": "A", "text": "den ganzen Weg zur Schule langsam fahren."}, {"key": "B", "text": "ihre Kinder immer begleiten."}, {"key": "C", "text": "mit ihren Kindern den Schulweg üben."}]'::jsonb, 1, null::jsonb, 3),
    ('lv3', '35', 'Die Firma Teletronica GmbH kann auch an einem anderen Termin kommen.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 4),
    ('lv3', '36', 'Herr Demir soll vor dem 30.11. die Firma Teletronica GmbH anrufen,', '[{"key": "A", "text": "wenn er an dem Tag nicht zu Hause ist."}, {"key": "B", "text": "wenn er Informationen zu seinem TV- und Radioempfang braucht."}, {"key": "C", "text": "wenn er keinen neuen Anschluss möchte."}]'::jsonb, 1, null::jsonb, 5),
    ('lv4', '37', 'Die Ware wird immer innerhalb von fünf Werktagen geliefert.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 0),
    ('lv4', '38', 'Die Ware wird an Kunden in der ganzen Welt verschickt.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 1),
    ('lv4', '39', 'Bei Rücksendung der Ware muss der Kunde in bestimmten Fällen das Porto selbst bezahlen.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 2),
    ('lv5', '40', 'Lücke 40', '[{"key": "A", "text": "euch"}, {"key": "B", "text": "ihnen"}, {"key": "C", "text": "uns"}]'::jsonb, 1, null::jsonb, 0),
    ('lv5', '41', 'Lücke 41', '[{"key": "A", "text": "können"}, {"key": "B", "text": "müssen"}, {"key": "C", "text": "sollen"}]'::jsonb, 1, null::jsonb, 1),
    ('lv5', '42', 'Lücke 42', '[{"key": "A", "text": "Haben"}, {"key": "B", "text": "Hätten"}, {"key": "C", "text": "Würden"}]'::jsonb, 1, null::jsonb, 2),
    ('lv5', '43', 'Lücke 43', '[{"key": "A", "text": "letzten"}, {"key": "B", "text": "nächsten"}, {"key": "C", "text": "vorigen"}]'::jsonb, 1, null::jsonb, 3),
    ('lv5', '44', 'Lücke 44', '[{"key": "A", "text": "erst"}, {"key": "B", "text": "schon"}, {"key": "C", "text": "wieder"}]'::jsonb, 1, null::jsonb, 4),
    ('lv5', '45', 'Lücke 45', '[{"key": "A", "text": "Damit"}, {"key": "B", "text": "Dann"}, {"key": "C", "text": "Sonst"}]'::jsonb, 1, null::jsonb, 5),
    ('s1', '46', 'Aufgabe A: Sie haben ein interessantes Wohnungsangebot gelesen. Sie schreiben einen Brief an den Vermieter, Herrn Schmitz, weil Sie sich für die Wohnung interessieren. Schreiben Sie etwas über folgende Punkte. Vergessen Sie nicht die Anrede und den Gruß. - Grund für Ihr Schreiben - Angaben zu Ihrer Person - Termin für Besichtigung - möglicher Einzugstermin oder Aufgabe B: Sie haben vor einem halben Jahr bei der Firma Neumann eine Waschmaschine gekauft. Jetzt ist sie kaputt. Sie erreichen bei der Firma telefonisch niemanden. Deshalb schreiben Sie eine E-Mail. Schreiben Sie etwas über folgende Punkte. Vergessen Sie nicht die Anrede und den Gruß. - Grund für Ihr Schreiben - Garantie - Reparatur oder neue Waschmaschine - wie Sie erreichbar sind', null::jsonb, 0, null::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'dtz-b1' and t.slug = 'modell-03'
join sections s on s.test_id = t.id and s.section_id = v.section_id
on conflict (section_id, item_id) do update set text = excluded.text, options = excluded.options, points = excluded.points, meta = excluded.meta, sort = excluded.sort;

insert into item_answers (item_id, answer, explanation)
select i.id, v.answer, v.explanation
from (values
    ('hv1', '1', 'C', null),
    ('hv1', '2', 'B', null),
    ('hv1', '3', 'B', null),
    ('hv1', '4', 'C', null),
    ('hv2', '5', 'A', null),
    ('hv2', '6', 'C', null),
    ('hv2', '7', 'A', null),
    ('hv2', '8', 'C', null),
    ('hv2', '9', 'C', null),
    ('hv3', '10', 'f', null),
    ('hv3', '11', 'C', null),
    ('hv3', '12', 'f', null),
    ('hv3', '13', 'C', null),
    ('hv3', '14', 'r', null),
    ('hv3', '15', 'C', null),
    ('hv3', '16', 'f', null),
    ('hv3', '17', 'B', null),
    ('hv4', '18', 'E', null),
    ('hv4', '19', 'A', null),
    ('hv4', '20', 'D', null),
    ('lv1', '21', 'A', null),
    ('lv1', '22', 'B', null),
    ('lv1', '23', 'A', null),
    ('lv1', '24', 'A', null),
    ('lv1', '25', 'C', null),
    ('lv2', '26', 'F', null),
    ('lv2', '27', 'A', null),
    ('lv2', '28', 'B', null),
    ('lv2', '29', 'E', null),
    ('lv2', '30', 'X', null),
    ('lv3', '31', 'f', null),
    ('lv3', '32', 'B', null),
    ('lv3', '33', 'f', null),
    ('lv3', '34', 'C', null),
    ('lv3', '35', 'r', null),
    ('lv3', '36', 'A', null),
    ('lv4', '37', 'f', null),
    ('lv4', '38', 'f', null),
    ('lv4', '39', 'r', null),
    ('lv5', '40', 'C', null),
    ('lv5', '41', 'A', null),
    ('lv5', '42', 'A', null),
    ('lv5', '43', 'B', null),
    ('lv5', '44', 'B', null),
    ('lv5', '45', 'B', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'dtz-b1' and t.slug = 'modell-03'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;


commit;
