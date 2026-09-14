-- مولّد من content/goethe/a1 بـtools/export_sql.py — لا تعدّله بالإيد
begin;

insert into levels (id, title, sort, published, provider, stufe) values ('goethe-a1', 'Goethe-Zertifikat A1', 0, true, 'Goethe', 'A1')
on conflict (id) do update set title = excluded.title,
  provider = coalesce(levels.provider, excluded.provider),
  stufe    = coalesce(levels.stufe,    excluded.stufe);

-- ================= modell-01 · WINFRIED =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('goethe-a1', 'modell-01', 'WINFRIED', '17 Aufgaben · 45 Minuten',
        '[{"id": "block-lesen", "parts": ["lv1", "lv2", "lv3"], "title": "Lesen", "minutes": 25, "hint": "Aufgaben 1–15", "maxPoints": 15, "availablePoints": 15, "missing": 0}, {"id": "block-schreiben", "parts": ["s1", "s2"], "title": "Schreiben", "minutes": 20, "hint": "Aufgaben 16–21", "maxPoints": 15, "availablePoints": 15, "missing": 0}]'::jsonb, 17, true, 1)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('lv1', 'Lesen', 'Lesen, Teil 1', 10, 'Lesen Sie die beiden Texte und die Aufgaben 1 bis 5. Kreuzen Sie an: Richtig oder Falsch.', 'truefalse', '{"passages": [{"paragraphs": [{"t": "Einladung zum Jazz-Konzert", "b": true}, {"t": "Liebe Frau Dehner,", "b": false}, {"t": "vielen Dank für die Einladung zu Ihrem Jazz-Konzert. Ich komme gern und ich freue mich sehr auf das Konzert.", "b": false}, {"t": "Ich danke Ihnen auch, dass ich in Ihrem Gästezimmer schlafen kann und kein Hotel suchen muss. Mein Zug kommt schon um circa 16 Uhr an.", "b": false}, {"t": "Kann ich Ihnen am Nachmittag dann vor dem Konzert etwas helfen?", "b": false}, {"t": "Bis bald und herzliche Grüße", "b": false}, {"t": "Winfried Beck", "b": false}]}], "maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1}'::jsonb, 0),
    ('lv2', 'Lesen', 'Lesen, Teil 2', 10, 'Lesen Sie die Texte und die Aufgaben 6 bis 10. Wo finden Sie Informationen? Kreuzen Sie an: a oder b.', 'mc', '{"maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1}'::jsonb, 1),
    ('lv3', 'Lesen', 'Lesen, Teil 3', 5, 'Lesen Sie die Texte und die Aufgaben 11 bis 15. Kreuzen Sie an: Richtig oder Falsch.', 'truefalse', '{"passages": [{"paragraphs": [{"t": "Vor einem Blumenladen", "b": true}, {"t": "Neu! Neu! Neu! Neu! Neu!", "b": false}, {"t": "Liebe Kunden!", "b": false}, {"t": "Ab sofort haben wir auch sonntags von 9-12 Uhr für Sie geöffnet!", "b": false}]}], "maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1}'::jsonb, 2),
    ('s1', 'Schreiben', 'Schreiben, Teil 1 (Formular)', 10, 'Ihre Freundin Eva Kadavy macht mit ihrem Mann und ihren beiden Söhnen (8 und 11 Jahre alt) Urlaub in Seeheim. Im Reisebüro bucht sie für den nächsten Sonntag eine Busfahrt um den Bodensee. Frau Kadavy hat keine Kreditkarte. Helfen Sie Ihrer Freundin und schreiben Sie die fünf fehlenden Informationen in das Formular.', 'writing', '{"bankTitle": "Formular", "bankImage": "img/m01-s1.png", "passages": [{"paragraphs": [{"t": "Bodensee-Rundfahrt Anmeldung", "b": true}, {"t": "Ihre Freundin Eva Kadavy macht mit ihrem Mann und ihren beiden Söhnen (8 und 11 Jahre alt) Urlaub in Seeheim. Im Reisebüro bucht sie für den nächsten Sonntag eine Busfahrt um den Bodensee. Frau Kadavy hat keine Kreditkarte.", "b": false}, {"t": "Helfen Sie Ihrer Freundin und schreiben Sie die fünf fehlenden Informationen in das Formular.", "b": false}]}], "maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 5}'::jsonb, 3),
    ('s2', 'Schreiben', 'Schreiben, Teil 2', 10, 'Schreiben Sie an Ihren Nachbarn, Herrn Maier, und bitten Sie um Hilfe. Schreiben Sie zu jedem Punkt ein bis zwei Sätze (ca. 30 Wörter).', 'writing', '{"passages": [{"paragraphs": [{"t": "Schreibaufgabe", "b": true}, {"t": "Sie bekommen am Dienstag einen neuen Kühlschrank. Sie müssen arbeiten. Schreiben Sie an Ihren Nachbarn, Herrn Maier, und bitten Sie um Hilfe.", "b": false}, {"t": "Schreiben Sie zu jedem Punkt ein bis zwei Sätze (ca. 30 Wörter):", "b": false}, {"t": "• Warum schreiben Sie?", "b": false}, {"t": "• Uhrzeit?", "b": false}, {"t": "• Schlüssel?", "b": false}]}], "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 10}'::jsonb, 4)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'goethe-a1' and t.slug = 'modell-01'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('lv1', '1', 'Herr Beck übernachtet im Hotel.', null::jsonb, 1, null::jsonb, 0),
    ('lv1', '2', 'Herr Beck bietet Frau Dehner seine Hilfe an. Text: **Betreff: Neuer Arbeitsplan** Liebe Frau Jakobs, ich komme heute, Dienstag, noch nicht aus Berlin zurück. Ich habe morgen ein Gespräch mit dem Kunden Maybach. Der ist ganz wichtig für uns. Und am Donnerstag habe ich zwei weitere neue Termine. Aber am Freitag bin ich ab 8 Uhr wieder im Büro. Bitte machen Sie mir für 11 Uhr einen Termin mit Dr. Falk. Vielen Dank und herzliche Grüße Helga Stein Aufgaben:', null::jsonb, 1, null::jsonb, 1),
    ('lv1', '3', 'Frau Stein ist in Berlin.', null::jsonb, 1, null::jsonb, 2),
    ('lv1', '4', 'Am Mittwoch hat Frau Stein frei.', null::jsonb, 1, null::jsonb, 3),
    ('lv1', '5', 'Frau Stein will am Freitag Dr. Falk treffen.', null::jsonb, 1, null::jsonb, 4),
    ('lv2', '6', 'Sie wollen viele Freunde zu Ihrem Geburtstag einladen. Sie suchen einen Ort.', '[{"key": "A", "text": "www.raum-in-koeln.de: Raum für Tanz, Sport, Hochzeiten und andere private Feiern zu vermieten. Auch abends Termine frei, günstige Preise."}, {"key": "B", "text": "www.wohnen-in-koeln.de: Schöne Zimmer und Apartments für 2 - 12 Wochen im Großraum Köln zu interessanten Preisen."}]'::jsonb, 1, null::jsonb, 0),
    ('lv2', '7', 'Der Computer ist kaputt. Sie können ihn nicht allein reparieren.', '[{"key": "A", "text": "www.computer-loesungen.de: Für alles, was mit Computern, Druckern, Scannern, Internet usw. zu tun hat. Auch Reparaturen."}, {"key": "B", "text": "www.technohaus.de: Gebrauchte Kühlschränke, Herde, Waschmaschinen, Computer, Drucker, Fernseher, Radios, Handys usw. zu supergünstigen Preisen!"}]'::jsonb, 1, null::jsonb, 1),
    ('lv2', '8', 'Sie möchten am Samstagabend mit Freunden tanzen gehen.', '[{"key": "A", "text": "www.tanzen-macht-spass.de: Tanzschule Renz. Informieren Sie sich jetzt über die neuen Tanzkurse für Jugendliche und Erwachsene. Bitte bestellen Sie unseren Tanzplan."}, {"key": "B", "text": "www.wohin-am-wochenende.de: Ins Aladin! Das neue Tanz-Restaurant! Erst gut essen, dann Tanzen - die ganze Nacht! Freitag - Samstag haben wir bis 4 Uhr geöffnet."}]'::jsonb, 1, null::jsonb, 2),
    ('lv2', '9', 'Sie möchten am Wochenende Fußball spielen.', '[{"key": "A", "text": "www.freizeitsport-freiburg.de: Basketball, Fitness, Fußball und mehr. Montags bis donnerstags 18.30 bis 21.00 Uhr im Südpark am See."}, {"key": "B", "text": "www.fc-1897.de/training: Der Fußballklub FC 1897 sucht Spieler und Spielerinnen. Treffpunkt: Sportanlage Ulrichsplatz, sonntags 10-12 Uhr. Keine Anmeldung."}]'::jsonb, 1, null::jsonb, 3),
    ('lv2', '10', 'Sie studieren und möchten ein bisschen arbeiten.', '[{"key": "A", "text": "Tel.: 0176 - 55 44 321 (Unsere Bäckerei braucht Hilfe. Wir suchen eine junge Frau / einen jungen Mann im Verkauf am Samstag von 7 bis 11 Uhr.)"}, {"key": "B", "text": "Tel.: 0160 - 683 456 20 (Junge Verkäuferin / Junger Verkäufer gesucht für Zeitungskiosk. 42 Stunden / Woche, bei guter Bezahlung.)"}]'::jsonb, 1, null::jsonb, 4),
    ('lv3', '11', 'Am Sonntagvormittag bekommen Sie hier Blumen. Text: **Im Restaurant** Liebe Gäste, im nächsten Monat kocht bei uns ein Koch aus Kalkutta indische Spezialitäten. Wir freuen uns auf Ihren Besuch. Aufgaben:', null::jsonb, 1, null::jsonb, 0),
    ('lv3', '12', 'Jeden Montag bietet das Restaurant indisches Essen an. Text: **Bei der Straßenbahn** Linie 8: Ab 15. nur bis Hauptbahnhof. Zur Weiterfahrt nach Huchting: Linie 1 oder Bus Nr. 53. Aufgaben:', null::jsonb, 1, null::jsonb, 1),
    ('lv3', '13', 'Es ist der 2. Mai, 21 Uhr. Sie können jetzt nicht zum Hauptbahnhof fahren. Text: **An einer Haustür** Sehr geehrte Interessenten, es gibt leider keine Besichtigungen mehr. Die 3-Zimmer-Wohnung im 3. Stock ist schon vermietet. Aufgaben:', null::jsonb, 1, null::jsonb, 2),
    ('lv3', '14', 'Sie können die Wohnung nicht besichtigen. Text: **Im Bahnhof** Sehr geehrte Fahrgäste! Ab 22 Uhr sind unsere Schalter geschlossen. Fahrkarten bekommen Sie dann an unseren Automaten. Aufgaben:', null::jsonb, 1, null::jsonb, 3),
    ('lv3', '15', 'Ab 22 Uhr können Sie keine Fahrkarten mehr kaufen.', null::jsonb, 1, null::jsonb, 4),
    ('s1', '16', 'Schreiben Sie die fünf fehlenden Informationen in das Formular (Aufgaben 16–20):', null::jsonb, 0, '{"points": ["(1) Anzahl der Personen: 4", "(2) Davon Kinder: 2", "(3) PLZ, Urlaubsort: Seeheim", "(4) Zahlungsweise (Bar oder Kreditkarte): Bar", "(5) Reisetermin: Sonntag"]}'::jsonb, 0),
    ('s2', '21', 'Schreiben Sie eine E-Mail oder einen kurzen Brief an Herrn Maier:', null::jsonb, 0, '{"minWords": 30, "points": ["Warum schreiben Sie?", "Uhrzeit?", "Schlüssel?"]}'::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'goethe-a1' and t.slug = 'modell-01'
join sections s on s.test_id = t.id and s.section_id = v.section_id
on conflict (section_id, item_id) do update set text = excluded.text, options = excluded.options, points = excluded.points, meta = excluded.meta, sort = excluded.sort;

insert into item_answers (item_id, answer, explanation)
select i.id, v.answer, v.explanation
from (values
    ('lv1', '1', 'f', null),
    ('lv1', '2', 'r', null),
    ('lv1', '3', 'r', null),
    ('lv1', '4', 'f', null),
    ('lv1', '5', 'r', null),
    ('lv2', '6', 'A', null),
    ('lv2', '7', 'A', null),
    ('lv2', '8', 'B', null),
    ('lv2', '9', 'B', null),
    ('lv2', '10', 'A', null),
    ('lv3', '11', 'r', null),
    ('lv3', '12', 'f', null),
    ('lv3', '13', 'f', null),
    ('lv3', '14', 'r', null),
    ('lv3', '15', 'f', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'goethe-a1' and t.slug = 'modell-01'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;

-- ================= modell-02 · KARIN =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('goethe-a1', 'modell-02', 'KARIN', '17 Aufgaben · 45 Minuten',
        '[{"id": "block-lesen", "parts": ["lv1", "lv2", "lv3"], "title": "Lesen", "minutes": 25, "hint": "Aufgaben 1–15", "maxPoints": 15, "availablePoints": 15, "missing": 0}, {"id": "block-schreiben", "parts": ["s1", "s2"], "title": "Schreiben", "minutes": 20, "hint": "Aufgaben 16–21", "maxPoints": 15, "availablePoints": 15, "missing": 0}]'::jsonb, 17, true, 2)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('lv1', 'Lesen', 'Lesen, Teil 1', 10, 'Lesen Sie die beiden Texte und die Aufgaben 1 bis 5. Kreuzen Sie an: Richtig oder Falsch.', 'truefalse', '{"passages": [{"paragraphs": [{"t": "Hallo Li,", "b": true}, {"t": "danke für deine Mail. Dein Zug kommt hier in Hannover um 12.36 Uhr an. Ich bin ab 12.15 Uhr im Hauptbahnhof und warte auf dich vor der Auskunft.", "b": false}, {"t": "Du kannst mich den ganzen Vormittag auf meinem Handy (++49 173 62 205 59) erreichen.", "b": false}, {"t": "Deine Karin", "b": false}]}], "maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1}'::jsonb, 0),
    ('lv2', 'Lesen', 'Lesen, Teil 2', 10, 'Lesen Sie die Texte und die Aufgaben 6 bis 10. Wo finden Sie Informationen? Kreuzen Sie an: a oder b.', 'mc', '{"maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1}'::jsonb, 1),
    ('lv3', 'Lesen', 'Lesen, Teil 3', 5, 'Lesen Sie die Texte und die Aufgaben 11 bis 15. Kreuzen Sie an: Richtig oder Falsch.', 'truefalse', '{"passages": [{"paragraphs": [{"t": "In der Sprachschule", "b": true}, {"t": "In der 10-Uhr-Pause bekommen Sie an der Rezeption ein Frühstückspaket:", "b": false}, {"t": "Belegte Brötchen und Getränke für 2 Euro.", "b": false}]}], "maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1}'::jsonb, 2),
    ('s1', 'Schreiben', 'Schreiben, Teil 1 (Formular)', 10, 'Ihr Freund Munir Kassem kommt aus Ägypten und wohnt jetzt in Hamburg. Er ist 35 Jahre alt und von Beruf Arzt. In seiner Freizeit will er in einem Verein Fußball spielen. Bezahlen will er mit Kreditkarte. Helfen Sie Ihrem Freund und schreiben Sie die fünf fehlenden Informationen in das Formular.', 'writing', '{"bankTitle": "Formular", "bankImage": "img/m02-s1.png", "passages": [{"paragraphs": [{"t": "Sportclub von 1896 Anmeldung", "b": true}, {"t": "Ihr Freund Munir Kassem kommt aus Ägypten und wohnt jetzt in Hamburg. Er ist 35 Jahre alt und von Beruf Arzt. In seiner Freizeit will er in einem Verein Fußball spielen. Bezahlen will er mit Kreditkarte.", "b": false}, {"t": "Munir hat ein Formular für die Anmeldung in einem Sportverein bekommen.", "b": false}, {"t": "Helfen Sie Ihrem Freund und schreiben Sie die fünf fehlenden Informationen in das Formular.", "b": false}]}], "maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 5}'::jsonb, 3),
    ('s2', 'Schreiben', 'Schreiben, Teil 2', 10, 'Sie suchen eine Arbeit als Verkäufer / Verkäuferin und Sie lesen in der Zeitung eine Anzeige. Antworten Sie an den Supermarkt „cent“. Schreiben Sie zu jedem Punkt ein bis zwei Sätze (ca. 30 Wörter).', 'writing', '{"passages": [{"paragraphs": [{"t": "Schreibaufgabe", "b": true}, {"t": "Sie suchen eine Arbeit als Verkäufer / Verkäuferin und Sie lesen in der Zeitung eine Anzeige. Antworten Sie an den Supermarkt „cent“.", "b": false}, {"t": "Schreiben Sie zu jedem Punkt ein bis zwei Sätze (ca. 30 Wörter):", "b": false}, {"t": "• Warum schreiben Sie?", "b": false}, {"t": "• Informationen über sich?", "b": false}, {"t": "• Arbeitszeit?", "b": false}]}], "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 10}'::jsonb, 4)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'goethe-a1' and t.slug = 'modell-02'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('lv1', '1', 'Lis Zug kommt nach halb eins an.', null::jsonb, 1, null::jsonb, 0),
    ('lv1', '2', 'Karin wartet den ganzen Vormittag vor der Auskunft. Text: **Liebe Carmen,** am kommenden Sonntag habe ich Geburtstag. Ich möchte gerne mit dir feiern und lade dich herzlich zu meiner Party am Samstagabend ein. Wir fangen um 21 Uhr an. Ist das okay für dich? Es werden viele Leute da sein, die du auch kennst. Kannst du vielleicht einen Salat mitbringen? Und vergiss bitte nicht einen Pullover oder eine Jacke! Wir wollen nämlich draußen im Garten feiern. Ich freue mich sehr auf dich! Bis zum Wochenende Ralf Aufgaben:', null::jsonb, 1, null::jsonb, 1),
    ('lv1', '3', 'Ralf hatte am letzten Wochenende Geburtstag.', null::jsonb, 1, null::jsonb, 2),
    ('lv1', '4', 'Ralf hat nur zwei oder drei Leute eingeladen.', null::jsonb, 1, null::jsonb, 3),
    ('lv1', '5', 'Die Party findet draußen statt.', null::jsonb, 1, null::jsonb, 4),
    ('lv2', '6', 'Sie möchten mit dem Schiff auf dem Rhein fahren.', '[{"key": "A", "text": "www.schiff-ruedesheim.de: Hotel - Pension „Schiff“, Einzel- und Doppelzimmer mit Dusche/WC, Restaurant mit Rhein-Terrasse, Preise über uns."}, {"key": "B", "text": "www.bingen-ruedesheimer.de: Bingen-Rüdesheimer Rheinschiffe: täglich von Rüdesheim nach Koblenz, alle Abfahrtszeiten und Preise hier."}]'::jsonb, 1, null::jsonb, 0),
    ('lv2', '7', 'Sie möchten Deutsch in Deutschland lernen.', '[{"key": "A", "text": "www.sprachenfuchs.de: Sprachinstitut Fuchs, Dresden, Prager Str. 4. Deutsch · Englisch · Französisch · Russisch. Die Schule · Die Preise · Die Kurse · Kontakt."}, {"key": "B", "text": "www.eviva.com: Eviva-Idiomas: Sprachkurse für Deutsche. Spanisch auf Mallorca, Englisch auf Malta. Unsere Preise · Unser Unterricht · Buchungen."}]'::jsonb, 1, null::jsonb, 1),
    ('lv2', '8', 'Sie möchten ein Zugticket im Internet kaufen.', '[{"key": "A", "text": "www.DER.com: Deutsches Reisebüro: Ticketbestellungen und Reservierungen für Flüge weltweit, Deutsche Bahn, Eurobus, 24-Stunden-Service, E-Mail Ticketbestellung."}, {"key": "B", "text": "www.RED.com: Reisedienst GmbH: Ticketservice für Theater, Konzerte, Busreisen in Deutschland und nach Polen, Tschechien und Ungarn."}]'::jsonb, 1, null::jsonb, 2),
    ('lv2', '9', 'Sie möchten Informationen über den Bodensee.', '[{"key": "A", "text": "www.bodensee.de: Touristeninformation Bodensee: Urlaubsorte · Hotelservice · Ferienwohnungen · Rundreisen."}, {"key": "B", "text": "www.rottenmeier.de: Hans Rottenmeier: Ferienwohnungen am Bodensee. Häuser · Preise · Kontakt."}]'::jsonb, 1, null::jsonb, 3),
    ('lv2', '10', 'Sie sind in Wiesbaden und möchten mit dem Zug am Mittag in Hamburg sein.', '[{"key": "A", "text": "www.reiseauskunft.bahn.de: ab Hamburg 12.18, an Wiesbaden 16.52"}, {"key": "B", "text": "www.reiseauskunft.bahn.de: ab Wiesbaden 08.09, an Hamburg 12.40"}]'::jsonb, 1, null::jsonb, 4),
    ('lv3', '11', 'In der Sprachschule können Sie etwas zu essen kaufen. Text: **An der Post** Öffnungszeiten: montags – freitags: 8.00 – 12.00 und 13.00 – 18.00 samstags: 8.00 – 12.00 Aufgaben:', null::jsonb, 1, null::jsonb, 0),
    ('lv3', '12', 'Es ist Samstagnachmittag. Sie können auf der Post Briefmarken kaufen. Text: **Am Bahnhof** Auf dem gesamten Bahnhof ist das Rauchen verboten. Aufgaben:', null::jsonb, 1, null::jsonb, 1),
    ('lv3', '13', 'Sie können hier Zigaretten rauchen. Text: **Eingang Restaurant** Heute im Bavaria: Bayerischer Abend: Brezeln, Weißwürste, Sauerkraut. Volksmusik, ab 20 Uhr Tanz. Aufgaben:', null::jsonb, 1, null::jsonb, 2),
    ('lv3', '14', 'Heute Abend können Sie in diesem Restaurant tanzen. Text: **An der Haltestelle** In der Neujahrsnacht: Busverkehr bis 23.00 Uhr und von 1.00 Uhr bis 5.00 Uhr alle 30 Minuten. Aufgaben:', null::jsonb, 1, null::jsonb, 3),
    ('lv3', '15', 'Von 23 Uhr bis 1 Uhr fährt kein Bus.', null::jsonb, 1, null::jsonb, 4),
    ('s1', '16', 'Schreiben Sie die fünf fehlenden Informationen in das Formular (Aufgaben 16–20):', null::jsonb, 0, '{"points": ["(1) Wohnort: Hamburg", "(2) Beruf: Arzt", "(3) Alter: 35", "(4) Sport: Fußball", "(5) Zahlung (bar, Überweisung, Kreditkarte): Kreditkarte"]}'::jsonb, 0),
    ('s2', '21', 'Antworten Sie an den Supermarkt:', null::jsonb, 0, '{"minWords": 30, "points": ["Warum schreiben Sie?", "Informationen über sich?", "Arbeitszeit?"]}'::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'goethe-a1' and t.slug = 'modell-02'
join sections s on s.test_id = t.id and s.section_id = v.section_id
on conflict (section_id, item_id) do update set text = excluded.text, options = excluded.options, points = excluded.points, meta = excluded.meta, sort = excluded.sort;

insert into item_answers (item_id, answer, explanation)
select i.id, v.answer, v.explanation
from (values
    ('lv1', '1', 'r', null),
    ('lv1', '2', 'f', null),
    ('lv1', '3', 'f', null),
    ('lv1', '4', 'f', null),
    ('lv1', '5', 'r', null),
    ('lv2', '6', 'B', null),
    ('lv2', '7', 'A', null),
    ('lv2', '8', 'A', null),
    ('lv2', '9', 'A', null),
    ('lv2', '10', 'B', null),
    ('lv3', '11', 'r', null),
    ('lv3', '12', 'f', null),
    ('lv3', '13', 'f', null),
    ('lv3', '14', 'r', null),
    ('lv3', '15', 'r', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'goethe-a1' and t.slug = 'modell-02'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;

-- ================= modell-03 · YVONNE =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('goethe-a1', 'modell-03', 'YVONNE', '17 Aufgaben · 45 Minuten',
        '[{"id": "block-lesen", "parts": ["lv1", "lv2", "lv3"], "title": "Lesen", "minutes": 25, "hint": "Aufgaben 1–15", "maxPoints": 15, "availablePoints": 15, "missing": 0}, {"id": "block-schreiben", "parts": ["s1", "s2"], "title": "Schreiben", "minutes": 20, "hint": "Aufgaben 16–21", "maxPoints": 15, "availablePoints": 15, "missing": 0}]'::jsonb, 17, true, 3)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('lv1', 'Lesen', 'Lesen, Teil 1', 10, 'Lesen Sie die beiden Texte und die Aufgaben 1 bis 5. Kreuzen Sie an: Richtig oder Falsch.', 'truefalse', '{"passages": [{"paragraphs": [{"t": "Liebe Nora", "b": true}, {"t": "Liebe Nora,", "b": false}, {"t": "viele Grüße aus Weimar! Ich habe ein schönes Zimmer im Hotel Drei Kronen ganz in der Nähe vom Zentrum. Die Arbeit an der Universität ist sehr interessant, aber ich muss viel arbeiten. Am Abend habe ich aber frei. Wollen wir uns morgen um 19:30 Uhr im Restaurant „Zum Schwan“ treffen?", "b": false}, {"t": "Bis morgen", "b": false}, {"t": "Renate", "b": false}]}], "maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1}'::jsonb, 0),
    ('lv2', 'Lesen', 'Lesen, Teil 2', 10, 'Lesen Sie die Texte und die Aufgaben 6 bis 10. Wo finden Sie Informationen? Kreuzen Sie an: a oder b.', 'mc', '{"maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1}'::jsonb, 1),
    ('lv3', 'Lesen', 'Lesen, Teil 3', 5, 'Lesen Sie die Texte und die Aufgaben 11 bis 15. Kreuzen Sie an: Richtig oder Falsch.', 'truefalse', '{"passages": [{"paragraphs": [{"t": "Am Fahrkartenautomaten", "b": true}, {"t": "Bayern-Ticket:", "b": false}, {"t": "Ein Tag. Fünf Personen. 29 Euro.", "b": false}, {"t": "Montag und Freitag ab 9 Uhr,", "b": false}, {"t": "am Wochenende von 6 bis 24 Uhr.", "b": false}]}], "maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1}'::jsonb, 2),
    ('s1', 'Schreiben', 'Schreiben, Teil 1 (Formular)', 10, 'Ihre Freundin Yvonne Legrand aus Frankreich, geboren am 17.4.1993 in Lyon, möchte vom 1. bis zum 28. August einen Deutschkurs in Deutschland besuchen. Sie hat schon sechs Monate Deutsch gelernt. Sie hat am Vormittag Zeit. In der Schule hat sie Englisch gelernt. Helfen Sie Ihrer Freundin und schreiben Sie die fünf fehlenden Informationen in das Formular.', 'writing', '{"bankTitle": "Formular", "bankImage": "img/m03-s1.png", "passages": [{"paragraphs": [{"t": "Sprachenschule NEWbornSCHOOL Anmeldung", "b": true}, {"t": "Ihre Freundin Yvonne Legrand aus Frankreich, geboren am 17.4.1993 in Lyon, möchte vom 1. bis zum 28. August einen Deutschkurs in Deutschland besuchen. Sie hat schon sechs Monate Deutsch gelernt. Sie hat am Vormittag Zeit. In der Schule hat sie Englisch gelernt.", "b": false}, {"t": "Helfen Sie Ihrer Freundin und schreiben Sie die fünf fehlenden Informationen in das Formular.", "b": false}]}], "maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 5}'::jsonb, 3),
    ('s2', 'Schreiben', 'Schreiben, Teil 2', 10, 'Ihre Freundin Nina möchte sich am Samstag mit Ihnen treffen, aber Sie können es nicht. Schreiben Sie an Nina. Schreiben Sie zu jedem Punkt ein bis zwei Sätze (ca. 30 Wörter).', 'writing', '{"passages": [{"paragraphs": [{"t": "Schreibaufgabe", "b": true}, {"t": "Ihre Freundin Nina möchte sich am Samstag mit Ihnen treffen, aber Sie können es nicht.", "b": false}, {"t": "Schreiben Sie an Nina.", "b": false}, {"t": "Schreiben Sie zu jedem Punkt ein bis zwei Sätze (ca. 30 Wörter):", "b": false}, {"t": "• Warum schreiben Sie?", "b": false}, {"t": "• Treffen, wann?", "b": false}, {"t": "• Mitbringen?", "b": false}]}], "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 10}'::jsonb, 4)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'goethe-a1' and t.slug = 'modell-03'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('lv1', '1', 'Renate macht in Weimar Urlaub.', null::jsonb, 1, null::jsonb, 0),
    ('lv1', '2', 'Sie möchte am Abend mit Nora zusammen essen. Text: **Sommerausflug Sportsfreunde** Liebe Sportsfreunde vom Verein 1896, auch dieses Jahr wollen wir wieder unseren Sommerausflug machen. Wir fahren mit dem Bus an den Dümmer See. Dort wollen wir wandern und in einem netten Restaurant zu Mittag essen. Abfahrt ist am 27. Juni um 9 Uhr vor dem Vereinshaus. Die Busfahrt kostet 10 Euro pro Person; das Essen und die Getränke zahlt jeder allein. Liebe Freunde, bitte meldet euch bald an! Bis dann Heinz Paschke Aufgaben:', null::jsonb, 1, null::jsonb, 1),
    ('lv1', '3', 'Die Sportsfreunde machen jeden Sommer einen Ausflug.', null::jsonb, 1, null::jsonb, 2),
    ('lv1', '4', 'Der Bus wartet vor dem Vereinshaus.', null::jsonb, 1, null::jsonb, 3),
    ('lv1', '5', 'Für die Fahrt und das Essen bezahlt jeder 10 Euro.', null::jsonb, 1, null::jsonb, 4),
    ('lv2', '6', 'Sie studieren in Frankfurt und möchten eine Wohnung mieten.', '[{"key": "A", "text": "www.goetheuni-frankfurt.de: Wohnen in Frankfurt. Wohngemeinschaften, Plätze im Studentenwohnheim, Ein- und Zwei-Zimmer-Wohnungen."}, {"key": "B", "text": "www.agentur-spiess.com: AGENTUR-SPIESS. Wir finden für Sie ein neues Zuhause. Günstige Kaufangebote: Häuser, Wohnungen, Apartments."}]'::jsonb, 1, null::jsonb, 0),
    ('lv2', '7', 'Sie möchten wissen: Wie kommt man vom Hamburger Bahnhof zum Hamburger Flughafen?', '[{"key": "A", "text": "www.flughafen-service.de: Flughafen Hamburg. Unsere Service-Leistungen: Flughafenhotel, Restaurants, Einkaufen / Banken / Geldwechsel, Besucherführungen."}, {"key": "B", "text": "www.hh-flughafen.de: Abflug, Ankunft, Parken. Flughafenbus: Hamburg Hauptbahnhof, Hamburg Altona."}]'::jsonb, 1, null::jsonb, 1),
    ('lv2', '8', 'Sie suchen ein Angebot für Ihre Urlaubsreise.', '[{"key": "A", "text": "www.travel-münchen.de: Der Reiseladen bietet an: Heute Abend aktuell „Meine schönste Reise – unsere Mitarbeiter erzählen von ihren Expeditionen“. Um 20 Uhr im Laden."}, {"key": "B", "text": "www.lastminute.de: Spanien, Abflug 27.8. ab Hannover, *** Hotel Soller, 370,- Euro/Woche mit Halbpension. Türkei, Abflug 28.8. ab Hamburg, **** Club Side, 465,- Euro/Woche..."}]'::jsonb, 1, null::jsonb, 2),
    ('lv2', '9', 'Sie suchen eine Wohnung für Ihren Urlaub.', '[{"key": "A", "text": "www.st.peter-ording.de/mietwohnungen: Schöne 3-Zimmerwohnung im Zentrum von St. Peter Ording. 5 Minuten zum Meer. 450 € kalt + Nebenkosten. Keine Küche."}, {"key": "B", "text": "www.ferienandernordsee.de: Ferienhäuser und -wohnungen. Alle Größen, das ganze Jahr. Auch auf den Inseln: Sylt, Juist, Amrum, Langeoog."}]'::jsonb, 1, null::jsonb, 3),
    ('lv2', '10', 'Sie arbeiten in Deutschland. In Ihrer Freizeit möchten Sie Fußball spielen.', '[{"key": "A", "text": "www.goal.de: Aktuelle Informationen aus der Welt des Fußballs. Hier finden Sie alles über die Spiele, die Fußballstars, die Ergebnisse, die Mannschaften."}, {"key": "B", "text": "www.vereinssport.de: Welcher Verein für meinen Sport? Klicken Sie an: Tennis / Squash, Leichtathletik, Radsport, Fußball / Basketball, Schwimmen / Wasserball."}]'::jsonb, 1, null::jsonb, 4),
    ('lv3', '11', 'Am Samstag können Sie und Ihre Freunde mit dem Ticket für 29 Euro fahren. Text: **Im Hotelzimmer** Liebe Gäste, ab 21 Uhr ist die Haustür geschlossen. Bitte nehmen Sie Ihren Zimmerschlüssel mit, er ist auch der Hausschlüssel! Aufgaben:', null::jsonb, 1, null::jsonb, 0),
    ('lv3', '12', 'Nach 22 Uhr kommen Sie nicht mehr ins Hotel. Text: **Eingang Restaurant** Wir haben für Sie täglich von 11.30 bis 15.00 Uhr und von 18.00 bis 22.00 Uhr geöffnet, auch am Wochenende und an Feiertagen. Aufgaben:', null::jsonb, 1, null::jsonb, 1),
    ('lv3', '13', 'Am Sonntagmittag können Sie in diesem Restaurant essen. Text: **Im Kultur-Verein** Ab sofort: Jeden Samstag um 20 Uhr Filmabend! Am 3.5.: „Im Juli“ von Fatih Akın. Eintritt 2 Euro. Aufgaben:', null::jsonb, 1, null::jsonb, 2),
    ('lv3', '14', 'Man kann diesen Samstagabend einen Film sehen. Text: **Im Bahnhof** Kartenverkauf an Schalter 1 bis 3. Informationen an Schalter 4. Aufgaben:', null::jsonb, 1, null::jsonb, 3),
    ('lv3', '15', 'Fahrkarten können Sie an allen Schaltern bekommen.', null::jsonb, 1, null::jsonb, 4),
    ('s1', '16', 'Schreiben Sie die fünf fehlenden Informationen in das Formular (Aufgaben 16–20):', null::jsonb, 0, '{"points": ["(1) Geburtsort: Lyon", "(2) Andere Sprachen: Englisch", "(3) Wie lange Deutsch gelernt? — 6 Monate / sechs Monate", "(4) Kurstermin: 1. - 28. August / 1. bis 28. August / vom 1. bis zum 28. August", "(5) Kurszeit: von 9 - 12 Uhr / von 9 bis 12 Uhr / 9 - 12 Uhr / 9 bis 12 Uhr"]}'::jsonb, 0),
    ('s2', '21', 'Schreiben Sie eine Mitteilung an Ihre Freundin Nina:', null::jsonb, 0, '{"minWords": 30, "points": ["Warum schreiben Sie?", "Treffen, wann?", "Mitbringen?"]}'::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'goethe-a1' and t.slug = 'modell-03'
join sections s on s.test_id = t.id and s.section_id = v.section_id
on conflict (section_id, item_id) do update set text = excluded.text, options = excluded.options, points = excluded.points, meta = excluded.meta, sort = excluded.sort;

insert into item_answers (item_id, answer, explanation)
select i.id, v.answer, v.explanation
from (values
    ('lv1', '1', 'f', null),
    ('lv1', '2', 'r', null),
    ('lv1', '3', 'r', null),
    ('lv1', '4', 'r', null),
    ('lv1', '5', 'f', null),
    ('lv2', '6', 'A', null),
    ('lv2', '7', 'B', null),
    ('lv2', '8', 'B', null),
    ('lv2', '9', 'B', null),
    ('lv2', '10', 'B', null),
    ('lv3', '11', 'r', null),
    ('lv3', '12', 'f', null),
    ('lv3', '13', 'r', null),
    ('lv3', '14', 'r', null),
    ('lv3', '15', 'f', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'goethe-a1' and t.slug = 'modell-03'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;

-- ================= modell-04 · VLADIMIR =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('goethe-a1', 'modell-04', 'VLADIMIR', '17 Aufgaben · 45 Minuten',
        '[{"id": "block-lesen", "parts": ["lv1", "lv2", "lv3"], "title": "Lesen", "minutes": 25, "hint": "Aufgaben 1–15", "maxPoints": 15, "availablePoints": 15, "missing": 0}, {"id": "block-schreiben", "parts": ["s1", "s2"], "title": "Schreiben", "minutes": 20, "hint": "Aufgaben 16–21", "maxPoints": 15, "availablePoints": 15, "missing": 0}]'::jsonb, 17, true, 4)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('lv1', 'Lesen', 'Lesen, Teil 1', 10, 'Lesen Sie die beiden Texte und die Aufgaben 1 bis 5. Kreuzen Sie an: Richtig oder Falsch.', 'truefalse', '{"passages": [{"paragraphs": [{"t": "Nachricht von Andrea", "b": true}, {"t": "Hallo Julia,", "b": false}, {"t": "ich muss heute länger im Büro bleiben. Ich weiß noch nicht, wie lange. Aber um 20 Uhr kann ich nicht beim Kino sein. Können wir morgen Abend ins Kino gehen? Auch um 20 Uhr? Ist das ok für dich?", "b": false}, {"t": "Tut mir leid ...", "b": false}, {"t": "Liebe Grüße", "b": false}, {"t": "Andrea", "b": false}]}], "maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1}'::jsonb, 0),
    ('lv2', 'Lesen', 'Lesen, Teil 2', 10, 'Lesen Sie die Texte und die Aufgaben 6 bis 10. Wo finden Sie Informationen? Kreuzen Sie an: a oder b.', 'mc', '{"maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1}'::jsonb, 1),
    ('lv3', 'Lesen', 'Lesen, Teil 3', 5, 'Lesen Sie die Texte und die Aufgaben 11 bis 15. Kreuzen Sie an: Richtig oder Falsch.', 'truefalse', '{"passages": [{"paragraphs": [{"t": "In der Schule", "b": true}, {"t": "Schulfest am nächsten Samstag.", "b": false}, {"t": "Alle Schülerinnen, Schüler und Eltern sind eingeladen.", "b": false}, {"t": "Kaffee und Kuchen gibt es in der Cafeteria.", "b": false}, {"t": "Abends Disco", "b": false}]}], "maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1}'::jsonb, 2),
    ('s1', 'Schreiben', 'Schreiben, Teil 1 (Formular)', 10, 'Ihr Freund, Vladimir Serjakov, 30 Jahre alt, kommt aus Sankt Petersburg in Russland und lebt seit einem Monat in Hamburg. Er hat eine neue Stelle bei TUI als Reiseleiter. Seit gestern hat er 39 Grad Fieber. Heute geht er zum Arzt. Helfen Sie Ihrem Freund und schreiben Sie die fünf fehlenden Informationen in das Formular.', 'writing', '{"bankTitle": "Formular", "bankImage": "img/m04-s1.png", "passages": [{"paragraphs": [{"t": "Patienteninformation Dr. Arnold Friedrich", "b": true}, {"t": "Ihr Freund, Vladimir Serjakov, 30 Jahre alt, kommt aus Sankt Petersburg in Russland und lebt seit einem Monat in Hamburg. Er hat eine neue Stelle bei TUI als Reiseleiter. Seit gestern hat er 39 Grad Fieber. Heute geht er zum Arzt.", "b": false}, {"t": "Helfen Sie Ihrem Freund und schreiben Sie die fünf fehlenden Informationen in das Formular.", "b": false}]}], "maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 5}'::jsonb, 3),
    ('s2', 'Schreiben', 'Schreiben, Teil 2', 10, 'Sie möchten umziehen und suchen eine neue Wohnung. Sie haben eine Anzeige gelesen. Schreiben Sie an den Vermieter, Herrn Mawat. Schreiben Sie zu jedem Punkt ein bis zwei Sätze (ca. 30 Wörter).', 'writing', '{"passages": [{"paragraphs": [{"t": "Schreibaufgabe", "b": true}, {"t": "Sie möchten umziehen und suchen eine neue Wohnung. Sie haben eine Anzeige gelesen.", "b": false}, {"t": "Schreiben Sie an den Vermieter, Herrn Mawat.", "b": false}, {"t": "Schreiben Sie zu jedem Punkt ein bis zwei Sätze (ca. 30 Wörter):", "b": false}, {"t": "• Warum schreiben Sie?", "b": false}, {"t": "• Wann können Sie die Wohnung sehen?", "b": false}, {"t": "• Adresse der Wohnung?", "b": false}]}], "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 10}'::jsonb, 4)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'goethe-a1' and t.slug = 'modell-04'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('lv1', '1', 'Andrea muss heute lange arbeiten.', null::jsonb, 1, null::jsonb, 0),
    ('lv1', '2', 'Sie möchte Julia morgen treffen. Text: **Notiz von Julia Berger** Liebe Frau Schmidt, wir fahren doch nächsten Montag in den Urlaub, in die Türkei. Können Sie bitte nach der Post und den Blumen sehen? Als Dankeschön möchte ich Sie gerne zu einem Essen bei mir zu Hause einladen. Wann haben Sie Zeit? Dann gebe ich Ihnen auch die Wohnungsschlüssel. Danke Julia Berger Aufgaben:', null::jsonb, 1, null::jsonb, 1),
    ('lv1', '3', 'Frau Berger braucht Hilfe.', null::jsonb, 1, null::jsonb, 2),
    ('lv1', '4', 'Frau Schmidt soll die Schlüssel abholen.', null::jsonb, 1, null::jsonb, 3),
    ('lv1', '5', 'Frau Berger möchte ein Essen machen.', null::jsonb, 1, null::jsonb, 4),
    ('lv2', '6', 'Sie möchten Urlaub am Meer machen.', '[{"key": "A", "text": "www.staedtereisen.de: Ferien in deutschen Städten. Lernen Sie Berlin, München, Köln und andere Städte in Deutschland kennen. Pauschalangebote mit Hotel und Reiseführer."}, {"key": "B", "text": "www.familienferien.de: Familienferien in der Natur an der Nordsee und Ostsee. Wassersport, Schwimmkurse und vieles mehr."}]'::jsonb, 1, null::jsonb, 0),
    ('lv2', '7', 'Sie suchen einen Fußballverein.', '[{"key": "A", "text": "www.fge.de: Werden Sie Mitglied in unserem Verein. Alle Sportarten - Alle Altersstufen. Jahresbeitrag 12 Euro pro Monat."}, {"key": "B", "text": "www.ballania.de: Bei uns können Sie alles machen, was mit Wassersport zu tun hat. Wasserball, Surfen, Wassergymnastik und vieles mehr. Einfach Mitglied werden."}]'::jsonb, 1, null::jsonb, 1),
    ('lv2', '8', 'Sie sind in Frankfurt und möchten am Abend in Wien sein. Sie möchten mit dem Zug fahren.', '[{"key": "A", "text": "www.reiseauskunft-bahn.de: Frankfurt ab 12.21, Wien an 19.48. Dauer 7:20, Gleis 5."}, {"key": "B", "text": "www.reiseportal.de: Frankfurt ab 23.00, Wien an 09.38. Dauer 10:38, Gleis 6."}]'::jsonb, 1, null::jsonb, 2),
    ('lv2', '9', 'Sie suchen einen billigen Fernseher.', '[{"key": "A", "text": "www.tv-und-partner.de: Günstig zu verkaufen: DVD-Recorder, 1 Jahr Garantie, mit diesem Gerät können Sie ohne Probleme Ihre Lieblingsprogramme im Fernsehen aufnehmen."}, {"key": "B", "text": "www.hifi-und-co.com: NEUERÖFFNUNG mit super Angeboten: Farbfernseher HD-tauglich zu günstigen Preisen."}]'::jsonb, 1, null::jsonb, 3),
    ('lv2', '10', 'Ihr Freund möchte Deutsch lernen. Er kann noch kein Deutsch.', '[{"key": "A", "text": "www.vhs.de: Nächste Woche beginnen unsere Anfängerkurse Deutsch als Fremdsprache. Schnell anmelden – es sind noch wenige Plätze frei."}, {"key": "B", "text": "www.sprachschule-mitte.de: Deutsch für den Beruf – schriftliche Geschäftskorrespondenz. Haben Sie schon Deutsch gelernt? (Stufe A2 oder B1?) Dann ist dieser Kurs der richtige für Sie!"}]'::jsonb, 1, null::jsonb, 4),
    ('lv3', '11', 'In der Schule können Sie am Samstag tanzen. Text: **Am Busbahnhof** Ab Januar günstige Busreisen in ganz Deutschland. Informationen am Busbahnhof, Schalter 12 Aufgaben:', null::jsonb, 1, null::jsonb, 0),
    ('lv3', '12', 'Im Januar gibt es Busfahrten nach Deutschland. Text: **Vor dem Ticketshop** Das Konzert der Toten Hosen in der Stadthalle ist ausverkauft. Aufgaben:', null::jsonb, 1, null::jsonb, 1),
    ('lv3', '13', 'Es gibt keine Karten mehr. Text: **Im Internet** Hessenticket der Deutschen Bahn Bis zu 5 Personen können an einem Tag durch ganz Hessen mit Bus oder Bahn fahren. Für nur 31,- Euro. Aufgaben:', null::jsonb, 1, null::jsonb, 2),
    ('lv3', '14', 'Das Hessenticket gibt es nur für Gruppen ab 5 Personen. Text: **Beim Arzt** In der Praxis sind Handys verboten. Aufgaben:', null::jsonb, 1, null::jsonb, 3),
    ('lv3', '15', 'Sie dürfen mit dem Handy nicht telefonieren.', null::jsonb, 1, null::jsonb, 4),
    ('s1', '16', 'Schreiben Sie die fünf fehlenden Informationen in das Formular (Aufgaben 16–20):', null::jsonb, 0, '{"points": ["(1) Postleitzahl, Wohnort: Hamburg / 20969 Hamburg", "(2) Alter: 30", "(3) Beruf: Reiseleiter", "(4) Seit wann sind Sie krank? — seit gestern / gestern", "(5) Was fehlt Ihnen? — Fieber / 39 Grad Fieber / hohes Fieber"]}'::jsonb, 0),
    ('s2', '21', 'Schreiben Sie eine E-Mail an den Vermieter, Herrn Mawat:', null::jsonb, 0, '{"minWords": 30, "points": ["Warum schreiben Sie?", "Wann können Sie die Wohnung sehen?", "Adresse der Wohnung?"]}'::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'goethe-a1' and t.slug = 'modell-04'
join sections s on s.test_id = t.id and s.section_id = v.section_id
on conflict (section_id, item_id) do update set text = excluded.text, options = excluded.options, points = excluded.points, meta = excluded.meta, sort = excluded.sort;

insert into item_answers (item_id, answer, explanation)
select i.id, v.answer, v.explanation
from (values
    ('lv1', '1', 'r', null),
    ('lv1', '2', 'r', null),
    ('lv1', '3', 'r', null),
    ('lv1', '4', 'f', null),
    ('lv1', '5', 'r', null),
    ('lv2', '6', 'B', null),
    ('lv2', '7', 'A', null),
    ('lv2', '8', 'A', null),
    ('lv2', '9', 'B', null),
    ('lv2', '10', 'A', null),
    ('lv3', '11', 'r', null),
    ('lv3', '12', 'f', null),
    ('lv3', '13', 'r', null),
    ('lv3', '14', 'f', null),
    ('lv3', '15', 'r', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'goethe-a1' and t.slug = 'modell-04'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;

-- ================= modell-05 · PAOLO =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('goethe-a1', 'modell-05', 'PAOLO', '17 Aufgaben · 45 Minuten',
        '[{"id": "block-lesen", "parts": ["lv1", "lv2", "lv3"], "title": "Lesen", "minutes": 25, "hint": "Aufgaben 1–15", "maxPoints": 15, "availablePoints": 15, "missing": 0}, {"id": "block-schreiben", "parts": ["s1", "s2"], "title": "Schreiben", "minutes": 20, "hint": "Aufgaben 16–21", "maxPoints": 15, "availablePoints": 15, "missing": 0}]'::jsonb, 17, true, 5)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('lv1', 'Lesen', 'Lesen, Teil 1', 10, 'Lesen Sie die beiden Texte und die Aufgaben 1 bis 5. Kreuzen Sie an: Richtig oder Falsch.', 'truefalse', '{"passages": [{"paragraphs": [{"t": "Entschuldigung für die Schule", "b": true}, {"t": "Sehr geehrte Frau Helbich,", "b": false}, {"t": "ich möchte meine Tochter Andrea entschuldigen. Sie hat Fieber und kann nicht zur Schule kommen. Nächste Woche kann sie wieder kommen. Können Sie mir bitte die Hausaufgaben sagen – am besten per Mail?", "b": false}, {"t": "Danke und viele Grüße", "b": false}, {"t": "Julia Schmidt", "b": false}]}], "maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1}'::jsonb, 0),
    ('lv2', 'Lesen', 'Lesen, Teil 2', 10, 'Lesen Sie die Texte und die Aufgaben 6 bis 10. Wo finden Sie Informationen? Kreuzen Sie an: a oder b.', 'mc', '{"maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1}'::jsonb, 1),
    ('lv3', 'Lesen', 'Lesen, Teil 3', 5, 'Lesen Sie die Texte und die Aufgaben 11 bis 15. Kreuzen Sie an: Richtig oder Falsch.', 'truefalse', '{"passages": [{"paragraphs": [{"t": "In der Sprachschule", "b": true}, {"t": "Griechischlehrer/in gesucht.", "b": false}, {"t": "Die Volkshochschule sucht ab sofort KursleiterInnen für Griechischkurse auf allen Stufen.", "b": false}]}], "maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 1}'::jsonb, 2),
    ('s1', 'Schreiben', 'Schreiben, Teil 1 (Formular)', 10, 'Ihr Freund Paolo Pellizzari aus Turin möchte mit seiner Familie (Ehefrau, drei Kinder, 2–7 Jahre alt) an der Ostsee Urlaub machen. Paolo hat drei Wochen Urlaub, vom 25.6. bis zum 15.7. Er sucht eine ruhige Wohnung am Meer, zwei Schlafzimmer, Wohnraum mit Küche, Bad. Paolo will mit dem Auto nach Deutschland kommen. Helfen Sie Ihrem Freund und schreiben Sie die fünf fehlenden Informationen in das Formular.', 'writing', '{"bankTitle": "Formular", "bankImage": "img/m05-s1.png", "passages": [{"paragraphs": [{"t": "Ferienwohnung an der Ostsee Reservierung", "b": true}, {"t": "Ihr Freund Paolo Pellizzari aus Turin möchte mit seiner Familie (Ehefrau, drei Kinder, 2–7 Jahre alt) an der Ostsee Urlaub machen. Paolo hat drei Wochen Urlaub, vom 25.6. bis zum 15.7. Er sucht eine ruhige Wohnung am Meer, zwei Schlafzimmer, Wohnraum mit Küche, Bad. Paolo will mit dem Auto nach Deutschland kommen.", "b": false}, {"t": "Helfen Sie Ihrem Freund und schreiben Sie die fünf fehlenden Informationen in das Formular.", "b": false}]}], "maxPoints": 5, "availablePoints": 5, "missing": 0, "pointsPerItem": 5}'::jsonb, 3),
    ('s2', 'Schreiben', 'Schreiben, Teil 2', 10, 'Sie haben bald Geburtstag und möchten am Freitag feiern. Sie möchten Ihre Freunde Linda und Martin aus dem Sprachkurs einladen. Schreiben Sie an Linda und Martin. Schreiben Sie zu jedem Punkt ein bis zwei Sätze (ca. 30 Wörter).', 'writing', '{"passages": [{"paragraphs": [{"t": "Schreibaufgabe", "b": true}, {"t": "Sie haben bald Geburtstag und möchten am Freitag feiern. Sie möchten Ihre Freunde Linda und Martin aus dem Sprachkurs einladen.", "b": false}, {"t": "Schreiben Sie an Linda und Martin.", "b": false}, {"t": "Schreiben Sie zu jedem Punkt ein bis zwei Sätze (ca. 30 Wörter):", "b": false}, {"t": "• Warum schreiben Sie?", "b": false}, {"t": "• Uhrzeit der Party?", "b": false}, {"t": "• Musik?", "b": false}]}], "maxPoints": 10, "availablePoints": 10, "missing": 0, "pointsPerItem": 10}'::jsonb, 4)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'goethe-a1' and t.slug = 'modell-05'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('lv1', '1', 'Das Kind von Frau Schmidt ist krank.', null::jsonb, 1, null::jsonb, 0),
    ('lv1', '2', 'Frau Schmidt möchte die Hausaufgaben wissen. Text: **Urlaubsplanung an der Nordsee** Hallo Robert, wie geht es dir? Du, Robert, wir möchten nächsten Sommer an der Nordsee Urlaub machen. Du warst doch letzten Sommer dort. Kannst du mir ein paar Tipps geben, kannst du mir etwas empfehlen? Vielleicht fahren wir auch ein paar Tage nach Hamburg. Kennst du gute Hotels? Welche Sehenswürdigkeiten gibt es dort? Wir können uns ja bald mal wieder treffen. Dann lade ich dich zu einem Glas Wein ein. Viele Grüße Fabian Aufgaben:', null::jsonb, 1, null::jsonb, 1),
    ('lv1', '3', 'Fabian sucht Informationen über Urlaub an der Nordsee.', null::jsonb, 1, null::jsonb, 2),
    ('lv1', '4', 'Robert und Fabian waren noch nie an der Nordsee.', null::jsonb, 1, null::jsonb, 3),
    ('lv1', '5', 'Fabian möchte Robert in Hamburg treffen.', null::jsonb, 1, null::jsonb, 4),
    ('lv2', '6', 'Sie suchen Informationen über München.', '[{"key": "A", "text": "www.münchen-outdoor.de: Ihr Outdoor-Laden jetzt auch in München. Alles für Ihren Urlaub. Campingsachen, Schlafsäcke, Rucksäcke, Fahrräder."}, {"key": "B", "text": "www.meine-stadt.de: Klicken Sie auf eine Stadt in Deutschland. Klicken Sie dann auf: Hotels – Sehenswürdigkeiten – Was ist los in ..."}]'::jsonb, 1, null::jsonb, 0),
    ('lv2', '7', 'Sie möchten in einem Restaurant Fisch essen.', '[{"key": "A", "text": "www.viva-andaluz.com: Essen in angenehmer Atmosphäre. Fleisch- und Fischspezialitäten aus dem Mittelmeerraum. Öffnungszeiten täglich 18–24 Uhr."}, {"key": "B", "text": "www.tapas-co.de: Tapas und Co. Lebensmittelimport aus Spanien und Südamerika. Fische und Meeresfrüchte. Auch online bestellen."}]'::jsonb, 1, null::jsonb, 1),
    ('lv2', '8', 'Sie machen im Sommer einen Deutschkurs in Berlin. Sie suchen ein billiges Zimmer.', '[{"key": "A", "text": "www.wohnungsfinder.de: Supergünstige 1-Zimmer-Wohnungen und Apartments überall in Deutschland. Angebote gibt es jeden Monat."}, {"key": "B", "text": "www.wohnungsbörse.de: Suche dringend für Juli kleine Wohnung oder Zimmer in Berlin – gerne auch möbliert. Bitte rufen Sie mich an: 0033-1-5678888."}]'::jsonb, 1, null::jsonb, 2),
    ('lv2', '9', 'Sie suchen eine Arbeit. Sie können nicht Auto fahren.', '[{"key": "A", "text": "www.euro-pizza.de: EURO-PIZZA sucht Fahrer für die Auslieferung von Pizzen und Getränken. Ab sofort."}, {"key": "B", "text": "www.praxis-markt.de: PRAXIS-MARKT sucht ab sofort Verkäufer/Verkäuferinnen. Arbeitszeiten flexibel, gute Bezahlung."}]'::jsonb, 1, null::jsonb, 3),
    ('lv2', '10', 'Sie suchen einen neuen Kühlschrank. Er soll nicht mehr als 300 Euro kosten.', '[{"key": "A", "text": "www.alles-für-die-küche.de: Superangebote von Ihrem Küchenspezialisten. Alles, was Sie in der Küche brauchen, zu günstigen Preisen."}, {"key": "B", "text": "www.küchenchef.de: Keine Idee, was Sie kochen können? Mehr als 300 Kochrezepte auf dieser Seite. Einfach ausprobieren."}]'::jsonb, 1, null::jsonb, 4),
    ('lv3', '11', 'Hier gibt es Sprachkurse für Griechen. Text: **An der Post** Räder abstellen verboten. Aufgaben:', null::jsonb, 1, null::jsonb, 0),
    ('lv3', '12', 'Sie dürfen hier keine Räder abstellen. Text: **Beim Zahnarzt** Dr. Kern – Sprechstunde Mo–Di, Do–Fr 9–12 Uhr, 14–18 Uhr Mi 9–12 Uhr. Aufgaben:', null::jsonb, 1, null::jsonb, 1),
    ('lv3', '13', 'Am Vormittag ist die Praxis immer geöffnet. Text: **Im Kaufhaus** Weihnachten steht vor der Tür. Haben Sie schon alle Geschenke? An den vier Sonntagen vor Weihnachten haben wir für Sie geöffnet. Aufgaben:', null::jsonb, 1, null::jsonb, 2),
    ('lv3', '14', 'Am Sonntag vor Weihnachten können Sie einkaufen. Text: **An einer Videothek** Videothek SATURN Neueröffnung am 1. Juni. In zwei Wochen können Sie in der Heidestraße DVDs kaufen und ausleihen. Aufgaben:', null::jsonb, 1, null::jsonb, 3),
    ('lv3', '15', 'Sie können ab sofort in der Heidestraße DVDs bekommen.', null::jsonb, 1, null::jsonb, 4),
    ('s1', '16', 'Schreiben Sie die fünf fehlenden Informationen in das Formular (Aufgaben 16–20):', null::jsonb, 0, '{"points": ["(1) Anzahl der Personen: 5", "(2) davon Kinder: 3", "(3) Brauchen Sie eine Küche? — ja / Ja", "(4) Abreise: 15. Juli / 15.7. / 15.07.", "(5) Wie reisen Sie an? (Flugzeug, Zug, Auto): Auto / mit dem Auto"]}'::jsonb, 0),
    ('s2', '21', 'Schreiben Sie eine Einladung an Ihre Freunde Linda und Martin:', null::jsonb, 0, '{"minWords": 30, "points": ["Warum schreiben Sie?", "Uhrzeit der Party?", "Musik?"]}'::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'goethe-a1' and t.slug = 'modell-05'
join sections s on s.test_id = t.id and s.section_id = v.section_id
on conflict (section_id, item_id) do update set text = excluded.text, options = excluded.options, points = excluded.points, meta = excluded.meta, sort = excluded.sort;

insert into item_answers (item_id, answer, explanation)
select i.id, v.answer, v.explanation
from (values
    ('lv1', '1', 'r', null),
    ('lv1', '2', 'r', null),
    ('lv1', '3', 'r', null),
    ('lv1', '4', 'f', null),
    ('lv1', '5', 'f', null),
    ('lv2', '6', 'B', null),
    ('lv2', '7', 'A', null),
    ('lv2', '8', 'A', null),
    ('lv2', '9', 'B', null),
    ('lv2', '10', 'A', null),
    ('lv3', '11', 'f', null),
    ('lv3', '12', 'r', null),
    ('lv3', '13', 'r', null),
    ('lv3', '14', 'r', null),
    ('lv3', '15', 'f', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'goethe-a1' and t.slug = 'modell-05'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;

commit;
