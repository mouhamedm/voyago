import 'package:flutter/material.dart';
import '../../core/motion.dart';
import '../../core/theme_config.dart';
import '../../main.dart';
import '../../shared/widgets/scene_decor.dart';
import '../auth/auth_service.dart';
import '../destination/destination_detail_screen.dart';
import '../destination/destination_model.dart';
import '../favorites/favorites_screen.dart';
import '../map/map_screen.dart';
import '../profile/profile_screen.dart';
import 'widgets/animated_search_bar.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/destination_card.dart';
import 'widgets/hero_card.dart';
import 'widgets/home_header.dart';

/// Séquence 5 : la Home.
/// Héberge désormais les 4 onglets majeurs de Voyago :
/// 0: Explorer (Accueil dynamique, Hero Card & Destinations cliquables)
/// 1: Favoris (Liste de souhaits, filtres par continent, alertes de prix)
/// 2: Carte (Radar aérien en direct, hubs internationaux, météo)
/// 3: Profil (Compte VIP, carte d'embarquement, réglages, déconnexion)
class HomeScreen extends StatefulWidget {
  final ThemeConfig config;
  const HomeScreen({super.key, required this.config});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _clock;
  final _scrollController = ScrollController();
  int _currentTab = 0;
  int _selectedCategoryIndex = 0;
  static const _categories = ['Tous', 'Fjords & Nord', 'Plages & Îles', 'Villes d\'Art', 'Évasions VIP'];

  final List<DestinationItem> _destinations = DestinationItem.sampleDestinations;
  late final List<GlobalKey> _cardKeys = List.generate(_destinations.length, (_) => GlobalKey());

  @override
  void initState() {
    super.initState();
    _clock = AnimationController(vsync: this, duration: const Duration(seconds: 1000))..repeat();
    _entrance = AnimationController(vsync: this, duration: const Duration(milliseconds: 1700));

    Future.delayed(Motion.homeRevealDelay, () {
      if (!mounted) return;
      if (Motion.reduceMotion) {
        _entrance.value = 1;
      } else {
        _entrance.forward();
      }
    });
  }

  @override
  void dispose() {
    _entrance.dispose();
    _clock.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  double _slice(double start, double end, {Curve curve = Curves.linear}) =>
      Interval(start.clamp(0.0, 1.0), end.clamp(0.0, 1.0), curve: curve).transform(_entrance.value);

  double _depthScale(int index) {
    final renderObject = _cardKeys[index].currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.attached) return 1;
    final screenHeight = MediaQuery.of(context).size.height;
    final position = renderObject.localToGlobal(Offset.zero);
    final itemCenter = position.dy + renderObject.size.height / 2;
    final distance = (itemCenter - screenHeight / 2).abs();
    final fraction = (distance / (screenHeight / 2)).clamp(0.0, 1.0);
    return 1 - fraction * 0.05;
  }

  void _openDestination(DestinationItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DestinationDetailScreen(item: item, config: widget.config),
      ),
    ).then((_) => setState(() {}));
  }

  void _openSpecialOffer() {
    // Offre du moment VIP
    final specialOffer = _destinations.firstWhere(
      (d) => d.id == 'fjords',
      orElse: () => _destinations.first,
    );
    _openDestination(specialOffer);
  }

  void _showSearchDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.65,
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Rechercher un pays, une île, une ville...',
                  prefixIcon: Icon(Icons.search_rounded, color: widget.config.secondary),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Escales populaires', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: _destinations.length,
                  itemBuilder: (context, i) {
                    final item = _destinations[i];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: widget.config.accent.withValues(alpha: 0.1),
                        child: Icon(item.icon, color: widget.config.accent, size: 20),
                      ),
                      title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                      subtitle: Text('${item.location} · dès ${item.price} €'),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                      onTap: () {
                        Navigator.pop(ctx);
                        _openDestination(item);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _handleLogout() async {
    await AuthService.instance.logout();
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
    kReplaySignal.value++;
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;

    return Scaffold(
      backgroundColor: config.backgroundBottom,
      body: Container(
        decoration: BoxDecoration(gradient: config.backgroundGradient),
        child: AnimatedBuilder(
          animation: Listenable.merge([_entrance, _clock, _scrollController]),
          builder: (context, _) {
            final time = _clock.value * 1000;

            // Proposition 1 : Apparition en cascade (Staggered Entrance)
            // 1. Header : avatar & cloche descendent doucement (Fade + SlideDown, 300ms)
            final headerReveal = _slice(0.0, 0.22, curve: Curves.easeOutBack);
            // 2. Barre de recherche & Chips : glissent depuis la droite avec inertie douce
            final searchReveal = _slice(0.10, 0.38, curve: Curves.easeOutCubic);
            final chipsReveal = _slice(0.16, 0.44, curve: Curves.easeOutCubic);
            // 3. Bannière Hero : s'agrandit légèrement avec effet shimmer
            final heroReveal = _slice(0.24, 0.58, curve: Curves.easeOutBack);
            // 5. Bottom Bar : remonte délicatement avec flou glassmorphic
            final navReveal = _slice(0.18, 0.60, curve: Curves.easeOutBack);

            return SafeArea(
              child: Stack(
                children: [
                  // Nuages en fond dans le tiers supérieur
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 220,
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: 0.75,
                        child: SceneDecor(config: config, time: time),
                      ),
                    ),
                  ),

                  // Corps des onglets
                  IndexedStack(
                    index: _currentTab,
                    children: [
                      // Onglet 0 : Explorer / Home
                      Column(
                        children: [
                          // 1. Header (Fade + SlideDown)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                            child: HomeHeader(
                              config: config,
                              reveal: headerReveal,
                              onProfileTap: () => setState(() => _currentTab = 3),
                            ),
                          ),

                          // 2. Barre de recherche (Glisse depuis la droite avec inertie douce)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Opacity(
                              opacity: searchReveal.clamp(0.0, 1.0),
                              child: Transform.translate(
                                offset: Offset(42 * (1 - searchReveal), 0),
                                child: GestureDetector(
                                  onTap: _showSearchDialog,
                                  child: AbsorbPointer(
                                    child: AnimatedSearchBar(config: config, reveal: searchReveal),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // 2bis. Chips catégories (Glissent depuis la droite avec inertie douce)
                          Padding(
                            padding: const EdgeInsets.only(top: 12, bottom: 4),
                            child: Opacity(
                              opacity: chipsReveal.clamp(0.0, 1.0),
                              child: Transform.translate(
                                offset: Offset(55 * (1 - chipsReveal), 0),
                                child: SizedBox(
                                  height: 38,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    itemCount: _categories.length,
                                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                                    itemBuilder: (context, idx) {
                                      final isSelected = _selectedCategoryIndex == idx;
                                      return GestureDetector(
                                        onTap: () => setState(() => _selectedCategoryIndex = idx),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 250),
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? config.accent
                                                : (config.isLight
                                                    ? Colors.white.withValues(alpha: 0.9)
                                                    : Colors.white.withValues(alpha: 0.08)),
                                            borderRadius: BorderRadius.circular(20),
                                            border: Border.all(
                                              color: isSelected
                                                  ? config.accent
                                                  : (config.isLight
                                                      ? const Color(0x1E0F4C81)
                                                      : Colors.white12),
                                              width: 1.1,
                                            ),
                                            boxShadow: isSelected
                                                ? [
                                                    BoxShadow(
                                                      color: config.accent.withValues(alpha: 0.35),
                                                      blurRadius: 10,
                                                      offset: const Offset(0, 3),
                                                    ),
                                                  ]
                                                : null,
                                          ),
                                          child: Text(
                                            _categories[idx],
                                            style: TextStyle(
                                              color: isSelected
                                                  ? Colors.white
                                                  : (config.isLight
                                                      ? const Color(0xFF0F172A)
                                                      : Colors.white70),
                                              fontSize: 13,
                                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          Expanded(
                            child: CustomScrollView(
                              controller: _scrollController,
                              slivers: [
                                // 3. Bannière Hero (S'agrandit légèrement avec brillance shimmer)
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    child: HeroCard(
                                      config: config,
                                      reveal: heroReveal,
                                      time: time,
                                      onTap: _openSpecialOffer,
                                    ),
                                  ),
                                ),
                                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                                // 4. Grille de destinations (Chaque carte apparaît avec 60ms de décalage)
                                SliverPadding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  sliver: SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, i) {
                                        // Décalage exact de 60ms par carte
                                        final start = 0.34 + i * (60 / 1700);
                                        final reveal = _slice(start, (start + 0.26).clamp(0.0, 1.0), curve: Curves.easeOutCubic);
                                        final item = _destinations[i];
                                        return DestinationCard(
                                          key: _cardKeys[i],
                                          config: config,
                                          data: DestinationData(
                                            title: item.title,
                                            location: item.location,
                                            price: item.price,
                                            durationDays: item.durationDays,
                                          ),
                                          reveal: reveal,
                                          depthScale: _depthScale(i),
                                          onTap: () => _openDestination(item),
                                        );
                                      },
                                      childCount: _destinations.length,
                                    ),
                                  ),
                                ),
                                const SliverToBoxAdapter(child: SizedBox(height: 110)),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Onglet 1 : Favoris
                      FavoritesScreen(
                        config: config,
                        onExploreTap: () => setState(() => _currentTab = 0),
                      ),

                      // Onglet 2 : Carte interactive & radar
                      MapScreen(config: config),

                      // Onglet 3 : Profil & Déconnexion
                      ProfileScreen(
                        config: config,
                        onLogout: _handleLogout,
                      ),
                    ],
                  ),

                  // Barre de navigation inférieure persistante
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: BottomNav(
                      config: config,
                      reveal: navReveal,
                      currentIndex: _currentTab,
                      onTap: (index) => setState(() => _currentTab = index),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
