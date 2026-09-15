-- جزء 2 من 4 — نماذج modell-04–modell-07
-- مولّد من supabase/seed/dtz-b1.sql بـtools/split_seed.sh — لا تعدّله بالإيد
-- آمن للإعادة: شغّله مرتين ما بيغيّر شي.

begin;

-- مولّد من content/dtz/b1 بـtools/export_sql.py — لا تعدّله بالإيد

insert into levels (id, title, sort, published, provider, stufe) values ('dtz-b1', 'Deutsch-Test für Zuwanderer B1', 0, true, 'DTZ', 'B1')
on conflict (id) do update set title = excluded.title,
  provider = coalesce(levels.provider, excluded.provider),
  stufe    = coalesce(levels.stufe,    excluded.stufe);

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
    ('hv3', '10', 'Die Personen sind Nachbarn.', null::jsonb, 1, null::jsonb, 0),
    ('hv3', '11', 'Herr Brunner ...', '[{"key": "A", "text": "findet Urlaub auf dem Bauernhof langweilig."}, {"key": "B", "text": "möchte auch Urlaub auf dem Bauernhof machen."}, {"key": "C", "text": "will seiner Schwester die Adresse vom Bauernhof geben."}]'::jsonb, 1, null::jsonb, 1),
    ('hv3', '12', 'Herr Huber sucht Arbeit.', null::jsonb, 1, null::jsonb, 2),
    ('hv3', '13', 'Der Computerkurs', '[{"key": "A", "text": "dauert eine Woche."}, {"key": "B", "text": "ist für Herrn Huber nicht interessant."}, {"key": "C", "text": "wird vom Arbeitsmarktservice bezahlt."}]'::jsonb, 1, null::jsonb, 3),
    ('hv3', '14', 'Die Frau und der Mann sind Arbeitskollegen.', null::jsonb, 1, null::jsonb, 4),
    ('hv3', '15', 'Claudia', '[{"key": "A", "text": "ist in Chemie nicht so gut."}, {"key": "B", "text": "soll an einem Wettbewerb teilnehmen."}, {"key": "C", "text": "soll nach Salzburg fahren."}]'::jsonb, 1, null::jsonb, 5),
    ('hv3', '16', 'Die Gastherme von Frau Schuster ist kaputt.', null::jsonb, 1, null::jsonb, 6),
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
    ('lv3', '31', 'Herr Berger möchte Ruhe in der Nacht.', null::jsonb, 1, null::jsonb, 0),
    ('lv3', '32', 'Die Arbeiter ...', '[{"key": "A", "text": "arbeiten auch jetzt noch bis 21 Uhr."}, {"key": "B", "text": "arbeiten am Morgen nie vor 6 Uhr."}, {"key": "C", "text": "arbeiten manchmal auch am Wochenende."}]'::jsonb, 1, null::jsonb, 1),
    ('lv3', '33', 'Frau Baumgartner hört bald auf zu arbeiten.', null::jsonb, 1, null::jsonb, 2),
    ('lv3', '34', 'Die Eltern sollen ...', '[{"key": "A", "text": "Frau Baumgartner ein Geschenk mitbringen."}, {"key": "B", "text": "kommenden Samstag Getränke mitbringen."}, {"key": "C", "text": "sagen, ob Sie kommenden Samstag Zeit haben."}]'::jsonb, 1, null::jsonb, 3),
    ('lv3', '35', 'Herr Sanchez hat seine Versicherung gekündigt.', null::jsonb, 1, null::jsonb, 4),
    ('lv3', '36', 'Die Versicherung bietet Herrn Sanchez an, dass er ...', '[{"key": "A", "text": "ein halbes Jahr gratis versichert bleibt."}, {"key": "B", "text": "eine neue Versicherung bekommt."}, {"key": "C", "text": "einen besseren Service bekommt."}]'::jsonb, 1, null::jsonb, 5),
    ('lv4', '37', 'Auch Schwangere dürfen die Tabletten nehmen.', null::jsonb, 1, null::jsonb, 0),
    ('lv4', '38', 'Ein 13-jähriges Kind darf eine Tablette pro Tag nehmen.', null::jsonb, 1, null::jsonb, 1),
    ('lv4', '39', 'Man soll die Tabletten vor dem Essen nehmen.', null::jsonb, 1, null::jsonb, 2),
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
    ('hv3', '10', 'richtig', null),
    ('hv3', '11', 'C', null),
    ('hv3', '12', 'richtig', null),
    ('hv3', '13', 'C', null),
    ('hv3', '14', 'falsch', null),
    ('hv3', '15', 'B', null),
    ('hv3', '16', 'falsch', null),
    ('hv3', '17', 'C', null),
    ('hv4', '18', 'f', null),
    ('hv4', '19', 'e', null),
    ('hv4', '20', 'c', null),
    ('lv1', '21', 'B', null),
    ('lv1', '22', 'C', null),
    ('lv1', '23', 'C', null),
    ('lv1', '24', 'B', null),
    ('lv1', '25', 'B', null),
    ('lv2', '26', 'h', null),
    ('lv2', '27', 'a', null),
    ('lv2', '28', 'x', null),
    ('lv2', '29', 'e', null),
    ('lv2', '30', 'c', null),
    ('lv3', '31', 'richtig', null),
    ('lv3', '32', 'C', null),
    ('lv3', '33', 'richtig', null),
    ('lv3', '34', 'C', null),
    ('lv3', '35', 'richtig', null),
    ('lv3', '36', 'A', null),
    ('lv4', '37', 'falsch', null),
    ('lv4', '38', 'falsch', null),
    ('lv4', '39', 'falsch', null),
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
    ('hv3', '10', 'Herr Hamann spricht mit seiner Chefin.', null::jsonb, 1, null::jsonb, 0),
    ('hv3', '11', 'Was soll Herr Hamann am Wochenende tun?', '[{"key": "A", "text": "Er soll am Wochenende arbeiten."}, {"key": "B", "text": "Er soll einen Kollegen anrufen."}, {"key": "C", "text": "Er soll zur Firma Müller gehen."}]'::jsonb, 1, null::jsonb, 1),
    ('hv3', '12', 'Herr Förster und Frau Knauer sind Freunde.', null::jsonb, 1, null::jsonb, 2),
    ('hv3', '13', 'Was soll Herr Förster machen?', '[{"key": "A", "text": "Den Briefkasten leeren."}, {"key": "B", "text": "Die Blumen gießen."}, {"key": "C", "text": "Die Katze versorgen."}]'::jsonb, 1, null::jsonb, 3),
    ('hv3', '14', 'Melanie und Leo lernen zusammen Russisch.', null::jsonb, 1, null::jsonb, 4),
    ('hv3', '15', 'Was soll Melanie mitbringen?', '[{"key": "A", "text": "Musik-CDs."}, {"key": "B", "text": "Eine DVD."}, {"key": "C", "text": "Bilder."}]'::jsonb, 1, null::jsonb, 5),
    ('hv3', '16', 'Margit ist im Reisebüro.', null::jsonb, 1, null::jsonb, 6),
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
    ('lv3', '31', 'Die Stadt Nordhausen verkauft billige Fahrkarten für Familien.', null::jsonb, 1, null::jsonb, 0),
    ('lv3', '32', 'Die Fahrkarten kann man', '[{"key": "A", "text": "sich schicken lassen."}, {"key": "B", "text": "online bestellen."}, {"key": "C", "text": "im Rathaus bekommen."}]'::jsonb, 1, null::jsonb, 1),
    ('lv3', '33', 'Das Leseprogramm ist für Eltern und Kindern.', null::jsonb, 1, null::jsonb, 2),
    ('lv3', '34', 'Die Eltern sollen bei Interesse', '[{"key": "A", "text": "ihr Kind selbst im Internet anmelden."}, {"key": "B", "text": "eine Erklärung unterschreiben."}, {"key": "C", "text": "der Lehrkraft ein Passwort mitteilen."}]'::jsonb, 1, null::jsonb, 3),
    ('lv3', '35', 'Die Versicherung bezahlt einen Teil der Kosten.', null::jsonb, 1, null::jsonb, 4),
    ('lv3', '36', 'Bevor Frau Kim behandelt wird,', '[{"key": "A", "text": "muss sie diesen Brief Ihrem Zahnarzt geben."}, {"key": "B", "text": "überweist die Versicherung das Geld an Frau Kim."}, {"key": "C", "text": "muss Frau Kim Geld überweisen."}]'::jsonb, 1, null::jsonb, 5),
    ('lv4', '37', 'Man kann auf den Anrufbeantworter sprechen, wenn Sie telefonieren.', null::jsonb, 1, null::jsonb, 0),
    ('lv4', '38', 'Sie können die Nachrichten nur zu Hause anhören.', null::jsonb, 1, null::jsonb, 1),
    ('lv4', '39', 'Sie bekommen eine SMS über eine neue Nachricht, wenn Sie eine Gebühr bezahlt haben.', null::jsonb, 1, null::jsonb, 2),
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
    ('hv3', '10', 'richtig', null),
    ('hv3', '11', 'A', null),
    ('hv3', '12', 'falsch', null),
    ('hv3', '13', 'A', null),
    ('hv3', '14', 'richtig', null),
    ('hv3', '15', 'B', null),
    ('hv3', '16', 'falsch', null),
    ('hv3', '17', 'C', null),
    ('hv4', '18', 'c', null),
    ('hv4', '19', 'e', null),
    ('hv4', '20', 'a', null),
    ('lv1', '21', 'A', null),
    ('lv1', '22', 'C', null),
    ('lv1', '23', 'B', null),
    ('lv1', '24', 'A', null),
    ('lv1', '25', 'B', null),
    ('lv2', '26', 'c', null),
    ('lv2', '27', 'h', null),
    ('lv2', '28', 'x', null),
    ('lv2', '29', 'd', null),
    ('lv2', '30', 'a', null),
    ('lv3', '31', 'falsch', null),
    ('lv3', '32', 'C', null),
    ('lv3', '33', 'falsch', null),
    ('lv3', '34', 'B', null),
    ('lv3', '35', 'richtig', null),
    ('lv3', '36', 'A', null),
    ('lv4', '37', 'richtig', null),
    ('lv4', '38', 'falsch', null),
    ('lv4', '39', 'falsch', null),
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
    ('hv3', '10', 'Sonja und ihr Mann haben eine neue Wohnung gemietet.', null::jsonb, 1, null::jsonb, 0),
    ('hv3', '11', 'Die neue Wohnung', '[{"key": "A", "text": "ist teurer als die alte, hat aber mehr Quadratmeter."}, {"key": "B", "text": "hat keine Küche."}, {"key": "C", "text": "ist auf dem Land."}]'::jsonb, 1, null::jsonb, 1),
    ('hv3', '12', 'Frau Schmidt möchte ein Konto eröffnen.', null::jsonb, 1, null::jsonb, 2),
    ('hv3', '13', 'Was fragt sie den Bankangestellten?', '[{"key": "A", "text": "Ob es in der Müllerstraße auch eine Bank gibt."}, {"key": "B", "text": "Ob Bankgeschäfte im Internet sicher sind."}, {"key": "C", "text": "Ob sie für Überweisungsformulare etwas bezahlen muss."}]'::jsonb, 1, null::jsonb, 3),
    ('hv3', '14', 'Anette und Claudia planen ein Hoffest.', null::jsonb, 1, null::jsonb, 4),
    ('hv3', '15', 'Was sind die Pläne der Hausbewohner?', '[{"key": "A", "text": "Sie wollen den Hinterhof schöner machen."}, {"key": "B", "text": "Sie wollen jeden Monat feiern."}, {"key": "C", "text": "Sie wollen auch die neuen Nachbarn einladen."}]'::jsonb, 1, null::jsonb, 5),
    ('hv3', '16', 'Frau Klein und Frau Maier sprechen über einen neuen Mitarbeiter.', null::jsonb, 1, null::jsonb, 6),
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
    ('lv3', '31', 'Die Polizei Hessens möchte, dass mehr Ausländer bei ihr arbeiten.', null::jsonb, 1, null::jsonb, 0),
    ('lv3', '32', 'Wenn man bei der Polizei arbeiten will,', '[{"key": "A", "text": "muss man keinen deutschen Pass haben."}, {"key": "B", "text": "muss man seit 1994 in Deutschland leben."}, {"key": "C", "text": "bekommt man nächstes Jahr 20 Prozent mehr Gehalt."}]'::jsonb, 1, null::jsonb, 1),
    ('lv3', '33', 'Die Schule plant ein Fest, weil die neue Cafeteria fertig ist.', null::jsonb, 1, null::jsonb, 2),
    ('lv3', '34', 'Die Festbesucher sollen', '[{"key": "A", "text": "T-Shirts der Schule tragen."}, {"key": "B", "text": "eigenes Geschirr mitbringen."}, {"key": "C", "text": "auf dem Schulhof Theater spielen."}]'::jsonb, 1, null::jsonb, 3),
    ('lv3', '35', 'Der Fahrradkeller ist zu voll.', null::jsonb, 1, null::jsonb, 4),
    ('lv3', '36', 'Nach dem 1. August', '[{"key": "A", "text": "dürfen keine Räder mehr in den Keller gestellt werden."}, {"key": "B", "text": "müssen die Mieter etwas zahlen, wenn sie ihr Fahrrad in den Keller stellen."}, {"key": "C", "text": "gibt es im Keller nur noch Platz für ein Fahrrad für jeden Mieter."}]'::jsonb, 1, null::jsonb, 5),
    ('lv4', '37', 'Normalerweise müssen Sie Ihr Handy mindestens drei Monate vor Ende des Vertrags kündigen.', null::jsonb, 1, null::jsonb, 0),
    ('lv4', '38', 'Sie müssen bei einer Kündigung immer auch Gründe für die Kündigung angeben.', null::jsonb, 1, null::jsonb, 1),
    ('lv4', '39', 'Die Mitnahme der alten Handynummer ist kostenlos.', null::jsonb, 1, null::jsonb, 2),
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
    ('hv3', '10', 'falsch', null),
    ('hv3', '11', 'A', null),
    ('hv3', '12', 'falsch', null),
    ('hv3', '13', 'C', null),
    ('hv3', '14', 'falsch', null),
    ('hv3', '15', 'A', null),
    ('hv3', '16', 'richtig', null),
    ('hv3', '17', 'C', null),
    ('hv4', '18', 'f', null),
    ('hv4', '19', 'a', null),
    ('hv4', '20', 'c', null),
    ('lv1', '21', 'C', null),
    ('lv1', '22', 'B', null),
    ('lv1', '23', 'C', null),
    ('lv1', '24', 'B', null),
    ('lv1', '25', 'B', null),
    ('lv2', '26', 'e', null),
    ('lv2', '27', 'f', null),
    ('lv2', '28', 'd', null),
    ('lv2', '29', 'c', null),
    ('lv2', '30', 'x', null),
    ('lv3', '31', 'richtig', null),
    ('lv3', '32', 'A', null),
    ('lv3', '33', 'falsch', null),
    ('lv3', '34', 'B', null),
    ('lv3', '35', 'richtig', null),
    ('lv3', '36', 'C', null),
    ('lv4', '37', 'richtig', null),
    ('lv4', '38', 'falsch', null),
    ('lv4', '39', 'falsch', null),
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


commit;
