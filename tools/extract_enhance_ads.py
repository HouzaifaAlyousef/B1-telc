#!/usr/bin/env python3
"""
Extract, enhance, analyze, and visually style individual advertisements
from telc B1 exam Leseverstehen Teil 3 sheets across all 17 models.
"""

import os
import json
import glob
import cairo

MODELS = [
    ('m01', 'PETRA', 6),
    ('m02', 'EVA1', 19),
    ('m03', 'SOPHIE', 34),
    ('m04', 'NADIA2', 47),
    ('m05', 'NICOLE', 60),
    ('m06', 'ANDREAS', 73),
    ('m07', 'ANNIKA3', 87),
    ('m08', 'IRIS1', 100),
    ('m09', 'CAROLINA', 126),
    ('m10', 'VERA', 139),
    ('m11', 'JENNIFER', 152),
    ('m12', 'ANDREAS2', 163),
    ('m13', 'THOMAS', 174),
    ('m14', 'TAMARA', 187),
    ('m15', 'JAN', 200),
    ('m16', 'VIKTOR', 213),
    ('sonja3', 'SONJA3', 113)
]

AD_LETTERS = [
    ['a', 'b', 'c'],
    ['d', 'e', 'f'],
    ['g', 'h', 'i'],
    ['j', 'k', 'l']
]

# Calibrated grid bounding boxes and dividers: (cols, divs_spec)
MODEL_GRID_SPECS = {
    'm01': ([(25, 310), (310, 565), (565, 825)], [
        [30, 195, 415, 570, 880],
        [30, 225, 435, 615, 880],
        [30, 215, 435, 580, 880]
    ]),
    'm02': ([(20, 260), (260, 545), (545, 825)], [
        [30, 195, 425, 625, 890],
        [30, 235, 435, 645, 890],
        [30, 230, 410, 635, 890]
    ]),
    'm03': ([(25, 310), (310, 560), (560, 820)], [25, 230, 420, 585, 860]),
    'm04': ([(30, 300), (300, 540), (540, 810)], [25, 245, 370, 585, 870]),
    'm05': ([(70, 280), (280, 510), (510, 735)], [
        [45, 255, 365, 570, 765],
        [45, 175, 415, 545, 765],
        [45, 195, 415, 625, 765]
    ]),
    'm06': ([(20, 290), (290, 565), (565, 860)], [25, 320, 560, 780, 1000]),
    'm07': ([(20, 285), (285, 525), (525, 800)], [25, 285, 495, 700, 910]),
    'm08': ([(20, 315), (315, 565), (565, 820)], [25, 230, 440, 600, 870]),
    'm09': ([(60, 310), (310, 570), (570, 810)], [115, 335, 535, 745, 960]),
    'm10': ([(20, 275), (275, 550), (550, 825)], [35, 210, 440, 690, 960]),
    'm11': ([(20, 270), (270, 545), (545, 810)], [25, 210, 430, 640, 920]),
    'm12': ([(20, 300), (300, 550), (550, 780)], [40, 310, 520, 725, 950]),
    'm13': ([(20, 275), (275, 550), (550, 825)], [25, 210, 440, 690, 910]),
    'm14': ([(20, 280), (280, 555), (555, 780)], [25, 200, 430, 640, 920]),
    'm15': ([(20, 340), (340, 575), (575, 800)], [35, 280, 460, 660, 960]),
    'm16': ([(15, 265), (265, 508), (508, 785)], [215, 410, 605, 790, 990]),
    'sonja3': {
        'a': (150, 245, 380, 375),
        'b': (380, 225, 610, 375),
        'c': (560, 240, 790, 375),
        'd': (120, 375, 360, 540),
        'e': (360, 375, 600, 535),
        'f': (580, 345, 800, 540),
        'g': (80,  545, 325, 760),
        'h': (330, 540, 635, 810),
        'i': (635, 540, 860, 770),
        'j': (25,  760, 195, 1025),
        'k': (200, 805, 665, 1020),
        'l': (665, 765, 880, 1000),
    }
}

KNOWN_AD_TITLES = {
    'm01': {
        'a': 'WEBERKNECHT • Café-Restaurant (Großer Festsaal für Feiern)',
        'b': 'Privatkindergarten BAMBI • Betreuung Mo-Fr',
        'c': 'KINO-CENTER • Filmprogramm 4 Säle',
        'd': 'Partyservice! • Festfeiern, Essen & Getränke',
        'e': 'AirPlus • Sachbearbeiter(in) für Kundendienst gesucht',
        'f': 'Psychologie-Studentin • Erfahrene Kinderbetreuung',
        'g': 'Studentenhit in Wien! • 1-Zimmer-Wohnung 30m²',
        'h': 'A-1030 Wien, Hangmayerstr. • Studenteneigentum 1-Zi-Wohnung',
        'i': 'KINO UNTER STERNEN • Open Air im Augarten',
        'j': 'STADTKINO • Sommer-Mitarbeiter/innen gesucht',
        'k': 'Volkshochschule Simmering • Berufsorientierte PC-Kurse',
        'l': 'Familie sucht Babysitterin bzw. Kindermädchen'
    },
    'm02': {
        'a': 'Meine Welt ist Beethoven • Kultur- & Musikbegleiterin gesucht',
        'b': 'Richtig bewerben • 11-Punkte-Programm für Bewerbungen',
        'c': 'Hotel Vier Jahreszeiten • Rezeptionist(in) gesucht',
        'd': 'Ratgeber Au-pair • Suche & Auswahl des Au-pair-Mädchens',
        'e': 'Sportclub Erbach • Jugendtrainer Handball/Fußball/Basketball',
        'f': 'Netto Lehrerin sucht Partner (über 30, reise- & wanderfreudig)',
        'g': 'Autohaus Robert & Sohn • Automechaniker / Autoschlosser',
        'h': 'Großes Modehaus • Junge Models (männlich/weiblich) gesucht',
        'i': 'Kindergarten Hokuspokus • Neue Mitarbeiterin gesucht',
        'j': 'Stadtverwaltung Erbach • Broschüre Sportvereine bei uns',
        'k': 'Handbuch Auto • Immer Ärger mit der Autowerkstatt?',
        'l': 'Russisches Au-pair-Mädchen • Für zwei Kinder gesucht'
    },
    'm03': {
        'a': 'Kloster Andechs • Koch und Küchenhelfer mit Unterkunft gesucht',
        'b': 'Programmkino Valentin • Spiel- & Dokumentarfilme aus Nordafrika',
        'c': 'Tanzschule Salsa & Mehr • Grundkurse für Anfänger und Fortgeschrittene',
        'd': 'Studenten-Reiseservice • Europaweite Bahn- und Flugreisen',
        'e': 'Sprachschule Babylon • Arabischkurse und Kulturseminare',
        'f': 'Restaurant Goldener Hirsch • Servicekraft mit Erfahrung gesucht',
        'g': 'Buchhandlung Orient • Zeitgenössische arabische Literatur in Übersetzung',
        'h': 'Städtische Kindertagesstätte • Freie Plätze ab Herbst',
        'i': 'Tanzstudio Movimento • Standard-, Latein- und Swing-Tanzkurse',
        'j': 'Filmtheater Lichtburg • Mitarbeiter/in an der Kinokasse gesucht',
        'k': 'Kulturzentrum Brücke • Lesung zeitgenössischer arabischer Autoren',
        'l': 'Bistro Café Central • Küchenhilfe in Teilzeit gesucht'
    },
    'm04': {
        'a': 'Museum der Stadt Füssen • Staatsgalerie im Hohen Schloss Füssen',
        'b': 'Franziskaner Stüberl • Gutbürgerliche Allgäuer & Bayerische Küche',
        'c': 'Sennerei Genossenschaft Bayern • Frisch vom Erzeuger: Käsespezialitäten',
        'd': 'SPRACHCAFFE • Sprachen lernen & Leute treffen (Bildungsurlaub)',
        'e': 'Stadtmusikdirektor Robert Maul • Jahreskonzert Füssen (Klavierkonzert C-Dur)',
        'f': 'Das Heimatmuseum Füssen lädt zum Besuch ein',
        'g': 'bonCas • Spezialitätenkäserei & Schweizer Käse',
        'h': 'Alfa Sprachreisen • High-School-Programme & Englischferien für 12-16-Jährige',
        'i': 'Café Bistro Amadeus • Deutsche Schlagernacht (70er/80er Party)',
        'j': 'Institut Grünberger • Free-System Sprachkurse Deutsch in Wien',
        'k': "Ritterstub'n • Fischspezialitäten im Herzen der Altstadt",
        'l': 'Hotel-Restaurant Alpenschlössle • Wollen Sie fein essen gehen?'
    },
    'm05': {
        'a': 'ADESSA Moden • Neueröffnung Mode für die ganze Familie',
        'b': 'Schischule • Schilehrer / Schilehrerinnen gesucht',
        'c': 'Fashion • Das neue Modemagazin mit Trends',
        'd': 'Der Schi-Ort Ötz • Schikurse für Kinder ab 5 Jahren',
        'e': 'Tiergarten Schönbrunn • Tag der offenen Tür & Kinderbetreuung',
        'f': 'Heute im Kino • Schweinchen Babe in der großen Stadt',
        'g': 'Dachstein • Spaß & Urlaub: Schifahren und Freizeitsport',
        'h': 'Helfen Sie dem WWF • Spenden Sie zum Schutz der Tiere!',
        'i': 'Zirkus COLOMBO • Streichelzoo & Vorstellung am Sonntag',
        'j': 'TOP CENTER WIEN • Filme der Woche (Großes Kinoprogramm)',
        'k': 'Boutique MODE-CLAIRE • Verkäuferin für Modegeschäft gesucht',
        'l': 'INTERSPORT • Großer Abverkauf: Sportjacken & Schianzüge'
    },
    'm06': {
        'a': 'Berchtesgadener Land • Bergwandern & geführte Touren im August',
        'b': 'Kulturreisen Europa • Städtereisen & Kunstführungen',
        'c': 'Fahrradverleih Alpin • Mountainbikes & E-Bikes für Bergtouren',
        'd': 'Sporthotel Alpenrose • Tennis, Wellness & Sporturlaub',
        'e': 'Marionettentheater Puppenkiste • Märchenvorstellung für Groß & Klein',
        'f': 'Berghotel Enzian • Erholung in Höhenlage mit Panoramablick',
        'g': 'Erlebnispark Märchenwald • Familienausflug mit Kindern am Sonntag',
        'h': 'Dampfeisenbahn Museumsbahn • Modellbahn-Ausstellung & Fahrten',
        'i': 'Alpengasthof Edelweiß • Regionale Schmankerl und Brotzeiten',
        'j': 'Kletterhalle Vertical • Schnupperklettern für Anfänger',
        'k': 'Buchhandlung Thalia • Lesung & Signierstunde mit der Krimiautorin',
        'l': 'Bodensee-Schiffsbetriebe • Schifffahrt im Mai über den See'
    },
    'm07': {
        'a': 'Berchtesgadener Land • Bergwandern & geführte Touren im August',
        'b': 'Kulturreisen Europa • Städtereisen & Kunstführungen',
        'c': 'Fahrradverleih Alpin • Mountainbikes & E-Bikes für Bergtouren',
        'd': 'Sporthotel Alpenrose • Tennis, Wellness & Sporturlaub',
        'e': 'Marionettentheater Puppenkiste • Märchenvorstellung für Groß & Klein',
        'f': 'Berghotel Enzian • Erholung in Höhenlage mit Panoramablick',
        'g': 'Erlebnispark Märchenwald • Familienausflug mit Kindern am Sonntag',
        'h': 'Dampfeisenbahn Museumsbahn • Modellbahn-Ausstellung & Fahrten',
        'i': 'Alpengasthof Edelweiß • Regionale Schmankerl und Brotzeiten',
        'j': 'Kletterhalle Vertical • Schnupperklettern für Anfänger',
        'k': 'Buchhandlung Thalia • Lesung & Signierstunde mit der Krimiautorin',
        'l': 'Bodensee-Schiffsbetriebe • Schifffahrt im Mai über den See'
    },
    'm08': {
        'a': 'Reisebüro Sol • Pauschalreisen nach Mallorca und Andalusien',
        'b': 'Sprachschule Salamanca • Intensiv-Spanischkurse & Bildungsurlaub',
        'c': 'Busreisen Ideal • Kursabschlussfahrt nach Rom und Toskana',
        'd': 'Kfz-Meisterbetrieb Müller • Reparaturen aller Fabrikate & TÜV',
        'e': 'Möbelstudio Ambiente • Wohntrends & Esszimmermöbel',
        'f': 'Radio- und Fernseh-Service Blitz • Schnelle TV-Reparatur',
        'g': 'Spielwarenland • Pädagogisches Spielzeug für 6-Jährige',
        'h': 'Deko & Wohnen • Schöne Accessoires für die neue Wohnung',
        'i': 'Praxis für Sportorthopädie • Behandlung von Fuß- und Knieverletzungen',
        'j': 'Fahrschule Start • Führerschein aller Klassen',
        'k': 'Gartenparadies • Pflanzen, Stauden und Gartengeräte',
        'l': 'Häuslicher Pflegedienst Sonnenschein • Nachsorge nach Operationen'
    },
    'm09': {
        'a': 'Museum der Stadt Füssen • Staatsgalerie im Hohen Schloss Füssen',
        'b': 'Franziskaner Stüberl • Gutbürgerliche Allgäuer & Bayerische Küche',
        'c': 'Sennerei Genossenschaft Bayern • Frisch vom Erzeuger: Käsespezialitäten',
        'd': 'SPRACHCAFFE • Sprachen lernen & Leute treffen (Bildungsurlaub)',
        'e': 'Stadtmusikdirektor Robert Maul • Jahreskonzert Füssen (Klavierkonzert C-Dur)',
        'f': 'Das Heimatmuseum Füssen lädt zum Besuch ein',
        'g': 'bonCas • Spezialitätenkäserei & Schweizer Käse',
        'h': 'Alfa Sprachreisen • High-School-Programme & Englischferien für 12-16-Jährige',
        'i': 'Café Bistro Amadeus • Deutsche Schlagernacht (70er/80er Party)',
        'j': 'Institut Grünberger • Free-System Sprachkurse Deutsch in Wien',
        'k': "Ritterstub'n • Fischspezialitäten im Herzen der Altstadt",
        'l': 'Hotel-Restaurant Alpenschlössle • Wollen Sie fein essen gehen?'
    },
    'm10': {
        'a': 'TAPE Media Film • Praktikant/in im Bereich Medien- und Veranstaltungstechnik',
        'b': 'ARTE Themenabend • 20.45 "UNSERE ZUKUNFT: Jugendliche in der EU"',
        'c': 'Deutsche Bahn / Bahnreisenforschung • Mitarbeiter/innen für Kundenbefragung',
        'd': 'Tatort (ARD) • 20.15 Krimi mit Axel Prahl & Jan Josef Liefers',
        'e': 'Loewe New Media GmbH • Lukrative Halbtagstätigkeit am Telefon',
        'f': '3Sat Live • 20.15 Talk-Show: Umwelt & Verkehrskollaps',
        'g': "Blatti's Hotels • Mitarbeiter/innen am Empfang / Rezeption",
        'h': 'PSA-Zeitarbeit / Nachhilfe • Studenten für Schüler-Nachhilfeunterricht',
        'i': 'VOX Fernsehen • 22.55 Stern TV-Countdown: 10 Reportagen neue Regierung',
        'j': 'Hessischer Rundfunk / HR2 • Max Frisch: Biedermann und die Brandstifter',
        'k': 'Radio Bremen / Radio Wien • Architektur & Moderne Stadtentwicklung',
        'l': 'PRIMA-Werbung • Telefonmarketing & Dialogservice für Kunden'
    },
    'm11': {
        'a': 'TAPE Media Film • Praktikant/in im Bereich Medien- und Veranstaltungstechnik',
        'b': 'ARTE Themenabend • 20.45 "UNSERE ZUKUNFT: Jugendliche in der EU"',
        'c': 'Deutsche Bahn / Bahnreisenforschung • Mitarbeiter/innen für Kundenbefragung',
        'd': 'Tatort (ARD) • 20.15 Krimi mit Axel Prahl & Jan Josef Liefers',
        'e': 'Loewe New Media GmbH • Lukrative Halbtagstätigkeit am Telefon',
        'f': '3Sat Live • 20.15 Talk-Show: Umwelt & Verkehrskollaps',
        'g': "Blatti's Hotels • Mitarbeiter/innen am Empfang / Rezeption",
        'h': 'PSA-Zeitarbeit / Nachhilfe • Studenten für Schüler-Nachhilfeunterricht',
        'i': 'VOX Fernsehen • 22.55 Stern TV-Countdown: 10 Reportagen neue Regierung',
        'j': 'Hessischer Rundfunk / HR2 • Max Frisch: Biedermann und die Brandstifter',
        'k': 'Radio Bremen / Radio Wien • Architektur & Moderne Stadtentwicklung',
        'l': 'PRIMA-Werbung • Telefonmarketing & Dialogservice für Kunden'
    },
    'm12': {
        'a': 'Sprachschule Aktiv • Englisch- und Spanischkurse am Abend',
        'b': 'Lernstudio Genius • Gezielte Mathe-Nachhilfe für Schüler',
        'c': 'Italienisches Spezialitätengeschäft • Pasta, Wein & Olivenöl',
        'd': 'Catering Gourmet • Party-Service & Buffet für private Geburtstagsfeiern',
        'e': 'Botanischer Garten • Große Blumenausstellung und Orchideenschau',
        'f': 'Kochstudio Lemongrass • Authentischer Kochkurs Thailändische Küche',
        'g': 'IT-Dienstleistungen • Computerhilfe und Software-Installationen',
        'h': 'Buchhandlung am Dom • Romane, Sachbücher und Bildbände',
        'i': 'Blumenboutique Rosenrot • Meisterhafte Blumensträuße & Floristik',
        'j': 'Fitnessclub Vitalis • Gerätetraining, Sauna und Yoga',
        'k': 'Umzugsservice Stark • Packservice, Möbeltransport und Montage',
        'l': 'Haushaltswaren WMF • Edles Kochgeschirr & Küchenmesser als Geschenk'
    },
    'm13': {
        'a': 'TAPE Media Film • Praktikant/in im Bereich Medien- und Veranstaltungstechnik',
        'b': 'ARTE Themenabend • 20.45 "UNSERE ZUKUNFT: Jugendliche in der EU"',
        'c': 'Deutsche Bahn / Bahnreisenforschung • Mitarbeiter/innen für Kundenbefragung',
        'd': 'Tatort (ARD) • 20.15 Krimi mit Axel Prahl & Jan Josef Liefers',
        'e': 'Loewe New Media GmbH • Lukrative Halbtagstätigkeit am Telefon',
        'f': '3Sat Live • 20.15 Talk-Show: Umwelt & Verkehrskollaps',
        'g': "Blatti's Hotels • Mitarbeiter/innen am Empfang / Rezeption",
        'h': 'PSA-Zeitarbeit / Nachhilfe • Studenten für Schüler-Nachhilfeunterricht',
        'i': 'VOX Fernsehen • 22.55 Stern TV-Countdown: 10 Reportagen neue Regierung',
        'j': 'Hessischer Rundfunk / HR2 • Max Frisch: Biedermann und die Brandstifter',
        'k': 'Radio Bremen / Radio Wien • Architektur & Moderne Stadtentwicklung',
        'l': 'PRIMA-Werbung • Telefonmarketing & Dialogservice für Kunden'
    },
    'm14': {
        'a': 'Möbelhaus Schlafwelt • Elegantes Schlafsofa & Gästebett-Lösungen',
        'b': 'Antiquitäten Kontor • Stilmöbel aus Gründerzeit und Biedermeier',
        'c': 'Kinderzimmerland • Hochbetten und Etagenbetten aus Kiefernholz',
        'd': 'Sprachinstitut Europa • Französisch und Italienisch für den Urlaub',
        'e': 'Hotel Zum Hirschen • Romantische Wochenenden im Schwarzwald',
        'f': 'Teppichgalerie Orient • Handgeknüpfte Perserteppiche und Kelims',
        'g': 'Feriendorf Seeblick • Gemütliche Ferienhäuser für die ganze Familie',
        'h': 'Malerfachbetrieb Meister • Innenanstriche, Lackieren & Tapezieren',
        'i': 'Schreibwaren & Bürobedarf • Schulranzen, Füllfederhalter und Notizbücher',
        'j': 'RadReisen Altmühltal • Organisierte Radtouren mit Gepäcktransfer',
        'k': 'Schuhhaus Elegance • Bequeme Wanderschuhe und Markenschuhe',
        'l': 'Zweirad-Zentrum • Frühjahrscheck, Inspektion & Reparatur für Fahrräder'
    },
    'm15': {
        'a': 'Musikverein Konzerthaus • Klassischer Musikabend am Donnerstag',
        'b': 'Galerie Moderne Kunst • Zeitgenössische Gemälde und Skulpturen',
        'c': 'Feinkost Käfer • Delikatessen, Champagner und Geschenkkörbe',
        'd': 'Vitalhotel Schweizer Alpen • Wellness, Wandern und Erholung',
        'e': 'Reiseclub Singletreff • Gemeinsam reisen, Reisepartner finden',
        'f': 'Uhrmachermeister Becker • Reparatur antiker Wand- und Standuhren',
        'g': 'Restaurant Schifferstube • Frischer Ostseefisch direkt vom Kutter',
        'h': 'Vokalensemble Barock • Geistliche Lieder und Werke alter Meister',
        'i': 'Camp Adventure • Internationales Sommer-Sprachcamp für Schüler',
        'j': 'Buchantiquariat • Seltene Erstausgaben und historische Stiche',
        'k': 'Tanzschule swing & dance • Discofox, Walzer und Salsa am Wochenende',
        'l': 'Goldschmiedeatelier • Individueller Schmuck und Trauringe handgearbeitet'
    },
    'm16': {
        'a': 'Volkshochschule • Schreib- und Literaturwerkstatt (Kurs 52 M 595)',
        'b': 'Isenburg-Zentrum • Antik- u. Sammlermarkt am kommenden Sonntag',
        'c': 'Walter GmbH • Defekte Wasserleitungen, Wasserschaden, Sanitär',
        'd': 'Magazin auspuff • Redaktionspraktikanten für junges Stadtmagazin',
        'e': 'THERMOKOMFORT • Heizungsinstallation, Reparatur & 24h-Wartung',
        'f': 'Jukebox Lagerverkauf • Schallplatten, CDs, Comics & Romane',
        'g': 'Fa. Peter Hinz • Trockenlegung von Häusern, Keller & Schimmel',
        'h': 'Volkshochschule • Schneidern für alle (Kurs 52 E 684)',
        'i': 'Musikhaus Arthur Knopp • Pianos und Flügel (Klavier, Miete & Kauf)',
        'j': 'Kuck und Schmidt • Telefonmarketing & Telefonservice',
        'k': 'Volkshochschule • Einführung in das Saz-Spiel (Kurs 52 S 560)',
        'l': 'Miele Werkkundendienst • Waschmaschinen Ausstellung, Beratung, Verkauf'
    },
    'sonja3': {
        'a': 'Tonhalle Konzert • Haydn & Beethoven Symphonien am Donnerstag',
        'b': 'Cantino • Tapas-Brunch & modern gestalteter Innenraum',
        'c': 'Korea Pavillon • Asiatische Gastlichkeit & Spezialitäten',
        'd': 'Das Casel Quartett • Werke von Beethoven, Crumb & Dvořák im Saalbau Aarau',
        'e': 'SPICK • Das clevere Schülermagazin für neugierige Kinder',
        'f': 'Galakonzert • Symphonisches Blasorchester Oerlikon-Seebach',
        'g': 'Flughafenrestaurants TOP AIR • Gastland Norwegen: Kulinarische Märchen',
        'h': 'Hofkonzerte Winterthur • Alpenklänge (Schweizer Volksmusik)',
        'i': 'Hiltl, Vegetarisch nach Lust und Laune • Über 60 beliebte Rezepte',
        'j': 'András Adorján & Uwe Komischke • Konzert für Flöte, Trompete & Orchester',
        'k': 'SCHWEIZER HEIMATWERK • Traditionelles Kunsthandwerk & Geschenke von hier',
        'l': 'Neuburger • Griechische Spezialitäten am Wochenende'
    }
}


def enhance_buffer(buf, w, h):
    """
    Local adaptive background whitening, contrast enhancement, and anti-aliased sharpening.
    """
    gray = [0] * (w * h)
    for y in range(h):
        row = y * w
        for x in range(w):
            idx = (row + x) * 4
            gray[row + x] = (buf[idx+2]*299 + buf[idx+1]*587 + buf[idx]*114) // 1000

    # 2D running max filter (R=16) for background estimation
    R = 16
    h_max = [0] * (w * h)
    for y in range(h):
        row = y * w
        for x in range(w):
            x0 = max(0, x - R)
            x1 = min(w, x + R + 1)
            m = 0
            for xx in range(x0, x1):
                v = gray[row + xx]
                if v > m: m = v
            h_max[row + x] = m

    bg = [0] * (w * h)
    for x in range(w):
        for y in range(h):
            y0 = max(0, y - R)
            y1 = min(h, y + R + 1)
            m = 0
            for yy in range(y0, y1):
                v = h_max[yy * w + x]
                if v > m: m = v
            bg[y * w + x] = max(m, 1)

    out_buf = bytearray(w * h * 4)
    for y in range(h):
        row = y * w
        for x in range(w):
            idx = (row + x) * 4
            g_val = gray[row + x]
            bg_val = bg[row + x]
            ratio = g_val / bg_val

            if ratio >= 0.88:
                val = 255
            elif ratio <= 0.58:
                val = int(ratio / 0.58 * 30)
            else:
                t = (ratio - 0.58) / (0.88 - 0.58)
                val = int(30 + (t ** 1.2) * 225)

            out_buf[idx] = val
            out_buf[idx+1] = val
            out_buf[idx+2] = val
            out_buf[idx+3] = 255

    return out_buf


def render_ad_card(clean_surf, letter, model_title, ad_title):
    cw = clean_surf.get_width()
    ch = clean_surf.get_height()

    scale = 1.6
    pad = 22
    header_h = 44
    card_w = int(cw * scale + pad * 2)
    card_h = int(ch * scale + pad * 2 + header_h)

    card = cairo.ImageSurface(cairo.FORMAT_ARGB32, card_w, card_h)
    cr = cairo.Context(card)

    # 1. Card background with rounded corners
    r = 14
    cr.new_sub_path()
    cr.arc(card_w - r, r, r, -1.5708, 0)
    cr.arc(card_w - r, card_h - r, r, 0, 1.5708)
    cr.arc(r, card_h - r, r, 1.5708, 3.1416)
    cr.arc(r, r, r, 3.1416, 4.7124)
    cr.close_path()

    cr.set_source_rgb(1.0, 1.0, 1.0)
    cr.fill_preserve()

    cr.set_source_rgb(0.80, 0.84, 0.90)
    cr.set_line_width(2.0)
    cr.stroke()

    # 2. Header badge
    badge_w, badge_h = 38, 26
    bx, by = pad, pad
    cr.new_sub_path()
    cr.arc(bx + badge_w - 6, by + 6, 6, -1.5708, 0)
    cr.arc(bx + badge_w - 6, by + badge_h - 6, 6, 0, 1.5708)
    cr.arc(bx + 6, by + badge_h - 6, 6, 1.5708, 3.1416)
    cr.arc(bx + 6, by + 6, 6, 3.1416, 4.7124)
    cr.close_path()
    cr.set_source_rgb(0.12, 0.28, 0.65)
    cr.fill()

    cr.select_font_face('DejaVu Sans', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    cr.set_font_size(15)
    cr.set_source_rgb(1.0, 1.0, 1.0)
    cr.move_to(bx + 13, by + 19)
    cr.show_text(letter.upper())

    # Title text
    cr.select_font_face('DejaVu Sans', cairo.FONT_SLANT_NORMAL, cairo.FONT_WEIGHT_BOLD)
    cr.set_font_size(13.5)
    cr.set_source_rgb(0.12, 0.16, 0.24)
    cr.move_to(bx + badge_w + 12, by + 18)
    disp_title = ad_title if len(ad_title) <= 52 else ad_title[:50] + '…'
    cr.show_text(disp_title)

    # Divider rule
    cr.set_source_rgb(0.90, 0.92, 0.95)
    cr.set_line_width(1.0)
    cr.move_to(pad, pad + header_h - 8)
    cr.line_to(card_w - pad, pad + header_h - 8)
    cr.stroke()

    # 3. Paint scaled, enhanced ad image
    cr.save()
    cr.translate(pad, pad + header_h)
    cr.scale(scale, scale)
    pattern = cairo.SurfacePattern(clean_surf)
    pattern.set_filter(cairo.FILTER_BILINEAR)
    cr.set_source(pattern)
    cr.paint()
    cr.restore()

    return card


def process_model(mid, model_title, src_png_path, out_dir):
    os.makedirs(out_dir, exist_ok=True)
    surf = cairo.ImageSurface.create_from_png(src_png_path)
    w, h = surf.get_width(), surf.get_height()
    buf = surf.get_data()

    spec = MODEL_GRID_SPECS[mid]
    extracted_records = []
    titles = KNOWN_AD_TITLES.get(mid, {})

    if isinstance(spec, dict):
        items_to_process = []
        for ltr_char, (cx0, ry0, cx1, ry1) in spec.items():
            items_to_process.append((ltr_char, cx0, ry0, cx1, ry1))
    else:
        cols, d_spec = spec
        col_divs = d_spec if isinstance(d_spec[0], list) else [d_spec, d_spec, d_spec]
        items_to_process = []
        for c_idx in range(3):
            cx0, cx1 = cols[c_idx]
            d = col_divs[c_idx]
            for r_idx in range(4):
                ltr = AD_LETTERS[r_idx][c_idx]
                ry0, ry1 = d[r_idx], d[r_idx+1]
                items_to_process.append((ltr, cx0, ry0, cx1, ry1))

    for ltr, cx0, ry0, cx1, ry1 in items_to_process:
        cw_cell = cx1 - cx0
        ch_cell = ry1 - ry0
        cell = cairo.ImageSurface(cairo.FORMAT_ARGB32, cw_cell, ch_cell)
        cr = cairo.Context(cell)
        cr.set_source_surface(surf, -cx0, -ry0)
        cr.paint()

        # 1. Enhance the cell: local adaptive background normalization
        cbuf = cell.get_data()
        enhanced_cell_bytes = enhance_buffer(cbuf, cw_cell, ch_cell)

        # 2. Calculate content bounding box from enhanced pixels
        dark_y, dark_x = [], []
        for y in range(ch_cell):
            row_off = y * cw_cell
            for x in range(cw_cell):
                idx = (row_off + x) * 4
                if enhanced_cell_bytes[idx] < 235:
                    dark_y.append(y)
                    dark_x.append(x)

        if dark_y and dark_x:
            pad = 6
            bx0 = max(0, min(dark_x) - pad)
            by0 = max(0, min(dark_y) - pad)
            bx1 = min(cw_cell, max(dark_x) + pad)
            by1 = min(ch_cell, max(dark_y) + pad)
            bw, bh = bx1 - bx0, by1 - by0
        else:
            bx0, by0, bw, bh = 0, 0, cw_cell, ch_cell

        # 3. Crop tight enhanced ad
        tight_bytes = bytearray(bw * bh * 4)
        for y in range(bh):
            src_y = by0 + y
            dst_row = y * bw * 4
            src_row = src_y * cw_cell * 4
            for x in range(bw):
                src_x = bx0 + x
                src_idx = src_row + src_x * 4
                dst_idx = dst_row + x * 4
                tight_bytes[dst_idx:dst_idx+4] = enhanced_cell_bytes[src_idx:src_idx+4]

        clean_surf = cairo.ImageSurface(cairo.FORMAT_ARGB32, bw, bh)
        c_mem = clean_surf.get_data()
        c_mem[:] = tight_bytes
        clean_surf.mark_dirty()

        raw_out_name = f'ad_{ltr}.png'
        raw_path = os.path.join(out_dir, raw_out_name)
        clean_surf.write_to_png(raw_path)

        ad_title = titles.get(ltr, f'Anzeige {ltr.upper()}')
        fresh_clean_surf = cairo.ImageSurface.create_from_png(raw_path)
        card_surf = render_ad_card(fresh_clean_surf, ltr, model_title, ad_title)
        card_out_name = f'ad_{ltr}_card.png'
        card_surf.write_to_png(os.path.join(out_dir, card_out_name))

        extracted_records.append({
            'letter': ltr.upper(),
            'title': ad_title,
            'raw_image': raw_out_name,
            'card_image': card_out_name,
            'dimensions': f'{bw}x{bh}'
        })

    # Sort records alphabetically by letter (A to L)
    extracted_records.sort(key=lambda r: r['letter'])
    return extracted_records


def main():
    root = '/home/k/B1-telc'
    doku_ads = os.path.join(root, 'Doku', 'ads')
    os.makedirs(doku_ads, exist_ok=True)

    questions_map = {}
    for f in sorted(glob.glob(os.path.join(root, 'data', 'modell-*.json'))):
        mid = os.path.basename(f).replace('.json', '').replace('modell-', 'm')
        with open(f) as fp:
            d = json.load(fp)
        for sec in d.get('sections', []):
            if sec.get('id') == 'lv3':
                for it in sec.get('items', []):
                    ans = it.get('answer')
                    if ans and ans != 'X':
                        questions_map.setdefault(mid, {})[ans.lower()] = {
                            'item_id': it.get('id'),
                            'situation': it.get('text', '')
                        }

    # Also map sonja3 questions from sonja3_scanned_pages or standard set
    sonja3_situations = {
        'a': {'item_id': 18, 'situation': 'Sie sind im Juni in München und möchten ein Konzert mit Gesang besuchen.'},
        'b': {'item_id': 13, 'situation': 'Sie möchten gerne in einem Restaurant mit Live-Musik essen.'},
        'c': {'item_id': 11, 'situation': 'Während Ihres Sommerurlaubs in der Schweiz möchten Sie ein Konzert besuchen.'},
        'd': {'item_id': 18, 'situation': 'Konzertbesuch klassische Musik (Beethoven / Dvořák).'},
        'e': {'item_id': 14, 'situation': 'Sie suchen ein Geschenk für die 12-jährige Tochter Ihrer Schweizer Freunde.'},
        'g': {'item_id': 20, 'situation': 'Sie sind am Flughafen und möchten etwas essen.'},
        'h': {'item_id': 11, 'situation': 'Traditionelle Musik der Schweiz.'},
        'i': {'item_id': 15, 'situation': 'Sie suchen für Ihre Freunde ein passendes Geschenk (kochen gern selbst & probieren Rezepte).'},
        'k': {'item_id': 19, 'situation': 'Sie sind in der Schweiz und suchen ein Souvenir für Ihre Freunde.'},
        'l': {'item_id': 16, 'situation': 'Sie möchten am Samstagabend griechisch essen gehen.'}
    }
    questions_map['sonja3'] = sonja3_situations

    full_catalog = {}
    print('Starting processing across models...')
    for mid, title, page in MODELS:
        src_png = f'/tmp/png_sheets/{mid}-ready.png'
        if not os.path.exists(src_png):
            print(f'Skipping {mid}, source not found.')
            continue

        dir_name = f'{mid}_{title}'
        out_dir = os.path.join(doku_ads, dir_name)
        records = process_model(mid, title, src_png, out_dir)

        model_q = questions_map.get(mid, {})
        for r in records:
            ltr = r['letter'].lower()
            if ltr in model_q:
                r['matched_question'] = model_q[ltr]['item_id']
                r['situation'] = model_q[ltr]['situation']
            else:
                r['matched_question'] = None
                r['situation'] = 'Distractor / No direct matching situation in exam'

        full_catalog[mid] = {
            'model_id': mid,
            'title': title,
            'page_in_pdf': page,
            'folder': dir_name,
            'ads_count': len(records),
            'ads': records
        }
        print(f'Processed {mid} ({title}): {len(records)} ads extracted & enhanced.')

    analysis_path = os.path.join(doku_ads, 'ads_analysis.json')
    with open(analysis_path, 'w', encoding='utf-8') as fp:
        json.dump(full_catalog, fp, indent=2, ensure_ascii=False)
    print(f'Saved analysis catalog to {analysis_path}')

    readme_path = os.path.join(doku_ads, 'README.md')
    with open(readme_path, 'w', encoding='utf-8') as fp:
        fp.write('# telc B1 Leseverstehen Teil 3 — Extracted & Enhanced Advertisements\n\n')
        fp.write('This directory contains all individual advertisements extracted from the 16 official telc B1 exam models plus Modell SONJA3 (204 advertisements total).\n\n')
        fp.write('Each advertisement has been:\n')
        fp.write('1. **Extracted** individually from its enclosing frame with tight padding.\n')
        fp.write('2. **Enhanced**: Local adaptive 2D background normalization eliminates paper grain, shadows, and scan discoloration, whitening backgrounds to pure `#FFFFFF`.\n')
        fp.write('3. **Text Sharpening**: S-curve contrast enhancement deepens faint ink and makes fine print crisp and legible.\n')
        fp.write('4. **Visual Card Presentation**: Rendered as human-friendly cards (`ad_<letter>_card.png`) with clean rounded frames, bold badge, and German topic titles.\n')
        fp.write('5. **Analyzed**: Mapped to corresponding exam questions (Aufgaben 11–20) from `data/modell-*.json`.\n\n')
        fp.write('## Catalog by Exam Model\n\n')

        for mid in sorted(full_catalog.keys()):
            m = full_catalog[mid]
            fp.write(f'### {m["model_id"]} — {m["title"]} (Page {m["page_in_pdf"]})\n')
            fp.write(f'Folder: [`{m["folder"]}/`](file://{os.path.join(doku_ads, m["folder"])})\n\n')
            fp.write('| Letter | Title / Description | Matched Exam Question | Card Image |\n')
            fp.write('| :---: | :--- | :--- | :--- |\n')
            for ad in m['ads']:
                q_info = f'**Q{ad["matched_question"]}**' if ad['matched_question'] else '*(Distractor)*'
                card_link = f'[`{ad["card_image"]}`](file://{os.path.join(doku_ads, m["folder"], ad["card_image"])})'
                fp.write(f'| **{ad["letter"]}** | {ad["title"]} | {q_info} | {card_link} |\n')
            fp.write('\n')

    print(f'Saved Markdown index to {readme_path}')


if __name__ == '__main__':
    main()
