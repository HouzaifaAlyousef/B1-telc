-- جزء 1 من 4 — نماذج modell-01–modell-04
-- مولّد من supabase/seed/b1.sql بـtools/split_seed.sh — لا تعدّله بالإيد
-- آمن للإعادة: شغّله مرتين ما بيغيّر شي.

begin;

-- مولّد من data بـtools/export_sql.py — لا تعدّله بالإيد

insert into levels (id, title, sort, published) values ('b1', 'telc Deutsch B1', 0, true)
on conflict (id) do update set title = excluded.title;

-- ================= modell-01 · PETRA =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('b1', 'modell-01', 'PETRA', '61 Aufgaben · 150 Minuten',
        '[{"id": "block-lv-sb", "title": "Leseverstehen und Sprachbausteine", "minutes": 90, "hint": "Aufgaben 1–40", "parts": ["lv1", "lv2", "lv3", "sb1", "sb2"], "maxPoints": 105.0, "availablePoints": 105.0, "missing": 0}, {"id": "block-hv", "title": "Hörverstehen", "minutes": 30, "hint": "Aufgaben 41–60", "parts": ["hv1", "hv2", "hv3"], "maxPoints": 75.0, "availablePoints": 75.0, "missing": 0}, {"id": "block-sa", "title": "Schriftlicher Ausdruck", "minutes": 30, "hint": "", "parts": ["sa"], "maxPoints": 45.0, "availablePoints": 45, "missing": 0}]'::jsonb, 61, true, 1)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('lv1', 'Leseverstehen', 'Leseverstehen, Teil 1', 15, 'Lesen Sie die Überschriften a–j und die Texte 1–5. Finden Sie für jeden Text die passende Überschrift. Jede Überschrift passt nur einmal.', 'matching', '{"bank": [{"key": "A", "text": "Angebot für Reisende: Für wenig Geld öffentliche Verkehrsmittel benutzen"}, {"key": "B", "text": "Bildband: Babys im Garten"}, {"key": "C", "text": "Ein Schüler mit vielen Ideen"}, {"key": "D", "text": "Früh übt sich: Hotels bieten Skikurse für Zweijährige an"}, {"key": "E", "text": "Handbuch für Hobby-Fotografen"}, {"key": "F", "text": "Neu: Mit dem Taxi gratis zur Disco"}, {"key": "G", "text": "Neu: Taxi Tickest für Discobesucher"}, {"key": "H", "text": "Schulkinder schreiben spannende Geschichten"}, {"key": "I", "text": "Skikurs für Eltern und Kinder"}, {"key": "J", "text": "Straßenbahn und Bus im Flugticket enthalten"}], "bankTitle": "Überschriften", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 0),
    ('lv2', 'Leseverstehen', 'Leseverstehen, Teil 2', 20, 'Lesen Sie den Text und die Aufgaben 6–10. Welche Lösung (A, B oder C) ist jeweils richtig?', 'mc', '{"passages": [{"paragraphs": [{"t": "Leipzigerin geht in den USA auf Sendung", "b": true}, {"t": "Drei Monate Praktikum für junge Sachsen im Land der unbegrenzten Möglichkeiten", "b": true}, {"t": "Manchmal fühle ich mich wie ein Missionar, scherzt Ulrike Rudelt. Das Bild vom Deutschen, der Lederhosen trägt, Bier trinkt und Sauerkraut isst, hält sich ihrer Meinung nach in der Öffentlichkeit Amerikas ganz stark und wird vor allem in der Fernsehwerbung ständig wiederholt. Dagegen kämpfe ich, sagt die 25- Jährige selbstbewusst, die derzeit ein dreimonatiges Praktikum am Institute of International Studies in Kalifornien absolviert und so oft es geht über die Heimat erzählt.", "b": false}, {"t": "An der Uni in Monterey darf die Leipziger Studentin neben dem Hospitieren auch selbst unterrichten. Das Interesse der Studenten und Dozenten an der deutschen Sprache, an Geschichte und Gegenwart Deutschlands ist große. Richtig in Fahrt kommt Ulrike, wenn es um den Mauerfall geht und darum, wie sich der Osten nach der Wende entwickelt hat. Die Chancen, die ich jetzt habe, hatten meine Eltern nicht, sagt sie. So ging sie nach dem Studium als Au Pair-Mädchen nach England und machte im Rahmen studentischer Austauschprogramme bereits Praktika in den USA und den Niederlanden.", "b": false}, {"t": "Einen Vorgeschmack vom. American Way of Life gab es bereits während des einwöchigen Einführungsseminars in New York, schwärmt Cornelia Schiemenz. Die Stadt pulsiert, und wir hatten jede Menge Spaß. Auf dem Programm standen Ausflüge, und dazu hörten sie jede Menge vor träge zum Welthandel, Kampf gegen Arbeitslosigkeit, zur wirtschaftlichen Entwicklung der USA und Kriminalitätsbekämpfung. In Denver, wo die Studentin für Kommunikations-und Medienwissenschaft die Arbeit eines Tv- Senders kennen lernt, steht sie nach einigen Tagen selbst vor der Kamera und darf Beiträge für den Sender produzieren ich bin absolut glücklich, sagt die 23 jährige.", "b": false}, {"t": "Antje Kutzer, die dritte Leipzigerin in der Gruppe, hat es nach Los Angeles verschlagen. Nach dem Abitur hat sie Reiseverkehrskauffrau gelernt. In der Reisekette New World Travel erste Erfahrungen. Anfangs erzählt die 23- jährige hatte ich großes Heimweh, es sind doch einige Kilometer weg von Leipzig. Doch dann stelle ich mich der Chefin im besten Englisch vor, worauf sie auf Deutsch antwortete, dass wahnsinnig freut, dass ich ihr über die Schulter sehen will.", "b": false}, {"t": "Die drei Frauen zählen zu den 20 jungen Berufsanfängern aus Ostdeutschland, die unter 2100 Bewerben der Pall- Mall - Initiative ausgewählt wurden und ein dreimonatiges Praktikum in den Staaten absolvieren. Bei der Auswahl der Praktikanten legt man auch auf Auslandserfahrung Wert. Schließlich geht es nicht darum, dass die Teilnehmer ein paar", "b": false}, {"t": "schöne Wochen im Land der unbegrenzten Möglichkeiten erleben. Die Unternehmen stellen zumeist hohe Anforderungen.", "b": false}]}], "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 1),
    ('lv3', 'Leseverstehen', 'Leseverstehen, Teil 3', 20, 'Lesen Sie die Situationen 11–20 und die Anzeigen im Bild. Finden Sie für jede Situation die passende Anzeige. Wenn Sie keine passende Anzeige finden, wählen Sie X.', 'matching', '{"bank": [{"key": "A", "text": ""}, {"key": "B", "text": ""}, {"key": "C", "text": ""}, {"key": "D", "text": ""}, {"key": "E", "text": ""}, {"key": "F", "text": ""}, {"key": "G", "text": ""}, {"key": "H", "text": ""}, {"key": "I", "text": ""}, {"key": "J", "text": ""}, {"key": "K", "text": ""}, {"key": "L", "text": ""}, {"key": "X", "text": ""}], "bankTitle": "Anzeigen", "bankImage": "img/m01-lv3.jpg", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 2.5}'::jsonb, 2),
    ('sb1', 'Sprachbausteine', 'Sprachbausteine, Teil 1', 20, 'Lesen Sie den Text und schließen Sie die Lücken 21–30. Welche Lösung (A, B oder C) ist jeweils richtig?', 'mc', '{"passages": [{"paragraphs": [{"t": "Sehr geehrter Herr Meyerhofer,", "b": false}, {"t": "Wie Sie wissen , miete ich nun schon seit drei Jahren eine Wohnung in (21)Haus. Ich (22) die ganze Zeit sehr zufrieden, denn im Haus war es immer ruhig, sauber und sicher. In der Zwischenzeit (23) sich die Wohnqualität durch die Eröffnung des Restaurants im Erdgeschoss aber deutlich verschlechtert.(24) spät abends höre ich nun täglich (25) Lärm der Restaurantsgäste im Garten, die Mülleimer im Hof sind immer überfüllt, die Parkplätze vor dem Haus, (26) eigentlich für die Mieter reserviert sin , sind immer besetzt, und das Treppenhaus ist ständig verschmutzt. Außerdem fühle ich mich (27) Haus nicht mehr sicher, weil das Restaurant oft die ganze Nacht (28) hat. Ich möchte Sie dringend bitten, such um diese (29) zu kümmern und mit den Restaurantbesitzern zu sprechen. Vielleicht könnte (30)", "b": false}, {"t": "Gemeinsam eine Lösung finden.", "b": false}, {"t": "Mit freundlichen Grüßen", "b": false}, {"t": "Ihre Anneliese Kühne", "b": false}]}], "maxPoints": 15.0, "availablePoints": 15.0, "missing": 0, "pointsPerItem": 1.5}'::jsonb, 3),
    ('sb2', 'Sprachbausteine', 'Sprachbausteine, Teil 2', 15, 'Lesen Sie den Text und schließen Sie die Lücken 31–40. Benutzen Sie die Wörter aus der Liste. Jedes Wort passt nur einmal.', 'wordbank', '{"bank": [{"key": "A", "text": "AM"}, {"key": "B", "text": "BIS"}, {"key": "C", "text": "DASS"}, {"key": "D", "text": "FÜR"}, {"key": "E", "text": "GUTE"}, {"key": "F", "text": "KENIE"}, {"key": "G", "text": "MICH"}, {"key": "H", "text": "MIR"}, {"key": "I", "text": "MIT"}, {"key": "J", "text": "MÖCHTE"}, {"key": "K", "text": "OHNE"}, {"key": "L", "text": "PRO"}, {"key": "M", "text": "WÄHREND"}, {"key": "N", "text": "WÄRE"}, {"key": "O", "text": "WÜRDEN"}], "bankTitle": "Wörterliste", "passages": [{"paragraphs": [{"t": "Sehr geehrte Herr Blanco Ruiz", "b": false}, {"t": "Ich schreibe Ihnen auf die Anzeige, die (31) in der heutigen Bild Zeitung aufgefallen ist. Da ich (32) einige Monate beruflich nach Südamerika gehe, muss ich sehr schnell Spanisch lernen. Für einen richtigen Sprachkurs habe ich leider (33) Zeit. Aber Ihre Methode interessiert mich, vor allem die Sprachübungen (34) den CDs. Ich denke, damit könnte ich ganz (35) Ich arbeite (36) liebsten mit meinem PC. Sie schreiben, (37) Ihr Programm besonders die alltägliche Kommunikation fördert. Wie lange wird es dauern, (38) ich mich meinen Geschäftsfreunden richtig unterhalten kann? Und wie viele Stunden (39) Woche sollte man mindestens üben? Können Sie mir eine Musterlektion schicken ich? (40) gerne ausprobieren, wie ihre Methode funktioniert", "b": false}, {"t": "Mit freundlichen Grüßen", "b": false}, {"t": "Ihre KARIN ÜBERSCHÄR", "b": false}]}], "maxPoints": 15.0, "availablePoints": 15.0, "missing": 0, "pointsPerItem": 1.5}'::jsonb, 4),
    ('hv1', 'Hörverstehen', 'Hörverstehen, Teil 1', 8, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 5),
    ('hv2', 'Hörverstehen', 'Hörverstehen, Teil 2', 14, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 2.5}'::jsonb, 6),
    ('hv3', 'Hörverstehen', 'Hörverstehen, Teil 3', 8, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 7),
    ('sa', 'Schriftlicher Ausdruck', 'Schriftlicher Ausdruck', 30, 'Antworten Sie auf den Brief. Schreiben Sie etwas zu den folgenden Punkten:', 'writing', '{"brief": {"intro": "Eine Bekannte hat Ihnen folgenden Brief geschrieben:", "greeting": "Liebe(r)........", "paragraphs": ["Ich habe eine tolle Überraschung. stelle dir vor, was mir mein Onkel angeboten hat. Er rief mich am Samstag an. Er hat ein großes Ferienhaus im Schwarzwald. Das Haus kann ich für die Ferien kostenlos haben. Ich kann auch Freunde mitbringen! Wäre das nichts für uns? Wir könnten uns alle dort treffen. Du, deine Eltern und Freunde, und ich mit meiner Familie und meinen Freunden. Ich würde mich wahnsinnig freuen, wenn das klappen würde. Bitte schreibe mir so schnell du kannst, damit wir alles planen können. Urlaub im Schwarzwald - das wird traumhaft schön!", "Herzliche Grüße"], "signature": "Petra"}, "hints": ["Bevor Sie den Brief schreiben, überlegen Sie sich eine passende Reihenfolge der punkte, eine passende", "Schreiben Sie mindestens 100 Wörter."], "criteria": [{"title": "Aufgabenbewältigung", "hint": "Sind alle vier Leitpunkte inhaltlich angemessen bearbeitet?"}, {"title": "Kommunikative Gestaltung", "hint": "Anrede, Gruß, passendes Register und verbundene Sätze statt aneinandergereihter Punkte?"}, {"title": "Formale Richtigkeit", "hint": "Stören Fehler in Grammatik, Wortschatz und Rechtschreibung das Verstehen?"}], "grades": [{"key": "A", "points": 5}, {"key": "B", "points": 3}, {"key": "C", "points": 1}, {"key": "D", "points": 0}], "factor": 3, "maxPoints": 45, "availablePoints": 45, "missing": 0}'::jsonb, 8)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'b1' and t.slug = 'modell-01'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('lv1', '1', 'Ich möchte, dass Menschen, die meine Fotos gesehen haben, von nun an die Welt mit anderen Augen betrachten. Das könnte der neuseeländischen Fotografin Anne Geddes gelingen. Denn die Bilder, die sie für das Buch. Drunten im Garten von den kleinen Menschenkindern gemacht hat, sind ungewöhnlich und wunderschön: Babys auf Blumen, Blättern, Beeren, verkleidet als Morcheln, Melonen oder Marienkäfer, Babys in Tulpen und als Schmetterlinge. Ein Bildband, angereichert mit poetischen Texten und Ratschlägen.', null::jsonb, 5.0, null::jsonb, 0),
    ('lv1', '2', 'Die meisten Skikurse für Kinder beginnen im Alter von vier Jahren. Im Kärntner Baby Dorf Trebesing ist das anders: Hier werden im Windel Wedel Camp bereits Kleinkinder ab zwei Jahren unterrichtet. Täglich zwei Stunden können die Skihaserin unter fachkundiger Anleitung auf einem flachen Hügel erste Geh- bzw. Fahrversuche auf zwei Brettern machen. Nach einigen Tagen Übung geht es dann mit dem Baby Bus ins Skigebiet Innerkrems. Auch Ginas Baby und Kinderhotel am Fiaker See bietet seinen jüngsten Gästen Skikurse. Fast 1000 Knirpse haben in der Windelschule schon Skifahren gelernt. Auskunft: Tourismusverband Leiser Malta Tal und die Kinderhotels', null::jsonb, 5.0, null::jsonb, 1),
    ('lv1', '3', 'Berlins jüngster Schriftsteller hat deutlich mehr Texte verfasst als er Jahre zählt. Rund 50 Gedichte und Erzählungen tippte Daniel Story. 12, schon in seiner Computer. Ich schreibe fast, seitdem es mich gibt, sagt der Sechstklässler Bereits mit sieben dichtete er die ersten Verse, jetzt mit zwölf ist er stolz auf seine erste Autorenlesung. Wenn Freunde Fußball spielen, tobt Daniels Phantasie im Kinderzimmer. Warum er lieber schreibt? Daniel: Ich schreibe, weil ich nicht alles erleben kann, was ich denke.', null::jsonb, 5.0, null::jsonb, 2),
    ('lv1', '4', 'Ob Sie privat oder geschäftlich unterwegs sind, mit dem Stadt Ticket können Sie billig die öffentlichen Verkehrsmittel nutzen. Voraussetzung: Sie sind mit dem Flugzeug oder der Deutschen Bahn(über 100 km) angereist. Gegen einen Aufpreis von nur Euro 2,50 ermöglicht Ihnen das Stadt Ticket auch nach der Ankunft am Zielort freie Fahrt. Mit U- S- oder Straßenbahnen sowie Bussen. Bis zu 48 Stunden. Übrigens: Ihr Stadt Ticket gilt an zwei aufeinanderfolgenden Tagen, die Sie beim Kauf Ihres Fahrscheines selbst bestimmen.', null::jsonb, 5.0, null::jsonb, 3),
    ('lv1', '5', 'In Mecklenburg-Vorpommern können junge Leute jetzt für den halben Fahrpreis mit dem Taxi auf Discotour gehen. Tickets dafür sind bei allen Geschäftsstellen der Allgemeinen Ortskrankenkasse (AOK) sowie an Esso Tankstellen zum halben Preis erhältlich. Junge Leute zwischen 16 und 25 Jahren können sie an Wochenenden und Feiertagen in der Zeit von 20 Uhr bis morgens 6 Uhr benutzen. Die Taxifahrer erhalten bei ihrer Zentrale dann den vollen Fahrpreis erstattet.', null::jsonb, 5.0, null::jsonb, 4),
    ('lv2', '6', 'Die Werbung in den Vereinigten Staaten', '[{"key": "A", "text": "beschäftigt sich überhaupt nicht mit Deutschland."}, {"key": "B", "text": "zeigt immer wieder dasselbe Bild von Deutschland."}, {"key": "C", "text": "zeigt viele unterschiedliche Seiten von Deutschland."}]'::jsonb, 5.0, null::jsonb, 0),
    ('lv2', '7', 'Die Eltern von Laura Rudelt.', '[{"key": "A", "text": "arbeiten und lebten lange Jahre in den Niederlanden."}, {"key": "B", "text": "hatten nicht die Möglichkeiten wie ihre Tochter."}, {"key": "C", "text": "wollen ihre Tochter nun in den USA Besuchen."}]'::jsonb, 5.0, null::jsonb, 1),
    ('lv2', '8', 'Während die Praktikantinnen in New York waren.', '[{"key": "A", "text": "bekamen sie eine Stadtführung."}, {"key": "B", "text": "besuchten sie einen Sprachkurs."}, {"key": "C", "text": "wurden sie über wichtige Themen informiert"}]'::jsonb, 5.0, null::jsonb, 2),
    ('lv2', '9', 'Die dritte Leipzigerin, die in die USA gereist ist', '[{"key": "A", "text": "kommt eigentlich aus Österreich."}, {"key": "B", "text": "wollte dort ihr Abitur machen und dann studieren."}, {"key": "C", "text": "wurde von ihrer neuen Chefin freundlich aufgenommen."}]'::jsonb, 5.0, null::jsonb, 3),
    ('lv2', '10', 'Wer als Praktikantin ins Ausland geht', '[{"key": "A", "text": "braucht schon einige Berufserfahrungen."}, {"key": "B", "text": "soll dabei vor allem das Land kennenlernen."}, {"key": "C", "text": "soll schon einmal im Ausland gewesen sein."}]'::jsonb, 5.0, null::jsonb, 4),
    ('lv3', '11', 'Sie möchten für ein Jahr in Wien Psychologie studieren und suchen daher eine günstige Mietwohnung.', null::jsonb, 2.5, null::jsonb, 0),
    ('lv3', '12', 'Sie möchten am Abend ins Kino gehen und suchen daher eine verlässliche Person, die auf Ihr Kind aufpasst.', null::jsonb, 2.5, null::jsonb, 1),
    ('lv3', '13', 'Sie möchten in den Sommerferien nebenbei ein wenig Geld dazu verdienen und suchen daher einen passenden Job.', null::jsonb, 2.5, null::jsonb, 2),
    ('lv3', '14', 'Sie möchten ein Geburtstagfest organisieren und brauchen dafür einen Raum. Um das Essen und die Getränke für die Gäste möchten Sie sich selbst kümmern.', null::jsonb, 2.5, null::jsonb, 3),
    ('lv3', '15', 'Ihre Bekannten aus Deutschland müssen aus beruflichen Gründen nach Salzburg umziehen und haben Sie gebeten, eine Mietwohnung für Sie suchen.', null::jsonb, 2.5, null::jsonb, 4),
    ('lv3', '16', 'Ihre 23 jährige Freundin hat soeben einen Computerkurs abgeschlossen und sucht einen Job.', null::jsonb, 2.5, null::jsonb, 5),
    ('lv3', '17', 'Ihr 12 jährige Sohn wünscht sich zum Geburtstag Buch über Sterne.', null::jsonb, 2.5, null::jsonb, 6),
    ('lv3', '18', 'Ihre Kinder möchten am Nachmittag ins Kino gehen. Sie suchen einen passenden Film für Kinder.', null::jsonb, 2.5, null::jsonb, 7),
    ('lv3', '19', 'Sie möchten mit Freunden gern ins Kino gehen. Da es ein sehr warmer Sommerabend ist, suchen Sie nach einer Vorstellung im Ferien.', null::jsonb, 2.5, null::jsonb, 8),
    ('lv3', '20', 'Ihre Freundin ist Erzieherin und zur Zeit arbeitslos. Sie möchte daher als Kindermädchen bei einer Familie arbeiten.', null::jsonb, 2.5, null::jsonb, 9),
    ('sb1', '21', '… , miete ich nun schon seit drei Jahren eine Wohnung in (21)Haus. Ich (22) die ganze Zeit sehr zufrieden, denn im Haus …', '[{"key": "A", "text": "Ihr"}, {"key": "B", "text": "Ihrem"}, {"key": "C", "text": "Ihren"}]'::jsonb, 1.5, null::jsonb, 0),
    ('sb1', '22', '… nun schon seit drei Jahren eine Wohnung in (21)Haus. Ich (22) die ganze Zeit sehr zufrieden, denn im Haus war es immer …', '[{"key": "A", "text": "war"}, {"key": "B", "text": "wäre"}, {"key": "C", "text": "würde"}]'::jsonb, 1.5, null::jsonb, 1),
    ('sb1', '23', '… es immer ruhig, sauber und sicher. In der Zwischenzeit (23) sich die Wohnqualität durch die Eröffnung des Restaurants …', '[{"key": "A", "text": "hat"}, {"key": "B", "text": "ist"}, {"key": "C", "text": "wurde"}]'::jsonb, 1.5, null::jsonb, 2),
    ('sb1', '24', '… Restaurants im Erdgeschoss aber deutlich verschlechtert.(24) spät abends höre ich nun täglich (25) Lärm der …', '[{"key": "A", "text": "Bis"}, {"key": "B", "text": "Nach"}, {"key": "C", "text": "Von"}]'::jsonb, 1.5, null::jsonb, 3),
    ('sb1', '25', '… verschlechtert.(24) spät abends höre ich nun täglich (25) Lärm der Restaurantsgäste im Garten, die Mülleimer im Hof …', '[{"key": "A", "text": "dem"}, {"key": "B", "text": "den"}, {"key": "C", "text": "der"}]'::jsonb, 1.5, null::jsonb, 4),
    ('sb1', '26', '… im Hof sind immer überfüllt, die Parkplätze vor dem Haus, (26) eigentlich für die Mieter reserviert sin , sind immer …', '[{"key": "A", "text": "denen"}, {"key": "B", "text": "die"}, {"key": "C", "text": "diese"}]'::jsonb, 1.5, null::jsonb, 5),
    ('sb1', '27', '… ist ständig verschmutzt. Außerdem fühle ich mich (27) Haus nicht mehr sicher, weil das Restaurant oft die ganze …', '[{"key": "A", "text": "im"}, {"key": "B", "text": "in"}, {"key": "C", "text": "ins"}]'::jsonb, 1.5, null::jsonb, 6),
    ('sb1', '28', '… mehr sicher, weil das Restaurant oft die ganze Nacht (28) hat. Ich möchte Sie dringend bitten, such um diese (29) …', '[{"key": "A", "text": "geöffnet"}, {"key": "B", "text": "öffnen"}, {"key": "C", "text": "öffnet"}]'::jsonb, 1.5, null::jsonb, 7),
    ('sb1', '29', '… (28) hat. Ich möchte Sie dringend bitten, such um diese (29) zu kümmern und mit den Restaurantbesitzern zu sprechen. …', '[{"key": "A", "text": "Problem"}, {"key": "B", "text": "Probleme"}, {"key": "C", "text": "Problemen"}]'::jsonb, 1.5, null::jsonb, 8),
    ('sb1', '30', '… den Restaurantbesitzern zu sprechen. Vielleicht könnte (30) Gemeinsam eine Lösung finden. Mit freundlichen Grüßen …', '[{"key": "A", "text": "er"}, {"key": "B", "text": "man"}, {"key": "C", "text": "wir"}]'::jsonb, 1.5, null::jsonb, 9),
    ('sb2', '31', '… Herr Blanco Ruiz Ich schreibe Ihnen auf die Anzeige, die (31) in der heutigen Bild Zeitung aufgefallen ist. Da ich (32) …', null::jsonb, 1.5, null::jsonb, 0),
    ('sb2', '32', '… (31) in der heutigen Bild Zeitung aufgefallen ist. Da ich (32) einige Monate beruflich nach Südamerika gehe, muss ich …', null::jsonb, 1.5, null::jsonb, 1),
    ('sb2', '33', '… lernen. Für einen richtigen Sprachkurs habe ich leider (33) Zeit. Aber Ihre Methode interessiert mich, vor allem die …', null::jsonb, 1.5, null::jsonb, 2),
    ('sb2', '34', '… Methode interessiert mich, vor allem die Sprachübungen (34) den CDs. Ich denke, damit könnte ich ganz (35) Ich …', null::jsonb, 1.5, null::jsonb, 3),
    ('sb2', '35', '… (34) den CDs. Ich denke, damit könnte ich ganz (35) Ich arbeite (36) liebsten mit meinem PC. Sie schreiben, …', null::jsonb, 1.5, null::jsonb, 4),
    ('sb2', '36', '… CDs. Ich denke, damit könnte ich ganz (35) Ich arbeite (36) liebsten mit meinem PC. Sie schreiben, (37) Ihr Programm …', null::jsonb, 1.5, null::jsonb, 5),
    ('sb2', '37', '… Ich arbeite (36) liebsten mit meinem PC. Sie schreiben, (37) Ihr Programm besonders die alltägliche Kommunikation …', null::jsonb, 1.5, null::jsonb, 6),
    ('sb2', '38', '… Kommunikation fördert. Wie lange wird es dauern, (38) ich mich meinen Geschäftsfreunden richtig unterhalten …', null::jsonb, 1.5, null::jsonb, 7),
    ('sb2', '39', '… richtig unterhalten kann? Und wie viele Stunden (39) Woche sollte man mindestens üben? Können Sie mir eine …', null::jsonb, 1.5, null::jsonb, 8),
    ('sb2', '40', '… üben? Können Sie mir eine Musterlektion schicken ich? (40) gerne ausprobieren, wie ihre Methode funktioniert Mit …', null::jsonb, 1.5, null::jsonb, 9),
    ('hv1', '41', 'Die Sprecherin wünscht sich einen Arbeitsplatz für ihren Vater.', null::jsonb, 5.0, null::jsonb, 0),
    ('hv1', '42', 'Der Sprecher ist kein besonders guter Schüler.', null::jsonb, 5.0, null::jsonb, 1),
    ('hv1', '43', 'Die Sprecherin möchte nicht immer gestört werden.', null::jsonb, 5.0, null::jsonb, 2),
    ('hv1', '44', 'Der Sprecher versteht sich nicht gut mit seiner Mutter.', null::jsonb, 5.0, null::jsonb, 3),
    ('hv1', '45', 'Die Sprecherin ist am liebsten mit ihren Eltern zusammen.', null::jsonb, 5.0, null::jsonb, 4),
    ('hv2', '46', 'Frau Schäfer hat von dem Verein kurz nach der Gründung zum ersten Mal gehört.', null::jsonb, 2.5, null::jsonb, 0),
    ('hv2', '47', 'Die Mitglieder des Vereins kommen aus ganz Deutschland.', null::jsonb, 2.5, null::jsonb, 1),
    ('hv2', '48', 'Die Mitglieder des Vereins wissen über Hausarbeit gut Bescheid', null::jsonb, 2.5, null::jsonb, 2),
    ('hv2', '49', 'Im Verein werden oft Feste gefeiert.', null::jsonb, 2.5, null::jsonb, 3),
    ('hv2', '50', 'Der Verein bietet auch die Organisation von Festen an', null::jsonb, 2.5, null::jsonb, 4),
    ('hv2', '51', 'Der Verein vermittelt Senioren, die tagsüber Kinder betreuen', null::jsonb, 2.5, null::jsonb, 5),
    ('hv2', '52', 'Laut Frau Schäfer vertrauen viele Familien den Mitarbeiterinnen des Vereins mehr als anderen', null::jsonb, 2.5, null::jsonb, 6),
    ('hv2', '53', 'Vereinsmitglied kann nur werden, wer einen Beruf gelernt hat', null::jsonb, 2.5, null::jsonb, 7),
    ('hv2', '54', 'Die Mitarbeiterinnen bekommen für ihre Arbeiten 10 Euro pro Stunde.', null::jsonb, 2.5, null::jsonb, 8),
    ('hv2', '55', 'Kunden mit wenig Geld zahlen für den Service nichts.', null::jsonb, 2.5, null::jsonb, 9),
    ('hv3', '56', 'Sie sollen um 19:30 Uhr bei Georg und Claudia sein.', null::jsonb, 5.0, null::jsonb, 0),
    ('hv3', '57', 'Im südlichen Österreich ist es tagsüber sonnig, später windig und regnerisch', null::jsonb, 5.0, null::jsonb, 1),
    ('hv3', '58', 'Der Speisewagen befindet sich im hinteren Teil des Zuges.', null::jsonb, 5.0, null::jsonb, 2),
    ('hv3', '59', 'Die Schweizer geben für Urlaub mehr Geld aus als für ihre Gesundheit.', null::jsonb, 5.0, null::jsonb, 3),
    ('hv3', '60', 'Der Sänger beginnt seine Konzertreise mit einer Vorstellung in Wien', null::jsonb, 5.0, null::jsonb, 4),
    ('sa', 'A', 'Antworten Sie auf den Brief. Schreiben Sie etwas zu den folgenden Punkten:', null::jsonb, 0, '{"minWords": 100, "points": ["Warum Sie gern nach Deutschland kommen möchten", "Wie Sie anreisen wollen", "Was Sie gemeinsam machen könnten", "Wen Sie mitbringen möchten"]}'::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'b1' and t.slug = 'modell-01'
join sections s on s.test_id = t.id and s.section_id = v.section_id
on conflict (section_id, item_id) do update set text = excluded.text, options = excluded.options, points = excluded.points, meta = excluded.meta, sort = excluded.sort;

insert into item_answers (item_id, answer, explanation)
select i.id, v.answer, v.explanation
from (values
    ('lv1', '1', 'B', null),
    ('lv1', '2', 'D', null),
    ('lv1', '3', 'C', null),
    ('lv1', '4', 'A', null),
    ('lv1', '5', 'G', null),
    ('lv2', '6', 'B', null),
    ('lv2', '7', 'B', null),
    ('lv2', '8', 'C', null),
    ('lv2', '9', 'C', null),
    ('lv2', '10', 'C', null),
    ('lv3', '11', 'G', null),
    ('lv3', '12', 'F', null),
    ('lv3', '13', 'J', null),
    ('lv3', '14', 'A', null),
    ('lv3', '15', 'X', null),
    ('lv3', '16', 'E', null),
    ('lv3', '17', 'X', null),
    ('lv3', '18', 'C', null),
    ('lv3', '19', 'I', null),
    ('lv3', '20', 'L', null),
    ('sb1', '21', 'B', null),
    ('sb1', '22', 'A', null),
    ('sb1', '23', 'A', null),
    ('sb1', '24', 'A', null),
    ('sb1', '25', 'B', null),
    ('sb1', '26', 'B', null),
    ('sb1', '27', 'A', null),
    ('sb1', '28', 'A', null),
    ('sb1', '29', 'B', null),
    ('sb1', '30', 'B', null),
    ('sb2', '31', 'H', 'Das Wort lautet: MIR'),
    ('sb2', '32', 'D', 'Das Wort lautet: FÜR'),
    ('sb2', '33', 'F', 'Das Wort lautet: KENIE'),
    ('sb2', '34', 'I', 'Das Wort lautet: MIT'),
    ('sb2', '35', 'E', 'Das Wort lautet: GUTE'),
    ('sb2', '36', 'A', 'Das Wort lautet: AM'),
    ('sb2', '37', 'C', 'Das Wort lautet: DASS'),
    ('sb2', '38', 'B', 'Das Wort lautet: BIS'),
    ('sb2', '39', 'L', 'Das Wort lautet: PRO'),
    ('sb2', '40', 'J', 'Das Wort lautet: MÖCHTE'),
    ('hv1', '41', 'f', null),
    ('hv1', '42', 'r', null),
    ('hv1', '43', 'r', null),
    ('hv1', '44', 'r', null),
    ('hv1', '45', 'f', null),
    ('hv2', '46', 'f', null),
    ('hv2', '47', 'f', null),
    ('hv2', '48', 'r', null),
    ('hv2', '49', 'f', null),
    ('hv2', '50', 'r', null),
    ('hv2', '51', 'r', null),
    ('hv2', '52', 'r', null),
    ('hv2', '53', 'r', null),
    ('hv2', '54', 'f', null),
    ('hv2', '55', 'f', null),
    ('hv3', '56', 'f', null),
    ('hv3', '57', 'r', null),
    ('hv3', '58', 'f', null),
    ('hv3', '59', 'f', null),
    ('hv3', '60', 'r', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'b1' and t.slug = 'modell-01'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;

-- ================= modell-02 · EVA1 =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('b1', 'modell-02', 'EVA1', '61 Aufgaben · 150 Minuten',
        '[{"id": "block-lv-sb", "title": "Leseverstehen und Sprachbausteine", "minutes": 90, "hint": "Aufgaben 1–40", "parts": ["lv1", "lv2", "lv3", "sb1", "sb2"], "maxPoints": 105.0, "availablePoints": 105.0, "missing": 0}, {"id": "block-hv", "title": "Hörverstehen", "minutes": 30, "hint": "Aufgaben 41–60", "parts": ["hv1", "hv2", "hv3"], "maxPoints": 75.0, "availablePoints": 75.0, "missing": 0}, {"id": "block-sa", "title": "Schriftlicher Ausdruck", "minutes": 30, "hint": "", "parts": ["sa"], "maxPoints": 45.0, "availablePoints": 45, "missing": 0}]'::jsonb, 61, true, 2)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('lv1', 'Leseverstehen', 'Leseverstehen, Teil 1', 15, 'Lesen Sie die Überschriften a–j und die Texte 1–5. Finden Sie für jeden Text die passende Überschrift. Jede Überschrift passt nur einmal.', 'matching', '{"bank": [{"key": "A", "text": "Zufriedenheit im Job schützt vor Stress"}, {"key": "B", "text": "Erfolgreiche Männer können auch gute Väter sein"}, {"key": "C", "text": "Keiner lacht so fröhlich wie der Weihnachtsmann"}, {"key": "D", "text": "Wie Männer und Frauen lachen"}, {"key": "E", "text": "Weniger Arbeit weniger Stress"}, {"key": "F", "text": "Schlechte Nachrichten? Sagen Sie es mit einem Lächeln"}, {"key": "G", "text": "Der Beruf ist für Männer wichtiger als die Familie"}, {"key": "H", "text": "Auch ältere Menschen leiden unter Stress"}, {"key": "I", "text": "Frauen reagieren besser auf schlechte Nachrichten als Männer"}, {"key": "J", "text": "Mit 70 Jahren macht das Leben am meistens Spaß"}], "bankTitle": "Überschriften", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 0),
    ('lv2', 'Leseverstehen', 'Leseverstehen, Teil 2', 20, 'Lesen Sie den Text und die Aufgaben 6–10. Welche Lösung (A, B oder C) ist jeweils richtig?', 'mc', '{"passages": [{"paragraphs": [{"t": "Geheimnisse des Schlafes", "b": true}, {"t": "Schlafstörungen die meisten Ursachen sind harmlos", "b": true}, {"t": "Lange Zeit hat man geglaubt, dass der Schlaf nur so etwas ist wie der kleine Bruder des Todes Ein Zustand der Körper Energie spart und alles langsamer läuft. Erst in den 50 er Jahren des letzten Jahrhunderts fand man heraus dass schlafen etwas sehr Aktives ist und Nacht für Nacht in unterschiedlichen Abschnitten verläuft. Der Schweizer Schlafforscher Alexander Borbely hat diesen Vorgang mit einer Treppe verglichen, über die wir jede Nacht mehrmals gehen.", "b": false}, {"t": "Zunächst sind wir wach, dann schlafen wir ein und gehen bis tief hinab in den Keller in einen tiefen Schlaf. Danach geht es wieder hoch in einen leichten Schlaf, der von lebhaften, intensiven Träumen und schnellen Augenbewegungen begleitet wird Daher wird diese Phase auch REM-Schlaf ( rapid-eye-movements = schnelle Augenbewegung) genannt. Dieser Abschnitt ist im Gegensatz zu den anderen Phasen mit etwa 20 Minuten sehr kurz, soll aber äußerst wichtig für die physische Erholung sein.", "b": false}, {"t": "Damit hat die Wissenschaft aber noch lange nicht alle Probleme des Schlafes gelöst. Erwiesen ist nur: Wir brauchen ihn zur körperlichen Erholung, auch wenn wir ihn manchmal als Zeitverschwendung empfinden – immerhin verbringen wir ein Drittel unseres Lebens mit schlafen.", "b": false}, {"t": "Warum können wir aber nicht immer sofort einschlafen, wenn müde sind? Tatsächlich klagen viele Menschen in den westlichen Industrienationen über gelegentliche oder dauernde Schlafstörungen.", "b": false}, {"t": "So muss unser Körper, ins besonders das Gehirn die Eindrücke des Tages erst einmal verarbeiten damit wir gesund schlafen. Diese System reagiert so sensibel, dass schon kleine Ursachen – äußere und innere – störend wirken können.", "b": false}, {"t": "Äußere Ursachen können sein: Lärm, eine ungewohnte Umgebung, ein zu spätes, zu reichliches Essen, kälte oder wärme, alles wirkt sich auf unser Wohlbefinden und somit auch auf den Schlaf aus.", "b": false}, {"t": "Als innere Ursachen kommen Schmerzen, Angst oder Ärger über ungelöste Konflikte in Frage.", "b": false}, {"t": "Erkrankungen beeinflussen den Schlaf, auch Medikamente können eine störende Rolle spielen Alles was uns gedanklich stark beschäftigt, kann unseren Schlaf beeinträchtigen. Wer aber nur gelegentlich nachts aufwacht, oder auch einmal einige Tag schlecht schläft braucht sich keine Sorgen zu machen. Ein paar schlaflose Nächte lassen sich schnell wieder nachholen.", "b": false}, {"t": "Ein echte Schlafstörung liegt erst dann vor wenn unsere Leistungsfähigkeit oder unsere Gesundheit auf Dauer stark beeinträchtigt werden. Dann sollte man auf jeden Fall ärztlichen Rat suchen.", "b": false}]}], "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 1),
    ('lv3', 'Leseverstehen', 'Leseverstehen, Teil 3', 20, 'Lesen Sie die Situationen 11–20 und die Anzeigen im Bild. Finden Sie für jede Situation die passende Anzeige. Wenn Sie keine passende Anzeige finden, wählen Sie X.', 'matching', '{"bank": [{"key": "A", "text": ""}, {"key": "B", "text": ""}, {"key": "C", "text": ""}, {"key": "D", "text": ""}, {"key": "E", "text": ""}, {"key": "F", "text": ""}, {"key": "G", "text": ""}, {"key": "H", "text": ""}, {"key": "I", "text": ""}, {"key": "J", "text": ""}, {"key": "K", "text": ""}, {"key": "L", "text": ""}, {"key": "X", "text": ""}], "bankTitle": "Anzeigen", "bankImage": "img/m02-lv3.jpg", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 2.5}'::jsonb, 2),
    ('sb1', 'Sprachbausteine', 'Sprachbausteine, Teil 1', 20, 'Lesen Sie den Text und schließen Sie die Lücken 21–30. Welche Lösung (A, B oder C) ist jeweils richtig?', 'mc', '{"passages": [{"paragraphs": [{"t": "Herrn Das COMPUTER-MAGAZIN Matthias Buschhaus Alte Gasse 19 D-80344 München", "b": false}, {"t": "München, den 21. Mai…. Ihre Kündigung vom 15. Mai", "b": false}, {"t": "Sehr geehrter Herr Buschhaus,", "b": false}, {"t": "schade, (21) Sie CHIP nicht weiter beziehen (22). Die Belieferung beenden wir mit unserem (23) Heft. Sie erhalten daher die darauf folgende Ausgabe nicht (24).", "b": false}, {"t": "Wir (25) Sie natürlich nur ungern als Abonnenten und würden uns freuen, wenn Sie CHIP (26)", "b": false}, {"t": "ab und zu am Kiosk kaufen. Vielleicht gelingt es uns, (27) wieder von der Qualität von CHIP zu überzeugen.", "b": false}, {"t": "(28) Sie noch Fragen haben oder sich wieder für ein Abonnement entscheiden, stehen wir Ihnen gerne unter (29) Nummer 0781/639 6259 von montags bis freitags von 8 bis 18 Uhr zur Verfügung.", "b": false}, {"t": "Mit (30) Grüßen", "b": false}, {"t": "Ihr CHIP-Aboservice", "b": false}]}], "maxPoints": 15.0, "availablePoints": 15.0, "missing": 0, "pointsPerItem": 1.5}'::jsonb, 3),
    ('sb2', 'Sprachbausteine', 'Sprachbausteine, Teil 2', 15, 'Lesen Sie den Text und schließen Sie die Lücken 31–40. Benutzen Sie die Wörter aus der Liste. Jedes Wort passt nur einmal.', 'wordbank', '{"bank": [{"key": "A", "text": "AUSSERDEM"}, {"key": "B", "text": "DÜRFEN"}, {"key": "C", "text": "ERSTENS"}, {"key": "D", "text": "FÜR"}, {"key": "E", "text": "KEINES"}, {"key": "F", "text": "MÖCHTE"}, {"key": "G", "text": "MÜSSEN"}, {"key": "H", "text": "NICHTS"}, {"key": "I", "text": "OB"}, {"key": "J", "text": "OBWOHL"}, {"key": "K", "text": "TAGE"}, {"key": "L", "text": "ÜBER"}, {"key": "M", "text": "VORAUS"}, {"key": "N", "text": "WENN"}, {"key": "O", "text": "WOCHENENDE"}], "bankTitle": "Wörterliste", "passages": [{"paragraphs": [{"t": "Sehr geehrter Herr Maier,", "b": false}, {"t": "ich habe Ihre Anzeige in der Zeitung vom letzten (31) gelesen und interessiere mich sehr (32) das Angebot. Ich (33) mit meiner Mutter und ihrer Schwester, die beide schon etwas ältere Damen sind, im September ein paar (34) Urlaub machen und benötige daher einige Informationen.", "b": false}, {"t": "Ist die Benutzung des Hallenbads und der Sauna im Preis enthalten oder (35) wir diese extra bezahlen? Weiters würde mich noch interessieren, (36) Pensionisten eine Ermäßigung bekommen. Sie schreiben darüber leider (37) in Ihrer Anzeige. (38) möchte ich wissen, ob man in der Gegend um das Hotel einfache Wanderungen unternehmen kann.", "b": false}, {"t": "Ich wäre Ihnen sehr dankbar, (39) Sie mir Bildmaterial zum Hotel und der Landschaft sowie eine Preisliste zukommen lassen könnten.", "b": false}, {"t": "Ich bedanke mich im(40) für die Informationen.", "b": false}, {"t": "Mit freundlichen Grüßen", "b": false}, {"t": "ANNELIESE SCHNEEBERGER", "b": false}]}], "maxPoints": 15.0, "availablePoints": 15.0, "missing": 0, "pointsPerItem": 1.5}'::jsonb, 4),
    ('hv1', 'Hörverstehen', 'Hörverstehen, Teil 1', 8, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 5),
    ('hv2', 'Hörverstehen', 'Hörverstehen, Teil 2', 14, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 2.5}'::jsonb, 6),
    ('hv3', 'Hörverstehen', 'Hörverstehen, Teil 3', 8, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 7),
    ('sa', 'Schriftlicher Ausdruck', 'Schriftlicher Ausdruck', 30, 'Schreiben Sie Ihrer Bekannten nun einen Antwortbrief, der die folgenden Punkte erhält:', 'writing', '{"brief": {"intro": "Eine Bekannte aus der Schweiz hat eine neue Stelle. Sie hat Ihnen den folgenden Brief geschrieben:", "greeting": "Liebe(r)........", "paragraphs": ["wie geht es denn so mit dem Deutsch lernen? Kommst du gut voran, und was machst du im Moment so? Stell dir vor, ich habe die neue Stelle bei der Zeitschrift VIA bekommen! ich arbeite jetzt als Journalistin, und das war ja immer mein Traumberuf!", "VIA wird vor allem von jüngeren Leuten gelesen. Deshalb schreiben wir viel über Berufe und Ausbildungen und auch über Freizeit und Sport. Für die nächsten Hefte von VIA planen wir jetzt eine neue Serie über Berufs wünsche. Was ist eigentlich dein Traumberuf? Wenn du möchtest, schicke ich dir gerne einmal ein Grätschet von VIA, damit du siehst, was ich so mache.", "Ich freue mich schon auf deine Antwort.", "Herzliche Grüße"], "signature": "Eva"}, "hints": ["Bevor Sie den Brief schreiben, überlegen Sie sich eine passende Reihenfolge der punkte, eine passende"], "criteria": [{"title": "Aufgabenbewältigung", "hint": "Sind alle vier Leitpunkte inhaltlich angemessen bearbeitet?"}, {"title": "Kommunikative Gestaltung", "hint": "Anrede, Gruß, passendes Register und verbundene Sätze statt aneinandergereihter Punkte?"}, {"title": "Formale Richtigkeit", "hint": "Stören Fehler in Grammatik, Wortschatz und Rechtschreibung das Verstehen?"}], "grades": [{"key": "A", "points": 5}, {"key": "B", "points": 3}, {"key": "C", "points": 1}, {"key": "D", "points": 0}], "factor": 3, "maxPoints": 45, "availablePoints": 45, "missing": 0}'::jsonb, 8)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'b1' and t.slug = 'modell-02'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('lv1', '1', 'Frauen lachen auf viele Arten Sie kichern glucksen und manchmal singen sie fast Bei Männern dagegen kommt das viel seltener vor. Aber gemeinsam ist Männern und Frauen, dass sie in Vokalen lachen die im Mundzentrum gebildet werden. Und das ist entscheidend: Nur wenn die Vokale im Mundzentrum gebildet werden, ist das Lachen für uns fröhlich und positiv. Damit ist bewiesen, dass das Lachen vom Weihnachtsmann, dass wie eine tiefes Ho, ho, ho klingt. Kaum als fröhlich empfunden wird. Denn dieser Laut wird im hinteren Teil des Mundraums gebildet. (aus einer deutschen Zeitung)', null::jsonb, 5.0, null::jsonb, 0),
    ('lv1', '2', 'Viel Arbeit, viel Stress. Wer viel arbeitet muss nicht unbedingt gestresst sein. Frauen in medizinischen Berufen zum Beispiel klagen trotz teilweise hoher Belastung deutlich weniger über stressbedingte Krankheiten als Raumpflegerinnen, Kindergärtnerinnen oder Berufsschullehrerinnen. Dies zeigt eine Untersuchung des Hamburger IPO Instituts, das für eine Studie 1000 Frauen und Männer befragt hat. Vor Stress schützen laut Studie ein angenehmes Betriebsklima, ein gutes Verhältnis zur Chefin oder zum Chef und die Möglichkeit, die eigene Arbeit selbstständig zu planen. (aus einer deutschen Zeitung)', null::jsonb, 5.0, null::jsonb, 1),
    ('lv1', '3', 'Ein neues Buch zeigt, wie Männer Fähigkeiten aus dem Arbeitsleben auf die Erziehung übertragen können und so zu erfolgreichen Vätern werden. Da wird die gemeinsame Kindererziehung zur Partnerarbeit (oder sogar zum Joint Venture) geschicktes Verhandeln heißt, das Kind zu überzeugen, dass sie Zähne geputzt werden müssen, und der Familienurlaub hat alle Qualitäten einer Tagung oder eines Seminars: Man erhält die Gelegenheit, die Kinder intensiv zu studieren. (aus einer deutschen Zeitung)', null::jsonb, 5.0, null::jsonb, 2),
    ('lv1', '4', 'Eine Studie der Universität Essex hat ergeben dass wir mit siebzig Jahren am glücklichsten sind. Zwar haben die meisten Menschen in diesem Alter gesundheitliche Probleme, aber dafür genießen sie viel Freizeit und haben keinen Stress mehr. Deshalb macht ihnen das Leben so viel Spaß wie nie zuvor. Die Studie besagt auch, dass wir einen ersten Höhepunkt der Lebensfreude mit fünfzehn Jahren erreichen. Danach geht es bergab zwischen dreißig und fünfzig Jahren tragen wir am meisten Verantwortung das Leben ist geprägt von Sachzwängen. (aus einer deutschen Zeitung)', null::jsonb, 5.0, null::jsonb, 3),
    ('lv1', '5', 'Warum bleiben manche Managerinnen erfolgreich, obwohl sie Nachrichten mitteilen, die ihr Publikum lieber nicht hören möchte? Ganz einfach: Sie verkaufen die schlechte Nachricht mit Humor. Ein Londoner Soziologe hat während einer Studie beobachtet, dass gerade bei Reden unangenehmen Inhalts oft heiter gelacht wird. Das Lachen wird bewusst provoziert, etwa durch bestimmte Wörter oder durch ein eigenes breites Lächeln. Die fröhliche Stimmung soll dafür sorgen, dass die Zuhörenden das Gefühl haben würden mehr wissen als alle anderen. (aus einer deutschen Zeitung)', null::jsonb, 5.0, null::jsonb, 4),
    ('lv2', '6', 'Der Schweizer Schlafforscher Alexander Borbety', '[{"key": "A", "text": "behauptet, dass der gesunde Schlaf gleichmäßig ist."}, {"key": "B", "text": "beschäftigt sich seit 50 Jahren mit dem Thema Schlaf."}, {"key": "C", "text": "meint, dass es beim Schlaf verschiedene Stufen gibt."}]'::jsonb, 5.0, null::jsonb, 0),
    ('lv2', '7', 'Während der Leichtschlafphase', '[{"key": "A", "text": "erholt man sich nicht gut."}, {"key": "B", "text": "träumt man besonders viel."}, {"key": "C", "text": "wacht man öfter auf."}]'::jsonb, 5.0, null::jsonb, 1),
    ('lv2', '8', 'Die Wissenschaft ist heute der Meinung, dass', '[{"key": "A", "text": "alle Probleme des Schlafes gelöst sind."}, {"key": "B", "text": "der Schlaf der Körperlichen Erholung dient."}, {"key": "C", "text": "man durch Schlafen viel Zeit verliert."}]'::jsonb, 5.0, null::jsonb, 2),
    ('lv2', '9', 'Vor allem die Menschen in westlichen Ländern', '[{"key": "A", "text": "klagen darüber, dass sie schlecht schlafen können."}, {"key": "B", "text": "können ohne Sorgen und Probleme schlafen."}, {"key": "C", "text": "werden beim Schlafen gelegentlich gestört."}]'::jsonb, 5.0, null::jsonb, 3),
    ('lv2', '10', 'Zum Arzt sollen die Menschen gehen, die', '[{"key": "A", "text": "längere Zeit sehr schlecht schlafen."}, {"key": "B", "text": "manchmal nachts aufwachen."}, {"key": "C", "text": "zu viel und zu lange schlafen."}]'::jsonb, 5.0, null::jsonb, 4),
    ('lv3', '11', 'Ihr Bekannter ist Sportlehrer und sucht eine Nebenbeschäftigung in einem Verein.', null::jsonb, 2.5, null::jsonb, 0),
    ('lv3', '12', 'Ein guter Bekannter (39) sucht eine Partnerin. Er ist reiselustig und geht spazieren.', null::jsonb, 2.5, null::jsonb, 1),
    ('lv3', '13', 'Ihre Freundin ist besonders hübsch, Studentin und sucht für die Semesterferien im Sommer einen Job.', null::jsonb, 2.5, null::jsonb, 2),
    ('lv3', '14', 'Sie suchen für das kommende Wochenende eine Konzertkarte.', null::jsonb, 2.5, null::jsonb, 3),
    ('lv3', '15', 'Ihre 30-jährige Freundin hat in einem Hotel in Spanien gearbeitet und sucht jetzt eine ähnliche Arbeit in Deutschland.', null::jsonb, 2.5, null::jsonb, 4),
    ('lv3', '16', 'Ihre 55-jährige Nachbarin sucht jemanden, mit dem sie reisen und klassische Konzerte besuchen kann.', null::jsonb, 2.5, null::jsonb, 5),
    ('lv3', '17', 'Sie möchten lernen, wie Sie kleinere Reparaturen an Ihrem Auto selbst machen können.', null::jsonb, 2.5, null::jsonb, 6),
    ('lv3', '18', 'Die Tochter Ihrer russischen Bekannten sucht eine Au-pair-Stelle in Deutschland. Sie ist erst 18 Jahre alt.', null::jsonb, 2.5, null::jsonb, 7),
    ('lv3', '19', 'Ihre 21-jährige Bekannte sucht eine Stelle als Kindergärtnerin.', null::jsonb, 2.5, null::jsonb, 8),
    ('lv3', '20', 'Eine Freundin braucht ein paar Ratschläge, wie sie erfolgreich eine neue Arbeit finden kann.', null::jsonb, 2.5, null::jsonb, 9),
    ('sb1', '21', '… vom 15. Mai Sehr geehrter Herr Buschhaus, schade, (21) Sie CHIP nicht weiter beziehen (22). Die Belieferung …', '[{"key": "A", "text": "darum"}, {"key": "B", "text": "dass"}, {"key": "C", "text": "weil"}]'::jsonb, 1.5, null::jsonb, 0),
    ('sb1', '22', '… Buschhaus, schade, (21) Sie CHIP nicht weiter beziehen (22). Die Belieferung beenden wir mit unserem (23) Heft. Sie …', '[{"key": "A", "text": "möchte"}, {"key": "B", "text": "möchten"}, {"key": "C", "text": "möchtest"}]'::jsonb, 1.5, null::jsonb, 1),
    ('sb1', '23', '… beziehen (22). Die Belieferung beenden wir mit unserem (23) Heft. Sie erhalten daher die darauf folgende Ausgabe …', '[{"key": "A", "text": "nächste"}, {"key": "B", "text": "nächsten"}, {"key": "C", "text": "nächstes"}]'::jsonb, 1.5, null::jsonb, 2),
    ('sb1', '24', '… Sie erhalten daher die darauf folgende Ausgabe nicht (24). Wir (25) Sie natürlich nur ungern als Abonnenten und …', '[{"key": "A", "text": "mehr"}, {"key": "B", "text": "noch"}, {"key": "C", "text": "nur"}]'::jsonb, 1.5, null::jsonb, 3),
    ('sb1', '25', '… daher die darauf folgende Ausgabe nicht (24). Wir (25) Sie natürlich nur ungern als Abonnenten und würden uns …', '[{"key": "A", "text": "verlieren"}, {"key": "B", "text": "verliert"}, {"key": "C", "text": "verloren"}]'::jsonb, 1.5, null::jsonb, 4),
    ('sb1', '26', '… als Abonnenten und würden uns freuen, wenn Sie CHIP (26) ab und zu am Kiosk kaufen. Vielleicht gelingt es uns, …', '[{"key": "A", "text": "obwohl"}, {"key": "B", "text": "trotz"}, {"key": "C", "text": "trotzdem"}]'::jsonb, 1.5, null::jsonb, 5),
    ('sb1', '27', '… ab und zu am Kiosk kaufen. Vielleicht gelingt es uns, (27) wieder von der Qualität von CHIP zu überzeugen. (28) Sie …', '[{"key": "A", "text": "Ihnen"}, {"key": "B", "text": "sie"}, {"key": "C", "text": "Sie"}]'::jsonb, 1.5, null::jsonb, 6),
    ('sb1', '28', '… uns, (27) wieder von der Qualität von CHIP zu überzeugen. (28) Sie noch Fragen haben oder sich wieder für ein Abonnement …', '[{"key": "A", "text": "Aber"}, {"key": "B", "text": "Falls"}, {"key": "C", "text": "Wann"}]'::jsonb, 1.5, null::jsonb, 7),
    ('sb1', '29', '… ein Abonnement entscheiden, stehen wir Ihnen gerne unter (29) Nummer 0781/639 6259 von montags bis freitags von 8 bis …', '[{"key": "A", "text": "das"}, {"key": "B", "text": "der"}, {"key": "C", "text": "die"}]'::jsonb, 1.5, null::jsonb, 8),
    ('sb1', '30', '… montags bis freitags von 8 bis 18 Uhr zur Verfügung. Mit (30) Grüßen Ihr CHIP-Aboservice', '[{"key": "A", "text": "freundlich"}, {"key": "B", "text": "freundlichem"}, {"key": "C", "text": "freundlichen"}]'::jsonb, 1.5, null::jsonb, 9),
    ('sb2', '31', '… Maier, ich habe Ihre Anzeige in der Zeitung vom letzten (31) gelesen und interessiere mich sehr (32) das Angebot. Ich …', null::jsonb, 1.5, null::jsonb, 0),
    ('sb2', '32', '… vom letzten (31) gelesen und interessiere mich sehr (32) das Angebot. Ich (33) mit meiner Mutter und ihrer …', null::jsonb, 1.5, null::jsonb, 1),
    ('sb2', '33', '… gelesen und interessiere mich sehr (32) das Angebot. Ich (33) mit meiner Mutter und ihrer Schwester, die beide schon …', null::jsonb, 1.5, null::jsonb, 2),
    ('sb2', '34', '… schon etwas ältere Damen sind, im September ein paar (34) Urlaub machen und benötige daher einige Informationen. …', null::jsonb, 1.5, null::jsonb, 3),
    ('sb2', '35', '… des Hallenbads und der Sauna im Preis enthalten oder (35) wir diese extra bezahlen? Weiters würde mich noch …', null::jsonb, 1.5, null::jsonb, 4),
    ('sb2', '36', '… extra bezahlen? Weiters würde mich noch interessieren, (36) Pensionisten eine Ermäßigung bekommen. Sie schreiben …', null::jsonb, 1.5, null::jsonb, 5),
    ('sb2', '37', '… eine Ermäßigung bekommen. Sie schreiben darüber leider (37) in Ihrer Anzeige. (38) möchte ich wissen, ob man in der …', null::jsonb, 1.5, null::jsonb, 6),
    ('sb2', '38', '… Sie schreiben darüber leider (37) in Ihrer Anzeige. (38) möchte ich wissen, ob man in der Gegend um das Hotel …', null::jsonb, 1.5, null::jsonb, 7),
    ('sb2', '39', '… unternehmen kann. Ich wäre Ihnen sehr dankbar, (39) Sie mir Bildmaterial zum Hotel und der Landschaft sowie …', null::jsonb, 1.5, null::jsonb, 8),
    ('sb2', '40', '… Preisliste zukommen lassen könnten. Ich bedanke mich im(40) für die Informationen. Mit freundlichen Grüßen ANNELIESE …', null::jsonb, 1.5, null::jsonb, 9),
    ('hv1', '41', 'Herr Pawliczek erledigt alle seine Einkäufe im Internet.', null::jsonb, 5.0, null::jsonb, 0),
    ('hv1', '42', 'Frau Zimmermann legt beim Einkaufen großen Wert auf persönlichen Kontakt.', null::jsonb, 5.0, null::jsonb, 1),
    ('hv1', '43', 'Frau Schmidt findet zu Hause nicht genug Ruhe, um im Internet einzukaufen.', null::jsonb, 5.0, null::jsonb, 2),
    ('hv1', '44', 'Frau Ruttnigg ist vom Einkaufen im Internet nicht überzeugt.', null::jsonb, 5.0, null::jsonb, 3),
    ('hv1', '45', 'Herr Krause kauft seine Medikamente am liebsten in der nächsten Stadt.', null::jsonb, 5.0, null::jsonb, 4),
    ('hv2', '46', 'Herr Thurnherr ist Chef in einem großen Reisebüro in Bern.', null::jsonb, 2.5, null::jsonb, 0),
    ('hv2', '47', 'Jährlich wollen über 100 Personen eine Ausbildung in einem Reisebüro machen.', null::jsonb, 2.5, null::jsonb, 1),
    ('hv2', '48', 'Während der Ausbildung kann man noch keine Studienreisen machen.', null::jsonb, 2.5, null::jsonb, 2),
    ('hv2', '49', 'Herr Thurnherr meint, die Arbeit in einem Reisebüro sei anstrengend.', null::jsonb, 2.5, null::jsonb, 3),
    ('hv2', '50', 'In einem Reisebüro muss man oft Überstunden machen.', null::jsonb, 2.5, null::jsonb, 4),
    ('hv2', '51', 'In einem Reisebüro verdient man gut.', null::jsonb, 2.5, null::jsonb, 5),
    ('hv2', '52', 'Auf Studienreisen besichtigt man viele Hotels.', null::jsonb, 2.5, null::jsonb, 6),
    ('hv2', '53', 'Im schriftlichen Teil des Tests wird vor allem politisches Wissen geprüft.', null::jsonb, 2.5, null::jsonb, 7),
    ('hv2', '54', 'Jährlich können 50 Jugendliche an einem Eignungstest teilnehmen.', null::jsonb, 2.5, null::jsonb, 8),
    ('hv2', '55', 'Das Reisebüro muss für die Fehler der Mitarbeitenden bezahlen.', null::jsonb, 2.5, null::jsonb, 9),
    ('hv3', '56', 'Sie müssen in Ingolstadt die Regionalbahn nach Regensburg nehmen.', null::jsonb, 5.0, null::jsonb, 0),
    ('hv3', '57', 'Clara kann wegen einer Prüfung die Theaterkarten nicht abholen.', null::jsonb, 5.0, null::jsonb, 1),
    ('hv3', '58', 'Im Schwarzwald können die Straßen morgen glatt werden', null::jsonb, 5.0, null::jsonb, 2),
    ('hv3', '59', 'Der Liederabend findet zu einem späteren Termin statt', null::jsonb, 5.0, null::jsonb, 3),
    ('hv3', '60', 'Im Untergeschoss gibt es Winterkleidung zum halben Preis.', null::jsonb, 5.0, null::jsonb, 4),
    ('sa', 'A', 'Schreiben Sie Ihrer Bekannten nun einen Antwortbrief, der die folgenden Punkte erhält:', null::jsonb, 0, '{"minWords": 100, "points": ["Fortschritte beim Deutsch Lernen", "Auf Evas neue Stelle reagieren", "Was es Neues bei Ihnen gibt", "Ihr Traumberuf"]}'::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'b1' and t.slug = 'modell-02'
join sections s on s.test_id = t.id and s.section_id = v.section_id
on conflict (section_id, item_id) do update set text = excluded.text, options = excluded.options, points = excluded.points, meta = excluded.meta, sort = excluded.sort;

insert into item_answers (item_id, answer, explanation)
select i.id, v.answer, v.explanation
from (values
    ('lv1', '1', 'D', null),
    ('lv1', '2', 'A', null),
    ('lv1', '3', 'B', null),
    ('lv1', '4', 'J', null),
    ('lv1', '5', 'F', null),
    ('lv2', '6', 'C', null),
    ('lv2', '7', 'B', null),
    ('lv2', '8', 'B', null),
    ('lv2', '9', 'A', null),
    ('lv2', '10', 'A', null),
    ('lv3', '11', 'E', null),
    ('lv3', '12', 'F', null),
    ('lv3', '13', 'H', null),
    ('lv3', '14', 'X', null),
    ('lv3', '15', 'C', null),
    ('lv3', '16', 'A', null),
    ('lv3', '17', 'K', null),
    ('lv3', '18', 'X', null),
    ('lv3', '19', 'I', null),
    ('lv3', '20', 'B', null),
    ('sb1', '21', 'B', null),
    ('sb1', '22', 'B', null),
    ('sb1', '23', 'B', null),
    ('sb1', '24', 'A', null),
    ('sb1', '25', 'A', null),
    ('sb1', '26', 'B', null),
    ('sb1', '27', 'C', null),
    ('sb1', '28', 'B', null),
    ('sb1', '29', 'B', null),
    ('sb1', '30', 'C', null),
    ('sb2', '31', 'O', 'Das Wort lautet: WOCHENENDE'),
    ('sb2', '32', 'D', 'Das Wort lautet: FÜR'),
    ('sb2', '33', 'F', 'Das Wort lautet: MÖCHTE'),
    ('sb2', '34', 'K', 'Das Wort lautet: TAGE'),
    ('sb2', '35', 'G', 'Das Wort lautet: MÜSSEN'),
    ('sb2', '36', 'I', 'Das Wort lautet: OB'),
    ('sb2', '37', 'H', 'Das Wort lautet: NICHTS'),
    ('sb2', '38', 'A', 'Das Wort lautet: AUSSERDEM'),
    ('sb2', '39', 'N', 'Das Wort lautet: WENN'),
    ('sb2', '40', 'M', 'Das Wort lautet: VORAUS'),
    ('hv1', '41', 'r', null),
    ('hv1', '42', 'f', null),
    ('hv1', '43', 'r', null),
    ('hv1', '44', 'f', null),
    ('hv1', '45', 'f', null),
    ('hv2', '46', 'r', null),
    ('hv2', '47', 'r', null),
    ('hv2', '48', 'f', null),
    ('hv2', '49', 'r', null),
    ('hv2', '50', 'r', null),
    ('hv2', '51', 'f', null),
    ('hv2', '52', 'r', null),
    ('hv2', '53', 'f', null),
    ('hv2', '54', 'f', null),
    ('hv2', '55', 'r', null),
    ('hv3', '56', 'f', null),
    ('hv3', '57', 'f', null),
    ('hv3', '58', 'f', null),
    ('hv3', '59', 'r', null),
    ('hv3', '60', 'r', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'b1' and t.slug = 'modell-02'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;

-- ================= modell-03 · SOPHIE =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('b1', 'modell-03', 'SOPHIE', '61 Aufgaben · 150 Minuten',
        '[{"id": "block-lv-sb", "title": "Leseverstehen und Sprachbausteine", "minutes": 90, "hint": "Aufgaben 1–40", "parts": ["lv1", "lv2", "lv3", "sb1", "sb2"], "maxPoints": 105.0, "availablePoints": 105.0, "missing": 0}, {"id": "block-hv", "title": "Hörverstehen", "minutes": 30, "hint": "Aufgaben 41–60", "parts": ["hv1", "hv2", "hv3"], "maxPoints": 75.0, "availablePoints": 75.0, "missing": 0}, {"id": "block-sa", "title": "Schriftlicher Ausdruck", "minutes": 30, "hint": "", "parts": ["sa"], "maxPoints": 45.0, "availablePoints": 45, "missing": 0}]'::jsonb, 61, true, 3)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('lv1', 'Leseverstehen', 'Leseverstehen, Teil 1', 15, 'Lesen Sie die Überschriften a–j und die Texte 1–5. Finden Sie für jeden Text die passende Überschrift. Jede Überschrift passt nur einmal.', 'matching', '{"bank": [{"key": "A", "text": "Arbeitsplatz: Bezahlung wichtiger als Zufriedenheit"}, {"key": "B", "text": "Ausstellungseröffnung an bayerischem Gymnasium"}, {"key": "C", "text": "Frauen: mehr Spaß am Beruf als Männer"}, {"key": "D", "text": "Gründe für Zufriedenheit am Arbeitsplatz"}, {"key": "E", "text": "Immer mehr Teilzeitarbeitsplätze für Männer"}, {"key": "F", "text": "Karriere ist Männern weniger wichtig als Frauen"}, {"key": "G", "text": "Technik für Kleinkinder"}, {"key": "H", "text": "Technisches Museum vergibt Umwelt-und Technikpreis"}, {"key": "I", "text": "Umwelt- und Technikpreis"}, {"key": "J", "text": "Wünsche von berufstätigen Eltern"}], "bankTitle": "Überschriften", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 0),
    ('lv2', 'Leseverstehen', 'Leseverstehen, Teil 2', 20, 'Lesen Sie den Text und die Aufgaben 6–10. Welche Lösung (A, B oder C) ist jeweils richtig?', 'mc', '{"passages": [{"paragraphs": [{"t": "Die Sendung mit der Maus Eine Ausstellung über die berühmte Fernsehserie", "b": true}, {"t": "SPEYER. Mit dem Fragebogen in der Hand marschieren die Grundschüler durch das Historische Museum in Speyer. Wie heißt doch noch mal der, der die Maus gezeichnet hat? Fragt Anna. Lisa entdeckt den Namen neben dem Zeichenpult. Friedrich Streich kritzelt sie auf ihr Blatt. Allerdings erst, nachdem sie sich bei einem erwachsenen Ausstellungsbesucher vergewissert hat, dass diese Information auch richtig ist. Maus Oleum heißt die Ausstellung im Jungen Museum, die sich mit einem Stück Fernsehgeschichte beschäftigt. Sie zeigt über 30 Jahre von der Geschichte der Sendung mit der Maus. In den farbenfrohen Räumen wird gezeigt, was und wer hinter den Lach- und Sachgeschichten steckt. Eine Weltkarte beweist, dass die Maus international bekannt ist. Kaum ein Land, in dem die beliebte Kindersendung nicht zu sehen ist. Die orangefarbene Maus erklärt die Welt, indem sie selbstverständlich gewordene Dinge hinter fragt. Mit welchen Mitteln dies geschieht das zeigt die Ausstellung. Was steckt in einer Parkuhr? Wie funktioniert eine Luftpumpe? Woraus wird Creme gemacht? Wie kommen die Löcher in den Käser? Mit solchen und anderen Fragen verblüfft und fasziniert die Maus auch ihre großen Zuschauer, die sich schlagartig daran erinnern, dass sie einst entscheiden neugieriger waren. Wie Detektive, die im Auftrag der Kinder ganz genau hingucken, gehen die Macher an jede Sendung heran. Sie wollen genauso viel wissen und verstehen wie die Kinder selbst Deshalb wird zum Beispiel die Parkuhr einfach aufgeschraubt oder das Innere einer Fahrradpumpe gezeigt.", "b": false}, {"t": "An Vorschlägen, was die Maus erklären könnte fehlt es nicht. Woche für Woche kommen Briefe aus aller Welt. Einige davon sind auch in der Ausstellung zu lesen. Liebe Maus heißt es da. Wir sind heute an einem Druckzentrum vorbeigefahren. Bitte sage uns doch wie eine Zeitung gemacht wird Seit 1971 ist die Maus aktiv: Sie reist in die Vergangenheit oder blickt in die Zukunft sie beantwortet Fragen und lässt Kinder aus verschiedene Ländern selbst erzählen . Auch schwierige Themen wie Politik sind dank der Maus kinderleicht zu verstehen.", "b": false}, {"t": "Überall da, man in der Ausstellung etwas anfassen ausprobieren kann, wo kleine und große Geheimnisse gelüftet werden, dort staunen die kleinen Besucher. Bilder werden zum Laufen gebracht, Töne erzeugt und Kamers getestet.", "b": false}, {"t": "Die Maus ist inzwischen auch bei Künstlern beliebt. Sie ist auf Bildern, Postkarten und Plakaten auf der ganzen Welt zu sehen. Schöner aber sind die kleinen Kunstwerke aus Kinderhand, die die Fernsehmacher im Laufe der Jahre gesammelt und Papier bunte Bilder und sogar ein Puppen Theater ganz aus Pappe alles für die Maus Öffnungszeiten Die Ausstellung in Speyer ist noch bis zum 27 Oktober geöffnet. Dienstags bis sonntags von 10 bis 18 mittwochs bis 20 Uhr.", "b": false}, {"t": "6. Die Maus", "b": false}, {"t": "führt Kinder durch das Museum.", "b": false}, {"t": "wird in einer Werbefirma gezeichnet.", "b": false}, {"t": "wurde von Friedrich Streich erfunden. 7. Das Thema der Ausstellung", "b": false}, {"t": "ist die Geschichte der Sendung mit der Maus.", "b": false}, {"t": "ist 30 Jahre Junges Museum.", "b": false}, {"t": "sind Kinder aus aller Welt.", "b": false}, {"t": "8. Die Sendung mit der Maus", "b": false}, {"t": "erhält Post aus der ganzen Welt.", "b": false}, {"t": "hat es schwer, noch neue Themen zu finden.", "b": false}, {"t": "nimmt nur Vorschläge von Kindern an. 9. Die Ausstellung", "b": false}, {"t": "erlaubt den Kindern, mit den Ausstellungsstücken zu spielen.", "b": false}, {"t": "erlaubt den Kindern nicht, die Ausstellungsstücke anzufassen.", "b": false}, {"t": "ist nur für Kinder geöffnet. 10. Die Maus", "b": false}, {"t": "erhält von den Kindern Geschenke aus verschiedenen Materialien.", "b": false}, {"t": "B gibt es nur auf Postkarten und Plakaten zu kaufen.", "b": false}, {"t": "ist aus Wolle und Papier.", "b": false}]}], "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 1),
    ('lv3', 'Leseverstehen', 'Leseverstehen, Teil 3', 20, 'Lesen Sie die Situationen 11–20 und die Anzeigen im Bild. Finden Sie für jede Situation die passende Anzeige. Wenn Sie keine passende Anzeige finden, wählen Sie X.', 'matching', '{"bank": [{"key": "A", "text": ""}, {"key": "B", "text": ""}, {"key": "C", "text": ""}, {"key": "D", "text": ""}, {"key": "E", "text": ""}, {"key": "F", "text": ""}, {"key": "G", "text": ""}, {"key": "H", "text": ""}, {"key": "I", "text": ""}, {"key": "J", "text": ""}, {"key": "K", "text": ""}, {"key": "L", "text": ""}, {"key": "X", "text": ""}], "bankTitle": "Anzeigen", "bankImage": "img/m03-lv3.jpg", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 2.5}'::jsonb, 2),
    ('sb1', 'Sprachbausteine', 'Sprachbausteine, Teil 1', 20, 'Lesen Sie den Text und schließen Sie die Lücken 21–30. Welche Lösung (A, B oder C) ist jeweils richtig?', 'mc', '{"passages": [{"paragraphs": [{"t": "Liebe Vollzwinkler,", "b": false}, {"t": "wir wohnen jetzt schon (21) sechs Wochen in unserer neuen Wohnung. Zwar ist immer noch", "b": false}, {"t": "nicht alles so eingerichtet, wie Wir (22) das wünschen .Aber wir wussten ja. Dass das einige", "b": false}, {"t": "Zeit (23) würde, bis alles fertig ist. Natürlich haben wir uns zuerst um das Kinderzimmer", "b": false}, {"t": "gekümmert. Unsere beiden Kinder durften sich die Farben für die Wände selbst (24) Sie haben", "b": false}, {"t": "sich für Blau und Gelb entschieden. Meinem Mann (25) das am Anfang gar nicht gefallen, aber jetzt hat er sich (26) gewöhnt. Jetzt fehlt eigentlich nur noch das Wohnzimmer.", "b": false}, {"t": "Wir warten auf die neuen Möbel (27) wir gekauft haben. In der (28) Woche kommen sie", "b": false}, {"t": "endlich. Dann können auch wieder Gäste zu uns kommen. Wir würden uns alle sehr freuen,", "b": false}, {"t": "wenn Sie und Ihr Mann uns sehr bald besuchen (29).Wir waren schließlich fünf Jahre lang", "b": false}, {"t": "Nachbarn! und trotz (30) schönen neuen Wohnung sind wir ein bisschen traurig, dass wir", "b": false}, {"t": "nicht mehr neben Ihnen wohnen.", "b": false}, {"t": "Viele Liebe Grüße", "b": false}, {"t": "Ihre", "b": false}, {"t": "Edeltraut Augenthaler", "b": false}]}], "maxPoints": 15.0, "availablePoints": 15.0, "missing": 0, "pointsPerItem": 1.5}'::jsonb, 3),
    ('sb2', 'Sprachbausteine', 'Sprachbausteine, Teil 2', 15, 'Lesen Sie den Text und schließen Sie die Lücken 31–40. Benutzen Sie die Wörter aus der Liste. Jedes Wort passt nur einmal.', 'wordbank', '{"bank": [{"key": "A", "text": "AUCH"}, {"key": "B", "text": "BEIDEN"}, {"key": "C", "text": "EINE"}, {"key": "D", "text": "EINIGE"}, {"key": "E", "text": "KÖNNTEN"}, {"key": "F", "text": "MÖCHTE"}, {"key": "G", "text": "MÜSSEN"}, {"key": "H", "text": "OB"}, {"key": "I", "text": "SCHNELLE"}, {"key": "J", "text": "SCHON"}, {"key": "K", "text": "SOLL"}, {"key": "L", "text": "SONDERN"}, {"key": "M", "text": "VORNE"}, {"key": "N", "text": "WANN"}, {"key": "O", "text": "WERDE"}], "bankTitle": "Wörterliste", "passages": [{"paragraphs": [{"t": "Sehr geehrte Damen und Herren, vielen Dank für die (31) Zusendung der Informationsmaterialien. Ich interessiere mich sowohl für das Seminar Schutz gegen Computerviren als (32) für Einführung ins Internet. Dazu habe ich noch (33) Fragen: Ist die Veranstaltung Einführung ins Internet auch wirklich für Anfänger gedacht? Da ich noch gar keine Erfahrung habe, möchte ich mich (34) jetzt auf das Seminar vorbereiten. (35) Sie mir die Schulungsunterlagen bereits vorher schicken? Gibt es für die (36) Seminare noch genügend freie Plätze? Bis (37) muss ich mich spätestens anmelden?", "b": false}, {"t": "Und nun noch eine Frage zur Bezahlung: Auslandsüberweisungen sind sehr teuer, daher (38) ich wissen, (39) man im Voraus bezahlen muss oder auch vor Ort bar bezahlen kann. (40) ich auch eine Kursbestätigung am Ende des Seminars erhalten? Mit freundlichen Grüßen WILLY GATES", "b": false}]}], "maxPoints": 15.0, "availablePoints": 15.0, "missing": 0, "pointsPerItem": 1.5}'::jsonb, 4),
    ('hv1', 'Hörverstehen', 'Hörverstehen, Teil 1', 8, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 5),
    ('hv2', 'Hörverstehen', 'Hörverstehen, Teil 2', 14, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 2.5}'::jsonb, 6),
    ('hv3', 'Hörverstehen', 'Hörverstehen, Teil 3', 8, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 7),
    ('sa', 'Schriftlicher Ausdruck', 'Schriftlicher Ausdruck', 30, 'Antworten Sie Sophie. Schreiben Sie etwas zu allen vier Punkten: Was es Neues bei Ihnen gibt', 'writing', '{"brief": {"intro": "Sie haben folgende E-Mail von Ihrer Freundin Sophie bekommen:", "greeting": "Liebe(r)........", "paragraphs": ["wir haben lange nichts mehr voreinander gehört. Ich hoffe, es geht dir gut. Gibt es bei dir Neuigkeiten? Ich bin nun schon seit zwei Monaten in Würzburg, und mein neuer Job gefällt mir sehr gut. In der Firma fühle ich mich wohl, mit meinen Kollegen verstehe ich mich prima und die Arbeit macht mir großen Spaß.", "Allerdings habe ich ein Problem: Außer meinen Kollegen kenne ich hier in der Stadt noch niemanden. In meiner Freizeit bin ich oft allein und weiß nicht, was ich machen soll. Wie könnte ich neue Leute kennenlernen? Hast du vielleicht einen Tipp für mich? Würzburg ist wirklich eine schöne Stadt mit vielen Sehenswürdigkeiten. Hast du Lust, mich mal an einem Wochenende zu besuchen? Ich würde mich sehr freuen.", "Viele Grüße"], "signature": "Sophie"}, "hints": ["Überlegen Sie sich vor dem Schreiben eine passende Reihenfolge der punkte, eine passende Betreff, eine"], "criteria": [{"title": "Aufgabenbewältigung", "hint": "Sind alle vier Leitpunkte inhaltlich angemessen bearbeitet?"}, {"title": "Kommunikative Gestaltung", "hint": "Anrede, Gruß, passendes Register und verbundene Sätze statt aneinandergereihter Punkte?"}, {"title": "Formale Richtigkeit", "hint": "Stören Fehler in Grammatik, Wortschatz und Rechtschreibung das Verstehen?"}], "grades": [{"key": "A", "points": 5}, {"key": "B", "points": 3}, {"key": "C", "points": 1}, {"key": "D", "points": 0}], "factor": 3, "maxPoints": 45, "availablePoints": 45, "missing": 0}'::jsonb, 8)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'b1' and t.slug = 'modell-03'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('lv1', '1', 'Eine aktuelle Umfrage der Arbeiterkammer unter berufstätigen Eltern zeigt den dringenden Wunsch nach flexiblen Arbeitszeiten (60% der Eltern) und nach Kindergärten im oder in der Nähe des Betriebes (58%). Frauen verlangen aber deutlich mehr Teilzeitarbeitsplätze (50%) als Männer (36%). 52% aller Eltern wünschen eine Ersatzperson, die den Vater oder die Mutter bei Krankheit des Kindes im Betrieb vertritt. Die Arbeiterkammer fordert, dass sich Bedarf der Eltern orientieren.', null::jsonb, 5.0, null::jsonb, 0),
    ('lv1', '2', 'MÜNCHEN: Schüler an bayerischen Gymnasien, die sich für Umwelt oder Technik interessieren, können sich auch dieses Jahr wieder um den Carl Friedrich von Martius Umwelt und Technikpreis bewerben. Bei diesem Wettbewerb werden Facharbeiten aus dem letzten Schuljahr bewertet. Nähere Informationen erhältlich beim GSF- Forschungszentrum unter der Telefonnummer 089/311 87 27 12.', null::jsonb, 5.0, null::jsonb, 1),
    ('lv1', '3', 'WIEN. Eine einmalige Abteilung für drei- bis sechsjährige Kinder wurde im Technischen Museum (15, Mariahitferstraße 112 ) eröffnet. In einem speziell für Kinder eingerichteten Bereich können die jüngsten Besucher Technik angreifen. Dort gibt es unter anderem Plasmascheiben, die Blitze erzeugen, ein Laufrad und ein Hüpfklavier, mit dem die Kinder Töne erspringen können. Viel Spaß macht den Kleinen auch, in einem Elektroauto herumzukurven und sich in verschiedenen Zerrspiegeln zu betrachten.', null::jsonb, 5.0, null::jsonb, 2),
    ('lv1', '4', 'HAMBURG. Männer haben mehr Karrierechancen, Frauen dafür mehr Freude am Beruf: Das ergab eine große Umfrage in Hamburg. Obwohl nur 8% der weiblichen Arbeitnehmer an ihre Aufstiegschancen glauben, geben 61% an, dass ihre Arbeit ihnen Spaß mache. Bei den Männer ist dieses Verhältnis 23 zu 57 Prozent.', null::jsonb, 5.0, null::jsonb, 3),
    ('lv1', '5', 'Für Zufriedenheit am Arbeitsplatz kann Geld allein nicht entscheidend sein. Dies gilt in besonderen Maß für hochqualifizierte europäische Arbeitskräfte, wie eine vergleichende internationale Management-Studie zeigt. Sowohl in Europa wie auch unter japanischen und amerikanischen Managern wird der Möglichkeit, neben der Arbeit auch Zeit für das Privatleben zu haben, ein zentraler Stellenwert beigemessen. Viel stärker als in Japan spielt es unter europäischen Angestellten eine Rolle, dass die Arbeit Spaß macht. Die Analysen zeigen auch, dass neben dem Gehalt der Ruf des Unternehmens für die Arbeitsplatzwahl von europäischen Arbeitnehmern besonders wichtig ist.', null::jsonb, 5.0, null::jsonb, 4),
    ('lv2', '6', 'Die Sendung mit der Maus', '[{"key": "A", "text": "erhält Post aus der ganzen Welt."}, {"key": "B", "text": "hat es schwer, noch neue Themen zu finden."}, {"key": "C", "text": "nimmt nur Vorschläge von Kindern an."}]'::jsonb, 5.0, null::jsonb, 0),
    ('lv2', '7', 'Die Maus', '[{"key": "A", "text": "erzählt die Sachgeschichten."}, {"key": "B", "text": "wird in einer Werbefirma gezeichnet."}, {"key": "C", "text": "wurde von Friedrich Streich erfunden."}]'::jsonb, 5.0, null::jsonb, 1),
    ('lv2', '8', 'Das Thema der Ausstellung', '[{"key": "A", "text": "ist die Geschichte der Sendung mit der Maus."}, {"key": "B", "text": "ist 30 Jahre Junges Museum."}, {"key": "C", "text": "sind Kinder aus aller Welt."}]'::jsonb, 5.0, null::jsonb, 2),
    ('lv2', '9', 'Die Ausstellung', '[{"key": "A", "text": "erlaubt den Kindern, mit den Ausstellungsstücken zu spielen."}, {"key": "B", "text": "erlaubt den Kindern nicht, die Ausstellungsstücke anzufassen."}, {"key": "C", "text": "ist nur für Kinder geöffnet."}]'::jsonb, 5.0, null::jsonb, 3),
    ('lv2', '10', 'Die Maus', '[{"key": "A", "text": "erhält von den Kindern Geschenke aus verschiedenen Materialien."}, {"key": "B", "text": "gibt es nur auf Postkarten und Plakaten zu kaufen."}, {"key": "C", "text": "ist aus Wolle und Papier."}]'::jsonb, 5.0, null::jsonb, 4),
    ('lv3', '11', 'Sie möchten als Student nebenbei Geld verdienen. Sie reisen gern.', null::jsonb, 2.5, null::jsonb, 0),
    ('lv3', '12', 'Sie interessieren sich für Literatur aus arabischen Ländern.', null::jsonb, 2.5, null::jsonb, 1),
    ('lv3', '13', 'Ihr Freund möchte gerne in einem Kino arbeiten.', null::jsonb, 2.5, null::jsonb, 2),
    ('lv3', '14', 'Sie wollen in einem Restaurant arbeiten und dort auch wohnen.', null::jsonb, 2.5, null::jsonb, 3),
    ('lv3', '15', 'Ihre Freundin sucht einen Kindergartenplatz für ihren kleinen Sohn.', null::jsonb, 2.5, null::jsonb, 4),
    ('lv3', '16', 'Sie möchten am nächsten Wochenende in eine Diskothek gehen.', null::jsonb, 2.5, null::jsonb, 5),
    ('lv3', '17', 'Sie möchten tanzen lernen.', null::jsonb, 2.5, null::jsonb, 6),
    ('lv3', '18', 'Sie haben große Berufserfahrung in Gaststätten. Jetzt möchten Sie ein Restaurant leiten.', null::jsonb, 2.5, null::jsonb, 7),
    ('lv3', '19', 'Sie möchten Filme aus afrikanischen Ländern sehen.', null::jsonb, 2.5, null::jsonb, 8),
    ('lv3', '20', 'Sie möchten einen Fotografiekurs besuchen und haben nur abends Zeit.', null::jsonb, 2.5, null::jsonb, 9),
    ('sb1', '21', 'Liebe Vollzwinkler, wir wohnen jetzt schon (21) sechs Wochen in unserer neuen Wohnung. Zwar ist immer …', '[{"key": "A", "text": "ab"}, {"key": "B", "text": "seit"}, {"key": "C", "text": "vor"}]'::jsonb, 1.5, null::jsonb, 0),
    ('sb1', '22', '… Zwar ist immer noch nicht alles so eingerichtet, wie Wir (22) das wünschen .Aber wir wussten ja. Dass das einige Zeit …', '[{"key": "A", "text": "ihnen"}, {"key": "B", "text": "sich"}, {"key": "C", "text": "uns"}]'::jsonb, 1.5, null::jsonb, 1),
    ('sb1', '23', '… das wünschen .Aber wir wussten ja. Dass das einige Zeit (23) würde, bis alles fertig ist. Natürlich haben wir uns …', '[{"key": "A", "text": "dauern"}, {"key": "B", "text": "dauert"}, {"key": "C", "text": "gedauert"}]'::jsonb, 1.5, null::jsonb, 2),
    ('sb1', '24', '… Kinder durften sich die Farben für die Wände selbst (24) Sie haben sich für Blau und Gelb entschieden. Meinem Mann …', '[{"key": "A", "text": "ausgesucht"}, {"key": "B", "text": "aussuchen"}, {"key": "C", "text": "aussuchten"}]'::jsonb, 1.5, null::jsonb, 3),
    ('sb1', '25', '… Sie haben sich für Blau und Gelb entschieden. Meinem Mann (25) das am Anfang gar nicht gefallen, aber jetzt hat er sich …', '[{"key": "A", "text": "hat"}, {"key": "B", "text": "ist"}, {"key": "C", "text": "wird"}]'::jsonb, 1.5, null::jsonb, 4),
    ('sb1', '26', '… das am Anfang gar nicht gefallen, aber jetzt hat er sich (26) gewöhnt. Jetzt fehlt eigentlich nur noch das Wohnzimmer. …', '[{"key": "A", "text": "daran"}, {"key": "B", "text": "darüber"}, {"key": "C", "text": "davon"}]'::jsonb, 1.5, null::jsonb, 5),
    ('sb1', '27', '… nur noch das Wohnzimmer. Wir warten auf die neuen Möbel (27) wir gekauft haben. In der (28) Woche kommen sie endlich. …', '[{"key": "A", "text": "das"}, {"key": "B", "text": "den"}, {"key": "C", "text": "die"}]'::jsonb, 1.5, null::jsonb, 6),
    ('sb1', '28', '… warten auf die neuen Möbel (27) wir gekauft haben. In der (28) Woche kommen sie endlich. Dann können auch wieder Gäste …', '[{"key": "A", "text": "nächsten"}, {"key": "B", "text": "nächster"}, {"key": "C", "text": "nächstes"}]'::jsonb, 1.5, null::jsonb, 7),
    ('sb1', '29', '… sehr freuen, wenn Sie und Ihr Mann uns sehr bald besuchen (29).Wir waren schließlich fünf Jahre lang Nachbarn! und trotz …', '[{"key": "A", "text": "worden"}, {"key": "B", "text": "wurden"}, {"key": "C", "text": "würden"}]'::jsonb, 1.5, null::jsonb, 8),
    ('sb1', '30', '… waren schließlich fünf Jahre lang Nachbarn! und trotz (30) schönen neuen Wohnung sind wir ein bisschen traurig, dass …', '[{"key": "A", "text": "unser"}, {"key": "B", "text": "unserer"}, {"key": "C", "text": "unseres"}]'::jsonb, 1.5, null::jsonb, 9),
    ('sb2', '31', 'Sehr geehrte Damen und Herren, vielen Dank für die (31) Zusendung der Informationsmaterialien. Ich interessiere …', null::jsonb, 1.5, null::jsonb, 0),
    ('sb2', '32', '… sowohl für das Seminar Schutz gegen Computerviren als (32) für Einführung ins Internet. Dazu habe ich noch (33) …', null::jsonb, 1.5, null::jsonb, 1),
    ('sb2', '33', '… als (32) für Einführung ins Internet. Dazu habe ich noch (33) Fragen: Ist die Veranstaltung Einführung ins Internet …', null::jsonb, 1.5, null::jsonb, 2),
    ('sb2', '34', '… Da ich noch gar keine Erfahrung habe, möchte ich mich (34) jetzt auf das Seminar vorbereiten. (35) Sie mir die …', null::jsonb, 1.5, null::jsonb, 3),
    ('sb2', '35', '… möchte ich mich (34) jetzt auf das Seminar vorbereiten. (35) Sie mir die Schulungsunterlagen bereits vorher schicken? …', null::jsonb, 1.5, null::jsonb, 4),
    ('sb2', '36', '… bereits vorher schicken? Gibt es für die (36) Seminare noch genügend freie Plätze? Bis (37) muss ich …', null::jsonb, 1.5, null::jsonb, 5),
    ('sb2', '37', '… es für die (36) Seminare noch genügend freie Plätze? Bis (37) muss ich mich spätestens anmelden? Und nun noch eine …', null::jsonb, 1.5, null::jsonb, 6),
    ('sb2', '38', '… Bezahlung: Auslandsüberweisungen sind sehr teuer, daher (38) ich wissen, (39) man im Voraus bezahlen muss oder auch …', null::jsonb, 1.5, null::jsonb, 7),
    ('sb2', '39', '… sind sehr teuer, daher (38) ich wissen, (39) man im Voraus bezahlen muss oder auch vor Ort bar …', null::jsonb, 1.5, null::jsonb, 8),
    ('sb2', '40', '… Voraus bezahlen muss oder auch vor Ort bar bezahlen kann. (40) ich auch eine Kursbestätigung am Ende des Seminars …', null::jsonb, 1.5, null::jsonb, 9),
    ('hv1', '41', 'Der Sprecher hat zu Hause keinen Computer.', null::jsonb, 5.0, null::jsonb, 0),
    ('hv1', '42', 'Der Sprecher benutzt den Computer nur am Arbeitsplatz.', null::jsonb, 5.0, null::jsonb, 1),
    ('hv1', '43', 'Die Sprecherin lehnt Computer ab.', null::jsonb, 5.0, null::jsonb, 2),
    ('hv1', '44', 'Die Sprecherin hat kein großes Vertrauen zu Computern.', null::jsonb, 5.0, null::jsonb, 3),
    ('hv1', '45', 'Die Sprecherin braucht den Computer im täglichen Leben.', null::jsonb, 5.0, null::jsonb, 4),
    ('hv2', '46', 'Herr Bachinger hat ein Buch über Väter geschrieben.', null::jsonb, 2.5, null::jsonb, 0),
    ('hv2', '47', 'Herr Bachinger hat vor zehn Monaten geheiratet.', null::jsonb, 2.5, null::jsonb, 1),
    ('hv2', '48', 'Herr Bachinger meint, dass die Zeitungen mehr über moderne Familien berichten sollen.', null::jsonb, 2.5, null::jsonb, 2),
    ('hv2', '49', 'Herr Bachinger konnte seinen Chef sofort überzeugen.', null::jsonb, 2.5, null::jsonb, 3),
    ('hv2', '50', 'Hausarbeit war für Herrn Bachinger nichts Neues.', null::jsonb, 2.5, null::jsonb, 4),
    ('hv2', '51', 'Seine Kollegen haben ihn anfangs sehr vermisst.', null::jsonb, 2.5, null::jsonb, 5),
    ('hv2', '52', 'Herr Bachinger hat gegen viele Vorurteile kämpfen müssen.', null::jsonb, 2.5, null::jsonb, 6),
    ('hv2', '53', 'Herr Bachinger hat das Buch für andere Väter geschrieben.', null::jsonb, 2.5, null::jsonb, 7),
    ('hv2', '54', 'Er will erst wieder arbeiten gehen, wenn sein Sohn in die Schule kommt.', null::jsonb, 2.5, null::jsonb, 8),
    ('hv2', '55', 'Herr Bachinger meint, dass Teilzeitarbeit für ihn das Beste sei.', null::jsonb, 2.5, null::jsonb, 9),
    ('hv3', '56', 'Der Fahrer des Wagens mit dem Kennzeichen HB-D 256 soll ins Erdgeschoss kommen.', null::jsonb, 5.0, null::jsonb, 0),
    ('hv3', '57', 'Die Firma liefert das bestellte Sofa am Dienstag ab drei Uhr nachmittags.', null::jsonb, 5.0, null::jsonb, 1),
    ('hv3', '58', 'Der Gasthof Lindner ist neben einer Tankstelle.', null::jsonb, 5.0, null::jsonb, 2),
    ('hv3', '59', 'Der Film Komiker läuft täglich um 20 Uhr.', null::jsonb, 5.0, null::jsonb, 3),
    ('hv3', '60', 'Das Wetter ist am Abend noch gut.', null::jsonb, 5.0, null::jsonb, 4),
    ('sa', 'A', 'Antworten Sie Sophie. Schreiben Sie etwas zu allen vier Punkten: Was es Neues bei Ihnen gibt', null::jsonb, 0, '{"minWords": 100, "points": ["Was Sie selbst gerne in Ihrer Freizeit machen", "Tipps für Sophie", "Reaktion auf den Vorschlag"]}'::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'b1' and t.slug = 'modell-03'
join sections s on s.test_id = t.id and s.section_id = v.section_id
on conflict (section_id, item_id) do update set text = excluded.text, options = excluded.options, points = excluded.points, meta = excluded.meta, sort = excluded.sort;

insert into item_answers (item_id, answer, explanation)
select i.id, v.answer, v.explanation
from (values
    ('lv1', '1', 'J', null),
    ('lv1', '2', 'I', null),
    ('lv1', '3', 'G', null),
    ('lv1', '4', 'C', null),
    ('lv1', '5', 'D', null),
    ('lv2', '6', 'C', null),
    ('lv2', '7', 'A', null),
    ('lv2', '8', 'A', null),
    ('lv2', '9', 'A', null),
    ('lv2', '10', 'A', null),
    ('lv3', '11', 'D', null),
    ('lv3', '12', 'K', null),
    ('lv3', '13', 'J', null),
    ('lv3', '14', 'A', null),
    ('lv3', '15', 'H', null),
    ('lv3', '16', 'X', null),
    ('lv3', '17', 'I', null),
    ('lv3', '18', 'F', null),
    ('lv3', '19', 'B', null),
    ('lv3', '20', 'X', null),
    ('sb1', '21', 'B', null),
    ('sb1', '22', 'C', null),
    ('sb1', '23', 'A', null),
    ('sb1', '24', 'B', null),
    ('sb1', '25', 'A', null),
    ('sb1', '26', 'A', null),
    ('sb1', '27', 'C', null),
    ('sb1', '28', 'A', null),
    ('sb1', '29', 'C', null),
    ('sb1', '30', 'B', null),
    ('sb2', '31', 'I', 'Das Wort lautet: SCHNELLE'),
    ('sb2', '32', 'A', 'Das Wort lautet: AUCH'),
    ('sb2', '33', 'D', 'Das Wort lautet: EINIGE'),
    ('sb2', '34', 'J', 'Das Wort lautet: SCHON'),
    ('sb2', '35', 'E', 'Das Wort lautet: KÖNNTEN'),
    ('sb2', '36', 'B', 'Das Wort lautet: BEIDEN'),
    ('sb2', '37', 'N', 'Das Wort lautet: WANN'),
    ('sb2', '38', 'F', 'Das Wort lautet: MÖCHTE'),
    ('sb2', '39', 'H', 'Das Wort lautet: OB'),
    ('sb2', '40', 'O', 'Das Wort lautet: WERDE'),
    ('hv1', '41', 'f', null),
    ('hv1', '42', 'f', null),
    ('hv1', '43', 'r', null),
    ('hv1', '44', 'r', null),
    ('hv1', '45', 'f', null),
    ('hv2', '46', 'r', null),
    ('hv2', '47', 'f', null),
    ('hv2', '48', 'f', null),
    ('hv2', '49', 'r', null),
    ('hv2', '50', 'r', null),
    ('hv2', '51', 'f', null),
    ('hv2', '52', 'f', null),
    ('hv2', '53', 'f', null),
    ('hv2', '54', 'r', null),
    ('hv2', '55', 'f', null),
    ('hv3', '56', 'r', null),
    ('hv3', '57', 'f', null),
    ('hv3', '58', 'r', null),
    ('hv3', '59', 'r', null),
    ('hv3', '60', 'f', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'b1' and t.slug = 'modell-03'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;

-- ================= modell-04 · NADIA2 =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('b1', 'modell-04', 'NADIA2', '61 Aufgaben · 150 Minuten',
        '[{"id": "block-lv-sb", "title": "Leseverstehen und Sprachbausteine", "minutes": 90, "hint": "Aufgaben 1–40", "parts": ["lv1", "lv2", "lv3", "sb1", "sb2"], "maxPoints": 105.0, "availablePoints": 105.0, "missing": 0}, {"id": "block-hv", "title": "Hörverstehen", "minutes": 30, "hint": "Aufgaben 41–60", "parts": ["hv1", "hv2", "hv3"], "maxPoints": 75.0, "availablePoints": 75.0, "missing": 0}, {"id": "block-sa", "title": "Schriftlicher Ausdruck", "minutes": 30, "hint": "", "parts": ["sa"], "maxPoints": 45.0, "availablePoints": 45, "missing": 0}]'::jsonb, 61, true, 4)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('lv1', 'Leseverstehen', 'Leseverstehen, Teil 1', 15, 'Lesen Sie die Überschriften a–j und die Texte 1–5. Finden Sie für jeden Text die passende Überschrift. Jede Überschrift passt nur einmal.', 'matching', '{"bank": [{"key": "A", "text": "Bilder mit dem Computer bearbeiten"}, {"key": "B", "text": "Kirche bietet Backkurs für Kinder an"}, {"key": "C", "text": "Kirche eröffnet neuen Treffpunkt"}, {"key": "D", "text": "Neu: Kochbuch über Weiner Fleischgerichte"}, {"key": "E", "text": "Neue Computerprogramme werden getestet"}, {"key": "F", "text": "Preis für bestes Lernprogramm"}, {"key": "G", "text": "Rezepte für Kuchen und Torten"}, {"key": "H", "text": "Studie zeigt: Kaffeetrinker sind glücklicher"}, {"key": "I", "text": "Warum die Wiener ins Café gehen"}, {"key": "J", "text": "Zürcher Fotografen stellen aus"}], "bankTitle": "Überschriften", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 0),
    ('lv2', 'Leseverstehen', 'Leseverstehen, Teil 2', 20, 'Lesen Sie den Text und die Aufgaben 6–10. Welche Lösung (A, B oder C) ist jeweils richtig?', 'mc', '{"passages": [{"paragraphs": [{"t": "Verheiratet mit Handy und Computer", "b": true}, {"t": "Die Woche mit sechzig bis achtzig Arbeitsstunden war für Volkmar Bergmann ganz normal. Der Gründer und Chefingenieur einer Software – Firma hatte von montags bis freitags einen Zwölfstundentag und arbeite auch an Samstagen und Sonntagen. Das Geschäft ging sehr gut. Die Firma wurde immer größer: 1.100 Mitarbeiterinnen und Mitarbeiter – darauf konnte Volkmar Bergmann wirklich stolz sein. Die Arbeit machte ihm Spaß, jedenfalls so lange bis sein Sohn geboren wurde. Auf einmal fing ich an, die Dinge in einem anderen Licht zu sehen Stress mit Nacht – und Wochenendarbeit heraus zukommen. Jahrelang gelang ihm das nicht. Erst als er sich entschlossen hatte, sein Leben vollkommen zu ändern, wurde es besser: Heute arbeitet Bergmann nur 20 Stunden die Woche, als Berater für die Firma, die ihm früher einmal gehörte. Er hat Zeit für die Kinder und sagt: Ich bin zufriedener als jemals zuvor in meinem Leben. Glück gehabt Anderen Vielarbeiten ist eine solche Änderung nicht möglich sie bleiben mit ihrem Schreibtisch verheiratet Ein 24 Stunden Arbeitstag ist der Trend sagt Bryan EE. Robinson Professor in den USA Millionen von Arbeitnehmern geben ihre ganze Kraft für ihnen Job. Wir leben in einer Welt die vor allem den Menschen alle Chancen bietet, für die die Arbeit das Wichtigste im Leben ist, den so genannten Workaholics Diese Menschen können Gutes nur doch in ihrer Arbeit tun. Sie haben längst die Fähigkeit verloren ein Privatleben zu führen und sich um ihre Familie und die Freunde zu kümmern.", "b": false}, {"t": "Die Schwierigkeiten der Menschen, die an der Krankheiten Workaholismus leiden nehmen ständigen zu immer Mehr Menschen laufen Gefahr von ihrer Arbeit regelrecht aufgefressen zu werden Das Ende dieser Entwicklung lässt sich leicht absehen: absehen Die Mitarbeiter werden häufiger krank Arbeitsfreude und Motivation nehmen ab, es kommt zu Fehlen und Pannen. Das Familienleben leidet.", "b": false}, {"t": "Moderne Technik und Medien machen es möglich: Durch das Handy ist man überall und jeder Zeit erreichbar. Mit Laptops und Mini – Computern ist man unabhängig vom Arbeitsplatz und kann von jedem Ort der Welt aus im Internet surfen oder seine elektronische Post erledigen. Die räumliche Grenze zwischen dem Zuhause und dem Büro besteht für viele nicht mehr. Der Arbeitsplatz wird als Zuhause angesehen und das Zuhause wird zum Arbeitsplatz Eigentlich waren die neuen Medien dazu gedacht, die Arbeit einfacher zu machen. In Wirklichkeit führen sie dazu, dass die Arbeit immer tiefer in den Bereich der Freizeit eindringt. Ein Privatleben, in dem man von der Arbeit einmal ganz abschalten kann, gibt es schon heute für viele nicht mehr.", "b": false}, {"t": "Inzwischen gibt es Seminare für Arbeitskranke in denen die Teilnehmenden lernen sollen wieder zu leben und nicht nur zu funktionieren: Der Psychologe Ulrich Beer gibt seinen Patienten in einer solchen Situation einen einfach Ral: im Kalender müssen genau so viele private wie berufliche Termine stehen Familie und Beruf sind", "b": false}, {"t": "gleich wichtig", "b": false}]}], "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 1),
    ('lv3', 'Leseverstehen', 'Leseverstehen, Teil 3', 20, 'Lesen Sie die Situationen 11–20 und die Anzeigen im Bild. Finden Sie für jede Situation die passende Anzeige. Wenn Sie keine passende Anzeige finden, wählen Sie X.', 'matching', '{"bank": [{"key": "A", "text": ""}, {"key": "B", "text": ""}, {"key": "C", "text": ""}, {"key": "D", "text": ""}, {"key": "E", "text": ""}, {"key": "F", "text": ""}, {"key": "G", "text": ""}, {"key": "H", "text": ""}, {"key": "I", "text": ""}, {"key": "J", "text": ""}, {"key": "K", "text": ""}, {"key": "L", "text": ""}, {"key": "X", "text": ""}], "bankTitle": "Anzeigen", "bankImage": "img/m04-lv3.jpg", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 2.5}'::jsonb, 2),
    ('sb1', 'Sprachbausteine', 'Sprachbausteine, Teil 1', 20, 'Lesen Sie den Text und schließen Sie die Lücken 21–30. Welche Lösung (A, B oder C) ist jeweils richtig?', 'mc', '{"passages": [{"paragraphs": [{"t": "Sehr geehrter Herr Meyerhofer,", "b": false}, {"t": "Wie Sie wissen , miete ich nun schon seit drei Jahren eine Wohnung in (21)Haus. Ich (22) die ganze Zeit sehr zufrieden, denn im Haus war es immer ruhig, sauber und sicher. In der Zwischenzeit (23) sich die Wohnqualität durch die Eröffnung des Restaurants im Erdgeschoss aber deutlich verschlechtert.(24) spät abends höre ich nun täglich (25) Lärm der Restaurantsgäste im Garten, die Mülleimer im Hof sind immer überfüllt, die Parkplätze vor dem Haus, (26) eigentlich für die Mieter reserviert sind , sind immer besetzt, und das Treppenhaus ist ständig verschmutzt. Außerdem fühle ich mich (27) Haus nicht mehr sicher, weil das Restaurant oft die ganze Nacht (28) hat.", "b": false}, {"t": "Ich möchte Sie dringend bitten, such um diese (29) zu kümmern und mit den Restaurantbesitzern zu sprechen. Vielleicht könnte (30) Gemeinsam eine Lösung finden.", "b": false}, {"t": "Mit freundlichen Grüßen", "b": false}, {"t": "Ihre Anneliese Kühne", "b": false}]}], "maxPoints": 15.0, "availablePoints": 15.0, "missing": 0, "pointsPerItem": 1.5}'::jsonb, 3),
    ('sb2', 'Sprachbausteine', 'Sprachbausteine, Teil 2', 15, 'Lesen Sie den Text und schließen Sie die Lücken 31–40. Benutzen Sie die Wörter aus der Liste. Jedes Wort passt nur einmal.', 'wordbank', '{"bank": [{"key": "A", "text": "ABER"}, {"key": "B", "text": "DAMIT"}, {"key": "C", "text": "DER"}, {"key": "D", "text": "IN"}, {"key": "E", "text": "MANCHMAL"}, {"key": "F", "text": "MIT"}, {"key": "G", "text": "PAAR"}, {"key": "H", "text": "SCHON"}, {"key": "I", "text": "SEHR"}, {"key": "J", "text": "TROTZ"}, {"key": "K", "text": "WANN"}, {"key": "L", "text": "WEIL"}, {"key": "M", "text": "WENN"}, {"key": "N", "text": "WIE"}, {"key": "O", "text": "ZU"}], "bankTitle": "Wörterliste", "passages": [{"paragraphs": [{"t": "Sehr geehrte Damen und Herren,", "b": false}, {"t": "ich habe Ihre Anzeige gelesen und interessiere mich sehr für Ihr Angebot. Ich komme aus Kroatien und möchte (31) den nächsten Sommerferien mein Deutsch verbessern. Klagenfurt ist für mich der ideale Ort, (32) das nicht so weit weg von meiner Heimatstadt Zagreb ist. Da kann ich an den Wochenenden vielleicht auch (33) nach Hause fahren. Nun aber zu meiner Person: Ich bin 24 Jahre alt und habe in der Schule vier Jahre lang Deutsch gelernt. Ich kann zwar (34) ganz gut schreiben, (35) ich habe immer wieder Probleme beim freien Sprechen. Im Herbst möchte ich in Hamburg ein Studium beginnen, für das ich ebenfalls gute Deutschkenntnisse brauche.", "b": false}, {"t": "Am liebsten wäre mir ein vierwöchiger Deutschkurs, (36) nur vormittags stattfindet, (37) ich nachmittags etwas anderes machen kann. Ich hätte den ganzen August bis Mitte September Zeit.", "b": false}, {"t": "(38) Sie einen passenden Kurs für mich haben, schicken Sie mir bitte sobald (39) möglich nähere Informationen zu. Mich interessieren auch Ihre Freizeitprogramme, Spezialkurse, die Unterkunftsmöglichkeiten und natürlich die Preise.", "b": false}, {"t": "Bitte empfehlen Sie mir auch ein (40) gute Webseiten über Klagenfurt und den Wörthersee.", "b": false}, {"t": "Vielen Dank im Voraus und freundliche Grüße", "b": false}, {"t": "Ivica Palic", "b": false}]}], "maxPoints": 15.0, "availablePoints": 15.0, "missing": 0, "pointsPerItem": 1.5}'::jsonb, 4),
    ('hv1', 'Hörverstehen', 'Hörverstehen, Teil 1', 8, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 5),
    ('hv2', 'Hörverstehen', 'Hörverstehen, Teil 2', 14, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 2.5}'::jsonb, 6),
    ('hv3', 'Hörverstehen', 'Hörverstehen, Teil 3', 8, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 7),
    ('sa', 'Schriftlicher Ausdruck', 'Schriftlicher Ausdruck', 30, 'Antworten Sie auf den Brief. Schreiben Sie etwas zu den folgenden vier Punkten:', 'writing', '{"brief": {"intro": "Sie haben von einer Freundin folgenden Brief erhalten:", "greeting": "Liebe(r)........", "paragraphs": ["ich hoffe, dir geht’s gut. stell dir vor, bei mir gibt es Neuigkeiten Du weißt doch, dass wir schon lange von einem Garten geträumt haben. Jetzt haben wir endlich einen am Stadtrand gefunden. Da er sehr groß ist. Wollte ich dich fragen, ob du nicht Lust hast den Garten mit uns zu teilen. Die Miete ist gar nicht so hoch . Du könntest dort Salat und Gemüse anpflanzen, natürlich auch Blumen ganz wie du willst. Es gibt auch Obstbäume und eine große Wiese, auf der man sich einfach hinlegen, und wir könnten im Garten auch grillen. Was denkst du? Wäre das nicht toll.", "Antworte mir bald.", "Alles Liebe"], "signature": "Deine Nadja"}, "hints": ["Überlegen Sie sich vor dem Schreiben eine passende Reihenfolge der punkte, eine passende Betreff, eine"], "criteria": [{"title": "Aufgabenbewältigung", "hint": "Sind alle vier Leitpunkte inhaltlich angemessen bearbeitet?"}, {"title": "Kommunikative Gestaltung", "hint": "Anrede, Gruß, passendes Register und verbundene Sätze statt aneinandergereihter Punkte?"}, {"title": "Formale Richtigkeit", "hint": "Stören Fehler in Grammatik, Wortschatz und Rechtschreibung das Verstehen?"}], "grades": [{"key": "A", "points": 5}, {"key": "B", "points": 3}, {"key": "C", "points": 1}, {"key": "D", "points": 0}], "factor": 3, "maxPoints": 45, "availablePoints": 45, "missing": 0}'::jsonb, 8)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'b1' and t.slug = 'modell-04'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('lv1', '1', '– Die Kunst und Medienschule F+ F Zürich bietet bereits zum dritten Mal den Computerkurs Digitale Bildbearbeitung an im neuen Semester steht für zehn Samstage Fotografie nach der Fotografie also die digitale Bearbeitung von Bildern im Mittelpunkt Dabei kommen verschiedene Softwareprodukte zum Einsatz Der Kurs befasst sich aber nicht nur mit dem – – Vermitteln auch Themen und Problembereiche rund um die digitale Foto und Bildbearbeitung kurskosten 800Franken Nähere Informationen und Anmeldung zu diesem Kurs www.f- f.ch.', null::jsonb, 5.0, null::jsonb, 0),
    ('lv1', '2', '– Neuperlach-Süd Nach dem Einkaufen eine Kaffee genießen, mit anderen ins Gespräch Immen, sich mit Bekannten treffen oder einfach spannen all das geht ab 11 Juli immer – – dienstags zwischen 14 und 18 Uhr im neuen Eiscafé der Dietrich Bonhoeffer Kirche Wir hotten damit einen Ort der Begegnung für Jung und Alt anbieten und zur Belebung des Stadtteils beitragen erklärt Pfarrer Sebastian Kühnen. Neben kalten und heißen Getränken sowie Kuchen steht während der Öffnungszeiten auch eine Mitarbeiten für Gespräch zur Verfügung.', null::jsonb, 5.0, null::jsonb, 1),
    ('lv1', '3', 'Geheimnisse der modernen Konditorkunst der Meister des Süßen, Herwig Gasser, in Jahre hinweg sammelte der Bäcker des berühmten Wiener Café Landmann Mehlspeisenrezepte. Von der Birnentorte über den Apfelstrudel bis hin zum Heidelbeerstolle Verlag Kettel, 110 Fotos, 300 Seiten. – – ISBAN 3 85134 014 -0', null::jsonb, 5.0, null::jsonb, 2),
    ('lv1', '4', 'Am Montag wird in Stuttgart die Bildungs-Didacta eröffnet. Dort werden vor allem Lehrmaterialien vorgestellt. Bei vielen sich um Bildungssoftware. Für ein gelungenes Softwareprojekt wird am der Bildungssoftwarepreis digital vergeben Dabei handelt es sich um die wichtige Auszeichnung für Lehr und Lernprogramm deutschsprachigen Raum Die verzeichnen mit dem digital multimediale Gebote aus, die inhaltlich und formal als ragend und beispielgebend gelten können.', null::jsonb, 5.0, null::jsonb, 3),
    ('lv1', '5', '– Des Gallup Instituts hat sich mit Kaffeehausverhaltens der Wiener Ein Vorurteil hat sich dabei bestätigt Kaffeehaus und der Wiener Seine Melange Ergebnisse der Studie 27 der an, zumindest einmal im Monat der Nähe ihrer Wohnung zu gehen. Durchschnittlich 54 Minuten Befragten in ihrem Stamm Café Kundschaft umso länger wird gegessen. Der Grund ein Kaffeehaus wichtiger ist das Plaudern und Freunden. 77 der Befragten Grund für den Besuch im Kaffeehaus.', null::jsonb, 5.0, null::jsonb, 4),
    ('lv2', '6', 'Volkmar Bergmann', '[{"key": "A", "text": "wollte bei einer anderen Firma arbeiten."}, {"key": "B", "text": "wollte mehr Zeit für sein Privatleben haben."}, {"key": "C", "text": "wollte nur noch nachts und an Wochenenden arbeiten."}]'::jsonb, 5.0, null::jsonb, 0),
    ('lv2', '7', 'Es gibt viele Menschen,', '[{"key": "A", "text": "die gerne einen anderen Schreibtisch hätten."}, {"key": "B", "text": "die heute bereits arbeitskrank sind."}, {"key": "C", "text": "die pro Woche nur noch 24 Stunden arbeiten."}]'::jsonb, 5.0, null::jsonb, 1),
    ('lv2', '8', 'Durch die moderne Technik', '[{"key": "A", "text": "haben die Menschen mehr Zeit für das Privatleben."}, {"key": "B", "text": "kann die Arbeit fast überall erledigt werden."}, {"key": "C", "text": "wird es in Zukunft immer weniger Arbeit geben."}]'::jsonb, 5.0, null::jsonb, 2),
    ('lv2', '9', 'Laut Professor Robinson', '[{"key": "A", "text": "wollen viele Menschen weniger arbeiten."}, {"key": "B", "text": "kann viel Arbeit den Menschen gut tun."}, {"key": "C", "text": "leben viele Menschen nur noch für ihren Beruf."}]'::jsonb, 5.0, null::jsonb, 3),
    ('lv2', '10', 'In Seminaren sollen die Teilnehmer lernen,', '[{"key": "A", "text": "kranken Mitarbeitern zu helfen."}, {"key": "B", "text": "wie man die Arbeit im Büro besser organisieren kann."}, {"key": "C", "text": "ein gesundes Verhältnis zur Arbeit zu finden."}]'::jsonb, 5.0, null::jsonb, 4),
    ('lv3', '11', 'Sie wollen am Wochenende gerne in ein Klavierkonzert gehen.', null::jsonb, 2.5, null::jsonb, 0),
    ('lv3', '12', 'Sie sind in Füssen und wollen am Montag ins Museum gehen.', null::jsonb, 2.5, null::jsonb, 1),
    ('lv3', '13', 'Sie sind in Süddeutschland im Urlaub und möchten gerne eine bayerische Spezialität essen.', null::jsonb, 2.5, null::jsonb, 2),
    ('lv3', '14', 'Sie haben sich mit Bekannten zu einem Fischessen verabredet.', null::jsonb, 2.5, null::jsonb, 3),
    ('lv3', '15', 'Sie sind in Bayern und wollen Käsespezialitäten einkaufen.', null::jsonb, 2.5, null::jsonb, 4),
    ('lv3', '16', 'Sie möchten einen Deutschkurs in Wien besuchen.', null::jsonb, 2.5, null::jsonb, 5),
    ('lv3', '17', 'Ihr 16 jähriger Sohn soll in den Ferien im Ausland Englisch lernen.', null::jsonb, 2.5, null::jsonb, 6),
    ('lv3', '18', 'Sie interessieren sich für einen Sprachkurs auf CD.', null::jsonb, 2.5, null::jsonb, 7),
    ('lv3', '19', 'Sie wollen, dass Ihre 10- jährige Tochter in den Ferien eine Fremdsprache lernt.', null::jsonb, 2.5, null::jsonb, 8),
    ('lv3', '20', 'Eine Bekannte will ihren Geburtstag in einem Restaurant feiern und dort auch übernachten.', null::jsonb, 2.5, null::jsonb, 9),
    ('sb1', '21', '… , miete ich nun schon seit drei Jahren eine Wohnung in (21)Haus. Ich (22) die ganze Zeit sehr zufrieden, denn im Haus …', '[{"key": "A", "text": "Ihr"}, {"key": "B", "text": "Ihrem"}, {"key": "C", "text": "Ihren"}]'::jsonb, 1.5, null::jsonb, 0),
    ('sb1', '22', '… nun schon seit drei Jahren eine Wohnung in (21)Haus. Ich (22) die ganze Zeit sehr zufrieden, denn im Haus war es immer …', '[{"key": "A", "text": "war"}, {"key": "B", "text": "wäre"}, {"key": "C", "text": "würde"}]'::jsonb, 1.5, null::jsonb, 1),
    ('sb1', '23', '… es immer ruhig, sauber und sicher. In der Zwischenzeit (23) sich die Wohnqualität durch die Eröffnung des Restaurants …', '[{"key": "A", "text": "hat"}, {"key": "B", "text": "ist"}, {"key": "C", "text": "wurde"}]'::jsonb, 1.5, null::jsonb, 2),
    ('sb1', '24', '… Restaurants im Erdgeschoss aber deutlich verschlechtert.(24) spät abends höre ich nun täglich (25) Lärm der …', '[{"key": "A", "text": "Bis"}, {"key": "B", "text": "Nach"}, {"key": "C", "text": "Von"}]'::jsonb, 1.5, null::jsonb, 3),
    ('sb1', '25', '… verschlechtert.(24) spät abends höre ich nun täglich (25) Lärm der Restaurantsgäste im Garten, die Mülleimer im Hof …', '[{"key": "A", "text": "dem"}, {"key": "B", "text": "den"}, {"key": "C", "text": "der"}]'::jsonb, 1.5, null::jsonb, 4),
    ('sb1', '26', '… im Hof sind immer überfüllt, die Parkplätze vor dem Haus, (26) eigentlich für die Mieter reserviert sind , sind immer …', '[{"key": "A", "text": "denen"}, {"key": "B", "text": "die"}, {"key": "C", "text": "diese"}]'::jsonb, 1.5, null::jsonb, 5),
    ('sb1', '27', '… ist ständig verschmutzt. Außerdem fühle ich mich (27) Haus nicht mehr sicher, weil das Restaurant oft die ganze …', '[{"key": "A", "text": "im"}, {"key": "B", "text": "in"}, {"key": "C", "text": "ins"}]'::jsonb, 1.5, null::jsonb, 6),
    ('sb1', '28', '… mehr sicher, weil das Restaurant oft die ganze Nacht (28) hat. Ich möchte Sie dringend bitten, such um diese (29) …', '[{"key": "A", "text": "geöffnet"}, {"key": "B", "text": "öffnen"}, {"key": "C", "text": "öffnet"}]'::jsonb, 1.5, null::jsonb, 7),
    ('sb1', '29', '… (28) hat. Ich möchte Sie dringend bitten, such um diese (29) zu kümmern und mit den Restaurantbesitzern zu sprechen. …', '[{"key": "A", "text": "Problem"}, {"key": "B", "text": "Probleme"}, {"key": "C", "text": "Problemen"}]'::jsonb, 1.5, null::jsonb, 8),
    ('sb1', '30', '… den Restaurantbesitzern zu sprechen. Vielleicht könnte (30) Gemeinsam eine Lösung finden. Mit freundlichen Grüßen …', '[{"key": "A", "text": "er"}, {"key": "B", "text": "man"}, {"key": "C", "text": "wir"}]'::jsonb, 1.5, null::jsonb, 9),
    ('sb2', '31', '… sehr für Ihr Angebot. Ich komme aus Kroatien und möchte (31) den nächsten Sommerferien mein Deutsch verbessern. …', null::jsonb, 1.5, null::jsonb, 0),
    ('sb2', '32', '… verbessern. Klagenfurt ist für mich der ideale Ort, (32) das nicht so weit weg von meiner Heimatstadt Zagreb ist. …', null::jsonb, 1.5, null::jsonb, 1),
    ('sb2', '33', '… ist. Da kann ich an den Wochenenden vielleicht auch (33) nach Hause fahren. Nun aber zu meiner Person: Ich bin 24 …', null::jsonb, 1.5, null::jsonb, 2),
    ('sb2', '34', '… der Schule vier Jahre lang Deutsch gelernt. Ich kann zwar (34) ganz gut schreiben, (35) ich habe immer wieder Probleme …', null::jsonb, 1.5, null::jsonb, 3),
    ('sb2', '35', '… Deutsch gelernt. Ich kann zwar (34) ganz gut schreiben, (35) ich habe immer wieder Probleme beim freien Sprechen. Im …', null::jsonb, 1.5, null::jsonb, 4),
    ('sb2', '36', '… Am liebsten wäre mir ein vierwöchiger Deutschkurs, (36) nur vormittags stattfindet, (37) ich nachmittags etwas …', null::jsonb, 1.5, null::jsonb, 5),
    ('sb2', '37', '… Deutschkurs, (36) nur vormittags stattfindet, (37) ich nachmittags etwas anderes machen kann. Ich hätte den …', null::jsonb, 1.5, null::jsonb, 6),
    ('sb2', '38', '… Ich hätte den ganzen August bis Mitte September Zeit. (38) Sie einen passenden Kurs für mich haben, schicken Sie mir …', null::jsonb, 1.5, null::jsonb, 7),
    ('sb2', '39', '… Kurs für mich haben, schicken Sie mir bitte sobald (39) möglich nähere Informationen zu. Mich interessieren auch …', null::jsonb, 1.5, null::jsonb, 8),
    ('sb2', '40', '… natürlich die Preise. Bitte empfehlen Sie mir auch ein (40) gute Webseiten über Klagenfurt und den Wörthersee. Vielen …', null::jsonb, 1.5, null::jsonb, 9),
    ('hv1', '41', 'Die Sprecherin wäre lieber ein Einzelkind.', null::jsonb, 5.0, null::jsonb, 0),
    ('hv1', '42', 'Der Sprecher hat heute ein gutes Verhältnis zu seinem Bruder.', null::jsonb, 5.0, null::jsonb, 1),
    ('hv1', '43', 'Die Sprecherin würde heute gern noch eine Schwester haben.', null::jsonb, 5.0, null::jsonb, 2),
    ('hv1', '44', 'Die Sprecherin hat schon früh lernen müssen, dass man im Zusammenleben viel Rücksicht nehmen muss.', null::jsonb, 5.0, null::jsonb, 3),
    ('hv1', '45', 'Die Sprecherin versteht sich sehr gut mit ihrem Bruder.', null::jsonb, 5.0, null::jsonb, 4),
    ('hv2', '46', 'Die Lehrerin fährt mit ihrer Klasse und an die Nordsee.', null::jsonb, 2.5, null::jsonb, 0),
    ('hv2', '47', 'Herr Kühne hat den Brief der Lehrerin nicht erhalten.', null::jsonb, 2.5, null::jsonb, 1),
    ('hv2', '48', 'Die Klassenfahrt beginnt an einem Samstag.', null::jsonb, 2.5, null::jsonb, 2),
    ('hv2', '49', 'Herrn Kühnes Sohn Martin wird bei Busfahrten oft schlecht.', null::jsonb, 2.5, null::jsonb, 3),
    ('hv2', '50', 'Die Fahrt mit dem Schiff dauert fünf bis sechs Stunden.', null::jsonb, 2.5, null::jsonb, 4),
    ('hv2', '51', 'Das Haus, in dem die Schüler wohnen, gehört zu einem Hotel.', null::jsonb, 2.5, null::jsonb, 5),
    ('hv2', '52', 'Die Klassenfahrt wird von einer Lehrerin und einem Lehrer geleitet.', null::jsonb, 2.5, null::jsonb, 6),
    ('hv2', '53', 'Die Lehrerin empfiehlt, dass die Kinder nicht mehr als 50 Euro Taschengeld mitnehmen.', null::jsonb, 2.5, null::jsonb, 7),
    ('hv2', '54', 'Katerina kann entweder mitfahren, oder in eine andere Klasse gehen.', null::jsonb, 2.5, null::jsonb, 8),
    ('hv2', '55', 'Auf der Klassenfahrt darf nur mit Erlaubnis der Eltern geraucht werden.', null::jsonb, 2.5, null::jsonb, 9),
    ('hv3', '56', 'Sie müssen in Ingolstadt die Regionalbahn nach Regensburg nehmen.', null::jsonb, 5.0, null::jsonb, 0),
    ('hv3', '57', 'Clara kann wegen einer Prüfung die Theaterkarten nicht abholen.', null::jsonb, 5.0, null::jsonb, 1),
    ('hv3', '58', 'Im Schwarzwald können die Straßen morgen glatt werden.', null::jsonb, 5.0, null::jsonb, 2),
    ('hv3', '59', 'Der Liederabend findet zu einem späteren Termin statt.', null::jsonb, 5.0, null::jsonb, 3),
    ('hv3', '60', 'Im Untergeschoss gibt es Winterkleidung zum halben Preis.', null::jsonb, 5.0, null::jsonb, 4),
    ('sa', 'A', 'Antworten Sie auf den Brief. Schreiben Sie etwas zu den folgenden vier Punkten:', null::jsonb, 0, '{"minWords": 100, "points": ["Reaktion auf den Vorschlag", "Fragen zum Garten", "Weg zum Garten", "Was es bei Ihnen Neues gibt"]}'::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'b1' and t.slug = 'modell-04'
join sections s on s.test_id = t.id and s.section_id = v.section_id
on conflict (section_id, item_id) do update set text = excluded.text, options = excluded.options, points = excluded.points, meta = excluded.meta, sort = excluded.sort;

insert into item_answers (item_id, answer, explanation)
select i.id, v.answer, v.explanation
from (values
    ('lv1', '1', 'A', null),
    ('lv1', '2', 'C', null),
    ('lv1', '3', 'G', null),
    ('lv1', '4', 'E', null),
    ('lv1', '5', 'I', null),
    ('lv2', '6', 'B', null),
    ('lv2', '7', 'B', null),
    ('lv2', '8', 'B', null),
    ('lv2', '9', 'B', null),
    ('lv2', '10', 'B', null),
    ('lv3', '11', 'E', null),
    ('lv3', '12', 'F', null),
    ('lv3', '13', 'B', null),
    ('lv3', '14', 'K', null),
    ('lv3', '15', 'C', null),
    ('lv3', '16', 'J', null),
    ('lv3', '17', 'H', null),
    ('lv3', '18', 'X', null),
    ('lv3', '19', 'X', null),
    ('lv3', '20', 'L', null),
    ('sb1', '21', 'B', null),
    ('sb1', '22', 'A', null),
    ('sb1', '23', 'A', null),
    ('sb1', '24', 'A', null),
    ('sb1', '25', 'B', null),
    ('sb1', '26', 'B', null),
    ('sb1', '27', 'A', null),
    ('sb1', '28', 'A', null),
    ('sb1', '29', 'B', null),
    ('sb1', '30', 'B', null),
    ('sb2', '31', 'D', 'Das Wort lautet: IN'),
    ('sb2', '32', 'L', 'Das Wort lautet: WEIL'),
    ('sb2', '33', 'E', 'Das Wort lautet: MANCHMAL'),
    ('sb2', '34', 'H', 'Das Wort lautet: SCHON'),
    ('sb2', '35', 'A', 'Das Wort lautet: ABER'),
    ('sb2', '36', 'C', 'Das Wort lautet: DER'),
    ('sb2', '37', 'B', 'Das Wort lautet: DAMIT'),
    ('sb2', '38', 'M', 'Das Wort lautet: WENN'),
    ('sb2', '39', 'N', 'Das Wort lautet: WIE'),
    ('sb2', '40', 'G', 'Das Wort lautet: PAAR'),
    ('hv1', '41', 'f', null),
    ('hv1', '42', 'r', null),
    ('hv1', '43', 'f', null),
    ('hv1', '44', 'r', null),
    ('hv1', '45', 'r', null),
    ('hv2', '46', 'f', null),
    ('hv2', '47', 'r', null),
    ('hv2', '48', 'f', null),
    ('hv2', '49', 'r', null),
    ('hv2', '50', 'f', null),
    ('hv2', '51', 'f', null),
    ('hv2', '52', 'r', null),
    ('hv2', '53', 'r', null),
    ('hv2', '54', 'r', null),
    ('hv2', '55', 'f', null),
    ('hv3', '56', 'f', null),
    ('hv3', '57', 'f', null),
    ('hv3', '58', 'r', null),
    ('hv3', '59', 'r', null),
    ('hv3', '60', 'f', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'b1' and t.slug = 'modell-04'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;


commit;
