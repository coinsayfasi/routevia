/// Converts raw Supabase / network errors into user-friendly Turkish messages.
String friendlyError(dynamic e) {
  final msg = e.toString().toLowerCase();
  if (msg.contains('jwt') ||
      msg.contains('invalid claim') ||
      msg.contains('not authenticated') ||
      msg.contains('unauthorized') ||
      msg.contains('401') ||
      msg.contains('session') && msg.contains('expired')) {
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
  if (msg.contains('permission denied') ||
      msg.contains('403') ||
      msg.contains('row level security') ||
      msg.contains('rls')) {
    return 'Bu işlem için yetkiniz yok.';
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
  return 'Bir sorun oluştu. Lütfen tekrar deneyin.';
}
