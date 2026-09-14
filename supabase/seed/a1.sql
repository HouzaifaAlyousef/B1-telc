-- مولّد من content/oesd/a1 بـtools/export_sql.py — لا تعدّله بالإيد
begin;

insert into levels (id, title, sort, published, provider, stufe) values ('oesd-a1', 'ÖSD Zertifikat A1', 0, true, 'ÖSD', 'A1')
on conflict (id) do update set title = excluded.title,
  provider = coalesce(levels.provider, excluded.provider),
  stufe    = coalesce(levels.stufe,    excluded.stufe);

-- ================= modell-01 · RAFAELA =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('oesd-a1', 'modell-01', 'RAFAELA', '29 Aufgaben · 55 Minuten',
        '[{"id": "block-lesen", "parts": ["lv1", "lv2", "lv3"], "title": "Lesen", "minutes": 25, "hint": "Aufgaben 1–16", "maxPoints": 30, "availablePoints": 30, "missing": 0}, {"id": "block-hoeren", "parts": ["hv1", "hv2", "hv3"], "title": "Hören", "minutes": 10, "hint": "Aufgaben 17–27", "maxPoints": 30, "availablePoints": 30, "missing": 0}, {"id": "block-schreiben", "parts": ["s1", "s2"], "title": "Schreiben", "minutes": 20, "hint": "Aufgaben 28–29", "maxPoints": 20, "availablePoints": 20, "missing": 0}]'::jsonb, 29, true, 1)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('lv1', 'Lesen', 'Lesen, Teil 1', 10, 'Finden Sie zu jeder Situation auf Blatt 1 (Situation A–E) die passende Anzeige auf Blatt 2 (Anzeige Nr. 1–6). Eine Anzeige ist zu viel.', 'matching', '{"bank": [{"key": "1", "text": "Sekretärin/Sekretär gesucht: Internationale Firma sucht Sekretärin/Sekretär mit Berufserfahrung (Vollzeit). Aufgaben: telefonische Kundenbetreuung, organisatorische Tätigkeiten. Bewerbungen an: info@personalvermittlung-holzer.de"}, {"key": "2", "text": "Fitnesscenter Olymp: Unser Angebot: 120 Geräte für Kraft- und Fitnesstraining, Rückengymnastik, Beratung durch geprüfte Trainer. Burggasse 10, 1070 Wien, täglich 10–22 Uhr"}, {"key": "3", "text": "Buchhandlung Steiner: Bücher zum halben Preis: Richtig telefonieren – Gesprächstraining für SekretärInnen; Gesund essen im Büro: 50 Kochideen; 100 Jahre Sportfotografie; Diverse Kinderbücher. Angebot gültig bis Ende Mai"}, {"key": "4", "text": "Die ganze Welt um wenig Geld! Günstige Auslandsanrufe ab 1,9 Cent/Minute. weltweitanrufen.de bietet Ihnen die besten Tarife für Anrufe in Mobilnetze und ins ausländische Festnetz. www.weltweitanrufen.de"}, {"key": "5", "text": "SIE SUCHEN JEMANDEN, der Ihre Wäsche wäscht und bügelt? SIE BRAUCHEN JEMANDEN, der beim Saubermachen oder bei der Gartenarbeit hilft? Kein Problem! RUFEN SIE MICH AN: Petra Maier, Tel. 0676 55 68 987"}, {"key": "6", "text": "Feinkost Klement: In unserem Delikatessengeschäft bieten wir Ihnen: hausgemachte Salate, Brötchen mit Ei- und Curryaufstrich, Schinken und Käse aus der Region. Petersgasse 8, 4051 Basel, Mo–Sa: 9–18 Uhr"}], "bankTitle": "Anzeigen", "bankImage": "img/oesd-a1-m01-lv1.jpg", "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 2}'::jsonb, 0),
    ('lv2', 'Lesen', 'Lesen, Teil 2', 10, 'Sie lesen drei Anzeigen. Dazu gibt es je 2 Fragen. Antworten Sie mit JA oder NEIN.', 'mc', '{"passages": [{"paragraphs": [{"t": "Schönes-Wochenende-Ticket", "b": true}, {"t": "• gültig ab Samstag 0 Uhr bis Montag 3 Uhr für Reisen in Deutschland", "b": false}, {"t": "• für Gruppen bis zu fünf Personen und für Einzelreisende", "b": false}, {"t": "Preis: 39 Euro im Internet, 41 Euro im Reisezentrum an Ihrem Bahnhof", "b": false}, {"t": "www.bahn.de/angebote", "b": false}]}], "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 1.67}'::jsonb, 1),
    ('lv3', 'Lesen', 'Lesen, Teil 3', 5, 'Sie lesen hier 5 kurze Texte (Text A–E). Zu jedem Text gibt es ein Bild (Bild 1–6). Welches Bild passt zu welchem Text? Ein Bild ist zu viel.', 'matching', '{"bank": [{"key": "1", "text": "Bild 1"}, {"key": "2", "text": "Bild 2"}, {"key": "3", "text": "Bild 3"}, {"key": "4", "text": "Bild 4"}, {"key": "5", "text": "Bild 5"}, {"key": "6", "text": "Bild 6"}], "bankTitle": "Bilder", "bankImage": "img/oesd-a1-m01-lv3.jpg", "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 2}'::jsonb, 2),
    ('hv1', 'Hören', 'Hören, Teil 1', 4, 'Sie hören fünf verschiedene Texte zu den Fotos. Welcher Text passt zu welchem Foto? Ein Bild ist zu viel.', 'matching', '{"bank": [{"key": "A", "text": "Foto A"}, {"key": "B", "text": "Foto B"}, {"key": "C", "text": "Foto C"}, {"key": "D", "text": "Foto D"}, {"key": "E", "text": "Foto E"}, {"key": "F", "text": "Foto F"}], "bankTitle": "Fotos", "bankImage": "img/oesd-a1-m01-hv1.jpg", "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 2}'::jsonb, 3),
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

-- ================= modell-02 · MARTIN =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('oesd-a1', 'modell-02', 'MARTIN', '29 Aufgaben · 55 Minuten',
        '[{"id": "block-lesen", "parts": ["lv1", "lv2", "lv3"], "title": "Lesen", "minutes": 25, "hint": "Aufgaben 1–16", "maxPoints": 30, "availablePoints": 30, "missing": 0}, {"id": "block-hoeren", "parts": ["hv1", "hv2", "hv3"], "title": "Hören", "minutes": 10, "hint": "Aufgaben 17–27", "maxPoints": 30, "availablePoints": 30, "missing": 0}, {"id": "block-schreiben", "parts": ["s1", "s2"], "title": "Schreiben", "minutes": 20, "hint": "Aufgaben 28–29", "maxPoints": 20, "availablePoints": 20, "missing": 0}]'::jsonb, 29, true, 2)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('lv1', 'Lesen', 'Lesen, Teil 1', 10, 'Finden Sie zu jeder Situation auf Blatt 1 (Situation A–E) die passende Anzeige auf Blatt 2 (Anzeige Nr. 1–6). Eine Anzeige ist zu viel.', 'matching', '{"bank": [{"key": "1", "text": "Miet-Hit: Wohnen am Stadtrand: drei Zimmer, Nebenräume, Balkon, familienfreundlicher Wohnpark mit Garagenplatz für Ihr Auto. Infos: www.gewog.at"}, {"key": "2", "text": "Computer-Börse: Probleme mit dem Computer? Wir bieten: neue und gebrauchte Computer, verschiedenes Zubehör und Reparaturen. Internet: www.computer.de"}, {"key": "3", "text": "Verkäufer/Verkäuferin gesucht! Wir suchen eine kompetente Verkaufskraft für unseren Handy- und Computerladen in Basel. Ihre Qualifikation: Erfahrung im Verkauf, Kenntnisse über neueste EDV und Internet-Software. Kontakt: office@computerladen.ch"}, {"key": "4", "text": "Der ONLINE-PREISHAMMER: Surfen Sie im Internet so lange Sie wollen! für nur 10 Euro im Monat. Nähere Informationen und Anmeldungen bei: ONLINE, Tel: 0800-33 21 300"}, {"key": "5", "text": "Telefonieren Sie zum billigsten Tarif in ganz Österreich und holen Sie sich die besten Handys und Smartphones ab 0 €. Gleich anmelden bei: Techno-Star Telefonsysteme, 54-mal in Österreich. www.techno-star.at"}, {"key": "6", "text": "KAUFEN oder VERKAUFEN? Sie wollen gebrauchte Dinge kaufen oder Ihren alten Fernseher, Möbel oder etwas anderes verkaufen? Mit einer Anzeige in Ihrer Bezirkszeitung ist das einfach! Telefonische Anfragen unter: 01 54 100/ DW 32 Anzeigenbüro"}], "bankTitle": "Anzeigen", "bankImage": "img/oesd-a1-m02-lv1.jpg", "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 2}'::jsonb, 0),
    ('lv2', 'Lesen', 'Lesen, Teil 2', 10, 'Sie lesen drei Anzeigen. Dazu gibt es je 2 Fragen. Antworten Sie mit JA oder NEIN.', 'mc', '{"passages": [{"paragraphs": [{"t": "Damen-Friseursalon Helga", "b": true}, {"t": "Neue Öffnungszeiten:", "b": false}, {"t": "Di.–Do. 11–18 Uhr", "b": false}, {"t": "Fr. 15–20 Uhr", "b": false}, {"t": "Sa. 10–14 Uhr", "b": false}, {"t": "Haare waschen – schneiden – färben – Dauerwelle", "b": false}, {"t": "Aktion für Studentinnen: minus 50 Prozent!", "b": false}]}], "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 1.67}'::jsonb, 1),
    ('lv3', 'Lesen', 'Lesen, Teil 3', 5, 'Sie lesen hier 5 kurze Texte (Text A–E). Zu jedem Text gibt es ein Bild (Bild 1–6). Welches Bild passt zu welchem Text? Ein Bild ist zu viel.', 'matching', '{"bank": [{"key": "1", "text": "Bild 1"}, {"key": "2", "text": "Bild 2"}, {"key": "3", "text": "Bild 3"}, {"key": "4", "text": "Bild 4"}, {"key": "5", "text": "Bild 5"}, {"key": "6", "text": "Bild 6"}], "bankTitle": "Bilder", "bankImage": "img/oesd-a1-m02-lv3.jpg", "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 2}'::jsonb, 2),
    ('hv1', 'Hören', 'Hören, Teil 1', 4, 'Sie hören fünf verschiedene Texte zu den Fotos. Welcher Text passt zu welchem Foto? Ein Bild ist zu viel.', 'matching', '{"bank": [{"key": "A", "text": "Foto A"}, {"key": "B", "text": "Foto B"}, {"key": "C", "text": "Foto C"}, {"key": "D", "text": "Foto D"}, {"key": "E", "text": "Foto E"}, {"key": "F", "text": "Foto F"}], "bankTitle": "Fotos", "bankImage": "img/oesd-a1-m02-hv1.jpg", "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 2}'::jsonb, 3),
    ('hv2', 'Hören', 'Hören, Teil 2 (Telefonnotiz)', 3, 'Sie hören eine Nachricht. Hören Sie gut zu und schreiben Sie die wichtigsten Informationen auf das Notizblatt. Sie hören den Text zwei Mal.', 'writing', '{"passages": [{"paragraphs": [{"t": "Notizen: Wohnung", "b": true}, {"t": "Was: Wohnung (Beispiel)", "b": false}, {"t": "Frei ab: ............................, Größe ............................ m²", "b": false}, {"t": "Preis: ............................ Euro", "b": false}, {"t": "Wo: in der ............................-Straße 23", "b": false}, {"t": "Telefonnummer: 0650/ ............................", "b": false}]}], "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 10}'::jsonb, 4),
    ('hv3', 'Hören', 'Hören, Teil 3', 3, 'Sie hören jetzt 5 Personen, die befragt werden: „Was lesen Sie am liebsten?“ Kreuzen Sie die richtige Antwort an. Pro Person gibt es nur eine Antwort.', 'mc', '{"maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 2}'::jsonb, 5),
    ('s1', 'Schreiben', 'Schreiben, Teil 1 (Formular)', 10, 'Helfen Sie Ihrem Freund und füllen Sie das Formular aus.', 'writing', '{"passages": [{"paragraphs": [{"t": "Ihr Freund, Juan Rodriguez, geboren am 12.10.1985, möchte einen Deutschkurs an der Volkshochschule machen. Er ist kein Anfänger, er hat schon die A1-Prüfung gemacht. Er ist Taxifahrer von Beruf und arbeitet abends. Er möchte vormittags einen Kurs besuchen. Juan wohnt in München, in der Danklstraße 15. Die Postleitzahl ist 81371.", "b": false}, {"t": "ANMELDUNG – SPRACHZENTRUM", "b": true}, {"t": "Familienname: Rodriguez", "b": false}, {"t": "Vorname: Juan", "b": false}, {"t": "Postleitzahl, Wohnort: (1) ............................", "b": false}, {"t": "Straße, Hausnummer: (2) ............................", "b": false}, {"t": "Telefon: 089/2935546", "b": false}, {"t": "Beruf: (3) ............................", "b": false}, {"t": "Kurs/Kursnummer: (4) Deutsch Anfänger – A1 / Deutsch Fortgeschrittene – A2", "b": false}, {"t": "Termin: (5) montags–freitags, 9–12 Uhr / montags–freitags, 18–21 Uhr", "b": false}]}], "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 10}'::jsonb, 6),
    ('s2', 'Schreiben', 'Schreiben, Teil 2 (E-Mail)', 10, 'Ihr Freund Martin möchte ans Meer fahren. Sie bekommen folgendes E-Mail von ihm. Antworten Sie Martin. Schreiben Sie circa 30 Wörter. Beantworten Sie alle Fragen und schreiben Sie am Ende einen Gruß.', 'writing', '{"passages": [{"paragraphs": [{"t": "Reise ans Meer", "b": true}, {"t": "Hallo!", "b": false}, {"t": "In meinem nächsten Urlaub möchte ich gern ans Meer reisen! Kommst du mit? Du kannst auch gerne deine Familie oder Freunde mitnehmen. Schreib mir bitte: Wann hast du Zeit? Wie möchtest du reisen? Wer kommt noch mit?", "b": false}, {"t": "Liebe Grüße", "b": false}, {"t": "Martin", "b": false}]}], "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 10}'::jsonb, 7)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'oesd-a1' and t.slug = 'modell-02'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('lv1', '1', 'Situation A: Sie haben ein altes Auto und möchten es verkaufen.', null::jsonb, 2, null::jsonb, 0),
    ('lv1', '2', 'Situation B: Sie suchen eine Wohnung für sich und Ihre Kinder.', null::jsonb, 2, null::jsonb, 1),
    ('lv1', '3', 'Situation C: Ihr PC ist kaputt. Sie möchten ihn reparieren lassen.', null::jsonb, 2, null::jsonb, 2),
    ('lv1', '4', 'Situation D: Ihre Tochter braucht oft das Internet. Sie suchen ein Angebot.', null::jsonb, 2, null::jsonb, 3),
    ('lv1', '5', 'Situation E: Sie rufen gerne Ihre Freunde an und brauchen ein neues Mobiltelefon.', null::jsonb, 2, null::jsonb, 4),
    ('lv2', '6', 'Können Sie am Freitagvormittag Ihre Haare schneiden lassen?', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 0),
    ('lv2', '7', 'Zahlen Studentinnen den halben Preis? Text: **Weltcafé** Vegetarische Küche Mittagsmenü (Suppe und Hauptspeise) für 5,80 Euro Überdachter Gastgarten! NEU jeden Freitag: Essen mit Musik von 18:00 bis 23:00 Uhr, nur mit Reservierung Aufgaben:', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 1),
    ('lv2', '8', 'Gibt es im Weltcafé Hauptspeisen ohne Fleisch?', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 2),
    ('lv2', '9', 'Muss man am Freitagabend reservieren? Text: **HAUPTBAHNHOF NEU** Wir bauen für Sie! Der Haupteingang am Rudolfsplatz ist bis Dezember geschlossen. Bitte nehmen Sie den Eingang in der Bahnhofstraße. Die Schalter für Fahrkarten und die Information haben ganz normal für Sie geöffnet. Wir danken für Ihr Verständnis! Aufgaben:', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 3),
    ('lv2', '10', 'Ist der Eingang in der Bahnhofstraße geschlossen?', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 4),
    ('lv2', '11', 'Können Sie im Bahnhof Tickets kaufen?', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 5),
    ('lv3', '12', 'Text A: Herzlich willkommen in unserem Einkaufszentrum! Unsere neuen Parkplätze in der Parkgarage warten auf Sie – die erste Stunde kostet nichts!', null::jsonb, 2, null::jsonb, 0),
    ('lv3', '13', 'Text B: Liebe Kundinnen und Kunden! Unsere Servicemitarbeiter sind rund um die Uhr für Sie da! Kontaktieren Sie uns unter 034-99099 oder unter der Adresse service@clientsfirst.co.de', null::jsonb, 2, null::jsonb, 1),
    ('lv3', '14', 'Text C: Liebe Naturfreunde, wir bitten Sie, diesen Park sauber zu halten. Bitte werfen Sie Ihren Abfall nicht im Park weg. An allen Ausgängen gibt es Mülleimer.', null::jsonb, 2, null::jsonb, 2),
    ('lv3', '15', 'Text D: Liebe MuseumsbesucherInnen, der Eingang für RollstuhlfahrerInnen und Personen mit Kinderwägen ist in der Brunnerstraße Nr. 5. Bitte läuten Sie an der Tür, wir helfen Ihnen gerne.', null::jsonb, 2, null::jsonb, 3),
    ('lv3', '16', 'Text E: Schneiderei Müller: Ihr Kleid ist zu weit, Ihre Hose zu lang, Ihr Mantel zu kurz? Kein Problem: Wir ändern Ihre Kleidung für Sie!', null::jsonb, 2, null::jsonb, 4),
    ('hv1', '17', 'Text 1', null::jsonb, 2, null::jsonb, 0),
    ('hv1', '18', 'Text 2', null::jsonb, 2, null::jsonb, 1),
    ('hv1', '19', 'Text 3', null::jsonb, 2, null::jsonb, 2),
    ('hv1', '20', 'Text 4', null::jsonb, 2, null::jsonb, 3),
    ('hv1', '21', 'Text 5', null::jsonb, 2, null::jsonb, 4),
    ('hv2', '22', 'Füllen Sie die wichtigsten Informationen in die Notizen ein:', null::jsonb, 0, '{"points": ["Frei ab: Juni", "Größe: 68 m²", "Preis: 500 Euro", "Wo: Hirschenstraße 23", "Telefonnummer: 0650 / 2648235"]}'::jsonb, 0),
    ('hv3', '23', 'Person 1: Was lesen Sie am liebsten?', '[{"key": "A", "text": "Zeitungen"}, {"key": "B", "text": "Wissens-/Sachbücher"}, {"key": "C", "text": "Reisebücher"}, {"key": "D", "text": "Bücher über Liebe"}]'::jsonb, 2, null::jsonb, 0),
    ('hv3', '24', 'Person 2: Was lesen Sie am liebsten?', '[{"key": "A", "text": "Zeitungen"}, {"key": "B", "text": "Wissens-/Sachbücher"}, {"key": "C", "text": "Reisebücher"}, {"key": "D", "text": "Bücher über Liebe"}]'::jsonb, 2, null::jsonb, 1),
    ('hv3', '25', 'Person 3: Was lesen Sie am liebsten?', '[{"key": "A", "text": "Zeitungen"}, {"key": "B", "text": "Wissens-/Sachbücher"}, {"key": "C", "text": "Reisebücher"}, {"key": "D", "text": "Bücher über Liebe"}]'::jsonb, 2, null::jsonb, 2),
    ('hv3', '26', 'Person 4: Was lesen Sie am liebsten?', '[{"key": "A", "text": "Zeitungen"}, {"key": "B", "text": "Wissens-/Sachbücher"}, {"key": "C", "text": "Reisebücher"}, {"key": "D", "text": "Bücher über Liebe"}]'::jsonb, 2, null::jsonb, 3),
    ('hv3', '27', 'Person 5: Was lesen Sie am liebsten?', '[{"key": "A", "text": "Zeitungen"}, {"key": "B", "text": "Wissens-/Sachbücher"}, {"key": "C", "text": "Reisebücher"}, {"key": "D", "text": "Bücher über Liebe"}]'::jsonb, 2, null::jsonb, 4),
    ('s1', '28', 'Schreiben Sie die fünf fehlenden Informationen in das Formular:', null::jsonb, 0, '{"points": ["(1) Postleitzahl, Wohnort: 81371 München", "(2) Straße, Hausnummer: Danklstraße 15", "(3) Beruf: Taxifahrer", "(4) Kurs: Deutsch Fortgeschrittene – A2", "(5) Termin: montags–freitags, 9–12 Uhr"]}'::jsonb, 0),
    ('s2', '29', 'Antworten Sie Martin (mindestens 30 Wörter):', null::jsonb, 0, '{"minWords": 30, "points": ["Wann hast du Zeit?", "Wie möchtest du reisen?", "Wer kommt noch mit?", "Gruß am Ende"]}'::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'oesd-a1' and t.slug = 'modell-02'
join sections s on s.test_id = t.id and s.section_id = v.section_id
on conflict (section_id, item_id) do update set text = excluded.text, options = excluded.options, points = excluded.points, meta = excluded.meta, sort = excluded.sort;

insert into item_answers (item_id, answer, explanation)
select i.id, v.answer, v.explanation
from (values
    ('lv1', '1', '6', null),
    ('lv1', '2', '1', null),
    ('lv1', '3', '2', null),
    ('lv1', '4', '4', null),
    ('lv1', '5', '5', null),
    ('lv2', '6', 'B', null),
    ('lv2', '7', 'A', null),
    ('lv2', '8', 'A', null),
    ('lv2', '9', 'A', null),
    ('lv2', '10', 'B', null),
    ('lv2', '11', 'A', null),
    ('lv3', '12', '5', null),
    ('lv3', '13', '6', null),
    ('lv3', '14', '2', null),
    ('lv3', '15', '3', null),
    ('lv3', '16', '1', null),
    ('hv1', '17', 'D', null),
    ('hv1', '18', 'E', null),
    ('hv1', '19', 'F', null),
    ('hv1', '20', 'B', null),
    ('hv1', '21', 'A', null),
    ('hv3', '23', 'A', null),
    ('hv3', '24', 'B', null),
    ('hv3', '25', 'D', null),
    ('hv3', '26', 'C', null),
    ('hv3', '27', 'D', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'oesd-a1' and t.slug = 'modell-02'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;

-- ================= modell-03 · MAGDA =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('oesd-a1', 'modell-03', 'MAGDA', '29 Aufgaben · 55 Minuten',
        '[{"id": "block-lesen", "parts": ["lv1", "lv2", "lv3"], "title": "Lesen", "minutes": 25, "hint": "Aufgaben 1–16", "maxPoints": 30, "availablePoints": 30, "missing": 0}, {"id": "block-hoeren", "parts": ["hv1", "hv2", "hv3"], "title": "Hören", "minutes": 10, "hint": "Aufgaben 17–27", "maxPoints": 30, "availablePoints": 30, "missing": 0}, {"id": "block-schreiben", "parts": ["s1", "s2"], "title": "Schreiben", "minutes": 20, "hint": "Aufgaben 28–29", "maxPoints": 20, "availablePoints": 20, "missing": 0}]'::jsonb, 29, true, 3)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('lv1', 'Lesen', 'Lesen, Teil 1', 10, 'Finden Sie zu jeder Situation auf Blatt 1 (Situation A–E) die passende Anzeige auf Blatt 2 (Anzeige Nr. 1–6). Eine Anzeige ist zu viel.', 'matching', '{"bank": [{"key": "1", "text": "Kunst zum kleinen Preis: Fotos und Naturbilder von berühmten KünstlerInnen und FotografInnen – schon ab 30 Euro! Kunst-Supermarkt, Neubaugasse 14, 1070 Wien"}, {"key": "2", "text": "Wir suchen eine/n Kellnerin/Kellner: Hotelrestaurant „Zur Goldenen Buche“. Erfahrung im Service notwendig, Essen und Unterkunft gratis. Kontakt: Frau Garcia, Tel.-Nr.: 012 785 1254"}, {"key": "3", "text": "WIEDERERÖFFNUNG DES STRANDHOTELS MEERBLICK: große Zimmer in allen Preisklassen mit Balkon oder Terrasse, Frühstücksbuffet. 5 Minuten vom Strand entfernt. www.hotelammeer.com"}, {"key": "4", "text": "„Bücher-Markt“: Egal ob Krimi, Sachbuch, Comic oder Poesie: Hier finden Sie Bücher zu verschiedenen Themen und günstigen Preisen! Jeden Freitag von 10 bis 17 Uhr, Stadtbibliothek Tulln"}, {"key": "5", "text": "Keine Zeit zum Einkaufen? Keine Lust zu kochen? Italienische Küche auf Bestellung bei Bellini. Rufen Sie uns an: 01 344 677. Wir bieten: Pasta, Pizza, Fleisch- und Fischgerichte"}, {"key": "6", "text": "Obst und Gemüse: Biologisch und frisch, direkt vom Bauernhof! Jeden Samstag Gemüse- und Obstmarkt von 8 bis 14 Uhr am Hauptplatz. Bio-Fleisch auf Vorbestellung"}], "bankTitle": "Anzeigen", "bankImage": "img/oesd-a1-m03-lv1.jpg", "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 2}'::jsonb, 0),
    ('lv2', 'Lesen', 'Lesen, Teil 2', 10, 'Sie lesen drei Anzeigen. Dazu gibt es je 2 Fragen. Antworten Sie mit JA oder NEIN.', 'mc', '{"passages": [{"paragraphs": [{"t": "Sprachkurse an der SPRACHSCHULE OLYMP", "b": true}, {"t": "Wir bieten Kurse für folgende Sprachen:", "b": false}, {"t": "Deutsch, Englisch, Französisch, Russisch, Slowenisch, Türkisch, Polnisch, Tschechisch und Slowakisch", "b": false}, {"t": "Kurse: Dienstag und Donnerstag, 13 bis 16 Uhr", "b": false}, {"t": "Sprachschule Olymp", "b": false}, {"t": "Oberbergerstraße 17 | Tel: 01 313 56 72", "b": false}]}], "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 1.67}'::jsonb, 1),
    ('lv3', 'Lesen', 'Lesen, Teil 3', 5, 'Sie lesen hier 5 kurze Texte (Text A–E). Zu jedem Text gibt es ein Bild (Bild 1–6). Welches Bild passt zu welchem Text? Ein Bild ist zu viel.', 'matching', '{"bank": [{"key": "1", "text": "Bild 1"}, {"key": "2", "text": "Bild 2"}, {"key": "3", "text": "Bild 3"}, {"key": "4", "text": "Bild 4"}, {"key": "5", "text": "Bild 5"}, {"key": "6", "text": "Bild 6"}], "bankTitle": "Bilder", "bankImage": "img/oesd-a1-m03-lv3.jpg", "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 2}'::jsonb, 2),
    ('hv1', 'Hören', 'Hören, Teil 1', 4, 'Sie hören fünf verschiedene Texte zu den Fotos. Welcher Text passt zu welchem Foto? Ein Bild ist zu viel.', 'matching', '{"bank": [{"key": "A", "text": "Foto A"}, {"key": "B", "text": "Foto B"}, {"key": "C", "text": "Foto C"}, {"key": "D", "text": "Foto D"}, {"key": "E", "text": "Foto E"}, {"key": "F", "text": "Foto F"}], "bankTitle": "Fotos", "bankImage": "img/oesd-a1-m03-hv1.jpg", "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 2}'::jsonb, 3),
    ('hv2', 'Hören', 'Hören, Teil 2 (Telefonnotiz)', 3, 'Sie hören eine Nachricht. Hören Sie gut zu und schreiben Sie die wichtigsten Informationen auf das Notizblatt. Sie hören den Text zwei Mal.', 'writing', '{"passages": [{"paragraphs": [{"t": "Notizen: Arbeitsamt", "b": true}, {"t": "Arbeitsamt: neuer Termin", "b": false}, {"t": "Wann: am ............................, 17. August, um ............................ Uhr", "b": false}, {"t": "Wo: im Büro von Frau ............................", "b": false}, {"t": "im Zimmer Nummer ............................", "b": false}, {"t": "Telefonnummer: 04323/ ............................", "b": false}]}], "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 10}'::jsonb, 4),
    ('hv3', 'Hören', 'Hören, Teil 3', 3, 'Sie hören jetzt 5 Personen, die befragt werden: „Wo kaufen Sie am liebsten Brot und Backwaren ein?“ Kreuzen Sie die richtige Antwort an. Pro Person gibt es nur eine Antwort.', 'mc', '{"maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 2}'::jsonb, 5),
    ('s1', 'Schreiben', 'Schreiben, Teil 1 (Formular)', 10, 'Helfen Sie Ihrer Freundin und füllen Sie das Formular aus.', 'writing', '{"passages": [{"paragraphs": [{"t": "Ihre Freundin Yvonne Legrand aus Frankreich, geboren am 17.4.1993 in Lyon, möchte vom 1. bis zum 28. August einen Deutschkurs in Deutschland besuchen. Sie hat schon sechs Monate Deutsch gelernt. Sie hat am Vormittag Zeit. In der Schule hat sie Englisch gelernt.", "b": false}, {"t": "Sprachenschule LIGA – Anmeldung", "b": true}, {"t": "(0) Familienname: Legrand", "b": false}, {"t": "Vorname: Yvonne", "b": false}, {"t": "Geburtsdatum: 17.4.1993", "b": false}, {"t": "(1) Geburtsort: ............................", "b": false}, {"t": "Muttersprache: Französisch", "b": false}, {"t": "(2) Andere Sprachen: ............................", "b": false}, {"t": "Schon Deutsch gelernt? ja [x] nein [ ]", "b": false}, {"t": "(3) Wie lange?: ............................", "b": false}, {"t": "(4) Kurstermin: ............................", "b": false}, {"t": "(5) Kurszeit: [ ] von 9 – 12 Uhr | [ ] von 13 – 16 Uhr | [ ] von 17 – 20 Uhr", "b": false}]}], "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 10}'::jsonb, 6),
    ('s2', 'Schreiben', 'Schreiben, Teil 2 (E-Mail)', 10, 'Ihre Freundin Magda möchte mit Ihnen einkaufen gehen. Sie bekommen folgendes E-Mail von ihr. Antworten Sie Magda. Schreiben Sie circa 30 Wörter. Beantworten Sie alle Fragen und schreiben Sie am Ende einen Gruß.', 'writing', '{"passages": [{"paragraphs": [{"t": "Zusammen einkaufen", "b": true}, {"t": "Hallo!", "b": false}, {"t": "Ich möchte mir neue Schuhe kaufen. Ich gehe aber nicht so gern alleine einkaufen, möchtest du vielleicht mitkommen?", "b": false}, {"t": "An welchem Tag und um wie viel Uhr hast du Zeit? Wo gibt es gute Geschäfte? Leider habe ich kein Auto. Wie können wir einkaufen fahren?", "b": false}, {"t": "Liebe Grüße", "b": false}, {"t": "Magda", "b": false}]}], "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 10}'::jsonb, 7)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'oesd-a1' and t.slug = 'modell-03'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('lv1', '1', 'Situation A: Sie haben Hunger und möchten telefonisch etwas zu essen bestellen.', null::jsonb, 2, null::jsonb, 0),
    ('lv1', '2', 'Situation B: Sie wollen am Wochenende einkaufen gehen. Sie brauchen frischen Salat, Äpfel und Karotten.', null::jsonb, 2, null::jsonb, 1),
    ('lv1', '3', 'Situation C: Ihre Freundin hat Geburtstag. Sie möchten ihr ein Bild kaufen.', null::jsonb, 2, null::jsonb, 2),
    ('lv1', '4', 'Situation D: Am Wochenende haben Sie viel Zeit. Sie wollen sich etwas zum Lesen kaufen.', null::jsonb, 2, null::jsonb, 3),
    ('lv1', '5', 'Situation E: Bald ist Sommer. Sie suchen für die Ferien ein Hotel für Ihre Familie.', null::jsonb, 2, null::jsonb, 4),
    ('lv2', '6', 'Kann man in der Sprachschule Griechisch lernen?', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 0),
    ('lv2', '7', 'Gibt es am Mittwochnachmittag Kurse? Text: **Tiere suchen ein Zuhause** über 500 Tiere im neuen Tierschutzzentrum in Wien-Donaustadt Besuchen Sie uns: Di und Do: 15 bis 17 Uhr Fr und Sa: 13 bis 17 Uhr Informationen und Kontakt: 01 277 55 www.tierquartier.at Aufgaben:', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 1),
    ('lv2', '8', 'Kann man jeden Tag ins Tierschutzzentrum gehen?', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 2),
    ('lv2', '9', 'Kann man im Tierschutzzentrum anrufen? Text: **Spezialkurs: Schreiben IM ALLTAG** Hier lernen Sie, wie man z. B.: ✓ ein Formular ausfüllt, ✓ einen kurzen Brief oder ✓ eine Entschuldigung für das kranke Kind in der Schule schreibt. Volkshochschule Süd, Raum 3 10 Abende je 2 Stunden ab Montag, 17–19 Uhr Tel. Anmeldung unter 01 45 67 988 Aufgaben:', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 3),
    ('lv2', '10', 'Ist der Schreibkurs für Kinder?', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 4),
    ('lv2', '11', 'Ist der Kurs am Vormittag?', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 5),
    ('lv3', '12', 'Text A: Machen Sie Pause und spielen Sie Tischtennis! Ab sofort finden Sie in unserem Fitnessraum mehrere Tischtennistische. Denn: Sport in der Arbeitspause hält gesund und macht Spaß.', null::jsonb, 2, null::jsonb, 0),
    ('lv3', '13', 'Text B: Sehr geehrte Hausbewohner! Bitte respektieren Sie die Ruhezeiten! Zu Mittag und nach 10 Uhr abends: KEINE LAUTE MUSIK IM HAUS!', null::jsonb, 2, null::jsonb, 1),
    ('lv3', '14', 'Text C: Gesundes Essen am Arbeitsplatz! Sie möchten in der Mittagspause etwas kochen? Kein Problem! Im 1. Stock finden Sie eine Küche mit Mikrowelle, Herd und Kühlschrank.', null::jsonb, 2, null::jsonb, 2),
    ('lv3', '15', 'Text D: Schützen Sie sich vor Grippe! In Grippezeiten ist es sehr wichtig, regelmäßig die Hände zu waschen – besonders vor dem Essen.', null::jsonb, 2, null::jsonb, 3),
    ('lv3', '16', 'Text E: Die Waschmaschine ist für alle Hausbewohner da! Bevor Sie Ihre Wäsche waschen: Schreiben Sie Ihren Namen in den Wochenplan!', null::jsonb, 2, null::jsonb, 4),
    ('hv1', '17', 'Text 1', null::jsonb, 2, null::jsonb, 0),
    ('hv1', '18', 'Text 2', null::jsonb, 2, null::jsonb, 1),
    ('hv1', '19', 'Text 3', null::jsonb, 2, null::jsonb, 2),
    ('hv1', '20', 'Text 4', null::jsonb, 2, null::jsonb, 3),
    ('hv1', '21', 'Text 5', null::jsonb, 2, null::jsonb, 4),
    ('hv2', '22', 'Füllen Sie die wichtigsten Informationen in die Notizen ein:', null::jsonb, 0, '{"points": ["Wann (Wochentag): Freitag / Fr(.)", "Uhrzeit: 15 / 3 Uhr", "Wo (Büro von Frau): Huber", "Zimmer Nummer: 12", "Telefonnummer: 1578942"]}'::jsonb, 0),
    ('hv3', '23', 'Text 1: Wo kaufen Sie am liebsten Brot und Backwaren ein?', '[{"key": "A", "text": "in der Bäckerei"}, {"key": "B", "text": "auf dem Bauernmarkt"}, {"key": "C", "text": "im Supermarkt"}, {"key": "D", "text": "im Bio-Geschäft"}]'::jsonb, 2, null::jsonb, 0),
    ('hv3', '24', 'Text 2: Wo kaufen Sie am liebsten Brot und Backwaren ein?', '[{"key": "A", "text": "in der Bäckerei"}, {"key": "B", "text": "auf dem Bauernmarkt"}, {"key": "C", "text": "im Supermarkt"}, {"key": "D", "text": "im Bio-Geschäft"}]'::jsonb, 2, null::jsonb, 1),
    ('hv3', '25', 'Text 3: Wo kaufen Sie am liebsten Brot und Backwaren ein?', '[{"key": "A", "text": "in der Bäckerei"}, {"key": "B", "text": "auf dem Bauernmarkt"}, {"key": "C", "text": "im Supermarkt"}, {"key": "D", "text": "im Bio-Geschäft"}]'::jsonb, 2, null::jsonb, 2),
    ('hv3', '26', 'Text 4: Wo kaufen Sie am liebsten Brot und Backwaren ein?', '[{"key": "A", "text": "in der Bäckerei"}, {"key": "B", "text": "auf dem Bauernmarkt"}, {"key": "C", "text": "im Supermarkt"}, {"key": "D", "text": "im Bio-Geschäft"}]'::jsonb, 2, null::jsonb, 3),
    ('hv3', '27', 'Text 5: Wo kaufen Sie am liebsten Brot und Backwaren ein?', '[{"key": "A", "text": "in der Bäckerei"}, {"key": "B", "text": "auf dem Bauernmarkt"}, {"key": "C", "text": "im Supermarkt"}, {"key": "D", "text": "im Bio-Geschäft"}]'::jsonb, 2, null::jsonb, 4),
    ('s1', '28', 'Schreiben Sie die fünf fehlenden Informationen in das Formular:', null::jsonb, 0, '{"points": ["(1) Geburtsort: Lyon", "(2) Andere Sprachen: Englisch", "(3) Wie lange: sechs Monate / 6 Monate", "(4) Kurstermin: vom 1. bis zum 28. August / 1. - 28. August", "(5) Kurszeit: von 9 – 12 Uhr"]}'::jsonb, 0),
    ('s2', '29', 'Antworten Sie Magda (mindestens 30 Wörter):', null::jsonb, 0, '{"minWords": 30, "points": ["An welchem Tag und um wie viel Uhr hast du Zeit?", "Wo gibt es gute Geschäfte?", "Wie können wir einkaufen fahren?", "Gruß am Ende"]}'::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'oesd-a1' and t.slug = 'modell-03'
join sections s on s.test_id = t.id and s.section_id = v.section_id
on conflict (section_id, item_id) do update set text = excluded.text, options = excluded.options, points = excluded.points, meta = excluded.meta, sort = excluded.sort;

insert into item_answers (item_id, answer, explanation)
select i.id, v.answer, v.explanation
from (values
    ('lv1', '1', '5', null),
    ('lv1', '2', '6', null),
    ('lv1', '3', '1', null),
    ('lv1', '4', '4', null),
    ('lv1', '5', '3', null),
    ('lv2', '6', 'B', null),
    ('lv2', '7', 'B', null),
    ('lv2', '8', 'B', null),
    ('lv2', '9', 'A', null),
    ('lv2', '10', 'B', null),
    ('lv2', '11', 'B', null),
    ('lv3', '12', '4', null),
    ('lv3', '13', '1', null),
    ('lv3', '14', '2', null),
    ('lv3', '15', '3', null),
    ('lv3', '16', '6', null),
    ('hv1', '17', 'C', null),
    ('hv1', '18', 'E', null),
    ('hv1', '19', 'A', null),
    ('hv1', '20', 'D', null),
    ('hv1', '21', 'F', null),
    ('hv3', '23', 'B', null),
    ('hv3', '24', 'A', null),
    ('hv3', '25', 'D', null),
    ('hv3', '26', 'A', null),
    ('hv3', '27', 'C', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'oesd-a1' and t.slug = 'modell-03'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;

-- ================= modell-04 · MATTHIAS =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('oesd-a1', 'modell-04', 'MATTHIAS', '29 Aufgaben · 55 Minuten',
        '[{"id": "block-lesen", "parts": ["lv1", "lv2", "lv3"], "title": "Lesen", "minutes": 25, "hint": "Aufgaben 1–16", "maxPoints": 30, "availablePoints": 30, "missing": 0}, {"id": "block-hoeren", "parts": ["hv1", "hv2", "hv3"], "title": "Hören", "minutes": 10, "hint": "Aufgaben 17–27", "maxPoints": 30, "availablePoints": 30, "missing": 0}, {"id": "block-schreiben", "parts": ["s1", "s2"], "title": "Schreiben", "minutes": 20, "hint": "Aufgaben 28–29", "maxPoints": 20, "availablePoints": 20, "missing": 0}]'::jsonb, 29, true, 4)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('lv1', 'Lesen', 'Lesen, Teil 1', 10, 'Finden Sie zu jeder Situation auf Blatt 1 (Situation A–E) die passende Anzeige auf Blatt 2 (Anzeige Nr. 1–6). Eine Anzeige ist zu viel.', 'matching', '{"bank": [{"key": "1", "text": "Reisebüro Smekal: Bahnreisen in alle deutschen Städte: schnell, billig und ohne Stress. auf Wunsch mit Übernachtung im Hotel. Aktuelle Angebote finden Sie unter: www.reise-smekal.de"}, {"key": "2", "text": "Wir organisieren Ihren Geburtstag! Feiern Sie Ihren Geburtstag im Nostalgiezug und schenken Sie sich und Ihren Freunden eine romantische Fahrt durch Wien. Start: 20.00 Uhr, Hauptbahnhof. Dauer: 2 Stunden, auf Wunsch mit Abendessen. www.agenturspezial.com"}, {"key": "3", "text": "Programm für die Woche vom 7. bis 13. November: Rot wie die Liebe; Die Nachtfahrt; Mein Freund Ferdi Fuchs; Kommt ein Raumschiff geflogen; Alpengold – Im Land der Berge. Filminfos, Kartenpreise und Reservierung: www.cineman.ch"}, {"key": "4", "text": "Kleidung, Schuhe, Taschen: Modegeschäft Graf. Kleine Preise für alle Größen! Große Auswahl an Mänteln, Pullovern und Kleidung für Kinder! Rosenaustr. 50, 86150 Augsburg"}, {"key": "5", "text": "IHR SPEZIALIST FÜR PFLANZEN: als Geschenk oder für den Garten. Rosalia. Öffnungszeiten Mo.–Fr.: 09:00–18:00 Uhr. Mayergasse 5. Internet: www.rosalia.at"}, {"key": "6", "text": "Zahnarzt Dr. Hubert Steiner: Ihr Spezialist für schmerzfreie Zahnbehandlung. Ordinationszeiten: Mo–Do 08:00–13:00. telefonische Anmeldung 01 536 783 45. alle Kassen"}], "bankTitle": "Anzeigen", "bankImage": "img/oesd-a1-m04-lv1.jpg", "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 2}'::jsonb, 0),
    ('lv2', 'Lesen', 'Lesen, Teil 2', 10, 'Sie lesen drei Anzeigen. Dazu gibt es je 2 Fragen. Antworten Sie mit JA oder NEIN.', 'mc', '{"passages": [{"paragraphs": [{"t": "Treffen Sie Menschen aus der ganzen Welt!", "b": true}, {"t": "Sie lernen neue Freunde kennen, kochen gemeinsam und hören etwas über andere Länder!", "b": false}, {"t": "Wann: jeden Freitag ab 18.00 Uhr", "b": false}, {"t": "Clubcafé im Amtshaus", "b": false}, {"t": "Goethestraße 3", "b": false}, {"t": "Tel: 0664 / 5763 45 32", "b": false}]}], "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 1.67}'::jsonb, 1),
    ('lv3', 'Lesen', 'Lesen, Teil 3', 5, 'Sie lesen hier 5 kurze Texte (Text A–E). Zu jedem Text gibt es ein Bild (Bild 1–6). Welches Bild passt zu welchem Text? Ein Bild ist zu viel.', 'matching', '{"bank": [{"key": "1", "text": "Bild 1"}, {"key": "2", "text": "Bild 2"}, {"key": "3", "text": "Bild 3"}, {"key": "4", "text": "Bild 4"}, {"key": "5", "text": "Bild 5"}, {"key": "6", "text": "Bild 6"}], "bankTitle": "Bilder", "bankImage": "img/oesd-a1-m04-lv3.jpg", "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 2}'::jsonb, 2),
    ('hv1', 'Hören', 'Hören, Teil 1', 4, 'Sie hören fünf verschiedene Texte zu den Fotos. Welcher Text passt zu welchem Foto? Ein Bild ist zu viel.', 'matching', '{"bank": [{"key": "A", "text": "Foto A"}, {"key": "B", "text": "Foto B"}, {"key": "C", "text": "Foto C"}, {"key": "D", "text": "Foto D"}, {"key": "E", "text": "Foto E"}, {"key": "F", "text": "Foto F"}], "bankTitle": "Fotos", "bankImage": "img/oesd-a1-m04-hv1.jpg", "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 2}'::jsonb, 3),
    ('hv2', 'Hören', 'Hören, Teil 2 (Telefonnotiz)', 3, 'Sie hören eine Nachricht. Hören Sie gut zu und schreiben Sie die wichtigsten Informationen auf das Notizblatt. Sie hören den Text zwei Mal.', 'writing', '{"passages": [{"paragraphs": [{"t": "Notizen: Geburtstagsparty", "b": true}, {"t": "Was: Geburtstagsparty", "b": false}, {"t": "Wann: am ............................, ............................ Februar", "b": false}, {"t": "um ............................ Uhr", "b": false}, {"t": "Wo: in der ............................gasse 8", "b": false}, {"t": "Telefonnummer: 0664/ ............................", "b": false}]}], "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 10}'::jsonb, 4),
    ('hv3', 'Hören', 'Hören, Teil 3', 3, 'Sie hören jetzt 5 Personen, die befragt werden: „Was essen Sie am liebsten?“ Kreuzen Sie die richtige Antwort an. Pro Person gibt es nur eine Antwort.', 'mc', '{"maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 2}'::jsonb, 5),
    ('s1', 'Schreiben', 'Schreiben, Teil 1 (Formular)', 10, 'Helfen Sie Ihrer Freundin und füllen Sie das Formular aus.', 'writing', '{"passages": [{"paragraphs": [{"t": "Ihre Freundin, Eva Kadavy, macht mit ihrem Mann und ihren beiden Söhnen (8 und 11 Jahre alt) Urlaub in Seeheim. Im Reisebüro bucht sie für den nächsten Sonntag eine Busfahrt um den Bodensee. Frau Kadavy hat keine Kreditkarte.", "b": false}, {"t": "BODENSEE-RUNDFAHRT – Anmeldung", "b": true}, {"t": "(0) Familienname, Vorname: Kadavy, Eva", "b": false}, {"t": "(1) Anzahl der Personen: ............................", "b": false}, {"t": "(2) Davon Kinder: ............................", "b": false}, {"t": "Urlaubsadresse: Hotel Schönblick", "b": false}, {"t": "Straße, Hausnummer: Burgstraße 34", "b": false}, {"t": "PLZ, Urlaubsort: 78014 (3) ............................", "b": false}, {"t": "Der Reisepreis ist mit der Anmeldung zu bezahlen.", "b": false}, {"t": "(4) Zahlungsweise: [ ] Bar | [ ] Kreditkarte", "b": false}, {"t": "(5) Reisetermin: ............................", "b": false}]}], "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 10}'::jsonb, 6),
    ('s2', 'Schreiben', 'Schreiben, Teil 2 (E-Mail)', 10, 'Ihr Freund Matthias möchte mit Ihnen Sport machen. Sie bekommen folgendes E-Mail von ihm. Antworten Sie Matthias. Schreiben Sie circa 30 Wörter. Beantworten Sie alle Fragen und schreiben Sie am Ende einen Gruß.', 'writing', '{"passages": [{"paragraphs": [{"t": "Freizeitsport", "b": true}, {"t": "Hallo!", "b": false}, {"t": "Ich möchte in meiner Freizeit gern Sport machen, vielleicht Schwimmen oder Radfahren. Möchtest du mit mir gemeinsam etwas machen?", "b": false}, {"t": "Schreib mir bitte: Welche Sportart möchtest du gerne machen? Was brauchen wir? An welchem Tag hast du Zeit?", "b": false}, {"t": "Liebe Grüße", "b": false}, {"t": "Matthias", "b": false}]}], "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 10}'::jsonb, 7)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'oesd-a1' and t.slug = 'modell-04'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('lv1', '1', 'Situation A: Ihre Mutter hat Geburtstag. Sie wollen Blumen kaufen.', null::jsonb, 2, null::jsonb, 0),
    ('lv1', '2', 'Situation B: Bald ist Winter. Sie suchen eine Jacke für Ihre kleine Tochter.', null::jsonb, 2, null::jsonb, 1),
    ('lv1', '3', 'Situation C: Sie haben Zahnschmerzen und brauchen schnell Hilfe.', null::jsonb, 2, null::jsonb, 2),
    ('lv1', '4', 'Situation D: Am Wochenende haben Sie Freizeit. Sie möchten mit Freunden ins Kino gehen.', null::jsonb, 2, null::jsonb, 3),
    ('lv1', '5', 'Situation E: Sie haben ein paar Tage frei. Sie möchten mit dem Zug wegfahren.', null::jsonb, 2, null::jsonb, 4),
    ('lv2', '6', 'Kann man im Clubcafé mit Menschen aus vielen Ländern sprechen?', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 0),
    ('lv2', '7', 'Kann man nächsten Donnerstag ins Clubcafé kommen? Text: **D-A-CH Bands laden zur MUSIK-NACHT** am Freitag, 7. Juli, Beginn 19 Uhr Musik aus Deutschland, Österreich und der Schweiz! Buffet mit regionalen Speisen aus allen drei Ländern DACH-Zentrum | Saal 3, 1. Stock Eintritt: 6 Euro Aufgaben:', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 1),
    ('lv2', '8', 'Gibt es etwas zu essen?', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 2),
    ('lv2', '9', 'Muss man für das Fest bezahlen? Text: **FLOTT Transport** Neue Wohnung, aber kein großes Auto? Wir bringen Ihre Möbel und vieles mehr an jeden Ort – in Österreich und Europa. 2 Männer + Auto: 40 Euro pro Stunde 24-Stunden-Hotline: +43 (0) 660 21 24 459 Aufgaben:', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 3),
    ('lv2', '10', 'Kann man bei Flott Transport Autos kaufen?', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 4),
    ('lv2', '11', 'Kann man auch in der Nacht anrufen?', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 5),
    ('lv3', '12', 'Text A: SEHR GEEHRTE DAMEN UND HERREN, Sie können von Montag bis Freitag 9–18 Uhr Ihre Briefe und Pakete abholen. Bitte füllen Sie das Abholformular aus und halten Sie Ihren Lichtbildausweis bereit.', null::jsonb, 2, null::jsonb, 0),
    ('lv3', '13', 'Text B: Bitte beachten Sie, dass in diesem Teil des Parks Hunde verboten sind. Für Hunde steht der hintere Teil des Parks zur Verfügung. Danke für Ihr Verständnis!', null::jsonb, 2, null::jsonb, 1),
    ('lv3', '14', 'Text C: Liebe Bibliotheksbesucherinnen und -besucher! Sie finden unsere Computer mit Internetzugang im Raum 4. Bei Fragen hilft Ihnen gerne unser Bibliothekspersonal.', null::jsonb, 2, null::jsonb, 2),
    ('lv3', '15', 'Text D: Konditorei BERGER: Original österreichische Kaffeehaus-Spezialitäten! Unsere Öffnungszeiten: Di.–So.: 9 –22 Uhr, warme Küche von 11 bis 21 Uhr, Montag Ruhetag', null::jsonb, 2, null::jsonb, 3),
    ('lv3', '16', 'Text E: Liebe Kollegen, bitte haltet den Aufenthaltsraum sauber. Alle Abfälle bitte in den Mülleimer! Vielen Dank für euer Verständnis!', null::jsonb, 2, null::jsonb, 4),
    ('hv1', '17', 'Text 1', null::jsonb, 2, null::jsonb, 0),
    ('hv1', '18', 'Text 2', null::jsonb, 2, null::jsonb, 1),
    ('hv1', '19', 'Text 3', null::jsonb, 2, null::jsonb, 2),
    ('hv1', '20', 'Text 4', null::jsonb, 2, null::jsonb, 3),
    ('hv1', '21', 'Text 5', null::jsonb, 2, null::jsonb, 4),
    ('hv2', '22', 'Füllen Sie die wichtigsten Informationen in die Notizen ein:', null::jsonb, 0, '{"points": ["Wann (Wochentag): Samstag / Sa(.)", "Datum: 14(.) Februar", "Uhrzeit: 19 / 7 Uhr", "Wo: Römergasse 8", "Telefonnummer: 4682146"]}'::jsonb, 0),
    ('hv3', '23', 'Text 1: Was essen Sie am liebsten?', '[{"key": "A", "text": "Schokolade"}, {"key": "B", "text": "Käse"}, {"key": "C", "text": "Brot"}, {"key": "D", "text": "Nudeln & Teigwaren"}]'::jsonb, 2, null::jsonb, 0),
    ('hv3', '24', 'Text 2: Was essen Sie am liebsten?', '[{"key": "A", "text": "Schokolade"}, {"key": "B", "text": "Käse"}, {"key": "C", "text": "Brot"}, {"key": "D", "text": "Nudeln & Teigwaren"}]'::jsonb, 2, null::jsonb, 1),
    ('hv3', '25', 'Text 3: Was essen Sie am liebsten?', '[{"key": "A", "text": "Schokolade"}, {"key": "B", "text": "Käse"}, {"key": "C", "text": "Brot"}, {"key": "D", "text": "Nudeln & Teigwaren"}]'::jsonb, 2, null::jsonb, 2),
    ('hv3', '26', 'Text 4: Was essen Sie am liebsten?', '[{"key": "A", "text": "Schokolade"}, {"key": "B", "text": "Käse"}, {"key": "C", "text": "Brot"}, {"key": "D", "text": "Nudeln & Teigwaren"}]'::jsonb, 2, null::jsonb, 3),
    ('hv3', '27', 'Text 5: Was essen Sie am liebsten?', '[{"key": "A", "text": "Schokolade"}, {"key": "B", "text": "Käse"}, {"key": "C", "text": "Brot"}, {"key": "D", "text": "Nudeln & Teigwaren"}]'::jsonb, 2, null::jsonb, 4),
    ('s1', '28', 'Schreiben Sie die fünf fehlenden Informationen in das Formular:', null::jsonb, 0, '{"points": ["(1) Anzahl der Personen: 4 / vier", "(2) Davon Kinder: 2 / zwei", "(3) Urlaubsort: Seeheim", "(4) Zahlungsweise: Bar", "(5) Reisetermin: nächsten Sonntag / Sonntag"]}'::jsonb, 0),
    ('s2', '29', 'Antworten Sie Matthias (mindestens 30 Wörter):', null::jsonb, 0, '{"minWords": 30, "points": ["Welche Sportart möchtest du gerne machen?", "Was brauchen wir?", "An welchem Tag hast du Zeit?", "Gruß am Ende"]}'::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'oesd-a1' and t.slug = 'modell-04'
join sections s on s.test_id = t.id and s.section_id = v.section_id
on conflict (section_id, item_id) do update set text = excluded.text, options = excluded.options, points = excluded.points, meta = excluded.meta, sort = excluded.sort;

insert into item_answers (item_id, answer, explanation)
select i.id, v.answer, v.explanation
from (values
    ('lv1', '1', '5', null),
    ('lv1', '2', '4', null),
    ('lv1', '3', '6', null),
    ('lv1', '4', '3', null),
    ('lv1', '5', '1', null),
    ('lv2', '6', 'A', null),
    ('lv2', '7', 'B', null),
    ('lv2', '8', 'A', null),
    ('lv2', '9', 'A', null),
    ('lv2', '10', 'B', null),
    ('lv2', '11', 'A', null),
    ('lv3', '12', '3', null),
    ('lv3', '13', '1', null),
    ('lv3', '14', '5', null),
    ('lv3', '15', '4', null),
    ('lv3', '16', '6', null),
    ('hv1', '17', 'F', null),
    ('hv1', '18', 'D', null),
    ('hv1', '19', 'B', null),
    ('hv1', '20', 'A', null),
    ('hv1', '21', 'E', null),
    ('hv3', '23', 'B', null),
    ('hv3', '24', 'A', null),
    ('hv3', '25', 'C', null),
    ('hv3', '26', 'B', null),
    ('hv3', '27', 'D', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'oesd-a1' and t.slug = 'modell-04'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;

-- ================= modell-05 · METIN =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('oesd-a1', 'modell-05', 'METIN', '29 Aufgaben · 55 Minuten',
        '[{"id": "block-lesen", "parts": ["lv1", "lv2", "lv3"], "title": "Lesen", "minutes": 25, "hint": "Aufgaben 1–16", "maxPoints": 30, "availablePoints": 30, "missing": 0}, {"id": "block-hoeren", "parts": ["hv1", "hv2", "hv3"], "title": "Hören", "minutes": 10, "hint": "Aufgaben 17–27", "maxPoints": 30, "availablePoints": 30, "missing": 0}, {"id": "block-schreiben", "parts": ["s1", "s2"], "title": "Schreiben", "minutes": 20, "hint": "Aufgaben 28–29", "maxPoints": 20, "availablePoints": 20, "missing": 0}]'::jsonb, 29, true, 5)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('lv1', 'Lesen', 'Lesen, Teil 1', 10, 'Finden Sie zu jeder Situation auf Blatt 1 (Situation A–E) die passende Anzeige auf Blatt 2 (Anzeige Nr. 1–6). Eine Anzeige ist zu viel.', 'matching', '{"bank": [{"key": "1", "text": "GLOBAL UNION: Geldtransfer in alle Länder. Barauszahlung in wenigen Minuten. Gebühren für Überweisungen in die Türkei: bis € 50: € 4,90; € 51 bis € 100: € 6,90. www.globalunion.at"}, {"key": "2", "text": "Oma/Opa-Projekt: Wir lernen mit dir am Nachmittag in deiner Schule. derverein@nl40.at, 0699/1123 8004"}, {"key": "3", "text": "Hals-Nasen-Ohren-Arzt Dr. Claudia Setz: Ordinationszeiten Mo: 10:00–13:00, Mi: 15:00–17:00, Do: 15:00–19:00. Telefon: 01 / 26 23 71 7, Schloßhoferstraße 38/1, 1210 Wien"}, {"key": "4", "text": "Papier & Buch Heyner: Sommeraktionen. alles zum Schulanfang für wenig Geld, 10% auf vegetarische Kochbücher, Hörbücher in verschiedenen Sprachen ab 5 €. Getreidegasse 102, 5020 Salzburg"}, {"key": "5", "text": "SPRACHINSTITUT NEUNER: WIR BIETEN: Kurse in kleinen Gruppen, Niveau A1–C2, aktuelle Materialien. KURSZEITEN: Mo–Fr, 8:30–11:30 Uhr oder 13:00–16:00 Uhr. INFORMATION: info@neuner.at"}, {"key": "6", "text": "Wir brauchen für die Mittagszeit Hilfe in der Küche: Mo, Mi, Fr: 11–14 Uhr, gute Bezahlung. Restaurant „Zum Alpenkönig“, Dorfgasse 12, 6020 Innsbruck"}], "bankTitle": "Anzeigen", "bankImage": "img/oesd-a1-m05-lv1.jpg", "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 2}'::jsonb, 0),
    ('lv2', 'Lesen', 'Lesen, Teil 2', 10, 'Sie lesen drei Anzeigen. Dazu gibt es je 2 Fragen. Antworten Sie mit JA oder NEIN.', 'mc', '{"passages": [{"paragraphs": [{"t": "Achtung!", "b": true}, {"t": "Ihr Deutschkurs fängt erst nächste Woche an. Die Trainerin ist krank.", "b": false}, {"t": "Erster Kurstag: Montag, 13. September", "b": false}, {"t": "Bücher bitte vor dem Kurs im Büro abholen.", "b": false}, {"t": "Informationen telefonisch: 02742/328 oder im Internet: www.vhs-noe.at", "b": false}]}], "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 1.67}'::jsonb, 1),
    ('lv3', 'Lesen', 'Lesen, Teil 3', 5, 'Sie lesen hier 5 kurze Texte (Text A–E). Zu jedem Text gibt es ein Bild (Bild 1–6). Welches Bild passt zu welchem Text? Ein Bild ist zu viel.', 'matching', '{"bank": [{"key": "1", "text": "Bild 1"}, {"key": "2", "text": "Bild 2"}, {"key": "3", "text": "Bild 3"}, {"key": "4", "text": "Bild 4"}, {"key": "5", "text": "Bild 5"}, {"key": "6", "text": "Bild 6"}], "bankTitle": "Bilder", "bankImage": "img/oesd-a1-m05-lv3.jpg", "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 2}'::jsonb, 2),
    ('hv1', 'Hören', 'Hören, Teil 1', 4, 'Sie hören fünf verschiedene Texte zu den Fotos. Welcher Text passt zu welchem Foto? Ein Bild ist zu viel.', 'matching', '{"bank": [{"key": "A", "text": "Foto A"}, {"key": "B", "text": "Foto B"}, {"key": "C", "text": "Foto C"}, {"key": "D", "text": "Foto D"}, {"key": "E", "text": "Foto E"}, {"key": "F", "text": "Foto F"}], "bankTitle": "Fotos", "bankImage": "img/oesd-a1-m05-hv1.jpg", "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 2}'::jsonb, 3),
    ('hv2', 'Hören', 'Hören, Teil 2 (Telefonnotiz)', 3, 'Sie hören eine Nachricht. Hören Sie gut zu und schreiben Sie die wichtigsten Informationen auf das Notizblatt. Sie hören den Text zwei Mal.', 'writing', '{"passages": [{"paragraphs": [{"t": "Notizen: Wohnung anschauen", "b": true}, {"t": "Was: Wohnung anschauen", "b": false}, {"t": "Wann: am ............................, den ............................ März, um ............................ Uhr", "b": false}, {"t": "Wo: ............................straße 68", "b": false}, {"t": "Telefonnummer: 0650/ ............................", "b": false}]}], "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 10}'::jsonb, 4),
    ('hv3', 'Hören', 'Hören, Teil 3', 3, 'Sie hören jetzt 5 Personen, die befragt werden: „Wo möchten Sie am liebsten arbeiten?“ Kreuzen Sie die richtige Antwort an. Pro Person gibt es nur eine Antwort.', 'mc', '{"maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 2}'::jsonb, 5),
    ('s1', 'Schreiben', 'Schreiben, Teil 1 (Formular)', 10, 'Helfen Sie Ihrer Freundin und füllen Sie das Formular aus.', 'writing', '{"passages": [{"paragraphs": [{"t": "Ihre Freundin, Kristina Pinnow, möchte ihren Sohn Oleg beim Sportverein TGB anmelden. Oleg ist 12 Jahre alt und möchte Fußball spielen. Familie Pinnow wohnt in 60385 Frankfurt, in der Leibnitzstraße 35. Frau Pinnow möchte den Mitgliedsbeitrag alle drei Monate überweisen.", "b": false}, {"t": "Sportverein TGB – ANMELDUNG", "b": true}, {"t": "(0) Name des Kindes: Pinnow", "b": false}, {"t": "(1) Vorname des Kindes: ............................", "b": false}, {"t": "Straße: Leibnitzstraße 35", "b": false}, {"t": "PLZ/Ort: 60385 Frankfurt", "b": false}, {"t": "Alter: 12 Jahre", "b": false}, {"t": "(2) Geschlecht: [ ] männlich | [ ] weiblich", "b": false}, {"t": "(3) Interessen: ............................", "b": false}, {"t": "Monatsbeitrag: [ ] Kinder bis 12 Jahre 5 € | [ ] Kinder von 13–18 Jahren 8 €", "b": false}, {"t": "(4) Monatsbeitrag: ............................", "b": false}, {"t": "zahlbar durch Abbuchung von Konto 315560-606 bei der Postbank Frankfurt BLZ 500 100 60", "b": false}, {"t": "(5) Zahlungsweise: [ ] monatlich | [ ] vierteljährlich | [ ] halbjährlich", "b": false}]}], "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 10}'::jsonb, 6),
    ('s2', 'Schreiben', 'Schreiben, Teil 2 (E-Mail)', 10, 'In einer Woche ist Ihr Deutschkurs zu Ende. Von Ihrem Kollegen Metin bekommen Sie folgendes E-Mail. Antworten Sie Metin. Schreiben Sie circa 30 Wörter. Beantworten Sie alle Fragen und schreiben Sie am Ende einen Gruß.', 'writing', '{"passages": [{"paragraphs": [{"t": "Gartenparty", "b": true}, {"t": "Hallo!", "b": false}, {"t": "In einer Woche ist unser Deutschkurs zu Ende. Wir können am letzten Kurstag eine Party mit Picknick im Garten unserer Schule machen. Und vielleicht geben wir unserer Lehrerin ein Geschenk.", "b": false}, {"t": "Was kannst du am letzten Kurstag zum Essen und Trinken mitbringen? Was geben wir unserer Lehrerin? Was können wir nach dem Essen noch machen?", "b": false}, {"t": "Liebe Grüße", "b": false}, {"t": "Metin", "b": false}]}], "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 10}'::jsonb, 7)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'oesd-a1' and t.slug = 'modell-05'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('lv1', '1', 'Situation A: Ihr Sohn hat Probleme in Mathematik. Er muss rechnen üben und braucht Hilfe.', null::jsonb, 2, null::jsonb, 0),
    ('lv1', '2', 'Situation B: Sie suchen einen Job. Sie können gut kochen.', null::jsonb, 2, null::jsonb, 1),
    ('lv1', '3', 'Situation C: Sie hören seit zwei Tagen nicht gut. Sie möchten einen Hörtest machen.', null::jsonb, 2, null::jsonb, 2),
    ('lv1', '4', 'Situation D: Ihre Familie lebt in einem anderen Land. Sie möchten Geld schicken.', null::jsonb, 2, null::jsonb, 3),
    ('lv1', '5', 'Situation E: Sie möchten in einer Sprachschule Deutsch lernen. Sie haben nur am Nachmittag Zeit.', null::jsonb, 2, null::jsonb, 4),
    ('lv2', '6', 'Bekommt man die Bücher im Kurs?', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 0),
    ('lv2', '7', 'Kann man in der Schule anrufen? Text: **Internationaler Abend** Orientalische Musik hören, zu afrikanischen Rhythmen tanzen, Essen aus Österreich genießen. Bei uns treffen sich Kulturen aus aller Welt. Samstag, 27. Juli, ab 20:00 Uhr im Vereinstreff Leopoldsdorf Eintritt: 2 Euro Aufgaben:', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 1),
    ('lv2', '8', 'Gibt es bei der Party Musik aus Afrika?', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 2),
    ('lv2', '9', 'Muss man für die Party etwas bezahlen? Text: **Service-Hotline** Ist Ihr Kühlschrank kaputt? Dann rufen Sie uns bitte an. Wir helfen Ihnen gerne und sind von 6 bis 22 Uhr für Sie da. Tel.: 0800 100 107 Garantie auf Neugeräte: 2 Jahre Aufgaben:', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 3),
    ('lv2', '10', 'Kann man bei Problemen mit dem Herd Hilfe bekommen?', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 4),
    ('lv2', '11', 'Kann man auch am Abend anrufen?', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 5),
    ('lv3', '12', 'Text A: Bitte beachten Sie, dass das Fußballspielen auf den Rasenflächen des Parks verboten ist!', null::jsonb, 2, null::jsonb, 0),
    ('lv3', '13', 'Text B: Kommen Sie zum Buchklub: Wir lesen jeden Monat zusammen ein neues Buch und sprechen darüber. Montags nach dem Deutschkurs, Raum 34.2', null::jsonb, 2, null::jsonb, 1),
    ('lv3', '14', 'Text C: Schlüssel verloren? Schloss kaputt? Ihr Schlüsseldienst kommt sofort! Rufen Sie uns an: 01 430 25 25. Wir öffnen Ihre Tür für Sie.', null::jsonb, 2, null::jsonb, 2),
    ('lv3', '15', 'Text D: Sie dürfen hier NICHT HALTEN oder PARKEN! Parkende Autos werden abgeschleppt!', null::jsonb, 2, null::jsonb, 3),
    ('lv3', '16', 'Text E: Willkommen im Tierpark Herberstein: Über 600 Tiere, viel Natur, alte Bäume ... Mai bis September 9–17 Uhr, www.tierwelt-herberstein.at', null::jsonb, 2, null::jsonb, 4),
    ('hv1', '17', 'Text 1', null::jsonb, 2, null::jsonb, 0),
    ('hv1', '18', 'Text 2', null::jsonb, 2, null::jsonb, 1),
    ('hv1', '19', 'Text 3', null::jsonb, 2, null::jsonb, 2),
    ('hv1', '20', 'Text 4', null::jsonb, 2, null::jsonb, 3),
    ('hv1', '21', 'Text 5', null::jsonb, 2, null::jsonb, 4),
    ('hv2', '22', 'Füllen Sie die wichtigsten Informationen in die Notizen ein:', null::jsonb, 0, '{"points": ["Wann (Wochentag): Mittwoch / Mi.", "Datum: 31. März", "Uhrzeit: 18 / 6 / sechs Uhr", "Wo: Ritterstraße 68", "Telefonnummer: 4986735"]}'::jsonb, 0),
    ('hv3', '23', 'Text 1: Wo möchten Sie am liebsten arbeiten?', '[{"key": "A", "text": "im Büro"}, {"key": "B", "text": "im Supermarkt"}, {"key": "C", "text": "im Wald"}, {"key": "D", "text": "im Restaurant"}]'::jsonb, 2, null::jsonb, 0),
    ('hv3', '24', 'Text 2: Wo möchten Sie am liebsten arbeiten?', '[{"key": "A", "text": "im Büro"}, {"key": "B", "text": "im Supermarkt"}, {"key": "C", "text": "im Wald"}, {"key": "D", "text": "im Restaurant"}]'::jsonb, 2, null::jsonb, 1),
    ('hv3', '25', 'Text 3: Wo möchten Sie am liebsten arbeiten?', '[{"key": "A", "text": "im Büro"}, {"key": "B", "text": "im Supermarkt"}, {"key": "C", "text": "im Wald"}, {"key": "D", "text": "im Restaurant"}]'::jsonb, 2, null::jsonb, 2),
    ('hv3', '26', 'Text 4: Wo möchten Sie am liebsten arbeiten?', '[{"key": "A", "text": "im Büro"}, {"key": "B", "text": "im Supermarkt"}, {"key": "C", "text": "im Wald"}, {"key": "D", "text": "im Restaurant"}]'::jsonb, 2, null::jsonb, 3),
    ('hv3', '27', 'Text 5: Wo möchten Sie am liebsten arbeiten?', '[{"key": "A", "text": "im Büro"}, {"key": "B", "text": "im Supermarkt"}, {"key": "C", "text": "im Wald"}, {"key": "D", "text": "im Restaurant"}]'::jsonb, 2, null::jsonb, 4),
    ('s1', '28', 'Schreiben Sie die fünf fehlenden Informationen in das Formular:', null::jsonb, 0, '{"points": ["(1) Vorname des Kindes: Oleg", "(2) Geschlecht: männlich", "(3) Interessen: Fußball / Fussball", "(4) Monatsbeitrag: 5 € / 5 Euro", "(5) Zahlungsweise: vierteljährlich / alle drei Monate"]}'::jsonb, 0),
    ('s2', '29', 'Antworten Sie Metin (mindestens 30 Wörter):', null::jsonb, 0, '{"minWords": 30, "points": ["Was kannst du zum Essen und Trinken mitbringen?", "Was geben wir unserer Lehrerin?", "Was können wir nach dem Essen noch machen?", "Gruß am Ende"]}'::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'oesd-a1' and t.slug = 'modell-05'
join sections s on s.test_id = t.id and s.section_id = v.section_id
on conflict (section_id, item_id) do update set text = excluded.text, options = excluded.options, points = excluded.points, meta = excluded.meta, sort = excluded.sort;

insert into item_answers (item_id, answer, explanation)
select i.id, v.answer, v.explanation
from (values
    ('lv1', '1', '2', null),
    ('lv1', '2', '6', null),
    ('lv1', '3', '3', null),
    ('lv1', '4', '1', null),
    ('lv1', '5', '5', null),
    ('lv2', '6', 'B', null),
    ('lv2', '7', 'A', null),
    ('lv2', '8', 'A', null),
    ('lv2', '9', 'A', null),
    ('lv2', '10', 'B', null),
    ('lv2', '11', 'A', null),
    ('lv3', '12', '4', null),
    ('lv3', '13', '3', null),
    ('lv3', '14', '2', null),
    ('lv3', '15', '1', null),
    ('lv3', '16', '6', null),
    ('hv1', '17', 'C', null),
    ('hv1', '18', 'E', null),
    ('hv1', '19', 'A', null),
    ('hv1', '20', 'D', null),
    ('hv1', '21', 'F', null),
    ('hv3', '23', 'C', null),
    ('hv3', '24', 'A', null),
    ('hv3', '25', 'D', null),
    ('hv3', '26', 'B', null),
    ('hv3', '27', 'A', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'oesd-a1' and t.slug = 'modell-05'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;

-- ================= modell-06 · HERBERT =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('oesd-a1', 'modell-06', 'HERBERT', '29 Aufgaben · 55 Minuten',
        '[{"id": "block-lesen", "parts": ["lv1", "lv2", "lv3"], "title": "Lesen", "minutes": 25, "hint": "Aufgaben 1–16", "maxPoints": 30, "availablePoints": 30, "missing": 0}, {"id": "block-hoeren", "parts": ["hv1", "hv2", "hv3"], "title": "Hören", "minutes": 10, "hint": "Aufgaben 17–27", "maxPoints": 30, "availablePoints": 30, "missing": 0}, {"id": "block-schreiben", "parts": ["s1", "s2"], "title": "Schreiben", "minutes": 20, "hint": "Aufgaben 28–29", "maxPoints": 20, "availablePoints": 20, "missing": 0}]'::jsonb, 29, true, 6)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('lv1', 'Lesen', 'Lesen, Teil 1', 10, 'Finden Sie zu jeder Situation auf Blatt 1 (Situation A–E) die passende Anzeige auf Blatt 2 (Anzeige Nr. 1–6). Eine Anzeige ist zu viel.', 'matching', '{"bank": [{"key": "1", "text": "Zusammen macht es mehr Spaß: Unsere Gruppe trifft sich jeden Samstag zum Laufen, Schwimmen oder Radfahren. Möchtest du auch dabei sein? Ruf einfach an unter 03685/45875."}, {"key": "2", "text": "Zum Sonnengarten: Das Lokal für Groß und Klein. Bei uns gibt es: Kaffee und Kuchen, Frühstück, Mittagessen, einen Kindertisch zum Spielen und Malen. täglich geöffnet von 7 bis 15 Uhr"}, {"key": "3", "text": "Jetzt neu im „Schwarzen Adler“: Nudel- und Salatbuffet. Essen so viel Sie wollen! Erwachsene: € 15,-, Kinder: € 8,-. Jeden Tag von 17 bis 21 Uhr"}, {"key": "4", "text": "Sie mögen Hunde?: Möchten Sie zweimal am Tag mit meinem Hund spazieren gehen? Ich zahle 7 Euro pro Spaziergang. W. Huber: 0699/4585156"}, {"key": "5", "text": "Neueröffnung in Basel: Willkommen im „Prinz und Prinzessin“! Bei uns finden Sie alles für die Kleinen (0 bis 6 Jahre): Kinderwagen, Kleidung, Spielzeug. Kastelstrasse 17"}, {"key": "6", "text": "Einfach-Raus-Ticket: günstig Zugfahren für 2 bis 5 Personen, gültig jeden Tag in ganz Österreich, Nehmen Sie Ihr Fahrrad gratis mit! Tickets unter www.oebb.at oder direkt am Bahnhof"}], "bankTitle": "Anzeigen", "bankImage": "img/oesd-a1-m06-lv1.jpg", "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 2}'::jsonb, 0),
    ('lv2', 'Lesen', 'Lesen, Teil 2', 10, 'Sie lesen drei Anzeigen. Dazu gibt es je 2 Fragen. Antworten Sie mit JA oder NEIN.', 'mc', '{"passages": [{"paragraphs": [{"t": "Babysitter gesucht!", "b": true}, {"t": "Sie ...", "b": false}, {"t": "✿ lieben Kinder?", "b": false}, {"t": "✿ können Auto fahren?", "b": false}, {"t": "✿ sprechen gut Deutsch und Englisch?", "b": false}, {"t": "✿ haben von Samstag bis Mittwoch Zeit?", "b": false}, {"t": "Dann haben wir den richtigen Job für Sie!", "b": false}, {"t": "Fam. Moosburger", "b": false}, {"t": "gabriela.moosburger@yahoo.de", "b": false}]}], "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 1.67}'::jsonb, 1),
    ('lv3', 'Lesen', 'Lesen, Teil 3', 5, 'Sie lesen hier 5 kurze Texte (Text A–E). Zu jedem Text gibt es ein Bild (Bild 1–6). Welches Bild passt zu welchem Text? Ein Bild ist zu viel.', 'matching', '{"bank": [{"key": "1", "text": "Bild 1"}, {"key": "2", "text": "Bild 2"}, {"key": "3", "text": "Bild 3"}, {"key": "4", "text": "Bild 4"}, {"key": "5", "text": "Bild 5"}, {"key": "6", "text": "Bild 6"}], "bankTitle": "Bilder", "bankImage": "img/oesd-a1-m06-lv3.jpg", "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 2}'::jsonb, 2),
    ('hv1', 'Hören', 'Hören, Teil 1', 4, 'Sie hören fünf verschiedene Texte zu den Fotos. Welcher Text passt zu welchem Foto? Ein Bild ist zu viel.', 'matching', '{"bank": [{"key": "A", "text": "Foto A"}, {"key": "B", "text": "Foto B"}, {"key": "C", "text": "Foto C"}, {"key": "D", "text": "Foto D"}, {"key": "E", "text": "Foto E"}, {"key": "F", "text": "Foto F"}], "bankTitle": "Fotos", "bankImage": "img/oesd-a1-m06-hv1.jpg", "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 2}'::jsonb, 3),
    ('hv2', 'Hören', 'Hören, Teil 2 (Telefonnotiz)', 3, 'Sie hören eine Nachricht. Hören Sie gut zu und schreiben Sie die wichtigsten Informationen auf das Notizblatt. Sie hören den Text zwei Mal.', 'writing', '{"passages": [{"paragraphs": [{"t": "Notizen: Wandern in Tirol", "b": true}, {"t": "Was: Wandern in Tirol", "b": false}, {"t": "Abfahrt: am ............................, um ............................ Uhr", "b": false}, {"t": "Übernachten: Haus ............................", "b": false}, {"t": "Preis: ............................ Euro", "b": false}, {"t": "Telefonnummer: 0660/ ............................", "b": false}]}], "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 10}'::jsonb, 4),
    ('hv3', 'Hören', 'Hören, Teil 3', 3, 'Sie hören jetzt 5 Personen, die befragt werden: „Welchen Kurs möchten Sie gerne besuchen?“ Kreuzen Sie die richtige Antwort an. Pro Person gibt es nur eine Antwort.', 'mc', '{"maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 2}'::jsonb, 5),
    ('s1', 'Schreiben', 'Schreiben, Teil 1 (Formular)', 10, 'Sie möchten Informationen über ein Studium an der Universität Ihrer Heimatstadt bekommen. Dafür müssen Sie ein Formular ausfüllen. Bitte füllen Sie das Formular aus. Sie können die Antworten auch erfinden.', 'writing', '{"passages": [{"paragraphs": [{"t": "UNIVERSITÄT – FORMULAR", "b": true}, {"t": "Vorname(n): ............................", "b": false}, {"t": "Nachname(n): ............................", "b": false}, {"t": "Geburtsdatum: ............................", "b": false}, {"t": "Geburtsland: ............................", "b": false}, {"t": "E-Mail-Adresse: ............................", "b": false}, {"t": "Adresse (Straße + Nr.): ............................", "b": false}, {"t": "Postleitzahl + Ort: ............................", "b": false}, {"t": "Datum und Unterschrift: ............................", "b": false}]}], "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 10}'::jsonb, 6),
    ('s2', 'Schreiben', 'Schreiben, Teil 2 (E-Mail)', 10, 'Ihre Freundin Alma heiratet bald in Berlin. Sie und Ihr Freund Herbert sind zum Hochzeitsfest eingeladen. Sie bekommen folgendes E-Mail von Herbert. Antworten Sie Herbert. Schreiben Sie circa 30 Wörter. Beantworten Sie alle Fragen und schreiben Sie am Ende einen Gruß.', 'writing', '{"passages": [{"paragraphs": [{"t": "Hochzeit in Berlin", "b": true}, {"t": "Hallo!", "b": false}, {"t": "Ich freue mich schon sehr auf Almas Fest. Natürlich brauchen wir ein schönes Geschenk für sie. Hast du eine Idee? Wir können zusammen etwas für sie kaufen. Wann hast du Zeit zum Einkaufen? Und noch etwas: Wie kommen wir nach Berlin?", "b": false}, {"t": "Liebe Grüße", "b": false}, {"t": "Herbert", "b": false}]}], "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 10}'::jsonb, 7)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'oesd-a1' and t.slug = 'modell-06'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('lv1', '1', 'Situation A: Ihre Schwester hat ein Baby. Sie wollen ein Geschenk kaufen.', null::jsonb, 2, null::jsonb, 0),
    ('lv1', '2', 'Situation B: Sie wollen mit Ihrer Freundin einen Ausflug machen. Ihr Auto ist kaputt.', null::jsonb, 2, null::jsonb, 1),
    ('lv1', '3', 'Situation C: Ihr Freund möchte etwas Geld verdienen. Er liebt Tiere.', null::jsonb, 2, null::jsonb, 2),
    ('lv1', '4', 'Situation D: Sie möchten mit anderen Sport treiben und haben am Wochenende frei.', null::jsonb, 2, null::jsonb, 3),
    ('lv1', '5', 'Situation E: Ihr Bruder besucht Sie heute. Sie möchten am Abend essen gehen.', null::jsonb, 2, null::jsonb, 4),
    ('lv2', '6', 'Braucht man für die Stelle einen Führerschein?', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 0),
    ('lv2', '7', 'Muss man am Wochenende arbeiten? Text: **Haus mit Garten zu verkaufen!** Besichtigen möglich ab Donnerstag, 17.05., täglich zwischen 09:00 und 13:30 Uhr! Für weitere Informationen melden Sie sich bitte direkt bei Julia Berger. julia.berger@gmx.at 0664 / 8154026 (ab 12:30 Uhr) Aufgaben:', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 1),
    ('lv2', '8', 'Kann man das Haus Anfang Mai ansehen?', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 2),
    ('lv2', '9', 'Kann man Frau Berger am Vormittag anrufen? Text: **TIERPARK Beck in Hamburg** Nach der Winterpause sind wir endlich wieder für Sie da! Dienstag–Sonntag: 09–20 Uhr Unser Frühlings-Angebot im März: Von 02.03.–15.03. gibt es -25 % auf alle Eintrittskarten! www.tierpark-beck.de Aufgaben:', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 3),
    ('lv2', '10', 'Ist der Tierpark montags geöffnet?', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 4),
    ('lv2', '11', 'Sind die Tickets den ganzen März lang billiger?', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 5),
    ('lv3', '12', 'Text A: Liebe Eltern! Nehmen Sie kleine Kinder am Bahnsteig immer an die Hand!', null::jsonb, 2, null::jsonb, 0),
    ('lv3', '13', 'Text B: Mahlzeit! Wir kochen jeden Tag frisch und mit viel Liebe. Schauen Sie in unsere Speisekarte.', null::jsonb, 2, null::jsonb, 1),
    ('lv3', '14', 'Text C: Neues Angebot! Wir kommen zu Ihnen nach Hause und reparieren kaputte Kühlschränke und Waschmaschinen schnell und günstig. Tel.: 0676/4515845', null::jsonb, 2, null::jsonb, 2),
    ('lv3', '15', 'Text D: Liebe Besucherinnen und Besucher! Bitte benutzen Sie unsere Kästen. Im Schwimmbad sind Schuhe verboten.', null::jsonb, 2, null::jsonb, 3),
    ('lv3', '16', 'Text E: Wir kaufen und verkaufen Häuser in ganz Österreich. Für mehr Informationen besuchen Sie uns unter www.deinhaus.at.', null::jsonb, 2, null::jsonb, 4),
    ('hv1', '17', 'Text 1', null::jsonb, 2, null::jsonb, 0),
    ('hv1', '18', 'Text 2', null::jsonb, 2, null::jsonb, 1),
    ('hv1', '19', 'Text 3', null::jsonb, 2, null::jsonb, 2),
    ('hv1', '20', 'Text 4', null::jsonb, 2, null::jsonb, 3),
    ('hv1', '21', 'Text 5', null::jsonb, 2, null::jsonb, 4),
    ('hv2', '22', 'Füllen Sie die wichtigsten Informationen in die Notizen ein:', null::jsonb, 0, '{"points": ["Abfahrt (Wochentag): Samstag / Sa(.)", "Abfahrt (Uhrzeit): 06:30 / halb 7 / halb sieben Uhr", "Übernachten: Haus Gimpel", "Preis: 27 Euro", "Telefonnummer: 4189724"]}'::jsonb, 0),
    ('hv3', '23', 'Text 1: Welchen Kurs möchten Sie gerne besuchen?', '[{"key": "A", "text": "Sprachkurs"}, {"key": "B", "text": "Tanzkurs"}, {"key": "C", "text": "Computerkurs"}, {"key": "D", "text": "Kochkurs"}]'::jsonb, 2, null::jsonb, 0),
    ('hv3', '24', 'Text 2: Welchen Kurs möchten Sie gerne besuchen?', '[{"key": "A", "text": "Sprachkurs"}, {"key": "B", "text": "Tanzkurs"}, {"key": "C", "text": "Computerkurs"}, {"key": "D", "text": "Kochkurs"}]'::jsonb, 2, null::jsonb, 1),
    ('hv3', '25', 'Text 3: Welchen Kurs möchten Sie gerne besuchen?', '[{"key": "A", "text": "Sprachkurs"}, {"key": "B", "text": "Tanzkurs"}, {"key": "C", "text": "Computerkurs"}, {"key": "D", "text": "Kochkurs"}]'::jsonb, 2, null::jsonb, 2),
    ('hv3', '26', 'Text 4: Welchen Kurs möchten Sie gerne besuchen?', '[{"key": "A", "text": "Sprachkurs"}, {"key": "B", "text": "Tanzkurs"}, {"key": "C", "text": "Computerkurs"}, {"key": "D", "text": "Kochkurs"}]'::jsonb, 2, null::jsonb, 3),
    ('hv3', '27', 'Text 5: Welchen Kurs möchten Sie gerne besuchen?', '[{"key": "A", "text": "Sprachkurs"}, {"key": "B", "text": "Tanzkurs"}, {"key": "C", "text": "Computerkurs"}, {"key": "D", "text": "Kochkurs"}]'::jsonb, 2, null::jsonb, 4),
    ('s1', '28', 'Füllen Sie das Formular mit Ihren Angaben aus:', null::jsonb, 0, '{"points": ["Vorname(n) und Nachname(n)", "Geburtsdatum und Geburtsland", "E-Mail-Adresse", "Adresse (Straße + Nr., Postleitzahl + Ort)", "Datum und Unterschrift"]}'::jsonb, 0),
    ('s2', '29', 'Antworten Sie Herbert (mindestens 30 Wörter):', null::jsonb, 0, '{"minWords": 30, "points": ["Was kaufen wir für Alma? (Geschenkidee)", "Wann hast du Zeit zum Einkaufen?", "Wie kommen wir nach Berlin? (Verkehrsmittel)", "Gruß am Ende"]}'::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'oesd-a1' and t.slug = 'modell-06'
join sections s on s.test_id = t.id and s.section_id = v.section_id
on conflict (section_id, item_id) do update set text = excluded.text, options = excluded.options, points = excluded.points, meta = excluded.meta, sort = excluded.sort;

insert into item_answers (item_id, answer, explanation)
select i.id, v.answer, v.explanation
from (values
    ('lv1', '1', '5', null),
    ('lv1', '2', '6', null),
    ('lv1', '3', '4', null),
    ('lv1', '4', '1', null),
    ('lv1', '5', '3', null),
    ('lv2', '6', 'A', null),
    ('lv2', '7', 'A', null),
    ('lv2', '8', 'B', null),
    ('lv2', '9', 'B', null),
    ('lv2', '10', 'B', null),
    ('lv2', '11', 'B', null),
    ('lv3', '12', '4', null),
    ('lv3', '13', '6', null),
    ('lv3', '14', '5', null),
    ('lv3', '15', '1', null),
    ('lv3', '16', '3', null),
    ('hv1', '17', 'B', null),
    ('hv1', '18', 'D', null),
    ('hv1', '19', 'F', null),
    ('hv1', '20', 'A', null),
    ('hv1', '21', 'E', null),
    ('hv3', '23', 'C', null),
    ('hv3', '24', 'A', null),
    ('hv3', '25', 'B', null),
    ('hv3', '26', 'D', null),
    ('hv3', '27', 'A', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'oesd-a1' and t.slug = 'modell-06'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;

-- ================= modell-07 · HELENA =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('oesd-a1', 'modell-07', 'HELENA', '29 Aufgaben · 55 Minuten',
        '[{"id": "block-lesen", "parts": ["lv1", "lv2", "lv3"], "title": "Lesen", "minutes": 25, "hint": "Aufgaben 1–16", "maxPoints": 30, "availablePoints": 30, "missing": 0}, {"id": "block-hoeren", "parts": ["hv1", "hv2", "hv3"], "title": "Hören", "minutes": 10, "hint": "Aufgaben 17–27", "maxPoints": 30, "availablePoints": 30, "missing": 0}, {"id": "block-schreiben", "parts": ["s1", "s2"], "title": "Schreiben", "minutes": 20, "hint": "Aufgaben 28–29", "maxPoints": 20, "availablePoints": 20, "missing": 0}]'::jsonb, 29, true, 7)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('lv1', 'Lesen', 'Lesen, Teil 1', 10, 'Finden Sie zu jeder Situation auf Blatt 1 (Situation A–E) die passende Anzeige auf Blatt 2 (Anzeige Nr. 1–6). Eine Anzeige ist zu viel.', 'matching', '{"bank": [{"key": "1", "text": "Meyer & Loos: jetzt auch in der Schweiz! Viele Angebote erwarten Sie! -25% auf Möbel für Bad, Schlafzimmer und Wohnzimmer. Karweg 78, 1702 Freiburg, Mo–Sa 8:30 bis 19:30"}, {"key": "2", "text": "Einfach und leicht!: Egal, ob schnelles Frühstück oder leckeres Abendessen für den Geburtstag oder den Jahrestag. Bei uns finden Sie tolle Ideen und italienische Rezepte zum Nachkochen. www.speisenfuerzuhause.de"}, {"key": "3", "text": "Probleme beim Schreiben und Lesen?: Ich übe mit Ihrem Kind und komme auch gerne zu Ihnen nach Hause. Susanne (Germanistik-Studentin), 0660 / 6243258, 10 Euro / Stunde"}, {"key": "4", "text": "„Willst du dich um mich kümmern, mit mir spielen und viel spazieren gehen?“ Dann melde dich bei Thomas u. Isabella (0171-3642075). Ein kleines Hunde-Baby sucht ein nettes Zuhause!"}, {"key": "5", "text": "Sommer in Kärnten: Lernen Sie Englisch, Italienisch oder Slowenisch am wunderschönen Wörthersee! Vormittag: 09:00–12:00 Unterricht, Nachmittag: Freizeitprogramm mit Schwimmen, Klettern, Wandern u. v. m. sommerinkaernten@lingua.at"}, {"key": "6", "text": "Endlich ist es so weit! Star-Koch Julius Mayer hat sein erstes Restaurant in Wien eröffnet. Speisen aus aller Welt warten auf Sie. Burggasse 35, 1070 Wien, Mo–So 16:00 bis 24:00"}], "bankTitle": "Anzeigen", "bankImage": "img/oesd-a1-m07-lv1.jpg", "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 2}'::jsonb, 0),
    ('lv2', 'Lesen', 'Lesen, Teil 2', 10, 'Sie lesen drei Anzeigen. Dazu gibt es je 2 Fragen. Antworten Sie mit JA oder NEIN.', 'mc', '{"passages": [{"paragraphs": [{"t": "Gebrauchte Waschmaschine billig zu verkaufen!", "b": true}, {"t": "Ich habe sie seit 3 Jahren. Sie wäscht noch sehr gut.", "b": false}, {"t": "Rufen Sie mich gerne an – bitte erst ab 17 Uhr.", "b": false}, {"t": "Emma 0650/4585612", "b": false}]}], "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 1.67}'::jsonb, 1),
    ('lv3', 'Lesen', 'Lesen, Teil 3', 5, 'Sie lesen hier 5 kurze Texte (Text A–E). Zu jedem Text gibt es ein Bild (Bild 1–6). Welches Bild passt zu welchem Text? Ein Bild ist zu viel.', 'matching', '{"bank": [{"key": "1", "text": "Bild 1"}, {"key": "2", "text": "Bild 2"}, {"key": "3", "text": "Bild 3"}, {"key": "4", "text": "Bild 4"}, {"key": "5", "text": "Bild 5"}, {"key": "6", "text": "Bild 6"}], "bankTitle": "Bilder", "bankImage": "img/oesd-a1-m07-lv3.jpg", "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 2}'::jsonb, 2),
    ('hv1', 'Hören', 'Hören, Teil 1', 4, 'Sie hören fünf verschiedene Texte zu den Fotos. Welcher Text passt zu welchem Foto? Ein Bild ist zu viel.', 'matching', '{"bank": [{"key": "A", "text": "Foto A"}, {"key": "B", "text": "Foto B"}, {"key": "C", "text": "Foto C"}, {"key": "D", "text": "Foto D"}, {"key": "E", "text": "Foto E"}, {"key": "F", "text": "Foto F"}], "bankTitle": "Fotos", "bankImage": "img/oesd-a1-m07-hv1.jpg", "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 2}'::jsonb, 3),
    ('hv2', 'Hören', 'Hören, Teil 2 (Telefonnotiz)', 3, 'Sie hören eine Nachricht. Hören Sie gut zu und schreiben Sie die wichtigsten Informationen auf das Notizblatt. Sie hören den Text zwei Mal.', 'writing', '{"passages": [{"paragraphs": [{"t": "Notizen: ein Geschenk kaufen", "b": true}, {"t": "Was: ein Geschenk kaufen", "b": false}, {"t": "Wo: in der ............................straße 74", "b": false}, {"t": "Laden offen von 09:00 bis ............................ Uhr", "b": false}, {"t": "Wann: am ............................, dem ............................ Juli", "b": false}, {"t": "Herrn Wagners Nummer: 0660 / ............................", "b": false}]}], "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 10}'::jsonb, 4),
    ('hv3', 'Hören', 'Hören, Teil 3', 3, 'Sie hören jetzt 5 Personen, die befragt werden: „Welche Zeit im Jahr gefällt Ihnen am besten?“ Kreuzen Sie die richtige Antwort an. Pro Person gibt es nur eine Antwort.', 'mc', '{"maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 2}'::jsonb, 5),
    ('s1', 'Schreiben', 'Schreiben, Teil 1 (Formular)', 10, 'Sie interessieren sich für ein Praktikum bei einer Zeitung. Dafür müssen Sie ein Formular ausfüllen. Bitte füllen Sie das Formular aus. Sie können die Antworten auch erfinden.', 'writing', '{"passages": [{"paragraphs": [{"t": "PRAKTIKUM BEI DER ZEITUNG – FORMULAR", "b": true}, {"t": "Vorname(n): ............................", "b": false}, {"t": "Nachname(n): ............................", "b": false}, {"t": "Alter: ............................", "b": false}, {"t": "Geburtsland: ............................", "b": false}, {"t": "E-Mail-Adresse: ............................", "b": false}, {"t": "Adresse (Straße + Nr.): ............................", "b": false}, {"t": "Postleitzahl + Ort: ............................", "b": false}, {"t": "Datum und Unterschrift: ............................", "b": false}]}], "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 10}'::jsonb, 6),
    ('s2', 'Schreiben', 'Schreiben, Teil 2 (E-Mail)', 10, 'Ihre Freundin Helena will mit Ihnen zum Stadtfest gehen. Sie bekommen folgendes E-Mail von Helena. Antworten Sie Helena. Schreiben Sie circa 30 Wörter. Beantworten Sie alle Fragen und schreiben Sie am Ende einen Gruß.', 'writing', '{"passages": [{"paragraphs": [{"t": "Stadtfest", "b": true}, {"t": "Hallo!", "b": false}, {"t": "Nächste Woche ist von Freitag bis Sonntag ein großes Fest in unserer Stadt. Es dauert immer von 10 bis 15 Uhr. Ich möchte gerne mit dir zusammen hingehen.", "b": false}, {"t": "Bitte schreib mir: An welchem Tag kannst du zum Fest gehen? Wen möchtest du mitbringen? Und was willst du danach machen?", "b": false}, {"t": "Liebe Grüße", "b": false}, {"t": "Helena", "b": false}]}], "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 10}'::jsonb, 7)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'oesd-a1' and t.slug = 'modell-07'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('lv1', '1', 'Situation A: Ihr Hobby sind Sprachen. Sie möchten einen Kurs besuchen.', null::jsonb, 2, null::jsonb, 0),
    ('lv1', '2', 'Situation B: Sie ziehen um und suchen ein Sofa.', null::jsonb, 2, null::jsonb, 1),
    ('lv1', '3', 'Situation C: Ihre Frau hat eine neue Stelle. Sie wollen feiern und mit ihr essen gehen.', null::jsonb, 2, null::jsonb, 2),
    ('lv1', '4', 'Situation D: Ihr Sohn hat schlechte Noten in Deutsch. Er braucht Hilfe.', null::jsonb, 2, null::jsonb, 3),
    ('lv1', '5', 'Situation E: Ihre Tochter hat Geburtstag. Sie möchte ein Haustier haben.', null::jsonb, 2, null::jsonb, 4),
    ('lv2', '6', 'Ist die Waschmaschine neu?', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 0),
    ('lv2', '7', 'Hat Emma am Vormittag Zeit zum Telefonieren? Text: **Liebe Kunden, aktuell in unserem Supermarkt:** • Getränke 20 % billiger • Original Schweizer Käse um 10 Euro/Kilo • NEU: Blumen und Kräuter für Garten und Balkon Jetzt auch online einkaufen: www.kaufmarkt.de Aufgaben:', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 1),
    ('lv2', '8', 'Kostet Apfelsaft jetzt weniger?', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 2),
    ('lv2', '9', 'Gibt es im Supermarkt auch Pflanzen? Text: **Besuchen Sie Bern** Drei Nächte für 2 Personen im Gästehaus Andermatt um nur 300 Franken. • zentrale Lage • Tram-Haltestelle vor der Tür (fährt auch zum Bahnhof) • ohne Frühstück www.gaestehaus-andermatt.ch Aufgaben:', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 3),
    ('lv2', '10', 'Kommt man ohne Auto zum Hotel?', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 4),
    ('lv2', '11', 'Bekommt man morgens im Gästehaus etwas zu essen?', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 5),
    ('lv3', '12', 'Text A: Liebe Kolleginnen und Kollegen! Papier für den Drucker findet ihr im IT-Büro im 1. Stock.', null::jsonb, 2, null::jsonb, 0),
    ('lv3', '13', 'Text B: Sehr geehrte Kundinnen und Kunden! Kinder bis 12 Jahre dürfen den Aufzug nur zusammen mit einem Erwachsenen benutzen.', null::jsonb, 2, null::jsonb, 1),
    ('lv3', '14', 'Text C: Achtung: Im gesamten Park ist Grillen wegen akuter Brandgefahr verboten.', null::jsonb, 2, null::jsonb, 2),
    ('lv3', '15', 'Text D: Willkommen in unserem Schwimmbad! Bitte duschen Sie, bevor Sie ins Wasser gehen.', null::jsonb, 2, null::jsonb, 3),
    ('lv3', '16', 'Text E: Liebe Patientinnen und Patienten! Füllen Sie bitte das Formular aus und geben Sie es bei der Sekretärin ab.', null::jsonb, 2, null::jsonb, 4),
    ('hv1', '17', 'Text 1', null::jsonb, 2, null::jsonb, 0),
    ('hv1', '18', 'Text 2', null::jsonb, 2, null::jsonb, 1),
    ('hv1', '19', 'Text 3', null::jsonb, 2, null::jsonb, 2),
    ('hv1', '20', 'Text 4', null::jsonb, 2, null::jsonb, 3),
    ('hv1', '21', 'Text 5', null::jsonb, 2, null::jsonb, 4),
    ('hv2', '22', 'Füllen Sie die wichtigsten Informationen in die Notizen ein:', null::jsonb, 0, '{"points": ["Wo: Kapferstraße 74", "Laden offen bis: 16 / 4 / vier Uhr", "Wann (Wochentag): Freitag / Fr(.)", "Datum: 25. Juli", "Herrn Wagners Nummer: 8629801"]}'::jsonb, 0),
    ('hv3', '23', 'Text 1: Welche Zeit im Jahr gefällt Ihnen am besten?', '[{"key": "A", "text": "Frühling"}, {"key": "B", "text": "Sommer"}, {"key": "C", "text": "Herbst"}, {"key": "D", "text": "Winter"}]'::jsonb, 2, null::jsonb, 0),
    ('hv3', '24', 'Text 2: Welche Zeit im Jahr gefällt Ihnen am besten?', '[{"key": "A", "text": "Frühling"}, {"key": "B", "text": "Sommer"}, {"key": "C", "text": "Herbst"}, {"key": "D", "text": "Winter"}]'::jsonb, 2, null::jsonb, 1),
    ('hv3', '25', 'Text 3: Welche Zeit im Jahr gefällt Ihnen am besten?', '[{"key": "A", "text": "Frühling"}, {"key": "B", "text": "Sommer"}, {"key": "C", "text": "Herbst"}, {"key": "D", "text": "Winter"}]'::jsonb, 2, null::jsonb, 2),
    ('hv3', '26', 'Text 4: Welche Zeit im Jahr gefällt Ihnen am besten?', '[{"key": "A", "text": "Frühling"}, {"key": "B", "text": "Sommer"}, {"key": "C", "text": "Herbst"}, {"key": "D", "text": "Winter"}]'::jsonb, 2, null::jsonb, 3),
    ('hv3', '27', 'Text 5: Welche Zeit im Jahr gefällt Ihnen am besten?', '[{"key": "A", "text": "Frühling"}, {"key": "B", "text": "Sommer"}, {"key": "C", "text": "Herbst"}, {"key": "D", "text": "Winter"}]'::jsonb, 2, null::jsonb, 4),
    ('s1', '28', 'Füllen Sie das Formular mit Ihren Angaben aus:', null::jsonb, 0, '{"points": ["Vorname(n) und Nachname(n)", "Alter und Geburtsland", "E-Mail-Adresse", "Adresse (Straße + Nr., Postleitzahl + Ort)", "Datum und Unterschrift"]}'::jsonb, 0),
    ('s2', '29', 'Antworten Sie Helena (mindestens 30 Wörter):', null::jsonb, 0, '{"minWords": 30, "points": ["An welchem Tag kannst du zum Fest gehen?", "Wen möchtest du mitbringen?", "Was willst du danach machen?", "Gruß am Ende"]}'::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'oesd-a1' and t.slug = 'modell-07'
join sections s on s.test_id = t.id and s.section_id = v.section_id
on conflict (section_id, item_id) do update set text = excluded.text, options = excluded.options, points = excluded.points, meta = excluded.meta, sort = excluded.sort;

insert into item_answers (item_id, answer, explanation)
select i.id, v.answer, v.explanation
from (values
    ('lv1', '1', '5', null),
    ('lv1', '2', '1', null),
    ('lv1', '3', '6', null),
    ('lv1', '4', '3', null),
    ('lv1', '5', '4', null),
    ('lv2', '6', 'B', null),
    ('lv2', '7', 'B', null),
    ('lv2', '8', 'A', null),
    ('lv2', '9', 'A', null),
    ('lv2', '10', 'A', null),
    ('lv2', '11', 'B', null),
    ('lv3', '12', '4', null),
    ('lv3', '13', '6', null),
    ('lv3', '14', '1', null),
    ('lv3', '15', '5', null),
    ('lv3', '16', '3', null),
    ('hv1', '17', 'F', null),
    ('hv1', '18', 'E', null),
    ('hv1', '19', 'A', null),
    ('hv1', '20', 'D', null),
    ('hv1', '21', 'B', null),
    ('hv3', '23', 'B', null),
    ('hv3', '24', 'C', null),
    ('hv3', '25', 'D', null),
    ('hv3', '26', 'A', null),
    ('hv3', '27', 'B', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'oesd-a1' and t.slug = 'modell-07'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;

-- ================= modell-08 · MARCO =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('oesd-a1', 'modell-08', 'MARCO', '29 Aufgaben · 55 Minuten',
        '[{"id": "block-lesen", "parts": ["lv1", "lv2", "lv3"], "title": "Lesen", "minutes": 25, "hint": "Aufgaben 1–16", "maxPoints": 30, "availablePoints": 30, "missing": 0}, {"id": "block-hoeren", "parts": ["hv1", "hv2", "hv3"], "title": "Hören", "minutes": 10, "hint": "Aufgaben 17–27", "maxPoints": 30, "availablePoints": 30, "missing": 0}, {"id": "block-schreiben", "parts": ["s1", "s2"], "title": "Schreiben", "minutes": 20, "hint": "Aufgaben 28–29", "maxPoints": 20, "availablePoints": 20, "missing": 0}]'::jsonb, 29, true, 8)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('lv1', 'Lesen', 'Lesen, Teil 1', 10, 'Finden Sie zu jeder Situation auf Blatt 1 (Situation A–E) die passende Anzeige auf Blatt 2 (Anzeige Nr. 1–6). Eine Anzeige ist zu viel.', 'matching', '{"bank": [{"key": "1", "text": "E.M.N.I.N.S: Schubertgasse 23. Egal, ob für Sommer oder Winter. Kaufen Sie gebrauchte Damen- und Herrenkleidung und helfen Sie so unserer Umwelt! Wir sind auch online für Sie da. www.es-muss-nicht-immer-neu-sein.at"}, {"key": "2", "text": "22 m² großes WG-Zimmer in Gartenwohnung: Bist du ordentlich und willst mit zwei netten Sport-Studenten zusammenwohnen? Dann melde dich bei uns! Jana & Klaus, 0664/2276892"}, {"key": "3", "text": "Neueröffnung Mamidu: günstige Babykleidung und -spiele von guter Qualität; Café im 1. Stock lädt müde Mamis ein, auch mal eine Pause zu machen. Adlergasse 6, 6900 Bregenz"}, {"key": "4", "text": "Wir haben die besten Angebote!: Ausflugsziele und Termine, die schönsten Museen, Sehenswürdigkeiten, Restaurants, Hotels und vieles mehr mit nur einem Klick. www.urlaub-in-muenster.de"}, {"key": "5", "text": "WGM Wohnpark Grün: Sie wohnen wie auf dem Land und sind doch mitten im Zentrum von Zürich! Noch Wohnungen in allen Größen frei! www.makler-blume.ch, Tel. +4144 76294062"}, {"key": "6", "text": "Kaufen und verkaufen Sie bei uns alte Autos, Motorräder und auch Fahrräder – zum besten Preis in ganz Österreich. schnell und einfach, gratis Anzeige, Hilfe von Experten. www.verkaufundkauf.at"}], "bankTitle": "Anzeigen", "bankImage": "img/oesd-a1-m08-lv1.jpg", "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 2}'::jsonb, 0),
    ('lv2', 'Lesen', 'Lesen, Teil 2', 10, 'Sie lesen drei Anzeigen. Dazu gibt es je 2 Fragen. Antworten Sie mit JA oder NEIN.', 'mc', '{"passages": [{"paragraphs": [{"t": "NEUE DEUTSCHKURSE", "b": true}, {"t": "★ 1. bis 31. August", "b": false}, {"t": "★ Anmeldung: Mo.–Fr. 09:00–11:00 Uhr, im Zimmer 19 bei Frau Dorn", "b": false}, {"t": "★ Mitbringen: Reisepass, Führerschein o. Ä.", "b": false}, {"t": "★ Welcher Kurs ist der richtige? Online-Test: www.deutschmachtspass.at/kurse", "b": false}]}], "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 1.67}'::jsonb, 1),
    ('lv3', 'Lesen', 'Lesen, Teil 3', 5, 'Sie lesen hier 5 kurze Texte (Text A–E). Zu jedem Text gibt es ein Bild (Bild 1–6). Welches Bild passt zu welchem Text? Ein Bild ist zu viel.', 'matching', '{"bank": [{"key": "1", "text": "Bild 1"}, {"key": "2", "text": "Bild 2"}, {"key": "3", "text": "Bild 3"}, {"key": "4", "text": "Bild 4"}, {"key": "5", "text": "Bild 5"}, {"key": "6", "text": "Bild 6"}], "bankTitle": "Bilder", "bankImage": "img/oesd-a1-m08-lv3.jpg", "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 2}'::jsonb, 2),
    ('hv1', 'Hören', 'Hören, Teil 1', 4, 'Sie hören fünf verschiedene Texte zu den Fotos. Welcher Text passt zu welchem Foto? Ein Bild ist zu viel.', 'matching', '{"bank": [{"key": "A", "text": "Foto A"}, {"key": "B", "text": "Foto B"}, {"key": "C", "text": "Foto C"}, {"key": "D", "text": "Foto D"}, {"key": "E", "text": "Foto E"}, {"key": "F", "text": "Foto F"}], "bankTitle": "Fotos", "bankImage": "img/oesd-a1-m08-hv1.jpg", "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 2}'::jsonb, 3),
    ('hv2', 'Hören', 'Hören, Teil 2 (Telefonnotiz)', 3, 'Sie hören eine Nachricht. Hören Sie gut zu und schreiben Sie die wichtigsten Informationen auf das Notizblatt. Sie hören den Text zwei Mal.', 'writing', '{"passages": [{"paragraphs": [{"t": "Notizen: Treffen im neuen Frühstücks-Lokal", "b": true}, {"t": "Treffen im neuen Frühstücks-Lokal", "b": false}, {"t": "Wann: am ............................, um ............................ Uhr", "b": false}, {"t": "Lokal heißt: ............................", "b": false}, {"t": "Adresse: Wagnergasse ............................", "b": false}, {"t": "Lauras Nummer: 0676 / ............................", "b": false}]}], "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 10}'::jsonb, 4),
    ('hv3', 'Hören', 'Hören, Teil 3', 3, 'Sie hören jetzt 5 Personen, die befragt werden: „Was gefällt Ihnen an Deutschland am besten?“ Kreuzen Sie die richtige Antwort an. Pro Person gibt es nur eine Antwort.', 'mc', '{"maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 2}'::jsonb, 5),
    ('s1', 'Schreiben', 'Schreiben, Teil 1 (Formular)', 10, 'Sie möchten sich bei einem Wanderverein anmelden. Dafür müssen Sie ein Formular ausfüllen. Bitte füllen Sie das Formular aus. Sie können die Antworten auch erfinden.', 'writing', '{"passages": [{"paragraphs": [{"t": "WANDERVEREIN – FORMULAR", "b": true}, {"t": "Vorname(n): ............................", "b": false}, {"t": "Nachname(n): ............................", "b": false}, {"t": "Alter: ............................", "b": false}, {"t": "E-Mail-Adresse: ............................", "b": false}, {"t": "Adresse (Straße + Nr.): ............................", "b": false}, {"t": "Postleitzahl + Ort: ............................", "b": false}, {"t": "Telefonnummer: ............................", "b": false}, {"t": "Datum und Unterschrift: ............................", "b": false}]}], "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 10}'::jsonb, 6),
    ('s2', 'Schreiben', 'Schreiben, Teil 2 (E-Mail)', 10, 'Sie haben eine neue Wohnung gefunden und ziehen bald um. Ein Freund möchte Ihnen helfen. Sie bekommen folgendes E-Mail von ihm. Antworten Sie Marco. Schreiben Sie circa 30 Wörter. Beantworten Sie alle Fragen und schreiben Sie am Ende einen Gruß.', 'writing', '{"passages": [{"paragraphs": [{"t": "Neue Wohnung", "b": true}, {"t": "Hallo!", "b": false}, {"t": "Schön, dass du endlich eine neue Wohnung gefunden hast! Ich hoffe, sie gefällt dir. Erzähl mir: Wie ist deine neue Wohnung? Und wann ziehst du um? Ich helfe dir gerne. Es gibt bestimmt viel zu tun. Bitte schreib mir, wie ich zu deiner neuen Wohnung komme.", "b": false}, {"t": "Liebe Grüße", "b": false}, {"t": "Marco", "b": false}]}], "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 10}'::jsonb, 7)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'oesd-a1' and t.slug = 'modell-08'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('lv1', '1', 'Situation A: Sie sind kulturell interessiert und brauchen Informationen für Ihre nächste Reise.', null::jsonb, 2, null::jsonb, 0),
    ('lv1', '2', 'Situation B: Sie wollen mehr Sport machen und suchen ein billiges Rad.', null::jsonb, 2, null::jsonb, 1),
    ('lv1', '3', 'Situation C: Ihre Freundin bekommt eine Tochter. Sie möchten dem kleinen Mädchen ein Geschenk kaufen.', null::jsonb, 2, null::jsonb, 2),
    ('lv1', '4', 'Situation D: Sie möchten umziehen und alleine leben.', null::jsonb, 2, null::jsonb, 3),
    ('lv1', '5', 'Situation E: Es wird kalt. Sie wollen eine Jacke im Internet bestellen.', null::jsonb, 2, null::jsonb, 4),
    ('lv2', '6', 'Kann man sich im Internet für den Deutschkurs anmelden?', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 0),
    ('lv2', '7', 'Braucht man bei Frau Dorn einen Ausweis? Text: **Wald-Fest** Freitag: Beginn um 20:00 Uhr mit DJ Ron Samstag: Live-Musik ab 11:00 Uhr, -50 % auf Ihr erstes Getränk (bis 15:00 Uhr) Samstag und Sonntag: Spaß und Spiele für kleine Gäste ab 4 Jahren (bis 15:00 Uhr) Aufgaben:', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 1),
    ('lv2', '8', 'Sind Getränke am Samstagabend billiger?', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 2),
    ('lv2', '9', 'Gibt es am Wochenende ein Kinderprogramm? Text: **Jumping Fitness-Kurs – Trainieren Sie 300 Muskeln auf einmal!** Dienstag bis Donnerstag und Samstag 9–10:30 Uhr Hubertstraße 87, 28757 Bremen Direkt bar im Kurs bezahlen. Die erste Stunde kostet nichts! www.jumpingfitness.de Aufgaben:', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 3),
    ('lv2', '10', 'Ist der Kurs am Mittwoch?', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 4),
    ('lv2', '11', 'Kann man das Geld für den Kurs überweisen?', '[{"key": "A", "text": "JA"}, {"key": "B", "text": "NEIN"}]'::jsonb, 1.67, null::jsonb, 5),
    ('lv3', '12', 'Text A: Probleme? Ruf uns an! Wir hören dir zu! Wir reden mit dir! 24 Stunden täglich, 0800 777 383', null::jsonb, 2, null::jsonb, 0),
    ('lv3', '13', 'Text B: Liebe Gäste! Sie können Speisen und Getränke auch mit Kreditkarte bezahlen.', null::jsonb, 2, null::jsonb, 1),
    ('lv3', '14', 'Text C: Abgedreht! Ab sofort sind Handys an dieser Schule nicht erlaubt!', null::jsonb, 2, null::jsonb, 2),
    ('lv3', '15', 'Text D: Nicht nur wir Menschen brauchen Wasser – auch Ihre Blumen haben Durst! Im Sommer tägliches Gießen nicht vergessen! Ihr „Flora-Fauna“-Team', null::jsonb, 2, null::jsonb, 3),
    ('lv3', '16', 'Text E: Willkommen im Kindergarten Sonne! Spiel und Spaß für kleine und große Kinder!', null::jsonb, 2, null::jsonb, 4),
    ('hv1', '17', 'Text 1', null::jsonb, 2, null::jsonb, 0),
    ('hv1', '18', 'Text 2', null::jsonb, 2, null::jsonb, 1),
    ('hv1', '19', 'Text 3', null::jsonb, 2, null::jsonb, 2),
    ('hv1', '20', 'Text 4', null::jsonb, 2, null::jsonb, 3),
    ('hv1', '21', 'Text 5', null::jsonb, 2, null::jsonb, 4),
    ('hv2', '22', 'Füllen Sie die wichtigsten Informationen in die Notizen ein:', null::jsonb, 0, '{"points": ["Wann (Wochentag): Dienstag / Di(.)", "Uhrzeit: 09:30 / halb 10 / halb zehn Uhr", "Lokal heißt: Artner", "Adresse: Wagnergasse 14", "Lauras Nummer: 1756293"]}'::jsonb, 0),
    ('hv3', '23', 'Text 1: Was gefällt Ihnen an Deutschland am besten?', '[{"key": "A", "text": "Essen"}, {"key": "B", "text": "Menschen"}, {"key": "C", "text": "Städte"}, {"key": "D", "text": "Natur"}]'::jsonb, 2, null::jsonb, 0),
    ('hv3', '24', 'Text 2: Was gefällt Ihnen an Deutschland am besten?', '[{"key": "A", "text": "Essen"}, {"key": "B", "text": "Menschen"}, {"key": "C", "text": "Städte"}, {"key": "D", "text": "Natur"}]'::jsonb, 2, null::jsonb, 1),
    ('hv3', '25', 'Text 3: Was gefällt Ihnen an Deutschland am besten?', '[{"key": "A", "text": "Essen"}, {"key": "B", "text": "Menschen"}, {"key": "C", "text": "Städte"}, {"key": "D", "text": "Natur"}]'::jsonb, 2, null::jsonb, 2),
    ('hv3', '26', 'Text 4: Was gefällt Ihnen an Deutschland am besten?', '[{"key": "A", "text": "Essen"}, {"key": "B", "text": "Menschen"}, {"key": "C", "text": "Städte"}, {"key": "D", "text": "Natur"}]'::jsonb, 2, null::jsonb, 3),
    ('hv3', '27', 'Text 5: Was gefällt Ihnen an Deutschland am besten?', '[{"key": "A", "text": "Essen"}, {"key": "B", "text": "Menschen"}, {"key": "C", "text": "Städte"}, {"key": "D", "text": "Natur"}]'::jsonb, 2, null::jsonb, 4),
    ('s1', '28', 'Füllen Sie das Formular mit Ihren Angaben aus:', null::jsonb, 0, '{"points": ["Vorname(n) und Nachname(n)", "Alter und E-Mail-Adresse", "Adresse (Straße + Nr., Postleitzahl + Ort)", "Telefonnummer", "Datum und Unterschrift"]}'::jsonb, 0),
    ('s2', '29', 'Antworten Sie Marco (mindestens 30 Wörter):', null::jsonb, 0, '{"minWords": 30, "points": ["Wie ist deine neue Wohnung?", "Wann ziehst du um?", "Wie komme ich zu deiner neuen Wohnung? (Wegbeschreibung)", "Gruß am Ende"]}'::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'oesd-a1' and t.slug = 'modell-08'
join sections s on s.test_id = t.id and s.section_id = v.section_id
on conflict (section_id, item_id) do update set text = excluded.text, options = excluded.options, points = excluded.points, meta = excluded.meta, sort = excluded.sort;

insert into item_answers (item_id, answer, explanation)
select i.id, v.answer, v.explanation
from (values
    ('lv1', '1', '4', null),
    ('lv1', '2', '6', null),
    ('lv1', '3', '3', null),
    ('lv1', '4', '5', null),
    ('lv1', '5', '1', null),
    ('lv2', '6', 'B', null),
    ('lv2', '7', 'A', null),
    ('lv2', '8', 'B', null),
    ('lv2', '9', 'A', null),
    ('lv2', '10', 'A', null),
    ('lv2', '11', 'B', null),
    ('lv3', '12', '2', null),
    ('lv3', '13', '3', null),
    ('lv3', '14', '5', null),
    ('lv3', '15', '6', null),
    ('lv3', '16', '4', null),
    ('hv1', '17', 'C', null),
    ('hv1', '18', 'E', null),
    ('hv1', '19', 'B', null),
    ('hv1', '20', 'A', null),
    ('hv1', '21', 'D', null),
    ('hv3', '23', 'D', null),
    ('hv3', '24', 'A', null),
    ('hv3', '25', 'C', null),
    ('hv3', '26', 'B', null),
    ('hv3', '27', 'D', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'oesd-a1' and t.slug = 'modell-08'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;

commit;
