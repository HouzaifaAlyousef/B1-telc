-- جزء 4 من 4 — نماذج modell-16–modell-17
-- مولّد من supabase/seed/b1.sql بـtools/split_seed.sh — لا تعدّله بالإيد
-- آمن للإعادة: شغّله مرتين ما بيغيّر شي.

begin;

-- مولّد من data بـtools/export_sql.py — لا تعدّله بالإيد

insert into levels (id, title, sort, published, provider, stufe) values ('b1', 'telc Deutsch B1', 0, true, 'telc', 'B1')
on conflict (id) do update set title = excluded.title,
  provider = coalesce(levels.provider, excluded.provider),
  stufe    = coalesce(levels.stufe,    excluded.stufe);

-- ================= modell-16 · VIKTOR =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('b1', 'modell-16', 'VIKTOR', '61 Aufgaben · 150 Minuten',
        '[{"id": "block-lv-sb", "title": "Leseverstehen und Sprachbausteine", "minutes": 90, "hint": "Aufgaben 1–40", "parts": ["lv1", "lv2", "lv3", "sb1", "sb2"], "maxPoints": 105.0, "availablePoints": 105.0, "missing": 0}, {"id": "block-hv", "title": "Hörverstehen", "minutes": 30, "hint": "Aufgaben 41–60", "parts": ["hv1", "hv2", "hv3"], "maxPoints": 75.0, "availablePoints": 75.0, "missing": 0}, {"id": "block-sa", "title": "Schriftlicher Ausdruck", "minutes": 30, "hint": "", "parts": ["sa"], "maxPoints": 45.0, "availablePoints": 45, "missing": 0}]'::jsonb, 61, true, 16)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('lv1', 'Leseverstehen', 'Leseverstehen, Teil 1', 15, 'Lesen Sie die Überschriften a–j und die Texte 1–5. Finden Sie für jeden Text die passende Überschrift. Jede Überschrift passt nur einmal.', 'matching', '{"bank": [{"key": "A", "text": "Nur wenige lesen im Zug"}, {"key": "B", "text": "Bahnfahren bei älteren Menschen immer beliebter"}, {"key": "C", "text": "Per Internet leichter ans Ziel"}, {"key": "D", "text": "Männer fahren besser"}, {"key": "E", "text": "Hilfe beim Reisen mit der Bahn"}, {"key": "F", "text": "Frauen finden den richtigen Weg"}, {"key": "G", "text": "Neuer Deutschkurs in Solothurn"}, {"key": "H", "text": "Jetzt wird auch im Zug gelernt"}, {"key": "I", "text": "Lesen im Zug ist beliebt"}], "bankTitle": "Überschriften", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 0),
    ('lv2', 'Leseverstehen', 'Leseverstehen, Teil 2', 20, 'Lesen Sie den Text und die Aufgaben 6–10. Welche Lösung (A, B oder C) ist jeweils richtig?', 'mc', '{"passages": [{"paragraphs": [{"t": "Weg von einer Adresse zu einer anderen möglich. Der elektronische Fahrplan führt Sie", "b": false}, {"t": "automatisch zum Haltepunkt des öffentlichen Verkehrs der am nächsten bei der Zieladresse", "b": false}, {"t": "liegt. Das ist mit dem Verkehrsleitssystem für Autos vergleichbar, das Sie aber auch in der", "b": false}, {"t": "Verkehrten Richtung durch Einbahnstraßen führen kann. Beim öffentlichen Verkehr kommt", "b": false}, {"t": "das glücklicherweise nicht vor.", "b": false}, {"t": "ist jeweils richtig?", "b": false}, {"t": "Neue Berufe", "b": true}, {"t": "Raumberater für harmonisches Wohnen", "b": true}, {"t": "Räume nach der chinesischen Lehre Feng Shui zu gestalten, damit sich die Menschen wohl Fühlen das ist der Beruf von Iris Eigenmann", "b": false}, {"t": "Seit knapp einem Jahr bin ich nun selbstständig und bin voller Energie. So stehe ich jeden Tag mit einem Lächeln auf und gehe abends wieder mit einem Lächeln ins Bett. Die diplomierte Raumberaterin Iris Eigenmann ist von ihrem Beruf sichtlich begeistert. Da viele mit dem Wort Fengshui nichts anfangen können, bezeichnet sie sich selbst als Raumberaterin für harmonisches Wohnungen aber auch Büros und andere Arbeitsplätze so einzurichten, dass sich Menschen in diesen Räumen wohl fühlen können.", "b": false}, {"t": "Ursprünglich ist Frau Eigenmann gelernte Hochbauzeichnerin und hat Jahrelang Bauprojekte geleitet. Diese Erfahrungen mit Architektur und Wohnbau helfen ihr nun sehr bei ihrer Tätigkeit als Raumberaterin. Ihre Arbeit besteht darin, den optimalen Energiefluss eines Wohn- oder Arbeitsumfeldes zu finden. Sie macht individuelle Vorschläge für die Raumanordnung, die Farbwahl der Wände oder für die Verwendung von Baumaterialien. Ich habe alle Ideen zuerst bei mir zu Hause ausprobiert und war selbst überrascht von der positiven Wirkung, erzählt sie begeistert.", "b": false}, {"t": "Eine Raumberaterin arbeitet in der Regel folgendermaßen: Zuerst besprechen die Leute mit Frau Eigenmann, warum sie sich in ihrer Wohnung nicht wohl fühlen und wie sie ihren Wohnraum verbessen möchten. Dann bittet die Beraterin ihre Kunden, ihr einen genauen Plan der Wohnung zu schicken, auf dem sie die Möbelaufstellung und die genaue Ausrichtung des Hauses sehen kann. Daraufhin macht Frau Eigenmann einen detaillierten Wohnungsplan mit ausführlichen Erklärungen, wie man die Räume optimal einrichtet, um sich darin zufrieden zu fühlen. Für die Erstellung eines solchen Planes benötigt sie nach eigener Aussage je nach Größe der Wohnung oder des Gebäudes zwischen einem halben und einem ganzen Tag.", "b": false}, {"t": "Anschließend geht Iris Eigenmann zu den Leuten nach Hause, um die Situation vor Ort zu analysieren und Verbesserungsmöglichkeiten aufzuzeigen.", "b": false}, {"t": "Auch immer mehr Firmen suchen Rat bei einer Raumberaterin meistens dann, wenn das Unternehmen nicht mehr so erfolgreich arbeitet. Iris Eigenmann versucht dann, das Arbeitsumfeld so zu verändern, dass sich Kunden und Angestellte wohler fühlen. Das führt in den meisten Fällen dazu, dass auch die Geschäfte wieder besser gehen. Der Preis für die Raumberatung wird je nach Aufwand mit dem Kunden gemeinsam bestimmt. Das Geld aber ist für Frau Eigenmann weniger wichtig als die Möglichkeit, den Menschen zu helfen und ihre positiven Erfahrungen weiterzugeben.", "b": false}, {"t": "p g g", "b": false}, {"t": "Das persönliche Ziel der Feng-Shui-Raumberaterin für die Zukunft ist es, vermehrt auch im sozialen Bereich zu wirken zum Beispiel in Krankenhäusern oder Altersheimen. Sie meint, dass mit einfachen Maßnahmen dort die Lebensqualität der Menschen erheblich verbessert werden könnte.", "b": false}]}], "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 1),
    ('lv3', 'Leseverstehen', 'Leseverstehen, Teil 3', 20, 'Lesen Sie die Situationen 11–20 und die Anzeigen im Bild. Finden Sie für jede Situation die passende Anzeige. Wenn Sie keine passende Anzeige finden, wählen Sie X.', 'matching', '{"bank": [{"key": "A", "text": ""}, {"key": "B", "text": ""}, {"key": "C", "text": ""}, {"key": "D", "text": ""}, {"key": "E", "text": ""}, {"key": "F", "text": ""}, {"key": "G", "text": ""}, {"key": "H", "text": ""}, {"key": "I", "text": ""}, {"key": "J", "text": ""}, {"key": "K", "text": ""}, {"key": "L", "text": ""}, {"key": "X", "text": ""}], "bankTitle": "Anzeigen", "bankImage": "img/m16-lv3.jpg", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 2.5}'::jsonb, 2),
    ('sb1', 'Sprachbausteine', 'Sprachbausteine, Teil 1', 20, 'Lesen Sie den Text und schließen Sie die Lücken 21–30. Welche Lösung (A, B oder C) ist jeweils richtig?', 'mc', '{"passages": [{"paragraphs": [{"t": "Liebe Dominique,", "b": true}, {"t": "da ich dich telefonisch nicht erreiche, auch nicht per E-Mail, schreibe ich dir einen Brief. Es ist nämlich etwas ganz Besonderes (21) : Stelle (22) vor, ich habe die Stelle bei der EU in Brüssel bekommen!", "b": false}, {"t": "Du weißt noch: Es gab ungefähr 300 Bewerber, und unter denen (23) die besten ausgesucht. Ich hatte mich auf das Vorstellungsgespräch schon (24) Zeit vorher vorbereitet. Trotzdem ohne meine Sprachkenntnisse und meine Auslandserfahrung (25) ich die Stelle sicher nicht bekommen. Aber ein bisschen Glück braucht man auch, (26) so etwas gelingt.", "b": false}, {"t": "Nun bitte ich dich (27) ein paar gute Tipps. Vielleicht kennst du auch jemanden, von(28) ich Informationen über das Leben in Belgien bekommen kann? Ich würde dich am liebsten kürz (29) , um mit dir persönlich zu sprechen. Geht das vielleicht (30) zwei Wochen, Z.B. am übernächsten Wochenende? Bitte gib mir Beschreiben.", "b": false}, {"t": "Herzlich Grüße", "b": true}, {"t": "Katie", "b": true}]}], "maxPoints": 15.0, "availablePoints": 15.0, "missing": 0, "pointsPerItem": 1.5}'::jsonb, 3),
    ('sb2', 'Sprachbausteine', 'Sprachbausteine, Teil 2', 15, 'Lesen Sie den Text und schließen Sie die Lücken 31–40. Benutzen Sie die Wörter aus der Liste. Jedes Wort passt nur einmal.', 'wordbank', '{"bank": [{"key": "A", "text": "AUF"}, {"key": "B", "text": "DAFÜR"}, {"key": "C", "text": "DARÜBER"}, {"key": "D", "text": "HÄTTE"}, {"key": "E", "text": "KANN"}, {"key": "F", "text": "KÖNNEN"}, {"key": "G", "text": "MÖCHTE"}, {"key": "H", "text": "SEHR"}, {"key": "I", "text": "SEIT"}, {"key": "J", "text": "SPRECHEN"}, {"key": "K", "text": "VOR"}, {"key": "L", "text": "WENIG"}, {"key": "M", "text": "WIE"}, {"key": "N", "text": "WIE VIELE"}, {"key": "O", "text": "WISSEN"}], "bankTitle": "Wörterliste", "passages": [{"paragraphs": [{"t": "Sehr geehrte Frau Campe,", "b": false}, {"t": "mein Deutschlehrer hat mich (31) informiert, dass Sie in St. Andreasburg Intensivkurse in Deutsch anbieten.", "b": false}, {"t": "Ich lerne (32) zwei Jahren Deutsch in Yverden, einer kleinen Stadt in der Westschweiz. Es gefällt mir hier, aber ich lebe in einer französischsprachigen Region und auch meine Arbeitskollegen (33) nur Französisch (oder Englisch) mit mir. So habe ich einfach zu (34). Gelegenheit, Deutsch zu sprechen. Deshalb interessiere ich mich (35) für Ihre Intensivkurse. Die Oberpfalz (36) ich schon seit langem einmal kennen lernen. Ich habe schon viel darüber gehört und gelesen, war aber selber noch nie dort.", "b": false}, {"t": "Bevor ich mich für einen Sprachkurs in St. Anderasburg entscheide, (37) ich noch einige", "b": false}, {"t": "Fragen. Bieten Sie auch Sprachkurse an, in denen man international anerkannte Diplome erwerben kann? (38). Studenten nehmen an einem Kurs teil? Kann man abends auch noch individuell mit dem Computer weiterlernen? Muss man für die Exkursionen extra bezahlen oder sind die Kosten (39) schon im Kursgeld enthalten?", "b": false}, {"t": "Für Ihre Antwort (40) meine Fragen bedanke ich mich vielmals.", "b": false}, {"t": "Mit freundlichen Grüßen Nadia Grade", "b": false}]}], "maxPoints": 15.0, "availablePoints": 15.0, "missing": 0, "pointsPerItem": 1.5}'::jsonb, 4),
    ('hv1', 'Hörverstehen', 'Hörverstehen, Teil 1', 8, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 5),
    ('hv2', 'Hörverstehen', 'Hörverstehen, Teil 2', 14, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 2.5}'::jsonb, 6),
    ('hv3', 'Hörverstehen', 'Hörverstehen, Teil 3', 8, 'Entscheiden Sie, ob die Aussagen richtig oder falsch sind.', 'truefalse', '{"note": "Hinweis: Die Hörtexte sind in der PDF-Vorlage nicht enthalten. Dieser Teil dient zum Wiederholen der Aussagen und zum Vergleich mit der Lösung — nicht zum Hörtraining.", "maxPoints": 25.0, "availablePoints": 25.0, "missing": 0, "pointsPerItem": 5.0}'::jsonb, 7),
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
    ('lv2', '10', 'Frau Eigenmann möchte in Zukunft', '[{"key": "A", "text": "als Krankenschwester arbeiten."}, {"key": "B", "text": "mit ihre Arbeit das Leben alter und kranker Menschen verbessern."}, {"key": "C", "text": "viel Geld verdienen."}]'::jsonb, 5.0, null::jsonb, 4),
    ('lv3', '11', 'Sie interessiert sich für eine neue Waschmaschine.', null::jsonb, 2.5, null::jsonb, 0),
    ('lv3', '12', 'Ihr Freund sucht einen Praktikumsplatz bei einer Zeitung.', null::jsonb, 2.5, null::jsonb, 1),
    ('lv3', '13', 'Sie wollen ein neues Musikinstrument spielen lernen.', null::jsonb, 2.5, null::jsonb, 2),
    ('lv3', '14', 'In Ihrer Wohnung gibt es Probleme mit dem Wasser in Bad und Küche und Sie wollen das verändern.', null::jsonb, 2.5, null::jsonb, 3),
    ('lv3', '15', 'Ihre Wohnung ist immer zu kalt und Sie wollen das ändern.', null::jsonb, 2.5, null::jsonb, 4),
    ('lv3', '16', 'Sie suchen einen Klavierlehrer für Ihre Tochter.', null::jsonb, 2.5, null::jsonb, 5),
    ('lv3', '17', 'Sie möchten lernen Kleider selber zu machen.', null::jsonb, 2.5, null::jsonb, 6),
    ('lv3', '18', 'In Ihrer Wohnung gibt es Probleme mit feuchten Wänden.', null::jsonb, 2.5, null::jsonb, 7),
    ('lv3', '19', 'Sie möchten einen schönen, alten Schrank kaufen.', null::jsonb, 2.5, null::jsonb, 8),
    ('lv3', '20', 'Sie wollen lernen, wie man kleine Geschichten auf Deutsch schreibt und suchen einen passenden Kurs.', null::jsonb, 2.5, null::jsonb, 9),
    ('sb1', '21', '… ich dir einen Brief. Es ist nämlich etwas ganz Besonderes (21) : Stelle (22) vor, ich habe die Stelle bei der EU in …', '[{"key": "A", "text": "geschah"}, {"key": "B", "text": "geschehen"}, {"key": "C", "text": "geschieht"}]'::jsonb, 1.5, null::jsonb, 0),
    ('sb1', '22', '… etwas ganz Besonderes (21) : Stelle (22) vor, ich habe die Stelle bei der EU in Brüssel bekommen! …', '[{"key": "A", "text": "dich"}, {"key": "B", "text": "dir"}, {"key": "C", "text": "Du"}]'::jsonb, 1.5, null::jsonb, 1),
    ('sb1', '23', '… Es gab ungefähr 300 Bewerber, und unter denen (23) die besten ausgesucht. Ich hatte mich auf das …', '[{"key": "A", "text": "halten"}, {"key": "B", "text": "wären"}, {"key": "C", "text": "wurden"}]'::jsonb, 1.5, null::jsonb, 2),
    ('sb1', '24', '… Ich hatte mich auf das Vorstellungsgespräch schon (24) Zeit vorher vorbereitet. Trotzdem ohne meine …', '[{"key": "A", "text": "lange"}, {"key": "B", "text": "langem"}, {"key": "C", "text": "langer"}]'::jsonb, 1.5, null::jsonb, 3),
    ('sb1', '25', '… Trotzdem – ohne meine Sprachkenntnisse und meine Auslandserfahrung (25) ich die Stelle sicher nicht bekommen. …', '[{"key": "A", "text": "habe"}, {"key": "B", "text": "hätte"}, {"key": "C", "text": "würde"}]'::jsonb, 1.5, null::jsonb, 4),
    ('sb1', '26', '… Aber ein bisschen Glück braucht man auch, (26) so etwas gelingt. Nun bitte ich dich (27) ein paar …', '[{"key": "A", "text": "als"}, {"key": "B", "text": "damit"}, {"key": "C", "text": "ob"}]'::jsonb, 1.5, null::jsonb, 5),
    ('sb1', '27', '… man auch, (26) so etwas gelingt. Nun bitte ich dich (27) ein paar gute Tipps. Vielleicht kennst du auch jemanden, …', '[{"key": "A", "text": "für"}, {"key": "B", "text": "über"}, {"key": "C", "text": "um"}]'::jsonb, 1.5, null::jsonb, 6),
    ('sb1', '28', '… Vielleicht kennst du auch jemanden, von (28) ich Informationen über das Leben in Belgien bekommen kann? …', '[{"key": "A", "text": "dem"}, {"key": "B", "text": "den"}, {"key": "C", "text": "denen"}]'::jsonb, 1.5, null::jsonb, 7),
    ('sb1', '29', '… Ich würde dich am liebsten kurz (29) , um mit dir persönlich zu sprechen. Geht das vielleicht (30) …', '[{"key": "A", "text": "getroffen"}, {"key": "B", "text": "treffe"}, {"key": "C", "text": "treffen"}]'::jsonb, 1.5, null::jsonb, 8),
    ('sb1', '30', '… , um mit dir persönlich zu sprechen. Geht das vielleicht (30) zwei Wochen, Z.B. am übernächsten Wochenende? Bitte gib …', '[{"key": "A", "text": "bis"}, {"key": "B", "text": "in"}, {"key": "C", "text": "an"}]'::jsonb, 1.5, null::jsonb, 9),
    ('sb2', '31', '… Sehr geehrte Frau Campe, mein Deutschlehrer hat mich (31) informiert, dass Sie in St. Andreasburg Intensivkurse in …', null::jsonb, 1.5, null::jsonb, 0),
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
    ('hv2', '55', 'Bis die Freie Filmbühne schließt, werden keine Filme mehr gezeigt.', null::jsonb, 2.5, null::jsonb, 9),
    ('hv3', '56', 'Wegen des Nebels sollte man heute nicht nach München fahren.', null::jsonb, 5.0, null::jsonb, 0),
    ('hv3', '57', 'In der Buchabteilung ist ein berühmter Autor zu Gast.', null::jsonb, 5.0, null::jsonb, 1),
    ('hv3', '58', 'Der Zug nach Wein fährt heute von einem anderen Bahnsteig ab.', null::jsonb, 5.0, null::jsonb, 2),
    ('hv3', '59', 'Die Firma ist mit der Straßenbahn in Richtung Königsplatz zu erreichen.', null::jsonb, 5.0, null::jsonb, 3),
    ('hv3', '60', 'Ab nächsten Montag kann man wieder einen Termin vereinbaren..', null::jsonb, 5.0, null::jsonb, 4),
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
    ('lv2', '10', 'B', null),
    ('lv3', '11', 'L', null),
    ('lv3', '12', 'D', null),
    ('lv3', '13', 'K', null),
    ('lv3', '14', 'C', null),
    ('lv3', '15', 'E', null),
    ('lv3', '16', 'X', null),
    ('lv3', '17', 'H', null),
    ('lv3', '18', 'G', null),
    ('lv3', '19', 'B', null),
    ('lv3', '20', 'X', null),
    ('sb1', '21', 'B', null),
    ('sb1', '22', 'B', null),
    ('sb1', '23', 'C', null),
    ('sb1', '24', 'C', null),
    ('sb1', '25', 'B', null),
    ('sb1', '26', 'B', null),
    ('sb1', '27', 'C', null),
    ('sb1', '28', 'C', null),
    ('sb1', '29', 'C', null),
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
    ('hv2', '55', 'f', null),
    ('hv3', '56', 'f', null),
    ('hv3', '57', 'r', null),
    ('hv3', '58', 'f', null),
    ('hv3', '59', 'r', null),
    ('hv3', '60', 'r', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'b1' and t.slug = 'modell-16'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;

-- ================= modell-17 · TANJA =================
insert into tests (level_id, slug, title, subtitle, blocks, aufgaben, published, sort)
values ('b1', 'modell-17', 'TANJA', '41 Aufgaben · 120 Minuten',
        '[{"id": "block-lv-sb", "parts": ["lv1", "lv2", "lv3", "sb1", "sb2"], "title": "Leseverstehen und Sprachbausteine", "minutes": 90, "hint": "Aufgaben 1–40", "maxPoints": 105, "missing": 0, "availablePoints": 105}, {"id": "block-sa", "parts": ["sa"], "title": "Schriftlicher Ausdruck", "minutes": 30, "hint": "", "maxPoints": 45, "missing": 0, "availablePoints": 45}]'::jsonb, 41, true, 17)
on conflict (level_id, slug) do update set title = excluded.title, subtitle = excluded.subtitle, blocks = excluded.blocks, aufgaben = excluded.aufgaben, sort = excluded.sort;

insert into sections (test_id, section_id, "group", title, minutes, instruction, format, config, sort)
select t.id, v.section_id, v.grp, v.title, v.minutes, v.instruction, v.format, v.config, v.sort
from (values
    ('lv1', 'Leseverstehen', 'Leseverstehen, Teil 1', 15, 'Lesen Sie die Überschriften a–j und die Texte 1–5. Finden Sie für jeden Text die passende Überschrift. Jede Überschrift passt nur einmal.', 'matching', '{"bank": [{"key": "A", "text": "Schweizer sollen gesünder leben"}, {"key": "B", "text": "Neu im Trend: Jung und gesund – mit Schokolade!"}, {"key": "C", "text": "Studie zeigt: Heiraten macht dick"}, {"key": "D", "text": "Japanische Studie: Vielschläfer leben länger"}, {"key": "E", "text": "Die Mehrheit der Schweizer treibt aktiv Sport"}, {"key": "F", "text": "Statistik: Unverheiratete haben oft ein paar Kilos zu viel"}, {"key": "G", "text": "Teures Essen für mehr Jugend und Schönheit"}, {"key": "H", "text": "USA: Nachfrage nach teuren Lebensmitteln geht zurück"}, {"key": "I", "text": "Schokolade essen – jung bleiben"}, {"key": "J", "text": "Weniger schlafen – länger leben"}], "bankTitle": "Überschriften", "maxPoints": 25, "availablePoints": 25, "missing": 0, "pointsPerItem": 5}'::jsonb, 0),
    ('lv2', 'Leseverstehen', 'Leseverstehen, Teil 2', 20, 'Lesen Sie den Text und die Aufgaben 6–10. Welche Lösung (A, B oder C) ist jeweils richtig?', 'mc', '{"passages": [{"paragraphs": [{"t": "Abenteuer Weltumrundung", "b": true}, {"t": "Von Antje Blinda", "b": true}, {"t": "Co2-Ausstoß: null. Geplante Strecke: einmal um die Welt. Endlich wird der Traum von Louis Palmer wahr: Der Schweizer startet mit seinem Auto, das mit Sonnenenergie fährt, zur Weltumrundung. Er will damit zeigen, dass Autofahren auch geht, ohne der Umwelt zu schaden.", "b": false}, {"t": "Entwickelt für mich ein Fahrzeug für eine Weltreise, das mit Sonnenenergie fährt, forderte Louis Palmer Studenten an Schweizer Universitäten auf. Das war vor drei Jahren. Heute ist das Auto fertig: ein dreirädriges Fahrzeug mit zwei Sitzplätzen. Und die Weltreise? Am 3. Juli starten er und sein 7-köpfiges Team in Luzern: Das Auto soll als erstes Solarfahrzeug die Welt umrunden.", "b": false}, {"t": "Die ganze Welt wartet auf revolutionäre Erfindungen für ein umweltbewusstes Auto, sagt der Schweizer, ich will darauf aufmerksam machen, dass die technischen Lösungen schon jetzt vorhanden sind. Mit 14 Jahren hatte Louis den Entschluss gefasst: Gegen die Veränderung des Klimas muss etwas getan werden. Die Lösung hatte er auch schon: Mit kräftigen Strichen zeichnete er ein Rennauto, verziert mit lachenden Sonnen. Der Rest war nur eine Frage der Organisation und der konsequenten Lebensplanung. Ich unterteile mein Leben in drei Phasen, sagt Palmer und lacht über sich selbst: zwischen 20 und 30 die Welt kennen lernen, zwischen 30 und 40 die Welt aufmerksam machen und zwischen 40 und 50 die Welt verändern.", "b": false}, {"t": "Phase eins begann mit 23 Jahren: Er zog aus, um 50 Länder auf allen Kontinenten zu bereisen: Anstatt an die Uni zu gehen, habe ich die Welt studiert. Mit dem Fahrrad fuhr er von Kenia nach Kapstadt, mit einem Segelflugzeug überflog er Südamerika und als Fotograf reiste er mehrmals nach Afghanistan.", "b": false}, {"t": "Phase zwei startete vor drei Jahren: Palmer konnte Studenten von vier Universitäten gewinnen, die für ihn das Auto bauten. Schwierig war es aber, Firmen und private Sponsoren für die finanzielle Unterstützung zu finden, meint Palmer. Doch auch das hat dann schließlich geklappt.", "b": false}, {"t": "Nun ist Palmer bereit für die Tour. Ich habe keine Ahnung, was auf uns zukommt, sagt der erfahrene Globetrotter, der sechs Sprachen spricht. Ich habe schon etwas Angst, z.B. vor dem Straßenverkehr in Millionenstädten oder unvorhersehbaren Zwischenfällen. Das Schlimmste ist aber, wenn jeder Tag wie der andere ist. In den nächsten 16 Monaten wird es dazu nicht kommen.", "b": false}]}], "maxPoints": 25, "availablePoints": 25, "missing": 0, "pointsPerItem": 5}'::jsonb, 1),
    ('lv3', 'Leseverstehen', 'Leseverstehen, Teil 3', 20, 'Lesen Sie die Situationen 11–20 und die Anzeigen im Bild. Finden Sie für jede Situation die passende Anzeige. Wenn Sie keine passende Anzeige finden, wählen Sie X.', 'matching', '{"bank": [{"key": "A", "text": ""}, {"key": "B", "text": ""}, {"key": "C", "text": ""}, {"key": "D", "text": ""}, {"key": "E", "text": ""}, {"key": "F", "text": ""}, {"key": "G", "text": ""}, {"key": "H", "text": ""}, {"key": "I", "text": ""}, {"key": "J", "text": ""}, {"key": "K", "text": ""}, {"key": "L", "text": ""}, {"key": "X", "text": ""}], "bankTitle": "Anzeigen", "bankImage": "img/m17-lv3.jpg", "maxPoints": 25, "availablePoints": 25, "missing": 0, "pointsPerItem": 2.5}'::jsonb, 2),
    ('sb1', 'Sprachbausteine', 'Sprachbausteine, Teil 1', 20, 'Lesen Sie den Text und schließen Sie die Lücken 21–30. Welche Lösung (A, B oder C) ist jeweils richtig?', 'mc', '{"passages": [{"paragraphs": [{"t": "Liebe Catherine,", "b": false}, {"t": "ich hab''s geschafft! Endlich habe ich einen Job bekommen. Wie versprochen möchte ich dir gleich (21) erzählen. Am Anfang (22) ich ziemlich enttäuscht, weil ich auf meine vielen Bewerbungsschreiben insgesamt (23) zwei Antworten bekommen habe. Aber zum Glück hat eine davon (24): Ich werde nun zwei Nachmittage in der Woche als Babysitterin (25) einer Familie arbeiten, die zwei Kinder hat. Sie sind 3 und 5 Jahre alt und (26) sind sehr nett. Wir haben in der (27) Woche bereits Vieles gemeinsam gemacht, sind in den Zoo und (28) Kindermuseum gegangen. (29) kann man eine Stadt gar nicht kennen lernen, und es macht mir viel Spaß!", "b": false}, {"t": "Für heute wünsche ich dir alles Gute – schreibe mir bald, wie es dir (30).", "b": false}, {"t": "Liebe Grüße", "b": false}, {"t": "Deine Tanja", "b": false}]}], "maxPoints": 15, "availablePoints": 15, "missing": 0, "pointsPerItem": 1.5}'::jsonb, 3),
    ('sb2', 'Sprachbausteine', 'Sprachbausteine, Teil 2', 20, 'Lesen Sie den Text und schließen Sie die Lücken 31–40. Benutzen Sie die Wörter a–o. Jedes Wort passt nur einmal.', 'wordbank', '{"bank": [{"key": "A", "text": "DER"}, {"key": "B", "text": "DIE"}, {"key": "C", "text": "ERST"}, {"key": "D", "text": "GEEIGNET"}, {"key": "E", "text": "GERNE"}, {"key": "F", "text": "HÄTTE"}, {"key": "G", "text": "IN"}, {"key": "H", "text": "MUSS"}, {"key": "I", "text": "NACH"}, {"key": "J", "text": "NOCH"}, {"key": "K", "text": "SCHON"}, {"key": "L", "text": "WANN"}, {"key": "M", "text": "WÄRE"}, {"key": "N", "text": "WENN"}, {"key": "O", "text": "WO"}], "bankTitle": "Wörter", "passages": [{"paragraphs": [{"t": "Ihre Anzeige in der Frankfurter Rundschau", "b": true}, {"t": "Sehr geehrte Frau Hermann,", "b": false}, {"t": "ich habe Ihre Anzeige in der Frankfurter Rundschau vom 5. Oktober gelesen und interessiere mich sehr für die 3-Zimmer-Wohnung.", "b": false}, {"t": "Zurzeit wohne ich noch in Krakau (Polen). Demnächst (31) ich aber aus beruflichen Gründen mit meinem Sohn (3 Jahre) (32) Frankfurt umziehen. Deshalb suche ich zum 1. November eine Wohnung, (33) möglichst zentral gelegen sein sollte. Ihre Wohnung (34) deshalb genau richtig für uns.", "b": false}, {"t": "Ich hätte jedoch noch einige Fragen zu Ihrer Anzeige: Ist die Wohnung auch für Kleinkinder (35)? Und gibt es in der näheren Umgebung einen Spielplatz, (36) mein Sohn spielen könnte?", "b": false}, {"t": "Außerdem würde ich (37) wissen, ob die Haltung von Haustieren in (38) Wohnung erlaubt ist. (39) es möglich ist, würden wir nämlich gerne unseren Hund mitbringen.", "b": false}, {"t": "Ich danke Ihnen (40) jetzt für Ihre Antwort und grüße Sie freundlich.", "b": false}, {"t": "Kasia Kloc", "b": false}]}], "maxPoints": 15, "availablePoints": 15, "missing": 0, "pointsPerItem": 1.5}'::jsonb, 4),
    ('sa', 'Schriftlicher Ausdruck', 'Schriftlicher Ausdruck', 30, 'Antworten Sie auf den Brief. Schreiben Sie etwas zu den folgenden Punkten:', 'writing', '{"brief": {"intro": "Eine Bekannte hat Ihnen folgenden Brief geschrieben:", "greeting": "Liebe(r)........", "paragraphs": ["endlich habe ich Zeit, dir wieder mal zu schreiben. Schade, dass du bei unserer Hochzeit nicht dabei sein konntest! Wir waren mit Freunden und Verwandten über 50 Personen. Ich habe ein langes, weißes Kleid getragen, und Karl hat sich für diesen Tag einen teuren, schwarzen Anzug gekauft, ob wohl er sonst immer nur Jeans trägt. Natürlich gab es ein wunderbares Festessen und danach wurde getanzt. Karl und ich haben viele Geschenke bekommen, vor allem auch Geld für unsere Hochzeitsreise. Wir wissen, aber noch gar nicht wohin wir fahren wollen. Wie läuft’s eigentlich bei dir, du hast doch eine neue Stelle? Wie gefällt dir die Arbeit? Karl und ich würden uns sehr freuen, wenn du uns wieder mal besuchen würdest!", "Liebe Grüße"], "signature": "Rita"}, "hints": ["Bevor Sie den Brief schreiben, überlegen Sie sich eine passende Reihenfolge der punkte, eine passende Betreff, eine passende Anrede, Einleitung und einen passenden Schluss.", "Schreiben Sie mindestens 100 Wörter."], "criteria": [{"title": "Aufgabenbewältigung", "hint": "Sind alle vier Leitpunkte inhaltlich angemessen bearbeitet?"}, {"title": "Kommunikative Gestaltung", "hint": "Anrede, Gruß, passendes Register und verbundene Sätze statt aneinandergereihter Punkte?"}, {"title": "Formale Richtigkeit", "hint": "Stören Fehler in Grammatik, Wortschatz und Rechtschreibung das Verstehen?"}], "grades": [{"key": "A", "points": 5}, {"key": "B", "points": 3}, {"key": "C", "points": 1}, {"key": "D", "points": 0}], "factor": 3, "maxPoints": 45, "availablePoints": 45, "missing": 0, "pointsPerItem": 45}'::jsonb, 5)
) as v(section_id, grp, title, minutes, instruction, format, config, sort)
join tests t on t.level_id = 'b1' and t.slug = 'modell-17'
on conflict (test_id, section_id) do update set "group" = excluded."group", title = excluded.title, minutes = excluded.minutes, instruction = excluded.instruction, format = excluded.format, config = excluded.config, sort = excluded.sort;

insert into items (section_id, item_id, text, options, points, meta, sort)
select s.id, v.item_id, v.text, v.options, v.points, v.meta, v.sort
from (values
    ('lv1', '1', 'Der Schokolade-Boom zeigt sich hierzulande nicht nur im hohen Verbrauch (jeder Schweizer isst fast 12 Kilo Schokolade im Jahr!), nein, er hat nun auch die Schönheitsindustrie erreicht. Vom 16. Januar bis zum 24. Februar bietet das Grand Hotel Bad Ragaz unter dem Namen Choco Therapy zahlreiche kosmetische Behandlungsmethoden mit Schokolade an. Die Bäder, Massagen und Hautcremes mit Kakao sind durchaus ernst gemeint, denn Kakao soll eine belebende Eigenschaft haben, die den Menschen jung und gesund aussehen lässt.', null::jsonb, 5, null::jsonb, 0),
    ('lv1', '2', 'Frisch verheiratete Paare nehmen oft schon in den Flitterwochen einige Kilos zu, weil sie ihre Essgewohnheiten ändern. Das belegt eine neue Studie. In Deutschland sind fast die Hälfte der verheirateten Frauen und circa zwei Drittel der Ehemänner übergewichtig. Alleinstehende sind vermutlich schlanker, weil sie besonderen Wert auf ihr Äußeres legen, mehr Sport treiben und sich selten Zeit für gemütliche Mahlzeiten nehmen.', null::jsonb, 5, null::jsonb, 1),
    ('lv1', '3', 'Wer acht Stunden und länger schläft, hat eine deutlich kürzere Lebenserwartung. Das berichtete das Apothekenmagazin Gesundheit am Mittwoch und bezog sich dabei auf eine neue japanische Studie. Schlecht für die Männer, denn laut dieser Studie schlafen Männer im Durchschnitt eine halbe Stunde länger pro Nacht als Frauen. Aber es gibt auch eine gute Nachricht für die Viel- und Langschläfer: Wer lange schläft, hat weniger Gewichtsprobleme und fühlt sich gesünder.', null::jsonb, 5, null::jsonb, 2),
    ('lv1', '4', 'Nach dem Motto beschwingt und bewegt starten die Schweizer Gesundheitsbehörden eine landesweite Bewegungskampagne. Dabei soll die Schweizer Bevölkerung aufgerufen werden, ausgewogen zu essen und sich täglich zu bewegen. Fast zwei Drittel der Bevölkerung in der Schweiz sind wenig aktiv und essen zu viel. Die Kampagne soll den Leuten zeigen, wie Sport und gesunde Ernährung ohne großen Aufwand in den Alltag integriert werden können, z.B. mit einem Spaziergang am Mittag oder mit einem Apfel zum Znüni statt Schokolade.', null::jsonb, 5, null::jsonb, 3),
    ('lv1', '5', 'Du bist, was du isst hat als Slogan ausgedient. Heute muss es heißen: Gut aussehen mit dem richtigen Essen. Der Trend kommt aus den USA: Dort kaufen bereits viele Leute neue teure Lebensmittel mit wissenschaftlichen Inhaltsstoffen, die dem Kunden jüngeres und schöneres Aussehen versprechen. So bietet z.B. ein New Yorker Nobelhotel das Menü gegen-graue-Haare an, das gegen das Älterwerden wirken soll. Aber wer wird schon eine solche Mahlzeit bestellen? Millionen von Leuten, so die Trendforscher. Und zwar aus dem einfachen Grund, weil jeder jung und gut aussehen will, und das mit möglichst wenig Aufwand.', null::jsonb, 5, null::jsonb, 4),
    ('lv2', '6', 'Mit 23 Jahren wollte Louis Palmer', '[{"key": "A", "text": "für Studenten Reisen nach Südamerika organisieren."}, {"key": "B", "text": "mit dem Fahrrad durch 50 verschiedene Länder fahren."}, {"key": "C", "text": "viele verschiedene Länder kennen lernen."}]'::jsonb, 5, null::jsonb, 0),
    ('lv2', '7', 'Sein Projekt konnte Palmer realisieren,', '[{"key": "A", "text": "weil er einen Preis von einer Universität gewonnen hat."}, {"key": "B", "text": "weil er finanzielle Unterstützung von vier Universitäten erhalten hat."}, {"key": "C", "text": "weil ihn Firmen und Universitäten unterstützt haben."}]'::jsonb, 5, null::jsonb, 1),
    ('lv2', '8', 'Schon als Jugendlicher', '[{"key": "A", "text": "baute Louis an einem umweltfreundlichen Auto."}, {"key": "B", "text": "wollte Louis etwas für die Umwelt tun."}, {"key": "C", "text": "wusste Louis genau, wie er sein Leben einteilen will."}]'::jsonb, 5, null::jsonb, 2),
    ('lv2', '9', 'Palmers Auto', '[{"key": "A", "text": "fährt mit alternativer Energie."}, {"key": "B", "text": "geht auf eine dreijährige Weltreise."}, {"key": "C", "text": "hat genug Platz für sieben Personen."}]'::jsonb, 5, null::jsonb, 3),
    ('lv2', '10', 'Louis Palmer', '[{"key": "A", "text": "hat für die Weltreise sechs Sprachen gelernt."}, {"key": "B", "text": "möchte mit seinem Auto nicht durch Großstädte fahren."}, {"key": "C", "text": "wird sich in nächster Zeit nicht langweilen."}]'::jsonb, 5, null::jsonb, 4),
    ('lv3', '11', 'Ihre Bekannte ist Mitte dreißig und sucht einen Partner, mit dem sie regelmäßig ins Kino gehen kann.', null::jsonb, 2.5, null::jsonb, 0),
    ('lv3', '12', 'Sie wollen Ihren Garten verändern und suchen Beratung/Tipps.', null::jsonb, 2.5, null::jsonb, 1),
    ('lv3', '13', 'Der Sohn Ihrer Freunde hat gerade das Abitur gemacht und sucht im Sommer für zwei Monate einen Job.', null::jsonb, 2.5, null::jsonb, 2),
    ('lv3', '14', 'Ihr Freund möchte im Nebenjob Gartenarbeiten übernehmen.', null::jsonb, 2.5, null::jsonb, 3),
    ('lv3', '15', 'Ihr 45-jähriger Onkel sucht eine Partnerin, mit der er zusammen verreisen kann.', null::jsonb, 2.5, null::jsonb, 4),
    ('lv3', '16', 'Sie möchten gern bei einem Film mitspielen und etwas Geld verdienen.', null::jsonb, 2.5, null::jsonb, 5),
    ('lv3', '17', 'Der Sohn Ihrer Freunde interessiert sich für die Geschichte des Autos. Am Sonntag wollen Sie mit ihm etwas Interessantes machen.', null::jsonb, 2.5, null::jsonb, 6),
    ('lv3', '18', 'Sie suchen eine Stelle und brauchen Tipps für Ihre Bewerbungen.', null::jsonb, 2.5, null::jsonb, 7),
    ('lv3', '19', 'Im Urlaub wollen Sie mit dem Auto eine Reise durch Deutschland machen und suchen ein passendes Angebot.', null::jsonb, 2.5, null::jsonb, 8),
    ('lv3', '20', 'Ihre Bekannte möchte lernen, wie sie kleinere Reparaturen an ihrem Wagen selbst machen kann.', null::jsonb, 2.5, null::jsonb, 9),
    ('sb1', '21', '… Wie versprochen möchte ich dir gleich (21) erzählen. Am Anfang …', '[{"key": "A", "text": "dafür"}, {"key": "B", "text": "damit"}, {"key": "C", "text": "davon"}]'::jsonb, 1.5, null::jsonb, 0),
    ('sb1', '22', '… Am Anfang (22) ich ziemlich enttäuscht, weil ich auf meine …', '[{"key": "A", "text": "bin"}, {"key": "B", "text": "habe"}, {"key": "C", "text": "war"}]'::jsonb, 1.5, null::jsonb, 1),
    ('sb1', '23', '… Bewerbungsschreiben insgesamt (23) zwei Antworten bekommen habe. Aber zum Glück …', '[{"key": "A", "text": "doch"}, {"key": "B", "text": "nur"}, {"key": "C", "text": "schon"}]'::jsonb, 1.5, null::jsonb, 2),
    ('sb1', '24', '… Aber zum Glück hat eine davon (24): Ich werde nun zwei Nachmittage …', '[{"key": "A", "text": "gepasst"}, {"key": "B", "text": "passen"}, {"key": "C", "text": "passt"}]'::jsonb, 1.5, null::jsonb, 3),
    ('sb1', '25', '… Nachmittage in der Woche als Babysitterin (25) einer Familie arbeiten, die …', '[{"key": "A", "text": "an"}, {"key": "B", "text": "bei"}, {"key": "C", "text": "zu"}]'::jsonb, 1.5, null::jsonb, 4),
    ('sb1', '26', '… Sie sind 3 und 5 Jahre alt und (26) sind sehr nett. Wir haben …', '[{"key": "A", "text": "beide"}, {"key": "B", "text": "beiden"}, {"key": "C", "text": "beides"}]'::jsonb, 1.5, null::jsonb, 5),
    ('sb1', '27', '… Wir haben in der (27) Woche bereits Vieles gemeinsam gemacht, sind …', '[{"key": "A", "text": "ersten"}, {"key": "B", "text": "erster"}, {"key": "C", "text": "erstes"}]'::jsonb, 1.5, null::jsonb, 6),
    ('sb1', '28', '… sind in den Zoo und (28) Kindermuseum gegangen. (29) kann man …', '[{"key": "A", "text": "im"}, {"key": "B", "text": "in"}, {"key": "C", "text": "ins"}]'::jsonb, 1.5, null::jsonb, 7),
    ('sb1', '29', '… (29) kann man eine Stadt gar nicht kennen lernen, und es macht …', '[{"key": "A", "text": "Am besten"}, {"key": "B", "text": "Besser"}, {"key": "C", "text": "Gut"}]'::jsonb, 1.5, null::jsonb, 8),
    ('sb1', '30', '… schreibe mir bald, wie es dir (30). Liebe Grüße …', '[{"key": "A", "text": "geht"}, {"key": "B", "text": "geht''s"}, {"key": "C", "text": "ging"}]'::jsonb, 1.5, null::jsonb, 9),
    ('sb2', '31', '… Demnächst (31) ich aber aus beruflichen Gründen …', null::jsonb, 1.5, null::jsonb, 0),
    ('sb2', '32', '… mit meinem Sohn (3 Jahre) (32) Frankfurt umziehen. …', null::jsonb, 1.5, null::jsonb, 1),
    ('sb2', '33', '… Deshalb suche ich zum 1. November eine Wohnung, (33) möglichst zentral gelegen sein sollte. …', null::jsonb, 1.5, null::jsonb, 2),
    ('sb2', '34', '… Ihre Wohnung (34) deshalb genau richtig für uns. …', null::jsonb, 1.5, null::jsonb, 3),
    ('sb2', '35', '… Ist die Wohnung auch für Kleinkinder (35)? …', null::jsonb, 1.5, null::jsonb, 4),
    ('sb2', '36', '… Und gibt es in der näheren Umgebung einen Spielplatz, (36) mein Sohn spielen könnte? …', null::jsonb, 1.5, null::jsonb, 5),
    ('sb2', '37', '… Außerdem würde ich (37) wissen, ob die Haltung von Haustieren …', null::jsonb, 1.5, null::jsonb, 6),
    ('sb2', '38', '… in (38) Wohnung erlaubt ist. …', null::jsonb, 1.5, null::jsonb, 7),
    ('sb2', '39', '… (39) es möglich ist, würden wir nämlich gerne …', null::jsonb, 1.5, null::jsonb, 8),
    ('sb2', '40', '… Ich danke Ihnen (40) jetzt für Ihre Antwort …', null::jsonb, 1.5, null::jsonb, 9),
    ('sa', 'A', 'Antworten Sie auf diesen Brief. Schreiben Sie in Ihrem Brief etwas zu den folgenden vier Punkten:', null::jsonb, 0, '{"minWords": 100, "points": ["Ihre neue Arbeitsstelle", "Wie man in Ihrem Land heiratet", "Vorschlag für Ritas Hochzeitsreise", "Rita und Karl besuchen?"]}'::jsonb, 0)
) as v(section_id, item_id, text, options, points, meta, sort)
join tests t on t.level_id = 'b1' and t.slug = 'modell-17'
join sections s on s.test_id = t.id and s.section_id = v.section_id
on conflict (section_id, item_id) do update set text = excluded.text, options = excluded.options, points = excluded.points, meta = excluded.meta, sort = excluded.sort;

insert into item_answers (item_id, answer, explanation)
select i.id, v.answer, v.explanation
from (values
    ('lv1', '1', 'B', null),
    ('lv1', '2', 'C', null),
    ('lv1', '3', 'J', null),
    ('lv1', '4', 'A', null),
    ('lv1', '5', 'G', null),
    ('lv2', '6', 'C', null),
    ('lv2', '7', 'C', null),
    ('lv2', '8', 'B', null),
    ('lv2', '9', 'A', null),
    ('lv2', '10', 'C', null),
    ('lv3', '11', 'H', null),
    ('lv3', '12', 'I', null),
    ('lv3', '13', 'J', null),
    ('lv3', '14', 'X', null),
    ('lv3', '15', 'K', null),
    ('lv3', '16', 'B', null),
    ('lv3', '17', 'D', null),
    ('lv3', '18', 'X', null),
    ('lv3', '19', 'E', null),
    ('lv3', '20', 'L', null),
    ('sb1', '21', 'C', null),
    ('sb1', '22', 'C', null),
    ('sb1', '23', 'B', null),
    ('sb1', '24', 'A', null),
    ('sb1', '25', 'B', null),
    ('sb1', '26', 'A', null),
    ('sb1', '27', 'A', null),
    ('sb1', '28', 'C', null),
    ('sb1', '29', 'B', null),
    ('sb1', '30', 'A', null),
    ('sb2', '31', 'H', null),
    ('sb2', '32', 'I', null),
    ('sb2', '33', 'B', null),
    ('sb2', '34', 'M', null),
    ('sb2', '35', 'D', null),
    ('sb2', '36', 'O', null),
    ('sb2', '37', 'E', null),
    ('sb2', '38', 'A', null),
    ('sb2', '39', 'N', null),
    ('sb2', '40', 'K', null)
) as v(section_id, item_id, answer, explanation)
join tests t on t.level_id = 'b1' and t.slug = 'modell-17'
join sections s on s.test_id = t.id and s.section_id = v.section_id
join items i on i.section_id = s.id and i.item_id = v.item_id
on conflict (item_id) do update set answer = excluded.answer, explanation = excluded.explanation;


commit;
