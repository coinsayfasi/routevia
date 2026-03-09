import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.documentId});

  final String documentId;

  @override
  Widget build(BuildContext context) {
    final doc = _docs[documentId] ?? _docs['privacy']!;
    return Scaffold(
      appBar: AppBar(title: Text(doc.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 48),
        children: [
          // Version / date badge
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: Color(0xFF64748B)),
              const SizedBox(width: 6),
              Text(
                'Son güncelleme: ${doc.updatedAt}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Summary card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F9FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: Text(
              doc.summary,
              style: const TextStyle(
                fontSize: 14,
                height: 1.55,
                color: Color(0xFF0C4A6E),
              ),
            ),
          ),
          const SizedBox(height: 14),
          ...doc.sections.map(
            (section) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...section.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ',
                                style: TextStyle(fontWeight: FontWeight.w700)),
                            Expanded(
                              child: Text(
                                item,
                                style: const TextStyle(
                                  height: 1.5,
                                  color: Color(0xFF475569),
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Web link
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => launchUrl(
              Uri.parse(doc.webUrl),
              mode: LaunchMode.externalApplication,
            ),
            icon: const Icon(Icons.open_in_browser, size: 18),
            label: const Text('Tam metni tarayıcıda aç'),
          ),
          const SizedBox(height: 8),
          // Contact
          TextButton.icon(
            onPressed: () => launchUrl(
              Uri.parse(
                'mailto:${AppConstants.supportEmail}'
                '?subject=Routevia%20Hukuki%20Soru',
              ),
            ),
            icon: const Icon(Icons.mail_outline, size: 18),
            label: Text(AppConstants.supportEmail),
          ),
          if (documentId == 'privacy') ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => context.push('/consent'),
              icon: const Icon(Icons.shield_outlined, size: 18),
              label: const Text('Gizlilik ve Consent Ayarlarım'),
            ),
          ],
        ],
      ),
    );
  }
}

class _LegalDoc {
  const _LegalDoc({
    required this.title,
    required this.summary,
    required this.sections,
    required this.updatedAt,
    required this.webUrl,
  });

  final String title;
  final String summary;
  final List<_LegalSection> sections;
  final String updatedAt;
  final String webUrl;
}

class _LegalSection {
  const _LegalSection({required this.title, required this.items});

  final String title;
  final List<String> items;
}

const _docs = <String, _LegalDoc>{
  'privacy': _LegalDoc(
    title: 'Gizlilik Politikası',
    updatedAt: 'Mart 2026',
    webUrl: AppConstants.privacyPolicyUrl,
    summary:
        'Routevia, kişisel verilerinizi yalnızca seyahat deneyimini sunmak ve iyileştirmek amacıyla kullanır. Verileriniz üçüncü taraflara satılmaz.',
    sections: [
      _LegalSection(
        title: 'Toplanan Veriler',
        items: [
          'Hesap verisi: e-posta adresi ve kullanıcı kimliği (Supabase Auth üzerinden).',
          'İçerik verisi: favoriler, yorumlar, puanlar, gezi planları ve kullanıcı önerileri.',
          'Konum verisi: yalnızca uygulama açıkken, yakın yer önerileri için anlık olarak kullanılır; cihazda saklanmaz.',
          'Kullanım verisi: uygulama içi etkinlikler (sayfa görüntüleme, plan oluşturma) — yalnızca analitik onayı verilmişse.',
        ],
      ),
      _LegalSection(
        title: 'Kullanım Amacı',
        items: [
          'Kişiselleştirilmiş gezi önerileri ve plan oluşturma.',
          'Topluluk değerlendirme ve yorum sisteminin işletilmesi.',
          'Hesap güvenliği ve kötüye kullanım tespiti.',
          'Hizmet kalitesini iyileştirmek için anonim kullanım analizi (izin verilmişse).',
        ],
      ),
      _LegalSection(
        title: 'Yasal Dayanak (KVKK / GDPR)',
        items: [
          'Hesap ve içerik verisi: sözleşmenin ifası (KVKK md. 5/2-c).',
          'Analitik verisi: açık rıza (KVKK md. 5/1).',
          'Konum verisi: meşru menfaat — yalnızca aktif oturum sırasında ve hizmet işlevi için.',
          'AB/AEA kullanıcıları için GDPR Madde 6 kapsamında aynı hukuki dayanak geçerlidir.',
        ],
      ),
      _LegalSection(
        title: 'Üçüncü Taraflar',
        items: [
          'Supabase (veritabanı ve kimlik doğrulama) — AB bölgesi sunucuları.',
          'OpenStreetMap — açık lisanslı harita verisi.',
          'OSRM — self-hosted rota hesaplama, kullanıcı konumu iletilmez.',
          'App Store / Google Play — abonelik ve satın alma doğrulama.',
          'Açık lisanslı ve editoryal veri kaynakları — yalnızca ürün içinde izinli içerik gösterilir.',
        ],
      ),
      _LegalSection(
        title: 'Haklarınız',
        items: [
          'Erişim: kayıtlı verilerinizi talep edebilirsiniz.',
          'Silme: Profil > Hesabımı Sil adımıyla hesabınızı ve tüm verilerinizi silebilirsiniz.',
          'Taşınabilirlik: veri talebini ${AppConstants.supportEmail} adresine iletebilirsiniz.',
          'İtiraz: pazarlama ve profilleme amaçlı işlemeye itiraz hakkınız saklıdır.',
          'Şikayet: KVKK kapsamında Kişisel Verileri Koruma Kurumu\'na başvurabilirsiniz.',
        ],
      ),
      _LegalSection(
        title: 'Veri Saklama ve Silme',
        items: [
          'Hesabınızı sildiğinizde profil, yorumlar, favoriler ve planlar kalıcı olarak silinir.',
          'Anonim analitik veriler en fazla 24 ay saklanır.',
          'Yüklenen fotoğraflar moderasyon sonrası en geç 30 gün içinde depodan temizlenir (reddedilmişse).',
        ],
      ),
    ],
  ),
  'terms': _LegalDoc(
    title: 'Kullanım Şartları',
    updatedAt: 'Mart 2026',
    webUrl: AppConstants.termsUrl,
    summary:
        'Routevia bir seyahat keşif ve planlama uygulamasıdır. Uygulamayı kullanarak aşağıdaki şartları kabul etmiş sayılırsınız.',
    sections: [
      _LegalSection(
        title: 'Kullanıcı Yükümlülükleri',
        items: [
          'Yanıltıcı, telif hakkı ihlali içeren veya zarar verici içerik gönderilemez.',
          'Sahte yorum, spam puanlama ve manipülatif öneri girişleri yasaktır.',
          'Kullanıcı önerileri ve fotoğraflar moderasyondan geçmeden yayınlanmaz.',
          'Başka kullanıcıları taciz etmek veya platformu kötüye kullanmak hesap askıya alınmasına yol açar.',
        ],
      ),
      _LegalSection(
        title: 'Premium ve Ödeme Koşulları',
        items: [
          'Abonelikler App Store veya Google Play üzerinden yönetilir; fiyatlandırma satın alma ekranında gösterilir.',
          'Abonelik, iptal edilmedikçe dönem sonunda otomatik olarak yenilenir.',
          'İptaller, App Store (iOS) veya Google Play hesap ayarlarından en geç bir gün önce yapılmalıdır.',
          'Deneme ve preview süreleri (örn. 7 günlük Pro önizleme) yalnızca bir kez geçerlidir.',
          'Referral kodundan kazanılan haklarda iade yapılmaz; satın alınan abonelikler platform iade politikasına tabidir.',
        ],
      ),
      _LegalSection(
        title: 'İçerik ve Lisans',
        items: [
          'Açıkça lisanslanmamış görseller ve yetkisiz kaynaklardan içerik yayınlanmaz.',
          'Kullanıcının yüklediği içerikler Routevia\'ya hizmet sunumu amacıyla sınırlı lisans verir.',
          'Sponsorlu içerikler organik sıralamadan ayrılır ve "Reklam" / "Sponsorlu" etiketiyle gösterilir.',
        ],
      ),
      _LegalSection(
        title: 'Sorumluluk Sınırı',
        items: [
          'Routevia, üçüncü taraf harita ve yol tarifi hizmetlerindeki hatalardan sorumlu tutulamaz.',
          'Kullanıcı tarafından oluşturulan içeriklerin doğruluğu garanti edilmez.',
          'Uygulama, mücbir sebep veya bakım kesintileri dışında %99 erişilebilirlik hedefler.',
        ],
      ),
      _LegalSection(
        title: 'Hesap Silme',
        items: [
          'Profil > Hesabımı Sil seçeneği ile hesabınızı kalıcı olarak silebilirsiniz.',
          'Silme işlemi geri alınamaz; tüm veriler 30 gün içinde sistemden kaldırılır.',
          'Aktif aboneliğiniz varsa önce store üzerinden iptal etmeniz önerilir.',
        ],
      ),
    ],
  ),
  'ads': _LegalDoc(
    title: 'Reklam ve Sponsorlu İçerik',
    updatedAt: 'Mart 2026',
    webUrl: AppConstants.businessApplyUrl,
    summary:
        'Routevia sponsorlu içerikleri organik önerilerden net biçimde ayırır. Her sponsorlu alan açıkça etiketlenir ve kullanıcı güveni korunur.',
    sections: [
      _LegalSection(
        title: 'Sponsorlu İçerik Kuralları',
        items: [
          'Tüm sponsorlu kartlar "Reklam" veya "Sponsorlu" rozeti ile gösterilir.',
          'Sponsorlu içerik ana keşif sıralamasına gizli şekilde karıştırılmaz.',
          'Yaş kısıtlı veya hassas kategoriler platforma kabul edilmez.',
          'Haftanın keşif rotasında organik ve sponsorlu öneriler birbirinden ayrı bölümlerde yer alır.',
        ],
      ),
      _LegalSection(
        title: 'Kişiselleştirme ve Onay',
        items: [
          'Kişiselleştirilmiş reklam yalnızca açık kullanıcı izni ile etkinleştirilir.',
          'İzin verilmemişse yalnızca bağlamsal (konum/kategori bazlı) sponsorlu içerik kullanılır.',
          'Consent ayarlarınızı Profil > Consent ve Gizlilik Ayarları bölümünden istediğiniz zaman değiştirebilirsiniz.',
        ],
      ),
      _LegalSection(
        title: 'İşletme Başvurusu',
        items: [
          'Routevia\'da yer almak isteyen işletmeler ${AppConstants.supportEmail} adresine başvurabilir.',
          'Başvurular editoryal incelemeden geçer; kalite ve doğruluk standartlarını karşılamayan içerikler reddedilir.',
          'Ücretlendirme ve paketler doğrudan iletişim yoluyla belirlenir.',
        ],
      ),
    ],
  ),
};
