-- جزء 2 من 4 — نماذج modell-06–modell-10
-- مولّد من supabase/seed/b1.sql بـtools/split_seed.sh — لا تعدّله بالإيد
-- آمن للإعادة: شغّله مرتين ما بيغيّر شي.

begin;

-- مولّد من data بـtools/export_sql.py — لا تعدّله بالإيد

insert into levels (id, title, sort, published, provider, stufe) values ('b1', 'telc Deutsch B1', 0, true, 'telc', 'B1')
on conflict (id) do update set title = excluded.title,
  provider = coalesce(levels.provider, excluded.provider),
  stufe    = coalesce(levels.stufe,    excluded.stufe);

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


commit;
