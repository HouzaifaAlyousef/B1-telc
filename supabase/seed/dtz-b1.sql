-- مولّد من content/dtz/b1 بـtools/export_sql.py — لا تعدّله بالإيد
begin;

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

-- ================= modell-04 · DEMBROWA =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('dtz-b1', 'modell-04', 'DEMBROWA', '46 Aufgaben · 100 Minuten',
        '[{"id": "block-hoeren", "parts": ["hv1", "hv2", "hv3", "hv4"], "title": "Hören", "minutes": 25, "hint": "Aufgaben 1–20", "maxPoints": 20, "availablePoints": 20, "missing": 0}, {"id": "block-lesen", "parts": ["lv1", "lv2", "lv3", "lv4", "lv5"], "title": "Lesen", "minutes": 45, "hint": "Aufgaben 21–45", "maxPoints": 25, "availablePoints": 25, "missing": 0}, {"id": "block-schreiben", "parts": ["s1"], "title": "Schreiben", "minutes": 30, "hint": "Aufgabe 46", "maxPoints": 20, "availablePoints": 20, "missing": 0}]'::jsonb, 46, true, 4)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('hv1', 'Hören', 'Hören, Teil 1', 6, 'Sie hören vier Ansagen. Zu jeder Ansage gibt es eine Aufgabe. Welche Lösung (a, b oder c) passt am besten?', 'mc', '{"maxPoints": 4, "availablePoints": 4, "missing": 0, "pointsPerItem": 1, "audioPlays": 1}'::jsonb, 0),
    ('hv2', 'Hören', 'Hören, Teil 2', 5, 'Sie hören fünf Ansagen aus dem Radio. Zu jeder Ansage gibt es eine Aufgabe. Welche Lösung (a, b oder c) passt am besten?', 'mc', '{"maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1, "audioPlays": 1}'::jsonb, 1),
    ('hv3', 'Hören', 'Hören, Teil 3', 7, 'Sie hören vier Gespräche. Zu jedem Gespräch gibt es zwei Aufgaben. Entscheiden Sie bei jedem Gespräch, ob die Aussage dazu richtig oder falsch ist und welche Antwort (a, b oder c) am besten passt.', 'mc', '{"maxPoints": 8, "availablePoints": 8, "missing": 0, "pointsPerItem": 1, "audioPlays": 1}'::jsonb, 2),
    ('hv4', 'Hören', 'Hören, Teil 4', 7, 'Sie hören die Meinungen von drei Personen zu einem Thema. Wählen Sie für die Aufgaben 18–20 die passende Aussage (a–f).', 'matching', '{"bank": [{"key": "A", "text": "Am besten sollte man jeden Tag Sport machen."}, {"key": "B", "text": "Sport ist nicht gut für ältere Leute."}, {"key": "C", "text": "Nicht alle haben Zeit für Sport."}, {"key": "D", "text": "Sport ist gut gegen Erkältung."}, {"key": "E", "text": "Sport macht nur zusammen mit anderen Spaß."}, {"key": "F", "text": "Zu viel Sport kann auch schaden."}], "bankTitle": "Aussagen", "maxPoints": 3, "availablePoints": 3, "missing": 0, "pointsPerItem": 1, "audioPlays": 1}'::jsonb, 3),
    ('lv1', 'Lesen', 'Lesen, Teil 1', 10, 'Sie sind beim Bürgerservice Ihrer Stadtverwaltung. Lesen Sie die Aufgaben 21–25 und den Wegweiser. In welches Zimmer (a, b oder c) gehen Sie?', 'mc', '{"bankImage": "img/dtz-b1-m04-lv1.jpg", "maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1}'::jsonb, 4),
    ('lv2', 'Lesen', 'Lesen, Teil 2', 10, 'Finden Sie zu jeder Situation (26–30) die passende Anzeige (a–h). Für eine Aufgabe gibt es keine passende Anzeige. Markieren Sie in diesem Fall ein x.', 'matching', '{"bank": [{"key": "A", "text": "Anzeige a"}, {"key": "B", "text": "Anzeige b"}, {"key": "C", "text": "Anzeige c"}, {"key": "D", "text": "Anzeige d"}, {"key": "E", "text": "Anzeige e"}, {"key": "F", "text": "Anzeige f"}, {"key": "G", "text": "Anzeige g"}, {"key": "H", "text": "Anzeige h"}, {"key": "X", "text": "Keine Anzeige passt"}], "bankTitle": "Anzeigen", "bankImage": "img/dtz-b1-m04-lv2.jpg", "maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1}'::jsonb, 5),
    ('lv3', 'Lesen', 'Lesen, Teil 3', 10, 'Lesen Sie die drei Texte. Zu jedem Text gibt es zwei Aufgaben. Entscheiden Sie bei jedem Text, ob die Aussage richtig oder falsch ist und welche Antwort (a, b oder c) am besten passt.', 'mc', '{"passages": [{"paragraphs": [{"t": "Bauarbeiten verärgern Bürger", "b": false}, {"t": "Seit Monaten beschäftigt der Neubau des Hauptbahnhofs die Bürger im 10. Gemeindebezirk von Wien. Wer in der Nähe der Baustelle wohnt, hat seit langer Zeit Probleme mit dem Schlaf. „Zu Beginn wurde sogar am Abend bis 21 Uhr gearbeitet“, berichtet Heinz Berger, der nur wenige Häuser von der Baustelle entfernt wohnt. „Ich habe dann mit den Nachbarn gemeinsam Unterschriften gesammelt und sie dem Bezirksvorsteher gebracht – erst dann wurde früher Feierabend gemacht.“ Ein kleiner Erfolg – aber eben nur ein kleiner. Andere Nachbarn erzählen, dass die Bauarbeiter bereits um 5 Uhr früh mit den Arbeiten beginnen und manchmal auch am Samstag arbeiten. Die Anrainer rund um den zukünftigen Wiener Hauptbahnhof haben nur einen Wunsch: endlich wieder in Ruhe schlafen können.", "b": false}]}, {"paragraphs": [{"t": "Liebe Eltern,", "b": false}, {"t": "bald beginnen die Sommerferien und wie Sie sicher wissen, wird dann auch wieder unser großes Sommerfest stattfinden. Aber nicht nur das: Auch unsere Frau Direktor, Frau Baumgartner, geht mit Ende dieses Schuljahres in Pension. Deshalb möchten wir Frau Baumgartner ein besonderes Geschenk machen: Ein Bild von allen Schülern und Eltern. Wir werden das Bild am nächsten Samstag vor dem Schulgebäude machen. Bitte geben Sie uns Bescheid, ob Sie am Samstag um 15 Uhr kommen können.", "b": false}, {"t": "Außerdem brauchen wir noch Helfer für das Sommerfest am selben Tag: Wenn Sie einen Salat oder Kuchen mitbringen möchten, melden Sie sich doch bitte bei Frau Wagner, unserer Sekretärin. Sie organisiert Essen und Getränke für das Fest.", "b": false}, {"t": "Mit freundlichen Grüßen und vielem Dank für Ihre Mitarbeit,", "b": false}, {"t": "F. Gruber, Assistentin", "b": false}]}, {"paragraphs": [{"t": "Sehr geehrter Herr Sanchez,", "b": false}, {"t": "mit Bedauern haben wir die Kündigung Ihrer Haftpflichtversicherung erhalten. Selbstverständlich werden wir den Termin wie gewünscht berücksichtigen.", "b": false}, {"t": "Uns interessiert aber sehr der Grund für Ihre Kündigung: Waren Sie mit dem Service nicht zufrieden? Haben Sie eine günstigere Versicherung gefunden?", "b": false}, {"t": "Wir würden uns freuen, wenn Sie weiterhin unser Kunde bleiben. Deshalb haben wir ein besonderes Angebot für Sie:", "b": false}, {"t": "Bleiben Sie bei unserer Versicherung und Sie zahlen für die nächsten 6 Monate keinen Beitrag! Ihr Versicherungsschutz bleibt natürlich bestehen – Sie sind also auch in dieser Zeit rundum versichert.", "b": false}, {"t": "Haben Sie Interesse? Dann rufen Sie uns an – alles andere machen wir für Sie!", "b": false}, {"t": "Mit freundlichen Grüßen", "b": false}, {"t": "Hans Schubert, ÖVG", "b": false}]}], "maxPoints": 6, "availablePoints": 6, "missing": 0, "pointsPerItem": 1}'::jsonb, 6),
    ('lv4', 'Lesen', 'Lesen, Teil 4', 9, 'Lesen Sie den Text. Entscheiden Sie, ob die Aussagen 37–39 richtig oder falsch sind.', 'mc', '{"passages": [{"paragraphs": [{"t": "Alginal extra – Packungsbeilage", "b": false}, {"t": "1. Was ist Alginal extra und wofür wird es angewendet?", "b": false}, {"t": "Alginal extra ist ein entzündungshemmendes und schmerzstillendes Arzneimittel.", "b": false}, {"t": "Alginal extra wird angewendet bei:", "b": false}, {"t": "- leichten bis mäßig starken Schmerzen (z. B. Kopfschmerzen, Zahnschmerzen)", "b": false}, {"t": "- Fieber", "b": false}, {"t": "2. Was müssen Sie vor der Einnahme von Alginal extra beachten?", "b": false}, {"t": "Alginal extra darf nicht eingenommen werden,", "b": false}, {"t": "- wenn Sie überempfindlich (allergisch) gegenüber Ibuprofen sind,", "b": false}, {"t": "- wenn Sie in der Vergangenheit mit Asthmaanfällen oder Hautreaktionen nach der Einnahme von Acetylsalicylsäure oder anderen Entzündungshemmern reagiert haben,", "b": false}, {"t": "- wenn Sie schwanger sind,", "b": false}, {"t": "- von Kindern unter 6 Jahren.", "b": false}, {"t": "3. Wie ist Alginal extra einzunehmen?", "b": false}, {"t": "Nehmen Sie Alginal extra immer genau nach der Anweisung in dieser Packungsbeilage ein. Nehmen Sie Alginal extra ohne ärztlichen Rat nicht länger als 4 Tage ein. Falls vom Arzt nicht anders verordnet, ist die übliche Einzeldosis für Kinder zwischen 6 und 14 Jahren ½ Filmtablette, für Jugendliche ab 15 Jahren und Erwachsene ½ bis 1 Filmtablette. An einem Tag dürfen Kinder bis 14 Jahren nicht mehr als ½ Filmtablette einnehmen, Jugendliche und Erwachsene nicht mehr als 2 Filmtabletten. Bei älteren Menschen ist keine spezielle Dosisanpassung erforderlich.", "b": false}, {"t": "Nehmen Sie die Filmtabletten unzerkaut mit einem Glas Wasser während einer Mahlzeit ein.", "b": false}, {"t": "4. Welche Nebenwirkungen sind möglich?", "b": false}, {"t": "Sehr selten: Magenbeschwerden", "b": false}, {"t": "Selten: Störungen der Blutbildung", "b": false}, {"t": "Gelegentlich: Sehstörungen, Erkrankungen des Ohrs", "b": false}, {"t": "5. Wie ist Alginal extra aufzubewahren?", "b": false}, {"t": "Arzneimittel für Kinder unzugänglich aufbewahren!", "b": false}, {"t": "Nach dem Verfallsdatum nicht mehr verwenden. Das Verfallsdatum bezieht sich auf den letzten Tag des Monats.", "b": false}]}], "maxPoints": 3, "availablePoints": 3, "missing": 0, "pointsPerItem": 1}'::jsonb, 7),
    ('lv5', 'Lesen', 'Lesen, Teil 5', 6, 'Lesen Sie den Text und schließen Sie die Lücken 40–45. Welche Lösung (a, b oder c) passt am besten?', 'mc', '{"passages": [{"paragraphs": [{"t": "Sehr geehrte Frau Schickl,", "b": false}, {"t": "letzte Woche habe ich bei (40) einen Pullover bestellt. (41) gestern das Paket kam, habe ich mich sehr gefreut. Aber leider haben Sie mir den falschen Pullover geschickt! Ich (42) einen blauen Pullover in Größe L für 29,90 Euro, (43) ich habe einen roten bekommen. Was soll ich tun? Und (44) wann bekomme ich den richtigen Pullover?", "b": false}, {"t": "Bitte (45) Sie mir schnell!", "b": false}, {"t": "Mit freundlichen Grüßen", "b": false}, {"t": "Maria Gruber", "b": false}]}], "maxPoints": 6, "availablePoints": 6, "missing": 0, "pointsPerItem": 1}'::jsonb, 8),
    ('s1', 'Schreiben', 'Schreiben', 30, 'Wählen Sie Aufgabe A oder Aufgabe B. Zeigen Sie, was Sie können. Schreiben Sie möglichst viel. Schreiben Sie Ihren Text auf den Antwortbogen.', 'writing', '{"maxPoints": 20, "availablePoints": 20, "missing": 0, "pointsPerItem": 20}'::jsonb, 9)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'dtz-b1' and t.slug = 'modell-04'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('hv1', '1', 'Was soll Frau Dembrowa machen?', '[{"key": "A", "text": "Frau Oberhauser heute anrufen."}, {"key": "B", "text": "Morgen bei der Volksbank anrufen."}, {"key": "C", "text": "Morgen zur Volksbank gehen."}]'::jsonb, 1, null::jsonb, 0),
    ('hv1', '2', 'Was soll Herr Gruber machen?', '[{"key": "A", "text": "Eine Nachricht schreiben."}, {"key": "B", "text": "Herrn Leitner anrufen."}, {"key": "C", "text": "Zum Arbeitsmarktservice gehen."}]'::jsonb, 1, null::jsonb, 1),
    ('hv1', '3', 'Wie lange kann man heute einkaufen?', '[{"key": "A", "text": "Bis 4 Uhr am Nachmittag."}, {"key": "B", "text": "Bis 6 Uhr am Abend."}, {"key": "C", "text": "Bis 7 Uhr abends."}]'::jsonb, 1, null::jsonb, 2),
    ('hv1', '4', 'Was soll Frau Li machen?', '[{"key": "A", "text": "Einen Termin machen."}, {"key": "B", "text": "Herrn Schrader schnell anrufen."}, {"key": "C", "text": "Zum Wohnungsamt gehen."}]'::jsonb, 1, null::jsonb, 3),
    ('hv2', '5', 'Im Westen wird es morgen ...', '[{"key": "A", "text": "kälter als heute."}, {"key": "B", "text": "wärmer als heute."}, {"key": "C", "text": "windig."}]'::jsonb, 1, null::jsonb, 0),
    ('hv2', '6', 'Die Musiksendung kommt auf ...', '[{"key": "A", "text": "Antenne 3."}, {"key": "B", "text": "Ö6."}, {"key": "C", "text": "Radio FM."}]'::jsonb, 1, null::jsonb, 1),
    ('hv2', '7', 'Was hören Sie?', '[{"key": "A", "text": "Nachrichten"}, {"key": "B", "text": "Verkehrshinweise"}, {"key": "C", "text": "Wetterbericht"}]'::jsonb, 1, null::jsonb, 2),
    ('hv2', '8', 'Wo sind Tiere auf der Autobahn?', '[{"key": "A", "text": "A 1"}, {"key": "B", "text": "A 2"}, {"key": "C", "text": "A 22"}]'::jsonb, 1, null::jsonb, 3),
    ('hv2', '9', 'Wo können Sie „Vitafix“ kaufen?', '[{"key": "A", "text": "In Apotheken und Drogerien."}, {"key": "B", "text": "In Supermärkten."}, {"key": "C", "text": "Nur in Apotheken."}]'::jsonb, 1, null::jsonb, 4),
    ('hv3', '10', 'Die Personen sind Nachbarn.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 0),
    ('hv3', '11', 'Herr Brunner ...', '[{"key": "A", "text": "findet Urlaub auf dem Bauernhof langweilig."}, {"key": "B", "text": "möchte auch Urlaub auf dem Bauernhof machen."}, {"key": "C", "text": "will seiner Schwester die Adresse vom Bauernhof geben."}]'::jsonb, 1, null::jsonb, 1),
    ('hv3', '12', 'Herr Huber sucht Arbeit.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 2),
    ('hv3', '13', 'Der Computerkurs', '[{"key": "A", "text": "dauert eine Woche."}, {"key": "B", "text": "ist für Herrn Huber nicht interessant."}, {"key": "C", "text": "wird vom Arbeitsmarktservice bezahlt."}]'::jsonb, 1, null::jsonb, 3),
    ('hv3', '14', 'Die Frau und der Mann sind Arbeitskollegen.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 4),
    ('hv3', '15', 'Claudia', '[{"key": "A", "text": "ist in Chemie nicht so gut."}, {"key": "B", "text": "soll an einem Wettbewerb teilnehmen."}, {"key": "C", "text": "soll nach Salzburg fahren."}]'::jsonb, 1, null::jsonb, 5),
    ('hv3', '16', 'Die Gastherme von Frau Schuster ist kaputt.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 6),
    ('hv3', '17', 'Herr Fuchs ...', '[{"key": "A", "text": "gibt Frau Schuster seinen Wohnungsschlüssel."}, {"key": "B", "text": "ist am Dienstag nicht zuhause."}, {"key": "C", "text": "nimmt Dienstag Urlaub."}]'::jsonb, 1, null::jsonb, 7),
    ('hv4', '18', 'Sprecher 1', null::jsonb, 1, null::jsonb, 0),
    ('hv4', '19', 'Sprecher 2', null::jsonb, 1, null::jsonb, 1),
    ('hv4', '20', 'Sprecher 3', null::jsonb, 1, null::jsonb, 2),
    ('lv1', '21', 'Sie möchten umziehen und brauchen Unterstützung.', '[{"key": "A", "text": "EG"}, {"key": "B", "text": "1. OG"}, {"key": "C", "text": "anderes Stockwerk"}]'::jsonb, 1, null::jsonb, 0),
    ('lv1', '22', 'Sie suchen einen Babysitter.', '[{"key": "A", "text": "1. OG"}, {"key": "B", "text": "3. OG"}, {"key": "C", "text": "anderes Stockwerk"}]'::jsonb, 1, null::jsonb, 1),
    ('lv1', '23', 'Sie möchten sich über Freizeitangebote informieren.', '[{"key": "A", "text": "2. OG"}, {"key": "B", "text": "3. OG"}, {"key": "C", "text": "anderes Stockwerk"}]'::jsonb, 1, null::jsonb, 2),
    ('lv1', '24', 'Sie möchten sich über Urlaub für Ihren Sohn (14 Jahre) informieren.', '[{"key": "A", "text": "EG"}, {"key": "B", "text": "4. OG"}, {"key": "C", "text": "anderes Stockwerk"}]'::jsonb, 1, null::jsonb, 3),
    ('lv1', '25', 'Sie möchten ein Passbild machen.', '[{"key": "A", "text": "1. OG"}, {"key": "B", "text": "2. OG"}, {"key": "C", "text": "anderes Stockwerk"}]'::jsonb, 1, null::jsonb, 4),
    ('lv2', '26', 'Sie möchten mit anderen Eltern über kleine Kinder reden.', null::jsonb, 1, null::jsonb, 0),
    ('lv2', '27', 'Sie suchen eine Teilzeitstelle. Sie haben eine Ausbildung als Verkäuferin.', null::jsonb, 1, null::jsonb, 1),
    ('lv2', '28', 'Sie möchten mit Ihrer Familie Urlaub auf dem Bauernhof machen.', null::jsonb, 1, null::jsonb, 2),
    ('lv2', '29', 'Sie suchen ein Geschenk für Ihre 3-jährige Nichte.', null::jsonb, 1, null::jsonb, 3),
    ('lv2', '30', 'Sie möchten altes Spielzeug von Ihren Kindern abgeben.', null::jsonb, 1, null::jsonb, 4),
    ('lv3', '31', 'Herr Berger möchte Ruhe in der Nacht.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 0),
    ('lv3', '32', 'Die Arbeiter ...', '[{"key": "A", "text": "arbeiten auch jetzt noch bis 21 Uhr."}, {"key": "B", "text": "arbeiten am Morgen nie vor 6 Uhr."}, {"key": "C", "text": "arbeiten manchmal auch am Wochenende."}]'::jsonb, 1, null::jsonb, 1),
    ('lv3', '33', 'Frau Baumgartner hört bald auf zu arbeiten.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 2),
    ('lv3', '34', 'Die Eltern sollen ...', '[{"key": "A", "text": "Frau Baumgartner ein Geschenk mitbringen."}, {"key": "B", "text": "kommenden Samstag Getränke mitbringen."}, {"key": "C", "text": "sagen, ob Sie kommenden Samstag Zeit haben."}]'::jsonb, 1, null::jsonb, 3),
    ('lv3', '35', 'Herr Sanchez hat seine Versicherung gekündigt.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 4),
    ('lv3', '36', 'Die Versicherung bietet Herrn Sanchez an, dass er ...', '[{"key": "A", "text": "ein halbes Jahr gratis versichert bleibt."}, {"key": "B", "text": "eine neue Versicherung bekommt."}, {"key": "C", "text": "einen besseren Service bekommt."}]'::jsonb, 1, null::jsonb, 5),
    ('lv4', '37', 'Auch Schwangere dürfen die Tabletten nehmen.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 0),
    ('lv4', '38', 'Ein 13-jähriges Kind darf eine Tablette pro Tag nehmen.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 1),
    ('lv4', '39', 'Man soll die Tabletten vor dem Essen nehmen.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 2),
    ('lv5', '40', 'Lücke 40', '[{"key": "A", "text": "Ihnen"}, {"key": "B", "text": "Euch"}, {"key": "C", "text": "Sie"}]'::jsonb, 1, null::jsonb, 0),
    ('lv5', '41', 'Lücke 41', '[{"key": "A", "text": "Als"}, {"key": "B", "text": "Ob"}, {"key": "C", "text": "Wenn"}]'::jsonb, 1, null::jsonb, 1),
    ('lv5', '42', 'Lücke 42', '[{"key": "A", "text": "mochte"}, {"key": "B", "text": "sollte"}, {"key": "C", "text": "wollte"}]'::jsonb, 1, null::jsonb, 2),
    ('lv5', '43', 'Lücke 43', '[{"key": "A", "text": "aber"}, {"key": "B", "text": "denn"}, {"key": "C", "text": "oder"}]'::jsonb, 1, null::jsonb, 3),
    ('lv5', '44', 'Lücke 44', '[{"key": "A", "text": "bis"}, {"key": "B", "text": "seit"}, {"key": "C", "text": "von"}]'::jsonb, 1, null::jsonb, 4),
    ('lv5', '45', 'Lücke 45', '[{"key": "A", "text": "antworten"}, {"key": "B", "text": "geben"}, {"key": "C", "text": "sagen"}]'::jsonb, 1, null::jsonb, 5),
    ('s1', '46', 'Aufgabe A: Sie suchen ein gebrauchtes Auto. Im Supermarkt haben Sie eine Anzeige gesehen: Herr Brandmeyer will sein Auto verkaufen. Sie wollen mehr Informationen und schreiben eine E-Mail. Schreiben Sie etwas zu folgenden Punkten: - Grund für Ihr Schreiben - Preis? - Alter/Zustand? - wann/wo anschauen? oder Aufgabe B: Ihre Krankenkassa will die Kosten für Ihre Zahnarztbehandlung nicht zahlen. Schreiben Sie Ihrer Krankenkassa einen Brief. Schreiben Sie etwas zu folgenden Punkten: - Grund für Ihr Schreiben - Grund für Ihren Besuch beim Zahnarzt - was Sie wollen - was Sie tun, wenn nichts passiert', null::jsonb, 0, null::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'dtz-b1' and t.slug = 'modell-04'
join sections s on s.test_id = t.id and s.section_id = v.section_id
on conflict (section_id, item_id) do update set text = excluded.text, options = excluded.options, points = excluded.points, meta = excluded.meta, sort = excluded.sort;

insert into item_answers (item_id, answer, explanation)
select i.id, v.answer, v.explanation
from (values
    ('hv1', '1', 'A', null),
    ('hv1', '2', 'C', null),
    ('hv1', '3', 'A', null),
    ('hv1', '4', 'C', null),
    ('hv2', '5', 'B', null),
    ('hv2', '6', 'A', null),
    ('hv2', '7', 'A', null),
    ('hv2', '8', 'A', null),
    ('hv2', '9', 'A', null),
    ('hv3', '10', 'r', null),
    ('hv3', '11', 'C', null),
    ('hv3', '12', 'r', null),
    ('hv3', '13', 'C', null),
    ('hv3', '14', 'f', null),
    ('hv3', '15', 'B', null),
    ('hv3', '16', 'f', null),
    ('hv3', '17', 'C', null),
    ('hv4', '18', 'F', null),
    ('hv4', '19', 'E', null),
    ('hv4', '20', 'C', null),
    ('lv1', '21', 'B', null),
    ('lv1', '22', 'C', null),
    ('lv1', '23', 'C', null),
    ('lv1', '24', 'B', null),
    ('lv1', '25', 'B', null),
    ('lv2', '26', 'H', null),
    ('lv2', '27', 'A', null),
    ('lv2', '28', 'X', null),
    ('lv2', '29', 'E', null),
    ('lv2', '30', 'C', null),
    ('lv3', '31', 'r', null),
    ('lv3', '32', 'C', null),
    ('lv3', '33', 'r', null),
    ('lv3', '34', 'C', null),
    ('lv3', '35', 'r', null),
    ('lv3', '36', 'A', null),
    ('lv4', '37', 'f', null),
    ('lv4', '38', 'f', null),
    ('lv4', '39', 'f', null),
    ('lv5', '40', 'A', null),
    ('lv5', '41', 'A', null),
    ('lv5', '42', 'C', null),
    ('lv5', '43', 'A', null),
    ('lv5', '44', 'A', null),
    ('lv5', '45', 'A', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'dtz-b1' and t.slug = 'modell-04'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;

-- ================= modell-06 · EBERT =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('dtz-b1', 'modell-06', 'EBERT', '46 Aufgaben · 100 Minuten',
        '[{"id": "block-hoeren", "parts": ["hv1", "hv2", "hv3", "hv4"], "title": "Hören", "minutes": 25, "hint": "Aufgaben 1–20", "maxPoints": 20, "availablePoints": 20, "missing": 0}, {"id": "block-lesen", "parts": ["lv1", "lv2", "lv3", "lv4", "lv5"], "title": "Lesen", "minutes": 45, "hint": "Aufgaben 21–45", "maxPoints": 25, "availablePoints": 25, "missing": 0}, {"id": "block-schreiben", "parts": ["s1"], "title": "Schreiben", "minutes": 30, "hint": "Aufgabe 46", "maxPoints": 20, "availablePoints": 20, "missing": 0}]'::jsonb, 46, true, 5)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('hv1', 'Hören', 'Hören, Teil 1', 6, 'Sie hören vier Ansagen. Zu jeder Ansage gibt es eine Aufgabe. Welche Lösung (a, b oder c) passt am besten?', 'mc', '{"maxPoints": 4, "availablePoints": 4, "missing": 0, "pointsPerItem": 1, "audioPlays": 1}'::jsonb, 0),
    ('hv2', 'Hören', 'Hören, Teil 2', 5, 'Sie hören fünf Ansagen aus dem Radio. Zu jeder Ansage gibt es eine Aufgabe. Welche Lösung (a, b oder c) passt am besten?', 'mc', '{"maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1, "audioPlays": 1}'::jsonb, 1),
    ('hv3', 'Hören', 'Hören, Teil 3', 7, 'Sie hören vier Gespräche. Zu jedem Gespräch gibt es zwei Aufgaben. Entscheiden Sie bei jedem Gespräch, ob die Aussage dazu richtig oder falsch ist und welche Antwort (a, b oder c) am besten passt.', 'mc', '{"maxPoints": 8, "availablePoints": 8, "missing": 0, "pointsPerItem": 1, "audioPlays": 1}'::jsonb, 2),
    ('hv4', 'Hören', 'Hören, Teil 4', 7, 'Sie hören die Meinungen von drei Personen zu einem Thema. Wählen Sie für die Aufgaben 18–20 die passende Aussage (a–f).', 'matching', '{"bank": [{"key": "A", "text": "Es ist wichtig, regelmäßig zum Arzt zu gehen."}, {"key": "B", "text": "Man hat keine Probleme mit der Gesundheit, wenn man schlank bleibt."}, {"key": "C", "text": "Man sollte nicht rauchen und wenig Alkohol trinken."}, {"key": "D", "text": "Wenn man sich viel bewegt, bleibt man auch gesund."}, {"key": "E", "text": "Die Gesundheit kommt von selbst, wenn man keinen Ärger hat."}, {"key": "F", "text": "Viele Medikamente schaden mehr als sie nützen."}], "bankTitle": "Aussagen", "maxPoints": 3, "availablePoints": 3, "missing": 0, "pointsPerItem": 1, "audioPlays": 1}'::jsonb, 3),
    ('lv1', 'Lesen', 'Lesen, Teil 1', 10, 'Sie sind im Rathaus Ihrer Stadt. Lesen Sie die Aufgaben 21–25 und den Wegweiser. In welches Zimmer (a, b oder c) gehen Sie?', 'mc', '{"bankImage": "img/dtz-b1-m06-lv1.jpg", "maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1}'::jsonb, 4),
    ('lv2', 'Lesen', 'Lesen, Teil 2', 10, 'Finden Sie zu jeder Situation (26–30) die passende Anzeige (a–h). Für eine Aufgabe gibt es keine passende Anzeige. Markieren Sie in diesem Fall ein x.', 'matching', '{"bank": [{"key": "A", "text": "Anzeige a"}, {"key": "B", "text": "Anzeige b"}, {"key": "C", "text": "Anzeige c"}, {"key": "D", "text": "Anzeige d"}, {"key": "E", "text": "Anzeige e"}, {"key": "F", "text": "Anzeige f"}, {"key": "G", "text": "Anzeige g"}, {"key": "H", "text": "Anzeige h"}, {"key": "X", "text": "Keine Anzeige passt"}], "bankTitle": "Anzeigen", "bankImage": "img/dtz-b1-m06-lv2.jpg", "maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1}'::jsonb, 5),
    ('lv3', 'Lesen', 'Lesen, Teil 3', 10, 'Lesen Sie die drei Texte. Zu jedem Text gibt es zwei Aufgaben. Entscheiden Sie bei jedem Text, ob die Aussage richtig oder falsch ist und welche Antwort (a, b oder c) am besten passt.', 'mc', '{"passages": [{"paragraphs": [{"t": "Nordhausen: Freie Fahrt für Familien und Personen mit geringem Einkommen", "b": false}, {"t": "Die Stadt Nordhausen führt zum 1. Februar für kinderreiche Familien und Personen mit geringem Einkommen einen neuen Fahrkarten-Service ein. Die Stadt schafft zwei Monatskarten für Einzelpersonen und zwei Familienmonatskarten für den Verkehrsverbund Nordhausen an. Die Einzeltickets sollen vor allem für Fahrten zu Behörden, Ärzten und Vorstellungsgesprächen genutzt werden, das Familienticket zum Besuch von kulturellen Veranstaltungen.", "b": false}, {"t": "Die Fahrkarten kann man jeweils für einen Tag ab 7:30 Uhr im Rathaus abholen. Sie müssen am nächsten Tag spätestens bis 7 Uhr zurückgegeben werden. Für die Abholung sind eine Unterschrift und ein gültiger Ausweis notwendig. Die Rückgabe ist auf zwei Wegen möglich: Man kann die Fahrkarten persönlich abgeben oder in den Briefkasten am Rathaus einwerfen.", "b": false}, {"t": "Nähere Informationen gibt es unter www.nordhausen.de oder von den Mitarbeitern des Bürgerbüros. Unter 01 31 - 73 73 72 ist eine telefonische Reservierung möglich.", "b": false}]}, {"paragraphs": [{"t": "Sehr geehrte Eltern,", "b": false}, {"t": "unsere Grundschule nimmt an dem Leseförderungsprogramm „Wir lesen!“ teil. Die Kinder können mit Fragen testen, wie gut sie den Inhalt eines Buches verstanden haben und bekommen dafür Punkte. Das Programm bietet nur die Fragen an, aber in der Stadtbücherei können Sie viele der darin behandelten Bücher ausleihen.", "b": false}, {"t": "Unsere Schule nimmt schon seit einigen Jahren an diesem Projekt teil. In der 2. Klasse beginnen wir mit dem Programm und führen es bis zur vierten Klasse durch. Zur Anmeldung ist ein Passwort notwendig, das die Kinder von der Klassenlehrkraft erhalten. Dafür benötigen wir einmalig eine Einverständniserklärung mit der Unterschrift der Eltern. Bitte geben Sie uns diese bis zum 01.10.", "b": false}, {"t": "Weitere Informationen erhalten Sie unter www.wirlesen.de.", "b": false}, {"t": "Mit freundlichen Grüßen", "b": false}, {"t": "Eva Kaubisch", "b": false}]}, {"paragraphs": [{"t": "Guten Tag Frau Kim,", "b": false}, {"t": "wir haben Ihren Heil- und Kostenplan für den Zahnersatz vom 23.2.2010 erhalten. Wir freuen uns Ihnen mitteilen zu können, dass wir 60 % der Kosten übernehmen. Leider ist eine Erstattung der Gesamtkosten nicht möglich, denn in Ihrem Versicherungsvertrag ist nur eine Bezuschussung von bis zu 60 % festgelegt.", "b": false}, {"t": "Bitte reichen Sie den Heil- und Kostenplan und diese Zusage vor der Behandlung an Ihre Praxis weiter. Ihr Zahnarzt rechnet nach der Behandlung die Kosten mit uns ab und Sie erhalten dann eine Rechnung über die Restsumme von Ihrem Zahnarzt.", "b": false}, {"t": "Bei Fragen rufen Sie uns gerne an.", "b": false}, {"t": "Freundliche Grüße", "b": false}, {"t": "Alexandra Klein", "b": false}]}], "maxPoints": 6, "availablePoints": 6, "missing": 0, "pointsPerItem": 1}'::jsonb, 6),
    ('lv4', 'Lesen', 'Lesen, Teil 4', 9, 'Lesen Sie den Text. Entscheiden Sie, ob die Aussagen 37–39 richtig oder falsch sind.', 'mc', '{"passages": [{"paragraphs": [{"t": "Ihr neuer Telefonanschluss – Ihr neuer Anrufbeantworter!", "b": false}, {"t": "Mit Ihrem neuen Telefonanschluss erhalten Sie automatisch einen Anrufbeantworter. Hier die wichtigsten Tipps für die Benutzung:", "b": false}, {"t": "Automatische Installation des Anrufbeantworters", "b": false}, {"t": "Innerhalb von einer Woche nach der Freischaltung Ihres neuen Anschlusses schaltet sich automatisch Ihr Anrufbeantworter ein. Er nimmt Anrufe entgegen, wenn Sie innerhalb von einer Minute den Anruf nicht entgegen nehmen oder wenn Ihr Apparat besetzt ist. Wenn Sie eine neue Nachricht haben, ruft Sie der Anrufbeantworter automatisch an und spielt Ihnen die Nachrichten vor. Sie können Ihren Anrufbeantworter auch personalisieren, indem Sie einen Begrüßungstext aufsprechen oder die Zeiten für die Aufnahme u. ä. ändern.", "b": false}, {"t": "Anrufbeantworter ein- und ausschalten", "b": false}, {"t": "Sie haben die Möglichkeit, den Anrufbeantworter auszuschalten. Dafür müssen Sie den Anrufbeantworter anwählen und dann die Tastenkombination 4# drücken.", "b": false}, {"t": "Nachrichten abfragen", "b": false}, {"t": "Sie können jederzeit Ihre Nachrichten abfragen, auch von unterwegs. Vom Festnetz wählen Sie den Anrufbeantworter an und drücken Sie im Hauptmenü 1. Für die Fernabfrage benötigen Sie eine PIN-Nummer, die Sie getrennt zugeschickt bekommen. Sie wählen dann Ihre eigene Rufnummer und drücken nach dem Begrüßungstext „0“. Anschließend geben Sie Ihre PIN-Nummer ein und bestätigen Sie diese erneut mit „0“.", "b": false}, {"t": "Nachrichten löschen", "b": false}, {"t": "Vom Festnetzanschluss oder per Fernabfrage können Sie Nachrichten auf dem Anrufbeantworter auch einzeln löschen. Geben Sie nach der Nachricht „*“ ein und die Nachricht wird gelöscht und kann nicht wieder aufgerufen werden.", "b": false}, {"t": "Benachrichtigung per SMS", "b": false}, {"t": "Über neue Nachrichten können Sie kostenfrei per SMS an Ihre Handy-Nummer informiert werden. Um diesen Service nutzen zu können, rufen Sie bitte die Nummer 08 00-70 07 00 an und registrieren Sie sich direkt bei unseren MitarbeiterInnen.", "b": false}]}], "maxPoints": 3, "availablePoints": 3, "missing": 0, "pointsPerItem": 1}'::jsonb, 7),
    ('lv5', 'Lesen', 'Lesen, Teil 5', 6, 'Lesen Sie den Text und schließen Sie die Lücken 40–45. Welche Lösung (a, b oder c) passt am besten?', 'mc', '{"passages": [{"paragraphs": [{"t": "DB Fernverkehr AG", "b": false}, {"t": "BahnCard-Service", "b": false}, {"t": "60643 Frankfurt am Main", "b": false}, {"t": "09.03.2010", "b": false}, {"t": "Kündigung der Bahncard Nr. 215762010", "b": false}, {"t": "(40) geehrte Damen und Herren,", "b": false}, {"t": "ich besitze (41) Juli 2009 eine BahnCard 25. Leider konnte ich die BahnCard nur wenig nutzen. Deshalb (42) ich mein Abonnement der Bahncard fristgerecht zum 01.07.2010 kündigen. Bitte schicken Sie mir (43) neue BahnCard, (44) bestätigen Sie mir diese Kündigung schriftlich.", "b": false}, {"t": "Bei Fragen erreichen Sie (45) telefonisch unter 0 69 – 7 44 89 33.", "b": false}, {"t": "Mit freundlichen Grüßen", "b": false}, {"t": "Hasan Özdemir", "b": false}]}], "maxPoints": 6, "availablePoints": 6, "missing": 0, "pointsPerItem": 1}'::jsonb, 8),
    ('s1', 'Schreiben', 'Schreiben', 30, 'Wählen Sie Aufgabe A oder Aufgabe B. Zeigen Sie, was Sie können. Schreiben Sie möglichst viel. Schreiben Sie Ihren Text auf den Antwortbogen.', 'writing', '{"maxPoints": 20, "availablePoints": 20, "missing": 0, "pointsPerItem": 20}'::jsonb, 9)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'dtz-b1' and t.slug = 'modell-06'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('hv1', '1', 'Was soll Frau Ebert machen?', '[{"key": "A", "text": "Die Polizei anrufen."}, {"key": "B", "text": "Die Rechnung bezahlen."}, {"key": "C", "text": "Die Versicherung bezahlen."}]'::jsonb, 1, null::jsonb, 0),
    ('hv1', '2', 'Die Tochter von Frau San braucht Hilfe in der Schule. Mit wem soll Frau San sprechen?', '[{"key": "A", "text": "Mit der Lehrerin."}, {"key": "B", "text": "Mit ihrem Mann."}, {"key": "C", "text": "Mit ihrer Tochter."}]'::jsonb, 1, null::jsonb, 1),
    ('hv1', '3', 'Frau Hetzel hat ein Problem mit der Gasrechnung. Was soll sie tun?', '[{"key": "A", "text": "Den Gaszähler ablesen."}, {"key": "B", "text": "Die Gasfirma anrufen."}, {"key": "C", "text": "Die Gasrechnung bezahlen."}]'::jsonb, 1, null::jsonb, 2),
    ('hv1', '4', 'Was soll Herr Bartel machen?', '[{"key": "A", "text": "Das Reisebüro anrufen."}, {"key": "B", "text": "Den Flug buchen."}, {"key": "C", "text": "Ins Reisebüro gehen."}]'::jsonb, 1, null::jsonb, 3),
    ('hv2', '5', 'Was kann man gewinnen?', '[{"key": "A", "text": "Eine CD."}, {"key": "B", "text": "Eine Fahrt nach München."}, {"key": "C", "text": "Konzertkarten."}]'::jsonb, 1, null::jsonb, 0),
    ('hv2', '6', 'Was hören Sie?', '[{"key": "A", "text": "Den Verkehrsfunk."}, {"key": "B", "text": "Die Nachrichten."}, {"key": "C", "text": "Ein Horoskop."}]'::jsonb, 1, null::jsonb, 1),
    ('hv2', '7', 'Wie wird das Wetter morgen?', '[{"key": "A", "text": "Die Sonne scheint."}, {"key": "B", "text": "Es schneit."}, {"key": "C", "text": "Es wird warm."}]'::jsonb, 1, null::jsonb, 2),
    ('hv2', '8', 'In der Innenstadt ...', '[{"key": "A", "text": "dürfen Taxis nicht fahren."}, {"key": "B", "text": "fahren keine Busse."}, {"key": "C", "text": "gibt es keine Parkplätze mehr."}]'::jsonb, 1, null::jsonb, 3),
    ('hv2', '9', 'Wo gibt es einen Stau?', '[{"key": "A", "text": "Auf der A 3."}, {"key": "B", "text": "Auf der A 42."}, {"key": "C", "text": "Auf der A 57."}]'::jsonb, 1, null::jsonb, 4),
    ('hv3', '10', 'Herr Hamann spricht mit seiner Chefin.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 0),
    ('hv3', '11', 'Was soll Herr Hamann am Wochenende tun?', '[{"key": "A", "text": "Er soll am Wochenende arbeiten."}, {"key": "B", "text": "Er soll einen Kollegen anrufen."}, {"key": "C", "text": "Er soll zur Firma Müller gehen."}]'::jsonb, 1, null::jsonb, 1),
    ('hv3', '12', 'Herr Förster und Frau Knauer sind Freunde.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 2),
    ('hv3', '13', 'Was soll Herr Förster machen?', '[{"key": "A", "text": "Den Briefkasten leeren."}, {"key": "B", "text": "Die Blumen gießen."}, {"key": "C", "text": "Die Katze versorgen."}]'::jsonb, 1, null::jsonb, 3),
    ('hv3', '14', 'Melanie und Leo lernen zusammen Russisch.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 4),
    ('hv3', '15', 'Was soll Melanie mitbringen?', '[{"key": "A", "text": "Musik-CDs."}, {"key": "B", "text": "Eine DVD."}, {"key": "C", "text": "Bilder."}]'::jsonb, 1, null::jsonb, 5),
    ('hv3', '16', 'Margit ist im Reisebüro.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 6),
    ('hv3', '17', 'Wie möchte Margit reisen?', '[{"key": "A", "text": "Mit dem Auto."}, {"key": "B", "text": "Mit dem Flugzeug."}, {"key": "C", "text": "Mit der Bahn."}]'::jsonb, 1, null::jsonb, 7),
    ('hv4', '18', 'Sprecher 1', null::jsonb, 1, null::jsonb, 0),
    ('hv4', '19', 'Sprecher 2', null::jsonb, 1, null::jsonb, 1),
    ('hv4', '20', 'Sprecher 3', null::jsonb, 1, null::jsonb, 2),
    ('lv1', '21', 'Ihre Frau hat ein Kind bekommen.', '[{"key": "A", "text": "Zimmer 13"}, {"key": "B", "text": "Zimmer 14"}, {"key": "C", "text": "anderes Zimmer"}]'::jsonb, 1, null::jsonb, 0),
    ('lv1', '22', 'Sie haben gestern Ihre Tasche im Bus vergessen.', '[{"key": "A", "text": "Zimmer 12"}, {"key": "B", "text": "Zimmer 14"}, {"key": "C", "text": "anderes Zimmer"}]'::jsonb, 1, null::jsonb, 1),
    ('lv1', '23', 'Sie müssen in den nächsten Schulferien arbeiten und suchen für Ihr Kind eine Betreuung.', '[{"key": "A", "text": "Zimmer 21"}, {"key": "B", "text": "Zimmer 22"}, {"key": "C", "text": "anderes Zimmer"}]'::jsonb, 1, null::jsonb, 2),
    ('lv1', '24', 'Sie haben ein Auto gekauft und möchten es anmelden.', '[{"key": "A", "text": "Zimmer 12"}, {"key": "B", "text": "Zimmer 23"}, {"key": "C", "text": "anderes Zimmer"}]'::jsonb, 1, null::jsonb, 3),
    ('lv1', '25', 'Sie möchten Ihre Arbeitserlaubnis für Deutschland verlängern.', '[{"key": "A", "text": "Zimmer 14"}, {"key": "B", "text": "Zimmer 21"}, {"key": "C", "text": "anderes Zimmer"}]'::jsonb, 1, null::jsonb, 4),
    ('lv2', '26', 'Sie möchten Englisch lernen und suchen einen Abendkurs. Der Lehrer soll unbedingt Muttersprachler sein.', null::jsonb, 1, null::jsonb, 0),
    ('lv2', '27', 'Sie kennen sich nicht gut mit Computern aus und möchten etwas über E-Mails lernen.', null::jsonb, 1, null::jsonb, 1),
    ('lv2', '28', 'Ihre achtzehnjährige Tochter ist sehr gut in Englisch und Französisch. Sie möchte gern anderen Schülern Nachhilfe geben.', null::jsonb, 1, null::jsonb, 2),
    ('lv2', '29', 'Sie suchen Informationen zur beruflichen Weiterbildung und wie Sie eine finanzielle Unterstützung bekommen können.', null::jsonb, 1, null::jsonb, 3),
    ('lv2', '30', 'Sie interessieren sich für die deutsche Geschichte und möchten gern kostenlos darüber etwas erfahren.', null::jsonb, 1, null::jsonb, 4),
    ('lv3', '31', 'Die Stadt Nordhausen verkauft billige Fahrkarten für Familien.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 0),
    ('lv3', '32', 'Die Fahrkarten kann man', '[{"key": "A", "text": "sich schicken lassen."}, {"key": "B", "text": "online bestellen."}, {"key": "C", "text": "im Rathaus bekommen."}]'::jsonb, 1, null::jsonb, 1),
    ('lv3', '33', 'Das Leseprogramm ist für Eltern und Kindern.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 2),
    ('lv3', '34', 'Die Eltern sollen bei Interesse', '[{"key": "A", "text": "ihr Kind selbst im Internet anmelden."}, {"key": "B", "text": "eine Erklärung unterschreiben."}, {"key": "C", "text": "der Lehrkraft ein Passwort mitteilen."}]'::jsonb, 1, null::jsonb, 3),
    ('lv3', '35', 'Die Versicherung bezahlt einen Teil der Kosten.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 4),
    ('lv3', '36', 'Bevor Frau Kim behandelt wird,', '[{"key": "A", "text": "muss sie diesen Brief Ihrem Zahnarzt geben."}, {"key": "B", "text": "überweist die Versicherung das Geld an Frau Kim."}, {"key": "C", "text": "muss Frau Kim Geld überweisen."}]'::jsonb, 1, null::jsonb, 5),
    ('lv4', '37', 'Man kann auf den Anrufbeantworter sprechen, wenn Sie telefonieren.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 0),
    ('lv4', '38', 'Sie können die Nachrichten nur zu Hause anhören.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 1),
    ('lv4', '39', 'Sie bekommen eine SMS über eine neue Nachricht, wenn Sie eine Gebühr bezahlt haben.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 2),
    ('lv5', '40', 'Lücke 40', '[{"key": "A", "text": "Meine"}, {"key": "B", "text": "Sehr"}, {"key": "C", "text": "Viel"}]'::jsonb, 1, null::jsonb, 0),
    ('lv5', '41', 'Lücke 41', '[{"key": "A", "text": "bis"}, {"key": "B", "text": "seit"}, {"key": "C", "text": "von"}]'::jsonb, 1, null::jsonb, 1),
    ('lv5', '42', 'Lücke 42', '[{"key": "A", "text": "möchte"}, {"key": "B", "text": "wünsche"}, {"key": "C", "text": "würde"}]'::jsonb, 1, null::jsonb, 2),
    ('lv5', '43', 'Lücke 43', '[{"key": "A", "text": "keine"}, {"key": "B", "text": "nicht"}, {"key": "C", "text": "nichts"}]'::jsonb, 1, null::jsonb, 3),
    ('lv5', '44', 'Lücke 44', '[{"key": "A", "text": "aber"}, {"key": "B", "text": "denn"}, {"key": "C", "text": "sondern"}]'::jsonb, 1, null::jsonb, 4),
    ('lv5', '45', 'Lücke 45', '[{"key": "A", "text": "mein"}, {"key": "B", "text": "mich"}, {"key": "C", "text": "mir"}]'::jsonb, 1, null::jsonb, 5),
    ('s1', '46', 'Aufgabe A: Ihre früheren Nachbarn sind vor einem Monat umgezogen und feiern ein Fest in der neuen Wohnung. Sie haben eine Einladung bekommen. Antworten Sie auf die Einladung. Schreiben Sie etwas über folgende Punkte. Vergessen Sie nicht die Anrede und den Gruß. - Grund des Schreibens - Geschenk - wer kommt noch? - Bitte um Wegbeschreibung oder Aufgabe B: In Ihrer Wohnung haben Sie seit einiger Zeit Probleme mit der Heizung. Der Vermieter soll die Heizung reparieren lassen. Leider können Sie Ihren Vermieter telefonisch nicht erreichen, deshalb schreiben Sie einen Brief. Schreiben Sie etwas über folgende Punkte. Vergessen Sie nicht die Anrede und den Gruß. - Grund des Schreibens - Problem: wie lange schon? - Termin für Reparatur - wie Sie erreichbar sind', null::jsonb, 0, null::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'dtz-b1' and t.slug = 'modell-06'
join sections s on s.test_id = t.id and s.section_id = v.section_id
on conflict (section_id, item_id) do update set text = excluded.text, options = excluded.options, points = excluded.points, meta = excluded.meta, sort = excluded.sort;

insert into item_answers (item_id, answer, explanation)
select i.id, v.answer, v.explanation
from (values
    ('hv1', '1', 'B', null),
    ('hv1', '2', 'A', null),
    ('hv1', '3', 'A', null),
    ('hv1', '4', 'C', null),
    ('hv2', '5', 'C', null),
    ('hv2', '6', 'C', null),
    ('hv2', '7', 'B', null),
    ('hv2', '8', 'C', null),
    ('hv2', '9', 'A', null),
    ('hv3', '10', 'r', null),
    ('hv3', '11', 'A', null),
    ('hv3', '12', 'f', null),
    ('hv3', '13', 'A', null),
    ('hv3', '14', 'r', null),
    ('hv3', '15', 'B', null),
    ('hv3', '16', 'f', null),
    ('hv3', '17', 'C', null),
    ('hv4', '18', 'C', null),
    ('hv4', '19', 'E', null),
    ('hv4', '20', 'A', null),
    ('lv1', '21', 'A', null),
    ('lv1', '22', 'C', null),
    ('lv1', '23', 'B', null),
    ('lv1', '24', 'A', null),
    ('lv1', '25', 'B', null),
    ('lv2', '26', 'C', null),
    ('lv2', '27', 'H', null),
    ('lv2', '28', 'X', null),
    ('lv2', '29', 'D', null),
    ('lv2', '30', 'A', null),
    ('lv3', '31', 'f', null),
    ('lv3', '32', 'C', null),
    ('lv3', '33', 'f', null),
    ('lv3', '34', 'B', null),
    ('lv3', '35', 'r', null),
    ('lv3', '36', 'A', null),
    ('lv4', '37', 'r', null),
    ('lv4', '38', 'f', null),
    ('lv4', '39', 'f', null),
    ('lv5', '40', 'B', null),
    ('lv5', '41', 'B', null),
    ('lv5', '42', 'A', null),
    ('lv5', '43', 'A', null),
    ('lv5', '44', 'C', null),
    ('lv5', '45', 'B', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'dtz-b1' and t.slug = 'modell-06'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;

-- ================= modell-07 · ARIAS =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('dtz-b1', 'modell-07', 'ARIAS', '46 Aufgaben · 100 Minuten',
        '[{"id": "block-hoeren", "parts": ["hv1", "hv2", "hv3", "hv4"], "title": "Hören", "minutes": 25, "hint": "Aufgaben 1–20", "maxPoints": 20, "availablePoints": 20, "missing": 0}, {"id": "block-lesen", "parts": ["lv1", "lv2", "lv3", "lv4", "lv5"], "title": "Lesen", "minutes": 45, "hint": "Aufgaben 21–45", "maxPoints": 25, "availablePoints": 25, "missing": 0}, {"id": "block-schreiben", "parts": ["s1"], "title": "Schreiben", "minutes": 30, "hint": "Aufgabe 46", "maxPoints": 20, "availablePoints": 20, "missing": 0}]'::jsonb, 46, true, 6)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('hv1', 'Hören', 'Hören, Teil 1', 6, 'Sie hören vier Ansagen. Zu jeder Ansage gibt es eine Aufgabe. Welche Lösung (a, b oder c) passt am besten?', 'mc', '{"maxPoints": 4, "availablePoints": 4, "missing": 0, "pointsPerItem": 1, "audioPlays": 1}'::jsonb, 0),
    ('hv2', 'Hören', 'Hören, Teil 2', 5, 'Sie hören fünf Ansagen aus dem Radio. Zu jeder Ansage gibt es eine Aufgabe. Welche Lösung (a, b oder c) passt am besten?', 'mc', '{"maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1, "audioPlays": 1}'::jsonb, 1),
    ('hv3', 'Hören', 'Hören, Teil 3', 7, 'Sie hören vier Gespräche. Zu jedem Gespräch gibt es zwei Aufgaben. Entscheiden Sie bei jedem Gespräch, ob die Aussage dazu richtig oder falsch ist und welche Antwort (a, b oder c) am besten passt.', 'mc', '{"maxPoints": 8, "availablePoints": 8, "missing": 0, "pointsPerItem": 1, "audioPlays": 1}'::jsonb, 2),
    ('hv4', 'Hören', 'Hören, Teil 4', 7, 'Sie hören die Meinungen von drei Personen zu einem Thema. Wählen Sie für die Aufgaben 18–20 die passende Aussage (a–f).', 'matching', '{"bank": [{"key": "A", "text": "Regelmäßig Sport treiben ist wichtiger als gesunde Ernährung."}, {"key": "B", "text": "Gesund leben kann man nur, wenn man viel Geld hat."}, {"key": "C", "text": "Wenig Stress und viel Ruhe sind gut für die Gesundheit."}, {"key": "D", "text": "Lebensmittel aus der Region sind frischer."}, {"key": "E", "text": "Spaß und Freude halten auch gesund."}, {"key": "F", "text": "Es ist gut, dass die Preise für viele Bio-Produkte gesunken sind."}], "bankTitle": "Aussagen", "maxPoints": 3, "availablePoints": 3, "missing": 0, "pointsPerItem": 1, "audioPlays": 1}'::jsonb, 3),
    ('lv1', 'Lesen', 'Lesen, Teil 1', 10, 'Sie sind im Medienhaus Süd. Lesen Sie die Aufgaben 21–25 und die Kaufhaustafel. Wo (a, b oder c) finden Sie etwas Passendes?', 'mc', '{"bankImage": "img/dtz-b1-m07-lv1.jpg", "maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1}'::jsonb, 4),
    ('lv2', 'Lesen', 'Lesen, Teil 2', 10, 'Finden Sie zu jeder Situation (26–30) die passende Anzeige (a–h). Für eine Aufgabe gibt es keine passende Anzeige. Markieren Sie in diesem Fall ein x.', 'matching', '{"bank": [{"key": "A", "text": "Anzeige a"}, {"key": "B", "text": "Anzeige b"}, {"key": "C", "text": "Anzeige c"}, {"key": "D", "text": "Anzeige d"}, {"key": "E", "text": "Anzeige e"}, {"key": "F", "text": "Anzeige f"}, {"key": "G", "text": "Anzeige g"}, {"key": "H", "text": "Anzeige h"}, {"key": "X", "text": "Keine Anzeige passt"}], "bankTitle": "Anzeigen", "bankImage": "img/dtz-b1-m07-lv2.jpg", "maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1}'::jsonb, 5),
    ('lv3', 'Lesen', 'Lesen, Teil 3', 10, 'Lesen Sie die drei Texte. Zu jedem Text gibt es zwei Aufgaben. Entscheiden Sie bei jedem Text, ob die Aussage richtig oder falsch ist und welche Antwort (a, b oder c) am besten passt.', 'mc', '{"passages": [{"paragraphs": [{"t": "Arbeit bei der Polizei", "b": false}, {"t": "Die hessische Polizei startet eine Kooperation mit der türkischen Tageszeitung Hürriyet. Ziel ist es, mehr ausländische Bewerberinnen und Bewerber für den Polizeiberuf zu interessieren. Als Vermittler zwischen den Kulturen genießen ausländische Polizisten besonderes Vertrauen in den unterschiedlichen Bevölkerungsgruppen. Sie sprechen die Sprache und sind mit den Traditionen ihrer Landsleute vertraut. Viele junge Menschen wissen nicht, dass Hessen schon seit 1994 Ausländer in den Polizeidienst einstellt. Dazu wird die deutsche Staatsangehörigkeit nicht benötigt.", "b": false}, {"t": "Der Anteil der Neueinstellungen von Polizisten, die nicht in Deutschland geboren sind, lag im vergangenen Jahr bei etwa 12 Prozent. Das entspricht ungefähr dem statistischen Ausländeranteil in Hessen. Ziel ist es, die Zahl der Ausländer bei der Polizei in den kommenden Jahren auf bis zu 20 Prozent zu erhöhen.", "b": false}]}, {"paragraphs": [{"t": "Liebe Eltern,", "b": false}, {"t": "am Samstag, den 4. Juni gibt es in der Albert-Schweitzer-Schule ein kleines Fest zur Eröffnung des neuen Schulhofs. Dazu laden wir Sie herzlich ein. Beginn 15 Uhr", "b": false}, {"t": "16.00 Uhr: Aufführung der Music Kids und ein kleines Theaterstück der Klassen 4a und 4b – alles auf dem neuen Schulhof, bei schlechtem Wetter in der Aula.", "b": false}, {"t": "Für Essen und Trinken ist gesorgt. Bitte bringen Sie aber, um Müll zu vermeiden, Tassen, Becher usw. mit. Sie finden unsere herzhaften und süßen Angebote sowie die Getränke auf dem neuen Schulhof und in der Cafeteria. Auf dem Fest können Sie auch die neuen Schul-T-Shirts kaufen, die endlich eingetroffen sind. Wir freuen uns auf Ihr Kommen!", "b": false}]}, {"paragraphs": [{"t": "An alle Mieter!", "b": false}, {"t": "Immer wieder beschweren sich Mieter über den Zustand des Kellers. Dort sind viele Fahrräder abgestellt, die nicht genutzt werden, sodass Mieter Probleme haben, an ihre Fahrräder zu kommen.", "b": false}, {"t": "Wir bitten Sie, an Ihr Fahrrad ein Namensschild zu hängen und Räder, die nicht benutzt werden, bis zum 1. August aus dem Keller zu nehmen. Außerdem bitten wir Sie, andere Gegenstände, z. B. alte Möbel, die nicht in den Keller gehören und dort abgestellt wurden, auch bis zum 1. August zu entfernen.", "b": false}, {"t": "Wenn das nicht geschieht, werden wir einer Firma den Auftrag geben, Fahrräder ohne Namensschild und die Sachen, die nicht in den Keller gehören, abzutransportieren. Die Kosten verteilen wir auf alle Mieter. Danach gilt die Regelung: Jeder Mieter darf nur noch ein Fahrrad in den Keller stellen.", "b": false}, {"t": "Vielen Dank für Ihr Verständnis.", "b": false}]}], "maxPoints": 6, "availablePoints": 6, "missing": 0, "pointsPerItem": 1}'::jsonb, 6),
    ('lv4', 'Lesen', 'Lesen, Teil 4', 9, 'Lesen Sie den Text. Entscheiden Sie, ob die Aussagen 37–39 richtig oder falsch sind.', 'mc', '{"passages": [{"paragraphs": [{"t": "VERBRAUCHER-INFORMATION", "b": false}, {"t": "Handy-Kündigung – Wie kündige ich richtig?", "b": false}, {"t": "Sie wollen Ihren Anbieter wechseln?", "b": false}, {"t": "Bei der Kündigung eines Handyvertrags gibt es eine Mindestvertragslaufzeit. Diese beträgt meistens zwei Jahre. Danach verlängert sich der Vertrag automatisch, meistens um weitere sechs bis zwölf Monate.", "b": false}, {"t": "Unterschreiben Sie das Kündigungsschreiben persönlich. Kündigen Sie nicht per E-Mail. Kündigungen ohne persönliche Unterschrift werden oft nicht anerkannt.", "b": false}, {"t": "Bei Kündigungen gibt es eine Kündigungsfrist. Diese beträgt in der Regel drei Monate. Die Kündigung muss beim Handyanbieter also spätestens drei Monate vor Ende der Vertragslaufzeit eingehen. In Ausnahmefällen können Sie auch kündigen, ohne sich an diese Frist zu halten. Dann müssen Sie aber einen Kündigungsgrund angeben.", "b": false}, {"t": "Informieren Sie sich vorher, falls Sie Zweifel haben.", "b": false}, {"t": "Am besten kündigen Sie per Einschreiben mit Rückschein: Der Empfänger unterschreibt dann persönlich, dass er die Kündigung erhalten hat.", "b": false}, {"t": "Was noch interessant sein könnte:", "b": false}, {"t": "Bei einem Wechsel des Anbieters können Sie Ihre alte Nummer meistens mitnehmen. Dafür müssen Sie aber eine Gebühr bezahlen.", "b": false}, {"t": "Vorsicht: Einige Anbieter verlangen nach Vertragsende die SIM-Karte zurück. Wenn Sie diese nicht zurückgeben, kann das 30 € kosten.", "b": false}, {"t": "Wenn Sie Ihre alte Handynummer zum neuen Anbieter mitnehmen möchten, ist es sinnvoll, wenn Sie eine Kündigungsbestätigung von Ihrem alten Anbieter an den neuen Anbieter schicken. Darin sollten die wichtigsten Details wie Zeitpunkt des Vertragsendes und Ihre Kundendaten stehen.", "b": false}]}], "maxPoints": 3, "availablePoints": 3, "missing": 0, "pointsPerItem": 1}'::jsonb, 7),
    ('lv5', 'Lesen', 'Lesen, Teil 5', 6, 'Lesen Sie den Text und schließen Sie die Lücken 40–45. Welche Lösung (a, b oder c) passt am besten?', 'mc', '{"passages": [{"paragraphs": [{"t": "Agentur für Arbeit · Familienkasse · Fischerfeldstraße 10–12 · 60311 Frankfurt", "b": false}, {"t": "Frankfurt, den 17. September 2010", "b": false}, {"t": "Ihr Antrag auf Kindergeld", "b": false}, {"t": "(40) Herr Usta,", "b": false}, {"t": "Ihr Antrag auf Kindergeld ist heute eingegangen.", "b": false}, {"t": "Leider fehlen noch einige (41). Auch haben Sie vergessen, den Antrag zu (42).", "b": false}, {"t": "Wir (43) Sie bitten, in den nächsten Tagen zwischen 8.00 und 12.00 Uhr bei der Familienkasse (Raum 311) vorbeizukommen.", "b": false}, {"t": "Falls einige Punkte im Antragsformular unklar sein sollten, helfen wir (44) gern.", "b": false}, {"t": "Mit (45) Grüßen", "b": false}, {"t": "Ihre Agentur für Arbeit", "b": false}]}], "maxPoints": 6, "availablePoints": 6, "missing": 0, "pointsPerItem": 1}'::jsonb, 8),
    ('s1', 'Schreiben', 'Schreiben', 30, 'Wählen Sie Aufgabe A oder Aufgabe B. Zeigen Sie, was Sie können. Schreiben Sie möglichst viel. Schreiben Sie Ihren Text auf den Antwortbogen.', 'writing', '{"maxPoints": 20, "availablePoints": 20, "missing": 0, "pointsPerItem": 20}'::jsonb, 9)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'dtz-b1' and t.slug = 'modell-07'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('hv1', '1', 'Sie wollen zum Flughafen. Von welchem Gleis müssen Sie fahren?', '[{"key": "A", "text": "Von Gleis 10."}, {"key": "B", "text": "Von Gleis 12."}, {"key": "C", "text": "Von Gleis 8."}]'::jsonb, 1, null::jsonb, 0),
    ('hv1', '2', 'Was soll Frau Arias tun?', '[{"key": "A", "text": "Herrn Bauer anrufen."}, {"key": "B", "text": "Morgen vorbeikommen."}, {"key": "C", "text": "Frau Maas anrufen."}]'::jsonb, 1, null::jsonb, 1),
    ('hv1', '3', 'Wann ist der nächste Deutschkurs?', '[{"key": "A", "text": "Am Mittwoch."}, {"key": "B", "text": "Am Donnerstag."}, {"key": "C", "text": "Am Freitag."}]'::jsonb, 1, null::jsonb, 2),
    ('hv1', '4', 'Was soll Herr Aslan machen?', '[{"key": "A", "text": "Zum Hausarzt gehen."}, {"key": "B", "text": "Eine Überweisung vorbeibringen."}, {"key": "C", "text": "Einen Termin ausmachen."}]'::jsonb, 1, null::jsonb, 3),
    ('hv2', '5', 'Wie ist das Wetter nächste Woche?', '[{"key": "A", "text": "Es wird sonnig und heiß."}, {"key": "B", "text": "Es wird kälter."}, {"key": "C", "text": "Es wird starke Gewitter geben."}]'::jsonb, 1, null::jsonb, 0),
    ('hv2', '6', 'Wie kann man heute Nachmittag zum Hauptbahnhof kommen?', '[{"key": "A", "text": "Mit der U- oder S-Bahn."}, {"key": "B", "text": "Mit dem Auto."}, {"key": "C", "text": "Mit der Straßenbahn oder dem Bus."}]'::jsonb, 1, null::jsonb, 1),
    ('hv2', '7', 'Was gibt es heute Abend im Radio?', '[{"key": "A", "text": "Einen Krimi."}, {"key": "B", "text": "Eine Musiksendung."}, {"key": "C", "text": "Eine Sendung aus Wirtschaft und Politik."}]'::jsonb, 1, null::jsonb, 2),
    ('hv2', '8', 'Welche Probleme gibt es auf der A 8?', '[{"key": "A", "text": "Bauarbeiten."}, {"key": "B", "text": "Einen Unfall."}, {"key": "C", "text": "Lange Staus."}]'::jsonb, 1, null::jsonb, 3),
    ('hv2', '9', 'In der Sendung „Tipps für Patienten“', '[{"key": "A", "text": "geht es um günstige Kassenbeiträge."}, {"key": "B", "text": "gibt es Informationen zum Bonusheft."}, {"key": "C", "text": "werden neue Zahnbehandlungen vorgestellt."}]'::jsonb, 1, null::jsonb, 4),
    ('hv3', '10', 'Sonja und ihr Mann haben eine neue Wohnung gemietet.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 0),
    ('hv3', '11', 'Die neue Wohnung', '[{"key": "A", "text": "ist teurer als die alte, hat aber mehr Quadratmeter."}, {"key": "B", "text": "hat keine Küche."}, {"key": "C", "text": "ist auf dem Land."}]'::jsonb, 1, null::jsonb, 1),
    ('hv3', '12', 'Frau Schmidt möchte ein Konto eröffnen.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 2),
    ('hv3', '13', 'Was fragt sie den Bankangestellten?', '[{"key": "A", "text": "Ob es in der Müllerstraße auch eine Bank gibt."}, {"key": "B", "text": "Ob Bankgeschäfte im Internet sicher sind."}, {"key": "C", "text": "Ob sie für Überweisungsformulare etwas bezahlen muss."}]'::jsonb, 1, null::jsonb, 3),
    ('hv3', '14', 'Anette und Claudia planen ein Hoffest.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 4),
    ('hv3', '15', 'Was sind die Pläne der Hausbewohner?', '[{"key": "A", "text": "Sie wollen den Hinterhof schöner machen."}, {"key": "B", "text": "Sie wollen jeden Monat feiern."}, {"key": "C", "text": "Sie wollen auch die neuen Nachbarn einladen."}]'::jsonb, 1, null::jsonb, 5),
    ('hv3', '16', 'Frau Klein und Frau Maier sprechen über einen neuen Mitarbeiter.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 6),
    ('hv3', '17', 'Beide Kolleginnen', '[{"key": "A", "text": "mögen Herrn Funke nicht besonders."}, {"key": "B", "text": "haben Angst vor Konflikten."}, {"key": "C", "text": "finden Arbeit im Team wichtig."}]'::jsonb, 1, null::jsonb, 7),
    ('hv4', '18', 'Sprecher 1', null::jsonb, 1, null::jsonb, 0),
    ('hv4', '19', 'Sprecher 2', null::jsonb, 1, null::jsonb, 1),
    ('hv4', '20', 'Sprecher 3', null::jsonb, 1, null::jsonb, 2),
    ('lv1', '21', 'Sie wollen eine E-Mail schreiben, können aber Ihren eigenen Computer nicht benutzen.', '[{"key": "A", "text": "Computer & Software"}, {"key": "B", "text": "Haushaltsgeräte & Haustechnik"}, {"key": "C", "text": "andere Abteilung"}]'::jsonb, 1, null::jsonb, 0),
    ('lv1', '22', 'Sie haben Ihren Fernseher zur Reparatur gegeben und möchten nachfragen, ob er fertig ist.', '[{"key": "A", "text": "Audio, TV, Foto, Handys"}, {"key": "B", "text": "Freizeit & Service"}, {"key": "C", "text": "andere Abteilung"}]'::jsonb, 1, null::jsonb, 1),
    ('lv1', '23', 'Sie suchen ein neues Radio.', '[{"key": "A", "text": "Klang & Licht"}, {"key": "B", "text": "Haushaltsgeräte & Haustechnik"}, {"key": "C", "text": "andere Abteilung"}]'::jsonb, 1, null::jsonb, 2),
    ('lv1', '24', 'Sie möchten Ihrer Freundin eine Eintrittskarte für ein Konzert schenken.', '[{"key": "A", "text": "CDs & DVDs"}, {"key": "B", "text": "Freizeit & Service"}, {"key": "C", "text": "andere Abteilung"}]'::jsonb, 1, null::jsonb, 3),
    ('lv1', '25', 'Sie suchen für Ihren Computer ein Programm, mit dem Sie Fotos bearbeiten können.', '[{"key": "A", "text": "Audio, TV, Foto, Handys"}, {"key": "B", "text": "Computer & Software"}, {"key": "C", "text": "andere Abteilung"}]'::jsonb, 1, null::jsonb, 4),
    ('lv2', '26', 'Sie suchen eine Ausbildungsstelle für Ihren Sohn. Er macht gerade Abitur und arbeitet gern am PC.', null::jsonb, 1, null::jsonb, 0),
    ('lv2', '27', 'Ihre Freundin sucht eine zentral gelegene Wohnung mit Balkon.', null::jsonb, 1, null::jsonb, 1),
    ('lv2', '28', 'Ein Freund will sich selbstständig machen. Er möchte ein Gemüsegeschäft aufmachen und sucht einen Ladenraum in guter Lage.', null::jsonb, 1, null::jsonb, 2),
    ('lv2', '29', 'Ihre Bekannte sucht eine Bürotätigkeit. Sie kann gut rechnen und am Computer arbeiten. Sie möchte keine Arbeit, bei der sie viel telefonieren muss.', null::jsonb, 1, null::jsonb, 3),
    ('lv2', '30', 'Sie haben Erfahrung mit der Pflege alter und behinderter Menschen und möchten gern als Pflegekraft arbeiten. Sie suchen eine Festanstellung.', null::jsonb, 1, null::jsonb, 4),
    ('lv3', '31', 'Die Polizei Hessens möchte, dass mehr Ausländer bei ihr arbeiten.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 0),
    ('lv3', '32', 'Wenn man bei der Polizei arbeiten will,', '[{"key": "A", "text": "muss man keinen deutschen Pass haben."}, {"key": "B", "text": "muss man seit 1994 in Deutschland leben."}, {"key": "C", "text": "bekommt man nächstes Jahr 20 Prozent mehr Gehalt."}]'::jsonb, 1, null::jsonb, 1),
    ('lv3', '33', 'Die Schule plant ein Fest, weil die neue Cafeteria fertig ist.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 2),
    ('lv3', '34', 'Die Festbesucher sollen', '[{"key": "A", "text": "T-Shirts der Schule tragen."}, {"key": "B", "text": "eigenes Geschirr mitbringen."}, {"key": "C", "text": "auf dem Schulhof Theater spielen."}]'::jsonb, 1, null::jsonb, 3),
    ('lv3', '35', 'Der Fahrradkeller ist zu voll.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 4),
    ('lv3', '36', 'Nach dem 1. August', '[{"key": "A", "text": "dürfen keine Räder mehr in den Keller gestellt werden."}, {"key": "B", "text": "müssen die Mieter etwas zahlen, wenn sie ihr Fahrrad in den Keller stellen."}, {"key": "C", "text": "gibt es im Keller nur noch Platz für ein Fahrrad für jeden Mieter."}]'::jsonb, 1, null::jsonb, 5),
    ('lv4', '37', 'Normalerweise müssen Sie Ihr Handy mindestens drei Monate vor Ende des Vertrags kündigen.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 0),
    ('lv4', '38', 'Sie müssen bei einer Kündigung immer auch Gründe für die Kündigung angeben.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 1),
    ('lv4', '39', 'Die Mitnahme der alten Handynummer ist kostenlos.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 2),
    ('lv5', '40', 'Lücke 40', '[{"key": "A", "text": "Sehr geehrte"}, {"key": "B", "text": "Sehr geehrter"}, {"key": "C", "text": "Lieber"}]'::jsonb, 1, null::jsonb, 0),
    ('lv5', '41', 'Lücke 41', '[{"key": "A", "text": "Aufgaben"}, {"key": "B", "text": "Angaben"}, {"key": "C", "text": "Ansagen"}]'::jsonb, 1, null::jsonb, 1),
    ('lv5', '42', 'Lücke 42', '[{"key": "A", "text": "beschreiben"}, {"key": "B", "text": "verschreiben"}, {"key": "C", "text": "unterschreiben"}]'::jsonb, 1, null::jsonb, 2),
    ('lv5', '43', 'Lücke 43', '[{"key": "A", "text": "möchten"}, {"key": "B", "text": "können"}, {"key": "C", "text": "sollen"}]'::jsonb, 1, null::jsonb, 3),
    ('lv5', '44', 'Lücke 44', '[{"key": "A", "text": "Sie"}, {"key": "B", "text": "Ihnen"}, {"key": "C", "text": "euch"}]'::jsonb, 1, null::jsonb, 4),
    ('lv5', '45', 'Lücke 45', '[{"key": "A", "text": "lieben"}, {"key": "B", "text": "fröhlichen"}, {"key": "C", "text": "freundlichen"}]'::jsonb, 1, null::jsonb, 5),
    ('s1', '46', 'Aufgabe A: Sie haben von Ihrem Vermieter eine Einladung zur Mieterversammlung bekommen. Sie können an diesem Termin nicht teilnehmen. Schreiben Sie an Ihren Vermieter, Herrn Schneider. Schreiben Sie etwas über folgende Punkte. Vergessen Sie nicht die Anrede und den Gruß. - Grund für Ihr Schreiben - Entschuldigung für Ihr Fehlen - wer Sie bei der Versammlung vertritt - Bitte um Zusendung des Protokolls oder Aufgabe B: Ihr Sohn hat die Schule gewechselt. Die neue Schule liegt weit von Ihrer Wohnung entfernt. Schreiben Sie einen Brief an das Schulamt und beantragen Sie eine Schulfahrkarte. Schreiben Sie etwas über folgende Punkte. Vergessen Sie nicht die Anrede und den Gruß. - Grund für Ihr Schreiben - Angaben zu Ihrem Kind und zur neuen Schule - Weg zur Schule - Bitte um eine kostenlose Schulfahrkarte', null::jsonb, 0, null::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'dtz-b1' and t.slug = 'modell-07'
join sections s on s.test_id = t.id and s.section_id = v.section_id
on conflict (section_id, item_id) do update set text = excluded.text, options = excluded.options, points = excluded.points, meta = excluded.meta, sort = excluded.sort;

insert into item_answers (item_id, answer, explanation)
select i.id, v.answer, v.explanation
from (values
    ('hv1', '1', 'B', null),
    ('hv1', '2', 'C', null),
    ('hv1', '3', 'B', null),
    ('hv1', '4', 'A', null),
    ('hv2', '5', 'B', null),
    ('hv2', '6', 'A', null),
    ('hv2', '7', 'C', null),
    ('hv2', '8', 'A', null),
    ('hv2', '9', 'B', null),
    ('hv3', '10', 'f', null),
    ('hv3', '11', 'A', null),
    ('hv3', '12', 'f', null),
    ('hv3', '13', 'C', null),
    ('hv3', '14', 'f', null),
    ('hv3', '15', 'A', null),
    ('hv3', '16', 'r', null),
    ('hv3', '17', 'C', null),
    ('hv4', '18', 'F', null),
    ('hv4', '19', 'A', null),
    ('hv4', '20', 'C', null),
    ('lv1', '21', 'C', null),
    ('lv1', '22', 'B', null),
    ('lv1', '23', 'C', null),
    ('lv1', '24', 'B', null),
    ('lv1', '25', 'B', null),
    ('lv2', '26', 'E', null),
    ('lv2', '27', 'F', null),
    ('lv2', '28', 'D', null),
    ('lv2', '29', 'C', null),
    ('lv2', '30', 'X', null),
    ('lv3', '31', 'r', null),
    ('lv3', '32', 'A', null),
    ('lv3', '33', 'f', null),
    ('lv3', '34', 'B', null),
    ('lv3', '35', 'r', null),
    ('lv3', '36', 'C', null),
    ('lv4', '37', 'r', null),
    ('lv4', '38', 'f', null),
    ('lv4', '39', 'f', null),
    ('lv5', '40', 'B', null),
    ('lv5', '41', 'B', null),
    ('lv5', '42', 'C', null),
    ('lv5', '43', 'A', null),
    ('lv5', '44', 'B', null),
    ('lv5', '45', 'C', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'dtz-b1' and t.slug = 'modell-07'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;

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
    ('lv3', '31', 'Viele Mieter sind unzufrieden.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 0),
    ('lv3', '32', 'Die Hausverwaltung', '[{"key": "A", "text": "möchte die Mülltonnen nicht mehr in den Hof stellen."}, {"key": "B", "text": "möchte, dass die Mieter weniger Müll wegwerfen."}, {"key": "C", "text": "möchte weitere Mülltonnen besorgen."}]'::jsonb, 1, null::jsonb, 1),
    ('lv3', '33', 'Es ist wichtig, dass Eltern aller Schüler zum Elternabend kommen.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 2),
    ('lv3', '34', 'Wenn Eltern nicht kommen können,', '[{"key": "A", "text": "sollen sie den Klassenlehrer vor dem Elternabend anrufen."}, {"key": "B", "text": "müssen sie akzeptieren, was an diesem Abend besprochen wurde."}, {"key": "C", "text": "können ihre Kinder nicht an der Klassenfahrt teilnehmen."}]'::jsonb, 1, null::jsonb, 3),
    ('lv3', '35', 'Durch diese Pressemitteilung will die GEZ die Verbraucher warnen.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 4),
    ('lv3', '36', 'Die GEZ möchte, dass die Kunden', '[{"key": "A", "text": "weniger bezahlen."}, {"key": "B", "text": "die GEZ über bestimmte Anrufe informieren."}, {"key": "C", "text": "ihre Bankverbindung angeben."}]'::jsonb, 1, null::jsonb, 5),
    ('lv4', '37', 'Für das Telefonbanking muss der Kunde außer den Telefonkosten nichts bezahlen.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 0),
    ('lv4', '38', 'Nicht jede Überweisung ist mit dem Telefonbanking möglich.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 1),
    ('lv4', '39', 'Der Kunde bekommt jeden Monat Vordrucke und Formulare zugeschickt.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 2),
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
    ('hv4', '18', 'F', null),
    ('hv4', '19', 'A', null),
    ('hv4', '20', 'C', null),
    ('lv1', '21', 'A', null),
    ('lv1', '22', 'B', null),
    ('lv1', '23', 'A', null),
    ('lv1', '24', 'C', null),
    ('lv1', '25', 'B', null),
    ('lv2', '26', 'C', null),
    ('lv2', '27', 'H', null),
    ('lv2', '28', 'E', null),
    ('lv2', '29', 'X', null),
    ('lv2', '30', 'D', null),
    ('lv3', '31', 'r', null),
    ('lv3', '32', 'C', null),
    ('lv3', '33', 'r', null),
    ('lv3', '34', 'B', null),
    ('lv3', '35', 'r', null),
    ('lv3', '36', 'B', null),
    ('lv4', '37', 'r', null),
    ('lv4', '38', 'r', null),
    ('lv4', '39', 'f', null),
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
    ('lv3', '31', 'Am 24. April kann man in der Peter Petersen Grundschule günstig Sachen kaufen.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 0),
    ('lv3', '32', 'Die Schulleitung möchte,', '[{"key": "A", "text": "dass die Eltern etwas zu essen und zu trinken mitbringen."}, {"key": "B", "text": "dass die Eltern eigene Tische mitbringen."}, {"key": "C", "text": "dass die Eltern eine kleine Gebühr bezahlen, wenn sie etwas verkaufen."}]'::jsonb, 1, null::jsonb, 1),
    ('lv3', '33', 'Im Haus werden alle Gasöfen ausgetauscht. Die Firma Bauer kommt in den nächsten Tagen vorbei.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 2),
    ('lv3', '34', 'Die Kosten für Überprüfung und Reinigung', '[{"key": "A", "text": "zahlt der Vermieter."}, {"key": "B", "text": "muss der Mieter bezahlen."}, {"key": "C", "text": "sind dieses Jahr 20 Prozent geringer."}]'::jsonb, 1, null::jsonb, 3),
    ('lv3', '35', 'Die Kurse kann man auch besuchen, wenn man schon eine Arbeit hat.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 4),
    ('lv3', '36', 'Wenn man an den Kursen teilnehmen möchte,', '[{"key": "A", "text": "muss man gleichzeitig einen Integrationskurs machen"}, {"key": "B", "text": "muss man gute Deutschkenntnisse (Niveau B1) haben."}, {"key": "C", "text": "kann man seine Kinder zum Unterricht mitnehmen."}]'::jsonb, 1, null::jsonb, 5),
    ('lv4', '37', 'Wenn ein Teilnehmer seine Anmeldung zurücknehmen möchte, muss er immer mindestens zehn Euro bezahlen.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 0),
    ('lv4', '38', 'Man kann sich nicht mehr ummelden, wenn ein Kurs angefangen hat.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 1),
    ('lv4', '39', 'Die VHS stellt für ihre Kurse automatisch Teilnahmebescheinigungen aus.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 2),
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
    ('hv4', '18', 'F', null),
    ('hv4', '19', 'C', null),
    ('hv4', '20', 'D', null),
    ('lv1', '21', 'B', null),
    ('lv1', '22', 'A', null),
    ('lv1', '23', 'B', null),
    ('lv1', '24', 'C', null),
    ('lv1', '25', 'A', null),
    ('lv2', '26', 'C', null),
    ('lv2', '27', 'B', null),
    ('lv2', '28', 'H', null),
    ('lv2', '29', 'X', null),
    ('lv2', '30', 'G', null),
    ('lv3', '31', 'r', null),
    ('lv3', '32', 'C', null),
    ('lv3', '33', 'f', null),
    ('lv3', '34', 'B', null),
    ('lv3', '35', 'r', null),
    ('lv3', '36', 'B', null),
    ('lv4', '37', 'f', null),
    ('lv4', '38', 'r', null),
    ('lv4', '39', 'f', null),
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
    ('lv3', '31', 'Familie Kowalski hat im letzten Jahr zu viel an die Mainstrom AG gezahlt.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 0),
    ('lv3', '32', 'Familie Kowalski kann Geld sparen,', '[{"key": "A", "text": "wenn sie monatlich 180 € überweist."}, {"key": "B", "text": "wenn sie bis Ende des Jahres den Energieanbieter nicht wechselt."}, {"key": "C", "text": "wenn sie sich bis Ende des Jahres für den Tarif SuperSpar entscheidet."}]'::jsonb, 1, null::jsonb, 1),
    ('lv3', '33', 'Die Schule sucht Kinder für die Hausaufgabenbetreuung.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 2),
    ('lv3', '34', 'Die Hausaufgabenbetreuung', '[{"key": "A", "text": "gibt es täglich."}, {"key": "B", "text": "kostet 8,00 € pro Stunde."}, {"key": "C", "text": "wird auf einer Veranstaltung der Schule genauer vorgestellt."}]'::jsonb, 1, null::jsonb, 3),
    ('lv3', '35', 'Beim Projekt Mixopolis haben Jugendliche die Möglichkeit, sich im Internet gegenseitig von ihren Erfahrungen und Problemen zu berichten.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 4),
    ('lv3', '36', 'Auf der Internet-Seite Mixopolis können Jugendliche', '[{"key": "A", "text": "kostenlos Filme und Software bekommen."}, {"key": "B", "text": "sich beraten lassen."}, {"key": "C", "text": "Sachen kaufen und verkaufen."}]'::jsonb, 1, null::jsonb, 5),
    ('lv4', '37', 'Die Teilzahlungen sind nur zinsfrei, wenn Sie Ihre Zahnarztrechnung innerhalb von 30 Tagen bezahlen.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 0),
    ('lv4', '38', 'Wenn Sie länger als sechs Monate bezahlen, entstehen Ihnen neben den Zinsen noch weitere Kosten.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 1),
    ('lv4', '39', 'Sie können selbst festlegen, an welchem Tag im Monat Sie die Raten zahlen möchten.', '[{"key": "r", "text": "Richtig"}, {"key": "f", "text": "Falsch"}]'::jsonb, 1, null::jsonb, 2),
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
    ('hv4', '18', 'B', null),
    ('hv4', '19', 'D', null),
    ('hv4', '20', 'A', null),
    ('lv1', '21', 'A', null),
    ('lv1', '22', 'B', null),
    ('lv1', '23', 'A', null),
    ('lv1', '24', 'C', null),
    ('lv1', '25', 'A', null),
    ('lv2', '26', 'X', null),
    ('lv2', '27', 'B', null),
    ('lv2', '28', 'F', null),
    ('lv2', '29', 'E', null),
    ('lv2', '30', 'D', null),
    ('lv3', '31', 'r', null),
    ('lv3', '32', 'C', null),
    ('lv3', '33', 'f', null),
    ('lv3', '34', 'C', null),
    ('lv3', '35', 'r', null),
    ('lv3', '36', 'B', null),
    ('lv4', '37', 'f', null),
    ('lv4', '38', 'r', null),
    ('lv4', '39', 'r', null),
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
