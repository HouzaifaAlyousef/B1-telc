-- مولّد من content/oesd/a1 بـtools/export_sql.py — لا تعدّله بالإيد
begin;

insert into levels (id, title, sort, published, provider, stufe) values ('oesd-a1', 'ÖSD Zertifikat A1', 0, true, 'ÖSD', 'A1')
on conflict (id) do update set title = excluded.title,
  provider = coalesce(levels.provider, excluded.provider),
  stufe    = coalesce(levels.stufe,    excluded.stufe);

-- ================= modell-01 · MODELLSATZ =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('oesd-a1', 'modell-01', 'MODELLSATZ', '29 Aufgaben · 55 Minuten',
        '[{"id": "block-lesen", "parts": ["lv1", "lv2", "lv3"], "title": "Lesen", "minutes": 25, "hint": "Aufgaben 1–16", "maxPoints": 30, "availablePoints": 30, "missing": 0}, {"id": "block-hoeren", "parts": ["hv1", "hv2", "hv3"], "title": "Hören", "minutes": 10, "hint": "Aufgaben 17–27", "maxPoints": 30, "availablePoints": 30, "missing": 0}, {"id": "block-schreiben", "parts": ["s1", "s2"], "title": "Schreiben", "minutes": 20, "hint": "Aufgaben 28–29", "maxPoints": 20, "availablePoints": 20, "missing": 0}]'::jsonb, 29, true, 1)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('lv1', 'Lesen', 'Lesen, Teil 1', 10, 'Finden Sie zu jeder Situation auf Blatt 1 (Situation A–E) die passende Anzeige auf Blatt 2 (Anzeige Nr. 1–6). Eine Anzeige ist zu viel.', 'matching', '{"bank": [{"key": "1", "text": "Sekretärin/Sekretär gesucht: Internationale Firma sucht Sekretärin/Sekretär mit Berufserfahrung (Vollzeit). Aufgaben: telefonische Kundenbetreuung, organisatorische Tätigkeiten. Bewerbungen an: info@personalvermittlung-holzer.de"}, {"key": "2", "text": "Fitnesscenter Olymp: Unser Angebot: 120 Geräte für Kraft- und Fitnesstraining, Rückengymnastik, Beratung durch geprüfte Trainer. Burggasse 10, 1070 Wien, täglich 10–22 Uhr"}, {"key": "3", "text": "Buchhandlung Steiner: Bücher zum halben Preis: Richtig telefonieren – Gesprächstraining für SekretärInnen; Gesund essen im Büro: 50 Kochideen; 100 Jahre Sportfotografie; Diverse Kinderbücher. Angebot gültig bis Ende Mai"}, {"key": "4", "text": "Die ganze Welt um wenig Geld! Günstige Auslandsanrufe ab 1,9 Cent/Minute. weltweitanrufen.de bietet Ihnen die besten Tarife für Anrufe in Mobilnetze und ins ausländische Festnetz. www.weltweitanrufen.de"}, {"key": "5", "text": "SIE SUCHEN JEMANDEN, der Ihre Wäsche wäscht und bügelt? SIE BRAUCHEN JEMANDEN, der beim Saubermachen oder bei der Gartenarbeit hilft? Kein Problem! RUFEN SIE MICH AN: Petra Maier, Tel. 0676 55 68 987"}, {"key": "6", "text": "Feinkost Klement: In unserem Delikatessengeschäft bieten wir Ihnen: hausgemachte Salate, Brötchen mit Ei- und Curryaufstrich, Schinken und Käse aus der Region. Petersgasse 8, 4051 Basel, Mo–Sa: 9–18 Uhr"}], "bankTitle": "Anzeigen", "bankImage": "img/m01-lv1.png", "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 2}'::jsonb, 0),
    ('lv2', 'Lesen', 'Lesen, Teil 2', 10, 'Sie lesen drei Anzeigen. Dazu gibt es je 2 Fragen. Antworten Sie mit JA oder NEIN.', 'mc', '{"passages": [{"paragraphs": [{"t": "Schönes-Wochenende-Ticket", "b": true}, {"t": "• gültig ab Samstag 0 Uhr bis Montag 3 Uhr für Reisen in Deutschland", "b": false}, {"t": "• für Gruppen bis zu fünf Personen und für Einzelreisende", "b": false}, {"t": "Preis: 39 Euro im Internet, 41 Euro im Reisezentrum an Ihrem Bahnhof", "b": false}, {"t": "www.bahn.de/angebote", "b": false}]}], "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 1.67}'::jsonb, 1),
    ('lv3', 'Lesen', 'Lesen, Teil 3', 5, 'Sie lesen hier 5 kurze Texte (Text A–E). Zu jedem Text gibt es ein Bild (Bild 1–6). Welches Bild passt zu welchem Text? Ein Bild ist zu viel.', 'matching', '{"bank": [{"key": "1", "text": "Bild 1"}, {"key": "2", "text": "Bild 2"}, {"key": "3", "text": "Bild 3"}, {"key": "4", "text": "Bild 4"}, {"key": "5", "text": "Bild 5"}, {"key": "6", "text": "Bild 6"}], "bankTitle": "Bilder", "bankImage": "img/m01-lv3.png", "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 2}'::jsonb, 2),
    ('hv1', 'Hören', 'Hören, Teil 1', 4, 'Sie hören fünf verschiedene Texte zu den Fotos. Welcher Text passt zu welchem Foto? Ein Bild ist zu viel.', 'matching', '{"bank": [{"key": "A", "text": "Foto A"}, {"key": "B", "text": "Foto B"}, {"key": "C", "text": "Foto C"}, {"key": "D", "text": "Foto D"}, {"key": "E", "text": "Foto E"}, {"key": "F", "text": "Foto F"}], "bankTitle": "Fotos", "bankImage": "img/m01-hv1.png", "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 2}'::jsonb, 3),
    ('hv2', 'Hören', 'Hören, Teil 2 (Telefonnotiz)', 3, 'Sie hören eine Nachricht. Hören Sie gut zu und schreiben Sie die wichtigsten Informationen auf das Notizblatt. Sie hören den Text zwei Mal.', 'writing', '{"passages": [{"paragraphs": [{"t": "Notizen: Auto ansehen", "b": true}, {"t": "Was: Auto ansehen (Beispiel)", "b": false}, {"t": "Wann: am ............................, am Nachmittag, ............................ Mai, um ............................ Uhr", "b": false}, {"t": "Wo: in der ............................gasse 12", "b": false}, {"t": "Telefonnummer: 0664 / ............................", "b": false}]}], "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 10}'::jsonb, 4),
    ('hv3', 'Hören', 'Hören, Teil 3', 3, 'Sie hören jetzt 5 Personen, die befragt werden: „Wo gefällt es Ihnen am besten?“ Kreuzen Sie die richtige Antwort an. Pro Person gibt es nur eine Antwort.', 'mc', '{"maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 2}'::jsonb, 5),
    ('s1', 'Schreiben', 'Schreiben, Teil 1 (Formular)', 10, 'Schreiben Sie die fünf fehlenden Informationen in das Formular.', 'writing', '{"passages": [{"paragraphs": [{"t": "Die Tochter von Ihrem Nachbarn, Emina Kostić, 7 Jahre alt, möchte im Sportverein Fußball spielen. Sie hat nur am Mittwochnachmittag Zeit. Sie möchte sofort anfangen. Ihre Eltern wollen den Mitgliedsbeitrag jeden Monat überweisen.", "b": false}, {"t": "Anmeldung: Sportverein", "b": true}, {"t": "Name, Vorname: Kostić, Emina", "b": false}, {"t": "Straße/Hausnummer: Waldstraße 7", "b": false}, {"t": "Wohnort: 87656 Germaringen", "b": false}, {"t": "Telefon: 0 83 41/55 74 32", "b": false}, {"t": "Sportart: (1) ............................", "b": false}, {"t": "Alter: (2) ............................", "b": false}, {"t": "Wochentag: (3) ............................", "b": false}, {"t": "Beginn: (4) ............................", "b": false}, {"t": "Zahlung: (5) bar / Überweisung", "b": false}, {"t": "Unterschrift: Dragomir Kostić", "b": false}]}], "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 10}'::jsonb, 6),
    ('s2', 'Schreiben', 'Schreiben, Teil 2 (E-Mail)', 10, 'Ihre Freundin Rafaela wohnt in Berlin und hat Sie eingeladen. Sie möchten bald zu ihr fahren und bekommen folgendes Mail von ihr. Antworten Sie Rafaela. Schreiben Sie circa 30 Wörter. Beantworten Sie alle Fragen und schreiben Sie am Ende einen Gruß.', 'writing', '{"passages": [{"paragraphs": [{"t": "Hallo!", "b": true}, {"t": "Du schreibst, du möchtest bald zu mir nach Berlin kommen. Ich freue mich schon sehr! Du kannst auch gerne jemanden von deiner Familie oder Freunde mitbringen.", "b": false}, {"t": "Schreib mir bitte: An welchem Tag und um wie viel Uhr kommst du? Wie lange möchtest du bleiben? Wen bringst du mit?", "b": false}, {"t": "Liebe Grüße", "b": false}, {"t": "Rafaela", "b": false}]}], "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 10}'::jsonb, 7)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'oesd-a1' and t.slug = 'modell-01'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('lv1', '1', 'Situation A: Sie haben viele Freunde in anderen Ländern und möchten billig mit ihnen telefonieren.', null::jsonb, 2, null::jsonb, 0),
    ('lv1', '2', 'Situation B: Sie sollen für ein Fest etwas zum Essen mitbringen. Sie haben keine Zeit zum Kochen.', null::jsonb, 2, null::jsonb, 1),
    ('lv1', '3', 'Situation C: Sie suchen einen Job. Sie wollen in einem Büro arbeiten.', null::jsonb, 2, null::jsonb, 2),
    ('lv1', '4', 'Situation D: Sie haben eine große Wohnung. Sie brauchen Hilfe bei der Hausarbeit.', null::jsonb, 2, null::jsonb, 3),
    ('lv1', '5', 'Situation E: Sie arbeiten viel am Computer. In Ihrer Freizeit möchten Sie Sport machen.', null::jsonb, 2, null::jsonb, 4),
    ('lv2', '6', 'Kann man am Freitagabend mit dem Ticket fahren?', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 0),
    ('lv2', '7', 'Kostet das Ticket beim Kauf am Bahnhof mehr? Text: **Lesen im Park** Im Sommer gibt es in Grazer Parks wieder Bücherkisten mit vielen Kinderbüchern – zum Lesen vor Ort oder zum Mit-nach-Hause-Nehmen. Weitere Aktivitäten: Bastel- und Malgruppen; Papier und Stifte haben wir für dich. www.lesen-im-park.at Aufgaben:', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 1),
    ('lv2', '8', 'Darf man die Bücher nur im Park lesen?', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 2),
    ('lv2', '9', 'Müssen die Kinder Papier und Stifte mitbringen? Text: **3-Zimmer-Wohnung** Neu renovierte Wohnung (63 m²) ab 1. August zu vermieten Gesamtmiete: CHF 1.200,– Sie haben noch Fragen? Schreiben Sie eine E-Mail an: info@immobilien-heiss.ch Termine zur Wohnungsbesichtigung: 15. Juli, 11.00 Uhr | 18. Juli, 15.00 Uhr Aufgaben:', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 3),
    ('lv2', '10', 'Kann man telefonisch Informationen bekommen?', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 4),
    ('lv2', '11', 'Kann man die Wohnung am Vormittag sehen?', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 5),
    ('lv3', '12', 'Text A: Liebe Besucherinnen und Besucher! Im Krankenhaus ist das Telefonieren mit Handy verboten. Bitte schalten Sie Ihr Handy während Ihres Besuchs bei uns aus.', null::jsonb, 2, null::jsonb, 0),
    ('lv3', '13', 'Text B: Gasthaus Neuwirth: leichte regionale Küche, frische Salate vom Buffet, günstige Mittagsmenüs. Mo–Sa: 9–22 Uhr | Sonntag Ruhetag', null::jsonb, 2, null::jsonb, 1),
    ('lv3', '14', 'Text C: Liebe Kolleginnen und Kollegen! In den Büroräumen ist das Rauchen verboten. Bitte nützen Sie die Raucherzonen im Erdgeschoss.', null::jsonb, 2, null::jsonb, 2),
    ('lv3', '15', 'Text D: Liebe Hundebesitzer! Wir bitten Sie, im Interesse aller Parkbenützer Ihren Hund an die Leine zu nehmen.', null::jsonb, 2, null::jsonb, 3),
    ('lv3', '16', 'Text E: Der Flughafen-Bus bringt Sie schnell und bequem ins Stadtzentrum. Nützen Sie das Angebot! Fahrplanauskünfte am Flughafen Graz: +43 (316) 2902 172', null::jsonb, 2, null::jsonb, 4),
    ('hv1', '17', 'Text 1', null::jsonb, 2, null::jsonb, 0),
    ('hv1', '18', 'Text 2', null::jsonb, 2, null::jsonb, 1),
    ('hv1', '19', 'Text 3', null::jsonb, 2, null::jsonb, 2),
    ('hv1', '20', 'Text 4', null::jsonb, 2, null::jsonb, 3),
    ('hv1', '21', 'Text 5', null::jsonb, 2, null::jsonb, 4),
    ('hv2', '22', 'Füllen Sie die wichtigsten Informationen in die Notizen ein:', null::jsonb, 0, '{"points": ["Wann (Wochentag): Dienstag / Di.", "Wann (Datum): 12. Mai", "Wann (Uhrzeit): 14 Uhr / 2 Uhr nachmittags", "Wo (Straßenname): Bernergasse 12", "Telefonnummer: 0664 / 2582641"]}'::jsonb, 0),
    ('hv3', '23', 'Person 1: Wo gefällt es Ihnen am besten?', '[{"key": "A", "text": "Afrika"}, {"key": "B", "text": "Amerika"}, {"key": "C", "text": "Asien"}, {"key": "D", "text": "Europa"}]'::jsonb, 2, null::jsonb, 0),
    ('hv3', '24', 'Person 2: Wo gefällt es Ihnen am besten?', '[{"key": "A", "text": "Afrika"}, {"key": "B", "text": "Amerika"}, {"key": "C", "text": "Asien"}, {"key": "D", "text": "Europa"}]'::jsonb, 2, null::jsonb, 1),
    ('hv3', '25', 'Person 3: Wo gefällt es Ihnen am besten?', '[{"key": "A", "text": "Afrika"}, {"key": "B", "text": "Amerika"}, {"key": "C", "text": "Asien"}, {"key": "D", "text": "Europa"}]'::jsonb, 2, null::jsonb, 2),
    ('hv3', '26', 'Person 4: Wo gefällt es Ihnen am besten?', '[{"key": "A", "text": "Afrika"}, {"key": "B", "text": "Amerika"}, {"key": "C", "text": "Asien"}, {"key": "D", "text": "Europa"}]'::jsonb, 2, null::jsonb, 3),
    ('hv3', '27', 'Person 5: Wo gefällt es Ihnen am besten?', '[{"key": "A", "text": "Afrika"}, {"key": "B", "text": "Amerika"}, {"key": "C", "text": "Asien"}, {"key": "D", "text": "Europa"}]'::jsonb, 2, null::jsonb, 4),
    ('s1', '28', 'Schreiben Sie die fünf fehlenden Informationen in das Formular:', null::jsonb, 0, '{"points": ["(1) Sportart: Fußball", "(2) Alter: 7 (Jahre)", "(3) Wochentag: Mittwoch / Mittwochnachmittag", "(4) Beginn: sofort", "(5) Zahlung: Überweisung"]}'::jsonb, 0),
    ('s2', '29', 'Antworten Sie Rafaela (mindestens 30 Wörter):', null::jsonb, 0, '{"minWords": 30, "points": ["An welchem Tag und um wie viel Uhr kommst du?", "Wie lange möchtest du bleiben?", "Wen bringst du mit?", "Gruß am Ende"]}'::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'oesd-a1' and t.slug = 'modell-01'
join sections s on s.test_id = t.id and s.section_id = v.section_id
on conflict (section_id, item_id) do update set text = excluded.text, options = excluded.options, points = excluded.points, meta = excluded.meta, sort = excluded.sort;

insert into item_answers (item_id, answer, explanation)
select i.id, v.answer, v.explanation
from (values
    ('lv1', '1', '4', null),
    ('lv1', '2', '6', null),
    ('lv1', '3', '1', null),
    ('lv1', '4', '5', null),
    ('lv1', '5', '2', null),
    ('lv2', '6', 'B', null),
    ('lv2', '7', 'A', null),
    ('lv2', '8', 'B', null),
    ('lv2', '9', 'B', null),
    ('lv2', '10', 'B', null),
    ('lv2', '11', 'A', null),
    ('lv3', '12', '5', null),
    ('lv3', '13', '4', null),
    ('lv3', '14', '1', null),
    ('lv3', '15', '6', null),
    ('lv3', '16', '3', null),
    ('hv1', '17', 'E', null),
    ('hv1', '18', 'C', null),
    ('hv1', '19', 'F', null),
    ('hv1', '20', 'D', null),
    ('hv1', '21', 'A', null),
    ('hv3', '23', 'C', null),
    ('hv3', '24', 'A', null),
    ('hv3', '25', 'D', null),
    ('hv3', '26', 'B', null),
    ('hv3', '27', 'A', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'oesd-a1' and t.slug = 'modell-01'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;

commit;
