/* ترجمة الواجهة: ألماني (الأصل)، عربي، أوكراني.

   ★ الواجهة فقط. نصوص الامتحان — الأسئلة، النصوص، تعليمات telc — بتضل
     ألمانية. ترجمتها بتلغي الامتحان: قراءة التعليمة الألمانية جزء من
     الاختبار، وتغييرها بيخلّي التدرّب مو مطابق لليوم الحقيقي.

   الجمع: كل لغة إلها قواعدها (الألماني شكلين، الأوكراني تلاتة، العربي
   ستة). Intl.PluralRules هي يلي بتقرّر، وكل مدخلة بتعطي أشكالها. */
'use strict';

const I18N = (() => {

  const LANGS = [
    { id: 'de', name: 'Deutsch',    dir: 'ltr' },
    { id: 'ar', name: 'العربية',    dir: 'rtl' },
    { id: 'uk', name: 'Українська', dir: 'ltr' }
  ];

  const DICT = {
    de: {
      back: '‹ Zurück',
      loading: 'Lädt …',
      moment: 'Einen Moment …',
      preparing: 'Wird vorbereitet …',
      noServer: 'Keine Verbindung zum Server.',
      tryLater: 'Bitte später noch einmal versuchen.',
      notConfigured: 'Die App ist noch nicht mit dem Server verbunden.',
      fillConfig: 'assets/config.js ausfüllen.',

      codeTitle: 'Zugang',
      codeHint: 'Geben Sie Ihren Zugangscode ein. Sie haben ihn beim Kauf ' +
                'erhalten. Der Code wird nur einmal gebraucht — danach bleibt ' +
                'dieses Gerät angemeldet.',
      codeButton: 'Freischalten',

      welcome: 'Willkommen 👋',
      homeIntro: 'Wählen Sie einen Modelltest. Jeder Test hat die Prüfungsteile ' +
                 'der schriftlichen Prüfung {level} — mit der echten Prüfungszeit.',
      homeIntroPlain: 'Wählen Sie einen Modelltest. Jeder Test hat die ' +
                      'Prüfungsteile der schriftlichen Prüfung — mit der echten Prüfungszeit.',
      material: 'Lesematerial',
      materialMeta: 'Wortschatz und Hinweise · jederzeit',
      materialEmpty: 'Für diese Prüfung ist noch nichts hinterlegt.',
      repeat: 'Wiederholen',
      due: '{n} fällig',
      nothingDue: 'Nichts fällig',
      sitting: '{n} sitzen schon',
      noTime: 'ohne Zeit',

      fullAccess: 'Voller Zugang',
      demo: 'Demo',
      until: 'bis {date}',
      daysLeft: { one: 'noch {n} Tag', other: 'noch {n} Tage' },
      hoursLeft: { one: 'noch {n} Stunde', other: 'noch {n} Stunden' },
      lessThanHour: 'weniger als 1 Stunde',
      expired: 'abgelaufen',
      upsell: '{n} in dieser Prüfung enthalten. Mit dem vollen Zugang stehen ' +
              'alle offen — mit Korrektur und Lösungen.',

      overview: 'Übersicht',
      start: 'Start ▶',
      resume: 'Weiter',
      pause: 'Pause',
      finish: 'Beenden',
      submit: 'Abgeben & korrigieren',
      restart: 'Neu beginnen',
      timeUp: 'Die Zeit ist abgelaufen ⏱',
      timerPaused: 'Der Timer steht. Sie können die App schließen und später ' +
                   'weitermachen.',
      loadFailed: 'Der Modelltest konnte nicht geladen werden.',
      levelFailed: 'Die Prüfung konnte nicht geladen werden.',
      savedOffline: 'Ihre Antworten sind gespeichert — bitte mit Verbindung ' +
                    'erneut abgeben.',

      audioPlay: '▶ Hörtext abspielen',
      audioAgain: '▶ Noch einmal',
      audioDone: '▶ Abgespielt',
      audioLoading: 'Hörtext wird geladen …',
      audioFailed: 'Der Hörtext konnte nicht geladen werden.',
      audioLeft: { one: 'noch {n}× abspielbar', other: 'noch {n}× abspielbar' },
      audioNone: 'keine Wiedergabe mehr',
      transcript: 'Hörtext',

      imgLoading: 'Anzeigen werden geladen …',
      imgTap: 'Zum Vergrößern auf das Bild tippen',

      yourAnswer: 'Ihre Antwort',
      choose: '— bitte wählen —',
      solution: 'Lösung',
      wrong: '✘ Falsch · 0 P.',
      errorDetail: 'Fehler im Einzelnen',
      noSolutions: 'Für diese Prüfung liegen keine Lösungen vor.',
      noMistakes: 'Keine Fehler gespeichert.',
      empty: 'Leer.',
      view: 'Ansehen',
      remove: 'Löschen',
      tasks: 'Aufgaben',
      time: 'Zeit',
      better: 'Besser',

      yourText: 'Ihr Text',
      rateSelf: 'Bewerten Sie jedes Kriterium selbst — so wie telc bewertet.',
      grading: 'Bewertung',
      aiIntro: 'Ihr Brief wird gelesen und nach den telc-Kriterien bewertet — ' +
               'mit Hinweisen zu jedem Fehler.',
      aiRequest: 'Korrektur anfordern',
      aiWorking: 'Wird korrigiert …',
      aiView: 'Korrigierte Fassung ansehen',
      aiOffline: 'Ohne Verbindung ist keine Korrektur möglich.',
      aiFailed: 'Die Korrektur ist fehlgeschlagen.',
      correction: 'Korrektur',

      yes: 'Ja',
      no: 'Abbrechen',
      leave: 'Verlassen',
      leaveAsk: 'Prüfung verlassen? Ihre Antworten gehen verloren.',
      words: { one: '{n} Wort', other: '{n} Wörter' },
      minWords: '— mindestens {n} verlangt',
      passFrom: 'bestanden ab {p} Punkten (60 %)',

      again: 'Wiederholen',
      taskHead: 'Aufgabe',

      nTask:    { one: '{n} Aufgabe',     other: '{n} Aufgaben' },
      nMinute:  { one: '{n} Minute',      other: '{n} Minuten' },
      nTest:    { one: '{n} Modelltest',  other: '{n} Modelltests' },
      nText:    { one: '{n} Text',        other: '{n} Texte' },
      nMissing: { one: '{n} Aufgabe fehlt', other: '{n} Aufgaben fehlen' },
      nSits:    { one: '{n} Aufgabe sitzt', other: '{n} Aufgaben sitzen' },
      nMore:    { one: '{n} weiterer Modelltest ist',
                  other: '{n} weitere Modelltests sind' }
    },

    ar: {
      back: '‹ رجوع',
      loading: 'جاري التحميل …',
      moment: 'لحظة …',
      preparing: 'جاري التحضير …',
      noServer: 'ما في اتصال بالخادم.',
      tryLater: 'جرّب مرة تانية بعد شوي.',
      notConfigured: 'التطبيق لسا مو مربوط بالخادم.',
      fillConfig: 'عبّي assets/config.js.',

      codeTitle: 'الدخول',
      codeHint: 'أدخل رمز الدخول. أخذته عند الشراء. الرمز بينستعمل مرة ' +
                'وحدة — وبعدها بيضل هالجهاز مسجّل.',
      codeButton: 'تفعيل',

      welcome: 'أهلاً 👋',
      homeIntro: 'اختر نموذج امتحان. كل نموذج فيه أقسام الامتحان التحريري ' +
                 '{level} — بوقت الامتحان الحقيقي.',
      homeIntroPlain: 'اختر نموذج امتحان. كل نموذج فيه أقسام الامتحان ' +
                      'التحريري — بوقت الامتحان الحقيقي.',
      material: 'مواد للقراءة',
      materialMeta: 'مفردات وملاحظات · بأي وقت',
      materialEmpty: 'لهالامتحان لسا ما في مواد.',
      repeat: 'مراجعة',
      due: '{n} مستحقّة',
      nothingDue: 'ما في شي مستحقّ',
      sitting: '{n} صارت راسخة',
      noTime: 'بلا وقت',

      fullAccess: 'وصول كامل',
      demo: 'تجريبي',
      until: 'لتاريخ {date}',
      daysLeft: { zero: 'ما بقي يوم', one: 'باقي يوم', two: 'باقي يومين',
                  few: 'باقي {n} أيام', many: 'باقي {n} يوم',
                  other: 'باقي {n} يوم' },
      hoursLeft: { zero: 'ما بقيت ساعة', one: 'باقي ساعة', two: 'باقي ساعتين',
                   few: 'باقي {n} ساعات', many: 'باقي {n} ساعة',
                   other: 'باقي {n} ساعة' },
      lessThanHour: 'أقل من ساعة',
      expired: 'انتهى',
      upsell: '{n} بهالامتحان. مع الوصول الكامل بتنفتح كلها — مع التصحيح ' +
              'والحلول.',

      overview: 'نظرة عامة',
      start: 'ابدأ ▶',
      resume: 'متابعة',
      pause: 'إيقاف مؤقّت',
      finish: 'إنهاء',
      submit: 'تسليم وتصحيح',
      restart: 'ابدأ من جديد',
      timeUp: 'انتهى الوقت ⏱',
      timerPaused: 'المؤقّت واقف. فيك تسكّر التطبيق وتكمّل بعدين.',
      loadFailed: 'ما قدرنا نحمّل النموذج.',
      levelFailed: 'ما قدرنا نحمّل الامتحان.',
      savedOffline: 'إجاباتك محفوظة — سلّمها لما يرجع الاتصال.',

      audioPlay: '▶ شغّل التسجيل',
      audioAgain: '▶ مرة تانية',
      audioDone: '▶ انتهى التشغيل',
      audioLoading: 'جاري تحميل التسجيل …',
      audioFailed: 'ما قدرنا نحمّل التسجيل.',
      audioLeft: { zero: 'ما بقي تشغيل', one: 'باقي تشغيل واحد',
                   two: 'باقي تشغيلين', few: 'باقي {n} تشغيلات',
                   many: 'باقي {n} تشغيل', other: 'باقي {n} تشغيل' },
      audioNone: 'ما بقي تشغيل',
      transcript: 'نص التسجيل',

      imgLoading: 'جاري تحميل الإعلانات …',
      imgTap: 'اضغط على الصورة لتكبيرها',

      yourAnswer: 'إجابتك',
      choose: '— اختر —',
      solution: 'الحل',
      wrong: '✘ خطأ · ٠ نقطة',
      errorDetail: 'تفصيل الأخطاء',
      noSolutions: 'لهالامتحان ما في حلول.',
      noMistakes: 'ما في أخطاء محفوظة.',
      empty: 'فاضي.',
      view: 'عرض',
      remove: 'حذف',
      tasks: 'الأسئلة',
      time: 'الوقت',
      better: 'أفضل',

      yourText: 'نصّك',
      rateSelf: 'قيّم كل معيار بنفسك — متل ما بيقيّم telc.',
      grading: 'التقييم',
      aiIntro: 'رسالتك رح تنقرا وتتقيّم حسب معايير telc — مع ملاحظة على ' +
               'كل خطأ.',
      aiRequest: 'اطلب التصحيح',
      aiWorking: 'جاري التصحيح …',
      aiView: 'شوف النسخة المصحّحة',
      aiOffline: 'بلا اتصال ما في تصحيح.',
      aiFailed: 'فشل التصحيح.',
      correction: 'التصحيح',

      yes: 'نعم',
      no: 'إلغاء',
      leave: 'خروج',
      leaveAsk: 'تطلع من الامتحان؟ إجاباتك بتضيع.',
      words: { zero: 'ولا كلمة', one: 'كلمة', two: 'كلمتين',
               few: '{n} كلمات', many: '{n} كلمة', other: '{n} كلمة' },
      minWords: '— المطلوب {n} على الأقل',
      passFrom: 'النجاح من {p} نقطة (٦٠٪)',

      again: 'إعادة',
      taskHead: 'السؤال',

      nTask:    { zero: 'ولا سؤال', one: 'سؤال واحد', two: 'سؤالين',
                  few: '{n} أسئلة', many: '{n} سؤال', other: '{n} سؤال' },
      nMinute:  { zero: 'ولا دقيقة', one: 'دقيقة', two: 'دقيقتين',
                  few: '{n} دقائق', many: '{n} دقيقة', other: '{n} دقيقة' },
      nTest:    { zero: 'ولا نموذج', one: 'نموذج واحد', two: 'نموذجين',
                  few: '{n} نماذج', many: '{n} نموذج', other: '{n} نموذج' },
      nText:    { zero: 'ولا نص', one: 'نص واحد', two: 'نصّين',
                  few: '{n} نصوص', many: '{n} نص', other: '{n} نص' },
      nMissing: { zero: 'ما في ناقص', one: 'سؤال ناقص', two: 'سؤالين ناقصين',
                  few: '{n} أسئلة ناقصة', many: '{n} سؤال ناقص',
                  other: '{n} سؤال ناقص' },
      nSits:    { zero: 'ولا سؤال راسخ', one: 'سؤال راسخ', two: 'سؤالين راسخين',
                  few: '{n} أسئلة راسخة', many: '{n} سؤال راسخ',
                  other: '{n} سؤال راسخ' },
      nMore:    { zero: 'ما في نماذج تانية', one: 'في نموذج تاني',
                  two: 'في نموذجين تانيين', few: 'في {n} نماذج تانية',
                  many: 'في {n} نموذج تاني', other: 'في {n} نموذج تاني' }
    },

    uk: {
      back: '‹ Назад',
      loading: 'Завантаження …',
      moment: 'Хвилинку …',
      preparing: 'Підготовка …',
      noServer: 'Немає зв’язку із сервером.',
      tryLater: 'Спробуйте пізніше.',
      notConfigured: 'Застосунок ще не підключено до сервера.',
      fillConfig: 'Заповніть assets/config.js.',

      codeTitle: 'Доступ',
      codeHint: 'Введіть код доступу. Ви отримали його під час покупки. ' +
                'Код потрібен лише один раз — далі пристрій залишається ' +
                'підключеним.',
      codeButton: 'Активувати',

      welcome: 'Вітаємо 👋',
      homeIntro: 'Оберіть пробний тест. Кожен тест містить частини письмового ' +
                 'іспиту {level} — зі справжнім часом.',
      homeIntroPlain: 'Оберіть пробний тест. Кожен тест містить частини ' +
                      'письмового іспиту — зі справжнім часом.',
      material: 'Матеріали для читання',
      materialMeta: 'Лексика та поради · будь-коли',
      materialEmpty: 'Для цього іспиту ще нічого немає.',
      repeat: 'Повторення',
      due: '{n} до повторення',
      nothingDue: 'Нічого не потрібно',
      sitting: '{n} вже засвоєно',
      noTime: 'без часу',

      fullAccess: 'Повний доступ',
      demo: 'Демо',
      until: 'до {date}',
      daysLeft: { one: 'ще {n} день', few: 'ще {n} дні',
                  many: 'ще {n} днів', other: 'ще {n} дня' },
      hoursLeft: { one: 'ще {n} година', few: 'ще {n} години',
                   many: 'ще {n} годин', other: 'ще {n} години' },
      lessThanHour: 'менше ніж година',
      expired: 'термін вичерпано',
      upsell: '{n} у цьому іспиті. З повним доступом відкриті всі — з ' +
              'перевіркою та відповідями.',

      overview: 'Огляд',
      start: 'Почати ▶',
      resume: 'Далі',
      pause: 'Пауза',
      finish: 'Завершити',
      submit: 'Здати й перевірити',
      restart: 'Почати заново',
      timeUp: 'Час вичерпано ⏱',
      timerPaused: 'Таймер зупинено. Можна закрити застосунок і продовжити ' +
                   'пізніше.',
      loadFailed: 'Не вдалося завантажити тест.',
      levelFailed: 'Не вдалося завантажити іспит.',
      savedOffline: 'Ваші відповіді збережено — здайте їх, коли буде зв’язок.',

      audioPlay: '▶ Відтворити аудіо',
      audioAgain: '▶ Ще раз',
      audioDone: '▶ Відтворено',
      audioLoading: 'Аудіо завантажується …',
      audioFailed: 'Не вдалося завантажити аудіо.',
      audioLeft: { one: 'ще {n} відтворення', few: 'ще {n} відтворення',
                   many: 'ще {n} відтворень', other: 'ще {n} відтворення' },
      audioNone: 'відтворень не залишилось',
      transcript: 'Текст аудіо',

      imgLoading: 'Оголошення завантажуються …',
      imgTap: 'Торкніться зображення, щоб збільшити',

      yourAnswer: 'Ваша відповідь',
      choose: '— оберіть —',
      solution: 'Відповідь',
      wrong: '✘ Неправильно · 0 б.',
      errorDetail: 'Помилки докладно',
      noSolutions: 'Для цього іспиту немає відповідей.',
      noMistakes: 'Помилок не збережено.',
      empty: 'Порожньо.',
      view: 'Переглянути',
      remove: 'Видалити',
      tasks: 'Завдання',
      time: 'Час',
      better: 'Краще',

      yourText: 'Ваш текст',
      rateSelf: 'Оцініть кожен критерій самі — так само, як оцінює telc.',
      grading: 'Оцінювання',
      aiIntro: 'Ваш лист буде прочитано й оцінено за критеріями telc — з ' +
               'поясненням кожної помилки.',
      aiRequest: 'Запросити перевірку',
      aiWorking: 'Перевіряємо …',
      aiView: 'Переглянути виправлений варіант',
      aiOffline: 'Без зв’язку перевірка неможлива.',
      aiFailed: 'Перевірка не вдалася.',
      correction: 'Перевірка',

      yes: 'Так',
      no: 'Скасувати',
      leave: 'Вийти',
      leaveAsk: 'Вийти з іспиту? Ваші відповіді буде втрачено.',
      words: { one: '{n} слово', few: '{n} слова',
               many: '{n} слів', other: '{n} слова' },
      minWords: '— щонайменше {n}',
      passFrom: 'склав від {p} балів (60 %)',

      again: 'Повторити',
      taskHead: 'Завдання',

      nTask:    { one: '{n} завдання', few: '{n} завдання',
                  many: '{n} завдань', other: '{n} завдання' },
      nMinute:  { one: '{n} хвилина', few: '{n} хвилини',
                  many: '{n} хвилин', other: '{n} хвилини' },
      nTest:    { one: '{n} тест', few: '{n} тести',
                  many: '{n} тестів', other: '{n} тесту' },
      nText:    { one: '{n} текст', few: '{n} тексти',
                  many: '{n} текстів', other: '{n} тексту' },
      nMissing: { one: '{n} завдання бракує', few: '{n} завдання бракує',
                  many: '{n} завдань бракує', other: '{n} завдання бракує' },
      nSits:    { one: '{n} завдання засвоєно', few: '{n} завдання засвоєно',
                  many: '{n} завдань засвоєно', other: '{n} завдання засвоєно' },
      nMore:    { one: 'Ще {n} тест є', few: 'Ще {n} тести є',
                  many: 'Ще {n} тестів є', other: 'Ще {n} тесту є' }
    }
  };

  const KEY = 'b1.lang';
  let lang = 'de';

  /* لغة المتصفّح إذا منعرفها، وإلا ألماني. الاختيار اليدوي بيغلب. */
  function detect(){
    try {
      const saved = localStorage.getItem(KEY);
      if (saved && DICT[saved]) return saved;
    } catch {}
    const nav = (navigator.languages || [navigator.language || ''])
      .map(x => String(x).slice(0, 2).toLowerCase());
    return nav.find(x => DICT[x]) || 'de';
  }

  function setLang(id){
    if (!DICT[id]) return;
    lang = id;
    try { localStorage.setItem(KEY, id); } catch {}
    apply();
  }

  function apply(){
    const d = LANGS.find(l => l.id === lang) || LANGS[0];
    document.documentElement.lang = lang;
    document.documentElement.dir  = d.dir;
  }

  const fill = (tpl, vars) => String(tpl).replace(/\{(\w+)\}/g,
    (_, k) => vars && vars[k] != null ? vars[k] : '');

  /* المفتاح الناقص بيرجع للألماني، وبعدها للمفتاح نفسه. هيك ترجمة
     ناقصة بتطلع بالألماني بدل ما تطلع فاضية. */
  function raw(key){
    const v = DICT[lang] && DICT[lang][key];
    if (v != null) return v;
    const de = DICT.de[key];
    return de != null ? de : key;
  }

  function t(key, vars){
    const v = raw(key);
    return typeof v === 'string' ? fill(v, vars) : key;
  }

  /* الجمع: Intl.PluralRules بتعطي الفئة حسب اللغة، والمدخلة بتعطي شكلها.
     الألماني شكلين، الأوكراني تلاتة، العربي ستة — فربط الشكل بالفئة
     أسلم من عدّ الأشكال بالإيد. */
  function plural(n, key){
    const v = raw(key);
    if (typeof v === 'string') return fill(v, { n });
    let cat = 'other';
    try { cat = new Intl.PluralRules(lang).select(n); } catch {}
    const form = v[cat] != null ? v[cat] : v.other;
    return fill(form, { n });
  }

  lang = detect();
  return { LANGS, t, plural, setLang, get lang(){ return lang; }, apply,
           has: k => !!(DICT[lang] && DICT[lang][k]) };
})();

if (typeof module !== 'undefined' && module.exports) module.exports = I18N;
