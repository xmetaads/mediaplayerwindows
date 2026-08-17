/* ==========================================================================
   CÃ”NG Táº®C CHUYá»‚N HÆ¯á»šNG  â€”  redirect switch
   --------------------------------------------------------------------------
   Sá»­a 3 dÃ²ng ngay bÃªn dÆ°á»›i rá»“i commit. Vercel tá»± deploy trong ~30 giÃ¢y.

     ENABLED   = true   -> Báº¬T chuyá»ƒn hÆ°á»›ng
                 false  -> Táº®T, website hiá»‡n láº¡i nhÆ° cÅ©

     TARGET    = Ä‘á»‹a chá»‰ muá»‘n chuyá»ƒn hÆ°á»›ng tá»›i (nhá»› dáº¥u / á»Ÿ cuá»‘i)

     PERMANENT = false  -> 307 táº¡m thá»i. Táº¯t lÃ  háº¿t chuyá»ƒn hÆ°á»›ng NGAY.
                 true   -> 301 vÄ©nh viá»…n. Tá»‘t cho SEO, nhÆ°ng trÃ¬nh duyá»‡t
                           nhá»› ráº¥t lÃ¢u: táº¯t rá»“i khÃ¡ch cÅ© VáºªN bá»‹ chuyá»ƒn
                           hÆ°á»›ng cho tá»›i khi há» tá»± xoÃ¡ cache.
                           Chá»‰ báº­t true khi Ä‘Ã£ cháº¯c cháº¯n khÃ´ng Ä‘á»•i ná»¯a.

   KhÃ´ng muá»‘n sá»­a code? VÃ o Vercel -> Settings -> Environment Variables,
   Ä‘áº·t REDIRECT_ENABLED = 0 hoáº·c 1 (vÃ  REDIRECT_TARGET náº¿u muá»‘n Ä‘á»•i Ä‘Ã­ch),
   rá»“i báº¥m Redeploy. Biáº¿n mÃ´i trÆ°á»ng luÃ´n Ä‘Æ°á»£c Æ°u tiÃªn hÆ¡n 3 dÃ²ng dÆ°á»›i Ä‘Ã¢y.
   ========================================================================== */

const ENABLED   = true;
const TARGET    = 'https://driveplayerwindows.com/';
const PERMANENT = false;

/* ========================================================================== */

function flag(value, fallback) {
  if (value === undefined || value === null || value === '') return fallback;
  return ['1', 'true', 'on', 'yes'].includes(String(value).toLowerCase());
}

export default function middleware() {
  const enabled = flag(process.env.REDIRECT_ENABLED, ENABLED);

  if (!enabled) {
    // Äi tiáº¿p tá»›i file tÄ©nh trong repo â€” website hiá»ƒn thá»‹ bÃ¬nh thÆ°á»ng.
    return new Response(null, { headers: { 'x-middleware-next': '1' } });
  }

  const target    = process.env.REDIRECT_TARGET || TARGET;
  const permanent = flag(process.env.REDIRECT_PERMANENT, PERMANENT);

  return Response.redirect(target, permanent ? 301 : 307);
}
