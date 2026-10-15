import 'package:flutter/material.dart';
import '../../core/motion.dart';
import '../../core/theme_config.dart';
import '../../shared/widgets/scene_decor.dart';
import 'widgets/animated_search_bar.dart';
import 'widgets/bottom_nav.dart';
import 'widgets/destination_card.dart';
import 'widgets/hero_card.dart';
import 'widgets/home_header.dart';

/// Séquence 5 : la Home. Un seul AnimationController maître ([_entrance])
/// pilote la cascade d'ouverture (header -> recherche -> hero -> liste),
/// révélée [Motion.homeRevealDelay] après l'arrivée de l'écran (le temps que
/// le reveal circulaire termine de couvrir l'écran).
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

  static const _destinations = [
    DestinationData(title: 'Lisbonne au soleil', location: 'Portugal', price: 420, durationDays: 5),
    DestinationData(title: 'Les fjords de Norvège', location: 'Norvège', price: 980, durationDays: 7),
    DestinationData(title: 'Marrakech authentique', location: 'Maroc', price: 310, durationDays: 4),
    DestinationData(title: 'Kyoto en fleurs', location: 'Japon', price: 1450, durationDays: 9),
  ];
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

  /// Effet de profondeur léger : les cartes qui sortent du viewport
  /// rétrécissent légèrement (scale jusqu'à 0.95).
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
            final headerReveal = _slice(0, Motion.headerEntrance.inMilliseconds / 1700, curve: Curves.easeOutCubic);
            final searchReveal = _slice(0.16, 0.16 + Motion.searchBarExpand.inMilliseconds / 1700);
            final heroReveal = _slice(0.24, 0.6);
            final navReveal = _slice(0.1, 0.55);

            return SafeArea(
              child: Stack(
                children: [
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
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                        child: HomeHeader(config: config, reveal: headerReveal),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: AnimatedSearchBar(config: config, reveal: searchReveal),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: CustomScrollView(
                          controller: _scrollController,
                          slivers: [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: HeroCard(config: config, reveal: heroReveal, time: time),
                              ),
                            ),
                            const SliverToBoxAdapter(child: SizedBox(height: 20)),
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, i) {
                                    final start = 0.4 + i * (Motion.cardStagger.inMilliseconds / 1700);
                                    final reveal = _slice(start, start + 0.3);
                                    return DestinationCard(
                                      key: _cardKeys[i],
                                      config: config,
                                      data: _destinations[i],
                                      reveal: reveal,
                                      depthScale: _depthScale(i),
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
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: BottomNav(config: config, reveal: navReveal),
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
