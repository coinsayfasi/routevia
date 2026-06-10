/// Converts raw Supabase / network errors into user-friendly Turkish messages.
String friendlyError(dynamic e) {
  final msg = e.toString().toLowerCase();
  if (msg.contains('permission denied') ||
      msg.contains('admin required') ||
      msg.contains('forbidden') ||
      msg.contains('403') ||
      msg.contains('row level security') ||
      msg.contains('rls')) {
    return 'Bu işlem için yetkiniz yok.';
  }
  // Function-specific errors must be checked BEFORE generic auth patterns,
  // because a FunctionException with status 401 also contains "unauthorized"
  // which would otherwise be misclassified as a session-expiry error.
  if (msg.contains('admin_send_push')) {
    return 'Bildirim gönderimi şu an tamamlanamadı.';
  }
  if (msg.contains('jwt') ||
      msg.contains('invalid claim') ||
      msg.contains('not authenticated') ||
      msg.contains('unauthorized') ||
      msg.contains('401') ||
      msg.contains('oturum bulunamadi') ||
      msg.contains('oturum bulu') ||
      (msg.contains('session') && msg.contains('expired'))) {
    return 'Oturum süreniz dolmuş. Lütfen tekrar giriş yapın.';
  }
  if (msg.contains('network') ||
      msg.contains('socket') ||
      msg.contains('connection') ||
      msg.contains('timeout') ||
      msg.contains('failed host lookup') ||
      msg.contains('errno = 7') ||
      msg.contains('no address associated')) {
    return 'Bağlantı sorunu oluştu. İnternet bağlantınızı kontrol edin.';
  }
  if (msg.contains('too many requests') ||
      msg.contains('rate limit') ||
      msg.contains('429')) {
    return 'Çok fazla istek gönderildi. Lütfen biraz bekleyin.';
  }
  if (msg.contains('not found') || msg.contains('404')) {
    return 'İstenen içerik bulunamadı.';
  }
  if (msg.contains('already exists') || msg.contains('duplicate')) {
    return 'Bu kayıt zaten mevcut.';
  }
  if (msg.contains('store satin alma akisi baslatilamadi')) {
    return 'Store satın alma akışı başlatılamadı. Biraz sonra tekrar deneyin.';
  }
  if (msg.contains('verify_purchase')) {
    return 'Satın alma doğrulaması şu an tamamlanamadı. Biraz sonra tekrar deneyin.';
  }
  if (msg.contains('no shared trip found')) {
    return 'Paylaşılan rota bulunamadı veya bağlantı geçersiz.';
  }
  if (msg.contains('share_trip')) {
    return 'Paylaşım bağlantısı şu an üretilemedi.';
  }
  if (msg.contains('resolve_saved_items')) {
    return 'Kaydedilen öğeler şu an çözümlenemedi.';
  }
  if (msg.contains('delete_account')) {
    return 'Hesap silme işlemi şu an tamamlanamadı.';
  }
  if (msg.contains('secilen il bulunamadi')) {
    return 'Seçilen il verisi bulunamadı. Lütfen tekrar seçin.';
  }
  if (msg.contains('geçersiz puan') || msg.contains('gecersiz puan')) {
    return 'Geçerli bir puan seçin.';
  }
  if (msg.contains('mesaj çok kısa') || msg.contains('mesaj cok kisa')) {
    return 'Mesaj çok kısa.';
  }
  if (msg.contains('mesaj çok uzun') || msg.contains('mesaj cok uzun')) {
    return 'Mesaj çok uzun.';
  }
  if (msg.contains('yer hikayesi en az 40 karakter')) {
    return 'Yer hikayesi en az 40 karakter olmalı.';
  }
  if (msg.contains('yer hikayesi 2000 karakteri asamaz') ||
      msg.contains('yer hikayesi 2000 karakteri aşamaz')) {
    return 'Yer hikayesi 2000 karakteri aşamaz.';
  }
  if (msg.contains('kisa baslik 140 karakteri asamaz') ||
      msg.contains('kısa başlık 140 karakteri aşamaz')) {
    return 'Kısa başlık 140 karakteri aşamaz.';
  }
  if (msg.contains('puan 1-5')) {
    return 'Puan 1 ile 5 arasında olmalı.';
  }
  if (msg.contains('daily_photo_limit_exceeded')) {
    return 'Bugün için fotoğraf yükleme limitine ulaştınız. Daha sonra tekrar deneyin.';
  }
  return 'Bir sorun oluştu. Lütfen tekrar deneyin.';
}
