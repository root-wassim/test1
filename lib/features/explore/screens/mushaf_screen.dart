import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:projet/core/constants/app_colors.dart';
import 'package:projet/core/constants/app_strings.dart';
import 'package:projet/core/constants/app_theme.dart';
import 'package:projet/core/services/firestore_user_service.dart';
import 'package:projet/features/explore/providers/explore_providers.dart';
import 'package:projet/shared/widgets/loading_indicator.dart';

/// Surah names + the page they start on in the Mushaf (standard Madani print).
const _surahStartPages = <(String nameAr, String nameEn, int page)>[
  ('الفاتحة', 'Al-Faatiha', 1),
  ('البقرة', 'Al-Baqara', 2),
  ('آل عمران', 'Aal-i-Imraan', 50),
  ('النساء', 'An-Nisaa', 77),
  ('المائدة', 'Al-Maaida', 106),
  ('الأنعام', 'Al-An\'aam', 128),
  ('الأعراف', 'Al-A\'raaf', 151),
  ('الأنفال', 'Al-Anfaal', 177),
  ('التوبة', 'At-Tawba', 187),
  ('يونس', 'Yunus', 208),
  ('هود', 'Hud', 221),
  ('يوسف', 'Yusuf', 235),
  ('الرعد', 'Ar-Ra\'d', 249),
  ('إبراهيم', 'Ibrahim', 255),
  ('الحجر', 'Al-Hijr', 262),
  ('النحل', 'An-Nahl', 267),
  ('الإسراء', 'Al-Israa', 282),
  ('الكهف', 'Al-Kahf', 293),
  ('مريم', 'Maryam', 305),
  ('طه', 'Taa-Haa', 312),
  ('الأنبياء', 'Al-Anbiyaa', 322),
  ('الحج', 'Al-Hajj', 332),
  ('المؤمنون', 'Al-Muminoon', 342),
  ('النور', 'An-Noor', 350),
  ('الفرقان', 'Al-Furqaan', 359),
  ('الشعراء', 'Ash-Shu\'araa', 367),
  ('النمل', 'An-Naml', 377),
  ('القصص', 'Al-Qasas', 385),
  ('العنكبوت', 'Al-Ankaboot', 396),
  ('الروم', 'Ar-Room', 404),
  ('لقمان', 'Luqman', 411),
  ('السجدة', 'As-Sajda', 415),
  ('الأحزاب', 'Al-Ahzaab', 418),
  ('سبأ', 'Saba', 428),
  ('فاطر', 'Faatir', 434),
  ('يس', 'Yaseen', 440),
  ('الصافات', 'As-Saaffaat', 446),
  ('ص', 'Saad', 453),
  ('الزمر', 'Az-Zumar', 458),
  ('غافر', 'Ghafir', 467),
  ('فصلت', 'Fussilat', 477),
  ('الشورى', 'Ash-Shura', 483),
  ('الزخرف', 'Az-Zukhruf', 489),
  ('الدخان', 'Ad-Dukhaan', 496),
  ('الجاثية', 'Al-Jaathiya', 499),
  ('الأحقاف', 'Al-Ahqaf', 502),
  ('محمد', 'Muhammad', 507),
  ('الفتح', 'Al-Fath', 511),
  ('الحجرات', 'Al-Hujuraat', 515),
  ('ق', 'Qaaf', 518),
  ('الذاريات', 'Adh-Dhaariyat', 520),
  ('الطور', 'At-Tur', 523),
  ('النجم', 'An-Najm', 526),
  ('القمر', 'Al-Qamar', 528),
  ('الرحمن', 'Ar-Rahmaan', 531),
  ('الواقعة', 'Al-Waaqia', 534),
  ('الحديد', 'Al-Hadid', 537),
  ('المجادلة', 'Al-Mujaadila', 542),
  ('الحشر', 'Al-Hashr', 545),
  ('الممتحنة', 'Al-Mumtahana', 549),
  ('الصف', 'As-Saff', 551),
  ('الجمعة', 'Al-Jumu\'a', 553),
  ('المنافقون', 'Al-Munaafiqoon', 554),
  ('التغابن', 'At-Taghaabun', 556),
  ('الطلاق', 'At-Talaaq', 558),
  ('التحريم', 'At-Tahrim', 560),
  ('الملك', 'Al-Mulk', 562),
  ('القلم', 'Al-Qalam', 564),
  ('الحاقة', 'Al-Haaqqa', 566),
  ('المعارج', 'Al-Ma\'aarij', 568),
  ('نوح', 'Nooh', 570),
  ('الجن', 'Al-Jinn', 572),
  ('المزمل', 'Al-Muzzammil', 574),
  ('المدثر', 'Al-Muddaththir', 575),
  ('القيامة', 'Al-Qiyaama', 577),
  ('الإنسان', 'Al-Insaan', 578),
  ('المرسلات', 'Al-Mursalaat', 580),
  ('النبأ', 'An-Naba', 582),
  ('النازعات', 'An-Naazi\'aat', 583),
  ('عبس', 'Abasa', 585),
  ('التكوير', 'At-Takwir', 586),
  ('الانفطار', 'Al-Infitaar', 587),
  ('المطففين', 'Al-Mutaffifin', 587),
  ('الانشقاق', 'Al-Inshiqaaq', 589),
  ('البروج', 'Al-Burooj', 590),
  ('الطارق', 'At-Taariq', 591),
  ('الأعلى', 'Al-A\'laa', 591),
  ('الغاشية', 'Al-Ghaashiya', 592),
  ('الفجر', 'Al-Fajr', 593),
  ('البلد', 'Al-Balad', 594),
  ('الشمس', 'Ash-Shams', 595),
  ('الليل', 'Al-Lail', 595),
  ('الضحى', 'Ad-Dhuhaa', 596),
  ('الشرح', 'Al-Inshiraah', 596),
  ('التين', 'At-Tin', 597),
  ('العلق', 'Al-Alaq', 597),
  ('القدر', 'Al-Qadr', 598),
  ('البينة', 'Al-Bayyina', 598),
  ('الزلزلة', 'Az-Zalzala', 599),
  ('العاديات', 'Al-Aadiyaat', 599),
  ('القارعة', 'Al-Qaari\'a', 600),
  ('التكاثر', 'At-Takaathur', 600),
  ('العصر', 'Al-Asr', 601),
  ('الهمزة', 'Al-Humaza', 601),
  ('الفيل', 'Al-Fil', 601),
  ('قريش', 'Quraish', 602),
  ('الماعون', 'Al-Maa\'oon', 602),
  ('الكوثر', 'Al-Kawthar', 602),
  ('الكافرون', 'Al-Kaafiroon', 603),
  ('النصر', 'An-Nasr', 603),
  ('المسد', 'Al-Masad', 603),
  ('الإخلاص', 'Al-Ikhlaas', 604),
  ('الفلق', 'Al-Falaq', 604),
  ('الناس', 'An-Naas', 604),
];

class MushafScreen extends ConsumerStatefulWidget {
  const MushafScreen({super.key});

  @override
  ConsumerState<MushafScreen> createState() => _MushafScreenState();
}

class _MushafScreenState extends ConsumerState<MushafScreen> {
  int _currentPage = 1;
  int? _bookmarkedPage;
  final _pageController = PageController();
  final _textController = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    _loadBookmark();
  }

  Future<void> _loadBookmark() async {
    // Load from Firestore first (syncs across devices), falls back to local
    final page = await FirestoreUserService().loadBookmark();
    if (mounted) {
      setState(() => _bookmarkedPage = page);
    }
  }

  Future<void> _saveBookmark() async {
    // Save locally + Firestore (with offline queue fallback)
    await FirestoreUserService().saveBookmark(_currentPage);
    setState(() => _bookmarkedPage = _currentPage);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حفظ العلامة — صفحة $_currentPage'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _goToBookmark() {
    if (_bookmarkedPage == null) return;
    _jumpToPage(_bookmarkedPage!);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('الانتقال إلى العلامة — صفحة $_bookmarkedPage'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _jumpToPage(int page) {
    final clamped = page.clamp(1, 604);
    setState(() {
      _currentPage = clamped;
      _textController.text = '$clamped';
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(clamped - 1);
    }
  }

  void _showSurahIndex() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SurahIndexSheet(
        onSurahTap: (page) {
          Navigator.pop(context);
          _jumpToPage(page);
        },
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final imagesData = ref.watch(quranPageImagesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface, size: 20),
                    onPressed: () => context.pop(),
                  ),
                  Text(AppStrings.mushafTitle, style: AppTheme.headlineSm.copyWith(fontSize: 16)),
                  const Spacer(),
                  // Page input
                  SizedBox(
                    width: 52,
                    height: 32,
                    child: TextField(
                      controller: _textController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: AppTheme.bodyMd.copyWith(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 4),
                        filled: true,
                        fillColor: AppColors.primary.withValues(alpha: 0.1),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                      ),
                      onSubmitted: (v) => _jumpToPage(int.tryParse(v) ?? 1),
                    ),
                  ),
                  Text('/604', style: AppTheme.labelSm.copyWith(color: AppColors.onSurfaceVariant, fontSize: 10)),
                ],
              ),
            ),

            // ── Action Buttons Row ──
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Row(
                children: [
                  // Save bookmark
                  _ActionChip(
                    icon: Icons.bookmark_add_rounded,
                    label: 'حفظ علامة',
                    onTap: _saveBookmark,
                  ),
                  const SizedBox(width: 8),
                  // Go to bookmark
                  _ActionChip(
                    icon: Icons.bookmark_rounded,
                    label: 'الانتقال للعلامة',
                    onTap: _bookmarkedPage != null ? _goToBookmark : null,
                    badge: _bookmarkedPage != null ? '$_bookmarkedPage' : null,
                  ),
                  const SizedBox(width: 8),
                  // Surah index
                  _ActionChip(
                    icon: Icons.list_alt_rounded,
                    label: 'فهرس السور',
                    onTap: _showSurahIndex,
                  ),
                ],
              ),
            ),

            // ── Page View with Zoom ──
            Expanded(
              child: imagesData.when(
                data: (images) {
                  if (images.isEmpty) {
                    return Center(
                      child: Text(AppStrings.mushafUnavailable, style: AppTheme.bodyMd.copyWith(color: AppColors.onSurfaceVariant)),
                    );
                  }
                  return PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    onPageChanged: (i) {
                      setState(() {
                        _currentPage = i + 1;
                        _textController.text = '${i + 1}';
                      });
                    },
                    itemBuilder: (_, i) {
                      final isBookmarked = _bookmarkedPage == (i + 1);
                      return Stack(
                        children: [
                          // Zoomable page image
                          SizedBox.expand(
                            child: InteractiveViewer(
                              minScale: 1.0,
                              maxScale: 4.0,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      images[i],
                                      fit: BoxFit.contain,
                                      width: double.infinity,
                                      alignment: Alignment.center,
                                      loadingBuilder: (_, child, progress) {
                                        if (progress == null) return child;
                                        return const Center(child: LoadingIndicator());
                                      },
                                      errorBuilder: (_, e2, s2) => Center(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.broken_image, color: AppColors.onSurfaceVariant.withValues(alpha: 0.3), size: 60),
                                            const SizedBox(height: 8),
                                            Text(AppStrings.imageLoadError, style: AppTheme.bodySm.copyWith(color: AppColors.onSurfaceVariant)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Bookmark ribbon overlay
                          if (isBookmarked)
                            Positioned(
                              top: 0,
                              left: 12,
                              child: Container(
                                width: 32,
                                height: 52,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Color(0xFF0D7C66), Color(0xFF17B169)],
                                  ),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(4),
                                    bottomRight: Radius.circular(4),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x400D7C66),
                                      blurRadius: 8,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.bookmark_rounded, color: Colors.white, size: 16),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${i + 1}',
                                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  );
                },
                loading: () => const LoadingIndicator(),
                error: (e, s) => Center(child: Text(AppStrings.apiError, style: AppTheme.bodyMd.copyWith(color: AppColors.error))),
              ),
            ),

            // ── Navigation Controls ──
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                border: Border(top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.1))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _currentPage > 1
                        ? () => _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)
                        : null,
                    icon: Icon(Icons.chevron_left_rounded, color: _currentPage > 1 ? AppColors.primary : AppColors.onSurfaceVariant.withValues(alpha: 0.3), size: 32),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${AppStrings.pageLabel} $_currentPage',
                        style: AppTheme.bodyMd.copyWith(color: AppColors.onSurface, fontWeight: FontWeight.w600),
                      ),
                      if (_bookmarkedPage != null)
                        Text(
                          '🔖 علامة: $_bookmarkedPage',
                          style: AppTheme.labelSm.copyWith(color: AppColors.primary, fontSize: 9),
                        ),
                    ],
                  ),
                  IconButton(
                    onPressed: _currentPage < 604
                        ? () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)
                        : null,
                    icon: Icon(Icons.chevron_right_rounded, color: _currentPage < 604 ? AppColors.primary : AppColors.onSurfaceVariant.withValues(alpha: 0.3), size: 32),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Action Chip Widget ──
class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.icon, required this.label, required this.onTap, this.badge});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedOpacity(
          opacity: enabled ? 1.0 : 0.4,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(icon, color: AppColors.primary, size: 18),
                    if (badge != null)
                      Positioned(
                        top: -6,
                        right: -12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(badge!, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: AppTheme.labelSm.copyWith(color: AppColors.primary, fontSize: 9, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Surah Index Bottom Sheet ──
class _SurahIndexSheet extends StatefulWidget {
  const _SurahIndexSheet({required this.onSurahTap});
  final ValueChanged<int> onSurahTap;

  @override
  State<_SurahIndexSheet> createState() => _SurahIndexSheetState();
}

class _SurahIndexSheetState extends State<_SurahIndexSheet> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final filtered = _search.isEmpty
        ? _surahStartPages
        : _surahStartPages.where((s) =>
            s.$1.contains(_search) ||
            s.$2.toLowerCase().contains(_search.toLowerCase())).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scrollController) {
        return Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.onSurfaceVariant.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.list_alt_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text('فهرس السور', style: AppTheme.headlineSm.copyWith(fontSize: 16)),
                  const Spacer(),
                  Text('114 سورة', style: AppTheme.labelSm.copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceHigh,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _search = v),
                  style: AppTheme.bodyMd.copyWith(color: AppColors.onSurface, fontSize: 13),
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    hintText: 'بحث عن سورة…',
                    hintStyle: AppTheme.bodyMd.copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5), fontSize: 13),
                    prefixIcon: Icon(Icons.search, color: AppColors.onSurfaceVariant.withValues(alpha: 0.5), size: 18),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            // List
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: filtered.length,
                itemBuilder: (_, i) {
                  final surah = filtered[i];
                  final index = _surahStartPages.indexOf(surah) + 1;
                  return GestureDetector(
                    onTap: () => widget.onSurahTap(surah.$3),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withValues(alpha: 0.12),
                            ),
                            child: Center(
                              child: Text('$index', style: AppTheme.labelSm.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 11)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(surah.$1, style: AppTheme.bodyMd.copyWith(fontSize: 15, fontWeight: FontWeight.w600)),
                                Text(surah.$2, style: AppTheme.bodySm.copyWith(color: AppColors.onSurfaceVariant, fontSize: 11)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'ص ${surah.$3}',
                              style: AppTheme.labelSm.copyWith(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
