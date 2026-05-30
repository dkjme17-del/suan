import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/theme/baule_colors.dart';
import '../../../../shared/widgets/baule_decoration.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

enum _CatalogueSort { recommended, alphabetical, duration }

class _StatisticsPageState extends State<StatisticsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  _CatalogueSort _sort = _CatalogueSort.recommended;
  final Set<String> _favorites = <String>{};

  static const List<_CatalogueItem> _masks = [
    _CatalogueItem(
      title: 'Masque Goli',
      subtitle: 'Culte festif et protection communautaire',
      assetImagePath: 'assets/images/baoule/masques/masque_goli.jpg',
      imageUrl:
          'https://images.unsplash.com/photo-1534447677768-be436bb09401?auto=format&fit=crop&w=900&q=80',
      description:
          'Le masque Goli est souvent present lors des celebrations. Il symbolise la force, la joie collective et la transmission des valeurs.',
    ),
    _CatalogueItem(
      title: 'Masque Kpan Pre',
      subtitle: 'Danse de prestige et spiritualite',
      assetImagePath: 'assets/images/baoule/masques/masque_kpan_pre.jpg',
      imageUrl:
          'https://images.unsplash.com/photo-1594736797933-d0f06ba2fe65?auto=format&fit=crop&w=900&q=80',
      description:
          'Reconnaissable par ses lignes marquees, le Kpan Pre accompagne des danses codifiees et celebre la sagesse des anciens.',
    ),
  ];

  static const List<_CatalogueItem> _textiles = [
    _CatalogueItem(
      title: 'Pagnes a motifs geometriques',
      subtitle: 'Identite visuelle baoule',
      assetImagePath: 'assets/images/baoule/textiles/pagne_geometrique.jpg',
      imageUrl:
          'https://images.unsplash.com/photo-1617038220319-276d3cfab638?auto=format&fit=crop&w=900&q=80',
      description:
          'Les motifs geometriques evoquent les liens familiaux, le territoire et l harmonie sociale. Les couleurs or, noir et terre sont frequentes.',
    ),
    _CatalogueItem(
      title: 'Parure ceremonielle',
      subtitle: 'Textile et artisanat',
      assetImagePath: 'assets/images/baoule/textiles/parure_ceremonielle.jpg',
      imageUrl:
          'https://images.unsplash.com/photo-1521572163474-6864f9cf17ab?auto=format&fit=crop&w=900&q=80',
      description:
          'Cette parure rassemble tissu, perles et ornements. Elle accompagne les moments de fete, de danse et de reconnaissance sociale.',
    ),
  ];

  static const List<_VideoItem> _videos = [
    _VideoItem(
      title: 'Danse traditionnelle baoule',
      duration: '06:42',
      assetThumbnailPath:
          'assets/images/baoule/videos/danse_baoule_thumb.jpg',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?auto=format&fit=crop&w=900&q=80',
      assetVideoPath: 'assets/videos/baoule/danse_baoule.mp4',
      videoUrl:
          'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4',
    ),
    _VideoItem(
      title: 'Atelier de fabrication de masque',
      duration: '09:15',
      assetThumbnailPath:
          'assets/images/baoule/videos/atelier_masque_thumb.jpg',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1452800185063-6db5e12b8e2e?auto=format&fit=crop&w=900&q=80',
      assetVideoPath: 'assets/videos/baoule/atelier_masque.mp4',
      videoUrl:
          'https://sample-videos.com/video321/mp4/720/big_buck_bunny_720p_1mb.mp4',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(() {
      final next = _searchController.text.trim();
      if (next == _query) return;
      setState(() {
        _query = next;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesQuery({
    required String title,
    required String subtitle,
    String? description,
  }) {
    if (_query.isEmpty) return true;
    final q = _query.toLowerCase();
    return title.toLowerCase().contains(q) ||
        subtitle.toLowerCase().contains(q) ||
        (description ?? '').toLowerCase().contains(q);
  }

  List<_CatalogueItem> _sortedCatalogueItems(List<_CatalogueItem> input) {
    final items = input.toList();
    switch (_sort) {
      case _CatalogueSort.recommended:
        return items;
      case _CatalogueSort.alphabetical:
        items.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        return items;
      case _CatalogueSort.duration:
        // Non applicable aux items non-vidéo: fallback alphabétique.
        items.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        return items;
    }
  }

  int _parseDurationToSeconds(String duration) {
    // Supporte "mm:ss" (ex: "06:42"). Si invalide: 0.
    final parts = duration.split(':');
    if (parts.length != 2) return 0;
    final mm = int.tryParse(parts[0]) ?? 0;
    final ss = int.tryParse(parts[1]) ?? 0;
    return (mm * 60) + ss;
  }

  List<_VideoItem> _sortedVideoItems(List<_VideoItem> input) {
    final items = input.toList();
    switch (_sort) {
      case _CatalogueSort.recommended:
        return items;
      case _CatalogueSort.alphabetical:
        items.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        return items;
      case _CatalogueSort.duration:
        items.sort(
          (a, b) => _parseDurationToSeconds(a.duration)
              .compareTo(_parseDurationToSeconds(b.duration)),
        );
        return items;
    }
  }

  String _sortLabel(_CatalogueSort sort) {
    switch (sort) {
      case _CatalogueSort.recommended:
        return 'Recommandé';
      case _CatalogueSort.alphabetical:
        return 'Alphabétique';
      case _CatalogueSort.duration:
        return 'Durée';
    }
  }

  void _toggleFavorite(String key) {
    setState(() {
      if (_favorites.contains(key)) {
        _favorites.remove(key);
      } else {
        _favorites.add(key);
      }
    });
  }

  Widget _buildSearchAndControls() {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.92),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Effacer',
                      onPressed: () => _searchController.clear(),
                      icon: const Icon(Icons.close),
                    ),
              hintText: 'Rechercher (masques, textiles, vidéos…)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: BauleColors.lightGold),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: BauleColors.lightGold),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: theme.colorScheme.primary),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _MediaFilterChip(
                        label: 'Masques',
                        icon: Icons.masks,
                        isSelected: _tabController.index == 0,
                        onTap: () => _tabController.animateTo(0),
                      ),
                      const SizedBox(width: 8),
                      _MediaFilterChip(
                        label: 'Textiles',
                        icon: Icons.checkroom,
                        isSelected: _tabController.index == 1,
                        onTap: () => _tabController.animateTo(1),
                      ),
                      const SizedBox(width: 8),
                      _MediaFilterChip(
                        label: 'Vidéos',
                        icon: Icons.play_circle,
                        isSelected: _tabController.index == 2,
                        onTap: () => _tabController.animateTo(2),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              PopupMenuButton<_CatalogueSort>(
                tooltip: 'Trier',
                onSelected: (value) => setState(() => _sort = value),
                itemBuilder: (context) => [
                  for (final v in _CatalogueSort.values)
                    PopupMenuItem<_CatalogueSort>(
                      value: v,
                      child: Row(
                        children: [
                          Icon(
                            v == _CatalogueSort.recommended
                                ? Icons.auto_awesome
                                : v == _CatalogueSort.alphabetical
                                    ? Icons.sort_by_alpha
                                    : Icons.schedule,
                            size: 18,
                            color: BauleColors.deepBlack,
                          ),
                          const SizedBox(width: 10),
                          Text(_sortLabel(v)),
                        ],
                      ),
                    ),
                ],
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: BauleColors.lightGold),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.swap_vert, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        _sortLabel(_sort),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Catalogue Baoulé'),
        backgroundColor: BauleColors.deepBlack,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: BauleColors.gold,
          labelColor: BauleColors.gold,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Masques', icon: Icon(Icons.masks)),
            Tab(text: 'Textiles', icon: Icon(Icons.checkroom)),
            Tab(text: 'Vidéos', icon: Icon(Icons.play_circle)),
          ],
        ),
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: BaulePatternBackground(
              opacity: 0.1,
              backgroundColor: BauleColors.creamWhite,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                AnimatedBuilder(
                  animation: _tabController,
                  builder: (_, __) => _buildSearchAndControls(),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _CatalogueList(
                        items: _sortedCatalogueItems(
                          _masks
                              .where(
                                (i) => _matchesQuery(
                                  title: i.title,
                                  subtitle: i.subtitle,
                                  description: i.description,
                                ),
                              )
                              .toList(),
                        ),
                        favorites: _favorites,
                        onToggleFavorite: _toggleFavorite,
                        onOpenDetail: (item) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => _CatalogueDetailPage(item: item),
                            ),
                          );
                        },
                      ),
                      _CatalogueList(
                        items: _sortedCatalogueItems(
                          _textiles
                              .where(
                                (i) => _matchesQuery(
                                  title: i.title,
                                  subtitle: i.subtitle,
                                  description: i.description,
                                ),
                              )
                              .toList(),
                        ),
                        favorites: _favorites,
                        onToggleFavorite: _toggleFavorite,
                        onOpenDetail: (item) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => _CatalogueDetailPage(item: item),
                            ),
                          );
                        },
                      ),
                      _VideoList(
                        items: _sortedVideoItems(
                          _videos
                              .where(
                                (v) => _matchesQuery(
                                  title: v.title,
                                  subtitle: v.duration,
                                ),
                              )
                              .toList(),
                        ),
                        favorites: _favorites,
                        onToggleFavorite: _toggleFavorite,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaFilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _MediaFilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? BauleColors.gold : Colors.white.withValues(alpha: 0.92);
    final textColor = isSelected ? BauleColors.deepBlack : Colors.black87;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: BauleColors.lightGold),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.w700, color: textColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogueList extends StatelessWidget {
  final List<_CatalogueItem> items;
  final Set<String> favorites;
  final void Function(String key) onToggleFavorite;
  final void Function(_CatalogueItem item) onOpenDetail;

  const _CatalogueList({
    required this.items,
    required this.favorites,
    required this.onToggleFavorite,
    required this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Aucun résultat.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) => _CatalogueCard(
        item: items[index],
        isFavorite: favorites.contains(items[index].key),
        onToggleFavorite: () => onToggleFavorite(items[index].key),
        onOpenDetail: () => onOpenDetail(items[index]),
      ),
    );
  }
}

class _CatalogueCard extends StatelessWidget {
  final _CatalogueItem item;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final VoidCallback onOpenDetail;

  const _CatalogueCard({
    required this.item,
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.onOpenDetail,
  });

  Widget _buildCoverImage(BuildContext context) {
    final assetPath = item.assetImagePath;
    if (assetPath == null) {
      return Image.network(
        item.imageUrl,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    return Image.asset(
      assetPath,
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return Image.network(
          item.imageUrl,
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            height: 180,
            color: BauleColors.lightGold,
            alignment: Alignment.center,
            child: const Icon(Icons.image_not_supported, size: 42),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BauleColors.lightGold),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onOpenDetail,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  children: [
                    _buildCoverImage(context),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black.withValues(alpha: 0.45),
                          foregroundColor: Colors.white,
                        ),
                        tooltip: isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
                        onPressed: onToggleFavorite,
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: BauleColors.deepBlack,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: BauleColors.lightGold.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Baoulé',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: BauleColors.deepBlack,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.subtitle,
                      style: const TextStyle(
                        color: BauleColors.redOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      item.description,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        height: 1.45,
                        color: BauleColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: BauleColors.gold.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              'En savoir plus sur cet élément culturel.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: BauleColors.deepBlack,
                                  ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: onOpenDetail,
                          icon: const Icon(Icons.open_in_new, size: 18),
                          label: const Text('Voir le détail'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: BauleColors.deepBlack,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          onPressed: onToggleFavorite,
                          tooltip: isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black.withValues(alpha: 0.08),
                            foregroundColor: BauleColors.deepBlack,
                          ),
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VideoList extends StatelessWidget {
  final List<_VideoItem> items;
  final Set<String> favorites;
  final void Function(String key) onToggleFavorite;

  const _VideoList({
    required this.items,
    required this.favorites,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Aucun résultat.',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) => _VideoCard(
        item: items[index],
        isFavorite: favorites.contains(items[index].key),
        onToggleFavorite: () => onToggleFavorite(items[index].key),
      ),
    );
  }
}

class _VideoCard extends StatelessWidget {
  final _VideoItem item;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  const _VideoCard({
    required this.item,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  Widget _buildThumbnailImage() {
    final assetPath = item.assetThumbnailPath;
    if (assetPath == null) {
      return Image.network(
        item.thumbnailUrl,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    return Image.asset(
      assetPath,
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Image.network(
        item.thumbnailUrl,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          height: 180,
          color: BauleColors.lightGold,
          alignment: Alignment.center,
          child: const Icon(Icons.videocam_off, size: 42),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BauleColors.lightGold),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                await showDialog(
                  context: context,
                  builder: (_) => _VideoPlayDialog(item: item),
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildThumbnailImage(),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withValues(alpha: 0.45),
                        foregroundColor: Colors.white,
                      ),
                      tooltip:
                          isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
                      onPressed: onToggleFavorite,
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                      ),
                    ),
                  ),
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.duration,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: BauleColors.deepBlack,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: BauleColors.deepBlack.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: BauleColors.lightGold),
                  ),
                  child: Text(
                    item.duration,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: BauleColors.deepBlack,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogueItem {
  final String title;
  final String subtitle;
  final String? assetImagePath;
  final String imageUrl;
  final String description;

  const _CatalogueItem({
    required this.title,
    required this.subtitle,
    this.assetImagePath,
    required this.imageUrl,
    required this.description,
  });

  String get key => 'cat:${title.toLowerCase()}';
}

class _VideoItem {
  final String title;
  final String duration;
  final String thumbnailUrl;
  final String? assetThumbnailPath;
  final String? assetVideoPath;
  final String? videoUrl;

  const _VideoItem({
    required this.title,
    required this.duration,
    required this.thumbnailUrl,
    this.assetThumbnailPath,
    this.assetVideoPath,
    this.videoUrl,
  });

  String get key => 'vid:${title.toLowerCase()}';
}

class _CatalogueDetailPage extends StatelessWidget {
  final _CatalogueItem item;

  const _CatalogueDetailPage({required this.item});

  Widget _buildHeroImage(BuildContext context) {
    final image = item.assetImagePath != null
        ? Image.asset(
            item.assetImagePath!,
            width: double.infinity,
            height: 240,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Image.network(
              item.imageUrl,
              width: double.infinity,
              height: 240,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 240,
                color: BauleColors.lightGold,
                alignment: Alignment.center,
                child: const Icon(Icons.image_not_supported, size: 56),
              ),
            ),
          )
        : Image.network(
            item.imageUrl,
            width: double.infinity,
            height: 240,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 240,
              color: BauleColors.lightGold,
              alignment: Alignment.center,
              child: const Icon(Icons.image_not_supported, size: 56),
            ),
          );

    return Hero(
      tag: item.key,
      child: image,
    );
  }

  void _openImageFullScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FullscreenImagePage(item: item),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Détail'),
        backgroundColor: BauleColors.deepBlack,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: BaulePatternBackground(
              opacity: 0.1,
              backgroundColor: BauleColors.creamWhite,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: BauleColors.lightGold),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                      child: GestureDetector(
                        onTap: () => _openImageFullScreen(context),
                        child: Stack(
                          children: [
                            _buildHeroImage(context),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Container(
                                height: 120,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.65),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 16,
                              right: 16,
                              bottom: 16,
                              child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.subtitle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: BauleColors.gold.withOpacity(0.14),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  item.subtitle,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(
                                        color: BauleColors.deepBlack,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Description',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: BauleColors.deepBlack,
                                ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            item.description,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  height: 1.6,
                                  color: BauleColors.darkText,
                                ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline,
                                  color: BauleColors.gold),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Découvrez l’histoire, les usages et la symbolique du patrimoine baoulé à travers cet objet culturel.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        height: 1.5,
                                        color: BauleColors.deepBlack,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FullscreenImagePage extends StatelessWidget {
  final _CatalogueItem item;

  const _FullscreenImagePage({required this.item});

  @override
  Widget build(BuildContext context) {
    final imageWidget = item.assetImagePath != null
        ? Image.asset(
            item.assetImagePath!,
            fit: BoxFit.contain,
            width: double.infinity,
          )
        : Image.network(
            item.imageUrl,
            fit: BoxFit.contain,
            width: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (_, __, ___) => Container(
              color: BauleColors.lightGold,
              alignment: Alignment.center,
              child: const Icon(
                Icons.image_not_supported,
                size: 64,
                color: Colors.white,
              ),
            ),
          );

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          item.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 1.0,
          maxScale: 4.0,
          child: Hero(
            tag: item.key,
            child: imageWidget,
          ),
        ),
      ),
    );
  }
}

class _VideoPlayDialog extends StatefulWidget {
  final _VideoItem item;

  const _VideoPlayDialog({required this.item});

  @override
  State<_VideoPlayDialog> createState() => _VideoPlayDialogState();
}

class _VideoPlayDialogState extends State<_VideoPlayDialog> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  String? _error;
  bool _canOpenExternally = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Uri? _externalUri() {
    final raw = widget.item.videoUrl;
    if (raw == null) return null;
    final uri = Uri.tryParse(raw);
    if (uri == null) return null;
    if (uri.scheme != 'https') return null;
    return uri;
  }

  Future<void> _openExternally() async {
    final uri = _externalUri();
    if (uri == null) return;
    await launchUrl(
      uri,
      mode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
      webOnlyWindowName: kIsWeb ? '_blank' : null,
    );
  }

  Future<void> _init() async {
    try {
      final externalUri = _externalUri();
      _canOpenExternally = externalUri != null;

      // Sur Flutter Web, le lecteur HTML5 impose des contraintes (CORS/codec).
      // Pour une fiabilité maximale, on ouvre la vidéo dans un nouvel onglet.
      if (kIsWeb) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        return;
      }

      // 1) Priorité aux assets locaux (si présents)
      if (widget.item.assetVideoPath != null) {
        final assetController =
            VideoPlayerController.asset(widget.item.assetVideoPath!);
        try {
          await assetController.initialize();
          if (!mounted) return;
          setState(() {
            _controller = assetController;
            _isLoading = false;
          });
          return;
        } catch (e) {
          await assetController.dispose();
          // Fallback vers le réseau
        }
      }

      // 2) Fallback vers la source réseau
      final networkUrl = widget.item.videoUrl;
      if (networkUrl == null) {
        throw Exception('Aucune source vidéo disponible');
      }

      final networkController =
          VideoPlayerController.networkUrl(Uri.parse(networkUrl));
      await networkController.initialize();
      if (!mounted) return;
      setState(() {
        _controller = networkController;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.item.title),
      content: SizedBox(
        width: double.maxFinite,
        child: AspectRatio(
          aspectRatio: _controller?.value.aspectRatio ?? 16 / 9,
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : kIsWeb
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Lecture vidéo',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sur le Web, la lecture intégrée peut échouer (CORS / format).',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 12),
                        if (_canOpenExternally)
                          ElevatedButton.icon(
                            onPressed: _openExternally,
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('Ouvrir la vidéo'),
                          )
                        else
                          Text(
                            'Aucun lien vidéo https disponible.',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                      ],
                    )
                  : _error != null
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Lecture indisponible',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 12),
                            if (_canOpenExternally)
                              OutlinedButton.icon(
                                onPressed: _openExternally,
                                icon: const Icon(Icons.open_in_new),
                                label: const Text('Ouvrir la vidéo'),
                              ),
                          ],
                        )
                      : Stack(
                          children: [
                            VideoPlayer(_controller!),
                            Positioned.fill(
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      final isPlaying =
                                          _controller!.value.isPlaying;
                                      if (isPlaying) {
                                        _controller!.pause();
                                      } else {
                                        _controller!.play();
                                      }
                                      setState(() {});
                                    },
                                    icon: Icon(
                                      _controller!.value.isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                    ),
                                    label: Text(
                                      _controller!.value.isPlaying
                                          ? 'Pause'
                                          : 'Lecture',
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
        ),
      ),
      actions: [
        if (_canOpenExternally)
          TextButton(
            onPressed: _openExternally,
            child: const Text('Ouvrir'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fermer'),
        )
      ],
    );
  }
}
