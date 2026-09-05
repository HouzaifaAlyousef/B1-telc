/* ============================================================
   صيغة اللصق: نص ← امتحان
   ============================================================
   بتلصقي نص الامتحان بصيغة بسيطة، وبتتحوّل لنفس الشكل يلي بتفهمه
   قاعدة البيانات. الصيغة مقصودة تكون مكتوبة بالإيد، مو مولّدة.

   ليش محلّل ثابت مو ذكاء اصطناعي؟ لأنه بينفحص، وببلاش، وما بيهلوس.
   إذا عندك نص خام غير منظّم، حوّليه لهالصيغة برّا التطبيق — وبعدين
   الصقيه هون وشوفي بعينك شو انقرا قبل ما تنشري.

   المثال الكامل بـdocs/12-import-format.md
   ============================================================ */
'use strict';

const Markup = (() => {

  /* ---------- أدوات ---------- */
  const LABEL = /^([A-Za-zÄÖÜäöüß]+)\s*:\s*(.*)$/;
  const norm  = s => s.trim().toLowerCase()
    .replace(/ö/g,'oe').replace(/ä/g,'ae').replace(/ü/g,'ue').replace(/ß/g,'ss');

  const num = v => {
    const n = Number(String(v).replace(',', '.'));
    return Number.isFinite(n) ? n : null;
  };

  /* سطر بينهي وضع النص المتعدّد الأسطر */
  const BOUNDARY_LABELS = new Set(['aufgaben','auswahl','text','extra']);
  function isBoundary(t){
    if (/^#{1,3}\s/.test(t)) return true;
    if (/^\[[^\]]{1,12}\]/.test(t)) return true;
    const m = t.match(/^([A-Za-zÄÖÜäöüß]+)\s*:\s*/);
    return !!m && BOUNDARY_LABELS.has(m[1].trim().toLowerCase()
      .replace(/ö/g,'oe').replace(/ä/g,'ae').replace(/ü/g,'ue').replace(/ß/g,'ss'));
  }

  /* الحقول يلي بتنكتب على مستوى القسم */
  const SECTION_LABELS = {
    format: 'format', titel: 'title', gruppe: 'group', minuten: 'minutes',
    punkte: 'pointsPerItem', maximum: 'maxPoints', anweisung: 'instruction',
    hinweis: 'note', auswahltitel: 'bankTitle', bild: 'bankImage',
    hoertext: 'audio', wiedergaben: 'audioPlays'
  };

  /* ============================================================
     التحليل: نص ← كائن
     ============================================================ */
  function parse(text){
    const warn = [];
    const lines = String(text || '').replace(/\r\n?/g, '\n').split('\n');

    const test = { title: null, subtitle: null, blocks: [], sections: [] };
    let block = null, sec = null, item = null;
    let mode = null;          // null | 'bank' | 'items' | 'text' | 'extra'
    let buf = [];             // سطور مجمّعة للوضع الحالي
    let passages = [];

    const flushBuffer = () => {
      if (!sec || !mode) { buf = []; return; }
      if (mode === 'extra' && buf.length){
        try { Object.assign(sec, JSON.parse(buf.join('\n'))); }
        catch (e){ warn.push(`Teil ${sec.id}: Extra-JSON ist ungültig (${e.message})`); }
      }
      if (mode === 'text' && buf.length){
        const paragraphs = [];
        buf.forEach(l => {
          const t = l.trim();
          if (!t) return;
          const b = /^\*\*.*\*\*$/.test(t);
          paragraphs.push({ t: b ? t.replace(/^\*\*|\*\*$/g, '').trim() : t, b });
        });
        if (paragraphs.length) passages.push({ paragraphs });
      }
      buf = [];
    };

    const closeItem = () => {
      if (!item || !sec) return;
      item.text = (item._text || []).join(' ').replace(/\s+/g, ' ').trim();
      delete item._text;
      if (item.options && !item.options.length) delete item.options;
      if (item._pts && item._pts.length){ item.points = item._pts; }
      delete item._pts;
      if (!item.answer && sec.format !== 'writing')
        warn.push(`Aufgabe ${item.id} in Teil ${sec.id} hat keine Lösung`);
      sec.items.push(item);
      item = null;
    };

    const closeSection = () => {
      closeItem();
      flushBuffer();
      if (!sec) return;
      if (passages.length){ sec.passages = passages; passages = []; }
      if (sec.bank && !sec.bank.length) delete sec.bank;
      if (!sec.items.length) warn.push(`Teil ${sec.id} hat keine Aufgaben`);
      // المحسوب: النقاط المتاحة فعلياً من عدد الأسئلة
      const ppi = sec.pointsPerItem;
      if (ppi != null && sec.format !== 'writing'){
        sec.availablePoints = Math.round(sec.items.length * ppi * 10) / 10;
        if (sec.maxPoints == null) sec.maxPoints = sec.availablePoints;
        sec.missing = Math.max(0,
          Math.round((sec.maxPoints - sec.availablePoints) / ppi));
      } else {
        sec.availablePoints ??= sec.maxPoints ?? 0;
        sec.missing ??= 0;
      }
      test.sections.push(sec);
      sec = null; mode = null;
    };

    const closeBlock = () => {
      if (!block) return;
      test.blocks.push(block);
      block = null;
    };

    for (let raw of lines){
      const line = raw.replace(/\s+$/, '');
      const t = line.trim();

      /* ---- رؤوس ---- */
      if (/^###\s*(Teil|Section)\s*:/i.test(t)){
        closeSection();
        sec = { id: t.split(':').slice(1).join(':').trim(), items: [] };
        if (!sec.id) warn.push('Ein Teil hat keine Kennung (### Teil: lv1)');
        mode = null; passages = [];
        continue;
      }
      if (/^##\s*(Block)\s*:/i.test(t)){
        closeSection(); closeBlock();
        block = { id: t.split(':').slice(1).join(':').trim(), parts: [] };
        continue;
      }
      if (/^#\s+/.test(t)){
        closeSection(); closeBlock();
        test.title = t.replace(/^#\s+/, '').trim();
        continue;
      }

      /* ---- بداية سؤال: [12] ---- */
      const m = t.match(/^\[([^\]]{1,12})\]\s*(.*)$/);
      if (m && sec){
        if (mode !== 'items'){ flushBuffer(); mode = 'items'; }
        closeItem();
        item = { id: m[1].trim(), _text: m[2] ? [m[2]] : [], options: [] };
        continue;
      }

      /* ---- جوّا سؤال ---- */
      if (item){
        const opt = t.match(/^([A-Za-z])\)\s*(.+)$/);
        if (opt){ item.options.push({ key: opt[1].toUpperCase(), text: opt[2].trim() }); continue; }
        const lab = t.match(LABEL);
        if (lab){
          const k = norm(lab[1]), v = lab[2].trim();
          if (k === 'loesung'){
            item.answer = sec.format === 'truefalse'
              ? (/^(r|richtig|true|wahr)$/i.test(v) ? 'r' : 'f')
              : v;
            continue;
          }
          if (k === 'mindestwoerter'){ item.minWords = num(v); continue; }
          if (k === 'punkt'){ (item._pts ||= []).push(v); continue; }
          if (k === 'erklaerung'){ item.explain = v; continue; }
        }
        if (t) item._text.push(t);
        continue;
      }

      /* ---- أوضاع متعددة الأسطر ---- */
      if (mode === 'bank' && sec){
        const b = t.match(/^([A-Za-z0-9]{1,3})\s*=\s*(.*)$/);
        if (b){ (sec.bank ||= []).push({ key: b[1].toUpperCase(), text: b[2].trim() }); continue; }
        if (!t) continue;
      }
      if (mode === 'extra'){
        buf.push(line);
        // JSON بينتهي لما تتوازن الأقواس — هيك بينفع مضغوط ومنسّق سوا
        const j = buf.join('\n');
        let depth = 0, str = false, esclast = false;
        for (const ch of j){
          if (str){ if (esclast) esclast = false;
                    else if (ch === '\\') esclast = true;
                    else if (ch === '"') str = false; continue; }
          if (ch === '"') str = true;
          else if (ch === '{' || ch === '[') depth++;
          else if (ch === '}' || ch === ']') depth--;
        }
        if (depth <= 0 && /[}\]]/.test(j)){ flushBuffer(); mode = null; }
        continue;
      }
      if (mode === 'text'){
        if (t === '§§§'){ flushBuffer(); continue; }   // فاصل بين نصّين
        // حد فاصل: عنوان، سؤال، أو تسمية بتبدّل الوضع. بدون هالفحص
        // بينبلع سطر «Aufgaben:» كأنه فقرة من النص.
        if (!isBoundary(t)){ buf.push(line); continue; }
        flushBuffer(); mode = null;
        // ما منعمل continue: منخلّي السطر يتعالج عادي تحت
      }

      /* ---- تسميات ---- */
      const lab = t.match(LABEL);
      if (lab){
        const k = norm(lab[1]), v = lab[2].trim();

        if (!sec && !block){
          if (k === 'untertitel'){ test.subtitle = v; continue; }
        }
        if (block && !sec){
          if (k === 'titel')   { block.title = v; continue; }
          if (k === 'minuten') { block.minutes = num(v); continue; }
          if (k === 'hinweis') { block.hint = v; continue; }
          if (k === 'punkte')  { block.maxPoints = num(v); continue; }
          // عدد الأسئلة الناقصة بالكتلة: بيشمل أقسام غايبة كاملة، وهاد
          // شي ما بيقدر المحلّل يستنتجه — لازم ينكتب صراحةً.
          if (k === 'fehlend') { block.missing = num(v); continue; }
          if (k === 'teile'){
            block.parts = v.split(/[,;]/).map(x => x.trim()).filter(Boolean);
            continue;
          }
        }
        if (sec){
          if (k === 'auswahl'){ mode = 'bank'; continue; }
          if (k === 'aufgaben'){ flushBuffer(); mode = 'items'; continue; }
          if (k === 'text'){ flushBuffer(); mode = 'text'; continue; }
          if (k === 'extra'){ flushBuffer(); mode = 'extra'; continue; }
          const key = SECTION_LABELS[k];
          if (key){
            sec[key] = ['minutes','pointsPerItem','maxPoints','audioPlays']
                         .includes(key) ? num(v) : v;
            continue;
          }
          warn.push(`Teil ${sec.id}: unbekannte Angabe „${lab[1]}“`);
          continue;
        }
        if (t) warn.push(`Zeile außerhalb eines Teils: „${t.slice(0, 40)}“`);
        continue;
      }

      if (t && !sec && !block) warn.push(`Unerwartete Zeile: „${t.slice(0, 40)}“`);
    }
    closeSection(); closeBlock();

    /* ---- فحوص أخيرة ---- */
    if (!test.title) warn.push('Kein Titel (# NAME in der ersten Zeile)');
    if (!test.sections.length) warn.push('Keine Teile gefunden');
    const ids = test.sections.map(s => s.id);
    ids.forEach((id, i) => {
      if (ids.indexOf(id) !== i) warn.push(`Teil „${id}“ kommt doppelt vor`);
    });
    test.blocks.forEach(b => (b.parts || []).forEach(p => {
      if (!ids.includes(p)) warn.push(`Block „${b.id}“ verweist auf unbekannten Teil „${p}“`);
    }));
    test.sections.forEach(s => {
      const seen = new Set();
      s.items.forEach(it => {
        if (seen.has(it.id)) warn.push(`Aufgabe „${it.id}“ kommt in ${s.id} doppelt vor`);
        seen.add(it.id);
      });
    });

    // النقاط المتاحة لكل كتلة
    test.blocks.forEach(b => {
      const parts = (b.parts || []).map(p => test.sections.find(s => s.id === p)).filter(Boolean);
      b.availablePoints = Math.round(parts.reduce((a, s) => a + (s.availablePoints || 0), 0) * 10) / 10;
      if (b.maxPoints == null) b.maxPoints = b.availablePoints;
      if (b.missing == null)
        b.missing = parts.reduce((a, s) => a + (s.missing || 0), 0);
    });

    const nItems = test.sections.reduce((a, s) => a + s.items.length, 0);
    return { test, warnings: warn, counts: {
      blocks: test.blocks.length, sections: test.sections.length, items: nItems,
      answers: test.sections.reduce((a, s) =>
        a + s.items.filter(i => i.answer != null).length, 0) } };
  }

  /* ============================================================
     العكس: كائن ← نص. مفيد لتعديل امتحان موجود، ولإثبات إن
     الصيغة بتوسّع المحتوى الحقيقي (اختبار round-trip).
     ============================================================ */
  const EXTRA_KEYS = ['brief','hints','criteria','grades','factor'];

  function serialize(test){
    const L = [];
    L.push(`# ${test.title || ''}`);
    if (test.subtitle) L.push(`Untertitel: ${test.subtitle}`);

    (test.blocks || []).forEach(b => {
      L.push('', `## Block: ${b.id}`);
      if (b.title != null)     L.push(`Titel: ${b.title}`);
      if (b.minutes != null)   L.push(`Minuten: ${b.minutes}`);
      if (b.hint != null)      L.push(`Hinweis: ${b.hint}`);
      if (b.maxPoints != null) L.push(`Punkte: ${b.maxPoints}`);
      if (b.missing != null)   L.push(`Fehlend: ${b.missing}`);
      L.push(`Teile: ${(b.parts || []).join(', ')}`);
    });

    (test.sections || []).forEach(s => {
      L.push('', `### Teil: ${s.id}`);
      L.push(`Format: ${s.format}`);
      if (s.title != null)         L.push(`Titel: ${s.title}`);
      if (s.group != null)         L.push(`Gruppe: ${s.group}`);
      if (s.minutes != null)       L.push(`Minuten: ${s.minutes}`);
      if (s.pointsPerItem != null) L.push(`Punkte: ${s.pointsPerItem}`);
      if (s.maxPoints != null)     L.push(`Maximum: ${s.maxPoints}`);
      if (s.instruction)           L.push(`Anweisung: ${s.instruction}`);
      if (s.note)                  L.push(`Hinweis: ${s.note}`);
      if (s.bankTitle)             L.push(`AuswahlTitel: ${s.bankTitle}`);
      if (s.bankImage)             L.push(`Bild: ${s.bankImage}`);
      if (s.audio)                 L.push(`Hörtext: ${s.audio}`);
      if (s.audioPlays != null)    L.push(`Wiedergaben: ${s.audioPlays}`);

      const extra = {};
      EXTRA_KEYS.forEach(k => { if (s[k] !== undefined) extra[k] = s[k]; });
      if (Object.keys(extra).length){
        L.push('Extra:', JSON.stringify(extra, null, 1));
      }

      if (s.passages && s.passages.length){
        L.push('Text:');
        s.passages.forEach((p, i) => {
          if (i) L.push('§§§');
          (p.paragraphs || []).forEach(x => L.push(x.b ? `**${x.t}**` : x.t));
        });
      }
      if (s.bank && s.bank.length){
        L.push('Auswahl:');
        s.bank.forEach(o => L.push(`${o.key} = ${o.text || ''}`));
      }

      L.push('Aufgaben:');
      (s.items || []).forEach(it => {
        L.push(`[${it.id}] ${String(it.text || '').replace(/\s+/g, ' ').trim()}`);
        (it.options || []).forEach(o => L.push(`${o.key}) ${o.text}`));
        if (it.minWords != null) L.push(`Mindestwörter: ${it.minWords}`);
        if (Array.isArray(it.points)) it.points.forEach(p => L.push(`Punkt: ${p}`));
        if (it.explain) L.push(`Erklärung: ${it.explain}`);
        if (it.answer != null){
          L.push(`Lösung: ${s.format === 'truefalse'
            ? (it.answer === 'r' ? 'richtig' : 'falsch') : it.answer}`);
        }
      });
    });
    return L.join('\n') + '\n';
  }

  return { parse, serialize };
})();

if (typeof module !== 'undefined' && module.exports) module.exports = Markup;
