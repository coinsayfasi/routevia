import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants.dart';
import '../../core/i18n.dart';
import '../../core/legal_url_launcher.dart';

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.documentId});

  final String documentId;

  @override
  Widget build(BuildContext context) {
    final docs = context.isEnglish ? _docsEn : _docs;
    final doc = docs[documentId] ?? docs['privacy']!;
    return Scaffold(
      appBar: AppBar(title: Text(doc.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 48),
        children: [
          // Version / date badge
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: Color(0xFF64748B),
              ),
              const SizedBox(width: 6),
              Text(
                context.tr(
                  'Son güncelleme: ${doc.updatedAt}',
                  'Last updated: ${doc.updatedAt}',
                ),
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
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
                            const Text(
                              '• ',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
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
          const SizedBox(height: 8),
          if (doc.webUrl.isNotEmpty) ...[
            OutlinedButton.icon(
              onPressed: () => launchLegalUrl(doc.webUrl),
              icon: const Icon(Icons.open_in_new, size: 18),
              label: Text(context.tr('Web sürümünü aç', 'Open web version')),
            ),
            const SizedBox(height: 8),
          ],
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 18,
                  color: Color(0xFF475569),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    context.tr(
                      'Guncel hukuki metin uygulama icinde gosterilir ve resmi web yasal sayfasi ile eslesir.',
                      'The current legal text is shown in-app and matches the official web legal page.',
                    ),
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      height: 1.45,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Contact
          TextButton.icon(
            onPressed: () => launchUrl(
              Uri.parse(
                'mailto:${AppConstants.supportEmail}'
                '?subject=${context.isEnglish ? 'Routevia%20Legal%20Question' : 'Routevia%20Hukuki%20Soru'}',
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
              label: Text(
                context.tr(
                  'Gizlilik ve Consent Ayarlarım',
                  'My Privacy and Consent Settings',
                ),
              ),
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
          'İçerik verisi: favoriler, yorumlar, puanlar, gezi planları, kullanıcı önerileri ve kullanıcı tarafından yüklenen fotoğraflar.',
          'Konum verisi: yalnızca uygulama açıkken, yakın yer önerileri için anlık olarak kullanılır; cihazda saklanmaz.',
          'Kullanım verisi: uygulama içi etkinlikler (sayfa görüntüleme, plan oluşturma) — yalnızca analitik onayı verilmişse.',
        ],
      ),
      _LegalSection(
        title: 'Kullanım Amacı',
        items: [
          'Kişiselleştirilmiş gezi önerileri ve plan oluşturma.',
          'Topluluk değerlendirme ve yorum sisteminin işletilmesi.',
          'Trend Harita ve benzeri topluluk trend skorlarının; check-in, yorum, fotoğraf ve uygulama içi kullanıcı sinyallerinden türetilmesi.',
          'Kullanıcı tarafından yüklenen fotoğrafların moderasyonu, topluluk galerisine alınması ve uygun bulunursa ilgili yerin ana görseli olarak seçilmesi.',
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
          'Rexxel — operasyon, destek ve iş ortaklığı süreçlerinde kullanılan hizmet altyapısı.',
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
          'Reddedilen yüklenmiş fotoğraflar moderasyon sonrası en geç 30 gün içinde depodan temizlenir.',
          'Yayına alınan topluluk fotoğrafları, kullanıcı silme talebi veya içerik kaldırma kararı gelene kadar ürün içinde tutulabilir.',
        ],
      ),
      _LegalSection(
        title: 'Trend ve Yoğunluk Açıklaması',
        items: [
          'Trend Harita, topluluk trendi, hareketlilik veya kalabalık benzeri etiketler; Routevia kullanıcı etkileşimlerinden türetilen tahmini sinyallerdir.',
          'Bu skorlar resmi kurum verisi, sensör verisi veya birebir gerçek zamanlı fiziksel insan yoğunluğu ölçümü değildir.',
          'Uygulamayı kullanmayan kişilerin bulunduğu fiziksel yoğunluk bu skorlara doğrudan yansımayabilir.',
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
          'Yüklediğiniz görselin size ait olduğunu veya gerekli kullanım iznine sahip olduğunuzu beyan etmiş olursunuz.',
          'Başka kullanıcıları taciz etmek veya platformu kötüye kullanmak hesap askıya alınmasına yol açar.',
        ],
      ),
      _LegalSection(
        title: 'Premium ve Ödeme Koşulları',
        items: [
          'Abonelikler App Store veya Google Play üzerinden yönetilir; fiyatlandırma satın alma ekranında gösterilir.',
          'Abonelik, iptal edilmedikçe dönem sonunda otomatik olarak yenilenir.',
          'İptaller, App Store (iOS) veya Google Play hesap ayarlarından en geç bir gün önce yapılmalıdır.',
          'Tanıtım teklifleri (varsa) yalnızca bir kez geçerlidir; uygunluk App Store veya Google Play tarafından belirlenir.',
          'Referral kodundan kazanılan haklarda iade yapılmaz; satın alınan abonelikler platform iade politikasına tabidir.',
        ],
      ),
      _LegalSection(
        title: 'İçerik ve Lisans',
        items: [
          'Açıkça lisanslanmamış görseller ve yetkisiz kaynaklardan içerik yayınlanmaz.',
          'Kullanıcının yüklediği içerikler, içerik kaldırılana kadar Routevia\'ya barındırma, moderasyon ve uygulama içinde gösterim için sınırlı lisans verir.',
          'Kullanıcının yüklediği ve moderasyondan geçen fotoğraflar, seçilmesi halinde ilgili yerin topluluk galerisi ve ana kart görseli olarak kullanılabilir.',
          'Telif bildirimi veya hak ihlali şüphesinde içerik ön inceleme beklenmeden yayından kaldırılabilir.',
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
    webUrl: AppConstants.adsPolicyUrl,
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
          'İş ortaklığı ve reklam operasyonlarında Rexxel destek süreçleri kullanılabilir; kullanıcı verisi bu amaçla satılmaz.',
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
          'Sponsorlu iş birlikleri kullanıcı güveni, editoryal denge ve yasal uygunluk kontrolünden geçmeden yayına alınmaz.',
        ],
      ),
    ],
  ),
  'community': _LegalDoc(
    title: 'Topluluk Kuralları',
    updatedAt: 'Mart 2026',
    webUrl: AppConstants.communityGuidelinesUrl,
    summary:
        'Routevia içindeki gezi hikâyeleri, mini rehberler, yorumlar, fotoğraflar ve yer hikâyeleri güvenli, telifsiz ve moderasyonlu bir topluluk alanı olarak yönetilir.',
    sections: [
      _LegalSection(
        title: 'İzinli İçerik',
        items: [
          'Gezi hikâyeleri, mini rehberler, kişisel deneyimler ve yerle ilgili özgün notlar paylaşılabilir.',
          'Yüklenen içerik kullanıcıya ait olmalı veya kullanıcı paylaşım hakkına sahip olmalıdır.',
          'Kopya metin, otomatik spam, telif ihlali içeren görsel veya metin yayınlanmaz.',
        ],
      ),
      _LegalSection(
        title: 'Güvenlik ve Moderasyon',
        items: [
          'Topluluk yazıları ve yer hikâyeleri önce moderasyon kuyruğuna düşer, onay sonrası görünür.',
          'Kullanıcılar yayınlanmış topluluk içeriğini uygulama içinden bildirebilir.',
          'Kullanıcılar istemedikleri yazarları engelleyebilir; engellenen yazarın içerikleri akışta gizlenir.',
          'Hak ihlali, nefret söylemi, spam veya aldatıcı içerik tespit edilirse içerik kaldırılır.',
        ],
      ),
    ],
  ),
  'account-deletion': _LegalDoc(
    title: 'Hesap Silme',
    updatedAt: 'Mart 2026',
    webUrl: AppConstants.accountDeletionUrl,
    summary:
        'Routevia hesabınızı uygulama içinden silebilirsiniz. Bu sayfa aynı zamanda mağaza gereksinimleri için public bilgilendirme adresidir.',
    sections: [
      _LegalSection(
        title: 'Uygulama İçinden Silme',
        items: [
          'Profil > Hesabımı Sil adımıyla hesabınızı kalıcı olarak silebilirsiniz.',
          'Silme sonrası profil, favoriler, check-in\'ler, yorumlar ve ilişkili hesap verileri kaldırılır.',
          'Aktif aboneliğiniz varsa yenileme öncesi mağaza ayarlarından iptal etmeniz önerilir.',
        ],
      ),
      _LegalSection(
        title: 'Manuel Talep',
        items: [
          'Uygulamaya erişemiyorsanız ${AppConstants.supportEmail} adresine hesap silme talebi gönderebilirsiniz.',
          'Gerekirse doğrulama amacıyla kayıtlı e-posta adresiniz istenir.',
        ],
      ),
    ],
  ),
};

const _docsEn = <String, _LegalDoc>{
  'privacy': _LegalDoc(
    title: 'Privacy Policy',
    updatedAt: 'March 2026',
    webUrl: AppConstants.privacyPolicyUrl,
    summary:
        'Routevia uses your personal data only to provide and improve the travel experience. Your data is not sold to third parties.',
    sections: [
      _LegalSection(
        title: 'Collected Data',
        items: [
          'Account data: email address and user identity through Supabase Auth.',
          'Content data: favorites, reviews, ratings, trip plans, user suggestions, and user-uploaded photos.',
          'Location data: used only while the app is open for nearby suggestions and is not stored on the device.',
          'Usage data: in-app events such as screen views and plan generation, only if analytics consent is given.',
        ],
      ),
      _LegalSection(
        title: 'Purpose of Use',
        items: [
          'Personalized travel suggestions and plan generation.',
          'Operating community review and comment systems.',
          'Generating Trend Map and similar community trend scores from check-ins, reviews, photos, and in-app user signals.',
          'Moderating user-uploaded photos and, when appropriate, using them in the community gallery or as the place cover image.',
          'Account security and abuse detection.',
          'Anonymous usage analytics to improve service quality, if permitted.',
        ],
      ),
      _LegalSection(
        title: 'Legal Basis',
        items: [
          'Account and content data: performance of a contract.',
          'Analytics data: explicit consent.',
          'Location data: legitimate interest, only during active use and for service functionality.',
          'For EU/EEA users, the same legal basis applies under GDPR Article 6.',
        ],
      ),
      _LegalSection(
        title: 'Third Parties',
        items: [
          'Supabase for database and authentication.',
          'OpenStreetMap for open-license map data.',
          'OSRM for self-hosted route computation without sending user location.',
          'App Store / Google Play for subscription and purchase verification.',
          'Rexxel for operational, support, and business-partnership workflows.',
          'Open-license and editorial data sources for permitted in-product content.',
        ],
      ),
      _LegalSection(
        title: 'Your Rights',
        items: [
          'Access: you may request your stored data.',
          'Deletion: you can delete your account and all data from Profile > Delete Account.',
          'Portability: you can send data requests to ${AppConstants.supportEmail}.',
          'Objection: you may object to processing for marketing and profiling.',
          'Complaint: you may apply to the relevant data protection authority.',
        ],
      ),
      _LegalSection(
        title: 'Retention and Deletion',
        items: [
          'When you delete your account, your profile, reviews, favorites, and plans are permanently removed.',
          'Anonymous analytics data is stored for up to 24 months.',
          'Rejected uploaded photos are removed from storage within 30 days after moderation.',
          'Approved community photos may remain in product surfaces until deleted by the user or removed due to moderation or legal review.',
        ],
      ),
      _LegalSection(
        title: 'Trend and Density Disclaimer',
        items: [
          'Trend Map, movement, and crowd-like labels in Routevia are estimated community signals derived from Routevia user interactions.',
          'They are not official occupancy data and do not represent exact real-time physical foot traffic measurements.',
          'Physical density created by people who do not use the app may not be reflected in these scores.',
        ],
      ),
    ],
  ),
  'terms': _LegalDoc(
    title: 'Terms of Use',
    updatedAt: 'March 2026',
    webUrl: AppConstants.termsUrl,
    summary:
        'Routevia is a travel discovery and planning application. By using the app, you agree to the following terms.',
    sections: [
      _LegalSection(
        title: 'User Responsibilities',
        items: [
          'Misleading, copyright-infringing, or harmful content may not be submitted.',
          'Fake reviews, spam ratings, and manipulative suggestions are prohibited.',
          'User suggestions and photos are not published before moderation.',
          'By uploading an image, you confirm that you own it or have the right to share it.',
          'Harassing other users or abusing the platform may lead to suspension.',
        ],
      ),
      _LegalSection(
        title: 'Premium and Payments',
        items: [
          'Subscriptions are managed through the App Store or Google Play, and pricing is shown on the purchase screen.',
          'Subscriptions renew automatically unless canceled.',
          'Cancellations must be completed through App Store or Google Play settings before renewal.',
          'Trial and preview periods such as 7-day Pro access are valid only once.',
          'Benefits gained through referral codes are non-refundable; paid subscriptions follow platform refund rules.',
        ],
      ),
      _LegalSection(
        title: 'Content and License',
        items: [
          'Images without clear licensing and content from unauthorized sources are not published.',
          'Content uploaded by the user grants Routevia a limited license to host, moderate, and display that content inside the service until it is removed.',
          'User-uploaded photos that pass moderation may be used in the place community gallery and as the main card image if selected.',
          'Content may be removed immediately in response to a copyright notice or suspected rights violation.',
          'Sponsored content is separated from organic ranking and labeled as Ads / Sponsored.',
        ],
      ),
      _LegalSection(
        title: 'Limitation of Liability',
        items: [
          'Routevia is not responsible for errors in third-party map or navigation services.',
          'Accuracy of user-generated content is not guaranteed.',
          'The app targets 99% availability except force majeure and maintenance windows.',
        ],
      ),
      _LegalSection(
        title: 'Account Deletion',
        items: [
          'You can permanently delete your account from Profile > Delete Account.',
          'Deletion cannot be reversed; data is removed from systems within 30 days.',
          'If you have an active subscription, cancel it through the store first.',
        ],
      ),
    ],
  ),
  'ads': _LegalDoc(
    title: 'Ads and Sponsored Content',
    updatedAt: 'March 2026',
    webUrl: AppConstants.adsPolicyUrl,
    summary:
        'Routevia clearly separates sponsored content from organic recommendations. Every sponsored surface is labeled to protect user trust.',
    sections: [
      _LegalSection(
        title: 'Sponsored Content Rules',
        items: [
          'All sponsored cards are shown with an Ad or Sponsored badge.',
          'Sponsored content is not secretly mixed into the main discovery ranking.',
          'Age-restricted or sensitive categories are not accepted.',
          'In the weekly discovery route, organic and sponsored suggestions are shown in separate sections.',
          'Rexxel-supported partnership operations may be used for campaign workflow, but user data is not sold for advertising.',
        ],
      ),
      _LegalSection(
        title: 'Personalization and Consent',
        items: [
          'Personalized advertising is enabled only with explicit user consent.',
          'Without consent, only contextual sponsor content based on location or category is used.',
          'You can change consent settings any time from Profile > Consent and Privacy Settings.',
        ],
      ),
      _LegalSection(
        title: 'Business Applications',
        items: [
          'Businesses that want to appear on Routevia can apply via ${AppConstants.supportEmail}.',
          'Applications go through editorial review; content that does not meet quality and accuracy standards is rejected.',
          'Pricing and packages are determined through direct contact.',
          'No sponsored collaboration is published before legal, editorial, and trust review.',
        ],
      ),
    ],
  ),
  'community': _LegalDoc(
    title: 'Community Rules',
    updatedAt: 'March 2026',
    webUrl: AppConstants.communityGuidelinesUrl,
    summary:
        'Travel stories, mini guides, photos, and place notes inside Routevia are managed as a moderated, copyright-safe community layer.',
    sections: [
      _LegalSection(
        title: 'Allowed Content',
        items: [
          'Travel stories, mini guides, personal experiences, and original place notes are allowed.',
          'Uploaded content must belong to the user or be shared with permission.',
          'Copied text, automated spam, and copyright-infringing content are rejected.',
        ],
      ),
      _LegalSection(
        title: 'Safety and Moderation',
        items: [
          'Community posts and place stories go through moderation before publication.',
          'Users can report published community content in-app.',
          'Users can block authors; blocked authors are hidden from their feed.',
          'Content may be removed for abuse, hate, spam, deception, or rights violations.',
        ],
      ),
    ],
  ),
  'account-deletion': _LegalDoc(
    title: 'Account Deletion',
    updatedAt: 'March 2026',
    webUrl: AppConstants.accountDeletionUrl,
    summary:
        'You can delete your Routevia account inside the app. This page also serves as the public deletion information URL for store compliance.',
    sections: [
      _LegalSection(
        title: 'Delete in App',
        items: [
          'Use Profile > Delete Account to permanently remove your account.',
          'After deletion, your profile, favorites, check-ins, reviews, and linked account data are removed.',
          'If you have an active subscription, cancel it in the store settings before renewal.',
        ],
      ),
      _LegalSection(
        title: 'Manual Request',
        items: [
          'If you cannot access the app, send an account deletion request to ${AppConstants.supportEmail}.',
          'We may request your registered email for verification.',
        ],
      ),
    ],
  ),
};
