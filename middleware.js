/* ==========================================================================
   CÔNG TẮC CHUYỂN HƯỚNG  —  redirect switch
   --------------------------------------------------------------------------
   Sửa 3 dòng ngay bên dưới rồi commit. Vercel tự deploy trong ~30 giây.

     ENABLED   = true   -> BẬT chuyển hướng
                 false  -> TẮT, website hiện lại như cũ

     TARGET    = địa chỉ muốn chuyển hướng tới (nhớ dấu / ở cuối)

     PERMANENT = false  -> 307 tạm thời. Tắt là hết chuyển hướng NGAY.
                 true   -> 301 vĩnh viễn. Tốt cho SEO, nhưng trình duyệt
                           nhớ rất lâu: tắt rồi khách cũ VẪN bị chuyển
                           hướng cho tới khi họ tự xoá cache.
                           Chỉ bật true khi đã chắc chắn không đổi nữa.

   Không muốn sửa code? Vào Vercel -> Settings -> Environment Variables,
   đặt REDIRECT_ENABLED = 0 hoặc 1 (và REDIRECT_TARGET nếu muốn đổi đích),
   rồi bấm Redeploy. Biến môi trường luôn được ưu tiên hơn 3 dòng dưới đây.
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
    // Đi tiếp tới file tĩnh trong repo — website hiển thị bình thường.
    return new Response(null, { headers: { 'x-middleware-next': '1' } });
  }

  const target    = process.env.REDIRECT_TARGET || TARGET;
  const permanent = flag(process.env.REDIRECT_PERMANENT, PERMANENT);

  return Response.redirect(target, permanent ? 301 : 307);
}
