-- جزء 3 من 4 — نماذج modell-09–modell-12
-- مولّد من supabase/seed/b1.sql بـtools/split_seed.sh — لا تعدّله بالإيد
-- آمن للإعادة: شغّله مرتين ما بيغيّر شي.

begin;

-- مولّد من data بـtools/export_sql.py — لا تعدّله بالإيد

insert into levels (id, title, sort, published) values ('b1', 'telc Deutsch B1', 0, true)
on conflict (id) do update set title = excluded.title;

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


commit;
