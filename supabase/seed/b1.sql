-- مولّد من data بـtools/export_sql.py — لا تعدّله بالإيد
begin;

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

-- ================= modell-05 · NICOLE =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('b1', 'modell-05', 'NICOLE', '61 Aufgaben · 150 Minuten',
        '[{"id": "block-lv-sb", "title": "Leseverstehen und Sprachbausteine", "minutes": 90, "hint": "Aufgaben 1–40", "parts": ["lv1", "lv2", "lv3", "sb1", "sb2"], "maxPoints": 105.0, "availablePoints": 105.0, "missing": 0}, {"id": "block-hv", "title": "Hörverstehen", "minutes": 30, "hint": "Aufgaben 41–60", "parts": ["hv1", "hv2", "hv3"], "maxPoints": 75.0, "availablePoints": 75.0, "missing": 0}, {"id": "block-sa", "title": "Schriftlicher Ausdruck", "minutes": 30, "hint": "", "parts": ["sa"], "maxPoints": 45.0, "availablePoints": 45, "missing": 0}]'::jsonb, 61, true, 5)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('lv1', 'Leseverstehen', 'Leseverstehen, Teil 1', 15, 'Lesen Sie die Überschriften a–j und die Texte 1–5. Finden Sie für jeden Text die passende Überschrift. Jede Überschrift passt nur einmal.', 'matching', '{"bank": [{"key": "A", "text": "Sportkurse für ältere Menschen"}, {"key": "B", "text": "Für Jugendliche ist der Computer etwas Alltägliches"}, {"key": "C", "text": "Das Interesse am Handel über Internet nimmt stark ab"}, {"key": "D", "text": "Arbeiten am Computer verursacht häufig Rückenschmerzen"}, {"key": "E", "text": "Internetnutzer machen viele Dinge gleichzeitig"}, {"key": "F", "text": "Firmen müssen auch über Internet für Produkte werben"}, {"key": "G", "text": "Auch Freizei tsportarten sollten trainiert werden"}, {"key": "H", "text": "Was man gegen Rückenschmerzen tun kann"}, {"key": "I", "text": "Kinder wollen mit dem Computer nur spielen"}, {"key": "J", "text": "Internetnutzer interessieren sich nicht fürs Fernsehen"}], "bankTitle": "Überschriften", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 0),
    ('lv2', 'Leseverstehen', 'Leseverstehen, Teil 2', 20, 'Lesen Sie den Text und die Aufgaben 6–10. Welche Lösung (A, B oder C) ist jeweils richtig?', 'mc', '{"passages": [{"paragraphs": [{"t": "Computerkurse sind schon für Kinder spannend", "b": true}, {"t": "Schreiben, Rechnen, Programme installieren", "b": true}, {"t": "Schaden oder nützen Computer unseren Kindern? Fragen sich viele Eltern. Ein Computerkurs Veranstalter ist sich ganz sicher: wenn man den Kindern beibringt, den Computer richtig einzusetzen, ist sogar eine Lernhilfe. Seit fünf Jahren bietet Franz Krapfi Krapfen Bauer Computerkurse für Kinder zwischen sieben und vierzehn Jahren an und ist von seinen Schülern begeistert Am liebsten würden die Kinder drei Stunden ohne Pause durcharbeiten Und das obwohl in seinen Kursen nicht gespielt wird, sondern der Computer als Lernhilfe genutzt wird. Im ersten Kurs lernen die Kinder den Umgang mit dem Betriebssystem und erste Grundzüge der Textverarbeitung.", "b": false}, {"t": "Das Geheimnis von Krapfen Bauer Ich erkläre die Programme in der Sprache der Kinder und langweile sie nicht mit technischen Details. Sein Talent entdeckte er, als sich seine eigenen Kinder für den PC) zu interessieren begannen. Seine Tochter brachte immer mehr Mitschüler zum Sonntäglich PC-Training mit, bis eines Tages klar war: Das muss auf professionelle Beine gestellt werden. Das schwierigste war, einen passenden und vor allem kostengünstige Raum zu finden, denn Geld brachten die Kinderkurse am Anfang sehr wenig ein; Ein Bekannte, der Direktor eines Hotels ist, hatte schließlich die passende Lösung Die Schulungsräume im Hotel stehen den Kindern nun an den Wochenenden zur Verfügung Allgemein rät Krapffen Bauer, Kinder so früh wie möglich an den Computer zu lassen, allerdings nur unter Aufsicht und mit den richtigen Programmen. Beim Computer ist es wie beim Fernseher wenn man ihn als Kindermädchen einsetzt, ohne sich darum zu kümmern, was die Kinder damit machen, kann das negativ Folgen haben schon für drei bis vierjährige Kinder gebe es sehr gute Spielprogramme, die mit Vorschulaufgaben vergleichbar wären. Gerade in der Zeit nach Weihnachten haben Krapfis Kindercomputerkurse Hochsaison. Viele Eltern haben einen Computer unter den Christbaum gestellt und wollen jetzt, dass ihre Kinder frühzeitig damit umgehen lernen. Wobei der Seminarleiter für manche Eltern sogar zu viel wissen weitergibt Einige Eltern haben sich schon beschwert, weil ihre Kinder jetzt Hausaufgaben am Computer lösen Die manchmal befürchtet Überordnung der Kinder hat Krapfen Bauer noch nicht erlebt. Ganz im Gegenteil, die kleinen sind oft gar nicht zu stoppen, wenn sie wieder etwas Neues erlernt haben. Viele Teilnehmer kommen dann auch gern zu den nächsten Kursen. Zeichenprogramm oder Spiele kommen in den Computerkursen höchstens als Belohnung am Rande vor.", "b": false}, {"t": "Das größte Hindernis auf dem Weg zum Computerexperten ist für die Kinder in manchen Fällen die negative Einstellung der Eltern.", "b": false}, {"t": "Die Erwachsene kennen oft nur die komplizierten Datenbankwendungen und Programme aus dem Büro und können sich gar nicht vorstellen, was man mit dem Computer noch alles machen kann bedauert Krapfen Bauer natürlich wirkt sich diese negative Grundeinstellung auch auf die Kinder aus, Überraschenderweise sind es dann oft die Großeltern, die für Computerkurse das Geld geben, damit ihre Enkelkinder mit dem PC richtig umgehen lernen. Information und Anmeldung Tel: 0664/ 33 33 14 E Mail: Krapfi@aon.at", "b": false}]}], "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 1),
    ('lv3', 'Leseverstehen', 'Leseverstehen, Teil 3', 20, 'Lesen Sie die Situationen 11–20 und die Anzeigen im Bild. Finden Sie für jede Situation die passende Anzeige. Wenn Sie keine passende Anzeige finden, wählen Sie X.', 'matching', '{"bank": [{"key": "A", "text": ""}, {"key": "B", "text": ""}, {"key": "C", "text": ""}, {"key": "D", "text": ""}, {"key": "E", "text": ""}, {"key": "F", "text": ""}, {"key": "G", "text": ""}, {"key": "H", "text": ""}, {"key": "I", "text": ""}, {"key": "J", "text": ""}, {"key": "K", "text": ""}, {"key": "L", "text": ""}, {"key": "X", "text": ""}], "bankTitle": "Anzeigen", "bankImage": "img/m05-lv3.jpg", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 2.5}'::jsonb, 2),
    ('sb1', 'Sprachbausteine', 'Sprachbausteine, Teil 1', 20, 'Lesen Sie den Text und schließen Sie die Lücken 21–30. Welche Lösung (A, B oder C) ist jeweils richtig?', 'mc', '{"passages": [{"paragraphs": [{"t": "Genuss mit Kaffee Partner", "b": false}, {"t": "Sehr geehrte Frau Thoma,", "b": false}, {"t": "schade, (21) Sie bisher noch nicht Kunde bei Kaffee Partner (22). Vielleicht liegt das an uns,", "b": false}, {"t": "weil wir (23) nicht das richtige Angebot gemacht haben, seit wir uns vor einiger Zeit in Köln", "b": false}, {"t": "auf der ANUGA, der großen Messe für Nahrung und Genussmittel, (24) haben. Wir (25) das jetzt mit dem aktuellen Katalog nachholen, den Sie heute erhalten.", "b": false}, {"t": "Sie (26) darin viele nützliche und attraktive Dinge rund um das Thema Kaffee und Trinkwasser", "b": false}, {"t": "(27) Mitarbeiter und Besucher. Aber auch Tee, kleine Leckereien und nette Kalender für Büro", "b": false}, {"t": "und Zuhause (28) Ihnen unser Geschenkkatalog.", "b": false}, {"t": "Viel Spaß beim Blättern und Aussuchen. Wir freuen (29) auf Sie!", "b": false}, {"t": "(30) Grüße aus Wallenhorst", "b": false}, {"t": "Ihr Kaffee Partner-Team", "b": false}, {"t": "Manfred Pflüger", "b": false}]}], "maxPoints": 15.0, "availablePoints": 15.0, "missing": 0, "pointsPerItem": 1.5}'::jsonb, 3),
    ('sb2', 'Sprachbausteine', 'Sprachbausteine, Teil 2', 15, 'Lesen Sie den Text und schließen Sie die Lücken 31–40. Benutzen Sie die Wörter aus der Liste. Jedes Wort passt nur einmal.', 'wordbank', '{"bank": [{"key": "A", "text": "ABER"}, {"key": "B", "text": "DARF"}, {"key": "C", "text": "DASS"}, {"key": "D", "text": "DESHALB"}, {"key": "E", "text": "DIESE"}, {"key": "F", "text": "IN"}, {"key": "G", "text": "KANN"}, {"key": "H", "text": "KÖNNTEN"}, {"key": "I", "text": "MICH"}, {"key": "J", "text": "MIR"}, {"key": "K", "text": "OB"}, {"key": "L", "text": "OBWOHL"}, {"key": "M", "text": "UNTER"}, {"key": "N", "text": "VOR"}, {"key": "O", "text": "WANN"}], "bankTitle": "Wörterliste", "passages": [{"paragraphs": [{"t": "Sehr geehrte Damen und Herren,", "b": false}, {"t": "mit großem Interesse und auch mit Hoffnung habe ich Ihre Anzeige gelesen. leider (31) ich Sie im Moment nicht anrufen, da das Telefon immer belegt ist. (32) schreibe ich Ihnen diese Mail. Mein Sohn Matthias macht (33) zwei Jahren sein Abitur, (34) seine Leistungen sind zurzeit nicht so gut. Ich mache (35) vor allem bei den Fächern Physik und Mathematik große Sorgen. Matthias ist nicht dumm, aber er ist etwas faul und denkt, er brauche (36) Fächer nicht.", "b": false}, {"t": "Fragen wollte ich nun, (37) es bei Ihnen auch individuelle Physik und Mathematiknachhilfe gibt. Und (38) finden die Stunden statt? Am späten Nachmittag oder am frühen Abend? Mir wäre es jedenfalls sehr wichtig, dass Sie meinem Sohn helfen (39).", "b": false}, {"t": "Ab 19.30 Uhr bin ich telefonisch (40) der Nummer 0428-1734 zu erreichen.", "b": false}, {"t": "Mit freundlichen Grüßen JOSEF MARTINELL", "b": false}]}], "maxPoints": 15.0, "availablePoints": 15.0, "missing": 0, "pointsPerItem": 1.5}'::jsonb, 4),
    ('hv1', 'Hörverstehen', 'Hörverstehen, Teil 1', 8, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 5),
    ('hv2', 'Hörverstehen', 'Hörverstehen, Teil 2', 14, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 2.5}'::jsonb, 6),
    ('hv3', 'Hörverstehen', 'Hörverstehen, Teil 3', 8, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 7),
    ('sa', 'Schriftlicher Ausdruck', 'Schriftlicher Ausdruck', 30, 'Schreiben Sie Ihrer Bekannten einen Antwortbrief, der die folgenden Punkte enthält:', 'writing', '{"brief": {"intro": "Eine Freundin beschreibt in einem Brief, welche Probleme sie mit ihrem Bruder hat und bittet Sie um Rat:", "greeting": "Liebe(r)........", "paragraphs": ["entschuldige, dass ich dir so lange nicht mehr geschrieben habe. Aber weißt du mein älterer Bruder, der schon lange im Ausland lebt, ist jetzt für zwei Monate bei uns. Wir unternehmen einiges zusammen, Z.B. gehen wir nachmittags ins Schwimmbad oder abends ins Kino.", "Wir verstehen uns eigentlich ganz gut, aber dennoch habe ich ein Problem mit ihm: Wenn es im Fernsehen Sportsendungen gibt, dann bekomme ich ihn nicht mehr weg vom Fernseher! Er sitzt dann stundenlang nur da und sieht fern, ganz egal wie schön das Wetter draußen ist! Was soll ich bloß tun? Überhaupt nichts sagen oder soll ich mit ihm deswegen streiten? Er fährt bald wieder weg und ich möchte doch mit ihm zusammen sein. Was würdest du machen? Hast du vielleicht ein paar Tipps oder Ratschläge für mich?", "Herzliche Grüße"], "signature": "Nicole"}, "hints": ["Bevor Sie den Brief schreiben ,überlegen Sie sich eine passende Reihenfolge der punkte, eine passende"], "criteria": [{"title": "Aufgabenbewältigung", "hint": "Sind alle vier Leitpunkte inhaltlich angemessen bearbeitet?"}, {"title": "Kommunikative Gestaltung", "hint": "Anrede, Gruß, passendes Register und verbundene Sätze statt aneinandergereihter Punkte?"}, {"title": "Formale Richtigkeit", "hint": "Stören Fehler in Grammatik, Wortschatz und Rechtschreibung das Verstehen?"}], "grades": [{"key": "A", "points": 5}, {"key": "B", "points": 3}, {"key": "C", "points": 1}, {"key": "D", "points": 0}], "factor": 3, "maxPoints": 45, "availablePoints": 45, "missing": 0}'::jsonb, 8)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'b1' and t.slug = 'modell-05'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('lv1', '1', 'Falsche Körperhaltung, mangelnde Bewegung und psychische Faktoren sind meistens die Hauptfaktoren für Rückenschmerzen. Hier finden Sie ein ganzheitliches Trainingsprogramm, das hilft: Alle Übungen lassen sich im Alltag gut umsetzen und sind auch bei Vorschäden der Wirbelsäule durchführbar. Mit speziellen Entspannungstraining. 114 Seiten, durchgehend Farbabbildungen, 18×25 cm, gebunden.', null::jsonb, 5.0, null::jsonb, 0),
    ('lv1', '2', 'Der Computer gehört heute wie selbstverständlich in das Jugendzimmer. Wie früher die Modelleisendbahn oder die Barbie-Puppe. Was aber genau treiben die Kids mit den hochgerüsteten Rechenmaschinen auf dem Schreibtisch? Das wollte die Jugendzeitschrift Bravo wissen. Selbstverständlich spielen, aber auch andere, nützlichere Dinge wie Texte schreiben oder Hausaufgaben für die Schule erledigen, Tabellen erstellen und natürlich im Internet herumsurfen.', null::jsonb, 5.0, null::jsonb, 1),
    ('lv1', '3', 'Inline-Skating ist ein Idealer Ausdauersport – nicht nur für die jüngere Generation. Das haben jetzt Untersuchungen am Institut für Sportwissenschaften an der Universität Frankfurt bestätigt. Danach trainiert Inline-Skating das Herz-Kreislauf-System, beansprucht die wichtigsten Muskelgruppen und fördert die Koordination. Die Faszination dieser rasanten Freizeitsportart wirke generationenübergreifend und erfasst die Jungen wie die Alten, sagt Dr. Hans Jürgen Ahrens. Allerdings fragt der Arzt kritisch, warum jeder Skifahrer, Windsurfer oder Tennisspieler zu Beginn Trainingsstunden bei einem Profi belege, oft aber nicht der Inliner: Dabei lässt sich das Verletzungsrisiko durch regelmäßiges Fahrtraining deutlich verringern. In einem Kurs sollten die wichtigsten Sturz- Brems und Fahrtechniken erlernt werden.', null::jsonb, 5.0, null::jsonb, 2),
    ('lv1', '4', 'Eine Studie der Fernsehgesellschaften ARD und ZDF besagt, dass deutsche Internetnutzer sich auch mit anderen Dingen beschäftigen, wenn sie im Internet sind. Ein Großteil der beobachteten Personen telefoniert beim Surfen, hört nebenbei Musik, oder arbeitet mit anderen Computerprogrammen. Aber auch Konkurrenzmedien wie Fernsehen und Zeitschriften finden große Aufmerksamkeit, während im Internet nach Informationen gesucht wird.', null::jsonb, 5.0, null::jsonb, 3),
    ('lv1', '5', 'Geschäfte über das Internet werden in Deutschland auch in Zukunft Milliarden Euro einbringen. In spätestens zwei Jahren werden 20 Prozent aller europäischen Geschäfte über das Internet abgewickelt, sagen die Fachleute. Heutzutage ist es kaum vorstellbar, dass ein Unternehmen allein mit klassischen Verkaufsmethoden und ohne zusätzliches Online- Marketing erfolgreich sein wird. Wer heute nicht anfängt, diese Möglichkeiten zu nutzen, kann in Zukunft seine Kunden verlieren. Das Argument, dass die angebotene Ware sich ja auch ohne Internet gut verkaufe, stimmt so nicht mehr. Denn das Internet beeinflusst auch das Käuferverhalten auf der Straße.', null::jsonb, 5.0, null::jsonb, 4),
    ('lv2', '6', 'In der Computerkursen von Franz Krapfenbauer', '[{"key": "A", "text": "lernen die Kinder vor allem neue Computerspiele kennen.."}, {"key": "B", "text": "lernen Kinder ab 14 Jahren das richtige Arbeiten mit dem Computer."}, {"key": "C", "text": "werden die Computerprogramme so einfach wie möglich erklärt."}]'::jsonb, 5.0, null::jsonb, 0),
    ('lv2', '7', 'Am Anfang war es für Franz Krapfenbauer schwierig,', '[{"key": "A", "text": "einen geeigneten Raum für die Kurse zu finden."}, {"key": "B", "text": "genug Kinder für den Computerkurs zu finden."}, {"key": "C", "text": "seine Tochter für den Computer zu begeistern."}]'::jsonb, 5.0, null::jsonb, 1),
    ('lv2', '8', 'Herr Krapfenbauer meint,', '[{"key": "A", "text": "dass auch kleine Kinder mit dem Computer arbeiten sollen."}, {"key": "B", "text": "dass Kinderunter vier Jahren zu jung für den Computer seien."}, {"key": "C", "text": "dass sich Kinder alleine mit dem Computer beschäftigen sollen."}]'::jsonb, 5.0, null::jsonb, 2),
    ('lv2', '9', 'Viele Kinder', '[{"key": "A", "text": "machen im Kurs ihre Hausaufgaben am Computer."}, {"key": "B", "text": "machen nach dem ersten Kurs noch einen weiteren Kurs."}, {"key": "C", "text": "probieren im Kurs neue Computerspiele aus."}]'::jsonb, 5.0, null::jsonb, 3),
    ('lv2', '10', 'Franz Krapfenbauer erzählt,', '[{"key": "A", "text": "dass die Computerkurse oft von den Großeltern bezahlt werden."}, {"key": "B", "text": "dass einige Eltern selbst als Computerexperten arbeiten."}, {"key": "C", "text": "dass er auch Computerkurse in Büros plant."}]'::jsonb, 5.0, null::jsonb, 4),
    ('lv3', '11', 'Sie suchen für Ihnen 5-Jährigen Sohn einen Schikurs.', null::jsonb, 2.5, null::jsonb, 0),
    ('lv3', '12', 'Sie möchten am Wochenende in den Zoo gehen.', null::jsonb, 2.5, null::jsonb, 1),
    ('lv3', '13', 'Sie suchen eine Zeitschrift für Ihre Freundin, die sich für Mode interessiert.', null::jsonb, 2.5, null::jsonb, 2),
    ('lv3', '14', 'Ihre Bekannte sucht einen Job in einem Modegeschäft.', null::jsonb, 2.5, null::jsonb, 3),
    ('lv3', '15', 'Sie möchten Ihre Freunde am Montagabend in den Zirkus einladen.', null::jsonb, 2.5, null::jsonb, 4),
    ('lv3', '16', 'Ihre 10-jährige Tochter möchte sich gern einen Tierfilm ansehen.', null::jsonb, 2.5, null::jsonb, 5),
    ('lv3', '17', 'Sie möchten für Ihre Familie billige Winterkleidung kaufen.', null::jsonb, 2.5, null::jsonb, 6),
    ('lv3', '18', 'Sie möchten einen Schikurs machen und sich dafür Schier leihen.', null::jsonb, 2.5, null::jsonb, 7),
    ('lv3', '19', 'Sie machen in Österreich Urlaub und möchten sich einen Film im englischen Original ansehen.', null::jsonb, 2.5, null::jsonb, 8),
    ('lv3', '20', 'Sie interessieren sich für Tiere und möchten ihnen helfen.', null::jsonb, 2.5, null::jsonb, 9),
    ('sb1', '21', 'Genuss mit Kaffee Partner Sehr geehrte Frau Thoma, schade, (21) Sie bisher noch nicht Kunde bei Kaffee Partner (22). …', '[{"key": "A", "text": "dass"}, {"key": "B", "text": "darum"}, {"key": "C", "text": "weil"}]'::jsonb, 1.5, null::jsonb, 0),
    ('sb1', '22', '… (21) Sie bisher noch nicht Kunde bei Kaffee Partner (22). Vielleicht liegt das an uns, weil wir (23) nicht das …', '[{"key": "A", "text": "seid"}, {"key": "B", "text": "sein"}, {"key": "C", "text": "sind"}]'::jsonb, 1.5, null::jsonb, 1),
    ('sb1', '23', '… Partner (22). Vielleicht liegt das an uns, weil wir (23) nicht das richtige Angebot gemacht haben, seit wir uns …', '[{"key": "A", "text": "euch"}, {"key": "B", "text": "Ihnen"}, {"key": "C", "text": "Sie"}]'::jsonb, 1.5, null::jsonb, 2),
    ('sb1', '24', '… der ANUGA, der großen Messe für Nahrung und Genussmittel, (24) haben. Wir (25) das jetzt mit dem aktuellen Katalog …', '[{"key": "A", "text": "kennen gelernt"}, {"key": "B", "text": "kennen lernen"}, {"key": "C", "text": "kennen lernte"}]'::jsonb, 1.5, null::jsonb, 3),
    ('sb1', '25', '… Messe für Nahrung und Genussmittel, (24) haben. Wir (25) das jetzt mit dem aktuellen Katalog nachholen, den Sie …', '[{"key": "A", "text": "mochten"}, {"key": "B", "text": "möchten"}, {"key": "C", "text": "mögen"}]'::jsonb, 1.5, null::jsonb, 4),
    ('sb1', '26', '… aktuellen Katalog nachholen, den Sie heute erhalten. Sie (26) darin viele nützliche und attraktive Dinge rund um das …', '[{"key": "A", "text": "fanden"}, {"key": "B", "text": "finden"}, {"key": "C", "text": "findet"}]'::jsonb, 1.5, null::jsonb, 5),
    ('sb1', '27', '… attraktive Dinge rund um das Thema Kaffee und Trinkwasser (27) Mitarbeiter und Besucher. Aber auch Tee, kleine …', '[{"key": "A", "text": "für"}, {"key": "B", "text": "von"}, {"key": "C", "text": "wegen"}]'::jsonb, 1.5, null::jsonb, 6),
    ('sb1', '28', '… kleine Leckereien und nette Kalender für Büro und Zuhause (28) Ihnen unser Geschenkkatalog. Viel Spaß beim Blättern und …', '[{"key": "A", "text": "gezeigt"}, {"key": "B", "text": "zeigen"}, {"key": "C", "text": "zeigt"}]'::jsonb, 1.5, null::jsonb, 7),
    ('sb1', '29', '… Viel Spaß beim Blättern und Aussuchen. Wir freuen (29) auf Sie! (30) Grüße aus Wallenhorst Ihr Kaffee …', '[{"key": "A", "text": "mich"}, {"key": "B", "text": "sich"}, {"key": "C", "text": "uns"}]'::jsonb, 1.5, null::jsonb, 8),
    ('sb1', '30', '… beim Blättern und Aussuchen. Wir freuen (29) auf Sie! (30) Grüße aus Wallenhorst Ihr Kaffee Partner-Team Manfred …', '[{"key": "A", "text": "Freundlich"}, {"key": "B", "text": "Freundliche"}, {"key": "C", "text": "Freundlichen"}]'::jsonb, 1.5, null::jsonb, 9),
    ('sb2', '31', '… auch mit Hoffnung habe ich Ihre Anzeige gelesen. leider (31) ich Sie im Moment nicht anrufen, da das Telefon immer …', null::jsonb, 1.5, null::jsonb, 0),
    ('sb2', '32', '… im Moment nicht anrufen, da das Telefon immer belegt ist. (32) schreibe ich Ihnen diese Mail. Mein Sohn Matthias macht …', null::jsonb, 1.5, null::jsonb, 1),
    ('sb2', '33', '… schreibe ich Ihnen diese Mail. Mein Sohn Matthias macht (33) zwei Jahren sein Abitur, (34) seine Leistungen sind …', null::jsonb, 1.5, null::jsonb, 2),
    ('sb2', '34', '… Mein Sohn Matthias macht (33) zwei Jahren sein Abitur, (34) seine Leistungen sind zurzeit nicht so gut. Ich mache …', null::jsonb, 1.5, null::jsonb, 3),
    ('sb2', '35', '… seine Leistungen sind zurzeit nicht so gut. Ich mache (35) vor allem bei den Fächern Physik und Mathematik große …', null::jsonb, 1.5, null::jsonb, 4),
    ('sb2', '36', '… nicht dumm, aber er ist etwas faul und denkt, er brauche (36) Fächer nicht. Fragen wollte ich nun, (37) es bei Ihnen …', null::jsonb, 1.5, null::jsonb, 5),
    ('sb2', '37', '… er brauche (36) Fächer nicht. Fragen wollte ich nun, (37) es bei Ihnen auch individuelle Physik und …', null::jsonb, 1.5, null::jsonb, 6),
    ('sb2', '38', '… individuelle Physik und Mathematiknachhilfe gibt. Und (38) finden die Stunden statt? Am späten Nachmittag oder am …', null::jsonb, 1.5, null::jsonb, 7),
    ('sb2', '39', '… es jedenfalls sehr wichtig, dass Sie meinem Sohn helfen (39). Ab 19.30 Uhr bin ich telefonisch (40) der Nummer …', null::jsonb, 1.5, null::jsonb, 8),
    ('sb2', '40', '… meinem Sohn helfen (39). Ab 19.30 Uhr bin ich telefonisch (40) der Nummer 0428-1734 zu erreichen. Mit freundlichen …', null::jsonb, 1.5, null::jsonb, 9),
    ('hv1', '41', 'Der Sprecher interessiert sich für Sport als für Kultur.', null::jsonb, 5.0, null::jsonb, 0),
    ('hv1', '42', 'Die Sprecherin geht so oft sie kann ins Theater.', null::jsonb, 5.0, null::jsonb, 1),
    ('hv1', '43', 'Der Sprecher hört besonders gern moderne Musik.', null::jsonb, 5.0, null::jsonb, 2),
    ('hv1', '44', 'Die Sprecherin geht oft in Kunstausstellungen.', null::jsonb, 5.0, null::jsonb, 3),
    ('hv1', '45', 'Die Sprecherin hätte gerne mehr Zeit für die Kultur.', null::jsonb, 5.0, null::jsonb, 4),
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
    ('hv3', '56', 'Sie können mit dem Bus in die Innenstadt fahren.', null::jsonb, 5.0, null::jsonb, 0),
    ('hv3', '57', 'Sie können noch eine Stunde durch alle Geschäfte laufen.', null::jsonb, 5.0, null::jsonb, 1),
    ('hv3', '58', 'Dr. Krausch ist ab dem 18. Oktober wieder in der Praxis.', null::jsonb, 5.0, null::jsonb, 2),
    ('hv3', '59', 'Alle Kunden müssen an der Kasse nebenan bezahlen.', null::jsonb, 5.0, null::jsonb, 3),
    ('hv3', '60', 'Die Polizei informiert, dass alle Parkhäuser bei der Ausstellung besetzt sind.', null::jsonb, 5.0, null::jsonb, 4),
    ('sa', 'A', 'Schreiben Sie Ihrer Bekannten einen Antwortbrief, der die folgenden Punkte enthält:', null::jsonb, 0, '{"minWords": 100, "points": ["Eigene Erfahrungen mit Geschwistern, Freunden,", "Tipps für Nicole", "Was Sie über den Bruder denken", "Was Sie selbst gern gemeinsam mit anderen machen"]}'::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'b1' and t.slug = 'modell-05'
join sections s on s.test_id = t.id and s.section_id = v.section_id
on conflict (section_id, item_id) do update set text = excluded.text, options = excluded.options, points = excluded.points, meta = excluded.meta, sort = excluded.sort;

insert into item_answers (item_id, answer, explanation)
select i.id, v.answer, v.explanation
from (values
    ('lv1', '1', 'H', null),
    ('lv1', '2', 'B', null),
    ('lv1', '3', 'G', null),
    ('lv1', '4', 'E', null),
    ('lv1', '5', 'F', null),
    ('lv2', '6', 'C', null),
    ('lv2', '7', 'A', null),
    ('lv2', '8', 'A', null),
    ('lv2', '9', 'B', null),
    ('lv2', '10', 'A', null),
    ('lv3', '11', 'D', null),
    ('lv3', '12', 'E', null),
    ('lv3', '13', 'C', null),
    ('lv3', '14', 'K', null),
    ('lv3', '15', 'X', null),
    ('lv3', '16', 'J', null),
    ('lv3', '17', 'X', null),
    ('lv3', '18', 'B', null),
    ('lv3', '19', 'X', null),
    ('lv3', '20', 'H', null),
    ('sb1', '21', 'B', null),
    ('sb1', '22', 'C', null),
    ('sb1', '23', 'B', null),
    ('sb1', '24', 'A', null),
    ('sb1', '25', 'B', null),
    ('sb1', '26', 'B', null),
    ('sb1', '27', 'B', null),
    ('sb1', '28', 'C', null),
    ('sb1', '29', 'C', null),
    ('sb1', '30', 'B', null),
    ('sb2', '31', 'G', 'Das Wort lautet: KANN'),
    ('sb2', '32', 'D', 'Das Wort lautet: DESHALB'),
    ('sb2', '33', 'F', 'Das Wort lautet: IN'),
    ('sb2', '34', 'A', 'Das Wort lautet: ABER'),
    ('sb2', '35', 'J', 'Das Wort lautet: MIR'),
    ('sb2', '36', 'E', 'Das Wort lautet: DIESE'),
    ('sb2', '37', 'K', 'Das Wort lautet: OB'),
    ('sb2', '38', 'O', 'Das Wort lautet: WANN'),
    ('sb2', '39', 'H', 'Das Wort lautet: KÖNNTEN'),
    ('sb2', '40', 'M', 'Das Wort lautet: UNTER'),
    ('hv1', '41', 'r', null),
    ('hv1', '42', 'r', null),
    ('hv1', '43', 'f', null),
    ('hv1', '44', 'f', null),
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
    ('hv3', '56', 'r', null),
    ('hv3', '57', 'f', null),
    ('hv3', '58', 'r', null),
    ('hv3', '59', 'f', null),
    ('hv3', '60', 'f', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'b1' and t.slug = 'modell-05'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;

-- ================= modell-06 · ANDREAS =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('b1', 'modell-06', 'ANDREAS', '61 Aufgaben · 150 Minuten',
        '[{"id": "block-lv-sb", "title": "Leseverstehen und Sprachbausteine", "minutes": 90, "hint": "Aufgaben 1–40", "parts": ["lv1", "lv2", "lv3", "sb1", "sb2"], "maxPoints": 105.0, "availablePoints": 105.0, "missing": 0}, {"id": "block-hv", "title": "Hörverstehen", "minutes": 30, "hint": "Aufgaben 41–60", "parts": ["hv1", "hv2", "hv3"], "maxPoints": 75.0, "availablePoints": 75.0, "missing": 0}, {"id": "block-sa", "title": "Schriftlicher Ausdruck", "minutes": 30, "hint": "", "parts": ["sa"], "maxPoints": 45.0, "availablePoints": 45, "missing": 0}]'::jsonb, 61, true, 6)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('lv1', 'Leseverstehen', 'Leseverstehen, Teil 1', 15, 'Lesen Sie die Überschriften a–j und die Texte 1–5. Finden Sie für jeden Text die passende Überschrift. Jede Überschrift passt nur einmal.', 'matching', '{"bank": [{"key": "A", "text": "Märchen-Festspiele in Bremen"}, {"key": "B", "text": "Griechische Botschaft bietet Sprachkurse für Schüler"}, {"key": "C", "text": "Universitätsstadt wird 300 Jahre"}, {"key": "D", "text": "Wissenschaft: Von der Körpergröße hängt das Gehalt ab"}, {"key": "E", "text": "Durch Handel reich geworden"}, {"key": "F", "text": "Interessante Universitätsstadt mit hoher Lebensqualität"}, {"key": "G", "text": "Latein in deutschen Schulen wieder beliebter"}, {"key": "H", "text": "Wer wenig lacht, verdient auch weniger"}, {"key": "I", "text": "Fremdsprachen: Schüler lernen nur Englisch und Französisch"}, {"key": "J", "text": "Griechisch wird in deutschen Schulen kaum unterrichtet"}], "bankTitle": "Überschriften", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 0),
    ('lv2', 'Leseverstehen', 'Leseverstehen, Teil 2', 20, 'Lesen Sie den Text und die Aufgaben 6–10. Welche Lösung (A, B oder C) ist jeweils richtig?', 'mc', '{"passages": [{"paragraphs": [{"t": "Leben", "b": true}, {"t": "Das machen wir mit links", "b": true}, {"t": "Über eine Million Österreicher sind Linkshänder und langsam setzen sie sich durch in der Rechtshänder Welt", "b": true}, {"t": "Schau der macht das mit der linken Hand. Solche und ähnliche Kommentare hörte der gelernte Porzellanformer Gerhard Spur (51) von Besuchern, die die Porzellanmanufaktur im Wiener Augarten besichtigten und dem Künstler beim Herstellen eines Kunstwerkes zusahen allerdings nur früher, als nur die rechte Hand die so genannte schöne Hand war,", "b": false}, {"t": "die man zum Arbeiten. Schreiben usw. verwenden durfte. Heute ist es offensichtlich normal, dass jemand mit der linken Hand Vasen aus Porzellan bearbeitet. Gerhard Spur wird jedenfalls nicht mehr bestaunt.", "b": false}, {"t": "Links arbeiten", "b": false}, {"t": "Gut 15 Prozent der Menschheit sind Linkshänder. Über die Gründe für Linkshändigkeit ist sich die Wissenschaft nicht einig. Fest steht nur. Wenn Kinder gezwungen werden, statt mit der linken Hand mit der rechten Hand zu schreiben, hat dies schwerwiegende Folgen. Dies führt zu Knoten im Kopf so die Linkshänder-Expertin Johanna Barbara Sattier. Spätestens wenn umgeschulte Kinder mit dem Lesen und Schreiben beginnen, macht sich das Chaos im Kopf bemerkbar. In der Schule ist es mittlerweile verboten, Linkshänder auf rechts umzuschulen. Probleme machen allerdings noch Arbeitsplätze, die nicht für Linkshänder geeignet sind, erklärt Erich Pospischill, Leiter des arbeitsmedizinischen Zentrums Mödling: Schon die Computermaus auf der falschen Seite führt zu rascherer Ermüdung, weil das Gehirn durch das ständige Umdenken zusätzlich belastet wird.", "b": false}, {"t": "Lösungen im Betrieb", "b": false}, {"t": "Die Maschine, an der Slata Tanasic tagtäglich arbeitet, funktioniert von links unten nach rechts oben. Genau verkehrt für die 41- Jährige, die seit 21 Jahren im Seibert-Elektronikwerk arbeitet. Ich habe gesagt, dass ich mit der Maschine so nicht arbeiten kann. Und das wurde akzeptiert. Slata wurde in einen anderen Arbeitsbereich versetzt und macht jetzt Arbeiten, die auch mit der linken Hand möglich sind: Montieren und Vorbereiten der Bauteile.", "b": false}, {"t": "Eltern können helfen", "b": false}, {"t": "Bei Kleinkindern lässt sich nicht sofort erkennen, ob sie links- oder rechtshändig sind, sagt die Expertin Sattler: Viele Kinder ahmen zuerst die Tätigkeiten in unserer rechtshändigen Welt nach. Deshalb rät Sattler den Eltern, ihren Kinder beim Herausfinden ihrer Händigkeit zu helfen: Blumen gießen mit einer kleinen Kanne, einen Ball werfen bei diesen Handlungen greifen Kinder automatisch mit der starken Hand zu. Und dann sollten Eltern bereits erste Konsequenzen ziehen.", "b": false}]}], "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 1),
    ('lv3', 'Leseverstehen', 'Leseverstehen, Teil 3', 20, 'Lesen Sie die Situationen 11–20 und die Anzeigen im Bild. Finden Sie für jede Situation die passende Anzeige. Wenn Sie keine passende Anzeige finden, wählen Sie X.', 'matching', '{"bank": [{"key": "A", "text": ""}, {"key": "B", "text": ""}, {"key": "C", "text": ""}, {"key": "D", "text": ""}, {"key": "E", "text": ""}, {"key": "F", "text": ""}, {"key": "G", "text": ""}, {"key": "H", "text": ""}, {"key": "I", "text": ""}, {"key": "J", "text": ""}, {"key": "K", "text": ""}, {"key": "L", "text": ""}, {"key": "X", "text": ""}], "bankTitle": "Anzeigen", "bankImage": "img/m06-lv3.jpg", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 2.5}'::jsonb, 2),
    ('sb1', 'Sprachbausteine', 'Sprachbausteine, Teil 1', 20, 'Lesen Sie den Text und schließen Sie die Lücken 21–30. Welche Lösung (A, B oder C) ist jeweils richtig?', 'mc', '{"passages": [{"paragraphs": [{"t": "Liebe Jelena,", "b": false}, {"t": "ich hab dir doch schon vom Deutsschkurs erzählt, (21) ich hier besuche. Der ist wirklich ganz gut. Wir haben jetzt eine neue Aufgabe bekommen. Wir müssen Informationen (22) Thema Gesundheit und Ernährung suchen und schauen, was es dazu Interessantes (23) Internet gibt. Die interessanteste Internetseite, die ich finden (24) , ist www.gesund.ch. Diese Seite ist für (25) Leute gemacht, die gern mehr über gesunde Ernährung erfahren möchten. Fachleute beschreiben hier genau, (26) Lebensmittel für unseren Körper wichtig und gesund sind und wie oft und wie viel man pro Tag essen sollte. Außerdem kann man (27) seinen persönlichen Speiseplan selbst erstellen und dafür passende Rezepte (28) . Für Menschen, (29) ein paar Kilos zu viel haben, gibt es auch Tipps zum Abnehmen und Links zu verschiedenen Fitnesszentren in der Schweiz.", "b": false}, {"t": "Und was gibt es bei dir Neues? (30) mir doch möglichst bald zurück!", "b": false}, {"t": "Bis dann und viele Grüße", "b": false}, {"t": "Paola", "b": false}]}], "maxPoints": 15.0, "availablePoints": 15.0, "missing": 0, "pointsPerItem": 1.5}'::jsonb, 3),
    ('sb2', 'Sprachbausteine', 'Sprachbausteine, Teil 2', 15, 'Lesen Sie den Text und schließen Sie die Lücken 31–40. Benutzen Sie die Wörter aus der Liste. Jedes Wort passt nur einmal.', 'wordbank', '{"bank": [{"key": "A", "text": "BEOUEM"}, {"key": "B", "text": "GEEIGNET"}, {"key": "C", "text": "HÄTTE"}, {"key": "D", "text": "IHNEN"}, {"key": "E", "text": "JEDEN"}, {"key": "F", "text": "KÖNNTE"}, {"key": "G", "text": "MEHR"}, {"key": "H", "text": "NICHTS"}, {"key": "I", "text": "OHNE"}, {"key": "J", "text": "SCHON"}, {"key": "K", "text": "SIE"}, {"key": "L", "text": "TÄGLICH"}, {"key": "M", "text": "WIE HOCH"}, {"key": "N", "text": "WIE VIEL"}, {"key": "O", "text": "ZWAR"}], "bankTitle": "Wörterliste", "passages": [{"paragraphs": [{"t": "Sehr geehrter Herr Gauberger,", "b": false}, {"t": "ihre Anzeige habe ich mit Interesse gelesen. Ich bin (31) lange Rentner und bekomme", "b": false}, {"t": "monatlich nur wenig Geld. Wenn ich die Möglichkeit (32) , noch ein wenig zu verdienen, würde mir das sehr helfen. Ich bin (33) schon 72 Jahre alt, aber noch bei sehr guter Gesundheit. Daher denke ich, dass ich die Arbeit (34) Probleme machen kann. Seit über dreißig Jahren treibe ich (35) Tag Sport. Auch das frühe Aufstehen macht mir gar (36) aus.", "b": false}, {"t": "Einige Fragen hätte ich trotzdem noch: Müssen die Zeitungen ( 37) ausgetragen werden und wie lange ist man unterwegs? Außerdem möchte ich natürlich wissen, ( 38) man verdient. Ich bin gerne bereit, mich bei (39) vorzustellen, damit Sie sehen können, dass ich für die Tätigkeit", "b": false}, {"t": "(40) bin.", "b": false}, {"t": "Mit freundlichen Grüßen EBERHARD SPITZWEG", "b": false}]}], "maxPoints": 15.0, "availablePoints": 15.0, "missing": 0, "pointsPerItem": 1.5}'::jsonb, 4),
    ('hv1', 'Hörverstehen', 'Hörverstehen, Teil 1', 8, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 5),
    ('hv2', 'Hörverstehen', 'Hörverstehen, Teil 2', 14, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 2.5}'::jsonb, 6),
    ('hv3', 'Hörverstehen', 'Hörverstehen, Teil 3', 8, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 7),
    ('sa', 'Schriftlicher Ausdruck', 'Schriftlicher Ausdruck', 30, 'Antworten Sie Andreas. Schreiben Sie etwas zu allen vier Punkten: Vorschlag wie Andreas seinem Arbeitskollegen helfen kann.', 'writing', '{"brief": {"intro": "Sie haben im Urlaub Andreas kennengelernt. Er hat Ihnen folgende E-Mail geschrieben:", "greeting": "Liebe(r)........", "paragraphs": ["Heute habe ich Zeit, dir ein paar Zeilen zu schreiben. Der Urlaub war so schön, aber seit ich zurück bin, habe ich im Büro sehr viel Arbeit. Bestimmt brauche ich schon bald wieder Urlaub!", "Während ich weg war, hat sich hier übrigens einiges geändert: Es gibt einen neuen Kollegen, er heißt Roberto. Was aber die größte Veränderung ist:", "Er arbeitet mit mir in meinem Büro, das heißt, ich habe endlich jemanden, mit dem ich mich Zwischendurch auch ein bisschen unterhalten kann! Roberrto ist aus Spanien hierher gezogen. Er kennt noch niemanden hier, außer mir natürlich, und ist meistens allein. Denkst du, dass ich ihn und ein paar andere Arbeitskollegen einmal einladen sollte? Was würdest du tun? Na gut, für heute muss ich Schluss machen. Melde dich doch bald einmal bei mir!", "Viele Grüße"], "signature": "Andreas"}, "hints": ["Überlegen Sie sich vor dem Schreiben eine passende Reihenfolge der punkte, eine passende Betreff, eine"], "criteria": [{"title": "Aufgabenbewältigung", "hint": "Sind alle vier Leitpunkte inhaltlich angemessen bearbeitet?"}, {"title": "Kommunikative Gestaltung", "hint": "Anrede, Gruß, passendes Register und verbundene Sätze statt aneinandergereihter Punkte?"}, {"title": "Formale Richtigkeit", "hint": "Stören Fehler in Grammatik, Wortschatz und Rechtschreibung das Verstehen?"}], "grades": [{"key": "A", "points": 5}, {"key": "B", "points": 3}, {"key": "C", "points": 1}, {"key": "D", "points": 0}], "factor": 3, "maxPoints": 45, "availablePoints": 45, "missing": 0}'::jsonb, 8)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'b1' and t.slug = 'modell-06'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('lv1', '1', 'In Deutschland lernen nur ganz wenige Schüler Griechisch. Es sind insgesamt nur 0.14 aller Schüler. Vor 30 Jahren waren es noch 0,48 So berichtet die griechische Botschaft in Berlin in ihrem Europabericht. Griechisch wird meistens von Zwölftklässlern als dritte Fremdsprache neben Französisch und Englisch gewählt. Die wenigen Schüler, die Griechisch wählen, haben Verwandte in Griechenland.', null::jsonb, 5.0, null::jsonb, 0),
    ('lv1', '2', 'Dem Meer verdankt die Hansestadt Bremen ihre Bedeutung. Bremer Kaufleute und Seefahrer nutzten die günstige geografische Lage, um in aller Welt heimisch zu werden. Seit Generationenhaben sie Handel getrieben, so dass Geld in die Stadt. Dies steht man der Stadt heute noch an: das Alte Rathaus, das Kaufmannhaus, die historische Innenstadt. Außerdem war Bremen auch immer eine Heimat für natürlich das Märchen der Bremer Stadtmusikanten.', null::jsonb, 5.0, null::jsonb, 1),
    ('lv1', '3', 'Freiburg, die Hauptstadt des Schwarzwaldes, liegt in einer der sonnigsten Gegenden Deutschlands. Wo es so viel Sonne gibt, da ist auch viel Lebensfreude, und nicht zuletzt gehören auch badische Küche und badischer Wein zum Besten was in Deutschland geboten wird. Zum einmaligen Flair gemütlichen Universitätsstadt trägt auch ihre Lage bei. Frankreich und die Schweiz sind nicht weit entfernt. Die Stadt selbst lockt mit vielen alten Straßen mit zahlreichen Museen und Baudenkmälern. Über alles hinaus ragt die große Kirche, die nach 300 jähriger Bauzeit 1513 vollendet wurde.', null::jsonb, 5.0, null::jsonb, 2),
    ('lv1', '4', 'In einer wissenschaftlichen Untersuchung hat man erforscht, warum bestimme Menschen mehr Geld verdienen als andere. Britische Wissenschaftler behaupten, größeren Menschen zahlt der Chef mehr. Im Laufe des vergangenen Jahres haben zwei weitere Untersuchungen festgestellt: Wer wenig lacht oder häufig mit Kollegen trinken geht, verdient mehr nur: Nicht lachen und mit Kollegen trinken, gehen das kann man lernen. Aber wachsen?', null::jsonb, 5.0, null::jsonb, 3),
    ('lv1', '5', 'Das Statistische Bundesamt berichtet, dass in deutschen Schulen allgemein wieder mehr Latein gelernt wird. Allein in Thüringen hat sich die Anzahl in den letzten beiden Jahren verdoppelt Während der Tiefpunkt bei Latein im vorletzten Jahr erreicht war, wählen zurzeit wieder mehr Schüler Latein als erste Fremdsprache. Als vorteilhaft hat sich offenbar vor allem das wittenbergische Modell erwiesen, das Latein in der fünften Klasse mit einer modernen Fremdsprache (Französisch, Englisch usw.) kombiniert Allerdinges sind hier meist nur drei Stunden für beide Sprachen pro Woche vorgesehen. Das sei bei Weitem zu wenig, Kritisieren Lateinlehrer Weitem zu wenig kritisieren Lateinlehrer.', null::jsonb, 5.0, null::jsonb, 4),
    ('lv2', '6', 'Gerhard Spur', '[{"key": "A", "text": "arbeitet heute nur noch mit der rechten Hand."}, {"key": "B", "text": "arbeitet früher mit Linkshändern zusammen."}, {"key": "C", "text": "stellt seine Kunstwerke mit der linken Hand her"}]'::jsonb, 5.0, null::jsonb, 0),
    ('lv2', '7', 'Heute ist wissenschaftlich bewiesen, dass', '[{"key": "A", "text": "es eine klare Ursache für Linkshändigkeit gibt."}, {"key": "B", "text": "Linkshänder besser im Lesen und Schreiben sind."}, {"key": "C", "text": "Linkshänder das Schreiben mit der rechten Hand schadet."}]'::jsonb, 5.0, null::jsonb, 1),
    ('lv2', '8', 'Erich Pospischill meint, dass', '[{"key": "A", "text": "es für Linkshänder sehr oft keine geeigneten Arbeitsplätze gibt."}, {"key": "B", "text": "Linkshänder vor allem im Computerbereich eingesetzt werden."}, {"key": "C", "text": "Linkshänder wesentlich öfter krank sind."}]'::jsonb, 5.0, null::jsonb, 2),
    ('lv2', '9', 'Frau Slata Tanasic', '[{"key": "A", "text": "arbeitet seit 41 Jahren in der gleichen Firma."}, {"key": "B", "text": "erledigt alle Arbeiten mit der linken Hand."}, {"key": "C", "text": "ist seit 21 Jahren an der gleichen Maschine beschäftigt."}]'::jsonb, 5.0, null::jsonb, 3),
    ('lv2', '10', 'Laut der Linkshänder-Expertin Johanna Sattier', '[{"key": "A", "text": "haben Linkshänder meistens auch linkshändige Eltern."}, {"key": "B", "text": "kann man Linkshändigkeit bei kleinen Kindern nicht gleich entdecken."}, {"key": "C", "text": "sind linkshändige Kinder besonders gut im Ballspielen."}]'::jsonb, 5.0, null::jsonb, 4),
    ('lv3', '11', 'Sie lieben Krimis und möchten daher einer Krimiautorin beim Vorlesen zuhören.', null::jsonb, 2.5, null::jsonb, 0),
    ('lv3', '12', 'Ihr Bekannter würde gerne am Wochenende ein Boot mieten.', null::jsonb, 2.5, null::jsonb, 1),
    ('lv3', '13', 'Sie möchten sich in einem Hotel in den Bergen erholen und mit dem Zug anreisen.', null::jsonb, 2.5, null::jsonb, 2),
    ('lv3', '14', 'Sie möchten sich eine Märchenvorstellung im Theater ansehen.', null::jsonb, 2.5, null::jsonb, 3),
    ('lv3', '15', 'Ihre Freundin sucht ein angenehmes Hotel, in dem man auch Sport treiben kann.', null::jsonb, 2.5, null::jsonb, 4),
    ('lv3', '16', 'Am Sonntag wollen Sie einen kleinen Ausflug mit Kindern machen. Die Kinder mögen Tiere.', null::jsonb, 2.5, null::jsonb, 5),
    ('lv3', '17', 'Ihre Bekannten möchten gerne im Mai eine Schiffsfahrt machen.', null::jsonb, 2.5, null::jsonb, 6),
    ('lv3', '18', 'Sie möchten gerne am Wochenende tanzen gehen und suchen eine tolle Disco.', null::jsonb, 2.5, null::jsonb, 7),
    ('lv3', '19', 'Der kleine Sohn von Freunden ist begeistert von der Eisenbahn. Sie möchten am Wochenende mit ihm etwas Interessantes machen.', null::jsonb, 2.5, null::jsonb, 8),
    ('lv3', '20', 'Sie möchten im August eine Woche in den Bergen wandern und brauchen eine erfahren Person, die mit Ihnen geht.', null::jsonb, 2.5, null::jsonb, 9),
    ('sb1', '21', '… Jelena, ich hab dir doch schon vom Deutsschkurs erzählt, (21) ich hier besuche. Der ist wirklich ganz gut. Wir haben …', '[{"key": "A", "text": "das"}, {"key": "B", "text": "den"}, {"key": "C", "text": "der"}]'::jsonb, 1.5, null::jsonb, 0),
    ('sb1', '22', '… eine neue Aufgabe bekommen. Wir müssen Informationen (22) Thema Gesundheit und Ernährung suchen und schauen, was es …', '[{"key": "A", "text": "zu"}, {"key": "B", "text": "zum"}, {"key": "C", "text": "zur"}]'::jsonb, 1.5, null::jsonb, 1),
    ('sb1', '23', '… Ernährung suchen und schauen, was es dazu Interessantes (23) Internet gibt. Die interessanteste Internetseite, die ich …', '[{"key": "A", "text": "am"}, {"key": "B", "text": "im"}, {"key": "C", "text": "mit"}]'::jsonb, 1.5, null::jsonb, 2),
    ('sb1', '24', '… gibt. Die interessanteste Internetseite, die ich finden (24) , ist www.gesund.ch. Diese Seite ist für (25) Leute …', '[{"key": "A", "text": "können"}, {"key": "B", "text": "könnten"}, {"key": "C", "text": "konnte"}]'::jsonb, 1.5, null::jsonb, 3),
    ('sb1', '25', '… ich finden (24) , ist www.gesund.ch. Diese Seite ist für (25) Leute gemacht, die gern mehr über gesunde Ernährung …', '[{"key": "A", "text": "junge"}, {"key": "B", "text": "jungen"}, {"key": "C", "text": "junges"}]'::jsonb, 1.5, null::jsonb, 4),
    ('sb1', '26', '… erfahren möchten. Fachleute beschreiben hier genau, (26) Lebensmittel für unseren Körper wichtig und gesund sind …', '[{"key": "A", "text": "welche"}, {"key": "B", "text": "welchen"}, {"key": "C", "text": "welcher"}]'::jsonb, 1.5, null::jsonb, 5),
    ('sb1', '27', '… und wie viel man pro Tag essen sollte. Außerdem kann man (27) seinen persönlichen Speiseplan selbst erstellen und dafür …', '[{"key": "A", "text": "mir"}, {"key": "B", "text": "dir"}, {"key": "C", "text": "sich"}]'::jsonb, 1.5, null::jsonb, 6),
    ('sb1', '28', '… Speiseplan selbst erstellen und dafür passende Rezepte (28) . Für Menschen, (29) ein paar Kilos zu viel haben, gibt …', '[{"key": "A", "text": "fand"}, {"key": "B", "text": "finden"}, {"key": "C", "text": "gefunden"}]'::jsonb, 1.5, null::jsonb, 7),
    ('sb1', '29', '… erstellen und dafür passende Rezepte (28) . Für Menschen, (29) ein paar Kilos zu viel haben, gibt es auch Tipps zum …', '[{"key": "A", "text": "denen"}, {"key": "B", "text": "deren"}, {"key": "C", "text": "die"}]'::jsonb, 1.5, null::jsonb, 8),
    ('sb1', '30', '… in der Schweiz. Und was gibt es bei dir Neues? (30) mir doch möglichst bald zurück! Bis dann und viele Grüße …', '[{"key": "A", "text": "Schreibe"}, {"key": "B", "text": "Schreiben"}, {"key": "C", "text": "Schreibt"}]'::jsonb, 1.5, null::jsonb, 9),
    ('sb2', '31', '… ihre Anzeige habe ich mit Interesse gelesen. Ich bin (31) lange Rentner und bekomme monatlich nur wenig Geld. Wenn …', null::jsonb, 1.5, null::jsonb, 0),
    ('sb2', '32', '… monatlich nur wenig Geld. Wenn ich die Möglichkeit (32) , noch ein wenig zu verdienen, würde mir das sehr helfen. …', null::jsonb, 1.5, null::jsonb, 1),
    ('sb2', '33', '… wenig zu verdienen, würde mir das sehr helfen. Ich bin (33) schon 72 Jahre alt, aber noch bei sehr guter Gesundheit. …', null::jsonb, 1.5, null::jsonb, 2),
    ('sb2', '34', '… guter Gesundheit. Daher denke ich, dass ich die Arbeit (34) Probleme machen kann. Seit über dreißig Jahren treibe ich …', null::jsonb, 1.5, null::jsonb, 3),
    ('sb2', '35', '… Probleme machen kann. Seit über dreißig Jahren treibe ich (35) Tag Sport. Auch das frühe Aufstehen macht mir gar (36) …', null::jsonb, 1.5, null::jsonb, 4),
    ('sb2', '36', '… (35) Tag Sport. Auch das frühe Aufstehen macht mir gar (36) aus. Einige Fragen hätte ich trotzdem noch: Müssen die …', null::jsonb, 1.5, null::jsonb, 5),
    ('sb2', '37', '… Fragen hätte ich trotzdem noch: Müssen die Zeitungen ( 37) ausgetragen werden und wie lange ist man unterwegs? …', null::jsonb, 1.5, null::jsonb, 6),
    ('sb2', '38', '… ist man unterwegs? Außerdem möchte ich natürlich wissen, ( 38) man verdient. Ich bin gerne bereit, mich bei (39) …', null::jsonb, 1.5, null::jsonb, 7),
    ('sb2', '39', '… ( 38) man verdient. Ich bin gerne bereit, mich bei (39) vorzustellen, damit Sie sehen können, dass ich für die …', null::jsonb, 1.5, null::jsonb, 8),
    ('sb2', '40', '… damit Sie sehen können, dass ich für die Tätigkeit (40) bin. Mit freundlichen Grüßen EBERHARD SPITZWEG', null::jsonb, 1.5, null::jsonb, 9),
    ('hv1', '41', 'Die Sprecherin könnte sich vorstellen, mit dem Bus zur Arbeit zu fahren.', null::jsonb, 5.0, null::jsonb, 0),
    ('hv1', '42', 'Die Sprecherin findet es gut, dass sie zur Arbeit ein Stück zu Fuß gehen kann.', null::jsonb, 5.0, null::jsonb, 1),
    ('hv1', '43', 'Der Sprecher fährt nie mit dem Auto zur Arbeit.', null::jsonb, 5.0, null::jsonb, 2),
    ('hv1', '44', 'Der Sprecher benutzt für den Weg zur Arbeit zurzeit verschiedene Verkehrsmittel.', null::jsonb, 5.0, null::jsonb, 3),
    ('hv1', '45', 'Für die Sprecherin ist der Firmenbus die einzige Möglichkeit zur Arbeit zu kommen.', null::jsonb, 5.0, null::jsonb, 4),
    ('hv2', '46', 'Frau Reiter ist die einzige Lokführerin in Deutschland.', null::jsonb, 2.5, null::jsonb, 0),
    ('hv2', '47', 'Sie wollte schon mit 10 Jahren Lokführerin werden.', null::jsonb, 2.5, null::jsonb, 1),
    ('hv2', '48', 'Frau Reiter hat nach der Schule eine Lehrstell als Elektronikerin gefunden', null::jsonb, 2.5, null::jsonb, 2),
    ('hv2', '49', 'Nach der Lehre hat Frau Reiter als Automechanikerin gearbeitet.', null::jsonb, 2.5, null::jsonb, 3),
    ('hv2', '50', 'Frau Reiters Eltern waren mit der Berufswahl ihre Tochter einverstanden.', null::jsonb, 2.5, null::jsonb, 4),
    ('hv2', '51', 'Frau Reiter muss manchmal Reparaturen machen', null::jsonb, 2.5, null::jsonb, 5),
    ('hv2', '52', 'Frau Reiter macht gerne Nachtdienst.', null::jsonb, 2.5, null::jsonb, 6),
    ('hv2', '53', 'Von der Arbeit ist Frau Reiter oft müde', null::jsonb, 2.5, null::jsonb, 7),
    ('hv2', '54', 'Der Mann von Frau Reiter hat regelmäßige Arbeitszeiten.', null::jsonb, 2.5, null::jsonb, 8),
    ('hv2', '55', 'Frau Reiter möchte später Lokführer und Lokführerinnen ausbilden', null::jsonb, 2.5, null::jsonb, 9),
    ('hv3', '56', 'Der Fahrer des Wagens mit dem Kennzeichen HB-D 256 soll ins Erdgeschoss kommen.', null::jsonb, 5.0, null::jsonb, 0),
    ('hv3', '57', 'Die Firma liefert das bestellte Sofa am Dienstag ab drei Uhr nachmittags.', null::jsonb, 5.0, null::jsonb, 1),
    ('hv3', '58', 'Der Gasthof Lindner ist neben einer Tankstelle.', null::jsonb, 5.0, null::jsonb, 2),
    ('hv3', '59', 'Der Film Komiker läuft täglich um 20 Uhr.', null::jsonb, 5.0, null::jsonb, 3),
    ('hv3', '60', 'Das Wetter ist am Abend noch gut.', null::jsonb, 5.0, null::jsonb, 4),
    ('sa', 'A', 'Antworten Sie Andreas. Schreiben Sie etwas zu allen vier Punkten: Vorschlag wie Andreas seinem Arbeitskollegen helfen kann.', null::jsonb, 0, '{"minWords": 100, "points": ["Wie Sie am liebsten arbeiten (alleine oder mit Kollegen)", "Was Sie nach dem Urlaub gemacht haben", "Was es bei Ihnen Neues gibt"]}'::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'b1' and t.slug = 'modell-06'
join sections s on s.test_id = t.id and s.section_id = v.section_id
on conflict (section_id, item_id) do update set text = excluded.text, options = excluded.options, points = excluded.points, meta = excluded.meta, sort = excluded.sort;

insert into item_answers (item_id, answer, explanation)
select i.id, v.answer, v.explanation
from (values
    ('lv1', '1', 'J', null),
    ('lv1', '2', 'E', null),
    ('lv1', '3', 'F', null),
    ('lv1', '4', 'D', null),
    ('lv1', '5', 'G', null),
    ('lv2', '6', 'C', null),
    ('lv2', '7', 'C', null),
    ('lv2', '8', 'A', null),
    ('lv2', '9', 'C', null),
    ('lv2', '10', 'B', null),
    ('lv3', '11', 'K', null),
    ('lv3', '12', 'X', null),
    ('lv3', '13', 'F', null),
    ('lv3', '14', 'E', null),
    ('lv3', '15', 'D', null),
    ('lv3', '16', 'G', null),
    ('lv3', '17', 'L', null),
    ('lv3', '18', 'X', null),
    ('lv3', '19', 'H', null),
    ('lv3', '20', 'A', null),
    ('sb1', '21', 'B', null),
    ('sb1', '22', 'B', null),
    ('sb1', '23', 'B', null),
    ('sb1', '24', 'C', null),
    ('sb1', '25', 'A', null),
    ('sb1', '26', 'A', null),
    ('sb1', '27', 'C', null),
    ('sb1', '28', 'B', null),
    ('sb1', '29', 'C', null),
    ('sb1', '30', 'A', null),
    ('sb2', '31', 'J', 'Das Wort lautet: SCHON'),
    ('sb2', '32', 'C', 'Das Wort lautet: HÄTTE'),
    ('sb2', '33', 'O', 'Das Wort lautet: ZWAR'),
    ('sb2', '34', 'I', 'Das Wort lautet: OHNE'),
    ('sb2', '35', 'E', 'Das Wort lautet: JEDEN'),
    ('sb2', '36', 'H', 'Das Wort lautet: NICHTS'),
    ('sb2', '37', 'L', 'Das Wort lautet: TÄGLICH'),
    ('sb2', '38', 'N', 'Das Wort lautet: WIE VIEL'),
    ('sb2', '39', 'D', 'Das Wort lautet: IHNEN'),
    ('sb2', '40', 'B', 'Das Wort lautet: GEEIGNET'),
    ('hv1', '41', 'f', null),
    ('hv1', '42', 'r', null),
    ('hv1', '43', 'r', null),
    ('hv1', '44', 'f', null),
    ('hv1', '45', 'f', null),
    ('hv2', '46', 'f', null),
    ('hv2', '47', 'f', null),
    ('hv2', '48', 'r', null),
    ('hv2', '49', 'f', null),
    ('hv2', '50', 'r', null),
    ('hv2', '51', 'r', null),
    ('hv2', '52', 'f', null),
    ('hv2', '53', 'r', null),
    ('hv2', '54', 'f', null),
    ('hv2', '55', 'r', null),
    ('hv3', '56', 'r', null),
    ('hv3', '57', 'f', null),
    ('hv3', '58', 'r', null),
    ('hv3', '59', 'r', null),
    ('hv3', '60', 'f', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'b1' and t.slug = 'modell-06'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;

-- ================= modell-07 · ANNIKA3 =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('b1', 'modell-07', 'ANNIKA3', '61 Aufgaben · 150 Minuten',
        '[{"id": "block-lv-sb", "title": "Leseverstehen und Sprachbausteine", "minutes": 90, "hint": "Aufgaben 1–40", "parts": ["lv1", "lv2", "lv3", "sb1", "sb2"], "maxPoints": 105.0, "availablePoints": 105.0, "missing": 0}, {"id": "block-hv", "title": "Hörverstehen", "minutes": 30, "hint": "Aufgaben 41–60", "parts": ["hv1", "hv2", "hv3"], "maxPoints": 75.0, "availablePoints": 75.0, "missing": 0}, {"id": "block-sa", "title": "Schriftlicher Ausdruck", "minutes": 30, "hint": "", "parts": ["sa"], "maxPoints": 45.0, "availablePoints": 45, "missing": 0}]'::jsonb, 61, true, 7)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('lv1', 'Leseverstehen', 'Leseverstehen, Teil 1', 15, 'Lesen Sie die Überschriften a–j und die Texte 1–5. Finden Sie für jeden Text die passende Überschrift. Jede Überschrift passt nur einmal.', 'matching', '{"bank": [{"key": "A", "text": "Finanzielle Unterstützung für Kunstprojekte mit Schülern"}, {"key": "B", "text": "Winterveranstaltung auf dem Eis mit Musik"}, {"key": "C", "text": "Aktionsprogramm der Eu:Finanzielle Unterstützung für italienische Künstler"}, {"key": "D", "text": "Kunstausstellung von italienischen Schülern"}, {"key": "E", "text": "Deutschlernen mit euer Methode im Radio"}, {"key": "F", "text": "Geld für gemeinsame europäische Projekte"}, {"key": "G", "text": "Elternverein organsiert Kunstausstellung"}, {"key": "H", "text": "Mit der Eisenbahn ins winterliche Wien"}, {"key": "I", "text": "Mehr Geld für österreichische Musikschulen"}, {"key": "J", "text": "Wie Sprachaufenthalte auswählen?"}], "bankTitle": "Überschriften", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 0),
    ('lv2', 'Leseverstehen', 'Leseverstehen, Teil 2', 20, 'Lesen Sie den Text und die Aufgaben 6–10. Welche Lösung (A, B oder C) ist jeweils richtig?', 'mc', '{"passages": [{"paragraphs": [{"t": "Philipp Reis der wahre Erfinder des Telefons?", "b": true}, {"t": "Erfinder, Lehrer, Familienvater Auf den Spuren von Philipp Reis besuchte Susanne Müller seinen Geburtsort.", "b": true}, {"t": "Weil sein Vater nie aufgeschrieben habe, was er machte, ist mancher gute Gedanke verloren gegangen, klagt später einmal Karl Reis. Auch gibt es wenige offizielle Berichte und Dokumente über Philipp Reis in", "b": false}, {"t": "Friedrichsdorf und in seiner Geburtsstadt Gelnhausen. Das gilt besonders für das private Leben der Familie Reis, die ab 1852 in unmittelbarer Nähe des berühmten Garnier – Instituts in Friedrichsdorf ein Haus gefunden hatte. Berichte des Sohnes Karl Reis erzählen ein wenig mehr über das Leben des Erfinders. Karl Reis, der beim Tod des Vaters erst elf Jahre alt war, berichtet von einem lieben und gerechten Vater, der sich sehr um seine Frau und seine Kinder gesorgt hat. Wenn der Vater aber seine Experimente machte, vergaß er alles um sich herum.", "b": false}, {"t": "Philipp Reis lernte bereits als Junge viele technische Maschinen kennen und machte eine Reihe von Experimenten, die er als Lehrer am Garnier – Institut fortsetzte. Er entwickelte eine große Anzahl von technischen Geräten, die im Institut gut verwendet werden konnten. Auf die Schüler machte Philipp Reis einen oft sehr merkwürdigen Eindruck. Verunsichert waren die Schüler besonders dann, wenn Reis Aufsicht hatte, aber selbst im Klassenraum gar nicht anwesend war.", "b": false}, {"t": "Trotzdem konnte Reis alles hören und wusste, was passiert war. Philipp Reis hatte eine besondere Kamera gebaut, mit der er von seinem Arbeitszimmer aus, in dem er gleichzeitig Experimente durchführte, in die Klassenräume schauen konnte. Ein Draht, der über den Schulhof in sein Arbeitszimmer führte, diente als Vorläufer des späteren Telefons. Bei den Schülern und Lehrern entstand so der Ruf, dass der Reis auf geheimnisvolle. Weise alles sehen kann.", "b": false}, {"t": "1883 schrieb der englische Professor Silvanus Thompson einen Bericht über Reis und nannte ihn den wahren Erfinder des Telefons. Philipp Reis habe das Telefon entwickelt, und nicht Graham Bell oder Thomas Edison. Diese beiden amerikanischen Forscher hätten auch bei ihren Arbeite zur Entwicklung des Telefons auf Philipp Reis Experimente in Deutschland hingewiesen. Seine offizielle Anerkennung als Erfinder des Telefons hat Philipp Reis allerdings nicht mehr erlebt. Im Jahre 1874 ist er in Friedrichsdorf an einer Lungenkrankheit gestorben.", "b": false}]}], "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 1),
    ('lv3', 'Leseverstehen', 'Leseverstehen, Teil 3', 20, 'Lesen Sie die Situationen 11–20 und die Anzeigen im Bild. Finden Sie für jede Situation die passende Anzeige. Wenn Sie keine passende Anzeige finden, wählen Sie X.', 'matching', '{"bank": [{"key": "A", "text": ""}, {"key": "B", "text": ""}, {"key": "C", "text": ""}, {"key": "D", "text": ""}, {"key": "E", "text": ""}, {"key": "F", "text": ""}, {"key": "G", "text": ""}, {"key": "H", "text": ""}, {"key": "I", "text": ""}, {"key": "J", "text": ""}, {"key": "K", "text": ""}, {"key": "L", "text": ""}, {"key": "X", "text": ""}], "bankTitle": "Anzeigen", "bankImage": "img/m07-lv3.jpg", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 2.5}'::jsonb, 2),
    ('sb1', 'Sprachbausteine', 'Sprachbausteine, Teil 1', 20, 'Lesen Sie den Text und schließen Sie die Lücken 21–30. Welche Lösung (A, B oder C) ist jeweils richtig?', 'mc', '{"passages": [{"paragraphs": [{"t": "An alle Kunden Gewinnen", "b": true}, {"t": "Sehr geehrter Herr Schröder,", "b": true}, {"t": "zum Start (21) das neue Geschäftsjahre haben wir uns für Sie etwas ganz Besonders ausgedacht: einen", "b": false}, {"t": "attraktiven Gewinn! (22) dem Beginn des neuen Geschäftsjahres feiern wir unsere erfolgreiche Buchidee.", "b": false}, {"t": "Machen Sie mit! Es warten auf Sie sehr (23) Gewinne im Wert von vielen Tausend Euro. Mit ihrer", "b": false}, {"t": "Kundennummer können Sie an einem Preisausschreiben teilnehmen. Senden Sie uns (24) das beigefügte", "b": false}, {"t": "Antwortschreiben zurück und bestellen Sie damit – ohne Risiko – das Buch des Monats. Sie erhalten dieses", "b": false}, {"t": "Buch mit (25) versprechen, es nach 10 Tage zurückgeben zu können, sollte Ihnen das Buch nicht gefallen.", "b": false}, {"t": "Ohne irgendetwas zu zahlen! Behalten Sie das Buch, was wir (26) hoffen, zahlen Sie nur 50 Prozent des sonst", "b": false}, {"t": "üblichen Preises in einer Buchhandlung. Gleichzeitig nehmen Sie an einem Preisausschreiben (27).", "b": false}, {"t": "Bitte bedanken Sie: sollte Ihre Kundennummer(28) den richtigen Zahlen sein, haben Sie die Chance, ein Auto", "b": false}, {"t": "eine Reise und viele weitere Preise zu erhalten. Antworten Sie (29) noch diese Woche! Dann haben Sie in jedem Fall die Chance auf den Hauptgewinn - einen Mercedes der S-Klasse. Wenn Sie innerhalb der", "b": false}, {"t": "kommenden vier Wochen antworten, nehmen Sie immer(30) an unserer Gewinnverteilung teil –", "b": false}, {"t": "vorausgesetzt, Sie haben die richtige Kundennummer.", "b": false}, {"t": "Mit freundlichen Grüßen", "b": false}, {"t": "Petra Obermoser", "b": false}, {"t": "Leiterin der Abteilung Marketing", "b": false}]}], "maxPoints": 15.0, "availablePoints": 15.0, "missing": 0, "pointsPerItem": 1.5}'::jsonb, 3),
    ('sb2', 'Sprachbausteine', 'Sprachbausteine, Teil 2', 15, 'Lesen Sie den Text und schließen Sie die Lücken 31–40. Benutzen Sie die Wörter aus der Liste. Jedes Wort passt nur einmal.', 'wordbank', '{"bank": [{"key": "A", "text": "ANFRAGE"}, {"key": "B", "text": "ANGEBOT"}, {"key": "C", "text": "DABEI"}, {"key": "D", "text": "DAFÜR"}, {"key": "E", "text": "DANACH"}, {"key": "F", "text": "DARIN"}, {"key": "G", "text": "DESHALB"}, {"key": "H", "text": "HÄTTE"}, {"key": "I", "text": "MIT"}, {"key": "J", "text": "MÖCHTE"}, {"key": "K", "text": "NÄMLICH"}, {"key": "L", "text": "UNTER"}, {"key": "M", "text": "WÄRE"}, {"key": "N", "text": "WELCHE"}, {"key": "O", "text": "WENN"}], "bankTitle": "Wörterliste", "passages": [{"paragraphs": [{"t": "Sehr geehrte Damen und Herren,", "b": false}, {"t": "seit längerem plane ich eine Wanderreise in die Sahara-Länder. Nun ist mir beim Lesen der Zeitschrift Berge die Anzeige von Geo-Tours aufgefallen, denn (31) steht, dass Sie auf Erlebnisreisen in Wüstenregionen spezialisiert sind. Vielleicht haben Sie das richtige Angebot für uns - (32) für mich und meine 17-Jährige Tochter. Unsere Vorstellungen sind im Einzelnen diese:", "b": false}, {"t": "Zuerst eine Wanderreise, etwa 10 Tage, möglichst leichte Tageswanderungen(ca. 4 – 5 Stunden), und (33) ein Erholungsurlaub am Meer. Bieten Sie solche Kombinationen an? Und (34) ja, zu welchem Preis? Zur Wanderreise (35) ich noch folgende Fragen: Wird das Gepäck von einem Übernachtungsort zum nächsten transportiert? Schläft man immer (36) freiem Himmel? Ich (37) auch wissen, wie die Reisegruppen zusammengesetzt sind, (38) Sprache die Reiseleiterin/ der Reiseleiter spricht und ob ein Arzt (39) ist.", "b": false}, {"t": "Ich freue mich auf Ihr (40).", "b": false}, {"t": "Mit freundlichen Grüßen ANNETTE LUCHSINGER", "b": false}]}], "maxPoints": 15.0, "availablePoints": 15.0, "missing": 0, "pointsPerItem": 1.5}'::jsonb, 4),
    ('hv1', 'Hörverstehen', 'Hörverstehen, Teil 1', 8, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 5),
    ('hv2', 'Hörverstehen', 'Hörverstehen, Teil 2', 14, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 2.5}'::jsonb, 6),
    ('hv3', 'Hörverstehen', 'Hörverstehen, Teil 3', 8, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 7),
    ('sa', 'Schriftlicher Ausdruck', 'Schriftlicher Ausdruck', 30, 'Antworten Sie Annika. Schreiben Sie etwas zu allen vier Punkten:', 'writing', '{"brief": {"intro": "Sie haben von einer Freundin folgenden Brief erhalten:", "greeting": "Liebe(r)........", "paragraphs": ["Wie geht’s dir? Hattest du ein schönes Wochenende? Hier hat es die ganze Zeit geregnet, deshalb bin ich zuhause geblieben.", "Du hattest vorgeschlagen, dass wir im Sommer zusammen verreisen könnten. Die Idee finde ich super! An welches Reiseziel denkst du? Ich bin gerne am Meer, mag aber auch Städterreisen. Wichtig ist für mich nur, dass ich auch ein bisschen Sport machen kann. Die Reise sollte aber nicht zu viel kosten, denn ich habe vor Kurzem schon viel für eine Autoreparatur bezahlen müssen. Was meinst du: wie können wir günstig Urlaub machen? Es muss ja kein Luxushotel sein. Schreib mir bald, dann können wir anfangen zu planen.", "Viele Grüße"], "signature": "Annika"}, "hints": ["Überlegen Sie sich vor dem Schreiben eine passende Reihenfolge der punkte, eine passende Betreff, eine"], "criteria": [{"title": "Aufgabenbewältigung", "hint": "Sind alle vier Leitpunkte inhaltlich angemessen bearbeitet?"}, {"title": "Kommunikative Gestaltung", "hint": "Anrede, Gruß, passendes Register und verbundene Sätze statt aneinandergereihter Punkte?"}, {"title": "Formale Richtigkeit", "hint": "Stören Fehler in Grammatik, Wortschatz und Rechtschreibung das Verstehen?"}], "grades": [{"key": "A", "points": 5}, {"key": "B", "points": 3}, {"key": "C", "points": 1}, {"key": "D", "points": 0}], "factor": 3, "maxPoints": 45, "availablePoints": 45, "missing": 0}'::jsonb, 8)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'b1' and t.slug = 'modell-07'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('lv1', '1', 'Rund 150,000 Sprachreisen werden von Deutschen jährlich unternommen. Der Wunsch, eine andere Sprache zu lernen, kann verschieden Gründe haben: private, schulische oder berufliche. Das Angebot an Sprachreisen wächst ständig, über die Qualität ist jedoch wenig oder nichts bekannt. Im Marktplatz geht es diesmal um Kriterien für das Lernen mit Erfolg. Welche Methoden sind zu empfehlen, welche Anbieter kosten? Ihre Fragen werden am Hörertelefon unter 0800-839601 von Fachleuten beantwortet.', null::jsonb, 5.0, null::jsonb, 0),
    ('lv1', '2', 'Die Metropole Wien lädt zum winterlichen Eisvergnügen vor dem Wiener Rathaus ein: vom 22. Januar bis 7.März kann man auf 1800 Quadratmetern übers Eis fahren. Die Musik dazu bestimmt den Fahrstil und reicht vom klassischen Walzer bis zur Diskomusik. Nachts werden auf der Eisbahn Partys veranstaltet, vom Samba - Fest bis zum Hip-Hop –Event. Speisen und Getränke gibt es an verschiedenen Ständen, Schlittschuhe und Stiefel kann man leihen. Informationen: Wiener Tourismusverband.', null::jsonb, 5.0, null::jsonb, 1),
    ('lv1', '3', 'Für das Aktionsprogramm der Europäischen Union (EU) zur beruflichen Weiterbildung, Leonardo da Vinci, können noch bis zum 31. März Anträge gestellt werden. Ziel des Programms ist es, europäische Projekte zur beruflichen Weiterbildung zu unterstützen Anträge auf finanzielle unterstützen können die Institutionen stellen, die mit mindestens zwei weiteren europäischen Partnern an einem Projekt arbeiten wollen. Information: Nationale Koordinerungsstelle Leonardo da Vinci, Fehrbellineer Platz 3, D-10707 Berlin, Tel, 030//8643-0, Fax- 2637.', null::jsonb, 5.0, null::jsonb, 2),
    ('lv1', '4', 'Wien(SN.APA). Wie das Unterrichtsministerlum mitteilte, sollen im kommenden. Jahr monatlich 70,000 Euro für Kulturprojekte an Schulen zur Verfügung gestellt werden. Unterstützt würden damit Veranstaltungen und Projekte, die das Verständnis der Kinder und Jugendlichen für die Künste wecken, das Interesse am Musisch – Kreativen verstärken und zu Kontakten und einer Auseinandersetzung mit Künstlern führen. Dadurch soll in altersgemäßer Form die ganzheitliche Entwicklung der Persönlichkeit von Kindern und Jugendlichen gefördert werden.', null::jsonb, 5.0, null::jsonb, 3),
    ('lv1', '5', 'Zum sechsten Mal veranstaltet das Comitato Geniton Binnigen/ Bottmingen seine breit angelegte multikulturelle Kunstausstellung Arte. An der Veranstaltung nehmen 70 Künstlerinnen und Künstler aus der Region sowie Gäste aus Italien, Frankreich, Deutschland und weiteren Ländern teil. Bei dem vor 18 Jahren gegründeten Comitato handelt es sich um einen Elternverein, der damals italienischsprachigen Kindern bei ihren Schulprobiemen hilfreich zur Seite stand. Da die jetzige dritte Kindergeneration nicht mehr diese Probleme hat, suchte das Comitato nach neuen Aufgeben und fand in der Organisation der alljährlichen Kunstausstellung ein neues, interessantes Betätigungsfeld.', null::jsonb, 5.0, null::jsonb, 4),
    ('lv2', '6', 'Heute weiß man, dass Philipp Reis', '[{"key": "A", "text": "bei seinen Versuchen die Familie vergaß."}, {"key": "B", "text": "seinen Kindern viel über seine Experimente erzählte."}, {"key": "C", "text": "sogar mit seiner Familie Experimente machte."}]'::jsonb, 5.0, null::jsonb, 0),
    ('lv2', '7', 'Professor Thompson', '[{"key": "A", "text": "hat bei der Entwicklung des Telefons mitgearbeitet."}, {"key": "B", "text": "meinte, dass Reis das Telefon erfunden hat"}, {"key": "C", "text": "war ein Studienkollege von Philipp Reis."}]'::jsonb, 5.0, null::jsonb, 1),
    ('lv2', '8', 'Die Schüler von Philipp Reis', '[{"key": "A", "text": "konnten ihren Lehrer in seinem Arbeitszimmer sehen."}, {"key": "B", "text": "machen in seinem Arbeitszimmer Experimente."}, {"key": "C", "text": "wurden von ihrem Lehrer mit einer Kamera beobachtet"}]'::jsonb, 5.0, null::jsonb, 2),
    ('lv2', '9', 'Über das private Leben von Philipp Reis', '[{"key": "A", "text": "gibt es nur wenige Berichte aus seiner Familie."}, {"key": "B", "text": "kann man im Garnier-Institut viele Berichte finden."}, {"key": "C", "text": "kann man in Gelnhausen viel erfahren."}]'::jsonb, 5.0, null::jsonb, 3),
    ('lv2', '10', 'Philipp Reis', '[{"key": "A", "text": "hat viele technische Geräte gebaut ."}, {"key": "B", "text": "leitete als junger Wissenschaftler das Garnier-Institut."}, {"key": "C", "text": "studierte am Garnier-Institut"}]'::jsonb, 5.0, null::jsonb, 4),
    ('lv3', '11', 'Sie lieben Krimis und möchten daher einer Krimiautorin beim Vorlesen zuhören.', null::jsonb, 2.5, null::jsonb, 0),
    ('lv3', '12', 'Ihr Bekannter würde gerne am Wochenende ein Boot mieten.', null::jsonb, 2.5, null::jsonb, 1),
    ('lv3', '13', 'Sie möchten sich in einem Hotel in den Bergen erholen und mit dem Zug anreisen.', null::jsonb, 2.5, null::jsonb, 2),
    ('lv3', '14', 'Sie möchten sich eine Märchenvorstellung im Theater ansehen.', null::jsonb, 2.5, null::jsonb, 3),
    ('lv3', '15', 'Ihre Freundin sucht ein angenehmes Hotel, in dem man auch Sport treiben kann.', null::jsonb, 2.5, null::jsonb, 4),
    ('lv3', '16', 'Am Sonntag wollen Sie einen kleinen Ausflug mit Kindern machen. Die Kinder mögen Tiere.', null::jsonb, 2.5, null::jsonb, 5),
    ('lv3', '17', 'Ihre Bekannten möchten gerne im Mai eine Schiffsfahrt machen.', null::jsonb, 2.5, null::jsonb, 6),
    ('lv3', '18', 'Sie möchten gerne am Wochenende tanzen gehen und suchen eine tolle Disco.', null::jsonb, 2.5, null::jsonb, 7),
    ('lv3', '19', 'Der kleine Sohn von Freunden ist begeistert von der Eisenbahn. Sie möchten am Wochenende mit ihm etwas Interessantes machen.', null::jsonb, 2.5, null::jsonb, 8),
    ('lv3', '20', 'Sie möchten im August eine Woche in den Bergen wandern und brauchen eine erfahren Person, die mit Ihnen geht.', null::jsonb, 2.5, null::jsonb, 9),
    ('sb1', '21', '… Kunden Gewinnen Sehr geehrter Herr Schröder, zum Start (21) das neue Geschäftsjahre haben wir uns für Sie etwas ganz …', '[{"key": "A", "text": "auf"}, {"key": "B", "text": "in"}, {"key": "C", "text": "über"}]'::jsonb, 1.5, null::jsonb, 0),
    ('sb1', '22', '… ganz Besonders ausgedacht: einen attraktiven Gewinn! (22) dem Beginn des neuen Geschäftsjahres feiern wir unsere …', '[{"key": "A", "text": "Mit"}, {"key": "B", "text": "Von"}, {"key": "C", "text": "Zwischen"}]'::jsonb, 1.5, null::jsonb, 1),
    ('sb1', '23', '… Buchidee. Machen Sie mit! Es warten auf Sie sehr (23) Gewinne im Wert von vielen Tausend Euro. Mit ihrer …', '[{"key": "A", "text": "schöne"}, {"key": "B", "text": "schönen"}, {"key": "C", "text": "schönes"}]'::jsonb, 1.5, null::jsonb, 2),
    ('sb1', '24', '… Sie an einem Preisausschreiben teilnehmen. Senden Sie uns (24) das beigefügte Antwortschreiben zurück und bestellen Sie …', '[{"key": "A", "text": "einfach"}, {"key": "B", "text": "immer"}, {"key": "C", "text": "noch"}]'::jsonb, 1.5, null::jsonb, 3),
    ('sb1', '25', '… – das Buch des Monats. Sie erhalten dieses Buch mit (25) versprechen, es nach 10 Tage zurückgeben zu können, …', '[{"key": "A", "text": "unsere"}, {"key": "B", "text": "unserem"}, {"key": "C", "text": "unseren"}]'::jsonb, 1.5, null::jsonb, 4),
    ('sb1', '26', '… irgendetwas zu zahlen! Behalten Sie das Buch, was wir (26) hoffen, zahlen Sie nur 50 Prozent des sonst üblichen …', '[{"key": "A", "text": "natürlich"}, {"key": "B", "text": "schön"}, {"key": "C", "text": "viele"}]'::jsonb, 1.5, null::jsonb, 5),
    ('sb1', '27', '… Gleichzeitig nehmen Sie an einem Preisausschreiben (27). Bitte bedanken Sie: sollte Ihre Kundennummer(28) den …', '[{"key": "A", "text": "mit"}, {"key": "B", "text": "teil"}, {"key": "C", "text": "zu"}]'::jsonb, 1.5, null::jsonb, 6),
    ('sb1', '28', '… (27). Bitte bedanken Sie: sollte Ihre Kundennummer(28) den richtigen Zahlen sein, haben Sie die Chance, ein Auto …', '[{"key": "A", "text": "unter"}, {"key": "B", "text": "neben"}, {"key": "C", "text": "vor"}]'::jsonb, 1.5, null::jsonb, 7),
    ('sb1', '29', '… Reise und viele weitere Preise zu erhalten. Antworten Sie (29) noch diese Woche! Dann haben Sie in jedem Fall die Chance …', '[{"key": "A", "text": "bald"}, {"key": "B", "text": "bereits"}, {"key": "C", "text": "unbedingt"}]'::jsonb, 1.5, null::jsonb, 8),
    ('sb1', '30', '… der kommenden vier Wochen antworten, nehmen Sie immer(30) an unserer Gewinnverteilung teil – vorausgesetzt, Sie …', '[{"key": "A", "text": "noch"}, {"key": "B", "text": "schon"}, {"key": "C", "text": "schnell"}]'::jsonb, 1.5, null::jsonb, 9),
    ('sb2', '31', '… Berge die Anzeige von Geo-Tours aufgefallen, denn (31) steht, dass Sie auf Erlebnisreisen in Wüstenregionen …', null::jsonb, 1.5, null::jsonb, 0),
    ('sb2', '32', '… sind. Vielleicht haben Sie das richtige Angebot für uns - (32) für mich und meine 17-Jährige Tochter. Unsere …', null::jsonb, 1.5, null::jsonb, 1),
    ('sb2', '33', '… leichte Tageswanderungen(ca. 4 – 5 Stunden), und (33) ein Erholungsurlaub am Meer. Bieten Sie solche …', null::jsonb, 1.5, null::jsonb, 2),
    ('sb2', '34', '… am Meer. Bieten Sie solche Kombinationen an? Und (34) ja, zu welchem Preis? Zur Wanderreise (35) ich noch …', null::jsonb, 1.5, null::jsonb, 3),
    ('sb2', '35', '… an? Und (34) ja, zu welchem Preis? Zur Wanderreise (35) ich noch folgende Fragen: Wird das Gepäck von einem …', null::jsonb, 1.5, null::jsonb, 4),
    ('sb2', '36', '… zum nächsten transportiert? Schläft man immer (36) freiem Himmel? Ich (37) auch wissen, wie die Reisegruppen …', null::jsonb, 1.5, null::jsonb, 5),
    ('sb2', '37', '… transportiert? Schläft man immer (36) freiem Himmel? Ich (37) auch wissen, wie die Reisegruppen zusammengesetzt sind, …', null::jsonb, 1.5, null::jsonb, 6),
    ('sb2', '38', '… auch wissen, wie die Reisegruppen zusammengesetzt sind, (38) Sprache die Reiseleiterin/ der Reiseleiter spricht und ob …', null::jsonb, 1.5, null::jsonb, 7),
    ('sb2', '39', '… Reiseleiterin/ der Reiseleiter spricht und ob ein Arzt (39) ist. Ich freue mich auf Ihr (40). Mit freundlichen Grüßen …', null::jsonb, 1.5, null::jsonb, 8),
    ('sb2', '40', '… spricht und ob ein Arzt (39) ist. Ich freue mich auf Ihr (40). Mit freundlichen Grüßen ANNETTE LUCHSINGER', null::jsonb, 1.5, null::jsonb, 9),
    ('hv1', '41', 'Der Sprecher könnte sich vorstellen, mit dem Bus zur Arbeit zu fahren.', null::jsonb, 5.0, null::jsonb, 0),
    ('hv1', '42', 'Die Sprecherin geht gern zu Fuß.', null::jsonb, 5.0, null::jsonb, 1),
    ('hv1', '43', 'Der Sprecher findet es in Ordnung, dass seine Frau immer das Auto hat', null::jsonb, 5.0, null::jsonb, 2),
    ('hv1', '44', 'Die Sprecherin fährt jeden Tag mit ihrem Motorrad zur Arbeit.', null::jsonb, 5.0, null::jsonb, 3),
    ('hv1', '45', 'Die Sprecherin fährt immer mit dem Fahrrad zur Arbeit.', null::jsonb, 5.0, null::jsonb, 4),
    ('hv2', '46', 'Das Ziel des Vereins UKI ist, ausländische Bürger in Österreich zu unterstützen.', null::jsonb, 2.5, null::jsonb, 0),
    ('hv2', '47', 'Der Verein wendet sich besonders an internationale Manager, weil diese den Verein finanziell unterstützen.', null::jsonb, 2.5, null::jsonb, 1),
    ('hv2', '48', 'Die Abendkurse für Berufstätige dauern neun Monate.', null::jsonb, 2.5, null::jsonb, 2),
    ('hv2', '49', 'Es gibt einen speziellen Deutschkurs für Jugendliche, die eine österreichische Hauptschule besuchen wollen.', null::jsonb, 2.5, null::jsonb, 3),
    ('hv2', '50', 'Es gibt auch Kurse, die nichts mit Deutschlernen zu tun haben.', null::jsonb, 2.5, null::jsonb, 4),
    ('hv2', '51', 'Die Deutschlehrer sind gleichzeitig auch Sozialarbeiter.', null::jsonb, 2.5, null::jsonb, 5),
    ('hv2', '52', 'Sozialarbeiter helfen Ausländern bei Problemen mit Ämtern.', null::jsonb, 2.5, null::jsonb, 6),
    ('hv2', '53', 'Im Kurs werden Papiere für eine Bewerbung vorbereitet.', null::jsonb, 2.5, null::jsonb, 7),
    ('hv2', '54', 'Frauen und Kinder lernen im Unterricht gemeinsam Deutsch.', null::jsonb, 2.5, null::jsonb, 8),
    ('hv2', '55', 'Die Gesetze machen die Arbeit von Frau Böck schwerer.', null::jsonb, 2.5, null::jsonb, 9),
    ('hv3', '56', 'Ihr Flug nach Prag ist nicht pünktlich.', null::jsonb, 5.0, null::jsonb, 0),
    ('hv3', '57', 'Im Speisewagen kann man ins Internet gehen.', null::jsonb, 5.0, null::jsonb, 1),
    ('hv3', '58', 'Montags bis freitags ab 8:00 Uhr kann man sich persönlich beraten lassen.', null::jsonb, 5.0, null::jsonb, 2),
    ('hv3', '59', 'Das Hörspiel Katzen in der Nacht wird morgen um 20:30 Uhr gesendet.', null::jsonb, 5.0, null::jsonb, 3),
    ('hv3', '60', 'Das Flugzeug landet mit 20 Minuten Verspätung in Leipzig.', null::jsonb, 5.0, null::jsonb, 4),
    ('sa', 'A', 'Antworten Sie Annika. Schreiben Sie etwas zu allen vier Punkten:', null::jsonb, 0, '{"minWords": 100, "points": ["Was Sie am Wochenende unternommen haben", "Wohin Sie gerne reisen würden", "Was Sie im Urlaub gerne machen", "Wie man beim Reisen Geld sparren kann"]}'::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'b1' and t.slug = 'modell-07'
join sections s on s.test_id = t.id and s.section_id = v.section_id
on conflict (section_id, item_id) do update set text = excluded.text, options = excluded.options, points = excluded.points, meta = excluded.meta, sort = excluded.sort;

insert into item_answers (item_id, answer, explanation)
select i.id, v.answer, v.explanation
from (values
    ('lv1', '1', 'J', null),
    ('lv1', '2', 'B', null),
    ('lv1', '3', 'F', null),
    ('lv1', '4', 'A', null),
    ('lv1', '5', 'G', null),
    ('lv2', '6', 'A', null),
    ('lv2', '7', 'B', null),
    ('lv2', '8', 'C', null),
    ('lv2', '9', 'A', null),
    ('lv2', '10', 'A', null),
    ('lv3', '11', 'K', null),
    ('lv3', '12', 'X', null),
    ('lv3', '13', 'F', null),
    ('lv3', '14', 'E', null),
    ('lv3', '15', 'D', null),
    ('lv3', '16', 'G', null),
    ('lv3', '17', 'L', null),
    ('lv3', '18', 'X', null),
    ('lv3', '19', 'H', null),
    ('lv3', '20', 'A', null),
    ('sb1', '21', 'B', null),
    ('sb1', '22', 'A', null),
    ('sb1', '23', 'A', null),
    ('sb1', '24', 'A', null),
    ('sb1', '25', 'B', null),
    ('sb1', '26', 'A', null),
    ('sb1', '27', 'B', null),
    ('sb1', '28', 'B', null),
    ('sb1', '29', 'C', null),
    ('sb1', '30', 'A', null),
    ('sb2', '31', 'F', 'Das Wort lautet: DARIN'),
    ('sb2', '32', 'K', 'Das Wort lautet: NÄMLICH'),
    ('sb2', '33', 'E', 'Das Wort lautet: DANACH'),
    ('sb2', '34', 'O', 'Das Wort lautet: WENN'),
    ('sb2', '35', 'H', 'Das Wort lautet: HÄTTE'),
    ('sb2', '36', 'L', 'Das Wort lautet: UNTER'),
    ('sb2', '37', 'J', 'Das Wort lautet: MÖCHTE'),
    ('sb2', '38', 'N', 'Das Wort lautet: WELCHE'),
    ('sb2', '39', 'C', 'Das Wort lautet: DABEI'),
    ('sb2', '40', 'B', 'Das Wort lautet: ANGEBOT'),
    ('hv1', '41', 'f', null),
    ('hv1', '42', 'f', null),
    ('hv1', '43', 'r', null),
    ('hv1', '44', 'r', null),
    ('hv1', '45', 'f', null),
    ('hv2', '46', 'f', null),
    ('hv2', '47', 'f', null),
    ('hv2', '48', 'r', null),
    ('hv2', '49', 'r', null),
    ('hv2', '50', 'r', null),
    ('hv2', '51', 'r', null),
    ('hv2', '52', 'r', null),
    ('hv2', '53', 'r', null),
    ('hv2', '54', 'f', null),
    ('hv2', '55', 'f', null),
    ('hv3', '56', 'f', null),
    ('hv3', '57', 'f', null),
    ('hv3', '58', 'r', null),
    ('hv3', '59', 'f', null),
    ('hv3', '60', 'r', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'b1' and t.slug = 'modell-07'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;

-- ================= modell-08 · IRIS1 =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('b1', 'modell-08', 'IRIS1', '61 Aufgaben · 150 Minuten',
        '[{"id": "block-lv-sb", "title": "Leseverstehen und Sprachbausteine", "minutes": 90, "hint": "Aufgaben 1–40", "parts": ["lv1", "lv2", "lv3", "sb1", "sb2"], "maxPoints": 105.0, "availablePoints": 105.0, "missing": 0}, {"id": "block-hv", "title": "Hörverstehen", "minutes": 30, "hint": "Aufgaben 41–60", "parts": ["hv1", "hv2", "hv3"], "maxPoints": 75.0, "availablePoints": 75.0, "missing": 0}, {"id": "block-sa", "title": "Schriftlicher Ausdruck", "minutes": 30, "hint": "", "parts": ["sa"], "maxPoints": 45.0, "availablePoints": 45, "missing": 0}]'::jsonb, 61, true, 8)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('lv1', 'Leseverstehen', 'Leseverstehen, Teil 1', 15, 'Lesen Sie die Überschriften a–j und die Texte 1–5. Finden Sie für jeden Text die passende Überschrift. Jede Überschrift passt nur einmal.', 'matching', '{"bank": [{"key": "A", "text": "Zufriedenheit im Job schützt vor Stress"}, {"key": "B", "text": "Erfolgreiche Männer können auch gute Väter sein"}, {"key": "C", "text": "Keiner lacht so fröhlich wie der Weihnachtsmann"}, {"key": "D", "text": "Wie Männer und Frauen lachen"}, {"key": "E", "text": "Weniger Arbeit weniger Stress"}, {"key": "F", "text": "Schlechte Nachrichten? Sagen Sie es mit einem Lächeln"}, {"key": "G", "text": "Der Beruf ist für Männer wichtiger als die Familie"}, {"key": "H", "text": "Auch ältere Menschen leiden unter Stress"}, {"key": "I", "text": "Frauen reagieren besser auf schlechte Nachrichten als Männer"}, {"key": "J", "text": "Mit 70 Jahren macht das Leben am meistens Spaß"}], "bankTitle": "Überschriften", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 0),
    ('lv2', 'Leseverstehen', 'Leseverstehen, Teil 2', 20, 'Lesen Sie den Text und die Aufgaben 6–10. Welche Lösung (A, B oder C) ist jeweils richtig?', 'mc', '{"passages": [{"paragraphs": [{"t": "Informationsverhaltungen sind wichtige Grundlagen für die Berufswahl", "b": true}, {"t": "Die Entscheidung, welchen Beruf man erlernen will, ist nicht leicht. Große) Firmen bieten spezielle Information", "b": false}, {"t": "Veranstaltung für Schülerinnen und Schüler an. Wir haben einen Info Nachmittag der Bank Credit Suisse in Bern", "b": false}, {"t": "beucht und uns danach bei den Jugendlichen umgehört.", "b": false}, {"t": "20 Schülerinnen und Schüler kann Irene Leiser um Punkt 13 Uhr zu diesem Info Nachmittag Begrüßen. Die jugendlichen kommen aus dem ganzen Kanton Bern und haben sich vorher bei der Bank angemeldet. Viermal im", "b": false}, {"t": "Frühling und zwei weitere Male im August werden diese Info Veranstaltungen bei der Credit Suisse durchgeführt. Sie", "b": false}, {"t": "richten sich vor allem an Schülerinnen und Schüler aus der 8. Klasse. Irene Leiser hat gute Erfahrungen mit diesen", "b": false}, {"t": "Veranstaltungen gemacht die Jugendlichen können danach ihre Erwartungen an den Beruf und die Ausbildung an die", "b": false}, {"t": "Realität anpassen.", "b": false}, {"t": "Im ersten Teil des Nachmittags erklärt Frau Leiser die Hauptaufgaben einer Bank und stellt die Firma vor. Danach treten", "b": false}, {"t": "die Lehrlinge in Aktion: Daniel Sommer und Linda Schmidt sind im Zweiten Lehrjahre und erzählen aus ihrem", "b": false}, {"t": "Berufsalltag. Dieser Teil gefällt den Schülerinnen und Schülern besonders gut.", "b": false}, {"t": "Die Jugendlichen identifizieren sich mit den Lehrringe und sehen, wo sie selber in zwei Jahren beruflich stehen könnten.", "b": false}, {"t": "Das fasziniert sehr zum Schluss folge Informationen darüber, welche Voraussetzungen man mitbringen muss und wie", "b": false}, {"t": "man sich bewirbt. Um 16:30 Uhr schließt Frau Leiser die Veranstaltung. Sie ist zufrieden mit dem Nachmittag. Die", "b": false}, {"t": "Gruppe war sehr aufmerksam. Interessierten Schülerinnen und Schüler gibt sie folgenden Tipp: Gehen Sie auch noch zu", "b": false}, {"t": "anderen Firmen. Fragen Sie dort möglichst viele Lehrlinge und Mitarbeiter nach ihren Erfahrungen Wir haben danach", "b": false}, {"t": "eine Schülerin und einen Schüler befragt wie sie den Nachmittag erlebt haben:", "b": false}, {"t": "Tugba Kaptan aus Biel, 8. Klasse", "b": false}, {"t": "Mich fasziniert das Umfeld einer Bank. Ich hätte mehr Leute bei der Arbeit sehen wollen zum Beispiel am Schalter. Aber", "b": false}, {"t": "der Tag hat mir weiter geholfen. Ich habe viele Dinge erfahren die ich bis her nicht gewusst habe. Solche Nachmittag ist", "b": false}, {"t": "ideal weil da schulfrei ist.", "b": false}, {"t": "Alan Blank aus Mühleberg,8. Klasse", "b": false}, {"t": "Die Bank ist eigentlich mein Traumbiet und bietet mir nach der Lehre viele Entscheidungsmöglichkeiten. Ich habe mich", "b": false}, {"t": "umgeschaut und mich über viele Beruf informiert. Jetzt weiß ich, dass ich eine Lehre in diesem Bereich machen will. Ich", "b": false}, {"t": "suche nach der optimalen Lehrestelle. Eine Großbank wäre toll für mich. Dieser Nachmittag hat mir gefallen. Alles war", "b": false}, {"t": "sehr gut organisiert. Ich kann solche Veranstaltungen nur empfehlen . Was mir persönlich gefehlt hat, ist eine Führung", "b": false}, {"t": "durch den Betrieb. Es ist wichtig zu sehen, wie das alles genau vor sich geht.", "b": false}]}], "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 1),
    ('lv3', 'Leseverstehen', 'Leseverstehen, Teil 3', 20, 'Lesen Sie die Situationen 11–20 und die Anzeigen im Bild. Finden Sie für jede Situation die passende Anzeige. Wenn Sie keine passende Anzeige finden, wählen Sie X.', 'matching', '{"bank": [{"key": "A", "text": ""}, {"key": "B", "text": ""}, {"key": "C", "text": ""}, {"key": "D", "text": ""}, {"key": "E", "text": ""}, {"key": "F", "text": ""}, {"key": "G", "text": ""}, {"key": "H", "text": ""}, {"key": "I", "text": ""}, {"key": "J", "text": ""}, {"key": "K", "text": ""}, {"key": "L", "text": ""}, {"key": "X", "text": ""}], "bankTitle": "Anzeigen", "bankImage": "img/m08-lv3.jpg", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 2.5}'::jsonb, 2),
    ('sb1', 'Sprachbausteine', 'Sprachbausteine, Teil 1', 20, 'Lesen Sie den Text und schließen Sie die Lücken 21–30. Welche Lösung (A, B oder C) ist jeweils richtig?', 'mc', '{"passages": [{"paragraphs": [{"t": "Schwarzenbek, den", "b": false}, {"t": "…….. Liebe Maria, danke vielmals für die Einladung. Nächste Woche werde ich also (21) dir in Berlin sein. Ich freue mich schon sehr (22) , denn schließlich haben wir uns fast ein (23) Jahr nicht gesehen. Wie du ja weißt, wohne ich jetzt auf dem Land hier in der Nähe von Hamburg und das finde ich ganz toll. (24) ich würde gern auch mal wieder in eine richtige Disko gehen. Mal wieder eine ganze Nascht tanzen, das (25) mein Traum! Und zu zwei macht es viel (26) Spaß!", "b": false}, {"t": "Weißt du eigentlich, ob die Disko am Wittenberger Platz (27) existiert? Leider habe ich noch keine Ahnung, (28) ich in Berlin ankommen werde. Jedenfalls (29) ich versuchen, eine Mitfahrgelegenheit zu finden. Es gibt ja im Internet die Mitfahrzentrale, (30) so etwas organisiert. Also mache dir keine Sorgen, wenn ich etwas später komme! Ich freue mich sehr auf dich! Alexandra", "b": false}]}], "maxPoints": 15.0, "availablePoints": 15.0, "missing": 0, "pointsPerItem": 1.5}'::jsonb, 3),
    ('sb2', 'Sprachbausteine', 'Sprachbausteine, Teil 2', 15, 'Lesen Sie den Text und schließen Sie die Lücken 31–40. Benutzen Sie die Wörter aus der Liste. Jedes Wort passt nur einmal.', 'wordbank', '{"bank": [{"key": "A", "text": "ANTWORTEN"}, {"key": "B", "text": "AUF"}, {"key": "C", "text": "DASS"}, {"key": "D", "text": "DORT"}, {"key": "E", "text": "FRAGEN"}, {"key": "F", "text": "FÜR"}, {"key": "G", "text": "HABEN"}, {"key": "H", "text": "HILFT"}, {"key": "I", "text": "IHNEN"}, {"key": "J", "text": "IHRE"}, {"key": "K", "text": "INFORMIERT"}, {"key": "L", "text": "OB"}, {"key": "M", "text": "RICHTIGE"}, {"key": "N", "text": "WERDEN"}, {"key": "O", "text": "ZU"}], "bankTitle": "Wörterliste", "passages": [{"paragraphs": [{"t": "Frankfurter Allianz Bahnstr. 99 Max Kühne", "b": false}, {"t": "Tel.: 069-951670 Frankfurt, den", "b": false}, {"t": "…….", "b": false}, {"t": "Neuer Berater für Ihre Versicherungen Sehr geehrter Herr Frankel, wir möchten Sie darüber informieren, (31) Ihre Versicherungen künftig von Herrn Max Kühne bearbeitet werden. Ihm wurden (32) Unterlagen übergeben.", "b": false}, {"t": "Alle Kundendaten (33) selbstverständlich streng vertraulich behandelt. Wenn Sie also (34) zu Ihren Versicherungen haben, wenden Sie sich in Zukunft bitte an Herrn Kühne. Er berät und (35) Sie gern. Auch im Schadensfall (36) er Ihnen schnell und zuverlässig weiter. Im Übrigen möchten wir uns (37) einen Fehler in unserer letzten Beitragsrechnung entschuldigen. Leider ist (38) die Adresse von Herrn Kühne nicht korrekt. Seine (39) Anschrift und Telefonnummer finden Sie auf diesem Brief oben rechts.", "b": false}, {"t": "Wir danken (40) für Ihr Vertrauen.", "b": false}, {"t": "Mit freundlichen Grüßen Ihre Frankfurter Allianz", "b": false}]}], "maxPoints": 15.0, "availablePoints": 15.0, "missing": 0, "pointsPerItem": 1.5}'::jsonb, 4),
    ('hv1', 'Hörverstehen', 'Hörverstehen, Teil 1', 8, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 5),
    ('hv2', 'Hörverstehen', 'Hörverstehen, Teil 2', 14, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 2.5}'::jsonb, 6),
    ('hv3', 'Hörverstehen', 'Hörverstehen, Teil 3', 8, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 7),
    ('sa', 'Schriftlicher Ausdruck', 'Schriftlicher Ausdruck', 30, 'Antworten Sie Ihrer Bekannten. Schreiben Sie etwas zu allen vier Punkten: Reaktion auf die Prüfung', 'writing', '{"brief": {"intro": "Eine Bekannte hat Ihnen den folgende E-Mail geschrieben:", "greeting": "Liebe(r)........", "paragraphs": ["endlich habe ich die Deutscheprüfung hinter mir. Ich glaube, es ist gut gelaufen. Jetzt soll für unseren Kurs eine Party organisieren. Du hast doch kürzlich erzählt, dass Du für Euren Kurs auch ein Abschlussfest organsiert hast. Sicher kannst du mir ein paar Tipps geben. Ich habe mir gedacht, wir könnten vielleicht in einem Restaurant feiern .Da kann jeder essen und trinken, was er will . Was meinst Du? Essen zu kochen ist doch ziemlich viel Arbeit. und natürlich brauchen wir Musik. Welche Musik ist am besten geeignet? Was schlägst Du vor?", "Melde Dich bald.", "Ich freue mich schon auf deine Antwort.", "Liebe Grüße"], "signature": "Iris"}, "hints": ["Überlegen Sie sich vor dem Schreiben eine passende Reihenfolge der punkte, eine passende Betreff, eine"], "criteria": [{"title": "Aufgabenbewältigung", "hint": "Sind alle vier Leitpunkte inhaltlich angemessen bearbeitet?"}, {"title": "Kommunikative Gestaltung", "hint": "Anrede, Gruß, passendes Register und verbundene Sätze statt aneinandergereihter Punkte?"}, {"title": "Formale Richtigkeit", "hint": "Stören Fehler in Grammatik, Wortschatz und Rechtschreibung das Verstehen?"}], "grades": [{"key": "A", "points": 5}, {"key": "B", "points": 3}, {"key": "C", "points": 1}, {"key": "D", "points": 0}], "factor": 3, "maxPoints": 45, "availablePoints": 45, "missing": 0}'::jsonb, 8)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'b1' and t.slug = 'modell-08'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('lv1', '1', 'Frauen lachen auf viele Arten Sie kichern glucksen und manchmal singen sie fast Bei Männern dagegen kommt das viel seltener vor. Aber gemeinsam ist Männern und Frauen, dass sie in Vokalen lachen die im Mundzentrum gebildet werden. Und das ist entscheidend: Nur wenn die Vokale im Mundzentrum gebildet werden, ist das Lachen für uns fröhlich und positiv. Damit ist bewiesen, dass das Lachen vom Weihnachtsmann, dass wie eine tiefes Ho, ho, ho klingt. Kaum als fröhlich empfunden wird. Denn dieser Laut wird im hinteren Teil des Mundraums gebildet. (aus einer deutschen Zeitung)', null::jsonb, 5.0, null::jsonb, 0),
    ('lv1', '2', 'Viel Arbeit, viel Stress. Wer viel arbeitet muss nicht unbedingt gestresst sein. Frauen in medizinischen Berufen zum Beispiel klagen trotz teilweise hoher Belastung deutlich weniger über stressbedingte Krankheiten als Raumpflegerinnen, Kindergärtnerinnen oder Berufsschullehrerinnen. Dies zeigt eine Untersuchung des Hamburger IPO Instituts, das für eine Studie 1000 Frauen und Männer befragt hat. Vor Stress schützen laut Studie ein angenehmes Betriebsklima, ein gutes Verhältnis zur Chefin oder zum Chef und die Möglichkeit, die eigene Arbeit selbstständig zu planen. (aus einer deutschen Zeitung)', null::jsonb, 5.0, null::jsonb, 1),
    ('lv1', '3', 'Ein neues Buch zeigt, wie Männer Fähigkeiten aus dem Arbeitsleben auf die Erziehung übertragen können und so zu erfolgreichen Vätern werden. Da wird die gemeinsame Kindererziehung zur Partnerarbeit (oder sogar zum Joint Venture) geschicktes Verhandeln heißt, das Kind zu überzeugen, dass sie Zähne geputzt werden müssen, und der Familienurlaub hat alle Qualitäten einer Tagung oder eines Seminars: Man erhält die Gelegenheit, die Kinder intensiv zu studieren. (aus einer deutschen Zeitung)', null::jsonb, 5.0, null::jsonb, 2),
    ('lv1', '4', 'Eine Studie der Universität Essex hat ergeben dass wir mit siebzig Jahren am glücklichsten sind. Zwar haben die meisten Menschen in diesem Alter gesundheitliche Probleme, aber dafür genießen sie viel Freizeit und haben keinen Stress mehr. Deshalb macht ihnen das Leben so viel Spaß wie nie zuvor. Die Studie besagt auch, dass wir einen ersten Höhepunkt der Lebensfreude mit fünfzehn Jahren erreichen. Danach geht es bergab zwischen dreißig und fünfzig Jahren tragen wir am meisten Verantwortung das Leben ist geprägt von Sachzwängen. (aus einer deutschen Zeitung)', null::jsonb, 5.0, null::jsonb, 3),
    ('lv1', '5', 'Warum bleiben manche Managerinnen erfolgreich, obwohl sie Nachrichten mitteilen, die ihr Publikum lieber nicht hören möchte? Ganz einfach: Sie verkaufen die schlechte Nachricht mit Humor. Ein Londoner Soziologe hat während einer Studie beobachtet, dass gerade bei Reden unangenehmen Inhalts oft heiter gelacht wird. Das Lachen wird bewusst provoziert, etwa durch bestimmte Wörter oder durch ein eigenes breites Lächeln. Die fröhliche Stimmung soll dafür sorgen, dass die Zuhörenden das Gefühl haben würden mehr wissen als alle anderen. (aus einer deutschen Zeitung)', null::jsonb, 5.0, null::jsonb, 4),
    ('lv2', '6', 'Um Berufe kennenzulernen,', '[{"key": "A", "text": "arbeiten Berner Schüler in den Ferien bei großen Firmen."}, {"key": "B", "text": "nehmen Berner Schüler an Informationsveranstaltungen von großen Firmen teil."}, {"key": "C", "text": "sollen Berner Schüler zweimal jährlich ein Praktikum machen."}]'::jsonb, 5.0, null::jsonb, 0),
    ('lv2', '7', 'Frau Leiser', '[{"key": "A", "text": "erzählt aus ihrem Berufsalltag in der Bank."}, {"key": "B", "text": "stellt die wichtigsten Aufgaben der Bank vor."}, {"key": "C", "text": "zeigt den Jugendlichen die ganze Firma."}]'::jsonb, 5.0, null::jsonb, 1),
    ('lv2', '8', 'An dem Informationsnachmittag', '[{"key": "A", "text": "bekamen die Jugendlichen eine Liste mit Bewerbungstipps."}, {"key": "B", "text": "war die Gruppe interessiert und hat gut zugehört."}, {"key": "C", "text": "wurden viele Fragen gestellt."}]'::jsonb, 5.0, null::jsonb, 2),
    ('lv2', '9', 'Tugba Kaptan', '[{"key": "A", "text": "fand es gut, dass sie am Schalter arbeiten durfte."}, {"key": "B", "text": "fand es schade, dass an diesem Nachmittag die Schule ausgefallen ist."}, {"key": "C", "text": "hat viele Informationen bekommen."}]'::jsonb, 5.0, null::jsonb, 3),
    ('lv2', '10', 'Alan Blank', '[{"key": "A", "text": "möchte später gern bei einer Bank arbeiten."}, {"key": "B", "text": "möchte viele Dinge besser nicht selbst entscheiden."}, {"key": "C", "text": "weiß noch nicht, was er machen will."}]'::jsonb, 5.0, null::jsonb, 4),
    ('lv3', '11', 'Ihre Freund wollen einen Sprachkurs in Spanien machen und ihre Kinder mitnehmen.', null::jsonb, 2.5, null::jsonb, 0),
    ('lv3', '12', 'Ihr Auto ist kaputt und Sie brauchen jemanden, der es repariert.', null::jsonb, 2.5, null::jsonb, 1),
    ('lv3', '13', 'Sie wollen mit einem Videoprogramm Deutsch lernen.', null::jsonb, 2.5, null::jsonb, 2),
    ('lv3', '14', 'Sie wollen Ihrer Kursleiterin eine Kursabschlussreise vorschlagen.', null::jsonb, 2.5, null::jsonb, 3),
    ('lv3', '15', 'Ihr Fernseher ist kaputt. Sie wollen ihn reparieren lassen.', null::jsonb, 2.5, null::jsonb, 4),
    ('lv3', '16', 'Eine Bekannte hat eine neue Wohnung. Sie möchten ihr etwas für die Küche schenken.', null::jsonb, 2.5, null::jsonb, 5),
    ('lv3', '17', 'Sie suchen ein Geschenk für ein 6- jähriges Kind.', null::jsonb, 2.5, null::jsonb, 6),
    ('lv3', '18', 'Ihr Kind ist krank. Sie suchen einen Kinderarzt.', null::jsonb, 2.5, null::jsonb, 7),
    ('lv3', '19', 'Ihre Tante ist operiert worden. Jetzt ist sie wieder zu Hause und braucht spezielles Essen.', null::jsonb, 2.5, null::jsonb, 8),
    ('lv3', '20', 'Sie haben sich beim Tennis den Fuß verletzt und brauchen einen Arzt.', null::jsonb, 2.5, null::jsonb, 9),
    ('sb1', '21', '… vielmals für die Einladung. Nächste Woche werde ich also (21) dir in Berlin sein. Ich freue mich schon sehr (22) , denn …', '[{"key": "A", "text": "bei"}, {"key": "B", "text": "nach"}, {"key": "C", "text": "zu"}]'::jsonb, 1.5, null::jsonb, 0),
    ('sb1', '22', '… also (21) dir in Berlin sein. Ich freue mich schon sehr (22) , denn schließlich haben wir uns fast ein (23) Jahr nicht …', '[{"key": "A", "text": "darauf"}, {"key": "B", "text": "darum"}, {"key": "C", "text": "dazu"}]'::jsonb, 1.5, null::jsonb, 1),
    ('sb1', '23', '… schon sehr (22) , denn schließlich haben wir uns fast ein (23) Jahr nicht gesehen. Wie du ja weißt, wohne ich jetzt auf …', '[{"key": "A", "text": "halbe"}, {"key": "B", "text": "halben"}, {"key": "C", "text": "halbes"}]'::jsonb, 1.5, null::jsonb, 2),
    ('sb1', '24', '… hier in der Nähe von Hamburg und das finde ich ganz toll. (24) ich würde gern auch mal wieder in eine richtige Disko …', '[{"key": "A", "text": "Aber"}, {"key": "B", "text": "Sondern"}, {"key": "C", "text": "Trotzdem"}]'::jsonb, 1.5, null::jsonb, 3),
    ('sb1', '25', '… Disko gehen. Mal wieder eine ganze Nascht tanzen, das (25) mein Traum! Und zu zwei macht es viel (26) Spaß! Weißt du …', '[{"key": "A", "text": "hätte"}, {"key": "B", "text": "wäre"}, {"key": "C", "text": "würde"}]'::jsonb, 1.5, null::jsonb, 4),
    ('sb1', '26', '… tanzen, das (25) mein Traum! Und zu zwei macht es viel (26) Spaß! Weißt du eigentlich, ob die Disko am Wittenberger …', '[{"key": "A", "text": "am meisten"}, {"key": "B", "text": "ganz"}, {"key": "C", "text": "mehr"}]'::jsonb, 1.5, null::jsonb, 5),
    ('sb1', '27', '… Weißt du eigentlich, ob die Disko am Wittenberger Platz (27) existiert? Leider habe ich noch keine Ahnung, (28) ich in …', '[{"key": "A", "text": "auch"}, {"key": "B", "text": "noch"}, {"key": "C", "text": "nur"}]'::jsonb, 1.5, null::jsonb, 6),
    ('sb1', '28', '… Platz (27) existiert? Leider habe ich noch keine Ahnung, (28) ich in Berlin ankommen werde. Jedenfalls (29) ich …', '[{"key": "A", "text": "als"}, {"key": "B", "text": "wann"}, {"key": "C", "text": "wenn"}]'::jsonb, 1.5, null::jsonb, 7),
    ('sb1', '29', '… Ahnung, (28) ich in Berlin ankommen werde. Jedenfalls (29) ich versuchen, eine Mitfahrgelegenheit zu finden. Es gibt …', '[{"key": "A", "text": "darf"}, {"key": "B", "text": "soll"}, {"key": "C", "text": "will"}]'::jsonb, 1.5, null::jsonb, 8),
    ('sb1', '30', '… zu finden. Es gibt ja im Internet die Mitfahrzentrale, (30) so etwas organisiert. Also mache dir keine Sorgen, wenn …', '[{"key": "A", "text": "das"}, {"key": "B", "text": "die"}, {"key": "C", "text": "der"}]'::jsonb, 1.5, null::jsonb, 9),
    ('sb2', '31', '… Herr Frankel, wir möchten Sie darüber informieren, (31) Ihre Versicherungen künftig von Herrn Max Kühne …', null::jsonb, 1.5, null::jsonb, 0),
    ('sb2', '32', '… künftig von Herrn Max Kühne bearbeitet werden. Ihm wurden (32) Unterlagen übergeben. Alle Kundendaten (33) …', null::jsonb, 1.5, null::jsonb, 1),
    ('sb2', '33', '… Ihm wurden (32) Unterlagen übergeben. Alle Kundendaten (33) selbstverständlich streng vertraulich behandelt. Wenn Sie …', null::jsonb, 1.5, null::jsonb, 2),
    ('sb2', '34', '… streng vertraulich behandelt. Wenn Sie also (34) zu Ihren Versicherungen haben, wenden Sie sich in Zukunft …', null::jsonb, 1.5, null::jsonb, 3),
    ('sb2', '35', '… Sie sich in Zukunft bitte an Herrn Kühne. Er berät und (35) Sie gern. Auch im Schadensfall (36) er Ihnen schnell und …', null::jsonb, 1.5, null::jsonb, 4),
    ('sb2', '36', '… Kühne. Er berät und (35) Sie gern. Auch im Schadensfall (36) er Ihnen schnell und zuverlässig weiter. Im Übrigen …', null::jsonb, 1.5, null::jsonb, 5),
    ('sb2', '37', '… und zuverlässig weiter. Im Übrigen möchten wir uns (37) einen Fehler in unserer letzten Beitragsrechnung …', null::jsonb, 1.5, null::jsonb, 6),
    ('sb2', '38', '… letzten Beitragsrechnung entschuldigen. Leider ist (38) die Adresse von Herrn Kühne nicht korrekt. Seine (39) …', null::jsonb, 1.5, null::jsonb, 7),
    ('sb2', '39', '… ist (38) die Adresse von Herrn Kühne nicht korrekt. Seine (39) Anschrift und Telefonnummer finden Sie auf diesem Brief …', null::jsonb, 1.5, null::jsonb, 8),
    ('sb2', '40', '… finden Sie auf diesem Brief oben rechts. Wir danken (40) für Ihr Vertrauen. Mit freundlichen Grüßen Ihre …', null::jsonb, 1.5, null::jsonb, 9),
    ('hv1', '41', 'Für die Sprechen ist es unwichtig, ob ihre Kinder in der Schule gut sind.', null::jsonb, 5.0, null::jsonb, 0),
    ('hv1', '42', 'Der Sprecher findet es wichtig, dass Eltern immer für ihre Kinder da sind.', null::jsonb, 5.0, null::jsonb, 1),
    ('hv1', '43', 'Die Sprecherin glaubt, dass sie mehr mit ihrer Tochter sprechen müsste.', null::jsonb, 5.0, null::jsonb, 2),
    ('hv1', '44', 'Es ist dem Sprecher wichtig, dass seine Kinder gesund leben.', null::jsonb, 5.0, null::jsonb, 3),
    ('hv1', '45', 'Der Sprecher möchte, dass sein Kind die eigenen Ideen realisieren kann.', null::jsonb, 5.0, null::jsonb, 4),
    ('hv2', '46', 'Viele Touristen besuchen Torgau wegen seiner historischen Sehenswürdigkeiten.', null::jsonb, 2.5, null::jsonb, 0),
    ('hv2', '47', 'Den Spielpark Hartenfels gibt es schon seit vielen Jahren.', null::jsonb, 2.5, null::jsonb, 1),
    ('hv2', '48', 'Außer dem Spielpark gibt es in der Umgebung viele andere Freizeitmöglichkeiten für die Kinder.', null::jsonb, 2.5, null::jsonb, 2),
    ('hv2', '49', 'Der Spielpark bietet den Kindern Spielmöglichkeiten, die sie zu Hause nicht haben.', null::jsonb, 2.5, null::jsonb, 3),
    ('hv2', '50', 'Die Kinder können im Spielpark auch selbst etwas bauen.', null::jsonb, 2.5, null::jsonb, 4),
    ('hv2', '51', 'Das Spielen am Back kann für die Kinder gefährlich werden.', null::jsonb, 2.5, null::jsonb, 5),
    ('hv2', '52', 'Beide Elternteile müssen auf die Kinder aufpassen.', null::jsonb, 2.5, null::jsonb, 6),
    ('hv2', '53', 'Im Spielpark können Kinder bis zum Alter von sieben von Aufsichtspersonen betreut werden.', null::jsonb, 2.5, null::jsonb, 7),
    ('hv2', '54', 'Der Eintritt in den Spielpark ist zurzeit frei.', null::jsonb, 2.5, null::jsonb, 8),
    ('hv2', '55', 'Die Schlossführung bereitet Kindern und Erwachsenen viel Spaß.', null::jsonb, 2.5, null::jsonb, 9),
    ('hv3', '56', 'Die Linie 2 fährt zum Hauptbahnhof.', null::jsonb, 5.0, null::jsonb, 0),
    ('hv3', '57', 'Das Hallenbad schließt heute um 21:00 Uhr.', null::jsonb, 5.0, null::jsonb, 1),
    ('hv3', '58', 'Sie können mit der S1 nach Hütteldorf fahren.', null::jsonb, 5.0, null::jsonb, 2),
    ('hv3', '59', 'Badezimmerspiegel finden Sie im Untergeschoss.', null::jsonb, 5.0, null::jsonb, 3),
    ('hv3', '60', 'Sie können gleich in Richtung Eilenburg umsteigen.', null::jsonb, 5.0, null::jsonb, 4),
    ('sa', 'A', 'Antworten Sie Ihrer Bekannten. Schreiben Sie etwas zu allen vier Punkten: Reaktion auf die Prüfung', null::jsonb, 0, '{"minWords": 100, "points": ["Wo feiern? Restaurant- Ihre Meinung", "Welche Musik", "Urlaubpläne"]}'::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'b1' and t.slug = 'modell-08'
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
    ('lv2', '6', 'B', null),
    ('lv2', '7', 'B', null),
    ('lv2', '8', 'B', null),
    ('lv2', '9', 'C', null),
    ('lv2', '10', 'A', null),
    ('lv3', '11', 'B', null),
    ('lv3', '12', 'D', null),
    ('lv3', '13', 'X', null),
    ('lv3', '14', 'C', null),
    ('lv3', '15', 'F', null),
    ('lv3', '16', 'H', null),
    ('lv3', '17', 'G', null),
    ('lv3', '18', 'X', null),
    ('lv3', '19', 'L', null),
    ('lv3', '20', 'I', null),
    ('sb1', '21', 'A', null),
    ('sb1', '22', 'A', null),
    ('sb1', '23', 'C', null),
    ('sb1', '24', 'A', null),
    ('sb1', '25', 'B', null),
    ('sb1', '26', 'C', null),
    ('sb1', '27', 'B', null),
    ('sb1', '28', 'B', null),
    ('sb1', '29', 'C', null),
    ('sb1', '30', 'B', null),
    ('sb2', '31', 'C', 'Das Wort lautet: DASS'),
    ('sb2', '32', 'J', 'Das Wort lautet: IHRE'),
    ('sb2', '33', 'N', 'Das Wort lautet: WERDEN'),
    ('sb2', '34', 'E', 'Das Wort lautet: FRAGEN'),
    ('sb2', '35', 'K', 'Das Wort lautet: INFORMIERT'),
    ('sb2', '36', 'H', 'Das Wort lautet: HILFT'),
    ('sb2', '37', 'F', 'Das Wort lautet: FÜR'),
    ('sb2', '38', 'D', 'Das Wort lautet: DORT'),
    ('sb2', '39', 'M', 'Das Wort lautet: RICHTIGE'),
    ('sb2', '40', 'I', 'Das Wort lautet: IHNEN'),
    ('hv1', '41', 'f', null),
    ('hv1', '42', 'r', null),
    ('hv1', '43', 'f', null),
    ('hv1', '44', 'r', null),
    ('hv1', '45', 'r', null),
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
    ('hv3', '56', 'f', null),
    ('hv3', '57', 'r', null),
    ('hv3', '58', 'f', null),
    ('hv3', '59', 'r', null),
    ('hv3', '60', 'r', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'b1' and t.slug = 'modell-08'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;

-- ================= modell-09 · CAROLINA =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('b1', 'modell-09', 'CAROLINA', '61 Aufgaben · 150 Minuten',
        '[{"id": "block-lv-sb", "title": "Leseverstehen und Sprachbausteine", "minutes": 90, "hint": "Aufgaben 1–40", "parts": ["lv1", "lv2", "lv3", "sb1", "sb2"], "maxPoints": 105.0, "availablePoints": 105.0, "missing": 0}, {"id": "block-hv", "title": "Hörverstehen", "minutes": 30, "hint": "Aufgaben 41–60", "parts": ["hv1", "hv2", "hv3"], "maxPoints": 75.0, "availablePoints": 75.0, "missing": 0}, {"id": "block-sa", "title": "Schriftlicher Ausdruck", "minutes": 30, "hint": "", "parts": ["sa"], "maxPoints": 45.0, "availablePoints": 45, "missing": 0}]'::jsonb, 61, true, 9)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('lv1', 'Leseverstehen', 'Leseverstehen, Teil 1', 15, 'Lesen Sie die Überschriften a–j und die Texte 1–5. Finden Sie für jeden Text die passende Überschrift. Jede Überschrift passt nur einmal.', 'matching', '{"bank": [{"key": "A", "text": "Familienbildung Schwerpunkt Beruf und Familie"}, {"key": "B", "text": "Demonstration gegen Fluglärm b)"}, {"key": "C", "text": "Flughafen Frankfurt wird 10 Jahre"}, {"key": "D", "text": "Flughafen Frankfurt beliebter Veranstaltungsort"}, {"key": "E", "text": "Experten gegen Vergrößerung des Flughafens"}, {"key": "F", "text": "Diskussion über Flughafen und Arbeitsplätze"}, {"key": "G", "text": "Neue Kurse: Spiele für Mütter und Kinder"}, {"key": "H", "text": "Umwelt und Flughafen: Ein Informationsabend der Bürger"}, {"key": "I", "text": "Neue Kurse für Kinder"}, {"key": "J", "text": "Neue Kurse: Museumsführung für junge Väter"}], "bankTitle": "Überschriften", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 0),
    ('lv2', 'Leseverstehen', 'Leseverstehen, Teil 2', 20, 'Lesen Sie den Text und die Aufgaben 6–10. Welche Lösung (A, B oder C) ist jeweils richtig?', 'mc', '{"passages": [{"paragraphs": [{"t": "Computerprobleme ein Kinderspiel", "b": true}, {"t": "Anne und Melanie (beide 6) stehen Erzieherinnen mit Vorschlägen hilfreich zur Seite", "b": true}, {"t": "Von Christiane Altenberger", "b": true}, {"t": "Sie sind die Problemlöser im Kindergarten an der Munckerstraße. Wenn das Malprogram spinnt, plötzlich ein Spiel auftaucht, das keiner kennt, dann rufen die Erzieherinnen nach Anne und Melanie. Die sind zwar erst sechs Jahre alt, aber mit den Computerspielen kennen sie sich aus. Die Kinder wissen manchmal mehr als wir", "b": false}, {"t": "sagt Eva Schilling. Leiterin des Kindergartens. Gelernt haben die beiden ihr Know-how bei Multimedia- Landschaften für Kinder, einem Projekt, das das Schulamt zusammen mit dem Studio im Netz gestartet hat.", "b": false}, {"t": "Im Rahmen dieses Projekts werden in städtischen Kindergärten zwei Wanderstationen mit je drei Multimedia- Computern und einem Farbdrucker installiert. Die Stationen wandern durch 14 Kindergärten, wo sie jeweils für vier Wochen installiert werden. Mit dabei in den Kindergärten: ein ganzer Satz von Spiel – Software. Vierjährige am Computer? In Pädagogen kreisen sind viele Berührungsängste da, weiß Edith llg, Fachberaterin für Kindergärten beim Schulamt, aber wir können uns aus dieser Entwicklung nicht ausklinken. Die Kinder wollen sich mit ihrer Umwelt auseinandersetzen. Angefangen hat diese Auseinandersetzung im Studio im Netz – 193 Kinder waren eingeladen, um erste Erfahrungen am Computer zu sammeln. Die Kinder waren absolut begeistert, haben immer wieder gefragt, wann gehen wir da wieder hin, so Frau llg.", "b": false}, {"t": "Bevor jedoch die Computer in die Kindergärten kamen, waren die Eltern aufzuklären. Bei manchen Eltern löste das Stichwort Computer akute Ängste aus nach dem Motto: Mein fröhliches, gesundes Kind setzt sich vor den Computer und steht sechs Stunden später krank,, sprachlos und einsam wieder auf.", "b": false}, {"t": "Diese Ängste haben sich inzwischen gelegt und die Erfahrung vor Ort zeigt, dass sie weitgehend über flüssig sind. Die Erzieherinnen achten auch darauf, dass die Kinder nie länger als 15 bis 20 Minuten vor den Computern sitzen, und holen vor allem kreative Software auf den Bildschirm.", "b": false}, {"t": "Das einsame Dämmern vor dem Computer ist wohl ohnehin eher Sache der Erwachsenen – die Kinder spielen immer zu zweit oder zu dritt an der Maschine. Eva Schilling hat beobachtet, dass die Kinder am Computer sehr friedlich miteinander umgehen, sie helfen sich gegenseitig, es gibt wenig Konflikte. Dabei entwickeln gerade Kinder, die sich sonst nur schwer auf etwas konzentrieren können, plötzlich ungeahnte Konzentrationszeiten. Eva Schilling kann sich deshalb die Computer als Dauereinrichtung im Kindergarten vorstellen.", "b": false}]}], "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 1),
    ('lv3', 'Leseverstehen', 'Leseverstehen, Teil 3', 20, 'Lesen Sie die Situationen 11–20 und die Anzeigen im Bild. Finden Sie für jede Situation die passende Anzeige. Wenn Sie keine passende Anzeige finden, wählen Sie X.', 'matching', '{"bank": [{"key": "A", "text": ""}, {"key": "B", "text": ""}, {"key": "C", "text": ""}, {"key": "D", "text": ""}, {"key": "E", "text": ""}, {"key": "F", "text": ""}, {"key": "G", "text": ""}, {"key": "H", "text": ""}, {"key": "I", "text": ""}, {"key": "J", "text": ""}, {"key": "K", "text": ""}, {"key": "L", "text": ""}, {"key": "X", "text": ""}], "bankTitle": "Anzeigen", "bankImage": "img/m09-lv3.jpg", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 2.5}'::jsonb, 2),
    ('sb1', 'Sprachbausteine', 'Sprachbausteine, Teil 1', 20, 'Lesen Sie den Text und schließen Sie die Lücken 21–30. Welche Lösung (A, B oder C) ist jeweils richtig?', 'mc', '{"passages": [{"paragraphs": [{"t": "Liebe Catherine,", "b": false}, {"t": "seit ich dir letzte Mal von meinem Sprachaufenthalt in der Schweiz (21) habe, ist viel passiert. Ich kenne (22) Land jetzt schon recht gut.", "b": false}, {"t": "Die Schweiz ist ja wirklich nicht groß. (23) in jeder Gegend wird ein anderer Dialekt oder gar eine andere Sprache gesprochen. Das ist (24) mich fast unglaublich! Bei uns in Australien fährt man mit dem Auto 24 Stunden lang geradeaus, und (25)man ankommt, dann sprechen die", "b": false}, {"t": "Leute dort immer noch dieselbe Sprache. Am Anfang hat mich das Sprachgemisch (26) sehr verwirrt , aber (27)verstehe ich fast alles, wenn jemand auf Schweizerdeutsch zu mir spricht. Ich kann aber nur auf Hochdeutsch antworten. Zwischen der Schule hier und unserem Schulsystem in Australien gibt es einige (28) : In der Schweiz sprechen die Lehrer viel und die Schüler (29) Vieles im Kopf behalten oder aufschreiben. In Australien arbeiten wir meistens im Rahmen von Projekten und machen eigentlich alle Aufgaben auf (30) Computer. Viele Grüße", "b": false}, {"t": "Jack", "b": false}]}], "maxPoints": 15.0, "availablePoints": 15.0, "missing": 0, "pointsPerItem": 1.5}'::jsonb, 3),
    ('sb2', 'Sprachbausteine', 'Sprachbausteine, Teil 2', 15, 'Lesen Sie den Text und schließen Sie die Lücken 31–40. Benutzen Sie die Wörter aus der Liste. Jedes Wort passt nur einmal.', 'wordbank', '{"bank": [{"key": "A", "text": "BEI"}, {"key": "B", "text": "BEREITS"}, {"key": "C", "text": "EINMAL"}, {"key": "D", "text": "EURE"}, {"key": "E", "text": "GANZ"}, {"key": "F", "text": "GARANTIEREN"}, {"key": "G", "text": "GESTRN"}, {"key": "H", "text": "KÖNNEN"}, {"key": "I", "text": "MACHEN"}, {"key": "J", "text": "NUR"}, {"key": "K", "text": "STATT"}, {"key": "L", "text": "TECHNISCH"}, {"key": "M", "text": "ÜBER"}, {"key": "N", "text": "UNSER"}, {"key": "O", "text": "WENN"}], "bankTitle": "Wörterliste", "passages": [{"paragraphs": [{"t": "QUANTUM-SYSTEM", "b": true}, {"t": "Das Lotterie Systemspiel", "b": false}, {"t": "Otto – Suhr- Allee 100. D- 10120 Berlin", "b": false}, {"t": "Sehr geehrte Lottospieler,", "b": false}, {"t": "wer möchte nicht auch (31) bei sechs Richtigen im Lotto dabei sein? Vertrauen Sie beim Lottospiel nicht (32) auf das Glück, denn Sie (33) Ihre Chancen selbst strak verbessern, (34) Sie mit unserem Lotterie-System spielen – und das für nur 5 Euro in der Woche!", "b": false}, {"t": "(35) allein zu spielen, spielen Sie mit uns in einer starken Spielergemeinschaft. Dadurch erhöhen sich (36) automatisch Ihre Chancen!", "b": false}, {"t": "Und was Sie gewinnen können? (37). unserem Quantum-System spielen Sie mit einer Chance auf einen Gewinn von 1 Million Euro! Alle Gewinne erhalten Sie umgehend und ungekürzt zu 100%- das (38) wir Ihnen!", "b": false}, {"t": "Davon habe ich mich selbst überzeugt! Spielen Sie mit uns das Quantum – System: (39) 700 Quantum – Systemspielgruppen haben zusammen schon über sieben Millionen Euro gewonnen.", "b": false}, {"t": "Herzliche Grüße, Ihre SABINE MEIER-PÜTZ", "b": false}, {"t": "PS: Als besondere Gewinnchance erhalten Sie heute das. Vier-Richtige-Gratisspiel. (40) Sie hier unbedingt mit und gewinnen Sie! Ich drücke Ihnen die Daumen……", "b": false}]}], "maxPoints": 15.0, "availablePoints": 15.0, "missing": 0, "pointsPerItem": 1.5}'::jsonb, 4),
    ('hv1', 'Hörverstehen', 'Hörverstehen, Teil 1', 8, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 5),
    ('hv2', 'Hörverstehen', 'Hörverstehen, Teil 2', 14, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 2.5}'::jsonb, 6),
    ('hv3', 'Hörverstehen', 'Hörverstehen, Teil 3', 8, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 7),
    ('sa', 'Schriftlicher Ausdruck', 'Schriftlicher Ausdruck', 30, 'Antworten Sie Caroline. Schreiben Sie etwas zu den folgenden vier Punkten:', 'writing', '{"brief": {"intro": "Sie haben von einer Bekannten folgenden E-Mail erhalten:", "greeting": "Liebe(r)........", "paragraphs": ["Du hast schon so lange nicht mehr geschrieben. Wie geht es dir? Heute habe ich eine Bitte. Vielleicht kannst du uns helfen? Eine 16-jährige Schülerin aus deinem Land wird uns besuchen und zwei Wochen bei uns in Goldbach bleiben. Natürlich möchten wir, dass sie sich wohl fühlt. Dein Land kennen wir nur von deinen Erzählungen, denn wir waren selbst noch nicht da. Bitte gib uns ein paar Informationen Z.B über typische Gewohnheiten oder typisches Essen. Was können wir tun und wie können wir uns vorbereiten?", "Wir freuen uns schon auf deine Antwort.", "Schon einmal viele Dank und liebe Grüße"], "signature": "Caroline"}, "hints": ["Überlegen Sie sich vor dem Schreiben eine passende Reihenfolge der punkte, eine passende Betreff, eine"], "criteria": [{"title": "Aufgabenbewältigung", "hint": "Sind alle vier Leitpunkte inhaltlich angemessen bearbeitet?"}, {"title": "Kommunikative Gestaltung", "hint": "Anrede, Gruß, passendes Register und verbundene Sätze statt aneinandergereihter Punkte?"}, {"title": "Formale Richtigkeit", "hint": "Stören Fehler in Grammatik, Wortschatz und Rechtschreibung das Verstehen?"}], "grades": [{"key": "A", "points": 5}, {"key": "B", "points": 3}, {"key": "C", "points": 1}, {"key": "D", "points": 0}], "factor": 3, "maxPoints": 45, "availablePoints": 45, "missing": 0}'::jsonb, 8)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'b1' and t.slug = 'modell-09'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('lv1', '1', 'Der Frankfurter Flughafen wird weiter ausgebaut. Eine Gruppe von Frankfurter Bürgern aus den östlichen Stadtteilen, die sich seit Jahren aktiv für den Naturschutz und die Umwelt einsetzt, lädt für Donnerstag dieser Woche um 19.30 Uhr zu einem Informationsabend über den Ausbau des Frankfurter Flughafens ein. Im Bürgerhaus Ostend, Parkstraße 24, Clubraurn 12, werden verschiedene Sprecher zu hören sein. Die Gruppe möchte Antworten auf folgende Fragen suchen: Wie viel Lärm durch Flugzeuge verträgt die Stadt? Oder Welche Auswirkungen hat der Flugverkehr auf Umwelt und Natur?', null::jsonb, 5.0, null::jsonb, 0),
    ('lv1', '2', 'Der Frankfurter Flughafen erfreut sich bei vielen Firmen als beliebter Ort für Veranstaltungen und Tagungen. Dies zeigt ein Bericht des Frankfurter Flughafens, der beim zehnjährigen Jubiläum des Kongresszentruns vorgelegt wurde. Im Jubiläumsjahr haben am Frankfurter Flughafen 6800 Veranstaltungen mit insgesamt 72000 Teilnehmern stattgefunden. Im Jahr davor waren es nur 6300 Veranstaltungen mit 70000 Gästen. Im Kongresszentrum, das direkt gegenüber dem Hauptgebäude des Flughafens liegt, gibt es 28 Konferenzräume für bis zu 200 Teilnehmer. Modernste Technik wie Laptop-Anschlüsse und Internetzugänge in allen Konferenzräumen sind ebenso vorhanden, wie ein Dolmetscherdienst und verschiedene Speisemöglichkeiten. Eine transportable Videokonferenz-Anlage ermöglicht Verbindungen in die ganze Welt.', null::jsonb, 5.0, null::jsonb, 1),
    ('lv1', '3', 'Eine Bürgergruppe mit dem Namen Südliches Frankfurt lädt für Montag kommender Woche, um 19.30 Uhr ins Pfarrhaus St. Mauritius, Mauritiusstraße 14, zu einer öffentlichen Expertenbefragung zum Thema Arbeitsplätze am Frankfurter Flughafen ein. Der Gruppe liegen Berichte und Daten vor, die nach den Worten der Sprecher der Gruppe sehr fantastisch und zweifelhaft sind. Deshalb hat die Bürgergruppe Südliches Frankfurt den Personalleiter des Frankfurter Flughafens, einen Experten aus dem Wirtschaftsministerium, einen bekannten Stadtentwicklungsplaner und einen Soziologen, der sich mit der Arbeitsplatzentwicklung in der Frankfurter Region beschäftigt, eingeladen. Im Anschluss an die Vorträge der Experten haben die Gäste Zeit, Fragen zu stellen.', null::jsonb, 5.0, null::jsonb, 2),
    ('lv1', '4', 'Das neue Halbjahresprogramm der Evangelischen Familienbildungsstätte bringt eine Übersicht über viele Veranstaltungen. Neben Kursen wie Geburtsvorbereitung und Babypflege steht diesmal das Thema Berufstätige Eltern im Mittelpunkt. In Gruppen und Kursen vor allem für Frauen geht es darum, wie sich nach der Geburt eines Kindes Beruf und Familie miteinander vereinbaren lassen. Das Verhältnis zwischen Mann und Frau spielt eine große Rolle im Angebot der Familienbildung; hierzu gibt es wieder spezielle Programme nur für Frauen oder nur für Männer. Auch zum Verhältnis der Generationen (Großeltern und Enkelkinder) gibt es wieder Angebote. Darüber hinaus wartet das Programm mit Kursen für Entspannung und Zeitmanagement auf, die bei Fragen des Alltags helfen wollen.', null::jsonb, 5.0, null::jsonb, 3),
    ('lv1', '5', 'Die Volkshochschule Dornbirn bietet in den kommenden Wochen neue Kurse an. Am Mittwoch nächster Woche beginnen zwei Malkurse für Kinder. Zweieinhalb- bis vierjährige Kinder treffen sich um 15.30 Uhr, Kinder im Alter von fünf und sechs Jahren um 17.00 Uhr. Für Kinder im Alter zwischen eineinhalb und sechs Jahren und ihre Väter beginnt am Samstag um 10.00 Uhr eine feste Vater-Kind-Gruppe. Am darauf-folgenden Samstag gibt es dann auch ein Treffen für Väter und Kinder bis dreieinhalb Jahren. Etwas anderes ist die Kultur- und Kreativwerkstatt am Montag nächster Woche. Aus Ton und Erde sollen Figuren nach afrikanischen Beispielen gebastelt werden. Zur Vorbereitung treffen sich die Teilnehmer am kommenden Montag zuerst im Museum. Anmeldung spätestens morgen bis 15.00 Uhr.', null::jsonb, 5.0, null::jsonb, 4),
    ('lv2', '6', 'Das Schulamt hat ein Projekt gestartet, bei dem', '[{"key": "A", "text": "Computer in Kindergärten aufgestellt werden."}, {"key": "B", "text": "Computerspiele für Vierjährige entwickelt werden sollen."}, {"key": "C", "text": "Kinder neue Farbdrucker ausprobieren sollen."}]'::jsonb, 5.0, null::jsonb, 0),
    ('lv2', '7', 'Die Kinder', '[{"key": "A", "text": "hatten großen Spaß bei dem Projekt."}, {"key": "B", "text": "wollten lieber draußen im Freien spielen."}, {"key": "C", "text": "wussten nicht, wann sie ins Studio im Netz gehen sollten."}]'::jsonb, 5.0, null::jsonb, 1),
    ('lv2', '8', 'Eltern fürchten, dass', '[{"key": "A", "text": "der Computer ihren Kindern schadet."}, {"key": "B", "text": "ihre Kinder nicht so früh aufstehen können."}, {"key": "C", "text": "ihre Kinder vor dem Computer Angst haben."}]'::jsonb, 5.0, null::jsonb, 2),
    ('lv2', '9', 'Die Erzieherinnen', '[{"key": "A", "text": "arbeiten jeden Tag 15 bis 20 Minuten am Computer."}, {"key": "B", "text": "spielen immer mit zwei oder drei Kindern am Computer."}, {"key": "C", "text": "wählen für die Kinder die Software aus."}]'::jsonb, 5.0, null::jsonb, 3),
    ('lv2', '10', 'Wenn die Kinder am Computer sitzen, dann', '[{"key": "A", "text": "gibt es häufig Streit."}, {"key": "B", "text": "hilft ein Kind dem anderen."}, {"key": "C", "text": "können sich die meisten nicht lange konzentrieren."}]'::jsonb, 5.0, null::jsonb, 4),
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
    ('sb1', '21', '… dir letzte Mal von meinem Sprachaufenthalt in der Schweiz (21) habe, ist viel passiert. Ich kenne (22) Land jetzt schon …', '[{"key": "A", "text": "erzähle"}, {"key": "B", "text": "erzählen"}, {"key": "C", "text": "erzählt"}]'::jsonb, 1.5, null::jsonb, 0),
    ('sb1', '22', '… in der Schweiz (21) habe, ist viel passiert. Ich kenne (22) Land jetzt schon recht gut. Die Schweiz ist ja wirklich …', '[{"key": "A", "text": "diese"}, {"key": "B", "text": "diesen"}, {"key": "C", "text": "dieses"}]'::jsonb, 1.5, null::jsonb, 1),
    ('sb1', '23', '… schon recht gut. Die Schweiz ist ja wirklich nicht groß. (23) in jeder Gegend wird ein anderer Dialekt oder gar eine …', '[{"key": "A", "text": "aber"}, {"key": "B", "text": "obwohl"}, {"key": "C", "text": "sondern"}]'::jsonb, 1.5, null::jsonb, 2),
    ('sb1', '24', '… Dialekt oder gar eine andere Sprache gesprochen. Das ist (24) mich fast unglaublich! Bei uns in Australien fährt man …', '[{"key": "A", "text": "an"}, {"key": "B", "text": "für"}, {"key": "C", "text": "vor"}]'::jsonb, 1.5, null::jsonb, 3),
    ('sb1', '25', '… fährt man mit dem Auto 24 Stunden lang geradeaus, und (25)man ankommt, dann sprechen die Leute dort immer noch …', '[{"key": "A", "text": "als"}, {"key": "B", "text": "wann"}, {"key": "C", "text": "wenn"}]'::jsonb, 1.5, null::jsonb, 4),
    ('sb1', '26', '… dieselbe Sprache. Am Anfang hat mich das Sprachgemisch (26) sehr verwirrt , aber (27)verstehe ich fast alles, wenn …', '[{"key": "A", "text": "denn"}, {"key": "B", "text": "ganz"}, {"key": "C", "text": "schon"}]'::jsonb, 1.5, null::jsonb, 5),
    ('sb1', '27', '… hat mich das Sprachgemisch (26) sehr verwirrt , aber (27)verstehe ich fast alles, wenn jemand auf Schweizerdeutsch …', '[{"key": "A", "text": "früher"}, {"key": "B", "text": "jetzt"}, {"key": "C", "text": "seit"}]'::jsonb, 1.5, null::jsonb, 6),
    ('sb1', '28', '… hier und unserem Schulsystem in Australien gibt es einige (28) : In der Schweiz sprechen die Lehrer viel und die Schüler …', '[{"key": "A", "text": "unterschied"}, {"key": "B", "text": "unterschiede"}, {"key": "C", "text": "unterschieden"}]'::jsonb, 1.5, null::jsonb, 7),
    ('sb1', '29', '… : In der Schweiz sprechen die Lehrer viel und die Schüler (29) Vieles im Kopf behalten oder aufschreiben. In Australien …', '[{"key": "A", "text": "brauchen"}, {"key": "B", "text": "haben"}, {"key": "C", "text": "müssen"}]'::jsonb, 1.5, null::jsonb, 8),
    ('sb1', '30', '… von Projekten und machen eigentlich alle Aufgaben auf (30) Computer. Viele Grüße Jack', '[{"key": "A", "text": "dem"}, {"key": "B", "text": "den"}, {"key": "C", "text": "der"}]'::jsonb, 1.5, null::jsonb, 9),
    ('sb2', '31', '… Berlin Sehr geehrte Lottospieler, wer möchte nicht auch (31) bei sechs Richtigen im Lotto dabei sein? Vertrauen Sie …', null::jsonb, 1.5, null::jsonb, 0),
    ('sb2', '32', '… im Lotto dabei sein? Vertrauen Sie beim Lottospiel nicht (32) auf das Glück, denn Sie (33) Ihre Chancen selbst strak …', null::jsonb, 1.5, null::jsonb, 1),
    ('sb2', '33', '… Sie beim Lottospiel nicht (32) auf das Glück, denn Sie (33) Ihre Chancen selbst strak verbessern, (34) Sie mit …', null::jsonb, 1.5, null::jsonb, 2),
    ('sb2', '34', '… denn Sie (33) Ihre Chancen selbst strak verbessern, (34) Sie mit unserem Lotterie-System spielen – und das für nur …', null::jsonb, 1.5, null::jsonb, 3),
    ('sb2', '35', '… spielen – und das für nur 5 Euro in der Woche! (35) allein zu spielen, spielen Sie mit uns in einer starken …', null::jsonb, 1.5, null::jsonb, 4),
    ('sb2', '36', '… einer starken Spielergemeinschaft. Dadurch erhöhen sich (36) automatisch Ihre Chancen! Und was Sie gewinnen können? …', null::jsonb, 1.5, null::jsonb, 5),
    ('sb2', '37', '… automatisch Ihre Chancen! Und was Sie gewinnen können? (37). unserem Quantum-System spielen Sie mit einer Chance auf …', null::jsonb, 1.5, null::jsonb, 6),
    ('sb2', '38', '… Gewinne erhalten Sie umgehend und ungekürzt zu 100%- das (38) wir Ihnen! Davon habe ich mich selbst überzeugt! Spielen …', null::jsonb, 1.5, null::jsonb, 7),
    ('sb2', '39', '… überzeugt! Spielen Sie mit uns das Quantum – System: (39) 700 Quantum – Systemspielgruppen haben zusammen schon …', null::jsonb, 1.5, null::jsonb, 8),
    ('sb2', '40', '… erhalten Sie heute das. Vier-Richtige-Gratisspiel. (40) Sie hier unbedingt mit und gewinnen Sie! Ich drücke Ihnen …', null::jsonb, 1.5, null::jsonb, 9),
    ('hv1', '41', 'Die Sprecherin wäre lieber ein Einzelkind.', null::jsonb, 5.0, null::jsonb, 0),
    ('hv1', '42', 'Der Sprecher hat heute ein gutes Verhältnis zu seinem Bruder.', null::jsonb, 5.0, null::jsonb, 1),
    ('hv1', '43', 'Die Sprecherin würde heute gern noch eine Schwester haben.', null::jsonb, 5.0, null::jsonb, 2),
    ('hv1', '44', 'Die Sprecherin hat schon früh lernen müssen, dass man im Zusammenleben viel Rücksicht nehmen muss.', null::jsonb, 5.0, null::jsonb, 3),
    ('hv1', '45', 'Die Sprecherin versteht sich sehr gut mit ihrem Bruder.', null::jsonb, 5.0, null::jsonb, 4),
    ('hv2', '46', 'Frau Wallner-Calletti lebt seit fünf Jahren in Italien.', null::jsonb, 2.5, null::jsonb, 0),
    ('hv2', '47', 'Sie wollen zuerst nur ein Jahr an einem italienischen Gymnasium unterrichten.', null::jsonb, 2.5, null::jsonb, 1),
    ('hv2', '48', 'Sie hat ihren Mann bei einem Italienischkurs kennengelernt.', null::jsonb, 2.5, null::jsonb, 2),
    ('hv2', '49', 'Sie eröffnete ein Wiener Restaurant in Rom.', null::jsonb, 2.5, null::jsonb, 3),
    ('hv2', '50', 'Sie hatte am Anfang große Probleme, da sie das Kochen erst lernen musste.', null::jsonb, 2.5, null::jsonb, 4),
    ('hv2', '51', 'Frau Wallner-Calletti besitzt Inzwischen auch ein italienisches Weinlokal.', null::jsonb, 2.5, null::jsonb, 5),
    ('hv2', '52', 'Sie hatte immer große Schwierigkeiten mit den Behörden.', null::jsonb, 2.5, null::jsonb, 6),
    ('hv2', '53', 'Ihre Tochter lernt die deutsche und die italienische Sprache.', null::jsonb, 2.5, null::jsonb, 7),
    ('hv2', '54', 'Sie möchte bald eine Filiale des Wiener Café Central in Rom eröffnen.', null::jsonb, 2.5, null::jsonb, 8),
    ('hv2', '55', 'Sie glaubt, dass man überall Erfolg haben kann, wenn man sich bemüht.', null::jsonb, 2.5, null::jsonb, 9),
    ('hv3', '56', 'Sie müssen in Ingolstadt die Regionalbahn nach Regensburg nehmen.', null::jsonb, 5.0, null::jsonb, 0),
    ('hv3', '57', 'Clara kann wegen einer Prüfung die Theaterkarten nicht abholen.', null::jsonb, 5.0, null::jsonb, 1),
    ('hv3', '58', 'Im Schwarzwald können die Straßen morgen glatt werden.', null::jsonb, 5.0, null::jsonb, 2),
    ('hv3', '59', 'Der Liederabend findet zu einem späteren Termin statt.', null::jsonb, 5.0, null::jsonb, 3),
    ('hv3', '60', 'Im Untergeschoss gibt es Winterkleidung zum halben Preis.', null::jsonb, 5.0, null::jsonb, 4),
    ('sa', 'A', 'Antworten Sie Caroline. Schreiben Sie etwas zu den folgenden vier Punkten:', null::jsonb, 0, '{"minWords": 100, "points": ["Reaktion auf den Besuch der Schülerin", "Vorschlag zu Essen und Trinken", "Warum Sie so lange nicht geschrieben haben", "Unternehmungen/Programm mit der Schülerin"]}'::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'b1' and t.slug = 'modell-09'
join sections s on s.test_id = t.id and s.section_id = v.section_id
on conflict (section_id, item_id) do update set text = excluded.text, options = excluded.options, points = excluded.points, meta = excluded.meta, sort = excluded.sort;

insert into item_answers (item_id, answer, explanation)
select i.id, v.answer, v.explanation
from (values
    ('lv1', '1', 'H', null),
    ('lv1', '2', 'D', null),
    ('lv1', '3', 'F', null),
    ('lv1', '4', 'A', null),
    ('lv1', '5', 'I', null),
    ('lv2', '6', 'A', null),
    ('lv2', '7', 'A', null),
    ('lv2', '8', 'A', null),
    ('lv2', '9', 'C', null),
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
    ('sb1', '21', 'C', null),
    ('sb1', '22', 'C', null),
    ('sb1', '23', 'A', null),
    ('sb1', '24', 'B', null),
    ('sb1', '25', 'C', null),
    ('sb1', '26', 'C', null),
    ('sb1', '27', 'B', null),
    ('sb1', '28', 'B', null),
    ('sb1', '29', 'C', null),
    ('sb1', '30', 'A', null),
    ('sb2', '31', 'C', 'Das Wort lautet: EINMAL'),
    ('sb2', '32', 'J', 'Das Wort lautet: NUR'),
    ('sb2', '33', 'H', 'Das Wort lautet: KÖNNEN'),
    ('sb2', '34', 'O', 'Das Wort lautet: WENN'),
    ('sb2', '35', 'K', 'Das Wort lautet: STATT'),
    ('sb2', '36', 'E', 'Das Wort lautet: GANZ'),
    ('sb2', '37', 'A', 'Das Wort lautet: BEI'),
    ('sb2', '38', 'F', 'Das Wort lautet: GARANTIEREN'),
    ('sb2', '39', 'B', 'Das Wort lautet: BEREITS'),
    ('sb2', '40', 'I', 'Das Wort lautet: MACHEN'),
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
    ('hv2', '52', 'f', null),
    ('hv2', '53', 'r', null),
    ('hv2', '54', 'f', null),
    ('hv2', '55', 'r', null),
    ('hv3', '56', 'f', null),
    ('hv3', '57', 'f', null),
    ('hv3', '58', 'r', null),
    ('hv3', '59', 'r', null),
    ('hv3', '60', 'f', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'b1' and t.slug = 'modell-09'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;

-- ================= modell-10 · VERA =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('b1', 'modell-10', 'VERA', '61 Aufgaben · 150 Minuten',
        '[{"id": "block-lv-sb", "title": "Leseverstehen und Sprachbausteine", "minutes": 90, "hint": "Aufgaben 1–40", "parts": ["lv1", "lv2", "lv3", "sb1", "sb2"], "maxPoints": 105.0, "availablePoints": 105.0, "missing": 0}, {"id": "block-hv", "title": "Hörverstehen", "minutes": 30, "hint": "Aufgaben 41–60", "parts": ["hv1", "hv2", "hv3"], "maxPoints": 75.0, "availablePoints": 75.0, "missing": 0}, {"id": "block-sa", "title": "Schriftlicher Ausdruck", "minutes": 30, "hint": "", "parts": ["sa"], "maxPoints": 45.0, "availablePoints": 45, "missing": 0}]'::jsonb, 61, true, 10)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('lv1', 'Leseverstehen', 'Leseverstehen, Teil 1', 15, 'Lesen Sie die Überschriften a–j und die Texte 1–5. Finden Sie für jeden Text die passende Überschrift. Jede Überschrift passt nur einmal.', 'matching', '{"bank": [{"key": "A", "text": "Abendwanderungen ab89Euro"}, {"key": "B", "text": "Ausflugsziele für Literaturinteressierte"}, {"key": "C", "text": "Hinweis für Besucher der Bregenzer Festspiele"}, {"key": "D", "text": "Ihre Zeitung folgt Ihnen in den Urlaub"}, {"key": "E", "text": "Laute Musik stört den Nachbarn"}, {"key": "F", "text": "MusikveranstaltungenamNachmittag"}, {"key": "G", "text": "Neue Zeitung für Ihre Urlaubsplanung"}, {"key": "H", "text": "Rekord: 70.000 Besucher im Bücherdorf"}, {"key": "I", "text": "Schlechtes Wetter: Festspiele abgesagt"}, {"key": "J", "text": "Wandern ohne Gepäck"}], "bankTitle": "Überschriften", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 0),
    ('lv2', 'Leseverstehen', 'Leseverstehen, Teil 2', 20, 'Lesen Sie den Text und die Aufgaben 6–10. Welche Lösung (A, B oder C) ist jeweils richtig?', 'mc', '{"passages": [{"paragraphs": [{"t": "Computerprobleme ein Kinderspiel", "b": true}, {"t": "Anne und Melanie (beide 6) stehen Erzieherinnen mit Vorschlägen hilfreich zur Seite", "b": true}, {"t": "Von Christiane Altenberger", "b": true}, {"t": "Sie sind die Problemlöser im Kindergarten an der Munckerstraße. Wenn das Malprogram spinnt, plötzlich ein", "b": false}, {"t": "Spiel auftaucht, das keiner kennt, dann rufen die Erzieherinnen nach Anne und Melanie. Die sind zwar erst", "b": false}, {"t": "sechs Jahre alt, aber mit den Computerspielen kennen sie sich aus. Die Kinder wissen manchmal mehr als wir", "b": false}, {"t": "sagt Eva Schilling. Leiterin des Kindergartens. Gelernt haben die beiden ihr Know-how bei Multimedia-", "b": false}, {"t": "Landschaften für Kinder, einem Projekt, das das Schulamt zusammen mit dem Studio im Netz gestartet hat.", "b": false}, {"t": "Im Rahmen dieses Projekts werden in städtischen Kindergärten zwei Wanderstationen mit je drei Multimedia-", "b": false}, {"t": "Computern und einem Farbdrucker installiert. Die Stationen wandern durch 14 Kindergärten, wo sie jeweils", "b": false}, {"t": "für vier Wochen installiert werden. Mit dabei in den Kindergärten: ein ganzer Satz von Spiel – Software.", "b": false}, {"t": "Vierjährige am Computer? In Pädagogen kreisen sind viele Berührungsängste da, weiß Edith llg, Fachberaterin", "b": false}, {"t": "für Kindergärten beim Schulamt, aber wir können uns aus dieser Entwicklung nicht ausklinken. Die Kinder", "b": false}, {"t": "wollen sich mit ihrer Umwelt auseinandersetzen. Angefangen hat diese Auseinandersetzung im Studio im Netz – 193 Kinder waren eingeladen, um erste Erfahrungen am Computer zu sammeln. Die Kinder waren absolut", "b": false}, {"t": "begeistert, haben immer wieder gefragt, wann gehen wir da wieder hin, so Frau llg.", "b": false}, {"t": "Bevor jedoch die Computer in die Kindergärten kamen, waren die Eltern aufzuklären. Bei manchen Eltern löste", "b": false}, {"t": "das Stichwort Computer akute Ängste aus nach dem Motto: Mein fröhliches, gesundes Kind setzt sich vor den", "b": false}, {"t": "Computer und steht sechs Stunden später krank, sprachlos und einsam wieder auf.", "b": false}, {"t": "Diese Ängste haben sich inzwischen gelegt und die Erfahrung vor Ort zeigt, dass sie weitgehend über flüssig", "b": false}, {"t": "sind. Die Erzieherinnen achten auch darauf, dass die Kinder nie länger als 15 bis 20 Minuten vor den", "b": false}, {"t": "Computern sitzen, und holen vor allem kreative Software auf den Bildschirm.", "b": false}, {"t": "Das einsame Dämmern vor dem Computer ist wohl ohnehin eher Sache der Erwachsenen – die Kinder spielen", "b": false}, {"t": "immer zu zweit oder zu dritt an der Maschine. Eva Schilling hat beobachtet, dass die Kinder am Computer sehr", "b": false}, {"t": "friedlich miteinander umgehen, sie helfen sich gegenseitig, es gibt wenig Konflikte. Dabei entwickeln gerade", "b": false}, {"t": "Kinder, die sich sonst nur schwer auf etwas konzentrieren können, plötzlich ungeahnte Konzentrationszeiten.", "b": false}, {"t": "Eva Schilling kann sich deshalb die Computer als Dauereinrichtung im Kindergarten vorstellen.", "b": false}]}], "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 1),
    ('lv3', 'Leseverstehen', 'Leseverstehen, Teil 3', 20, 'Lesen Sie die Situationen 11–20 und die Anzeigen im Bild. Finden Sie für jede Situation die passende Anzeige. Wenn Sie keine passende Anzeige finden, wählen Sie X.', 'matching', '{"bank": [{"key": "A", "text": ""}, {"key": "B", "text": ""}, {"key": "C", "text": ""}, {"key": "D", "text": ""}, {"key": "E", "text": ""}, {"key": "F", "text": ""}, {"key": "G", "text": ""}, {"key": "H", "text": ""}, {"key": "I", "text": ""}, {"key": "J", "text": ""}, {"key": "K", "text": ""}, {"key": "L", "text": ""}, {"key": "X", "text": ""}], "bankTitle": "Anzeigen", "bankImage": "img/m10-lv3.jpg", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 2.5}'::jsonb, 2),
    ('sb1', 'Sprachbausteine', 'Sprachbausteine, Teil 1', 20, 'Lesen Sie den Text und schließen Sie die Lücken 21–30. Welche Lösung (A, B oder C) ist jeweils richtig?', 'mc', '{"passages": [{"paragraphs": [{"t": "Liebe Beatrice, wie du ja weißt, sind meine Eltern seit Anfang Mai in einem Haus (21)Mittelnehmer in Spanien. Zuerst wollen meine Eltern warten, bis ich mit dem Gymnasium fertig bin. Aber dann sind sie doch (22) früher gefahren. Als ich im Sommer 18 wurde, wollte ich mit (23) älteren Bruder zusammen eine kleine Wohnung mieten. Das hat aber nicht geklappt. Eine Freundin hat (24) dann ein Zimmer inihrer Wohngemeinschaft angeboten. Ich wohne jetzt mit drei (25) zusammen in der Innenstadt. Ich bin sehr zufrieden, (26) mein Zimmer recht klein ist. In der Schule habe ich keine Probleme. Ich staune selbst über meine Noten, wenn ich (27) denke, wie (28) Zeit ich mir für Hausaufgaben nehme.", "b": false}, {"t": "Manchmal schicken mir meine Eltern eine E-Mail. (29) sie rufen an.", "b": false}, {"t": "(30) jetzt habe ich jede Woche von ihnen gehört. Das war’s für heute, bis bald und liebe Grüße Saskia", "b": false}]}], "maxPoints": 15.0, "availablePoints": 15.0, "missing": 0, "pointsPerItem": 1.5}'::jsonb, 3),
    ('sb2', 'Sprachbausteine', 'Sprachbausteine, Teil 2', 15, 'Lesen Sie den Text und schließen Sie die Lücken 31–40. Benutzen Sie die Wörter aus der Liste. Jedes Wort passt nur einmal.', 'wordbank', '{"bank": [{"key": "A", "text": "ABER"}, {"key": "B", "text": "AUSSEN"}, {"key": "C", "text": "EINMAL"}, {"key": "D", "text": "ENTDECKT"}, {"key": "E", "text": "ETWAS"}, {"key": "F", "text": "HATTEN"}, {"key": "G", "text": "KENNEN"}, {"key": "H", "text": "LERNEN"}, {"key": "I", "text": "OFT"}, {"key": "J", "text": "PAAR"}, {"key": "K", "text": "UNS"}, {"key": "L", "text": "WANN"}, {"key": "M", "text": "WEIL"}, {"key": "N", "text": "WENN"}, {"key": "O", "text": "WÜRDEN"}], "bankTitle": "Wörterliste", "passages": [{"paragraphs": [{"t": "meinen trotz Sondern", "b": false}, {"t": "C C", "b": false}, {"t": "Chiffre 2063/9369 Sehr geehrter Unbekannter,", "b": false}, {"t": "mein Mann und ich haben Ihre Anzeige in den Mitteilungen des Deutschen. Alpenvereins (31). Wir wohnen etwa 40 km außerhalb von Nürnberg und schreiben Ihnen, (32) wir Lust hätten, etwas in einer Gruppe zu machen.", "b": false}, {"t": "Unseren Sommerurlaub verbringen wir eigentlich regelmäßig in den Bergen. Und (33) es unser Terminkalender erlaubt, gehen wir auch noch am Wochenende wandern, (34) fahren wir in die Gegend vom Wilden Kaiser, wo wir inzwischen alle Wanderwege (35).", "b": false}, {"t": "Wir fahren zwar beide auch Ski, (36) der Winter den Bergen ist nicht so unbedingt unsere Sache. Dagegen macht es (37) viel Spaß. Fahrrad zu fahren,; hier in Leupoldstein haben wir tolle Radwege, die durch die Felder führen. Daher (38) wir uns auch auf gemeinsame Radtouren hier bei uns freuen.", "b": false}, {"t": "Zum Schluss noch ein (39) Worte zu uns selbst. Wir sind 64 und 62. Jahre alt, lieben Musik und gehen ab und zu gern ins Theater. Rufen Sie uns doch einfach (40) an: Tel.: 09243/7448.", "b": false}, {"t": "Viele Grüße Ilka und Heiner Grossmann", "b": false}]}], "maxPoints": 15.0, "availablePoints": 15.0, "missing": 0, "pointsPerItem": 1.5}'::jsonb, 4),
    ('hv1', 'Hörverstehen', 'Hörverstehen, Teil 1', 8, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 5),
    ('hv2', 'Hörverstehen', 'Hörverstehen, Teil 2', 14, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 2.5}'::jsonb, 6),
    ('hv3', 'Hörverstehen', 'Hörverstehen, Teil 3', 8, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 7),
    ('sa', 'Schriftlicher Ausdruck', 'Schriftlicher Ausdruck', 30, 'Antworten Sie Vera. Schreiben Sie etwas zu allen vier Punkte:', 'writing', '{"brief": {"intro": "Eine Freundin hat Ihnen den folgenden Brief geschrieben:", "greeting": "Liebe(r)........", "paragraphs": ["Wie geht es dir und deiner Familie? Bei mir läuft alles prima. Endlich habe ich eine neue Arbeitsstelle. Ich habe nur ein kleines Problem: Es ist ein bisschen zu weit, um zu Fuß zu gehen. Und der Bus fährt nur alle 30 Minuten. Früher bin ich meist mit dem Fahrrad gefahren, aber hier gibt es keine Fahrradwege. Und da ist ja auch noch mein Daniel, den ich morgens in den Kindergarten bringen muss.", "Der liegt zum Glück gleich neben meiner neuen Firma. – Wie kommst du denn zur Arbeit oder zum Deutschkurs?", "Wollen wir uns nicht mal wieder treffen und alle zusammen was unternehmen? Ich würde mich freuen.", "Liebe Grüße"], "signature": "Vera"}, "hints": ["Überlegen Sie sich vor dem Schreiben eine passende Reihenfolge der punkte, eine passende Betreff, eine"], "criteria": [{"title": "Aufgabenbewältigung", "hint": "Sind alle vier Leitpunkte inhaltlich angemessen bearbeitet?"}, {"title": "Kommunikative Gestaltung", "hint": "Anrede, Gruß, passendes Register und verbundene Sätze statt aneinandergereihter Punkte?"}, {"title": "Formale Richtigkeit", "hint": "Stören Fehler in Grammatik, Wortschatz und Rechtschreibung das Verstehen?"}], "grades": [{"key": "A", "points": 5}, {"key": "B", "points": 3}, {"key": "C", "points": 1}, {"key": "D", "points": 0}], "factor": 3, "maxPoints": 45, "availablePoints": 45, "missing": 0}'::jsonb, 8)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'b1' and t.slug = 'modell-10'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('lv1', '1', 'Wenn Sie verreisen, wünschen wir ihnen erholsame und angenehme Ferienlage Bitte denken Sie daran, sich ihre Zeitung in den Urlaubtort nachsenden zu lassen. Denn mit den Neuigkeiten von zu Hause und aus aller Weil lässt sich die schönste Zeit des Jahres erst richtig genießen ganz Europa kostenlos, Die Höhe des Bezeugendes bleibt unverändert. Ausführliche Informationen und entsprechende Coupons ihrem Europabericht. Griechisch wird meistens von Zwölftklässlern als dritte Fremdsprache neben Französisch und Englisch gewählt. finden Sie in unserem großen Reise Service – Anzeigen oder rufen Sie uns einfach an: Telefon 01 30-18 58 50 zum Nulltarif. Hannoversche Allgemeine Neue Presse', null::jsonb, 5.0, null::jsonb, 0),
    ('lv1', '2', 'Im Luftkurort Stadtkylf in der MMittelgebirgslandschaft des Oberen Kullas werden dreitägige Wanderrungenn ohne Gepäck veranstaltet Die Rundwanderung im deutsch – bei gischen Naturpark führt abends zu reservierten Zimmern. Die Betriebe übernehmen den Gepäcktransport zum nächsten Tagesziel. Die Wanderungen werden ganzjährig angeboten. In den Wanderprogramm sind drei Übernachtungen mit Frühstück dreimal Gepäcktransport, eine Wanderkarte, eine Wegbeschreibung und ein Wanderpass enthalten. Der Pauschalbetrag beträgt pro Person 89 Euro. Auskünfte: Verkehrsverein Erholungsgebiet Oberes Kylltal. Kurallee, 54589 Stadtkylf, Telefon ( 06597) 28 78.', null::jsonb, 5.0, null::jsonb, 1),
    ('lv1', '3', 'Für den einen ist es musikalischer Hochgenuss für den anderen schlicht Lärm. Gemeint ist Musik, die aus Lautsprechen, Radios oder durch Musikinstrumente durch geöffnet Türen und Fenster bei sommerlichen Temperaturen ins Freie dringt. Die Gemeinde weist darauf hin, dass der Mittagsruhe von 13 bis 15 Uhr und nachts von 22 bis 7 Uhr keine musikalische Ruhestörung erfolgen darf. Gartengeräte mit Motoren dürfen montags bis freitags nur von 8 bis 13 und von 15 bis 19 Uhr benutzt werden, an Sonnabenden von 9 bis 13 Uhr. An Sonn - und Feiertagen dürfen die Geräte nicht zum Einsatz kommen.', null::jsonb, 5.0, null::jsonb, 2),
    ('lv1', '4', '– In dem Bücherdorf in Mühlbeck/ Fredersdorf(Sachsen Anhalt ) warten in acht Antiquarten über 7000 Bücher aus allen Bereichen der Literatur auf Interessenten. In acht Antiquariten warten über 70000 Bücher aus allen Bereichen der Literatur auf Interessenten. Das in reizvoller landschaftlicher Umgebung liegende Bücherdorf nahe Bitterfeld unweit der A19 und des Flughafens Leipzig ist aus allen Teilen Deutschlands leicht zu erreich. Geöffnet sind die Antiquariate auch am Samstag und Sonntag. In Europa gibt es bereits zahlreiche solcher Bücherdörfer.u.a. in Belgien Frankreich Großbritannien den Initiatorin des deutschen Bücherdorfes ist Heidi Dehne (Tel. 03493/4 30 43).', null::jsonb, 5.0, null::jsonb, 3),
    ('lv1', '5', 'Die Bregenzer Festspiele sind bemüht, die Vorstellungen auch bei zweifelhafter Witterung bzw. leichtem Regen auf der Seebühne abzuhalten, weshalb es zu Verzögerungen des Beginns oder zu Unterbrechungen kommen kann. Sollte die Seeaufführung nicht stattfinden können, wird eine halbszenische Version von Porgy and Bess im Festspielhaus gegeben. Wir empfehlen unseren Gästen, bei unsicherer Wetterlage regenfester Kleidung den Vorzug zu geben und auf Schirme zu verzichten, da diese die Sicht beeinträchtigen. Das Spiel auf dem See wird ohne Pause gespielt. Die Spieldauer beträgt ca.2 Std. 45 Min.', null::jsonb, 5.0, null::jsonb, 4),
    ('lv2', '6', 'Das Schulamt hat ein Projekt gestartet, bei dem', '[{"key": "A", "text": "Computer in Kindergärten aufgestellt werden."}, {"key": "B", "text": "Computerspiele für Vierjährige entwickelt werden sollen."}, {"key": "C", "text": "Kinder neue Farbdrucker ausprobieren sollen."}]'::jsonb, 5.0, null::jsonb, 0),
    ('lv2', '7', 'Die Kinder', '[{"key": "A", "text": "hatten großen Spaß bei dem Projekt."}, {"key": "B", "text": "wollten lieber draußen im Freien spielen."}, {"key": "C", "text": "wussten nicht, wann sie ins Studio im Netz gehen sollten."}]'::jsonb, 5.0, null::jsonb, 1),
    ('lv2', '8', 'Eltern fürchten, dass', '[{"key": "A", "text": "der Computer ihren Kindern schadet ."}, {"key": "B", "text": "ihre Kinder nicht so früh aufstehen können."}, {"key": "C", "text": "ihre Kinder vor dem Computer Angst haben."}]'::jsonb, 5.0, null::jsonb, 2),
    ('lv2', '9', 'Die Erzieherinnen', '[{"key": "A", "text": "arbeiten jeden Tag 15 bis 20 Minuten am Computer."}, {"key": "B", "text": "spielen immer mit zwei oder drei Kindern am Computer."}, {"key": "C", "text": "wählen für die Kinder die Software aus."}]'::jsonb, 5.0, null::jsonb, 3),
    ('lv2', '10', 'Wenn die Kinder am Computer sitzen, dann', '[{"key": "A", "text": "gibt es häufig Streit."}, {"key": "B", "text": "hilft ein Kind dem anderen."}, {"key": "C", "text": "können sich die meisten nicht lange konzentrieren."}]'::jsonb, 5.0, null::jsonb, 4),
    ('lv3', '11', 'Sie haben von einer noch unbekannten Schauspielerin gehört und möchten gern einen Film sehen.', null::jsonb, 2.5, null::jsonb, 0),
    ('lv3', '12', 'Sie haben bereits in einem Hotel gearbeitet und suchen wieder eine neue interessante Stelle.', null::jsonb, 2.5, null::jsonb, 1),
    ('lv3', '13', 'Sie interessieren sich für Umweltschutz und suchen eine passende Sendung.', null::jsonb, 2.5, null::jsonb, 2),
    ('lv3', '14', 'Ihr Freund, der am Institut für Film und Bild studiert, sucht einen geeigneten Praktikumsplatz.', null::jsonb, 2.5, null::jsonb, 3),
    ('lv3', '15', 'In einer Sendereihe wird im Fernsehen über die neue politische Entwicklung in Deutschland berichtet. Sie wollen sich informieren.', null::jsonb, 2.5, null::jsonb, 4),
    ('lv3', '16', 'Sie interessieren sich für moderne Stadtentwicklung und suchen dazu eine Sendung im Rundfunk.', null::jsonb, 2.5, null::jsonb, 5),
    ('lv3', '17', 'Sie wollen bei der Deutschen Bahn eine Ausbildung machen.', null::jsonb, 2.5, null::jsonb, 6),
    ('lv3', '18', 'Sie interessieren sich für politisches Theater und möchten am Wochenende dazu etwas hören oder sehen.', null::jsonb, 2.5, null::jsonb, 7),
    ('lv3', '19', 'Sie arbeiten gern mit anderen zusammen und suchen eine Tätigkeit bei einer Werbefirma.', null::jsonb, 2.5, null::jsonb, 8),
    ('lv3', '20', 'Sie studieren Fremdsprachen und suchen einen Job, bei dem Sie mit Kindern arbeiten können.', null::jsonb, 2.5, null::jsonb, 9),
    ('sb1', '21', '… ja weißt, sind meine Eltern seit Anfang Mai in einem Haus (21)Mittelnehmer in Spanien. Zuerst wollen meine Eltern …', '[{"key": "A", "text": "am"}, {"key": "B", "text": "in"}, {"key": "C", "text": "zum"}]'::jsonb, 1.5, null::jsonb, 0),
    ('sb1', '22', '… ich mit dem Gymnasium fertig bin. Aber dann sind sie doch (22) früher gefahren. Als ich im Sommer 18 wurde, wollte ich …', '[{"key": "A", "text": "bloß"}, {"key": "B", "text": "erst"}, {"key": "C", "text": "schon"}]'::jsonb, 1.5, null::jsonb, 1),
    ('sb1', '23', '… gefahren. Als ich im Sommer 18 wurde, wollte ich mit (23) älteren Bruder zusammen eine kleine Wohnung mieten. Das …', '[{"key": "A", "text": "mein"}, {"key": "B", "text": "meinem"}]'::jsonb, 1.5, null::jsonb, 2),
    ('sb1', '24', '… mieten. Das hat aber nicht geklappt. Eine Freundin hat (24) dann ein Zimmer inihrer Wohngemeinschaft angeboten. Ich …', '[{"key": "A", "text": "ihr"}, {"key": "B", "text": "mich"}, {"key": "C", "text": "mir"}]'::jsonb, 1.5, null::jsonb, 3),
    ('sb1', '25', '… Wohngemeinschaft angeboten. Ich wohne jetzt mit drei (25) zusammen in der Innenstadt. Ich bin sehr zufrieden, (26) …', '[{"key": "A", "text": "Freund"}, {"key": "B", "text": "Freundin"}, {"key": "C", "text": "Freundinnen"}]'::jsonb, 1.5, null::jsonb, 4),
    ('sb1', '26', '… (25) zusammen in der Innenstadt. Ich bin sehr zufrieden, (26) mein Zimmer recht klein ist. In der Schule habe ich keine …', '[{"key": "A", "text": "aber"}, {"key": "B", "text": "obwohl"}]'::jsonb, 1.5, null::jsonb, 5),
    ('sb1', '27', '… Probleme. Ich staune selbst über meine Noten, wenn ich (27) denke, wie (28) Zeit ich mir für Hausaufgaben nehme. …', '[{"key": "A", "text": "daran"}, {"key": "B", "text": "darauf"}, {"key": "C", "text": "darüber"}]'::jsonb, 1.5, null::jsonb, 6),
    ('sb1', '28', '… staune selbst über meine Noten, wenn ich (27) denke, wie (28) Zeit ich mir für Hausaufgaben nehme. Manchmal schicken …', '[{"key": "A", "text": "wenig"}, {"key": "B", "text": "wenigen"}, {"key": "C", "text": "weniger"}]'::jsonb, 1.5, null::jsonb, 7),
    ('sb1', '29', '… nehme. Manchmal schicken mir meine Eltern eine E-Mail. (29) sie rufen an. (30) jetzt habe ich jede Woche von ihnen …', '[{"key": "A", "text": "Damit"}, {"key": "B", "text": "Oder"}, {"key": "C", "text": "S d"}]'::jsonb, 1.5, null::jsonb, 8),
    ('sb1', '30', '… schicken mir meine Eltern eine E-Mail. (29) sie rufen an. (30) jetzt habe ich jede Woche von ihnen gehört. Das war’s für …', '[{"key": "A", "text": "Ab"}, {"key": "B", "text": "Bis"}, {"key": "C", "text": "Seit"}]'::jsonb, 1.5, null::jsonb, 9),
    ('sb2', '31', '… Anzeige in den Mitteilungen des Deutschen. Alpenvereins (31). Wir wohnen etwa 40 km außerhalb von Nürnberg und …', null::jsonb, 1.5, null::jsonb, 0),
    ('sb2', '32', '… etwa 40 km außerhalb von Nürnberg und schreiben Ihnen, (32) wir Lust hätten, etwas in einer Gruppe zu machen. Unseren …', null::jsonb, 1.5, null::jsonb, 1),
    ('sb2', '33', '… verbringen wir eigentlich regelmäßig in den Bergen. Und (33) es unser Terminkalender erlaubt, gehen wir auch noch am …', null::jsonb, 1.5, null::jsonb, 2),
    ('sb2', '34', '… erlaubt, gehen wir auch noch am Wochenende wandern, (34) fahren wir in die Gegend vom Wilden Kaiser, wo wir …', null::jsonb, 1.5, null::jsonb, 3),
    ('sb2', '35', '… vom Wilden Kaiser, wo wir inzwischen alle Wanderwege (35). Wir fahren zwar beide auch Ski, (36) der Winter den …', null::jsonb, 1.5, null::jsonb, 4),
    ('sb2', '36', '… alle Wanderwege (35). Wir fahren zwar beide auch Ski, (36) der Winter den Bergen ist nicht so unbedingt unsere …', null::jsonb, 1.5, null::jsonb, 5),
    ('sb2', '37', '… ist nicht so unbedingt unsere Sache. Dagegen macht es (37) viel Spaß. Fahrrad zu fahren,; hier in Leupoldstein haben …', null::jsonb, 1.5, null::jsonb, 6),
    ('sb2', '38', '… wir tolle Radwege, die durch die Felder führen. Daher (38) wir uns auch auf gemeinsame Radtouren hier bei uns …', null::jsonb, 1.5, null::jsonb, 7),
    ('sb2', '39', '… Radtouren hier bei uns freuen. Zum Schluss noch ein (39) Worte zu uns selbst. Wir sind 64 und 62. Jahre alt, …', null::jsonb, 1.5, null::jsonb, 8),
    ('sb2', '40', '… ab und zu gern ins Theater. Rufen Sie uns doch einfach (40) an: Tel.: 09243/7448. Viele Grüße Ilka und Heiner Grossmann', null::jsonb, 1.5, null::jsonb, 9),
    ('hv1', '41', 'Die Sprecherin könnte sich vorstellen, mit dem Bus zur Arbeit zu fahren.', null::jsonb, 5.0, null::jsonb, 0),
    ('hv1', '42', 'Die Sprecherin geht den ganzen Weg zur Arbeit zu Fuß.', null::jsonb, 5.0, null::jsonb, 1),
    ('hv1', '43', 'Der Sprecher fährt nie mit dem Auto zur Arbeit.', null::jsonb, 5.0, null::jsonb, 2),
    ('hv1', '44', 'Der Sprecher benutzt für den Weg zur Arbeit zurzeit verschiedene Verkehrsmittel.', null::jsonb, 5.0, null::jsonb, 3),
    ('hv1', '45', 'Für die Sprecherin ist der Firmenbus die einzige Möglichkeit zur Arbeit zu kommen.', null::jsonb, 5.0, null::jsonb, 4),
    ('hv2', '46', 'Viele Touristen besuchen Torgau wegen seiner historischen Sehenswürdigkeiten.', null::jsonb, 2.5, null::jsonb, 0),
    ('hv2', '47', 'Den Spielpark Hartenfels gibt es schon seit vielen Jahren.', null::jsonb, 2.5, null::jsonb, 1),
    ('hv2', '48', 'Außer dem Spielpark gibt es in der Umgebung viele andere Freizeitmöglichkeiten für die Kinder.', null::jsonb, 2.5, null::jsonb, 2),
    ('hv2', '49', 'Der Spielpark bietet den Kindern Spielmöglichkeiten, die sie zu Hause nicht haben.', null::jsonb, 2.5, null::jsonb, 3),
    ('hv2', '50', 'Die Kinder können im Spielpark auch selbst etwas bauen.', null::jsonb, 2.5, null::jsonb, 4),
    ('hv2', '51', 'Das Spielen am Back kann für die Kinder gefährlich werden.', null::jsonb, 2.5, null::jsonb, 5),
    ('hv2', '52', 'Beide Elternteile müssen auf die Kinder aufpassen.', null::jsonb, 2.5, null::jsonb, 6),
    ('hv2', '53', 'Im Spielpark können Kinder bis zum Alter von sieben von Aufsichtspersonen betreut werden.', null::jsonb, 2.5, null::jsonb, 7),
    ('hv2', '54', 'Der Eintritt in den Spielpark ist zurzeit frei.', null::jsonb, 2.5, null::jsonb, 8),
    ('hv2', '55', 'Die Schlossführung bereitet Kindern und Erwachsenen viel Spaß.', null::jsonb, 2.5, null::jsonb, 9),
    ('hv3', '56', 'Sie können zwei Flüge nach Griechenland gewinnen.', null::jsonb, 5.0, null::jsonb, 0),
    ('hv3', '57', 'Für Ihre Gruppe ist ein Wagen im Zug nach Aschaffenburg reserviert.', null::jsonb, 5.0, null::jsonb, 1),
    ('hv3', '58', 'Auf der Internetseite kann man auch günstige Angebote für Haushaltsgerät.', null::jsonb, 5.0, null::jsonb, 2),
    ('hv3', '59', 'Erst morgen Abend bildet sich Nebel..', null::jsonb, 5.0, null::jsonb, 3),
    ('hv3', '60', 'Am besten fahren Sie ab Northeim mit dem Bus.', null::jsonb, 5.0, null::jsonb, 4),
    ('sa', 'A', 'Antworten Sie Vera. Schreiben Sie etwas zu allen vier Punkte:', null::jsonb, 0, '{"minWords": 100, "points": ["Was es bei Ihnen Neues gibt", "Was Sie zur Arbeit kommen", "Was Sie über Veras neue Stelle wissen wollen", "Vorschlag für gemeinsame Unternehmung?"]}'::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'b1' and t.slug = 'modell-10'
join sections s on s.test_id = t.id and s.section_id = v.section_id
on conflict (section_id, item_id) do update set text = excluded.text, options = excluded.options, points = excluded.points, meta = excluded.meta, sort = excluded.sort;

insert into item_answers (item_id, answer, explanation)
select i.id, v.answer, v.explanation
from (values
    ('lv1', '1', 'D', null),
    ('lv1', '2', 'J', null),
    ('lv1', '3', 'E', null),
    ('lv1', '4', 'B', null),
    ('lv1', '5', 'C', null),
    ('lv2', '6', 'A', null),
    ('lv2', '7', 'A', null),
    ('lv2', '8', 'A', null),
    ('lv2', '9', 'C', null),
    ('lv2', '10', 'B', null),
    ('lv3', '11', 'D', null),
    ('lv3', '12', 'G', null),
    ('lv3', '13', 'F', null),
    ('lv3', '14', 'A', null),
    ('lv3', '15', 'I', null),
    ('lv3', '16', 'K', null),
    ('lv3', '17', 'X', null),
    ('lv3', '18', 'J', null),
    ('lv3', '19', 'L', null),
    ('lv3', '20', 'H', null),
    ('sb1', '21', 'A', null),
    ('sb1', '22', 'C', null),
    ('sb1', '23', 'B', null),
    ('sb1', '24', 'C', null),
    ('sb1', '25', 'C', null),
    ('sb1', '26', 'B', null),
    ('sb1', '27', 'A', null),
    ('sb1', '28', 'A', null),
    ('sb1', '29', 'B', null),
    ('sb1', '30', 'B', null),
    ('sb2', '31', 'D', 'Das Wort lautet: ENTDECKT'),
    ('sb2', '32', 'M', 'Das Wort lautet: WEIL'),
    ('sb2', '33', 'N', 'Das Wort lautet: WENN'),
    ('sb2', '34', 'I', 'Das Wort lautet: OFT'),
    ('sb2', '35', 'G', 'Das Wort lautet: KENNEN'),
    ('sb2', '36', 'A', 'Das Wort lautet: ABER'),
    ('sb2', '37', 'K', 'Das Wort lautet: UNS'),
    ('sb2', '38', 'O', 'Das Wort lautet: WÜRDEN'),
    ('sb2', '39', 'J', 'Das Wort lautet: PAAR'),
    ('sb2', '40', 'C', 'Das Wort lautet: EINMAL'),
    ('hv1', '41', 'f', null),
    ('hv1', '42', 'f', null),
    ('hv1', '43', 'r', null),
    ('hv1', '44', 'f', null),
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
    ('hv3', '56', 'f', null),
    ('hv3', '57', 'r', null),
    ('hv3', '58', 'r', null),
    ('hv3', '59', 'f', null),
    ('hv3', '60', 'r', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'b1' and t.slug = 'modell-10'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;

-- ================= modell-11 · JENNIFER =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('b1', 'modell-11', 'JENNIFER', '61 Aufgaben · 150 Minuten',
        '[{"id": "block-lv-sb", "title": "Leseverstehen und Sprachbausteine", "minutes": 90, "hint": "Aufgaben 1–40", "parts": ["lv1", "lv2", "lv3", "sb1", "sb2"], "maxPoints": 105.0, "availablePoints": 105.0, "missing": 0}, {"id": "block-hv", "title": "Hörverstehen", "minutes": 30, "hint": "Aufgaben 41–60", "parts": ["hv1", "hv2", "hv3"], "maxPoints": 75.0, "availablePoints": 75.0, "missing": 0}, {"id": "block-sa", "title": "Schriftlicher Ausdruck", "minutes": 30, "hint": "", "parts": ["sa"], "maxPoints": 45.0, "availablePoints": 45, "missing": 0}]'::jsonb, 61, true, 11)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('lv1', 'Leseverstehen', 'Leseverstehen, Teil 1', 15, 'Lesen Sie die Überschriften a–j und die Texte 1–5. Finden Sie für jeden Text die passende Überschrift. Jede Überschrift passt nur einmal.', 'matching', '{"bank": [{"key": "A", "text": "Früh übt sich: Hotels bieten Skikurse für Zweijährige an"}, {"key": "B", "text": "Neu: Mit dem Taxi gratis zur Disco"}, {"key": "C", "text": "Straßenbahn und Bus im Flugticket enthalten"}, {"key": "D", "text": "Neu: Taxi Tickest für Discobesucher"}, {"key": "E", "text": "Skikurs für Eltern und Kinder"}, {"key": "F", "text": "Angebot für Reisende: Für wenig Geld öffentliche Verkehrsmittel benutzen"}, {"key": "G", "text": "Buchtipp: Babys im Garten"}, {"key": "H", "text": "Schulkinder schreiben spannende Geschichten"}, {"key": "I", "text": "Ratschläge für Hobby-Fotografen"}, {"key": "J", "text": "Ein Schüler mit vielen Ideen"}], "bankTitle": "Überschriften", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 0),
    ('lv2', 'Leseverstehen', 'Leseverstehen, Teil 2', 20, 'Lesen Sie den Text und die Aufgaben 6–10. Welche Lösung (A, B oder C) ist jeweils richtig?', 'mc', '{"passages": [{"paragraphs": [{"t": "bis morgens 6 Uhr benutzen. Die Taxifahrer erhalten bei ihrer Zentrale dann den vollen", "b": false}, {"t": "Fahrpreis erstattet.", "b": false}, {"t": "Die neue Sir-Karl-Popper-Schule", "b": true}, {"t": "Ein Schulversuch für besonders Klage Schüler", "b": true}, {"t": "WIEN. Es ist eine ganz normale Schulstunde Geschichte in einer ganz normale Klasse. Während der Lehrer", "b": false}, {"t": "– – einen Vortrag über das alle Rom hält, unterhalten sich die Schüler über den Schulball, kreieren die Kleidung des Lehrers, reichen Zettel unter der Schulbank weiter. Ganz normale Kinder Auch überdurchschnittlich intelligente Kinder sind ganz normale Kinder, betont Elfriede Wegricht, Psychologin in der Sir Karl Popper Schule, die im vergangen September Ihren Betrieb aufgenommen hat nur weil sie in der Schule gut sind, heißt das nicht, dass sie nicht genauso wie alle anderen Schüler Liebeskummer, Ärger mit den Eltern und andere Pubertätsporobleme haben Der Unterschied zwischen normalen und hochbegabten in ihrer bisherigen Schulkarriere nicht besonders anstrengen mussten und es nicht gewohnt sind, mit ihrer Zeit gut hauszuhalten Federung durch Forderung Um überdurchschnittlich intelligente Kinder nun entsprechend zu fördern, sieht das Konzept der Sir Karl Popper- Schule mehr Fremdsprachen projektorientiertes Arbeiten in kleinen Klassen und vor allem mehr Eigenverantwortung für den Lernenden vor. Dazu kommt die Förderung der individuellen Fähigkeiten: Wer in einem Fach gut ist und sich besonders für ein Thema interessiert bekommt Sonderaufgaben und tiefer gehen Ende Unterlagen. Anfangs war der plötzlich Mehr aufwand ein Schock für die Schüler, die eine 40 Stunden Woche zu bewältigen haben Aber es ist besser, sie erleben den Schock jetzt als zu Beginn des Studiums meint Herr Peters Lehrer und Schülerbetreuer an der Popper Schule denn oft scheitern besonders kluge Menschen Später weil sie mit ihrer Intelligenz nichts anzufangen wissen Denn zumeist erreichten sie mit wenig Aufwand und Mitarbeit relativ gute Ergebnisse Wer ist hochbegabt Zielgruppe der Sir Karl Popper Schule sind Kinder, die in mindestens einem Fach hochbegabt sind und überdurchschnittlich gute Ergebnisse haben, das sind 20 30 der Schüler. Nach einer Aufnahmeprüfung wurden von 64 Bewerben 28 geteilt sind und von insgesamt 28 Lehren betreut werden In diesen Klassen können die über durchschnittliche intelligenten Schüler dann endlich so sein, wie sie sind, ohne bei jeder Wortmeldung von ihren Klassenkameraden beschimpft zu werden meint die Schulpsychologien Ziel des Schulversuchs sei es jedoch laut Peters nicht, besonders kluge Schüler von normalen Kindern zu trennen, sondern Erfahrung im Umgang mit überdurchschnittlich die Begabtenförderung in die Normalschule zu üb h", "b": false}, {"t": "übernehmen.", "b": false}]}], "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 1),
    ('lv3', 'Leseverstehen', 'Leseverstehen, Teil 3', 20, 'Lesen Sie die Situationen 11–20 und die Anzeigen im Bild. Finden Sie für jede Situation die passende Anzeige. Wenn Sie keine passende Anzeige finden, wählen Sie X.', 'matching', '{"bank": [{"key": "A", "text": ""}, {"key": "B", "text": ""}, {"key": "C", "text": ""}, {"key": "D", "text": ""}, {"key": "E", "text": ""}, {"key": "F", "text": ""}, {"key": "G", "text": ""}, {"key": "H", "text": ""}, {"key": "I", "text": ""}, {"key": "J", "text": ""}, {"key": "K", "text": ""}, {"key": "L", "text": ""}, {"key": "X", "text": ""}], "bankTitle": "Anzeigen", "bankImage": "img/m11-lv3.jpg", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 2.5}'::jsonb, 2),
    ('sb1', 'Sprachbausteine', 'Sprachbausteine, Teil 1', 20, 'Lesen Sie den Text und schließen Sie die Lücken 21–30. Welche Lösung (A, B oder C) ist jeweils richtig?', 'mc', '{"passages": [{"paragraphs": [{"t": "Liebe Olivia,", "b": false}, {"t": "wie du ja weißt, mache ich gerade Urlaub auf Fehmarn. Und dass ich mein Fahrrad mitgenommen habe, war wirklich eine gute Idee. Radfahren macht hier nämlich viel Spaß trotz (21) Windes. Und es gibt auch Angebote für Radfahrer wie (22) , die sich vor allem erholen und nicht besonders anstrengen wollen.", "b": false}, {"t": "So kann man hier zum Beispiel (23) Fahrkarten kaufen, um mit dem Bus in einen anderen Ort zu fahren und mit dem Rad zurück. Oder es gibt Angebote mit Schiffen, die das Rad (24) wenig Geld transportieren.", "b": false}, {"t": "Besonders (25) hat mich aber die Stadt Burg auf Fehmarn. Schon (26) Hafen sind mir die vielen Fahrräder aufgefallen. (27) gibt es Markierungen auf den Straßen, die den Radfahrern(28), sich bei roten Ampeln vor die Autos zu stellen. (29) Ampeln schalten für Radfahrer sogar früher auf Grün als für Autos.", "b": false}, {"t": "Du siehst also: Es hat sich gelohnt, das Fahrrad (30). Liebe Grüße", "b": false}, {"t": "Lutz", "b": false}]}], "maxPoints": 15.0, "availablePoints": 15.0, "missing": 0, "pointsPerItem": 1.5}'::jsonb, 3),
    ('sb2', 'Sprachbausteine', 'Sprachbausteine, Teil 2', 15, 'Lesen Sie den Text und schließen Sie die Lücken 31–40. Benutzen Sie die Wörter aus der Liste. Jedes Wort passt nur einmal.', 'wordbank', '{"bank": [{"key": "A", "text": "AM"}, {"key": "B", "text": "AUFTRAG"}, {"key": "C", "text": "FRAGEN"}, {"key": "D", "text": "GEEIGENET"}, {"key": "E", "text": "GEGEÜBER"}, {"key": "F", "text": "INFORMATIONEN"}, {"key": "G", "text": "KÖNNTEN"}, {"key": "H", "text": "NENNEN"}, {"key": "I", "text": "NUN"}, {"key": "J", "text": "STATTFINDEN"}, {"key": "K", "text": "TERMIN"}, {"key": "L", "text": "TROTZDEM"}, {"key": "M", "text": "VOR"}, {"key": "N", "text": "WÄREN"}, {"key": "O", "text": "WEGEN"}], "bankTitle": "Wörterliste", "passages": [{"paragraphs": [{"t": "besonderen zum Einiges", "b": false}, {"t": "C C", "b": false}, {"t": ") (  ", "b": false}, {"t": "Sehr geehrte Damen und Herren,", "b": false}, {"t": "unsere Organisation hat den (31) , eine deutsch-französische Konferenz zu europäischen Entwicklungsprogrammen vorzubereiten.", "b": false}, {"t": "Diese Veranstaltung könnte in Breisach (32) , und daher brauchen wir von Ihnen nähere(33). In Ihrer Anzeige (34) Sie die Sehenswürdigkeiten von Breisach und die verschiedenen touristischen Möglichkeiten. Deshalb erscheint uns Ihre Stadt als sehr (35) , auch (36) sie als Brücke zu Europa gilt.", "b": false}, {"t": "Nun haben wir folgende Bitte: Für diese Veranstaltung (37) wir ein gutes Hotel, möglichst am Ufer des Rheins, mit Konferenz- und Arbeitsräumen, ausgestattet mit den notwendigen technischen Anlagen, Internetanschluss usw. Es sollte (38) ruhig gelegen sein. Können Sie uns dazu Vorschläge schicken? Der (39) wäre 15.-21. November.", "b": false}, {"t": "Bitte geben Sie uns möglichst bald Bescheid. Für Prospekte und Informationen zu Preisen und Buchungsbedingungen(40) wir Ihnen dankbar. Mit freundlichen Grüßen", "b": false}, {"t": "ADRIAN SCHÖLLER EVD Trans GmbH", "b": false}]}], "maxPoints": 15.0, "availablePoints": 15.0, "missing": 0, "pointsPerItem": 1.5}'::jsonb, 4),
    ('hv1', 'Hörverstehen', 'Hörverstehen, Teil 1', 8, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 5),
    ('hv2', 'Hörverstehen', 'Hörverstehen, Teil 2', 14, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 2.5}'::jsonb, 6),
    ('hv3', 'Hörverstehen', 'Hörverstehen, Teil 3', 8, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 7),
    ('sa', 'Schriftlicher Ausdruck', 'Schriftlicher Ausdruck', 30, 'Antworten Sie auf den Brief. Schreiben Sie etwas zu den folgenden vier Punkten:', 'writing', '{"brief": {"intro": "Sie haben folgenden Brief von einer Freundin erhalten:", "greeting": "Liebe(r)........", "paragraphs": ["Entschuldige, dass ich mich erst jetzt wieder melde. Ich weiß, wir hatten ausgemacht, uns öfter mal zu schreiben. Aber es war so viel los in letzter Zeit. Ich habe eine Neuigkeit für dich: Meine kleine Schwester Janine heiratet im Oktober, und ich habe ihr versprochen, schon mal allen Freunden zu schreiben und Bescheid zu sagen. Die offizielle Einladung bekommst du natürlich noch von ihr direkt. Eddi, ihr zukünftiger Mann, ist echt nett, und wir mögen ihn alle sehr. Er ist koch und arbeitet hier in einem Hotel.", "Wir planen jetzt alles. Gib mir deshalb möglichst bald Bescheid, ob du kommst und mit wem.", "Herzliche Grüße"], "signature": "Jennifer"}, "hints": ["Bevor Sie den Brief schreiben, überlegen Sie sich eine passende Reihenfolge der punkte, eine passende"], "criteria": [{"title": "Aufgabenbewältigung", "hint": "Sind alle vier Leitpunkte inhaltlich angemessen bearbeitet?"}, {"title": "Kommunikative Gestaltung", "hint": "Anrede, Gruß, passendes Register und verbundene Sätze statt aneinandergereihter Punkte?"}, {"title": "Formale Richtigkeit", "hint": "Stören Fehler in Grammatik, Wortschatz und Rechtschreibung das Verstehen?"}], "grades": [{"key": "A", "points": 5}, {"key": "B", "points": 3}, {"key": "C", "points": 1}, {"key": "D", "points": 0}], "factor": 3, "maxPoints": 45, "availablePoints": 45, "missing": 0}'::jsonb, 8)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'b1' and t.slug = 'modell-11'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('lv1', '1', 'Ich möchte, dass Menschen, die meine Fotos gesehen haben, von nun an die Welt mit anderen Augen betrachten. Das könnte der neuseeländischen Fotografin Anne Geddes gelingen. Denn die Bilder, die sie für das Buch. Drunten im Garten von den kleinen Menschenkindern gemacht hat, sind ungewöhnlich und wunderschön: Babys auf Blumen, Blättern, Beeren, verkleidet als Morcheln, Melonen oder Marienkäfer, Babys in Tulpen und als Schmetterlinge. Ein Bildband, angereichert mit poetischen Texten und Ratschlägen.', null::jsonb, 5.0, null::jsonb, 0),
    ('lv1', '2', 'Die meisten Skikurse für Kinder beginnen im Alter von vier Jahren. Im Kärntner Baby Dorf Trebesing ist das anders: Hier werden im Windel Wedel Camp bereits Kleinkinder ab zwei Jahren unterrichtet. Täglich zwei Stunden können die Skihaserin unter fachkundiger Anleitung auf einem flachen Hügel erste Geh- bzw. Fahrversuche auf zwei Brettern machen. Nach einigen Tagen Übung geht es dann mit dem Baby Bus ins Skigebiet Innerkremms. Auch Ginas Baby und Kinderhotel am Fiaker See bietet seinen jüngsten Gästen Skikurse. Fast 1000 Knirpse haben in der Windelschule schon Skifahren gelernt. Auskunft: Tourismusverband Leiser Malta Tal und die Kinderhotels', null::jsonb, 5.0, null::jsonb, 1),
    ('lv1', '3', 'Berlins jüngster Schriftsteller hat deutlich mehr Texte verfasst als er Jahre zählt. Rund 50 Gedichte und Erzählungen tippte Daniel Story. 12, schon in seiner Computer. Ich schreibe fast, seitdem es mich gibt, sagt der Sechstklässler Bereits mit sieben dichtete er die ersten Verse, jetzt mit zwölf ist er stolz auf seine erste Autorenlesung. Wenn Freunde Fußball spielen, tobt Daniels Phantasie im Kinderzimmer. Warum er lieber schreibt? Daniel: Ich schreibe, weil ich nicht alles erleben kann, was ich denke.', null::jsonb, 5.0, null::jsonb, 2),
    ('lv1', '4', 'Ob Sie privat oder geschäftlich unterwegs sind, mit dem Stadt Ticket können Sie billig die öffentlichen Verkehrsmittel nutzen. Voraussetzung: Sie sind mit dem Flugzeug oder der Deutschen Bahn(über 100 km) angereist. Gegen einen Aufpreis von nur Euro 2,50 ermöglicht Ihnen das Stadt Ticket auch nach der Ankunft am Zielort freie Fahrt. Mit U- S- oder Straßenbahnen sowie Bussen. Bis zu 48 Stunden. Übrigens: Ihr Stadt Ticket gilt an zwei aufeinanderfolgenden Tagen, die Sie beim Kauf Ihres Fahrscheines selbst bestimmen.', null::jsonb, 5.0, null::jsonb, 3),
    ('lv1', '5', 'In Mecklenburg-Vorpommern können junge Leute jetzt für den halben Fahrpreis mit dem Taxi auf Discotour gehen. Tickets dafür sind bei allen Geschäftsstellen der Allgemeinen Ortskrankenkasse (AOK) sowie an Esso Tankstellen zum halben Preis erhältlich. Junge Leute zwischen 16 und 25 Jahren können sie an Wochenenden und Feiertagen in der Zeit von 20 Uhr', null::jsonb, 5.0, null::jsonb, 4),
    ('lv2', '6', 'Die Psychologin der Popper-Schule meint, dass', '[{"key": "A", "text": "besonders intelligente Kinder sich stark von anderen Kindern unterscheiden."}, {"key": "B", "text": "besonders intelligente Schüler dieselben Probleme haben wie andere Kinder."}, {"key": "C", "text": "besonders intelligente Schüler weniger Probleme im alltäglichen Leben haben."}]'::jsonb, 5.0, null::jsonb, 0),
    ('lv2', '7', 'Für überdurchschnittlich intelligente Schüler ist typisch, dass Sie', '[{"key": "A", "text": "auch ohne viel Anstrengung gute Noten haben."}, {"key": "B", "text": "nach der Schule immer großen Erfolg im Beruf haben."}, {"key": "C", "text": "sich die Zeit zum Lernen besser als andere einteilen können."}]'::jsonb, 5.0, null::jsonb, 1),
    ('lv2', '8', 'Im Unterricht der Popper-Schule sollen die Schüler', '[{"key": "A", "text": "immer in einer Fremdsprache miteinander sprechen."}, {"key": "B", "text": "in ihren besten Fächern eine spezielle Betreuung bekommen."}, {"key": "C", "text": "in kleinen Gruppen schwächeren Schülern helfen."}]'::jsonb, 5.0, null::jsonb, 2),
    ('lv2', '9', 'Die erste Zeit in der Popper-Schule war für die Schüler schwer, weil', '[{"key": "A", "text": "sich ihre Noten plötzlich verschlechterten."}, {"key": "B", "text": "sie auf einmal viel mehr Zeit mit Lernen verbringen mussten."}, {"key": "C", "text": "sie noch nicht wussten, welche besonderen Talente sie hatten."}]'::jsonb, 5.0, null::jsonb, 3),
    ('lv2', '10', 'In der Popper-Schule werden nur Schüler aufgenommen,', '[{"key": "A", "text": "die in mindestens einem Fach sehr gut sind."}, {"key": "B", "text": "die mindestens 20 bis 30 Prozent der Aufnahmeprüfung erreichen."}, {"key": "C", "text": "dievonden insgesamt 28Lehrernals intelligent bbeschriebenwerden"}]'::jsonb, 5.0, null::jsonb, 4),
    ('lv3', '11', 'Sie haben von einer Schweizer Schauspielerin gehört und möchten gern einen Film sehen.', null::jsonb, 2.5, null::jsonb, 0),
    ('lv3', '12', 'Sie haben gerade Ihre Ausbildung beendet und suchen eine Stelle an der Rezeption.', null::jsonb, 2.5, null::jsonb, 1),
    ('lv3', '13', 'Sie interessieren sich für Umweltschutz und suchen eine passende Sendung.', null::jsonb, 2.5, null::jsonb, 2),
    ('lv3', '14', 'Ihr Freund, der am Institut für Film und Bild studiert, sucht einen geeigneten Praktikumsplatz.', null::jsonb, 2.5, null::jsonb, 3),
    ('lv3', '15', 'In einer Sendereihe wird im Fernsehen über die neue politische Entwicklung in Deutschland berichtet. Sie wollen sich informieren.', null::jsonb, 2.5, null::jsonb, 4),
    ('lv3', '16', 'Sie interessieren sich für Großstädte und ihre Entwicklung und suchen dazu eine Sendung im Rundfunk.', null::jsonb, 2.5, null::jsonb, 5),
    ('lv3', '17', 'Sie sind mit der Schule fertig und wollen bei der Deutschen Bahn eine Ausbildung machen.', null::jsonb, 2.5, null::jsonb, 6),
    ('lv3', '18', 'Sie interessieren sich für politisches Theater und möchten dazu am Wochenende etwas hören oder sehen.', null::jsonb, 2.5, null::jsonb, 7),
    ('lv3', '19', 'Sie arbeiten gern mit anderen zusammen und suchen eine Tätigkeit bei einer Werbefirma.', null::jsonb, 2.5, null::jsonb, 8),
    ('lv3', '20', 'Sie wollen mehr über das Thema Arbeiten in Europa erfahren. ) ( DB', null::jsonb, 2.5, null::jsonb, 9),
    ('sb1', '21', '… gute Idee. Radfahren macht hier nämlich viel Spaß trotz (21) Windes. Und es gibt auch Angebote für Radfahrer wie (22) …', '[{"key": "A", "text": "den"}, {"key": "B", "text": "der"}, {"key": "C", "text": "des"}]'::jsonb, 1.5, null::jsonb, 0),
    ('sb1', '22', '… (21) Windes. Und es gibt auch Angebote für Radfahrer wie (22) , die sich vor allem erholen und nicht besonders …', '[{"key": "A", "text": "mein"}, {"key": "B", "text": "mich"}, {"key": "C", "text": "mir"}]'::jsonb, 1.5, null::jsonb, 1),
    ('sb1', '23', '… anstrengen wollen. So kann man hier zum Beispiel (23) Fahrkarten kaufen, um mit dem Bus in einen anderen Ort zu …', '[{"key": "A", "text": "besondere"}, {"key": "B", "text": "besonderem"}]'::jsonb, 1.5, null::jsonb, 2),
    ('sb1', '24', '… zurück. Oder es gibt Angebote mit Schiffen, die das Rad (24) wenig Geld transportieren. Besonders (25) hat mich aber …', '[{"key": "A", "text": "durch"}, {"key": "B", "text": "für"}, {"key": "C", "text": "mit"}]'::jsonb, 1.5, null::jsonb, 3),
    ('sb1', '25', '… die das Rad (24) wenig Geld transportieren. Besonders (25) hat mich aber die Stadt Burg auf Fehmarn. Schon (26) …', '[{"key": "A", "text": "beeindrucken"}, {"key": "B", "text": "beeindruckend"}, {"key": "C", "text": "beeindruckt"}]'::jsonb, 1.5, null::jsonb, 4),
    ('sb1', '26', '… (25) hat mich aber die Stadt Burg auf Fehmarn. Schon (26) Hafen sind mir die vielen Fahrräder aufgefallen. (27) …', '[{"key": "A", "text": "am"}, {"key": "B", "text": "im"}]'::jsonb, 1.5, null::jsonb, 5),
    ('sb1', '27', '… (26) Hafen sind mir die vielen Fahrräder aufgefallen. (27) gibt es Markierungen auf den Straßen, die den …', '[{"key": "A", "text": "Aber"}, {"key": "B", "text": "Außer"}, {"key": "C", "text": "Außerdem"}]'::jsonb, 1.5, null::jsonb, 6),
    ('sb1', '28', '… gibt es Markierungen auf den Straßen, die den Radfahrern(28), sich bei roten Ampeln vor die Autos zu stellen. (29) …', '[{"key": "A", "text": "erlauben"}, {"key": "B", "text": "erlaubt"}, {"key": "C", "text": "erlaubte"}]'::jsonb, 1.5, null::jsonb, 7),
    ('sb1', '29', '… sich bei roten Ampeln vor die Autos zu stellen. (29) Ampeln schalten für Radfahrer sogar früher auf Grün als …', '[{"key": "A", "text": "Einige"}, {"key": "B", "text": "Einigen"}]'::jsonb, 1.5, null::jsonb, 8),
    ('sb1', '30', '… Autos. Du siehst also: Es hat sich gelohnt, das Fahrrad (30). Liebe Grüße Lutz', '[{"key": "A", "text": "mitgenommen"}, {"key": "B", "text": "mitnehmen"}, {"key": "C", "text": "mitzunehmen"}]'::jsonb, 1.5, null::jsonb, 9),
    ('sb2', '31', '… geehrte Damen und Herren, unsere Organisation hat den (31) , eine deutsch-französische Konferenz zu europäischen …', null::jsonb, 1.5, null::jsonb, 0),
    ('sb2', '32', '… vorzubereiten. Diese Veranstaltung könnte in Breisach (32) , und daher brauchen wir von Ihnen nähere(33). In Ihrer …', null::jsonb, 1.5, null::jsonb, 1),
    ('sb2', '33', '… in Breisach (32) , und daher brauchen wir von Ihnen nähere(33). In Ihrer Anzeige (34) Sie die Sehenswürdigkeiten von …', null::jsonb, 1.5, null::jsonb, 2),
    ('sb2', '34', '… daher brauchen wir von Ihnen nähere(33). In Ihrer Anzeige (34) Sie die Sehenswürdigkeiten von Breisach und die …', null::jsonb, 1.5, null::jsonb, 3),
    ('sb2', '35', '… Möglichkeiten. Deshalb erscheint uns Ihre Stadt als sehr (35) , auch (36) sie als Brücke zu Europa gilt. Nun haben wir …', null::jsonb, 1.5, null::jsonb, 4),
    ('sb2', '36', '… Deshalb erscheint uns Ihre Stadt als sehr (35) , auch (36) sie als Brücke zu Europa gilt. Nun haben wir folgende …', null::jsonb, 1.5, null::jsonb, 5),
    ('sb2', '37', '… Nun haben wir folgende Bitte: Für diese Veranstaltung (37) wir ein gutes Hotel, möglichst am Ufer des Rheins, mit …', null::jsonb, 1.5, null::jsonb, 6),
    ('sb2', '38', '… technischen Anlagen, Internetanschluss usw. Es sollte (38) ruhig gelegen sein. Können Sie uns dazu Vorschläge …', null::jsonb, 1.5, null::jsonb, 7),
    ('sb2', '39', '… sein. Können Sie uns dazu Vorschläge schicken? Der (39) wäre 15.-21. November. Bitte geben Sie uns möglichst bald …', null::jsonb, 1.5, null::jsonb, 8),
    ('sb2', '40', '… und Informationen zu Preisen und Buchungsbedingungen(40) wir Ihnen dankbar. Mit freundlichen Grüßen ADRIAN …', null::jsonb, 1.5, null::jsonb, 9),
    ('hv1', '41', 'Herr Pawliczek erledigt alle seine Einkäufe im Internet.', null::jsonb, 5.0, null::jsonb, 0),
    ('hv1', '42', 'Frau Zimmermann legt beim Einkaufen großen Wert auf persönlichen Kontakt.', null::jsonb, 5.0, null::jsonb, 1),
    ('hv1', '43', 'Frau Schmidt findet zu Hause nicht genug Ruhe, um im Internet einzukaufen.', null::jsonb, 5.0, null::jsonb, 2),
    ('hv1', '44', 'Frau Ruttnigg ist vom Einkaufen im Internet nicht überzeugt.', null::jsonb, 5.0, null::jsonb, 3),
    ('hv1', '45', 'Herr Krause kauft seine Medikamente am liebsten in der nächsten Stadt.', null::jsonb, 5.0, null::jsonb, 4),
    ('hv2', '46', 'Mit einem Praktikum können sich Jugendliche auf das Studium vorbereiten.', null::jsonb, 2.5, null::jsonb, 0),
    ('hv2', '47', 'Herrn Mahlers Firma bietet jungen Leuten in verschiedenen Abteilungen ein Praktikum an.', null::jsonb, 2.5, null::jsonb, 1),
    ('hv2', '48', 'Herrn Mahlers Firma stellt alle Praktikanten nach der Ausbildung ein.', null::jsonb, 2.5, null::jsonb, 2),
    ('hv2', '49', 'Bei einer Bewerbung ist das Schulzeugnis für Herrn Mahler das Wichtigste.', null::jsonb, 2.5, null::jsonb, 3),
    ('hv2', '50', 'Praktikanten sollten selbst erkennen, wo man sie brauchen könnte.', null::jsonb, 2.5, null::jsonb, 4),
    ('hv2', '51', 'Herr Mahler meint, dass die Ideen der Praktikanten bei der Arbeit stören.', null::jsonb, 2.5, null::jsonb, 5),
    ('hv2', '52', 'Herr Mahler legt großen Wert auf Teamarbeit.', null::jsonb, 2.5, null::jsonb, 6),
    ('hv2', '53', 'Nach Frau Bachs Meinung verhalten sich Praktikanten im Betrieb oft wie in der Schule oder an der Universität.', null::jsonb, 2.5, null::jsonb, 7),
    ('hv2', '54', 'Für den Praktikanten ist es gut, wenn er Interesse an der Arbeit zeigt.', null::jsonb, 2.5, null::jsonb, 8),
    ('hv2', '55', 'Herr Mahler empfiehlt den Praktikanten, das Team mit Fleiß und guter Laune zu unterstützen.', null::jsonb, 2.5, null::jsonb, 9),
    ('hv3', '56', 'In Norddeutschland steigen die Temperaturen morgen auf 5 bis 7 Grad.', null::jsonb, 5.0, null::jsonb, 0),
    ('hv3', '57', 'Hamburg hat öfter gewonnen als Stuttgart.', null::jsonb, 5.0, null::jsonb, 1),
    ('hv3', '58', 'Nach zwei Monaten müssen Sie für die Zeitschrift bezahlen.', null::jsonb, 5.0, null::jsonb, 2),
    ('hv3', '59', 'Auf dem Mittleren Ring in München wird die Geschwindigkeit kontrolliert.', null::jsonb, 5.0, null::jsonb, 3),
    ('hv3', '60', 'Janas Geburtstagsfest findet nicht im LEO statt.', null::jsonb, 5.0, null::jsonb, 4),
    ('sa', 'A', 'Antworten Sie auf den Brief. Schreiben Sie etwas zu den folgenden vier Punkten:', null::jsonb, 0, '{"minWords": 100, "points": ["Reaktion auf Neuigkeit", "Übernachtungsmöglichkeit", "Sie möchten zur Hochzeit kommen", "Hochzeitsgeschenk"]}'::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'b1' and t.slug = 'modell-11'
join sections s on s.test_id = t.id and s.section_id = v.section_id
on conflict (section_id, item_id) do update set text = excluded.text, options = excluded.options, points = excluded.points, meta = excluded.meta, sort = excluded.sort;

insert into item_answers (item_id, answer, explanation)
select i.id, v.answer, v.explanation
from (values
    ('lv1', '1', 'G', null),
    ('lv1', '2', 'A', null),
    ('lv1', '3', 'J', null),
    ('lv1', '4', 'F', null),
    ('lv1', '5', 'D', null),
    ('lv2', '6', 'B', null),
    ('lv2', '7', 'A', null),
    ('lv2', '8', 'B', null),
    ('lv2', '9', 'B', null),
    ('lv2', '10', 'A', null),
    ('lv3', '11', 'D', null),
    ('lv3', '12', 'G', null),
    ('lv3', '13', 'F', null),
    ('lv3', '14', 'A', null),
    ('lv3', '15', 'I', null),
    ('lv3', '16', 'K', null),
    ('lv3', '17', 'X', null),
    ('lv3', '18', 'J', null),
    ('lv3', '19', 'L', null),
    ('lv3', '20', 'B', null),
    ('sb1', '21', 'C', null),
    ('sb1', '22', 'B', null),
    ('sb1', '23', 'A', null),
    ('sb1', '24', 'B', null),
    ('sb1', '25', 'C', null),
    ('sb1', '26', 'A', null),
    ('sb1', '27', 'C', null),
    ('sb1', '28', 'A', null),
    ('sb1', '29', 'A', null),
    ('sb1', '30', 'C', null),
    ('sb2', '31', 'B', 'Das Wort lautet: AUFTRAG'),
    ('sb2', '32', 'J', 'Das Wort lautet: STATTFINDEN'),
    ('sb2', '33', 'F', 'Das Wort lautet: INFORMATIONEN'),
    ('sb2', '34', 'H', 'Das Wort lautet: NENNEN'),
    ('sb2', '35', 'D', 'Das Wort lautet: GEEIGNET'),
    ('sb2', '36', 'O', 'Das Wort lautet: WEGEN'),
    ('sb2', '37', 'I', 'Das Wort lautet: NUN'),
    ('sb2', '38', 'A', 'Das Wort lautet: AM'),
    ('sb2', '39', 'K', 'Das Wort lautet: TERMIN'),
    ('sb2', '40', 'N', 'Das Wort lautet: WÄREN'),
    ('hv1', '41', 'r', null),
    ('hv1', '42', 'f', null),
    ('hv1', '43', 'r', null),
    ('hv1', '44', 'f', null),
    ('hv1', '45', 'f', null),
    ('hv2', '46', 'f', null),
    ('hv2', '47', 'r', null),
    ('hv2', '48', 'f', null),
    ('hv2', '49', 'f', null),
    ('hv2', '50', 'r', null),
    ('hv2', '51', 'f', null),
    ('hv2', '52', 'r', null),
    ('hv2', '53', 'r', null),
    ('hv2', '54', 'r', null),
    ('hv2', '55', 'r', null),
    ('hv3', '56', 'f', null),
    ('hv3', '57', 'r', null),
    ('hv3', '58', 'r', null),
    ('hv3', '59', 'f', null),
    ('hv3', '60', 'f', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'b1' and t.slug = 'modell-11'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;

-- ================= modell-12 · ANDREAS2 =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('b1', 'modell-12', 'ANDREAS2', '40 Aufgaben · 150 Minuten',
        '[{"id": "block-lv-sb", "title": "Leseverstehen und Sprachbausteine", "minutes": 90, "hint": "Aufgaben 1–40", "parts": ["lv1", "lv3", "sb2"], "maxPoints": 105.0, "availablePoints": 62.5, "missing": 16}, {"id": "block-hv", "title": "Hörverstehen", "minutes": 30, "hint": "Aufgaben 41–60", "parts": ["hv2", "hv3"], "maxPoints": 75.0, "availablePoints": 50.0, "missing": 5}, {"id": "block-sa", "title": "Schriftlicher Ausdruck", "minutes": 30, "hint": "", "parts": ["sa"], "maxPoints": 45.0, "availablePoints": 45, "missing": 0}]'::jsonb, 40, true, 12)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('lv1', 'Leseverstehen', 'Leseverstehen, Teil 1', 15, 'Lesen Sie die Überschriften a–j und die Texte 1–5. Finden Sie für jeden Text die passende Überschrift. Jede Überschrift passt nur einmal.', 'matching', '{"bank": [{"key": "A", "text": "Bilder mit dem Computer bearbeiten"}, {"key": "B", "text": "Kirche bietet Backkurs für Kinder an"}, {"key": "C", "text": "Kirche eröffnet neuen Treffpunkt"}, {"key": "D", "text": "Neu: Kochbuch über Weiner Fleischgerichte"}, {"key": "E", "text": "Neue Computerprogramme werden getestet"}, {"key": "F", "text": "Preis für bestes Lernprogramm"}, {"key": "G", "text": "Rezepte für Kuchen und Torten"}, {"key": "H", "text": "Studie zeigt: Kaffeetrinker sind glücklicher"}, {"key": "I", "text": "Warum die Wiener ins Café gehen"}, {"key": "J", "text": "Zürcher Fotografen stellen aus"}], "bankTitle": "Überschriften", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 0),
    ('lv3', 'Leseverstehen', 'Leseverstehen, Teil 3', 20, 'Lesen Sie die Situationen 11–20 und die Anzeigen im Bild. Finden Sie für jede Situation die passende Anzeige. Wenn Sie keine passende Anzeige finden, wählen Sie X.', 'matching', '{"bank": [{"key": "A", "text": ""}, {"key": "B", "text": ""}, {"key": "C", "text": ""}, {"key": "D", "text": ""}, {"key": "E", "text": ""}, {"key": "F", "text": ""}, {"key": "G", "text": ""}, {"key": "H", "text": ""}, {"key": "I", "text": ""}, {"key": "J", "text": ""}, {"key": "K", "text": ""}, {"key": "L", "text": ""}, {"key": "X", "text": ""}], "bankTitle": "Anzeigen", "bankImage": "img/m12-lv3.jpg", "maxPoints": 25.0, "availablePoints": 22.5, "missing": 1, "pointsPerItem": 2.5}'::jsonb, 1),
    ('sb2', 'Sprachbausteine', 'Sprachbausteine, Teil 2', 15, 'Lesen Sie den Text und schließen Sie die Lücken 31–40. Benutzen Sie die Wörter aus der Liste. Jedes Wort passt nur einmal.', 'wordbank', '{"bank": [{"key": "A", "text": "ALS"}, {"key": "B", "text": "ANFANGEN"}, {"key": "C", "text": "ARBEITEN"}, {"key": "D", "text": "ERZÄHLT"}, {"key": "E", "text": "FALLS"}, {"key": "F", "text": "INFORMIERT"}, {"key": "G", "text": "INTERESSIERT"}, {"key": "H", "text": "MÖCHTEN"}, {"key": "I", "text": "MÖGLICH"}, {"key": "J", "text": "NUR"}, {"key": "K", "text": "ÖFTER"}, {"key": "L", "text": "UNBEKANNT"}, {"key": "M", "text": "VOR"}, {"key": "N", "text": "WÜRDE"}, {"key": "O", "text": "ZWISCHEN"}], "bankTitle": "Wörterliste", "passages": [{"paragraphs": [{"t": ") (", "b": false}, {"t": "Neuendorf, den…. Sehr geehrte Frau Bauer, ich habe Ihre Anzeige in der Neuen Presse gelesen und bin an dem Filmprojekt sehr (31).", "b": false}, {"t": "ich war schon (32) für einige Wochen im Ausland. Vor allem im Sommer habe ich während meines Studiums viele Sprachkurse besucht. Länger als ein halbes Jahr habe ich (33) einmal im Ausland gelebt, und zwar (34) zwei Jahren. Mein Chef machte mir damals das Angebot, acht Monate im Tochterunternehmen der Firma in Portugal zu (35) , was ich dann auch getan habe.", "b": false}, {"t": "Am Anfang war es sehr schwer, weil ich niemanden kannte und alles sehr neu und (36) für mich war. Eigentlich wollte ich so schnell wie (37) wieder zurück. Aber dann habe ich nette Kollegen kennen gelernt, die mir auch über die Kultur und das Leben in Portugal (38) haben.", "b": false}, {"t": "Ich glaube, dass meine Erfahrungen für viele andere Menschen, die auch im Ausland leben wollen, sehr interessant sein könnten, und ich (39) gerne auch vor der Kamera darüber erzählen. (40) Sie noch weitere Fragen an mich haben, können Sie mich gerne anrufen, meine Telefonnummer ist 07612/64788980.", "b": false}, {"t": "Ich würde mich freuen, bald von Ihnen zu hören. Mit freundlichen Grüßen KAROLINE POINTNER", "b": false}]}], "maxPoints": 15.0, "availablePoints": 15.0, "missing": 0, "pointsPerItem": 1.5}'::jsonb, 2),
    ('hv2', 'Hörverstehen', 'Hörverstehen, Teil 2', 14, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 2.5}'::jsonb, 3),
    ('hv3', 'Hörverstehen', 'Hörverstehen, Teil 3', 8, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 4),
    ('sa', 'Schriftlicher Ausdruck', 'Schriftlicher Ausdruck', 30, 'Antworten Sie auf den Brief. Schreiben Sie etwas zu den folgenden vier Punkten:', 'writing', '{"brief": {"intro": "Ein Bekannter hat Ihnen folgenden Brief geschrieben:", "greeting": "Liebe(r)........", "paragraphs": ["es tut mir wirklich leid, dass ich dir schon so lange nicht geschrieben habe. Bei mir ist im letzten Monat ziemlich viel los gewesen. Vor drei Wochen bin ich nämlich in eine neue Wohnung gezogen, weil die alte für mich zu klein war. Mittlerweile habe ich mich schon sehr schön eingerichtet, mit ein paar neuen Möbeln usw. Ich fühle mich wirklich wohl! Hast du nicht Lust. Im Sommer zu mir zu Besuch zu kommen? In meiner neuen Wohnung habe ich jetzt auch ein kleines Arbeitszimmer für meine ganzen Bücher und den Schreibtisch mit dem Computer. Wie ist das bei dir? Machst du eigentlich viel am Computer?", "Lass doch mal wieder was von dir hören!", "Liebe Grüße und bis bald"], "signature": "Andreas"}, "hints": ["Bevor Sie den Brief schreiben, überlegen Sie sich eine passende Reihenfolge der punkte, eine passende"], "criteria": [{"title": "Aufgabenbewältigung", "hint": "Sind alle vier Leitpunkte inhaltlich angemessen bearbeitet?"}, {"title": "Kommunikative Gestaltung", "hint": "Anrede, Gruß, passendes Register und verbundene Sätze statt aneinandergereihter Punkte?"}, {"title": "Formale Richtigkeit", "hint": "Stören Fehler in Grammatik, Wortschatz und Rechtschreibung das Verstehen?"}], "grades": [{"key": "A", "points": 5}, {"key": "B", "points": 3}, {"key": "C", "points": 1}, {"key": "D", "points": 0}], "factor": 3, "maxPoints": 45, "availablePoints": 45, "missing": 0}'::jsonb, 5)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'b1' and t.slug = 'modell-12'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('lv1', '1', 'Die Kunst – und Medienschule F+ F Zürich bietet bereits zum dritten Mal den Computerkurs Digitale Bildbearbeitung an im neuen Semester steht für zehn Samstage Fotografie nach der Fotografie also die digitale Bearbeitung von Bildern im Mittelpunkt Dabei kommen verschiedene Softwareprodukte zum Einsatz Der Kurs befasst sich aber nicht nur mit dem – – Vermitteln auch Themen und Problembereiche rund um die digitale Foto und Bildbearbeitung kurskosten 800Franken Nähere Informationen und Anmeldung zu diesem Kurs www.f- f.ch.', null::jsonb, 5.0, null::jsonb, 0),
    ('lv1', '2', '– Neuperlach-Süd Nach dem Einkaufen eine Kaffee genießen, mit anderen ins Gespräch Immen, sich mit Bekannten treffen oder einfach spannen all das geht ab 11 Juli immer – – dienstags zwischen 14 und 18 Uhr im neuen Eiscafé der Dietrich Bonhoeffer Kirche Wir hotten damit einen Ort der Begegnung für Jung und Alt anbieten und zur Belebung des Stadtteils beitragen erklärt Pfarrer Sebastian Kühnen. Neben kalten und heißen Getränken sowie Kuchen steht während der Öffnungszeiten auch eine Mitarbeiten für Gespräch zur Verfügung.', null::jsonb, 5.0, null::jsonb, 1),
    ('lv1', '3', 'Geheimnisse der modernen Konditorkunst der Meister des Süßen, Herwig Gasser, in Jahre hinweg sammelte der Bäcker des berühmten Wiener Café Landmann Mehlspeisenrezepte. Von der Birnentorte über den Apfelstrudel bis hin zum Heidelbeerstolle Verlag Kettel, 110 Fotos, 300 Seiten. – – ISBAN 3 85134 014 -0', null::jsonb, 5.0, null::jsonb, 2),
    ('lv1', '4', 'Am Montag wird in Stuttgart die Bildungs-Didacta eröffnet. Dort werden vor allem Lehrmaterialien vorgestellt. Bei vielen sich um Bildungssoftware. Für ein gelungenes Softwareprojekt wird am der Bildungssoftwarepreis digital vergeben Dabei handelt es sich um die wichtige Auszeichnung für Lehr und Lernprogramm deutschsprachigen Raum Die verzeichnen mit dem digital multimediale Gebote aus, die inhaltlich und formal als ragend und beispielgebend gelten können.', null::jsonb, 5.0, null::jsonb, 3),
    ('lv1', '5', '– Des Gallup Instituts hat sich mit Kaffeehausverhaltens der Wiener Ein Vorurteil hat sich dabei bestätigt Kaffeehaus und der Wiener Seine Melange Ergebnisse der Studie 27 der an, zumindest einmal im Monat der Nähe ihrer Wohnung zu gehen. Durchschnittlich 54 Minuten Befragten in ihrem Stamm Café Kundschaft umso länger wird gegessen. Der Grund ein Kaffeehaus wichtiger ist das Plaudern und Freunden. 77 der Befragten Grund für den Besuch im Kaffeehaus', null::jsonb, 5.0, null::jsonb, 4),
    ('lv3', '11', 'Sie mögen thailändisches Essen und möchten lernen, einige Speisen selbst zu kochen.', null::jsonb, 2.5, null::jsonb, 0),
    ('lv3', '12', 'Sie müssen umziehen und brauchen jemand, der Ihnen hilft.', null::jsonb, 2.5, null::jsonb, 1),
    ('lv3', '13', 'Ihr Kind hat in Mathematik schlechte Noten bekommen und braucht Nachhilfe.', null::jsonb, 2.5, null::jsonb, 2),
    ('lv3', '14', 'Ihre Freundin hat Geburtstag. Sie möchten ihr einen Blumenstrauß schicken lassen.', null::jsonb, 2.5, null::jsonb, 3),
    ('lv3', '15', 'Am Samstag wollen sie mit Ihrer Tante eine Blumenausstellung besuchen.', null::jsonb, 2.5, null::jsonb, 4),
    ('lv3', '16', 'Ihr Kollege heiratet. Sie möchten ihm etwas für die Küche schenken.', null::jsonb, 2.5, null::jsonb, 5),
    ('lv3', '17', 'Sie wollen für eine Hochzeit einen Luxuswagen mieten.', null::jsonb, 2.5, null::jsonb, 6),
    ('lv3', '18', 'Am nächsten Montag möchten Sie mit Ihren Freunden thailändisch essen gehen.', null::jsonb, 2.5, null::jsonb, 7),
    ('lv3', '19', 'Für Ihre Geburtstagfeier suchen Sie jemanden, der bei Ihnen zu Hause kocht.', null::jsonb, 2.5, null::jsonb, 8),
    ('sb2', '31', '… der Neuen Presse gelesen und bin an dem Filmprojekt sehr (31). ich war schon (32) für einige Wochen im Ausland. Vor …', null::jsonb, 1.5, null::jsonb, 0),
    ('sb2', '32', '… und bin an dem Filmprojekt sehr (31). ich war schon (32) für einige Wochen im Ausland. Vor allem im Sommer habe …', null::jsonb, 1.5, null::jsonb, 1),
    ('sb2', '33', '… Sprachkurse besucht. Länger als ein halbes Jahr habe ich (33) einmal im Ausland gelebt, und zwar (34) zwei Jahren. Mein …', null::jsonb, 1.5, null::jsonb, 2),
    ('sb2', '34', '… Jahr habe ich (33) einmal im Ausland gelebt, und zwar (34) zwei Jahren. Mein Chef machte mir damals das Angebot, …', null::jsonb, 1.5, null::jsonb, 3),
    ('sb2', '35', '… Monate im Tochterunternehmen der Firma in Portugal zu (35) , was ich dann auch getan habe. Am Anfang war es sehr …', null::jsonb, 1.5, null::jsonb, 4),
    ('sb2', '36', '… schwer, weil ich niemanden kannte und alles sehr neu und (36) für mich war. Eigentlich wollte ich so schnell wie (37) …', null::jsonb, 1.5, null::jsonb, 5),
    ('sb2', '37', '… (36) für mich war. Eigentlich wollte ich so schnell wie (37) wieder zurück. Aber dann habe ich nette Kollegen kennen …', null::jsonb, 1.5, null::jsonb, 6),
    ('sb2', '38', '… die mir auch über die Kultur und das Leben in Portugal (38) haben. Ich glaube, dass meine Erfahrungen für viele …', null::jsonb, 1.5, null::jsonb, 7),
    ('sb2', '39', '… leben wollen, sehr interessant sein könnten, und ich (39) gerne auch vor der Kamera darüber erzählen. (40) Sie noch …', null::jsonb, 1.5, null::jsonb, 8),
    ('sb2', '40', '… und ich (39) gerne auch vor der Kamera darüber erzählen. (40) Sie noch weitere Fragen an mich haben, können Sie mich …', null::jsonb, 1.5, null::jsonb, 9),
    ('hv2', '46', 'Herr Schütz arbeitet erst seit kurzer Zeit als Taxifahrer.', null::jsonb, 2.5, null::jsonb, 0),
    ('hv2', '47', 'In der Kleinstadt hatte Herr Schütz keine Geschäftsleute als Kunden', null::jsonb, 2.5, null::jsonb, 1),
    ('hv2', '48', 'Herr Schütz hat sich schon einmal in einen Fahrgast verliebt.', null::jsonb, 2.5, null::jsonb, 2),
    ('hv2', '49', 'Die Fahrgäste erzählen viel, weil sie den Taxifahrer nicht kennen', null::jsonb, 2.5, null::jsonb, 3),
    ('hv2', '50', 'Männer sprechen oft über unpersönliche Dinge.', null::jsonb, 2.5, null::jsonb, 4),
    ('hv2', '51', 'Herr Schütz bekommt von den Fahrgästen manchmal auch einen Tipp.', null::jsonb, 2.5, null::jsonb, 5),
    ('hv2', '52', 'In der Freizeit steht Sport für Herrn SSchütz an erster Stelle.', null::jsonb, 2.5, null::jsonb, 6),
    ('hv2', '53', 'Beim Schwimmen kann sich Herr Schütz von einem anstrengenden Tag erholen.', null::jsonb, 2.5, null::jsonb, 7),
    ('hv2', '54', 'Herr Schütz hat sich entschieden, nur am Tag Taxi zu fahren', null::jsonb, 2.5, null::jsonb, 8),
    ('hv2', '55', 'Nach Meinung von Herrn Schütz haben jüngere Taxifahrer weniger Angst, nachts zu an.', null::jsonb, 2.5, null::jsonb, 9),
    ('hv3', '56', 'In Norddeutschland steigen die Temperaturen morgen auf 5 bis 7 Grad.', null::jsonb, 5.0, null::jsonb, 0),
    ('hv3', '57', 'Hamburg hat öfter gewonnen als Stuttgart.', null::jsonb, 5.0, null::jsonb, 1),
    ('hv3', '58', 'Nach zwei Monaten müssen Sie für die Zeitschrift bezahlen.', null::jsonb, 5.0, null::jsonb, 2),
    ('hv3', '59', 'Auf dem Mittleren Ring in München wird die Geschwindigkeit kontrolliert.', null::jsonb, 5.0, null::jsonb, 3),
    ('hv3', '60', 'Janas Geburtstagsfest findet nicht im LEO statt.', null::jsonb, 5.0, null::jsonb, 4),
    ('sa', 'A', 'Antworten Sie auf den Brief. Schreiben Sie etwas zu den folgenden vier Punkten:', null::jsonb, 0, '{"minWords": 100, "points": ["Ihre Erfahrungen mit dem Computer", "Etwas über Ihre Wohnung", "Ob Sie Andreas besuchen möchten", "Was es bei Ihnen Neues gibt"]}'::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'b1' and t.slug = 'modell-12'
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
    ('lv3', '11', 'F', null),
    ('lv3', '12', 'K', null),
    ('lv3', '13', 'B', null),
    ('lv3', '14', 'I', null),
    ('lv3', '15', 'E', null),
    ('lv3', '16', 'L', null),
    ('lv3', '17', 'X', null),
    ('lv3', '18', 'X', null),
    ('lv3', '19', 'D', null),
    ('sb2', '31', 'G', 'Das Wort lautet: INTERESSIERT'),
    ('sb2', '32', 'K', 'Das Wort lautet: ÖFTER'),
    ('sb2', '33', 'J', 'Das Wort lautet: NUR'),
    ('sb2', '34', 'M', 'Das Wort lautet: VOR'),
    ('sb2', '35', 'C', 'Das Wort lautet: ARBEITEN'),
    ('sb2', '36', 'L', 'Das Wort lautet: UNBEKANNT'),
    ('sb2', '37', 'I', 'Das Wort lautet: MÖGLICH'),
    ('sb2', '38', 'D', 'Das Wort lautet: ERZÄHLT'),
    ('sb2', '39', 'N', 'Das Wort lautet: WÜRDE'),
    ('sb2', '40', 'E', 'Das Wort lautet: FALLS'),
    ('hv2', '46', 'f', null),
    ('hv2', '47', 'r', null),
    ('hv2', '48', 'f', null),
    ('hv2', '49', 'r', null),
    ('hv2', '50', 'f', null),
    ('hv2', '51', 'f', null),
    ('hv2', '52', 'r', null),
    ('hv2', '53', 'f', null),
    ('hv2', '54', 'f', null),
    ('hv2', '55', 'f', null),
    ('hv3', '56', 'f', null),
    ('hv3', '57', 'r', null),
    ('hv3', '58', 'r', null),
    ('hv3', '59', 'f', null),
    ('hv3', '60', 'f', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'b1' and t.slug = 'modell-12'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;

-- ================= modell-13 · THOMAS =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('b1', 'modell-13', 'THOMAS', '52 Aufgaben · 150 Minuten',
        '[{"id": "block-lv-sb", "title": "Leseverstehen und Sprachbausteine", "minutes": 90, "hint": "Aufgaben 1–40", "parts": ["lv1", "lv2", "lv3", "sb1", "sb2"], "maxPoints": 105.0, "availablePoints": 84.0, "missing": 9}, {"id": "block-hv", "title": "Hörverstehen", "minutes": 30, "hint": "Aufgaben 41–60", "parts": ["hv1", "hv2", "hv3"], "maxPoints": 75.0, "availablePoints": 75.0, "missing": 0}, {"id": "block-sa", "title": "Schriftlicher Ausdruck", "minutes": 30, "hint": "", "parts": ["sa"], "maxPoints": 45.0, "availablePoints": 45, "missing": 0}]'::jsonb, 52, true, 13)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('lv1', 'Leseverstehen', 'Leseverstehen, Teil 1', 15, 'Lesen Sie die Überschriften a–j und die Texte 1–5. Finden Sie für jeden Text die passende Überschrift. Jede Überschrift passt nur einmal.', 'matching', '{"bank": [{"key": "A", "text": "Eine Karte – viele Vorteile"}, {"key": "B", "text": "Endlich Ferien ohne Kinder"}, {"key": "C", "text": "Günstiger Urlaub für Vereinsmitglieder"}, {"key": "D", "text": "Meer statt Berge"}, {"key": "E", "text": "Neues Wohnprojekt für Alleinerziehende"}, {"key": "F", "text": "Reisebüros weltweit vernetzt"}, {"key": "G", "text": "Schweizer Seen weiterhin sehr beliebt"}, {"key": "H", "text": "Söhne schenken mehr als Töchter"}, {"key": "I", "text": "Schöne werden großzügiger beschenkt"}, {"key": "J", "text": "Ti W h Ki d ih S ß h b"}], "bankTitle": "Überschriften", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 0),
    ('lv2', 'Leseverstehen', 'Leseverstehen, Teil 2', 20, 'Lesen Sie den Text und die Aufgaben 6–10. Welche Lösung (A, B oder C) ist jeweils richtig?', 'mc', '{"passages": [{"paragraphs": [{"t": "Gelsenkirchen bietet schon seit Jahren preisgünstige Ferien. Über 1100 Zimmer und", "b": false}, {"t": "– –", "b": false}, {"t": "Wohnungen auch für das kleine Portemonnaie stehen zwischen Nordsee und Sizilien den", "b": false}, {"t": "Mitgliedern im neuen Katalog zur Auswahl. Nichtmitglieder erhalten diesen Katalog gegen eine", "b": false}, {"t": "Gebühr von 5 Euro. Infos: Telefon 061/981 25 25 oder", "b": false}, {"t": "www.ferienwohnung.ch", "b": false}, {"t": "Du oder Sie das ist hier die Frage", "b": true}, {"t": "Sprachliche Regeln am Arbeitsplatz", "b": true}, {"t": "Häufig erscheint Invar Kamprad, lekea-Gründer und-Besitzer, am Morgen unangemeldet angemeldet am Hintereingang einer seiner Filialen Guten Morgen ich bin der Invar Das schwedische Möbelbaus ist das beste Beispiel für die Du Kultur am Arbeitsplatz, denn alle Beschäftigten sprechen sich mit Du an. Die Gesellschaft für deutsche Sprache in Wiesbaden hat nun in einer Untersuchung festgestellt, dass mehr als 53 Prozent der befragten Personen alle Arbeitskollegen duzen. Wie zu erwarten sind es vor allem die 16 bis 29 jährigen (59 Prozent) die sich lieber schnell duzen Bei den über 60 Jährigen sank die Zahl auf 14 Prozent warum eigentlich sagt man am Arbeitsplatz immer öfter Du Zum Beispiel pflegen Ikea Greenpeace und McDonalds alle das obligatorische Du Damit wollen sie Vertrauen aufbauen und ein familiäres Umfeld schaffen. Gegenüber den Kunden ist an jedoch vorsichtiger geworden. So hat Ikea im Verkaufskatalog statt dem Du wieder das sie eingeführt Man hofft mit Sie mehr Leute nicht nur jüngere anzusprechen. Bis heute üblich ist das Du zum Beispiel in Schweizer Gewerkschaften Viele Mitglieder sind sogar beleidigt, wenn sie mit sie angesprochen werden Es gibt aber auch umgekehrten Fall, zwar bei der Polizei Wer in Deutschland einen Polizisten duzt riskiert eine Strafe in der Schweizer hingegen findet man eine Anzeige wegen Duzens eines Beamten übertrieben Polizisten werden sowieso kaum mit Du angesprochen meint Hanspeter Fäh von der Zürcher Stadtpolizei Der Trend zum Du kann jedoch auch als sozialer Druck oder Zwang empfunden werden. Ein Du abzulehnen gilt nämlich als unfreundlich. Das hat Dieter S Angestellter bei einem Textilgeschäft in Deutschland erfahren Ein Gericht entschied, dass er seine Kollegen weiterhin mit Du ansprechen musste.", "b": false}, {"t": "So sehr das Du in der Gesellschaft auch an Bedeutung gewinnt das Sie hat immer noch eine feste soziale Basis und kann diese sogar ausbauen Benimmkurse, wo man Höflichkeit und die richtigen Umgangsformen lernt, sind heute im Trend immer mehr Firmen schulen ihre Mitarbeiter in stilvollem Verhalten. Dazu gehören folgende Grundregeln: Die ältere Person bietet der jüngeren das Du an Oft ist jedoch auch die Stellung entscheidend Der ältere Mitarbeiter bietet seinem jüngeren Chef nie das Du an.", "b": false}]}], "maxPoints": 25.0, "availablePoints": 20.0, "missing": 1, "pointsPerItem": 5.0}'::jsonb, 1),
    ('lv3', 'Leseverstehen', 'Leseverstehen, Teil 3', 20, 'Lesen Sie die Situationen 11–20 und die Anzeigen im Bild. Finden Sie für jede Situation die passende Anzeige. Wenn Sie keine passende Anzeige finden, wählen Sie X.', 'matching', '{"bank": [{"key": "A", "text": ""}, {"key": "B", "text": ""}, {"key": "C", "text": ""}, {"key": "D", "text": ""}, {"key": "E", "text": ""}, {"key": "F", "text": ""}, {"key": "G", "text": ""}, {"key": "H", "text": ""}, {"key": "I", "text": ""}, {"key": "J", "text": ""}, {"key": "K", "text": ""}, {"key": "L", "text": ""}, {"key": "X", "text": ""}], "bankTitle": "Anzeigen", "bankImage": "img/m13-lv3.jpg", "maxPoints": 25.0, "availablePoints": 15.0, "missing": 4, "pointsPerItem": 2.5}'::jsonb, 2),
    ('sb1', 'Sprachbausteine', 'Sprachbausteine, Teil 1', 20, 'Lesen Sie den Text und schließen Sie die Lücken 21–30. Welche Lösung (A, B oder C) ist jeweils richtig?', 'mc', '{"passages": [{"paragraphs": [{"t": "Sehr geehrter Herr Samir, im Mai habe ich bei (21) für mich und meine Familie Flugtickets nach Indien bestellt und diese zwei Tage vor Abflug am 27. Juni auch erhalten. Leider entsprachen die Tickets überhaupt nicht dem, was zuvor bei der Buchung am Telefon ausgemacht worden (22).", "b": false}, {"t": "(23) ich ausdrücklich einen Direktflug nach Mumbai bestellt hatte, haben Sie mir Tickets (24) Zwischenstopp in Delhi ausgestellt. Wir mussten eine Nacht in Delhi verbringen und kamen so (25) einen Tag später als geplant in Mumbai an. Doch damit nicht genug. Die Tickets waren nämlich nicht nur anders als vereinbart, (26) auch noch viel teurer. Statt der erwarteten 640 Euro kosteten (27) Tickets 720 Euro.", "b": false}, {"t": "Ich darf Sie daher (28) Rückzahlung der zu viel verrechneten Kosten auf mein Konto (29) der Bank of India in Mumbai bitten. Meine Bankdaten finden Sie unten. Ich bitte Sie, die Angelegenheit bald zu klären und (30) dann zu antworten.", "b": false}, {"t": "Mit freundlichen Grüßen Luisa Martin", "b": false}]}], "maxPoints": 15.0, "availablePoints": 9.0, "missing": 4, "pointsPerItem": 1.5}'::jsonb, 3),
    ('sb2', 'Sprachbausteine', 'Sprachbausteine, Teil 2', 15, 'Lesen Sie den Text und schließen Sie die Lücken 31–40. Benutzen Sie die Wörter aus der Liste. Jedes Wort passt nur einmal.', 'wordbank', '{"bank": [{"key": "A", "text": "AUCH"}, {"key": "B", "text": "AUFTRAG"}, {"key": "C", "text": "BESCHREIBEN"}, {"key": "D", "text": "FRAGEN"}, {"key": "E", "text": "GEEIGENET"}, {"key": "F", "text": "GEGEÜBER"}, {"key": "G", "text": "INFORMATIONEN"}, {"key": "H", "text": "KÖNNTEN"}, {"key": "I", "text": "STATTFINDEN"}, {"key": "J", "text": "SUCHEN"}, {"key": "K", "text": "TERMIN"}, {"key": "L", "text": "TOUR"}, {"key": "M", "text": "VOR"}, {"key": "N", "text": "WÄREN"}, {"key": "O", "text": "WEIL"}], "bankTitle": "Wörterliste", "passages": [{"paragraphs": [{"t": "3. anach an", "b": false}, {"t": "Obwohl sondern bei", "b": false}, {"t": "B B", "b": false}, {"t": "Nämlich sonst vor", "b": false}, {"t": "C C", "b": false}, {"t": ") (", "b": false}, {"t": "Sehr geehrte Damen und Herren,", "b": false}, {"t": "unsere Organisation hat den (31) , eine deutsch-französische Konferenz zu europäischen", "b": false}, {"t": "Entwicklungsprogrammen vorzubereiten.", "b": false}, {"t": "Diese Veranstaltung könnte in Breisach (32) , und daher brauchen wir von Ihnen nähere(33). In Ihrer Anzeige (34) Sie die Sehenswürdigkeiten von Breisach und die verschiedenen touristischen Möglichkeiten. Deshalb erscheint uns Ihre Stadt als sehr (35) , auch (36) sie als Brücke zu Europa gilt.", "b": false}, {"t": "Nun haben wir folgende Bitte: Für diese Veranstaltung (37) wir ein gutes Hotel, möglichst am Ufer des Rheins, mit Konferenz- und Arbeitsräumen, ausgestattet mit den notwendigen technischen Anlagen, Internetanschluss usw. Es sollte (38) ruhig gelegen sein. Können Sie uns dazu Vorschläge schicken? Der (39) wäre 15.-21. November. Bitte geben Sie uns möglichst bald Bescheid. Für Prospekte und Informationen zu Preisen und Buchungsbedingungen(40) wir Ihnen dankbar. Mit freundlichen Grüßen", "b": false}, {"t": "ADRIAN SCHÖLLER EVD Trans GmbH", "b": false}]}], "maxPoints": 15.0, "availablePoints": 15.0, "missing": 0, "pointsPerItem": 1.5}'::jsonb, 4),
    ('hv1', 'Hörverstehen', 'Hörverstehen, Teil 1', 8, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 5),
    ('hv2', 'Hörverstehen', 'Hörverstehen, Teil 2', 14, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 2.5}'::jsonb, 6),
    ('hv3', 'Hörverstehen', 'Hörverstehen, Teil 3', 8, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 7),
    ('sa', 'Schriftlicher Ausdruck', 'Schriftlicher Ausdruck', 30, 'Antworten Sie Thomas. Schreiben Sie etwas zu allen vier Punkten:', 'writing', '{"brief": {"intro": "Sie haben von Ihnen Freund folgende E-Mail erhalten:", "greeting": "Liebe(r)........", "paragraphs": ["nach unserm schönen, gemeinsamen Erlebnis letztes Jahr möchte ich auch dieses Jahr wieder einen Ausflug für uns alle organisieren. Ich hoffe sehr, dass ihr Zeit habt und mitkommen könnt - ich freue mich schon jetzt, euch alle bald wieder zu sehen! Das Dumme ist nur, dass ich mir vor drei Wochen beim Basketball das Bein gebrochen habe und noch nicht so gut zu Fuß bin. Deshalb habe ich einen gemütlichen Ausflug mit Bus und Schiff geplant - hoffentlich ist dann auch das Wetter gut für die Schiffsfahrt! Wohin es geht, möchte ich euch aber noch nicht verraten - das soll eine Überraschung werden.", "Termin: übernächster Samstag.", "Zeit und Treffpunkt: 9:30 Uhr bei mir.", "Bitte schreibt mir doch, ob ihr beim Ausflug dabei sein könnt!", "Hoffentlich bis bald."], "signature": "Thomas"}, "hints": ["Überlegen Sie sich vor dem Schreiben eine passende Reihenfolge der punkte, eine passende Betreff, eine"], "criteria": [{"title": "Aufgabenbewältigung", "hint": "Sind alle vier Leitpunkte inhaltlich angemessen bearbeitet?"}, {"title": "Kommunikative Gestaltung", "hint": "Anrede, Gruß, passendes Register und verbundene Sätze statt aneinandergereihter Punkte?"}, {"title": "Formale Richtigkeit", "hint": "Stören Fehler in Grammatik, Wortschatz und Rechtschreibung das Verstehen?"}], "grades": [{"key": "A", "points": 5}, {"key": "B", "points": 3}, {"key": "C", "points": 1}, {"key": "D", "points": 0}], "factor": 3, "maxPoints": 45, "availablePoints": 45, "missing": 0}'::jsonb, 8)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'b1' and t.slug = 'modell-13'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('lv1', '1', '– Das fängt ja gut an: Schon im Kinderzimmer werden Jungs bevorzugt sie bekommen mehr geschenkt als Mädchen. Das ist das Ergebnis einer Untersuchung vom Bundesverband des Spielwaren- Einzelhandels-Bundesweit wurden 6500 Familien nach ihren Schenkgewohnheiten – – befragt. Fast immer wurden für die Söhne auch schon im Babyalter mehr gekauft. Zuständig für die Geschenke sind übrigens meist die Mütter.', null::jsonb, 5.0, null::jsonb, 0),
    ('lv1', '2', 'In diesem Sommer werden weitere 200 Großstadt-Jugendherbergen auf der ganzen Welt miteinander vernetzt ICYN heißt das Zauberwort International Communication Youth Network. Das System wurde speziell für Jugendherbergen entwickelt. Für nur 15 Euro Jahresgebühr kann man mit der ICYN-Karte weltweit nicht nur Übernachtungen in anderen Herbergen reservieren, sondern auch unbegrenzt im Internet surfen, sogar gratis übers Internet telefonieren, Bahn- und Flugtickets bargeldlos buchen sowie günstige Konzerttickets bekommen.', null::jsonb, 5.0, null::jsonb, 1),
    ('lv1', '3', 'Ob zu Hause, irgendwo in der Schweiz oder im Ausland: Ferien mit Kindern wollen gut geplant sein. Wo gibt es denn Orte, wo Kinder noch Abenteuer erleben, Hotels oder Wohnungen, in denen sie sich wohl fühlen, wo aber gleichzeitig auch die Eltern auf ihre Rechnung kommen? Ruth Michaela Richter gibt Tipps, verrät Adressen und zeigt Beispiele. Damit werden sogar Städtereisen oder Schlossferien in England interessant.', null::jsonb, 5.0, null::jsonb, 2),
    ('lv1', '4', 'Die Sehnsucht nach dem Meer ist in der Schweiz groß, vor allem bei der jüngeren Generation. Ein Drittel der Schweizerinnen und Schweizer würde nach einer Umfrage im Tausch für eine Meeresküste die Hälfte der Berge hergeben. Die Zeitschrift mare ließ über 1000 Personen in der Schweiz nach ihrem Verhältnis zum Meer befragen. Rund 42 Prozent der 15-bis 34-Jährigen würden treu dem Motto der Jugendbewegung der 80er Jahre: Nieder mit den Alpen, freie Sicht aufs Mittelmeer den Tausch eingehen. In der Deutschschweiz könnten sich nur 29 Prozent von den Bergen trennen, in der Roman die sind es 37 und im Tessin 43 Prozent.', null::jsonb, 5.0, null::jsonb, 3),
    ('lv1', '5', 'Ob für die traditionelle Familie oder für Alleinerziehende: Der Verein für Familienherbergen in Gelsenkirchenbietet schonseit Jahrenpreisgünstige Ferien Über 1100 Zimmer und', null::jsonb, 5.0, null::jsonb, 4),
    ('lv2', '6', 'Die Firma Ikea benutzt heute das. Du,', '[{"key": "A", "text": "weil das ein Zeichen für eine Familie Atmosphäre ist."}, {"key": "B", "text": "weil sie mehr jüngere Kunden gewinnen will."}, {"key": "C", "text": "weil so mehr Leute den Verkaufskatalog lesen."}]'::jsonb, 5.0, null::jsonb, 0),
    ('lv2', '7', 'In der Schweiz', '[{"key": "A", "text": "gilt das Du in Gewerkschaften als Beleidigung."}, {"key": "B", "text": "werden Polizisten nur selten mit Du angesprochen."}, {"key": "C", "text": "wird man bestraft, wenn man zu Beamten Du sagt."}]'::jsonb, 5.0, null::jsonb, 1),
    ('lv2', '8', 'Eine Untersuchung hat gezeigt,', '[{"key": "A", "text": "dass 14 Prozent der jüngeren Mitarbeiter das Sie vorziehen."}, {"key": "B", "text": "dass besonders jüngere Arbeitskollegen schneller das Du wählen."}, {"key": "C", "text": "dass sich alle Arbeitskollegen gern mit Du anderen würden."}]'::jsonb, 5.0, null::jsonb, 2),
    ('lv2', '9', 'Durch Kurse können Angestellte', '[{"key": "A", "text": "höfliches Verhalten am Arbeitsplatz lernen."}, {"key": "B", "text": "ihre Stellung im Arbeitsleben verbessern."}, {"key": "C", "text": "neue Trends beim Einrichten des Arbeitsplatzes kennen lernen."}]'::jsonb, 5.0, null::jsonb, 3),
    ('lv3', '11', 'Sie haben von einer Schweizer Schauspielerin gehört und möchten gern einen Film sehen.', null::jsonb, 2.5, null::jsonb, 0),
    ('lv3', '12', 'Sie haben gerade Ihre Ausbildung beendet und suchen eine Stelle an der Rezeption.', null::jsonb, 2.5, null::jsonb, 1),
    ('lv3', '13', 'Sie interessieren sich für Umweltschutz und suchen eine passende Sendung.', null::jsonb, 2.5, null::jsonb, 2),
    ('lv3', '14', 'Ihr Freund, der am Institut für Film und Bild studiert, sucht einen geeigneten Praktikumsplatz.', null::jsonb, 2.5, null::jsonb, 3),
    ('lv3', '15', 'In einer Sendereihe wird im Fernsehen über die neue politische Entwicklung in Deutschland berichtet. Sie wollen sich informieren.', null::jsonb, 2.5, null::jsonb, 4),
    ('lv3', '16', 'Sie interessieren sich für Großstädte und ihre Entwicklung und suchen dazu eine Sendung im Rundfunk.', null::jsonb, 2.5, null::jsonb, 5),
    ('sb1', '21', 'Sehr geehrter Herr Samir, im Mai habe ich bei (21) für mich und meine Familie Flugtickets nach Indien …', '[{"key": "A", "text": "ihnen"}, {"key": "B", "text": "Ihnen"}, {"key": "C", "text": "Sie"}]'::jsonb, 1.5, null::jsonb, 0),
    ('sb1', '22', '… was zuvor bei der Buchung am Telefon ausgemacht worden (22). (23) ich ausdrücklich einen Direktflug nach Mumbai …', '[{"key": "A", "text": "hat"}, {"key": "B", "text": "war"}, {"key": "C", "text": "wäre"}]'::jsonb, 1.5, null::jsonb, 1),
    ('sb1', '24', '… nach Mumbai bestellt hatte, haben Sie mir Tickets (24) Zwischenstopp in Delhi ausgestellt. Wir mussten eine …', '[{"key": "A", "text": "für"}, {"key": "B", "text": "mit"}, {"key": "C", "text": "zu"}]'::jsonb, 1.5, null::jsonb, 2),
    ('sb1', '25', '… Wir mussten eine Nacht in Delhi verbringen und kamen so (25) einen Tag später als geplant in Mumbai an. Doch damit …', '[{"key": "A", "text": "erst"}, {"key": "B", "text": "jetzt"}, {"key": "C", "text": "schon"}]'::jsonb, 1.5, null::jsonb, 3),
    ('sb1', '27', '… noch viel teurer. Statt der erwarteten 640 Euro kosteten (27) Tickets 720 Euro. Ich darf Sie daher (28) Rückzahlung der …', '[{"key": "A", "text": "den"}, {"key": "B", "text": "der"}, {"key": "C", "text": "die"}]'::jsonb, 1.5, null::jsonb, 4),
    ('sb1', '30', '… Ich bitte Sie, die Angelegenheit bald zu klären und (30) dann zu antworten. Mit freundlichen Grüßen Luisa Martin', '[{"key": "A", "text": "mich"}, {"key": "B", "text": "mir"}, {"key": "C", "text": "sich"}]'::jsonb, 1.5, null::jsonb, 5),
    ('sb2', '31', '… geehrte Damen und Herren, unsere Organisation hat den (31) , eine deutsch-französische Konferenz zu europäischen …', null::jsonb, 1.5, null::jsonb, 0),
    ('sb2', '32', '… vorzubereiten. Diese Veranstaltung könnte in Breisach (32) , und daher brauchen wir von Ihnen nähere(33). In Ihrer …', null::jsonb, 1.5, null::jsonb, 1),
    ('sb2', '33', '… in Breisach (32) , und daher brauchen wir von Ihnen nähere(33). In Ihrer Anzeige (34) Sie die Sehenswürdigkeiten von …', null::jsonb, 1.5, null::jsonb, 2),
    ('sb2', '34', '… daher brauchen wir von Ihnen nähere(33). In Ihrer Anzeige (34) Sie die Sehenswürdigkeiten von Breisach und die …', null::jsonb, 1.5, null::jsonb, 3),
    ('sb2', '35', '… Möglichkeiten. Deshalb erscheint uns Ihre Stadt als sehr (35) , auch (36) sie als Brücke zu Europa gilt. Nun haben wir …', null::jsonb, 1.5, null::jsonb, 4),
    ('sb2', '36', '… Deshalb erscheint uns Ihre Stadt als sehr (35) , auch (36) sie als Brücke zu Europa gilt. Nun haben wir folgende …', null::jsonb, 1.5, null::jsonb, 5),
    ('sb2', '37', '… Nun haben wir folgende Bitte: Für diese Veranstaltung (37) wir ein gutes Hotel, möglichst am Ufer des Rheins, mit …', null::jsonb, 1.5, null::jsonb, 6),
    ('sb2', '38', '… technischen Anlagen, Internetanschluss usw. Es sollte (38) ruhig gelegen sein. Können Sie uns dazu Vorschläge …', null::jsonb, 1.5, null::jsonb, 7),
    ('sb2', '39', '… sein. Können Sie uns dazu Vorschläge schicken? Der (39) wäre 15.-21. November. Bitte geben Sie uns möglichst bald …', null::jsonb, 1.5, null::jsonb, 8),
    ('sb2', '40', '… und Informationen zu Preisen und Buchungsbedingungen(40) wir Ihnen dankbar. Mit freundlichen Grüßen ADRIAN …', null::jsonb, 1.5, null::jsonb, 9),
    ('hv1', '41', 'Für die Sprechen ist es unwichtig, ob ihre Kinder in der Schule gut sind.', null::jsonb, 5.0, null::jsonb, 0),
    ('hv1', '42', 'Der Sprecher findet es wichtig, dass Eltern immer für ihre Kinder da sind.', null::jsonb, 5.0, null::jsonb, 1),
    ('hv1', '43', 'Die Sprecherin glaubt, dass sie mehr mit ihrer Tochter sprechen müsste.', null::jsonb, 5.0, null::jsonb, 2),
    ('hv1', '44', 'Es ist dem Sprecher wichtig, dass seine Kinder gesund leben.', null::jsonb, 5.0, null::jsonb, 3),
    ('hv1', '45', 'Der Sprecher möchte, dass sein Kind die eigenen Ideen realisieren kann.', null::jsonb, 5.0, null::jsonb, 4),
    ('hv2', '46', 'Viele Touristen besuchen Torgau wegen seiner historischen Sehenswürdigkeiten.', null::jsonb, 2.5, null::jsonb, 0),
    ('hv2', '47', 'Den Spielpark Hartenfels gibt es schon seit vielen Jahren.', null::jsonb, 2.5, null::jsonb, 1),
    ('hv2', '48', 'Außer dem Spielpark gibt es in der Umgebung viele andere Freizeitmöglichkeiten für die Kinder.', null::jsonb, 2.5, null::jsonb, 2),
    ('hv2', '49', 'Der Spielpark bietet den Kindern Spielmöglichkeiten, die sie zu Hause nicht haben.', null::jsonb, 2.5, null::jsonb, 3),
    ('hv2', '50', 'Die Kinder können im Spielpark auch selbst etwas bauen.', null::jsonb, 2.5, null::jsonb, 4),
    ('hv2', '51', 'Das Spielen am Back kann für die Kinder gefährlich werden.', null::jsonb, 2.5, null::jsonb, 5),
    ('hv2', '52', 'Beide Elternteile müssen auf die Kinder aufpassen.', null::jsonb, 2.5, null::jsonb, 6),
    ('hv2', '53', 'Im Spielpark können Kinder bis zum Alter von sieben von Aufsichtspersonen betreut werden.', null::jsonb, 2.5, null::jsonb, 7),
    ('hv2', '54', 'Der Eintritt in den Spielpark ist zurzeit frei.', null::jsonb, 2.5, null::jsonb, 8),
    ('hv2', '55', 'Die Schlossführung bereitet Kindern und Erwachsenen viel Spaß.', null::jsonb, 2.5, null::jsonb, 9),
    ('hv3', '56', 'Der nächste Zug nach Füssen fährt um 11:56 Uhr.', null::jsonb, 5.0, null::jsonb, 0),
    ('hv3', '57', 'Die Firma befindet sich in der Bellmondstraße.', null::jsonb, 5.0, null::jsonb, 1),
    ('hv3', '58', 'Im City-Kino werden im Untergeschoss alte Filme gezeigt.', null::jsonb, 5.0, null::jsonb, 2),
    ('hv3', '59', 'Das Zugteam bringt Ihnen Südtiroler Käsespezialitäten an Ihren Platz.', null::jsonb, 5.0, null::jsonb, 3),
    ('hv3', '60', 'Die Großmutter kann heute nicht kommen.', null::jsonb, 5.0, null::jsonb, 4),
    ('sa', 'A', 'Antworten Sie Thomas. Schreiben Sie etwas zu allen vier Punkten:', null::jsonb, 0, '{"minWords": 100, "points": ["Alternativvorschlag für Schlechtes Wetter", "Einladung annehmen", "Was Sie noch über den Ausflug wissen wollen", "Auf Sportunfall reagieren"]}'::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'b1' and t.slug = 'modell-13'
join sections s on s.test_id = t.id and s.section_id = v.section_id
on conflict (section_id, item_id) do update set text = excluded.text, options = excluded.options, points = excluded.points, meta = excluded.meta, sort = excluded.sort;

insert into item_answers (item_id, answer, explanation)
select i.id, v.answer, v.explanation
from (values
    ('lv1', '1', 'I', null),
    ('lv1', '2', 'A', null),
    ('lv1', '3', 'J', null),
    ('lv1', '4', 'D', null),
    ('lv1', '5', 'C', null),
    ('lv2', '6', 'A', null),
    ('lv2', '7', 'B', null),
    ('lv2', '8', 'B', null),
    ('lv2', '9', 'A', null),
    ('lv3', '11', 'D', null),
    ('lv3', '12', 'G', null),
    ('lv3', '13', 'F', null),
    ('lv3', '14', 'A', null),
    ('lv3', '15', 'I', null),
    ('lv3', '16', 'K', null),
    ('sb1', '21', 'B', null),
    ('sb1', '22', 'B', null),
    ('sb1', '24', 'B', null),
    ('sb1', '25', 'A', null),
    ('sb1', '27', 'C', null),
    ('sb1', '30', 'B', null),
    ('sb2', '31', 'B', 'Das Wort lautet: AUFTRAG'),
    ('sb2', '32', 'I', 'Das Wort lautet: STATTFINDEN'),
    ('sb2', '33', 'G', 'Das Wort lautet: INFORMATIONEN'),
    ('sb2', '34', 'C', 'Das Wort lautet: BESCHREIBEN'),
    ('sb2', '35', 'E', 'Das Wort lautet: GEEIGNET'),
    ('sb2', '36', 'O', 'Das Wort lautet: WEIL'),
    ('sb2', '37', 'J', 'Das Wort lautet: SUCHEN'),
    ('sb2', '38', 'A', 'Das Wort lautet: AUCH'),
    ('sb2', '39', 'K', 'Das Wort lautet: TERMIN'),
    ('sb2', '40', 'N', 'Das Wort lautet: WÄREN'),
    ('hv1', '41', 'f', null),
    ('hv1', '42', 'r', null),
    ('hv1', '43', 'f', null),
    ('hv1', '44', 'r', null),
    ('hv1', '45', 'r', null),
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
    ('hv3', '58', 'f', null),
    ('hv3', '59', 'f', null),
    ('hv3', '60', 'f', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'b1' and t.slug = 'modell-13'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;

-- ================= modell-14 · TAMARA =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('b1', 'modell-14', 'TAMARA', '53 Aufgaben · 150 Minuten',
        '[{"id": "block-lv-sb", "title": "Leseverstehen und Sprachbausteine", "minutes": 90, "hint": "Aufgaben 1–40", "parts": ["lv1", "lv2", "lv3", "sb1", "sb2"], "maxPoints": 105.0, "availablePoints": 85.5, "missing": 8}, {"id": "block-hv", "title": "Hörverstehen", "minutes": 30, "hint": "Aufgaben 41–60", "parts": ["hv1", "hv2", "hv3"], "maxPoints": 75.0, "availablePoints": 75.0, "missing": 0}, {"id": "block-sa", "title": "Schriftlicher Ausdruck", "minutes": 30, "hint": "", "parts": ["sa"], "maxPoints": 45.0, "availablePoints": 45, "missing": 0}]'::jsonb, 53, true, 14)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('lv1', 'Leseverstehen', 'Leseverstehen, Teil 1', 15, 'Lesen Sie die Überschriften a–j und die Texte 1–5. Finden Sie für jeden Text die passende Überschrift. Jede Überschrift passt nur einmal.', 'matching', '{"bank": [{"key": "A", "text": "Neue Untersuchung über Familien in der Schweiz"}, {"key": "B", "text": "Ein Jahr preiswert reisen"}, {"key": "C", "text": "Buchtipp: Ausflüge für Familien"}, {"key": "D", "text": "Bahnfahren im nächsten Jahr um 25% teurer!"}, {"key": "E", "text": "Ein Unternehmen mit vielen beruflichen Möglichkeiten"}, {"key": "F", "text": "Neue Kindersendung im Fernsehen"}, {"key": "G", "text": "Der Film soll echt sein: Schweizer Filmteam in Indien"}, {"key": "H", "text": "Wie man im Zug Leute kennen lernt"}, {"key": "I", "text": "Jeden Tag ein Stück Wirklichkeit im Fernsehen"}, {"key": "J", "text": "Filmaufnahmen im Berner Oberland"}], "bankTitle": "Überschriften", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 0),
    ('lv2', 'Leseverstehen', 'Leseverstehen, Teil 2', 20, 'Lesen Sie den Text und die Aufgaben 6–10. Welche Lösung (A, B oder C) ist jeweils richtig?', 'mc', '{"passages": [{"paragraphs": [{"t": "treffen, lohnt es sich, sich gründlich zu informieren, zum Beispiel aus unserer Website", "b": false}, {"t": "www. Bahn .de", "b": false}, {"t": "Die neue Sir-Karl-Popper-Schule", "b": true}, {"t": "Ein Schulversuch für besonders Klage Schüler", "b": true}, {"t": "WIEN. Es ist eine ganz normale Schulstunde Geschichte in einer ganz normale Klasse. Während der Lehrer", "b": false}, {"t": "– – einen Vortrag über das alle Rom hält, unterhalten sich die Schüler über den Schulball, kreieren die Kleidung des Lehrers, reichen Zettel unter der Schulbank weiter. Ganz normale Kinder", "b": false}, {"t": "Auch überdurchschnittlich intelligente Kinder sind ganz normale Kinder, betont Elfriede Wegricht, Psychologin in der Sir Karl Popper Schule, die im vergangen September Ihren Betrieb aufgenommen hat nur weil sie in der Schule gut sind, heißt das nicht, dass sie nicht genauso wie alle anderen Schüler Liebeskummer, Ärger mit den Eltern und andere Pubertätsporobleme haben Der Unterschied zwischen normalen und hochbegabten in ihrer bisherigen Schulkarriere nicht besonders anstrengen mussten und es nicht gewohnt sind, mit ihrer Zeit gut hauszuhalten Förderung durch Forderung Um überdurchschnittlich intelligente Kinder nun entsprechend zu fördern, sieht das Konzept der Sir Karl Popper- Schule mehr Fremdsprachen projektorientiertes Arbeiten in kleinen Klassen und vor allem mehr Eigenverantwortung für den Lernenden vor. Dazu kommt die Förderung der individuellen Fähigkeiten: Wer in einem Fach gut ist und sich besonders für ein Thema interessiert bekommt Sonderaufgaben und tiefer gehen Ende Unterlagen. Anfangs war der plötzlich Mehr aufwand ein Schock für die Schüler, die eine 40 Stunden Woche zu bewältigen haben Aber es ist besser, sie erleben den Schock jetzt als zu Beginn des Studiums meint Herr Peters Lehrer und Schülerbetreuer an der Popper Schule denn oft scheitern besonders kluge Menschen Später weil sie mit ihrer Intelligenz nichts anzufangen wissen Denn zumeist erreichten sie mit wenig Aufwand und Mitarbeit relativ gute Ergebnisse Wer ist hochbegabt? Zielgruppe der Sir Karl Popper Schule sind Kinder, die in mindestens einem Fach hochbegabt sind und überdurchschnittlich gute Ergebnisse haben, das sind 20 30 der Schüler. Nach einer Aufnahmeprüfung wurden von 64 Bewerben 28 geteilt sind und von insgesamt 28 Lehren betreut werden In diesen Klassen können die über durchschnittliche intelligenten Schüler dann endlich so sein, wie sie sind, ohne bei jeder Wortmeldung von ihren Klassenkameraden beschimpft zu werden meint die Schulpsychologien Ziel des", "b": false}, {"t": "Schulversuchs sei es jedoch laut Peters nicht, besonders kluge Schüler von normalen Kindern zu trennen, sondern Erfahrung im Umgang mit überdurchschnittlich die Begabtenförderung in die Normalschule zu übernehmen.", "b": false}]}], "maxPoints": 25.0, "availablePoints": 20.0, "missing": 1, "pointsPerItem": 5.0}'::jsonb, 1),
    ('lv3', 'Leseverstehen', 'Leseverstehen, Teil 3', 20, 'Lesen Sie die Situationen 11–20 und die Anzeigen im Bild. Finden Sie für jede Situation die passende Anzeige. Wenn Sie keine passende Anzeige finden, wählen Sie X.', 'matching', '{"bank": [{"key": "A", "text": ""}, {"key": "B", "text": ""}, {"key": "C", "text": ""}, {"key": "D", "text": ""}, {"key": "E", "text": ""}, {"key": "F", "text": ""}, {"key": "G", "text": ""}, {"key": "H", "text": ""}, {"key": "I", "text": ""}, {"key": "J", "text": ""}, {"key": "K", "text": ""}, {"key": "L", "text": ""}, {"key": "X", "text": ""}], "bankTitle": "Anzeigen", "bankImage": "img/m14-lv3.jpg", "maxPoints": 25.0, "availablePoints": 15.0, "missing": 4, "pointsPerItem": 2.5}'::jsonb, 2),
    ('sb1', 'Sprachbausteine', 'Sprachbausteine, Teil 1', 20, 'Lesen Sie den Text und schließen Sie die Lücken 21–30. Welche Lösung (A, B oder C) ist jeweils richtig?', 'mc', '{"passages": [{"paragraphs": [{"t": "Sehr geehrter Herr Schmidt, im Januar hatte ich bei (21) für mich und meine Familie einen Flug nach Indien gebucht. Leider entsprach unser Flug überhaupt nicht dem, (22)bei der Buchung am Telefon ausgemacht worden war.", "b": false}, {"t": "(23) ich ausdrücklich einen Direktflug nach Mumbai bestellt hatte, haben Sie mir einen Flug (24) Zwischenstopp in Delhi ausgestellt. Wir mussten eine Nacht in Delhi verbringen und kamen so (25) einen Tag später als geplant in Mumbai an. Doch damit nicht genug. Der Flug war nicht nur anders als vereinbart, (26) auch noch viel teurer. statt (27) erwarteten 640 Euro kostete der Flug 720 Euro. Ich darf Sie daher (28) Rückzahlung der zu viel verrechneten Kosten auf mein Konto (29) der Deutschen Bank in Mumbai bitten. Meine Bankdaten haben Sie bereits.", "b": false}, {"t": "Ich bitte Sie, die Angelegenheit bald zu klären und (30) dann zu antworten.Mit", "b": false}, {"t": "freundlichen Grüßen Harish Khurana", "b": false}]}], "maxPoints": 15.0, "availablePoints": 10.5, "missing": 3, "pointsPerItem": 1.5}'::jsonb, 3),
    ('sb2', 'Sprachbausteine', 'Sprachbausteine, Teil 2', 15, 'Lesen Sie den Text und schließen Sie die Lücken 31–40. Benutzen Sie die Wörter aus der Liste. Jedes Wort passt nur einmal.', 'wordbank', '{"bank": [{"key": "A", "text": "AUF"}, {"key": "B", "text": "BEIM"}, {"key": "C", "text": "DESWEGEN"}, {"key": "D", "text": "MÖCHTE"}, {"key": "E", "text": "NENNT"}, {"key": "F", "text": "SAGT"}, {"key": "G", "text": "SOLLTE"}, {"key": "H", "text": "SONDERN"}, {"key": "I", "text": "VON"}, {"key": "J", "text": "WAS"}, {"key": "K", "text": "WEGEN"}, {"key": "L", "text": "WEIL"}, {"key": "M", "text": "WELCHEN"}, {"key": "N", "text": "WÜRDE"}, {"key": "O", "text": "ZUM"}], "bankTitle": "Wörterliste", "passages": [{"paragraphs": [{"t": "23. A Danach 26. A besonders 29. A an", "b": false}, {"t": "Obwohl sondern bei", "b": false}, {"t": "Nämlich sonst vor", "b": false}, {"t": "C C", "b": false}, {"t": ") (", "b": false}, {"t": "Sehr geehrte Frau Borner,", "b": false}, {"t": "es gibt ganz viele Raschläge, wie man sich ernähren soll, was man essen soll und was nicht. Die meisten Empfehlungen sind aber nicht für etwas, (31) gegen etwas, und zwar immer wieder gegen etwas anderes: gegen Fleisch zum Beispiel oder gegen Zucker, aber auch gegen Milch. so (32) man etwa, wer kein Fleisch isst, lebt nicht nur gesünder, sondern fühlt sich auch besser.", "b": false}, {"t": "(33) Durchsehen einer Zeitschrift ist mir Ihre Anzeige aufgefallen, und nun habe ich folgende Fragen an Sie: Von (34) Nahrungsmitteln darf man eigentlich so viel essen, wie man will? Was (35) jeden Tag gegessen werden? Und wie ist das mit der Milch? Die einen sagen, Milch ist sehr gesund (36) der vielen wichtigen Nährstoffe. Andere meinen, wer viel Milch trinkt, kann Probleme mit dem Magen bekommen. Außerdem kann man anstelle (37) Milch auch Mineralwasser trinken. Was soll ich jetzt glauben?", "b": false}, {"t": "Für eine Antwort (38) meine Fragen danke ich Ihnen im Voraus. Könnten Sie mir auch noch eine Broschüre schicken? Das Thema Essen und Sport (39) mich besonders interessieren, (40) ich selber viel Sport treibe.", "b": false}, {"t": "Mit freundlichen Grüßen Silvia Schönenberger", "b": false}]}], "maxPoints": 15.0, "availablePoints": 15.0, "missing": 0, "pointsPerItem": 1.5}'::jsonb, 4),
    ('hv1', 'Hörverstehen', 'Hörverstehen, Teil 1', 8, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 5),
    ('hv2', 'Hörverstehen', 'Hörverstehen, Teil 2', 14, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 2.5}'::jsonb, 6),
    ('hv3', 'Hörverstehen', 'Hörverstehen, Teil 3', 8, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 7),
    ('sa', 'Schriftlicher Ausdruck', 'Schriftlicher Ausdruck', 30, 'Antworten Sie Tamara. Schreiben Sie etwas zu allen vier Punkte:', 'writing', '{"brief": {"intro": "Eine Freundin hat Ihnen den folgenden Brief geschrieben:", "greeting": "Liebe(r)........", "paragraphs": ["wie geht es Dir? Du hast mir schon so lange nicht mehr geschrieben, dass ich mir Sorgen mache. Hoffentlich isst bei Euch alles in Ordnung. Es wird wirklich Zeit, dass wir uns wiedersehen. Anfang des Jahres habe ich meinen Arbeitsplatz gewechselt. Meine neue Stelle ist sehr interessant, aber auch anstrengend.", "Ich bin nun beruflich sehr viel unterwegs. Demnächst muss ich auch in Eure Gegend reisen. Dann könnten wir uns doch einmal am Abend treffen und gemeinsam etwas unternehmen. Wie findest Du meine Idee? Ich würde auch sehr gerne Deine Familie kennenlernen.", "Bitte antworte mir bald!", "Herzliche Grüße"], "signature": "Deine Tamara"}, "hints": ["Überlegen Sie sich vor dem Schreiben eine passende Reihenfolge der punkte, eine passende Betreff, eine"], "criteria": [{"title": "Aufgabenbewältigung", "hint": "Sind alle vier Leitpunkte inhaltlich angemessen bearbeitet?"}, {"title": "Kommunikative Gestaltung", "hint": "Anrede, Gruß, passendes Register und verbundene Sätze statt aneinandergereihter Punkte?"}, {"title": "Formale Richtigkeit", "hint": "Stören Fehler in Grammatik, Wortschatz und Rechtschreibung das Verstehen?"}], "grades": [{"key": "A", "points": 5}, {"key": "B", "points": 3}, {"key": "C", "points": 1}, {"key": "D", "points": 0}], "factor": 3, "maxPoints": 45, "availablePoints": 45, "missing": 0}'::jsonb, 8)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'b1' and t.slug = 'modell-14'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('lv1', '1', 'Immer wieder drehen indische Regisseure Szenen ihrer Kinofilme in den Schweizer Bergen. Warum nehmen sie die Strapazen und hoben Kosten einer solch langen Reise auf sich? Das Hamburger Abendblatt eines dieser Filmteams auf dem Drehplatz im idyllischen Berner Oberland erhielt spannende und heitere Antworten.', null::jsonb, 5.0, null::jsonb, 0),
    ('lv1', '2', 'KIDTOURS Ferien mit Kindern ist ein praktischer Ausflugsführer für Familien: mit 1000 Tipps, Tricks und Ideen für jeden Geschmack, jedes Alter und jedes Budget. Das übersichtliche, hübsch illustrierte Nach- schlage werk erhalten Sie für € 19,50 im Buchhandel oder direkt bei Werd Verlag, www.werd.net.', null::jsonb, 5.0, null::jsonb, 1),
    ('lv1', '3', 'Das Halbtax -Abo ist Ihr Schlüssel zu günstigen Reisen mit Bahn, Bus und Schifft und präsentiert sich im praktischen Kreditkartenformat. Schon beim Abo selbst können Sie zünftig sparen: Für ein Jahr halbtaxeln bezahlen Sie 150 Schweizer Franken. Und das ist noch nicht alles: Mit dem Halbtax-Abo sind Sie gut informiert: Zweimal jährlich erhalten Sie das Kundenmagazin mit vielen Reise -Ideen und exklusiven Reiseangeboten. Mit Ihrem Halbtax- Abo erhalten Sie 25% Preisnachlass auf Zugfahrten von der Schweiz nach Deutschland und Österreich, wenn Sie Ihre Fahrkarte in der Schweiz kaufen. SBB CFF FF SBB – Schweizerische Bundesbahnen', null::jsonb, 5.0, null::jsonb, 2),
    ('lv1', '4', 'Dokumentarfilm und Seifenoper zusammen heißt Doku-Soap, stammt aus England und macht sich seit Jahren auch auf deutschen TV Kanälen breit. Vor allem Privatsender haben sich als erfolgreiche Doku – Soap- Sender etabliert. In vielen TV- Serien kann man das wirkliche Leben von Menschen verfolgen und mit ihnen mit leben. Zurzeit besonders erfolgreich: die Sendung Tausche Familie die täglich um 18 Uhr viele Zuschauer vor den Fernseher lockt.', null::jsonb, 5.0, null::jsonb, 3),
    ('lv1', '5', 'Wir wollen dir bei der Berufswahl helfen: Die deutsche Bahn, ein Unternehmen mit Zukunft. Viele Berufe ändern sich im Laufe der Zeit. Genauso wie die Interessen im Leben. Und trotzdem gibt es Neigungen und Fähigkeiten, die du lange Zeit in deinem Leben behalten wirst. So zum Beispiel die Freude am Kontakt mit Menschen. Oder die Begeisterung für fremde Sprachen. Oder das Arbeiten in der freien Natur und im Team. Oder das Interesse an Technik und die Freude am Handwerk. Je nachdem, wofür du dich interessierst, kannst du bei der Deutschen Bahn aus insgesamt 15 Lehrberufen wählen. Um die richtige Entscheidung zu', null::jsonb, 5.0, null::jsonb, 4),
    ('lv2', '6', 'Die Psychologin der Popper-Schule meint, dass', '[{"key": "A", "text": "besonders intelligente Kinder sich stark von anderen Kindern unterscheiden."}, {"key": "B", "text": "besonders intelligente Schüler dieselben Probleme haben wie andere Kinder."}, {"key": "C", "text": "besonders intelligente Schüler weniger Probleme im alltäglichen Leben haben."}]'::jsonb, 5.0, null::jsonb, 0),
    ('lv2', '7', 'Für überdurchschnittlich intelligente Schüler ist typisch, dass Sie', '[{"key": "A", "text": "auch ohne viel Anstrengung gute Noten haben."}, {"key": "B", "text": "nach der Schule immer großen Erfolg im Beruf haben."}, {"key": "C", "text": "sich die Zeit zum Lernen besser als andere einteilen können."}]'::jsonb, 5.0, null::jsonb, 1),
    ('lv2', '8', 'Im Unterricht der Popper-Schule sollen die Schüler', '[{"key": "A", "text": "immer in einer Fremdsprache miteinander sprechen."}, {"key": "B", "text": "in ihren besten Fächern eine spezielle Betreuung bekommen."}, {"key": "C", "text": "in kleinen Gruppen schwächeren Schülern helfen."}]'::jsonb, 5.0, null::jsonb, 2),
    ('lv2', '9', 'Die erste Zeit in der Popper-Schule war für die Schüler schwer, weil', '[{"key": "A", "text": "sich ihre Noten plötzlich verschlechterten."}, {"key": "B", "text": "sie auf einmal viel mehr Zeit mit Lernen verbringen mussten."}, {"key": "C", "text": "sie noch nicht wussten, welche besonderen Talente sie hatten."}]'::jsonb, 5.0, null::jsonb, 3),
    ('lv3', '11', 'Sie suchen für Ihre beiden Kinder neue Betten und möchten höchstens 200 Euro ausgeben.', null::jsonb, 2.5, null::jsonb, 0),
    ('lv3', '12', 'Sie haben Probleme mit dem Rücken und suchen ein Gesundheitsbett.', null::jsonb, 2.5, null::jsonb, 1),
    ('lv3', '13', 'Sie suchen ein schönes Sofa, das man auch als Gästebett benutzen kann.', null::jsonb, 2.5, null::jsonb, 2),
    ('lv3', '14', 'Vor Ihre Urlaubsreise möchten Sie Ihr Fahrrad überprüfen lassen.', null::jsonb, 2.5, null::jsonb, 3),
    ('lv3', '15', 'Ihre Freunde möchten eine organisierte Radtour machen und suchen ein geeignetes Angebot.', null::jsonb, 2.5, null::jsonb, 4),
    ('lv3', '16', 'Ihre Verwandten haben eine Woche Urlaub und suchen einen Ferienort am Meer.', null::jsonb, 2.5, null::jsonb, 5),
    ('sb1', '21', 'Sehr geehrter Herr Schmidt, im Januar hatte ich bei (21) für mich und meine Familie einen Flug nach Indien …', '[{"key": "A", "text": "ihnen"}, {"key": "B", "text": "Ihnen"}, {"key": "C", "text": "Sie"}]'::jsonb, 1.5, null::jsonb, 0),
    ('sb1', '22', '… gebucht. Leider entsprach unser Flug überhaupt nicht dem, (22)bei der Buchung am Telefon ausgemacht worden war. (23) ich …', '[{"key": "A", "text": "das"}, {"key": "B", "text": "was"}, {"key": "C", "text": "wie"}]'::jsonb, 1.5, null::jsonb, 1),
    ('sb1', '24', '… nach Mumbai bestellt hatte, haben Sie mir einen Flug (24) Zwischenstopp in Delhi ausgestellt. Wir mussten eine …', '[{"key": "A", "text": "für"}, {"key": "B", "text": "mit"}, {"key": "C", "text": "zu"}]'::jsonb, 1.5, null::jsonb, 2),
    ('sb1', '25', '… Wir mussten eine Nacht in Delhi verbringen und kamen so (25) einen Tag später als geplant in Mumbai an. Doch damit …', '[{"key": "A", "text": "erst"}, {"key": "B", "text": "nach"}, {"key": "C", "text": "seit"}]'::jsonb, 1.5, null::jsonb, 3),
    ('sb1', '27', '… anders als vereinbart, (26) auch noch viel teurer. statt (27) erwarteten 640 Euro kostete der Flug 720 Euro. Ich darf …', '[{"key": "A", "text": "der"}, {"key": "B", "text": "deren"}, {"key": "C", "text": "die"}]'::jsonb, 1.5, null::jsonb, 4),
    ('sb1', '28', '… 640 Euro kostete der Flug 720 Euro. Ich darf Sie daher (28) Rückzahlung der zu viel verrechneten Kosten auf mein …', '[{"key": "A", "text": "für"}, {"key": "B", "text": "um"}, {"key": "C", "text": "zu"}]'::jsonb, 1.5, null::jsonb, 5),
    ('sb1', '30', '… Ich bitte Sie, die Angelegenheit bald zu klären und (30) dann zu antworten.Mit freundlichen Grüßen Harish Khurana', '[{"key": "A", "text": "mich"}, {"key": "B", "text": "mir"}, {"key": "C", "text": "sich"}]'::jsonb, 1.5, null::jsonb, 6),
    ('sb2', '31', '… Die meisten Empfehlungen sind aber nicht für etwas, (31) gegen etwas, und zwar immer wieder gegen etwas anderes: …', null::jsonb, 1.5, null::jsonb, 0),
    ('sb2', '32', '… zum Beispiel oder gegen Zucker, aber auch gegen Milch. so (32) man etwa, wer kein Fleisch isst, lebt nicht nur gesünder, …', null::jsonb, 1.5, null::jsonb, 1),
    ('sb2', '33', '… lebt nicht nur gesünder, sondern fühlt sich auch besser. (33) Durchsehen einer Zeitschrift ist mir Ihre Anzeige …', null::jsonb, 1.5, null::jsonb, 2),
    ('sb2', '34', '… aufgefallen, und nun habe ich folgende Fragen an Sie: Von (34) Nahrungsmitteln darf man eigentlich so viel essen, wie …', null::jsonb, 1.5, null::jsonb, 3),
    ('sb2', '35', '… darf man eigentlich so viel essen, wie man will? Was (35) jeden Tag gegessen werden? Und wie ist das mit der Milch? …', null::jsonb, 1.5, null::jsonb, 4),
    ('sb2', '36', '… das mit der Milch? Die einen sagen, Milch ist sehr gesund (36) der vielen wichtigen Nährstoffe. Andere meinen, wer viel …', null::jsonb, 1.5, null::jsonb, 5),
    ('sb2', '37', '… mit dem Magen bekommen. Außerdem kann man anstelle (37) Milch auch Mineralwasser trinken. Was soll ich jetzt …', null::jsonb, 1.5, null::jsonb, 6),
    ('sb2', '38', '… trinken. Was soll ich jetzt glauben? Für eine Antwort (38) meine Fragen danke ich Ihnen im Voraus. Könnten Sie mir …', null::jsonb, 1.5, null::jsonb, 7),
    ('sb2', '39', '… noch eine Broschüre schicken? Das Thema Essen und Sport (39) mich besonders interessieren, (40) ich selber viel Sport …', null::jsonb, 1.5, null::jsonb, 8),
    ('sb2', '40', '… Thema Essen und Sport (39) mich besonders interessieren, (40) ich selber viel Sport treibe. Mit freundlichen Grüßen …', null::jsonb, 1.5, null::jsonb, 9),
    ('hv1', '41', 'Der Sprecher hätte gern Urlaub wie die anderen Kinder gemacht.', null::jsonb, 5.0, null::jsonb, 0),
    ('hv1', '42', 'Dem Sprecher hat der Wanderurlaub nicht so gut gefallen.', null::jsonb, 5.0, null::jsonb, 1),
    ('hv1', '43', 'Die Sprecherin hat die Ferien bei Verwandten verbracht.', null::jsonb, 5.0, null::jsonb, 2),
    ('hv1', '44', 'Die Sprecherin hat mit ihren Eltern regelmäßig Fahrradausflüge gemacht.', null::jsonb, 5.0, null::jsonb, 3),
    ('hv1', '45', 'Der Sprecher hat den Urlaub mit den Eltern gemeinsam geplant.', null::jsonb, 5.0, null::jsonb, 4),
    ('hv2', '46', 'Herr Schütz arbeitet erst seit kurzer Zeit als Taxifahrer', null::jsonb, 2.5, null::jsonb, 0),
    ('hv2', '47', 'In der Kleinstadt hatte Herr Schütz keine Geschäftsleute als Kunden.', null::jsonb, 2.5, null::jsonb, 1),
    ('hv2', '48', 'Herr Schütz hat sich schon einmal in einen Fahrgast verliebt.', null::jsonb, 2.5, null::jsonb, 2),
    ('hv2', '49', 'Die Fahrgäste erzählen viel, weil sie den Taxifahrer nicht kennen.', null::jsonb, 2.5, null::jsonb, 3),
    ('hv2', '50', 'Männer sprechen oft über unpersönliche Dinge.', null::jsonb, 2.5, null::jsonb, 4),
    ('hv2', '51', 'Herr Schütz bekommt von den Fahrgästen manchmal auch einen Tipp.', null::jsonb, 2.5, null::jsonb, 5),
    ('hv2', '52', 'In der Freizeit steht Sport für Herrn Schütz an erster Stelle.', null::jsonb, 2.5, null::jsonb, 6),
    ('hv2', '53', 'Beim Schwimmen kann sich Herr Schütz von einem anstrengenden Tag erholen.', null::jsonb, 2.5, null::jsonb, 7),
    ('hv2', '54', 'Herr Schütz hat sich entschieden, nur am Tag Taxi zu fahren.', null::jsonb, 2.5, null::jsonb, 8),
    ('hv2', '55', 'Nach Meinung von Herrn Schütz haben jüngere Taxifahrer weniger Angst, nachts zu an.', null::jsonb, 2.5, null::jsonb, 9),
    ('hv3', '56', 'Der Zug nach Mannheim fährt um 13:14 Uhr ab.', null::jsonb, 5.0, null::jsonb, 0),
    ('hv3', '57', 'Dr. Hoffmann ist um Urlaub unter der Nummer 957 30 75 zu erreichen.', null::jsonb, 5.0, null::jsonb, 1),
    ('hv3', '58', 'Sie können den Film das Leben ist schön um 18: 15 Uhr im Central sehen.', null::jsonb, 5.0, null::jsonb, 2),
    ('hv3', '59', 'Heute Abend beginnt es zu schneien.', null::jsonb, 5.0, null::jsonb, 3),
    ('hv3', '60', 'Katrin hätte am Dreiundzwanzigsten Zeit.', null::jsonb, 5.0, null::jsonb, 4),
    ('sa', 'A', 'Antworten Sie Tamara. Schreiben Sie etwas zu allen vier Punkte:', null::jsonb, 0, '{"minWords": 100, "points": ["Vorschlag zum Treffen", "Jemanden mitbringen", "Frage zur neuen Arbeitsstelle", "Warum Sie nicht geschrieben haben"]}'::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'b1' and t.slug = 'modell-14'
join sections s on s.test_id = t.id and s.section_id = v.section_id
on conflict (section_id, item_id) do update set text = excluded.text, options = excluded.options, points = excluded.points, meta = excluded.meta, sort = excluded.sort;

insert into item_answers (item_id, answer, explanation)
select i.id, v.answer, v.explanation
from (values
    ('lv1', '1', 'J', null),
    ('lv1', '2', 'C', null),
    ('lv1', '3', 'B', null),
    ('lv1', '4', 'I', null),
    ('lv1', '5', 'E', null),
    ('lv2', '6', 'B', null),
    ('lv2', '7', 'A', null),
    ('lv2', '8', 'B', null),
    ('lv2', '9', 'B', null),
    ('lv3', '11', 'C', null),
    ('lv3', '12', 'X', null),
    ('lv3', '13', 'A', null),
    ('lv3', '14', 'L', null),
    ('lv3', '15', 'J', null),
    ('lv3', '16', 'G', null),
    ('sb1', '21', 'B', null),
    ('sb1', '22', 'B', null),
    ('sb1', '24', 'B', null),
    ('sb1', '25', 'A', null),
    ('sb1', '27', 'A', null),
    ('sb1', '28', 'B', null),
    ('sb1', '30', 'B', null),
    ('sb2', '31', 'H', 'Das Wort lautet: SONDERN'),
    ('sb2', '32', 'F', 'Das Wort lautet: SAGT'),
    ('sb2', '33', 'B', 'Das Wort lautet: BEIM'),
    ('sb2', '34', 'M', 'Das Wort lautet: WELCHEN'),
    ('sb2', '35', 'G', 'Das Wort lautet: SOLLTE'),
    ('sb2', '36', 'K', 'Das Wort lautet: WEGEN'),
    ('sb2', '37', 'I', 'Das Wort lautet: VON'),
    ('sb2', '38', 'A', 'Das Wort lautet: AUF'),
    ('sb2', '39', 'N', 'Das Wort lautet: AUF'),
    ('sb2', '40', 'L', 'Das Wort lautet: WEIL'),
    ('hv1', '41', 'r', null),
    ('hv1', '42', 'r', null),
    ('hv1', '43', 'f', null),
    ('hv1', '44', 'f', null),
    ('hv1', '45', 'r', null),
    ('hv2', '46', 'f', null),
    ('hv2', '47', 'r', null),
    ('hv2', '48', 'f', null),
    ('hv2', '49', 'r', null),
    ('hv2', '50', 'f', null),
    ('hv2', '51', 'f', null),
    ('hv2', '52', 'r', null),
    ('hv2', '53', 'f', null),
    ('hv2', '54', 'f', null),
    ('hv2', '55', 'f', null),
    ('hv3', '56', 'r', null),
    ('hv3', '57', 'f', null),
    ('hv3', '58', 'f', null),
    ('hv3', '59', 'f', null),
    ('hv3', '60', 'r', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'b1' and t.slug = 'modell-14'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;

-- ================= modell-15 · JAN =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('b1', 'modell-15', 'JAN', '51 Aufgaben · 150 Minuten',
        '[{"id": "block-lv-sb", "title": "Leseverstehen und Sprachbausteine", "minutes": 90, "hint": "Aufgaben 1–40", "parts": ["lv1", "lv2", "lv3", "sb1", "sb2"], "maxPoints": 105.0, "availablePoints": 80.5, "missing": 9}, {"id": "block-hv", "title": "Hörverstehen", "minutes": 30, "hint": "Aufgaben 41–60", "parts": ["hv1", "hv2", "hv3"], "maxPoints": 75.0, "availablePoints": 72.5, "missing": 1}, {"id": "block-sa", "title": "Schriftlicher Ausdruck", "minutes": 30, "hint": "", "parts": ["sa"], "maxPoints": 45.0, "availablePoints": 45, "missing": 0}]'::jsonb, 51, true, 15)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('lv1', 'Leseverstehen', 'Leseverstehen, Teil 1', 15, 'Lesen Sie die Überschriften a–j und die Texte 1–5. Finden Sie für jeden Text die passende Überschrift. Jede Überschrift passt nur einmal.', 'matching', '{"bank": [{"key": "A", "text": "Hinweis für Besucher der Bregenzer Festspiele"}, {"key": "B", "text": "Abendwanderungen ab 89 Euro"}, {"key": "C", "text": "Musikveranstaltungen am Nachmittag"}, {"key": "D", "text": "Ihre Zeitung folgt Ihnen in den Urlaub"}, {"key": "E", "text": "Schlechtes Wetter: Festspiele abgesagt"}, {"key": "F", "text": "Rekord: 70.000 Besucher im Bücherdorf"}, {"key": "G", "text": "Wandern ohne Gepäck"}, {"key": "H", "text": "Neues für Literaturinteressierte"}, {"key": "I", "text": "Neue Zeitung für Ihre Urlaubsplanung"}, {"key": "J", "text": "Laute Musik stört den Nachbarn"}], "bankTitle": "Überschriften", "maxPoints": 25.0, "availablePoints": 20.0, "missing": 1, "pointsPerItem": 5.0}'::jsonb, 0),
    ('lv2', 'Leseverstehen', 'Leseverstehen, Teil 2', 20, 'Lesen Sie den Text und die Aufgaben 6–10. Welche Lösung (A, B oder C) ist jeweils richtig?', 'mc', '{"passages": [{"paragraphs": [{"t": "5.", "b": false}, {"t": "Die Bregenzer Festspiele sind bemüht, die Vorstellungen auch bei zweifelhafter Witterung bzw. leichtem Regen", "b": false}, {"t": "auf der Seebühne abzuhalten, weshalb es zu Verzögerungen des Beginns oder zu Unterbrechungen kommen", "b": false}, {"t": "kann. Sollte die Seeaufführung nicht stattfinden können, wird eine halbszenische Version von Porgy and Bess im", "b": false}, {"t": "Festspielhaus gegeben. Wir empfehlen unseren Gästen , bei unsicherer Wetterlage regenfester Kleidung den", "b": false}, {"t": "Vorzug zu geben und auf Schirme zu verzichten, da diese die Sicht beeinträchtigen. Das Spiel auf dem See wird", "b": false}, {"t": "ohne Pause gespielt. Die Spieldauer beträgt ca.2 Std. 45 Min.", "b": false}, {"t": "Beruf am Flughafen: Kinderbetreuerin", "b": true}, {"t": "Dem Kind zuliebe in Kloten warten", "b": true}, {"t": "Auf keinem anderen Flughafen sei der Aufenthalt familienfeindlicher als in Kloten, sagen viele Eltern. Weil die Wartezeit im Flug vergeht dank der 18 Kinderbetreuerinnen. Von Gabriella Hofer", "b": false}, {"t": "24000 Kinder aus der ganzen Welt wurden letztes Jahr auf dem Flughafen Zürich-Kloten betreut. Die 18 Mitarbeiterinnen, die sich im Schichtbetrieb ablösen, stehen den Eltern und ihren Kindern täglich von 6.30 bis 22 Uhr mit Rat und Tat zur Seite. Die vielsprachigen Betreuerinnen – viele von ihnen sind ausgebildete Krankenschwestern, Kleinkindererzieherinnen oder Flugbegleiterinnen – verfügen auch über Erste-Hilfe- Kenntnisse. Der Flughafen Zürich-Kloten ist der einzige in Europa, der seinen kleinsten Gästen in beiden Terminals einen eigenen Aufenthaltsraum bietet.", "b": false}, {"t": "Aufenthalt und Betreuung sind kostenlos. In beiden Räumen stehen vier Wickeeltische mit Papierwindeln, eine Küche zum Aufwärmen der Kindermahlzeiten, sechs Bettchen, ein Laufgitter, Nachttöpfe und Toiletten für Kleinkinder zur Verfügung. Außerdem gibt es zahlreiche Stofftierchen, Schaukelpferdchen, Bauklötze, Puppenstuben, einen großen Stall, Bilderbücher, Spiele und vieles mehr.", "b": false}, {"t": "Es ist ein Erlebnis für die Kinder, mit Kindern zu spielen, die eine andere Muttersprache sprechen oder aus einem anderen Kulturkreis kommen, weiß Alice Martin (40). Die ehemalige Kinderschwester, selber Mutter eines sechsjährigen Sohnes, gehört seit 14 Jahren zum Team der Betreuerinnen. Zusammen mit 17 Kolleginnen ist sie abwechselnd in den beiden Kinderspielzimmern den Terminals A und B beschäftigt.", "b": false}, {"t": "Bevor Alice Martin 1994 von der Flughafendirektion angestellt wurde, war sie viele Jahre auf einer Geburtenabteilung und später noch in einem Behindertenheim beschäftigt. Die Kontakte zu den jetzt von ihr betreuten Kindern seinen nicht mehr so intensiv wie früher im Spital oder im Heim, dafür biete ihr die heutige", "b": false}, {"t": "Tätigkeit mehr Abwechslung.", "b": false}, {"t": "Die kinderliebende Frau reist selber gern und viel. Auch ihre Fremdsprachenkenntnisse kommen ihr hier zugute. Alice Martin spricht neben ihrer Muttersprache Englisch, Französisch und Spanisch. Sehr bereichernd sei, dass sie in ihrer täglichen Arbeit andere Kulturen kennenlerne.", "b": false}]}], "maxPoints": 25.0, "availablePoints": 20.0, "missing": 1, "pointsPerItem": 5.0}'::jsonb, 1),
    ('lv3', 'Leseverstehen', 'Leseverstehen, Teil 3', 20, 'Lesen Sie die Situationen 11–20 und die Anzeigen im Bild. Finden Sie für jede Situation die passende Anzeige. Wenn Sie keine passende Anzeige finden, wählen Sie X.', 'matching', '{"bank": [{"key": "A", "text": ""}, {"key": "B", "text": ""}, {"key": "C", "text": ""}, {"key": "D", "text": ""}, {"key": "E", "text": ""}, {"key": "F", "text": ""}, {"key": "G", "text": ""}, {"key": "H", "text": ""}, {"key": "I", "text": ""}, {"key": "J", "text": ""}, {"key": "K", "text": ""}, {"key": "L", "text": ""}, {"key": "X", "text": ""}], "bankTitle": "Anzeigen", "bankImage": "img/m15-lv3.jpg", "maxPoints": 25.0, "availablePoints": 15.0, "missing": 4, "pointsPerItem": 2.5}'::jsonb, 2),
    ('sb1', 'Sprachbausteine', 'Sprachbausteine, Teil 1', 20, 'Lesen Sie den Text und schließen Sie die Lücken 21–30. Welche Lösung (A, B oder C) ist jeweils richtig?', 'mc', '{"passages": [{"paragraphs": [{"t": "An alle Kunden Gewinnen", "b": true}, {"t": "Sehr geehrter Herr Schröder,", "b": true}, {"t": "zum Start (21) das neue Geschäftsjahre haben wir uns für Sie etwas ganz Besonders ausgedacht: einen", "b": false}, {"t": "attraktiven Gewinn! (22) dem Beginn des neuen Geschäftsjahres feiern wir unsere erfolgreiche Buchidee.", "b": false}, {"t": "Machen Sie mit! Es warten auf Sie sehr (23) Gewinne im Wert von vielen Tausend Euro. Mit ihrer", "b": false}, {"t": "Kundennummer können Sie an einem Preisausschreiben teilnehmen. Senden Sie uns (24) das beigefügte", "b": false}, {"t": "Antwortschreiben zurück und bestellen Sie damit – ohne Risiko – das Buch des Monats. Sie erhalten dieses", "b": false}, {"t": "Buch mit (25) versprechen, es nach 10 Tage zurückgeben zu können, sollte Ihnen das Buch nicht gefallen.", "b": false}, {"t": "Ohne irgendetwas zu zahlen! Behalten Sie das Buch, was wir (26) hoffen, zahlen Sie nur 50 Prozent des sonst", "b": false}, {"t": "üblichen Preises in einer Buchhandlung. Gleichzeitig nehmen Sie an einem Preisausschreiben (27).", "b": false}, {"t": "Bitte bedanken Sie: sollte Ihre Kundennummer(28) den richtigen Zahlen sein, haben Sie die Chance, ein Auto", "b": false}, {"t": "eine Reise und viele weitere Preise zu erhalten. Antworten Sie (29) noch diese Woche! Dann haben Sie in jedem Fall die Chance auf den Hauptgewinn - einen Mercedes der S-Klasse. Wenn Sie innerhalb der", "b": false}, {"t": "kommenden vier Wochen antworten, nehmen Sie immer(30) an unserer Gewinnverteilung teil –", "b": false}, {"t": "vorausgesetzt, Sie haben die richtige Kundennummer.", "b": false}, {"t": "Mit freundlichen Grüßen", "b": false}, {"t": "Petra Obermoser", "b": false}, {"t": "Leiterin der Abteilung Marketing", "b": false}]}], "maxPoints": 15.0, "availablePoints": 10.5, "missing": 3, "pointsPerItem": 1.5}'::jsonb, 3),
    ('sb2', 'Sprachbausteine', 'Sprachbausteine, Teil 2', 15, 'Lesen Sie den Text und schließen Sie die Lücken 31–40. Benutzen Sie die Wörter aus der Liste. Jedes Wort passt nur einmal.', 'wordbank', '{"bank": [{"key": "A", "text": "ALS"}, {"key": "B", "text": "ANFANGEN"}, {"key": "C", "text": "ARBEITEN"}, {"key": "D", "text": "ERZÄHLT"}, {"key": "E", "text": "FALLS"}, {"key": "F", "text": "INFORMIERT"}, {"key": "G", "text": "INTERESSIERT"}, {"key": "H", "text": "MÖCHTEN"}, {"key": "I", "text": "MÖGLICH"}, {"key": "J", "text": "NUR"}, {"key": "K", "text": "ÖFTER"}, {"key": "L", "text": "UNBEKANNT"}, {"key": "M", "text": "VOR"}, {"key": "N", "text": "WÜRDE"}, {"key": "O", "text": "ZWISCHEN"}], "bankTitle": "Wörterliste", "passages": [{"paragraphs": [{"t": "B B", "b": false}, {"t": "Zwischen unseren vor", "b": false}, {"t": "C C", "b": false}, {"t": "A . A .", "b": false}, {"t": "23. schöne 26 natürlich 29 A bald", "b": false}, {"t": "schönen schön bereits", "b": false}, {"t": "schönes viele unbedingt", "b": false}, {"t": "C C", "b": false}, {"t": ") (", "b": false}, {"t": "Neuendorf, den….", "b": false}, {"t": "Sehr geehrte Frau Bauer,", "b": false}, {"t": "ich habe Ihre Anzeige in der Neuen Presse gelesen und bin an dem Filmprojekt sehr (31).", "b": false}, {"t": "ich war schon (32) für einige Wochen im Ausland. Vor allem im Sommer habe ich während meines Studiums", "b": false}, {"t": "viele Sprachkurse besucht. Länger als ein halbes Jahr habe ich (33) einmal im Ausland gelebt, und zwar (34)", "b": false}, {"t": "zwei Jahren. Mein Chef machte mir damals das Angebot, acht Monate im Tochterunternehmen der Firma in", "b": false}, {"t": "Portugal zu (35) , was ich dann auch getan habe.", "b": false}, {"t": "Am Anfang war es sehr schwer, weil ich niemanden kannte und alles sehr neu und (36) für mich war.", "b": false}, {"t": "Eigentlich wollte ich so schnell wie (37) wieder zurück. Aber dann habe ich nette Kollegen kennen gelernt, die", "b": false}, {"t": "mir auch über die Kultur und das Leben in Portugal (38) haben.", "b": false}, {"t": "Ich glaube, dass meine Erfahrungen für viele andere Menschen, die auch im Ausland leben wollen, sehr", "b": false}, {"t": "interessant sein könnten, und ich (39) gerne auch vor der Kamera darüber erzählen. (40) Sie noch weitere", "b": false}, {"t": "Fragen an mich haben, können Sie mich gerne anrufen, meine Telefonnummer ist 07612/64788980.", "b": false}, {"t": "Ich würde mich freuen, bald von Ihnen zu hören.", "b": false}, {"t": "Mit freundlichen Grüßen", "b": false}, {"t": "KAROLINE POINTNER", "b": false}]}], "maxPoints": 15.0, "availablePoints": 15.0, "missing": 0, "pointsPerItem": 1.5}'::jsonb, 4),
    ('hv1', 'Hörverstehen', 'Hörverstehen, Teil 1', 8, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 5),
    ('hv2', 'Hörverstehen', 'Hörverstehen, Teil 2', 14, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 22.5, "missing": 1, "pointsPerItem": 2.5}'::jsonb, 6),
    ('hv3', 'Hörverstehen', 'Hörverstehen, Teil 3', 8, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 7),
    ('sa', 'Schriftlicher Ausdruck', 'Schriftlicher Ausdruck', 30, 'Antworten Sie Jan. Schreiben Sie etwas zu allen vier Punkte:', 'writing', '{"brief": {"intro": "Ihr Freund Jan hat Ihnen folgende E-Mail geschrieben:", "greeting": "Liebe(r)........", "paragraphs": ["Ich sende Dir ganz viele Grüße aus Rom! Du weißt ja, wie sehr mir diese Stadt gefällt. Ich bin hier von morgens bis abends nur unterwegs. Diese Museen, Parks Plätze und natürlich das Essen – wunderbar! Gestern Abend war ich übrigens in einem Rockkonzert. Ich fand die Musik ganz toll und die Stimmung war super.", "Doch Leider ist mein Urlaub schon fast vorbei und in drei Tagen muss ich wieder zurück nach Deutschland. Welche Stadt ist eigentlich Deine Lieblingsstadt? Hast du schon Pläne für Deinen nächsten Urlaub? Vielleicht können wir uns ja mal wieder treffen.", "Herzliche Grüße"], "signature": "Jan"}, "hints": [], "criteria": [{"title": "Aufgabenbewältigung", "hint": "Sind alle vier Leitpunkte inhaltlich angemessen bearbeitet?"}, {"title": "Kommunikative Gestaltung", "hint": "Anrede, Gruß, passendes Register und verbundene Sätze statt aneinandergereihter Punkte?"}, {"title": "Formale Richtigkeit", "hint": "Stören Fehler in Grammatik, Wortschatz und Rechtschreibung das Verstehen?"}], "grades": [{"key": "A", "points": 5}, {"key": "B", "points": 3}, {"key": "C", "points": 1}, {"key": "D", "points": 0}], "factor": 3, "maxPoints": 45, "availablePoints": 45, "missing": 0}'::jsonb, 8)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'b1' and t.slug = 'modell-15'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('lv1', '1', 'Abonnenten-Service Wenn Sie verreisen, wünschen wir ihnen erholsame und angenehme Ferienlage Bitte denken Sie daran, sich ihre Zeitung in den Urlaubtort nachsenden zu lassen. Denn mit den Neuigkeiten von zu Hause und aus aller Weil lässt sich die schönste Zeit des Jahres erst richtig genießen ganz Europa kostenlos, Die Höhe des Bezeugendes bleibt unverändert. Ausführliche Informationen und entsprechende Coupons ihrem Europabericht. Griechisch wird meistens von Zwölftklässlern als dritte Fremdsprache neben Französisch und Englisch gewählt. finden Sie in unserem großen Reise Service – Anzeigen oder rufen Sie uns einfach an: Telefon 01 30-18 58 50 zum Nulltarif. Hannoversche Allgemeine Neue Presse', null::jsonb, 5.0, null::jsonb, 0),
    ('lv1', '2', 'Im Luftkurort Stadtkylf in der Mittelgebirgslandschaft des Oberen Kullas werden dreitägige Wanderungen ohne Gepäck veranstaltet Die Rundwanderung im deutsch – bei gischen Naturpark führt abends zu reservierten Zimmern. Die Betriebe übernehmen den Gepäcktransport zum nächsten Tagesziel. Die Wanderungen werden ganzjährig angeboten. In den Wanderprogramm sind drei Übernachtungen mit Frühstück dreimal Gepäcktransport, eine Wanderkarte, eine Wegbeschreibung und ein Wanderpass enthalten. Der Pauschalbetrag beträgt pro Person 89 Euro. Auskünfte: Verkehrsverein Erholungsgebiet Oberes Kylltal. Kurallee, 54589 Stadtkylf, Telefon ( 06597) 28 78.', null::jsonb, 5.0, null::jsonb, 1),
    ('lv1', '3', 'Für den einen ist es musikalischer Hochgenuss für den anderen schlicht Lärm. Gemeint ist Musik, die aus Lautsprechen, Radios oder durch Musikinstrumente durch geöffnet Türen und Fenster bei sommerlichen Temperaturen ins Freie dringt. Die Gemeinde weist darauf hin, dass der Mittagsruhe von 13 bis 15 Uhr und nachts von 22 bis 7 Uhr keine musikalische Ruhestörung erfolgen darf. Gartengeräte mit Motoren dürfen montags bis freitags nur von 8 bis 13 und von 15 bis 19 Uhr benutzt werden, an Sonnabenden von 9 bis 13 Uhr. An Sonn - und Feiertagen dürfen die Geräte nicht zum Einsatz kommen.', null::jsonb, 5.0, null::jsonb, 2),
    ('lv1', '4', '– Das erste deutsche Bücherdorf hat in Mühlbeck/ Fredersdorf (Sachsen Anhalt ) seit Ende September seine Tore geöffnet. In acht Antiquarten warten über 70 000 Bücher aus alleen Bereichen der Literatur auf Interessenten. Das in reizvoller landschaftlicher Umgebung liegende Bücherdorf nahe Bitterfeld - unweit der A19 und des Flughafens Leipzig - ist aus allen Teilen Deutschlands leicht zu erreich. Geöffnet sind die Antiquariate auch am Samstag und Sonntag. In Europa gibt es bereits acht solcher Bücherdörfer in Belgien, Frankreich, Großbritannien, den Niederlanden, Norwegen und der Schweiz. Initiatorin des deutschen Bücherdorfes ist Heidi Dehne (Tel. 03493/4 30 43).', null::jsonb, 5.0, null::jsonb, 3),
    ('lv2', '6', 'Die Kinderbetreuerinnen kümmern sich um', '[{"key": "A", "text": "Kinder, die auf dem Flughafen warten müssen."}, {"key": "B", "text": "Kinder, die im Flugzeug krank wurden.."}, {"key": "C", "text": "Kinder, die ohne Eltern fliegen müssen."}]'::jsonb, 5.0, null::jsonb, 0),
    ('lv2', '7', 'Die Flughafen Zürich-Kloten ist besonders familienfreundlich,', '[{"key": "A", "text": "seit Alice Martin dort arbeitet."}, {"key": "B", "text": "weil die Wartezeit kürzer ist als auf anderen Flughäfen."}, {"key": "C", "text": "weil es Räume gibt, in denen Kinder spielen können"}]'::jsonb, 5.0, null::jsonb, 1),
    ('lv2', '8', 'Frau Alice Martin hat eine Ausbildung als', '[{"key": "A", "text": "Flugbegleiterin."}, {"key": "B", "text": "Kinderschwester."}, {"key": "C", "text": "Pilotin."}]'::jsonb, 5.0, null::jsonb, 2),
    ('lv2', '9', 'In den Aufenthaltsräumen spielen die Kinder', '[{"key": "A", "text": "am liebsten mit 18 Betreuerinnen."}, {"key": "B", "text": "am liebsten mit Alice Martin."}, {"key": "C", "text": "auch mit Kindern anderer Kulturen und Sprachen."}]'::jsonb, 5.0, null::jsonb, 3),
    ('lv3', '11', 'Sie sind in der Schweiz und möchten sich ein paar Tage beim Baden erholen.', null::jsonb, 2.5, null::jsonb, 0),
    ('lv3', '12', 'Sie hören gerne klassische Musik, am liebsten Barocklieder. Sie möchten in ein Konzert gehen.', null::jsonb, 2.5, null::jsonb, 1),
    ('lv3', '13', 'Ihr Sohn möchte gerne in den Schulfeien seinen Fremdsprachenkenntnisse verbessern.. Er möchte auch Sport treiben.', null::jsonb, 2.5, null::jsonb, 2),
    ('lv3', '14', 'Sie reisen nicht gerne allein und suchen deshalb Reisepartner.', null::jsonb, 2.5, null::jsonb, 3),
    ('lv3', '15', 'Sie möchten am Donnerstag Abend mit Ihrer Bekannten eine Musikveranstaltung besuchen.', null::jsonb, 2.5, null::jsonb, 4),
    ('lv3', '16', 'Ihre Familie möchte den nächsten Urlaub am Meer verbringen.', null::jsonb, 2.5, null::jsonb, 5),
    ('sb1', '21', '… Kunden Gewinnen Sehr geehrter Herr Schröder, zum Start (21) das neue Geschäftsjahre haben wir uns für Sie etwas ganz …', '[{"key": "A", "text": "auf"}, {"key": "B", "text": "in"}, {"key": "C", "text": "über"}]'::jsonb, 1.5, null::jsonb, 0),
    ('sb1', '22', '… ganz Besonders ausgedacht: einen attraktiven Gewinn! (22) dem Beginn des neuen Geschäftsjahres feiern wir unsere …', '[{"key": "A", "text": "Mit"}, {"key": "B", "text": "Von"}]'::jsonb, 1.5, null::jsonb, 1),
    ('sb1', '24', '… Sie an einem Preisausschreiben teilnehmen. Senden Sie uns (24) das beigefügte Antwortschreiben zurück und bestellen Sie …', '[{"key": "A", "text": "einfach"}, {"key": "B", "text": "immer"}, {"key": "C", "text": "noch"}]'::jsonb, 1.5, null::jsonb, 2),
    ('sb1', '25', '… – das Buch des Monats. Sie erhalten dieses Buch mit (25) versprechen, es nach 10 Tage zurückgeben zu können, …', '[{"key": "A", "text": "unsere"}, {"key": "B", "text": "unserem"}]'::jsonb, 1.5, null::jsonb, 3),
    ('sb1', '27', '… Gleichzeitig nehmen Sie an einem Preisausschreiben (27). Bitte bedanken Sie: sollte Ihre Kundennummer(28) den …', '[{"key": "A", "text": "mit"}, {"key": "B", "text": "teil"}, {"key": "C", "text": "zu"}]'::jsonb, 1.5, null::jsonb, 4),
    ('sb1', '28', '… (27). Bitte bedanken Sie: sollte Ihre Kundennummer(28) den richtigen Zahlen sein, haben Sie die Chance, ein Auto …', '[{"key": "A", "text": "unter"}, {"key": "B", "text": "neben"}]'::jsonb, 1.5, null::jsonb, 5),
    ('sb1', '30', '… der kommenden vier Wochen antworten, nehmen Sie immer(30) an unserer Gewinnverteilung teil – vorausgesetzt, Sie …', '[{"key": "A", "text": "noch"}, {"key": "B", "text": "schon"}, {"key": "C", "text": "schnell"}]'::jsonb, 1.5, null::jsonb, 6),
    ('sb2', '31', '… der Neuen Presse gelesen und bin an dem Filmprojekt sehr (31). ich war schon (32) für einige Wochen im Ausland. Vor …', null::jsonb, 1.5, null::jsonb, 0),
    ('sb2', '32', '… und bin an dem Filmprojekt sehr (31). ich war schon (32) für einige Wochen im Ausland. Vor allem im Sommer habe …', null::jsonb, 1.5, null::jsonb, 1),
    ('sb2', '33', '… Sprachkurse besucht. Länger als ein halbes Jahr habe ich (33) einmal im Ausland gelebt, und zwar (34) zwei Jahren. Mein …', null::jsonb, 1.5, null::jsonb, 2),
    ('sb2', '34', '… Jahr habe ich (33) einmal im Ausland gelebt, und zwar (34) zwei Jahren. Mein Chef machte mir damals das Angebot, …', null::jsonb, 1.5, null::jsonb, 3),
    ('sb2', '35', '… Monate im Tochterunternehmen der Firma in Portugal zu (35) , was ich dann auch getan habe. Am Anfang war es sehr …', null::jsonb, 1.5, null::jsonb, 4),
    ('sb2', '36', '… schwer, weil ich niemanden kannte und alles sehr neu und (36) für mich war. Eigentlich wollte ich so schnell wie (37) …', null::jsonb, 1.5, null::jsonb, 5),
    ('sb2', '37', '… (36) für mich war. Eigentlich wollte ich so schnell wie (37) wieder zurück. Aber dann habe ich nette Kollegen kennen …', null::jsonb, 1.5, null::jsonb, 6),
    ('sb2', '38', '… die mir auch über die Kultur und das Leben in Portugal (38) haben. Ich glaube, dass meine Erfahrungen für viele …', null::jsonb, 1.5, null::jsonb, 7),
    ('sb2', '39', '… leben wollen, sehr interessant sein könnten, und ich (39) gerne auch vor der Kamera darüber erzählen. (40) Sie noch …', null::jsonb, 1.5, null::jsonb, 8),
    ('sb2', '40', '… und ich (39) gerne auch vor der Kamera darüber erzählen. (40) Sie noch weitere Fragen an mich haben, können Sie mich …', null::jsonb, 1.5, null::jsonb, 9),
    ('hv1', '41', 'Die Sprecherin ist dagegen, dass Kinder so früh eine Fremdsprache lernen.', null::jsonb, 5.0, null::jsonb, 0),
    ('hv1', '42', 'Die Sprecherin meint, dass das frühe Lernen einer Fremdsprache für viele Kinder Nachteile hat.', null::jsonb, 5.0, null::jsonb, 1),
    ('hv1', '43', 'Der Sprecher findet es schade, dass er im Kindergarten keine Fremdsprache lernen konnte.', null::jsonb, 5.0, null::jsonb, 2),
    ('hv1', '44', 'Die Sprecherin meint, dass das Fremdsprachenlernen erst in der Schule beginnen sollte.', null::jsonb, 5.0, null::jsonb, 3),
    ('hv1', '45', 'Der Sprecher ist dagegen, dass Kinder schon früh Fremdsprache lernen.', null::jsonb, 5.0, null::jsonb, 4),
    ('hv2', '46', 'In Deutschland gibt es immer mehr Organisationen, die sich um alte und kranke Menschen.', null::jsonb, 2.5, null::jsonb, 0),
    ('hv2', '47', 'Die Spitex hat versorgt alte oder kranke Menschen im Krankenhaus.', null::jsonb, 2.5, null::jsonb, 1),
    ('hv2', '48', 'Die Spitex hat zwei große Aufgabenbereiche.', null::jsonb, 2.5, null::jsonb, 2),
    ('hv2', '49', 'Es gibt Aufgaben, die nur von einer Krankenschwester gemacht werden dürfen.', null::jsonb, 2.5, null::jsonb, 3),
    ('hv2', '50', 'Die Spitex kümmert sich nur um alte Leute.', null::jsonb, 2.5, null::jsonb, 4),
    ('hv2', '51', 'Die Spitex bekommt Geld von den Krankenkassen.', null::jsonb, 2.5, null::jsonb, 5),
    ('hv2', '52', 'Die Krankenkassen geben den größten Teil ihres Geldes für die Spitex aus.', null::jsonb, 2.5, null::jsonb, 6),
    ('hv2', '53', 'Herr Maurer findet den Preis pro Stunde in Ordnung.', null::jsonb, 2.5, null::jsonb, 7),
    ('hv2', '54', 'Die Spitex ist in der ganzen Schweiz eine private Organisation.', null::jsonb, 2.5, null::jsonb, 8),
    ('hv3', '56', 'Der Fahrer des Wagens mit dem Kennzeichen HB-D 256 soll ins Erdgeschoss kommen.', null::jsonb, 5.0, null::jsonb, 0),
    ('hv3', '57', 'Die Firma liefert das bestellte Sofa am Dienstagnachmittag zwischen drei und sechs Uhr liefern.', null::jsonb, 5.0, null::jsonb, 1),
    ('hv3', '58', 'Der Gasthof Lindner liegt neben einer Tankstelle.', null::jsonb, 5.0, null::jsonb, 2),
    ('hv3', '59', 'Der Film Komiker wird mehrmals am Tag gezeigt.', null::jsonb, 5.0, null::jsonb, 3),
    ('hv3', '60', 'Für den Abend wird kein Regen erwartet.', null::jsonb, 5.0, null::jsonb, 4),
    ('sa', 'A', 'Antworten Sie Jan. Schreiben Sie etwas zu allen vier Punkte:', null::jsonb, 0, '{"minWords": 100, "points": ["Ihre Lieblingsstadt", "Welche Musik Sie mögen", "Ihre Pläne für den nächsten Urlaub", "Treffen mit Jan?"]}'::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'b1' and t.slug = 'modell-15'
join sections s on s.test_id = t.id and s.section_id = v.section_id
on conflict (section_id, item_id) do update set text = excluded.text, options = excluded.options, points = excluded.points, meta = excluded.meta, sort = excluded.sort;

insert into item_answers (item_id, answer, explanation)
select i.id, v.answer, v.explanation
from (values
    ('lv1', '1', 'D', null),
    ('lv1', '2', 'G', null),
    ('lv1', '3', 'J', null),
    ('lv1', '4', 'H', null),
    ('lv2', '6', 'A', null),
    ('lv2', '7', 'C', null),
    ('lv2', '8', 'B', null),
    ('lv2', '9', 'C', null),
    ('lv3', '11', 'D', null),
    ('lv3', '12', 'H', null),
    ('lv3', '13', 'I', null),
    ('lv3', '14', 'E', null),
    ('lv3', '15', 'A', null),
    ('lv3', '16', 'X', null),
    ('sb1', '21', 'B', null),
    ('sb1', '22', 'A', null),
    ('sb1', '24', 'A', null),
    ('sb1', '25', 'B', null),
    ('sb1', '27', 'B', null),
    ('sb1', '28', 'B', null),
    ('sb1', '30', 'A', null),
    ('sb2', '31', 'G', 'Das Wort lautet: INTERESSIERT'),
    ('sb2', '32', 'K', 'Das Wort lautet: ÖFTER'),
    ('sb2', '33', 'J', 'Das Wort lautet: NUR'),
    ('sb2', '34', 'M', 'Das Wort lautet: VOR'),
    ('sb2', '35', 'C', 'Das Wort lautet: ARBEITEN'),
    ('sb2', '36', 'L', 'Das Wort lautet: UNBEKANNT'),
    ('sb2', '37', 'I', 'Das Wort lautet: MÖGLICH'),
    ('sb2', '38', 'D', 'Das Wort lautet: ERZÄHLT'),
    ('sb2', '39', 'N', 'Das Wort lautet: WÜRDE'),
    ('sb2', '40', 'E', 'Das Wort lautet: FALLS'),
    ('hv1', '41', 'f', null),
    ('hv1', '42', 'r', null),
    ('hv1', '43', 'f', null),
    ('hv1', '44', 'r', null),
    ('hv1', '45', 'r', null),
    ('hv2', '46', 'r', null),
    ('hv2', '47', 'r', null),
    ('hv2', '48', 'f', null),
    ('hv2', '49', 'r', null),
    ('hv2', '50', 'f', null),
    ('hv2', '51', 'f', null),
    ('hv2', '52', 'r', null),
    ('hv2', '53', 'r', null),
    ('hv2', '54', 'f', null),
    ('hv3', '56', 'r', null),
    ('hv3', '57', 'f', null),
    ('hv3', '58', 'r', null),
    ('hv3', '59', 'r', null),
    ('hv3', '60', 'f', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'b1' and t.slug = 'modell-15'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;

-- ================= modell-16 · VIKTOR =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('b1', 'modell-16', 'VIKTOR', '45 Aufgaben · 150 Minuten',
        '[{"id": "block-lv-sb", "title": "Leseverstehen und Sprachbausteine", "minutes": 90, "hint": "Aufgaben 1–40", "parts": ["lv1", "lv2", "lv3", "sb1", "sb2"], "maxPoints": 105.0, "availablePoints": 76.0, "missing": 13}, {"id": "block-hv", "title": "Hörverstehen", "minutes": 30, "hint": "Aufgaben 41–60", "parts": ["hv1", "hv2", "hv3"], "maxPoints": 75.0, "availablePoints": 62.5, "missing": 3}, {"id": "block-sa", "title": "Schriftlicher Ausdruck", "minutes": 30, "hint": "", "parts": ["sa"], "maxPoints": 45.0, "availablePoints": 45, "missing": 0}]'::jsonb, 45, true, 16)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('lv1', 'Leseverstehen', 'Leseverstehen, Teil 1', 15, 'Lesen Sie die Überschriften a–j und die Texte 1–5. Finden Sie für jeden Text die passende Überschrift. Jede Überschrift passt nur einmal.', 'matching', '{"bank": [{"key": "A", "text": "Nur wenige lesen im Zug"}, {"key": "B", "text": "Bahnfahren bei älteren Menschen immer beliebter"}, {"key": "C", "text": "Per Internet leichter ans Ziel"}, {"key": "D", "text": "Männer fahren besser"}, {"key": "E", "text": "Hilfe beim Reisen mit der Bahn"}, {"key": "F", "text": "Frauen finden den richtigen Weg"}, {"key": "G", "text": "Neuer Deutschkurs in Solothurn"}, {"key": "H", "text": "Jetzt wird auch im Zug gelernt"}, {"key": "I", "text": "Lesen im Zug ist beliebt"}], "bankTitle": "Überschriften", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 0),
    ('lv2', 'Leseverstehen', 'Leseverstehen, Teil 2', 20, 'Lesen Sie den Text und die Aufgaben 6–10. Welche Lösung (A, B oder C) ist jeweils richtig?', 'mc', '{"passages": [{"paragraphs": [{"t": "Weg von einer Adresse zu einer anderen möglich. Der elektronische Fahrplan führt Sie", "b": false}, {"t": "automatisch zum Haltepunkt des öffentlichen Verkehrs der am nächsten bei der Zieladresse", "b": false}, {"t": "liegt. Das ist mit dem Verkehrsleitssystem für Autos vergleichbar, das Sie aber auch in der", "b": false}, {"t": "Verkehrten Richtung durch Einbahnstraßen führen kann. Beim öffentlichen Verkehr kommt", "b": false}, {"t": "das glücklicherweise nicht vor.", "b": false}, {"t": "ist jeweils richtig?", "b": false}, {"t": "Neue Berufe", "b": true}, {"t": "Raumberater für harmonisches Wohnen", "b": true}, {"t": "Räume nach der chinesischen Lehre Feng Shui zu gestalten, damit sich die Menschen wohl Fühlen das ist der Beruf von Iris Eigenmann", "b": false}, {"t": "Seit knapp einem Jahr bin ich nun selbstständig und bin voller Energie. So stehe ich jeden Tag mit einem Lächeln auf und gehe abends wieder mit einem Lächeln ins Bett. Die diplomierte Raumberaterin Iris Eigenmann ist von ihrem Beruf sichtlich begeistert. Da viele mit dem Wort Fengshui nichts anfangen können, bezeichnet sie sich selbst als Raumberaterin für harmonisches Wohnungen aber auch Büros und andere Arbeitsplätze so einzurichten, dass sich Menschen in diesen Räumen wohl fühlen können.", "b": false}, {"t": "Ursprünglich ist Frau Eigenmann gelernte Hochbauzeichnerin und hat Jahrelang Bauprojekte geleitet. Diese Erfahrungen mit Architektur und Wohnbau helfen ihr nun sehr bei ihrer Tätigkeit als Raumberaterin. Ihre Arbeit besteht darin, den optimalen Energiefluss eines Wohn- oder Arbeitsumfeldes zu finden. Sie macht individuelle Vorschläge für die Raumanordnung, die Farbwahl der Wände oder für die Verwendung von Baumaterialien. Ich habe alle Ideen zuerst bei mir zu Hause ausprobiert und war selbst überrascht von der positiven Wirkung, erzählt sie begeistert.", "b": false}, {"t": "Eine Raumberaterin arbeitet in der Regel folgendermaßen: Zuerst besprechen die Leute mit Frau Eigenmann, warum sie sich in ihrer Wohnung nicht wohl fühlen und wie sie ihren Wohnraum verbessen möchten. Dann bittet die Beraterin ihre Kunden, ihr einen genauen Plan der Wohnung zu schicken, auf dem sie die Möbelaufstellung und die genaue Ausrichtung des Hauses sehen kann. Daraufhin macht Frau Eigenmann einen detaillierten Wohnungsplan mit ausführlichen Erklärungen, wie man die Räume optimal einrichtet, um sich darin zufrieden zu fühlen. Für die Erstellung eines solchen Planes benötigt sie nach eigener Aussage je nach Größe der Wohnung oder des Gebäudes zwischen einem halben und einem ganzen Tag.", "b": false}, {"t": "Anschließend geht Iris Eigenmann zu den Leuten nach Hause, um die Situation vor Ort zu analysieren und Verbesserungsmöglichkeiten aufzuzeigen.", "b": false}, {"t": "Auch immer mehr Firmen suchen Rat bei einer Raumberaterin meistens dann, wenn das Unternehmen nicht mehr so erfolgreich arbeitet. Iris Eigenmann versucht dann, das Arbeitsumfeld so zu verändern, dass sich Kunden und Angestellte wohler fühlen. Das führt in den meisten Fällen dazu, dass auch die Geschäfte wieder besser gehen. Der Preis für die Raumberatung wird je nach Aufwand mit dem Kunden gemeinsam bestimmt. Das Geld aber ist für Frau Eigenmann weniger wichtig als die Möglichkeit, den Menschen zu helfen und ihre positiven Erfahrungen weiterzugeben.", "b": false}, {"t": "p g g", "b": false}, {"t": "Das persönliche Ziel der Feng-Shui-Raumberaterin für die Zukunft ist es, vermehrt auch im sozialen Bereich zu wirken zum Beispiel in Krankenhäusern oder Altersheimen. Sie meint, dass mit einfachen Maßnahmen dort die Lebensqualität der Menschen erheblich verbessert werden könnte.", "b": false}]}], "maxPoints": 25.0, "availablePoints": 20.0, "missing": 1, "pointsPerItem": 5.0}'::jsonb, 1),
    ('lv3', 'Leseverstehen', 'Leseverstehen, Teil 3', 20, 'Lesen Sie die Situationen 11–20 und die Anzeigen im Bild. Finden Sie für jede Situation die passende Anzeige. Wenn Sie keine passende Anzeige finden, wählen Sie X.', 'matching', '{"bank": [{"key": "A", "text": ""}, {"key": "B", "text": ""}, {"key": "C", "text": ""}, {"key": "D", "text": ""}, {"key": "E", "text": ""}, {"key": "F", "text": ""}, {"key": "G", "text": ""}, {"key": "H", "text": ""}, {"key": "I", "text": ""}, {"key": "J", "text": ""}, {"key": "K", "text": ""}, {"key": "L", "text": ""}, {"key": "X", "text": ""}], "bankTitle": "Anzeigen", "bankImage": "img/m16-lv3.jpg", "maxPoints": 25.0, "availablePoints": 10.0, "missing": 6, "pointsPerItem": 2.5}'::jsonb, 2),
    ('sb1', 'Sprachbausteine', 'Sprachbausteine, Teil 1', 20, 'Lesen Sie den Text und schließen Sie die Lücken 21–30. Welche Lösung (A, B oder C) ist jeweils richtig?', 'mc', '{"passages": [{"paragraphs": [{"t": "Liebe Dominique,", "b": true}, {"t": "da ich dich telefonisch nicht erreiche, auch nicht per E-Mail, schreibe ich dir einen Brief. Es ist nämlich etwas ganz Besonderes (21) : Stelle (22) vor, ich habe die Stelle bei der EU in Brüssel bekommen!", "b": false}, {"t": "Du weißt noch: Es gab ungefähr 300 Bewerber, und unter denen (23) die besten ausgesucht. Ich hatte mich auf das Vorstellungsgespräch schon (24) Zeit vorher vorbereitet. Trotzdem ohne meine Sprachkenntnisse und meine Auslandserfahrung (25) ich die Stelle sicher nicht bekommen. Aber ein bisschen Glück braucht man auch, (26) so etwas gelingt.", "b": false}, {"t": "Nun bitte ich dich (27) ein paar gute Tipps. Vielleicht kennst du auch jemanden, von(28) ich Informationen über das Leben in Belgien bekommen kann? Ich würde dich am liebsten kürz (29) , um mit dir persönlich zu sprechen. Geht das vielleicht (30) zwei Wochen, Z.B. am übernächsten Wochenende? Bitte gib mir Beschreiben.", "b": false}, {"t": "Herzlich Grüße", "b": true}, {"t": "Katie", "b": true}]}], "maxPoints": 15.0, "availablePoints": 6.0, "missing": 6, "pointsPerItem": 1.5}'::jsonb, 3),
    ('sb2', 'Sprachbausteine', 'Sprachbausteine, Teil 2', 15, 'Lesen Sie den Text und schließen Sie die Lücken 31–40. Benutzen Sie die Wörter aus der Liste. Jedes Wort passt nur einmal.', 'wordbank', '{"bank": [{"key": "A", "text": "AUF"}, {"key": "B", "text": "DAFÜR"}, {"key": "C", "text": "DARÜBER"}, {"key": "D", "text": "HÄTTE"}, {"key": "E", "text": "KANN"}, {"key": "F", "text": "KÖNNEN"}, {"key": "G", "text": "MÖCHTE"}, {"key": "H", "text": "SEHR"}, {"key": "I", "text": "SEIT"}, {"key": "J", "text": "SPRECHEN"}, {"key": "K", "text": "VOR"}, {"key": "L", "text": "WENIG"}, {"key": "M", "text": "WIE"}, {"key": "N", "text": "WIE VIELE"}, {"key": "O", "text": "WISSEN"}], "bankTitle": "Wörterliste", "passages": [{"paragraphs": [{"t": "dir B hätte den", "b": false}, {"t": "Du würde denen", "b": false}, {"t": "C C", "b": false}, {"t": "A A A", "b": false}, {"t": "26. 29.", "b": false}, {"t": "23. halten als getroffen", "b": false}, {"t": "wären damit treffe", "b": false}, {"t": "B B B", "b": false}, {"t": "wurden ob treffen", "b": false}, {"t": "C C C", "b": false}, {"t": ") (", "b": false}, {"t": "Sehr geehrte Frau Campe,", "b": false}, {"t": "mein Deutschlehrer hat mich (31) informiert, dass Sie in St. Andreasburg Intensivkurse in Deutsch anbieten.", "b": false}, {"t": "Ich lerne (32) zwei Jahren Deutsch in Yverden, einer kleinen Stadt in der Westschweiz. Es gefällt mir hier, aber ich lebe in einer französischsprachigen Region und auch meine Arbeitskollegen (33) nur Französisch (oder Englisch) mit mir. So habe ich einfach zu (34). Gelegenheit, Deutsch zu sprechen. Deshalb interessiere ich mich (35) für Ihre Intensivkurse. Die Oberpfalz (36) ich schon seit langem einmal kennen lernen. Ich habe schon viel darüber gehört und gelesen, war aber selber noch nie dort.", "b": false}, {"t": "Bevor ich mich für einen Sprachkurs in St. Anderasburg entscheide, (37) ich noch einige", "b": false}, {"t": "Fragen. Bieten Sie auch Sprachkurse an, in denen man international anerkannte Diplome erwerben kann? (38). Studenten nehmen an einem Kurs teil? Kann man abends auch noch individuell mit dem Computer weiterlernen? Muss man für die Exkursionen extra bezahlen oder sind die Kosten (39) schon im Kursgeld enthalten?", "b": false}, {"t": "Für Ihre Antwort (40) meine Fragen bedanke ich mich vielmals.", "b": false}, {"t": "Mit freundlichen Grüßen Nadia Grade", "b": false}]}], "maxPoints": 15.0, "availablePoints": 15.0, "missing": 0, "pointsPerItem": 1.5}'::jsonb, 4),
    ('hv1', 'Hörverstehen', 'Hörverstehen, Teil 1', 8, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 5),
    ('hv2', 'Hörverstehen', 'Hörverstehen, Teil 2', 14, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 22.5, "missing": 1, "pointsPerItem": 2.5}'::jsonb, 6),
    ('hv3', 'Hörverstehen', 'Hörverstehen, Teil 3', 8, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 15.0, "missing": 2, "pointsPerItem": 5.0}'::jsonb, 7),
    ('sa', 'Schriftlicher Ausdruck', 'Schriftlicher Ausdruck', 30, 'Antworten Sie auf diesen Brief. Schreiben Sie in Ihrem Brief etwas zu den folgenden vier Punkten:', 'writing', '{"brief": {"intro": "Ihr Freund hat Ihnen folgenden Brief geschrieben:", "greeting": "Liebe(r)........", "paragraphs": ["ich sende dir sonnige Grüße von der wunderschöne Insel Malta Katja, die Kinder und ich sind ganz glücklich! Strand, Kultur. Sport- all das ist hier möglich! Gestern haben wir uns sogar ein Auto gemietet und einen Ausflug gemacht. Und auch für mein Hobby. Das Fotografieren, habe ich sehr viel Zeit, ich habe schon ganz viele Fotos gemacht. Ich schicke dir mit diesem Brief auch ein Buch über Malta, damit du siehst wie interessant dieses Land ist. Hoffentlich gefällt dir das Buch. Leider ist unser Urlaub auch schon in wenigen Tagen vorbei. Wie wäre das - vielleicht können wir uns ja wieder einmal treffen?", "Bis hoffentlich bald"], "signature": "Viktor"}, "hints": [], "criteria": [{"title": "Aufgabenbewältigung", "hint": "Sind alle vier Leitpunkte inhaltlich angemessen bearbeitet?"}, {"title": "Kommunikative Gestaltung", "hint": "Anrede, Gruß, passendes Register und verbundene Sätze statt aneinandergereihter Punkte?"}, {"title": "Formale Richtigkeit", "hint": "Stören Fehler in Grammatik, Wortschatz und Rechtschreibung das Verstehen?"}], "grades": [{"key": "A", "points": 5}, {"key": "B", "points": 3}, {"key": "C", "points": 1}, {"key": "D", "points": 0}], "factor": 3, "maxPoints": 45, "availablePoints": 45, "missing": 0}'::jsonb, 8)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'b1' and t.slug = 'modell-16'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('lv1', '1', 'Frauen kommen genauso gut an ihr Ziel wie Männer, sie geben nur nicht so damit an. Das – – ergab eine Studie der Eberhard Karls Universität Tübingen mit 600 Testpersonen. Obwohl Frauen sich so gut zurechtfinden wie Männer. Wenn Frauen allein unterwegs sind, fragen sie öfter nach dem Weg und freuen sich, wenn ihnen Freunde helfen. Die Tübinger Forscher nennen das ein kommunikatives. Orientierungsmodell Männer dagegen verfahren sich lieber dreimal, als einmal Um Hilfe zu bitten. Dabei Spielt offsichtlich die Erziehung eine Rolle.', null::jsonb, 5.0, null::jsonb, 0),
    ('lv1', '2', 'Bahnfahren ist entspannend und lädt zum Lesen ein. Deswegen liest auch etwa die Hälfte aller Reisenden während ihrer Banfahrt. Frauen sind dabei lesefreudiger als Männer: 63 Prozent von ihnen steigen mit dem Buch in den Zug unterwegs ist, verbringt im Durschnitt etwa eine Stunde und 28 Minuten mit dem Lesen eines Buches oder einer Zeitung. Ein Zehntel aller Bahnreisenden gesteht, dass sie keine Buchleser sind. Dies sind die wesentlichen Ergebnisse einer Studie der Stiftung Lesen in Zusammenarbeit mit der Deutschen Bahn.', null::jsonb, 5.0, null::jsonb, 1),
    ('lv1', '3', 'Der friere Verein junger Mädchen heißt nun Cornpagna und hat sich zu einem modernen gemeinnützigen Dienstleistungsbetrieb gewandelt. Das wichtigste Ziel des Vereins ist es weiterhin, Menschen zu begleiten. Diese Dienstleistung richtet sich vor allem an Menschen, die Hilfe angewiesen sind: Alleinreisende Kinder alte und behinderte Menschen. Die Reisen werden am Ausgangsbahnhof abgeholt und mit den öffentlich Verkehrsmitteln bis zum Zielort begleitet.', null::jsonb, 5.0, null::jsonb, 2),
    ('lv1', '4', 'Christine zum stein Leiterin der Volkshochschule Solothurn (VHS), ist begeistert: super gelaufen seien die Kurse, die die VHS in den Morgenzügen des Quartal angeboten hat. Weil sich das Pilotprojekt von VHS und RBS auf der Strecke Solothurn – Bern bestens bewährt hat, sollen künftig auch Pendlerinnen und Pendler in umgekehrter Richtung die Möglichkeit erhalten während der Bahnfahrt Sprachen zu lernen Zug ab Bern, mit einem Kurs in einer neuer Rechtschreibung. Ebenfalls angeboten werden Englisch, Italienisch und Französisch.', null::jsonb, 5.0, null::jsonb, 3),
    ('lv1', '5', 'Sie sind in der Schweiz zu einem Fest eingeladen aber auf der Einladung steht nur die Adresse? Kein Problem, auch ohne Auto: Seit einiger Zeit hat er Internet Fahrplan der Schweizerischen Bundesbahnen(www.sbb.ch) einen großen Brüder. Bis jetzt konnte man nur Verbindungen von Bahnhöfen zu Bahnhöfen oder Haltstellen zu abfragen. Neuerdings ist das auch für den', null::jsonb, 5.0, null::jsonb, 4),
    ('lv2', '6', 'Iris Eigenmann.', '[{"key": "A", "text": "berät Kunden beim Aufstellen von Möbeln in Wohnungen und Büros."}, {"key": "B", "text": "hilft Menschen bei der richtigen Berufswahl."}, {"key": "C", "text": "zeichnet Pläne für eine Große Baufirma."}]'::jsonb, 5.0, null::jsonb, 0),
    ('lv2', '7', 'Als Raumberaterin kümmert sich Iris Eigenmann darum,', '[{"key": "A", "text": "dass sich Menschen in Wohn und Arbeitsräumen wohler fühlen."}, {"key": "B", "text": "chinesische Möbel in Europa zu verkaufen."}, {"key": "C", "text": "Materialien für neue Bauprojekte zu entwickeln."}]'::jsonb, 5.0, null::jsonb, 1),
    ('lv2', '8', 'Die Leute, die sich beraten lassen wollen,', '[{"key": "A", "text": "besprechen mit Frau Eigenmann zuerst ihre Wünsche."}, {"key": "B", "text": "laden Frau Eigenmann zuerst in ihre Wohnung ein."}, {"key": "C", "text": "schicken Frau Eigenmann zuerst einen Plan der Wohnung."}]'::jsonb, 5.0, null::jsonb, 2),
    ('lv2', '9', 'Die Firmenkunden von Frau Eigenmann', '[{"key": "A", "text": "bezahlen besonders wenig für die Beratung."}, {"key": "B", "text": "sind meist erfolgreiche Unternehmen."}, {"key": "C", "text": "wollen auch ihre wirtschaftliche Lage verbessern."}]'::jsonb, 5.0, null::jsonb, 3),
    ('lv3', '11', 'Sie interessiert sich für eine neue Waschmaschine.', null::jsonb, 2.5, null::jsonb, 0),
    ('lv3', '12', 'Ihr Freund sucht einen Praktikumsplatz bei einer Zeitung.', null::jsonb, 2.5, null::jsonb, 1),
    ('lv3', '13', 'Sie wollen ein neues Musikinstrument spielen lernen.', null::jsonb, 2.5, null::jsonb, 2),
    ('lv3', '14', 'In Ihrer Wohnung gibt es Probleme mit dem Wasser in Bad und Küche und Sie wollen das verändern.', null::jsonb, 2.5, null::jsonb, 3),
    ('sb1', '21', '… ich dir einen Brief. Es ist nämlich etwas ganz Besonderes (21) : Stelle (22) vor, ich habe die Stelle bei der EU in …', '[{"key": "A", "text": "geschah"}, {"key": "B", "text": "geschehen"}, {"key": "C", "text": "geschieht"}]'::jsonb, 1.5, null::jsonb, 0),
    ('sb1', '24', '… Ich hatte mich auf das Vorstellungsgespräch schon (24) Zeit vorher vorbereitet. Trotzdem ohne meine …', '[{"key": "A", "text": "lange"}, {"key": "B", "text": "langem"}, {"key": "C", "text": "langer"}]'::jsonb, 1.5, null::jsonb, 1),
    ('sb1', '27', '… man auch, (26) so etwas gelingt. Nun bitte ich dich (27) ein paar gute Tipps. Vielleicht kennst du auch jemanden, …', '[{"key": "A", "text": "für"}, {"key": "B", "text": "über"}, {"key": "C", "text": "um"}]'::jsonb, 1.5, null::jsonb, 2),
    ('sb1', '30', '… , um mit dir persönlich zu sprechen. Geht das vielleicht (30) zwei Wochen, Z.B. am übernächsten Wochenende? Bitte gib …', '[{"key": "A", "text": "bis"}, {"key": "B", "text": "in"}, {"key": "C", "text": "an"}]'::jsonb, 1.5, null::jsonb, 3),
    ('sb2', '31', '… ) ( Sehr geehrte Frau Campe, mein Deutschlehrer hat mich (31) informiert, dass Sie in St. Andreasburg Intensivkurse in …', null::jsonb, 1.5, null::jsonb, 0),
    ('sb2', '32', '… Andreasburg Intensivkurse in Deutsch anbieten. Ich lerne (32) zwei Jahren Deutsch in Yverden, einer kleinen Stadt in …', null::jsonb, 1.5, null::jsonb, 1),
    ('sb2', '33', '… Region und auch meine Arbeitskollegen (33) nur Französisch (oder Englisch) mit mir. So habe ich …', null::jsonb, 1.5, null::jsonb, 2),
    ('sb2', '34', '… (oder Englisch) mit mir. So habe ich einfach zu (34). Gelegenheit, Deutsch zu sprechen. Deshalb interessiere …', null::jsonb, 1.5, null::jsonb, 3),
    ('sb2', '35', '… Deutsch zu sprechen. Deshalb interessiere ich mich (35) für Ihre Intensivkurse. Die Oberpfalz (36) ich schon seit …', null::jsonb, 1.5, null::jsonb, 4),
    ('sb2', '36', '… ich mich (35) für Ihre Intensivkurse. Die Oberpfalz (36) ich schon seit langem einmal kennen lernen. Ich habe …', null::jsonb, 1.5, null::jsonb, 5),
    ('sb2', '37', '… mich für einen Sprachkurs in St. Anderasburg entscheide, (37) ich noch einige Fragen. Bieten Sie auch Sprachkurse an, …', null::jsonb, 1.5, null::jsonb, 6),
    ('sb2', '38', '… denen man international anerkannte Diplome erwerben kann? (38). Studenten nehmen an einem Kurs teil? Kann man abends …', null::jsonb, 1.5, null::jsonb, 7),
    ('sb2', '39', '… für die Exkursionen extra bezahlen oder sind die Kosten (39) schon im Kursgeld enthalten? Für Ihre Antwort (40) meine …', null::jsonb, 1.5, null::jsonb, 8),
    ('sb2', '40', '… Kosten (39) schon im Kursgeld enthalten? Für Ihre Antwort (40) meine Fragen bedanke ich mich vielmals. Mit freundlichen …', null::jsonb, 1.5, null::jsonb, 9),
    ('hv1', '41', 'Die Sprecherin fühlt sich durch Handys gestört.', null::jsonb, 5.0, null::jsonb, 0),
    ('hv1', '42', 'Der Sprecher benützt das Handy für Gespräche mit Freunden.', null::jsonb, 5.0, null::jsonb, 1),
    ('hv1', '43', 'Der Sprecher ruft gerne sein Partnerin mit dem Handy an.', null::jsonb, 5.0, null::jsonb, 2),
    ('hv1', '44', 'Die Sprecherin findet Handys für Kinder nicht gut.', null::jsonb, 5.0, null::jsonb, 3),
    ('hv1', '45', 'Der Sprecher hätte auch gern ein Handy.', null::jsonb, 5.0, null::jsonb, 4),
    ('hv2', '46', 'Das Kino Freie Filmbühne ist in Burgoberdorf.', null::jsonb, 2.5, null::jsonb, 0),
    ('hv2', '47', 'Die Freie Filmbühne wird geschlossen.', null::jsonb, 2.5, null::jsonb, 1),
    ('hv2', '48', 'Die Freie Filmbühne hat dieses Jahr zum ersten Mal einen Preis gewonnen.', null::jsonb, 2.5, null::jsonb, 2),
    ('hv2', '49', 'Das Haus, in dem die Freie Filmbühne jetzt ist, war früher eine Schule.', null::jsonb, 2.5, null::jsonb, 3),
    ('hv2', '50', 'In der Nähe des Kinos kann man etwas trinken gehen.', null::jsonb, 2.5, null::jsonb, 4),
    ('hv2', '51', 'Wo jetzt die Freie Filmbühne ist, sollen Wohnungen und ein Freizeitzentrum gebaut werden.', null::jsonb, 2.5, null::jsonb, 5),
    ('hv2', '52', 'Es wird wahrscheinlich zwei Jahre dauern, bis die neuen Gebäude fertig sind.', null::jsonb, 2.5, null::jsonb, 6),
    ('hv2', '53', 'Es haben jetzt weniger Leute Interesse an der Freie Filmbühne als am Anfang.', null::jsonb, 2.5, null::jsonb, 7),
    ('hv2', '54', 'Frau Imbach möchte, dass die Freie Filmbühne umzieht.', null::jsonb, 2.5, null::jsonb, 8),
    ('hv3', '56', 'Wegen des Nebels sollte man heute nicht nach München fahren.', null::jsonb, 5.0, null::jsonb, 0),
    ('hv3', '57', 'In der Buchabteilung ist ein berühmter Autor zu Gast.', null::jsonb, 5.0, null::jsonb, 1),
    ('hv3', '58', 'Der Zug nach Wein fährt heute von einem anderen Bahnsteig ab.', null::jsonb, 5.0, null::jsonb, 2),
    ('sa', 'A', 'Antworten Sie auf diesen Brief. Schreiben Sie in Ihrem Brief etwas zu den folgenden vier Punkten:', null::jsonb, 0, '{"minWords": 100, "points": ["Ihre Hobbys", "Reaktion auf das Buch", "Ihre Pläne für den nächsten Urlaub", "Treffen mit Viktor"]}'::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'b1' and t.slug = 'modell-16'
join sections s on s.test_id = t.id and s.section_id = v.section_id
on conflict (section_id, item_id) do update set text = excluded.text, options = excluded.options, points = excluded.points, meta = excluded.meta, sort = excluded.sort;

insert into item_answers (item_id, answer, explanation)
select i.id, v.answer, v.explanation
from (values
    ('lv1', '1', 'F', null),
    ('lv1', '2', 'I', null),
    ('lv1', '3', 'E', null),
    ('lv1', '4', 'H', null),
    ('lv1', '5', 'C', null),
    ('lv2', '6', 'A', null),
    ('lv2', '7', 'C', null),
    ('lv2', '8', 'B', null),
    ('lv2', '9', 'C', null),
    ('lv3', '11', 'L', null),
    ('lv3', '12', 'D', null),
    ('lv3', '13', 'K', null),
    ('lv3', '14', 'C', null),
    ('sb1', '21', 'B', null),
    ('sb1', '24', 'C', null),
    ('sb1', '27', 'C', null),
    ('sb1', '30', 'B', null),
    ('sb2', '31', 'C', 'Das Wort lautet: DARÜBER'),
    ('sb2', '32', 'I', 'Das Wort lautet: SEIT'),
    ('sb2', '33', 'J', 'Das Wort lautet: SPRECHEN'),
    ('sb2', '34', 'L', 'Das Wort lautet: WENIG'),
    ('sb2', '35', 'H', 'Das Wort lautet: SEHR'),
    ('sb2', '36', 'G', 'Das Wort lautet: MÖCHTE'),
    ('sb2', '37', 'D', 'Das Wort lautet: HÄTTE'),
    ('sb2', '38', 'N', 'Das Wort lautet: WIE VIELE'),
    ('sb2', '39', 'M', 'Das Wort lautet: WIE'),
    ('sb2', '40', 'A', 'Das Wort lautet: AUF'),
    ('hv1', '41', 'r', null),
    ('hv1', '42', 'f', null),
    ('hv1', '43', 'f', null),
    ('hv1', '44', 'r', null),
    ('hv1', '45', 'f', null),
    ('hv2', '46', 'r', null),
    ('hv2', '47', 'r', null),
    ('hv2', '48', 'r', null),
    ('hv2', '49', 'f', null),
    ('hv2', '50', 'f', null),
    ('hv2', '51', 'r', null),
    ('hv2', '52', 'f', null),
    ('hv2', '53', 'r', null),
    ('hv2', '54', 'f', null),
    ('hv3', '56', 'f', null),
    ('hv3', '57', 'r', null),
    ('hv3', '58', 'f', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'b1' and t.slug = 'modell-16'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;

commit;
