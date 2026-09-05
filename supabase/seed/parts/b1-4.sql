-- جزء 4 من 4 — نماذج modell-13–modell-16
-- مولّد من supabase/seed/b1.sql بـtools/split_seed.sh — لا تعدّله بالإيد
-- آمن للإعادة: شغّله مرتين ما بيغيّر شي.

begin;

-- مولّد من data بـtools/export_sql.py — لا تعدّله بالإيد

insert into levels (id, title, sort, published) values ('b1', 'telc Deutsch B1', 0, true)
on conflict (id) do update set title = excluded.title;

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
