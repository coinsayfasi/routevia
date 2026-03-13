import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants.dart';
import '../../core/error_utils.dart';
import '../../core/i18n.dart';
import '../../core/legal_url_launcher.dart';
import '../../core/widgets/safe_network_image.dart';
import '../../data/providers.dart';
import '../../models/community_post_models.dart';

class CommunityPostEditorScreen extends ConsumerStatefulWidget {
  const CommunityPostEditorScreen({super.key, this.initialPost});

  final CommunityPostModel? initialPost;

  @override
  ConsumerState<CommunityPostEditorScreen> createState() =>
      _CommunityPostEditorScreenState();
}

class _CommunityPostEditorScreenState
    extends ConsumerState<CommunityPostEditorScreen> {
  final _titleCtrl = TextEditingController();
  final _summaryCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'Türkiye');
  final _tagsCtrl = TextEditingController();
  final _bodyCtrl = TextEditingController();
  final _picker = ImagePicker();

  String _postType = 'story';
  String? _relatedRouteId;
  bool _saving = false;
  bool _submitting = false;
  File? _pickedCover;
  final List<File> _pickedGallery = <File>[];
  CommunityPostModel? _post;
  List<Map<String, dynamic>> _routeOptions = const [];

  @override
  void initState() {
    super.initState();
    _post = widget.initialPost;
    _hydrateFromPost();
    _loadRoutes();
  }

  void _hydrateFromPost() {
    final post = _post;
    if (post == null) return;
    _titleCtrl.text = post.title;
    _summaryCtrl.text = post.summary;
    _cityCtrl.text = post.city;
    _countryCtrl.text = post.country;
    _tagsCtrl.text = post.tags.join(', ');
    _bodyCtrl.text = post.contentBody;
    _postType = post.postType;
    _relatedRouteId = post.relatedRouteId;
  }

  Future<void> _loadRoutes() async {
    final trips = await ref.read(repositoryProvider).listMyTrips();
    if (!mounted) return;
    setState(() {
      _routeOptions = trips
          .where((trip) => (trip['source'] as String?) == 'remote')
          .toList(growable: false);
    });
  }

  List<String> _parsedTags() {
    return _tagsCtrl.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList(growable: false);
  }

  String? _draftValidationError() {
    if (_titleCtrl.text.trim().length < 8) {
      return context.tr(
        'Baslik en az 8 karakter olmali.',
        'Title must be at least 8 characters.',
      );
    }
    if (_summaryCtrl.text.trim().length < 24) {
      return context.tr(
        'Kisa ozet en az 24 karakter olmali.',
        'Summary must be at least 24 characters.',
      );
    }
    if (_cityCtrl.text.trim().isEmpty || _countryCtrl.text.trim().isEmpty) {
      return context.tr(
        'Sehir ve ulke alanlari zorunlu.',
        'City and country are required.',
      );
    }
    if (_bodyCtrl.text.trim().length < 180) {
      return context.tr(
        'Icerik en az 180 karakter olmali.',
        'Content must be at least 180 characters.',
      );
    }
    return null;
  }

  String? _submitValidationError() {
    final base = _draftValidationError();
    if (base != null) return base;
    final hasCover =
        _pickedCover != null || ((_post?.coverImageUrl ?? '').trim().isNotEmpty);
    if (!hasCover) {
      return context.tr(
        'Kapak gorseli olmadan incelemeye gonderemezsin.',
        'A cover image is required before submission.',
      );
    }
    return null;
  }

  Future<void> _pickCover() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2400,
        maxHeight: 2400,
        imageQuality: 88,
      );
      if (picked == null || !mounted) return;
      setState(() => _pickedCover = File(picked.path));
    } catch (e) {
      _toast(friendlyError(e));
    }
  }

  Future<void> _pickGallery() async {
    try {
      final picked = await _picker.pickMultiImage(
        maxWidth: 2400,
        maxHeight: 2400,
        imageQuality: 88,
      );
      if (picked.isEmpty || !mounted) return;
      setState(() {
        _pickedGallery.addAll(picked.map((item) => File(item.path)));
      });
    } catch (e) {
      _toast(friendlyError(e));
    }
  }

  Future<CommunityPostModel?> _saveDraftInternal() async {
    final repo = ref.read(repositoryProvider);
    final saved = await repo.saveCommunityPostDraft(
      postId: _post?.id,
      title: _titleCtrl.text,
      summary: _summaryCtrl.text,
      city: _cityCtrl.text,
      country: _countryCtrl.text,
      postType: _postType,
      contentBody: _bodyCtrl.text,
      tags: _parsedTags(),
      relatedRouteId: _relatedRouteId,
    );
    if (_pickedCover != null) {
      await repo.uploadCommunityPostCover(
        postId: saved.id,
        file: _pickedCover!,
      );
    }
    if (_pickedGallery.isNotEmpty) {
      await repo.uploadCommunityPostGallery(
        postId: saved.id,
        files: List<File>.from(_pickedGallery),
      );
    }
    final refreshed = await repo.getCommunityPostById(saved.id);
    if (!mounted) return refreshed;
    setState(() {
      _post = refreshed ?? saved;
      _pickedCover = null;
      _pickedGallery.clear();
    });
    return refreshed ?? saved;
  }

  Future<bool> _ensureUgcAcceptance() async {
    final repo = ref.read(repositoryProvider);
    if (await repo.hasAcceptedUgcPolicy()) return true;
    if (!mounted) return false;
    var accepted = false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setLocalState) => AlertDialog(
          title: Text(
            context.tr(
              'Topluluk kurallarını kabul et',
              'Accept community rules',
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr(
                  'Topluluk yazısı paylaşmadan önce Topluluk Kuralları, Gizlilik Politikası ve Kullanım Şartları kabul edilmelidir.',
                  'Before posting, you must accept Community Rules, Privacy Policy, and Terms of Use.',
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton(
                    onPressed: () =>
                        launchLegalUrl(AppConstants.communityGuidelinesUrl),
                    child: Text(context.tr('Kuralları Aç', 'Open rules')),
                  ),
                  OutlinedButton(
                    onPressed: () =>
                        launchLegalUrl(AppConstants.privacyPolicyUrl),
                    child: Text(context.tr('Gizlilik', 'Privacy')),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: accepted,
                onChanged: (value) =>
                    setLocalState(() => accepted = value == true),
                title: Text(
                  context.tr(
                    'Kuralları okudum ve kabul ediyorum',
                    'I have read and accept the rules',
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(context.tr('Vazgeç', 'Cancel')),
            ),
            FilledButton(
              onPressed: accepted ? () => Navigator.of(ctx).pop(true) : null,
              child: Text(context.tr('Kabul Et', 'Accept')),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return false;
    await repo.acceptUgcPolicy();
    return true;
  }

  Future<void> _saveDraft() async {
    final validationError = _draftValidationError();
    if (validationError != null) {
      _toast(validationError);
      return;
    }
    final accepted = await _ensureUgcAcceptance();
    if (!accepted) return;
    setState(() => _saving = true);
    try {
      await _saveDraftInternal();
      if (!mounted) return;
      _toast(context.tr('Taslak kaydedildi.', 'Draft saved.'));
    } catch (e) {
      _toast(friendlyError(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _submitForReview() async {
    final validationError = _submitValidationError();
    if (validationError != null) {
      _toast(validationError);
      return;
    }
    final accepted = await _ensureUgcAcceptance();
    if (!accepted) return;
    setState(() => _submitting = true);
    try {
      final saved = await _saveDraftInternal();
      if (saved == null) return;
      await ref.read(repositoryProvider).submitCommunityPostForReview(saved.id);
      final refreshed = await ref
          .read(repositoryProvider)
          .getCommunityPostById(saved.id);
      if (!mounted) return;
      setState(() => _post = refreshed ?? saved.copyWith(status: 'pending'));
      _toast(
        context.tr(
          'İçerik incelemeye gönderildi. Onay sonrası toplulukta görünür.',
          'Submitted for review. It becomes public after approval.',
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      _toast(friendlyError(e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _removeGalleryImage(String imageId) async {
    try {
      await ref.read(repositoryProvider).deleteCommunityPostImage(imageId);
      final postId = _post?.id;
      if (postId == null) return;
      final refreshed = await ref
          .read(repositoryProvider)
          .getCommunityPostById(postId);
      if (!mounted || refreshed == null) return;
      setState(() => _post = refreshed);
    } catch (e) {
      _toast(friendlyError(e));
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _summaryCtrl.dispose();
    _cityCtrl.dispose();
    _countryCtrl.dispose();
    _tagsCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = _post;
    final canEdit = post == null || post.isDraft || post.isRejected;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          post == null
              ? context.tr('Yeni Topluluk Yazısı', 'New Community Post')
              : context.tr('Yazıyı Düzenle', 'Edit Post'),
        ),
        actions: [
          TextButton(
            onPressed: _saving || _submitting || !canEdit ? null : _saveDraft,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(context.tr('Taslak', 'Draft')),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 140),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr(
                    'Routevia Topluluk Yazısı',
                    'Routevia Community Post',
                  ),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr(
                    'Kısa ama güçlü bir gezi hikayesi ya da mini rehber yaz. Önce moderasyona düşer, onaylanınca Topluluk akışında görünür.',
                    'Write a concise travel story or mini guide. It goes through moderation before appearing in the community feed.',
                  ),
                  style: const TextStyle(color: Color(0xFF475569), height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleCtrl,
            enabled: canEdit,
            decoration: InputDecoration(
              labelText: context.tr('Başlık', 'Title'),
              hintText: context.tr(
                'Örnek: Kapadokya’da 2 Günde En Sevdiğim Duraklar',
                'Example: My favorite Cappadocia stops in 2 days',
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _summaryCtrl,
            enabled: canEdit,
            minLines: 2,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: context.tr('Kısa Özet', 'Summary'),
              hintText: context.tr(
                'Topluluk akışında görünecek kısa özet.',
                'Short summary shown in the community feed.',
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _cityCtrl,
                  enabled: canEdit,
                  decoration: InputDecoration(
                    labelText: context.tr('Şehir', 'City'),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _countryCtrl,
                  enabled: canEdit,
                  decoration: InputDecoration(
                    labelText: context.tr('Ülke', 'Country'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _postType,
            decoration: InputDecoration(
              labelText: context.tr('İçerik Türü', 'Post Type'),
            ),
            items: [
              DropdownMenuItem(
                value: 'story',
                child: Text(context.tr('Hikâye', 'Story')),
              ),
              DropdownMenuItem(
                value: 'guide',
                child: Text(context.tr('Rehber', 'Guide')),
              ),
            ],
            onChanged: canEdit
                ? (value) => setState(() => _postType = value ?? 'story')
                : null,
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String?>(
            initialValue: _relatedRouteId,
            decoration: InputDecoration(
              labelText: context.tr('Bağlı Rota', 'Related Route'),
            ),
            items: [
              DropdownMenuItem<String?>(
                value: null,
                child: Text(context.tr('Rota bağlama', 'No route')),
              ),
              ..._routeOptions.map(
                (trip) => DropdownMenuItem<String?>(
                  value: trip['id']?.toString(),
                  child: Text(
                    trip['title']?.toString().isNotEmpty == true
                        ? trip['title'].toString()
                        : '${(trip['province'] as Map?)?['name'] ?? 'Rota'} • ${trip['days']} gün',
                  ),
                ),
              ),
            ],
            onChanged: canEdit
                ? (value) => setState(() => _relatedRouteId = value)
                : null,
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _tagsCtrl,
            enabled: canEdit,
            decoration: InputDecoration(
              labelText: context.tr('Etiketler', 'Tags'),
              hintText: context.tr(
                'Örnek: gün doğumu, fotoğraf, 3 gün',
                'Example: sunrise, photo, 3 days',
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _bodyCtrl,
            enabled: canEdit,
            minLines: 10,
            maxLines: 16,
            decoration: InputDecoration(
              labelText: context.tr('İçerik', 'Content'),
              alignLabelWithHint: true,
              hintText: context.tr(
                'Deneyimini, rota önerilerini ve mini notlarını burada anlat.',
                'Tell your experience, route suggestions, and mini notes here.',
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            context.tr('Kapak Görseli', 'Cover Image'),
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          if (_pickedCover != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.file(_pickedCover!, height: 180, fit: BoxFit.cover),
            )
          else if ((post?.coverImageUrl ?? '').isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SafeNetworkImage(
                url: post!.coverImageUrl,
                height: 180,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: canEdit ? _pickCover : null,
            icon: const Icon(Icons.photo_outlined),
            label: Text(context.tr('Kapak görseli seç', 'Choose cover image')),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: Text(
                  context.tr('Galeri', 'Gallery'),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              TextButton.icon(
                onPressed: canEdit ? _pickGallery : null,
                icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                label: Text(context.tr('Galeri ekle', 'Add gallery')),
              ),
            ],
          ),
          if (_pickedGallery.isNotEmpty)
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _pickedGallery.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final file = _pickedGallery[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(file, width: 120, fit: BoxFit.cover),
                  );
                },
              ),
            ),
          if (post != null && post.gallery.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: post.gallery.length,
                separatorBuilder: (context, index) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final image = post.gallery[index];
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: SafeNetworkImage(
                          url: image.imageUrl,
                          width: 120,
                          height: 110,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (canEdit)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: InkWell(
                            onTap: () => _removeGalleryImage(image.id),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _saving || _submitting || !canEdit
                    ? null
                    : _saveDraft,
                child: Text(context.tr('Taslak Kaydet', 'Save Draft')),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: _saving || _submitting || !canEdit
                    ? null
                    : _submitForReview,
                icon: _submitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.publish_outlined, size: 18),
                label: Text(context.tr('İncelemeye Gönder', 'Submit')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
