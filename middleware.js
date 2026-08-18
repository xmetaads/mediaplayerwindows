/* ==========================================================================
   CONG TAC CHUYEN HUONG  /  redirect switch
   --------------------------------------------------------------------------
   Sua 3 dong ngay ben duoi roi commit. Vercel tu deploy trong ~30 giay.

     ENABLED   = true   -> BAT chuyen huong
                 false  -> TAT, website hien lai nhu cu

     TARGET    = dia chi muon chuyen huong toi (nho dau / o cuoi)

     PERMANENT = false  -> 307 tam thoi. Tat la het chuyen huong NGAY.
                 true   -> 301 vinh vien. Tot cho SEO, nhung trinh duyet
                           nho rat lau: tat roi khach cu VAN bi chuyen
                           huong cho toi khi ho tu xoa cache.
                           Chi dat true khi da chac chan khong doi nua.

   Khong muon sua code? Vao Vercel -> Settings -> Environment Variables,
   dat REDIRECT_ENABLED = 0 hoac 1 (va REDIRECT_TARGET neu muon doi dich),
   roi bam Redeploy. Bien moi truong luon duoc uu tien hon 3 dong duoi day.

   Hoac chay script o may:  .\redirect.ps1 -Off   /   .\redirect.ps1 -On
   ========================================================================== */

const ENABLED   = false;
const TARGET    = 'https://www.driveplayerwindows.com/';
const PERMANENT = false;

/* ========================================================================== */

function flag(value, fallback) {
  if (value === undefined || value === null || value === '') return fallback;
  return ['1', 'true', 'on', 'yes'].includes(String(value).toLowerCase());
}

export default function middleware() {
  const enabled = flag(process.env.REDIRECT_ENABLED, ENABLED);

  if (!enabled) {
    // Di tiep toi file tinh trong repo - website hien thi binh thuong.
    return new Response(null, { headers: { 'x-middleware-next': '1' } });
  }

  const target    = process.env.REDIRECT_TARGET || TARGET;
  const permanent = flag(process.env.REDIRECT_PERMANENT, PERMANENT);

  return Response.redirect(target, permanent ? 301 : 307);
}
