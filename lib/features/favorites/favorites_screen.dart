import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme_config.dart';
import '../destination/destination_detail_screen.dart';
import '../destination/destination_model.dart';

class FavoritesScreen extends StatefulWidget {
  final ThemeConfig config;
  final VoidCallback? onExploreTap;

  const FavoritesScreen({
    super.key,
    required this.config,
    this.onExploreTap,
  });

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String _selectedFilter = 'Tous';
  final List<String> _filters = ['Tous', 'Europe', 'Scandinavie', 'Afrique', 'Asie'];

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final allItems = DestinationItem.sampleDestinations;
    final favoriteItems = allItems.where((d) => d.isFavorite).toList();

    final filteredItems = _selectedFilter == 'Tous'
        ? favoriteItems
        : favoriteItems.where((d) => d.country == _selectedFilter).toList();

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vos Favoris',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: config.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${favoriteItems.length} voyages d\'exception enregistrés',
                      style: TextStyle(fontSize: 13, color: config.textSecondary),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 20),
                ),
              ],
            ),
          ),

          // Filtres par région
          SizedBox(
            height: 40,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final filter = _filters[i];
                final active = _selectedFilter == filter;
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilter = filter),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? config.accent : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: active ? config.accent : const Color(0xFFE2E8F0),
                        width: 1.2,
                      ),
                      boxShadow: active
                          ? [
                              BoxShadow(
                                color: config.accent.withValues(alpha: 0.25),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: active ? Colors.white : config.textSecondary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          // Liste des favoris ou état vide
          Expanded(
            child: filteredItems.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.favorite_border_rounded, size: 64, color: config.textMuted),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun favori dans cette catégorie',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: config.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Ajoutez des destinations en cliquant sur le cœur.',
                            style: TextStyle(color: config.textSecondary, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          if (widget.onExploreTap != null)
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: config.accent,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              onPressed: widget.onExploreTap,
                              child: const Text('Découvrir les voyages'),
                            ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, i) {
                      final item = filteredItems[i];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DestinationDetailScreen(item: item, config: config),
                            ),
                          ).then((_) => setState(() {}));
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: const Color(0x180F4C81), width: 1.2),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF0F4C81).withValues(alpha: 0.06),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: item.gradientColors),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(item.icon, color: Colors.white, size: 26),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: GoogleFonts.spaceGrotesk(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: config.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${item.location} · ${item.durationDays} jours',
                                      style: TextStyle(color: config.textSecondary, fontSize: 13),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${item.price} € / pers.',
                                      style: TextStyle(
                                        color: config.accent,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.favorite_rounded, color: Colors.redAccent),
                                onPressed: () {
                                  setState(() {
                                    item.isFavorite = false;
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      behavior: SnackBarBehavior.floating,
                                      content: Text('${item.title} retiré des favoris'),
                                      duration: const Duration(seconds: 2),
                                      action: SnackBarAction(
                                        label: 'Annuler',
                                        onPressed: () => setState(() => item.isFavorite = true),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
