/* كاتب واحد لسطر `Hörtext:` — بيستعمله link_audio.mjs وrelink_audio.mjs.
 *
 * ★ ليش مشترك: telc/b1 مصدره data/*.json وغيره text.txt، والفرق سهل
 *   ينتنسى. كاتبين اتنين معناهن مستوى بينكتب صح ومستوى بينكتب غلط،
 *   والفرق ما بيبيّن إلا لما الطالب يضغط «شغّل» وما يطلع صوت.
 */
import { readFileSync, writeFileSync } from 'fs';
import path from 'path';

/* الاسم بالدلو بيحمل كل شي: telc-b1-m01-hv1.mp3
   الدلو مسطّح، فالاسم هو المفتاح الوحيد — ومنه منرجّع الربط لو ضاعت
   الملفّات المحلية (وهي مستثناة من git عن قصد). */
export const AUDIO_RE =
  /^([a-z]+)-([a-z]\d)-m(\d{2})-([a-z]{1,2}\d?|hvs)\.(mp3|m4a|ogg|wav|aac)$/i;

export function parseAudioName(file){
  const m = AUDIO_RE.exec(file);
  if (!m) return null;
  return { prov: m[1].toLowerCase(), lvl: m[2].toLowerCase(),
           model: `modell-${m[3]}`, sec: m[4].toLowerCase(), name: file };
}

/* كتابة `Hörtext:` بمصدر المستوى — data/ لـtelc/b1، وtext.txt لغيره */
export function setAudio(ROOT, prov, lvl, m, sec, name, plays){
  if (prov === 'telc' && lvl === 'b1') {
    const f = path.join(ROOT, 'data', `${m}.json`);
    const d = JSON.parse(readFileSync(f, 'utf8'));
    const s = (d.sections || []).find(x => x.id === sec);
    if (!s) throw new Error(`${m}: ما في قسم ${sec}`);
    s.audio = name; s.audioPlays = plays;
    // ★ ملاحظة «ما في تسجيلات بالـPDF» صارت كذب بعد ما إجا التسجيل.
    //   التطبيق بيخفيها لحاله لما يكون في صوت، بس خلّيها تنشال من
    //   المصدر كمان — ملاحظة كاذبة بالملف بترجع تطلع بأوّل تصدير.
    if (/H(ö|oe)rtexte .*nicht enthalten/i.test(s.note || '')) delete s.note;
    writeFileSync(f, JSON.stringify(d, null, 1) + '\n');
    return;
  }
  const f = path.join(ROOT, 'content', prov, lvl, m, 'text.txt');
  let t = readFileSync(f, 'utf8');
  const re = new RegExp(`(^### Teil: ${sec}$)([\\s\\S]*?)(?=^### Teil: |\\Z)`, 'm');
  const mt = re.exec(t);
  if (!mt) throw new Error(`${m}: ما في قسم ${sec} بـtext.txt`);
  let body = mt[2]
    .replace(/^H(ö|oe)rtext: .*\n/gm, '')
    .replace(/^Wiedergaben: .*\n/gm, '')
    .replace(/^Hinweis: .*H(ö|oe)rtexte .*nicht enthalten.*\n/gm, '');
  // بعد سطر Format: — مطرحه الطبيعي بباقي الملفّات
  body = body.replace(/(^Format: .*\n)/m, `$1Hörtext: ${name}\nWiedergaben: ${plays}\n`);
  t = t.slice(0, mt.index) + mt[1] + body + t.slice(mt.index + mt[0].length);
  writeFileSync(f, t);
}
