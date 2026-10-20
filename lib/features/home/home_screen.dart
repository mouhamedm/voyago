import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme_config.dart';
import '../auth/auth_service.dart';
import '../auth/login_screen.dart';
import '../flights/flight_results_screen.dart';

/// Écran 2 : Accueil (Home)
/// Fidèle à la deuxième capture d'écran :
/// - Header : Logo avion en papier + VOYAGO + Avatar (Mouhamed) + Cloche
/// - Message : "Bonjour Mouhamed, / Où souhaitez-vous aller aujourd'hui ?"
/// - Carte de recherche de vol :
///   - De : Abidjan (ABJ) + Bouton swap
///   - À : Destination / Paris (CDG)
///   - Date de départ : Sam. 25 oct. 2025 >
///   - Passagers : 1 adulte, Économique >
/// Modèle enrichi pour les cartes de destinations populaires
class PopularDestinationItem {
  final String id;
  final String title;
  final String country;
  final String code;
  final String price;
  final String originalPrice;
  final String image;
  final double rating;
  final int reviews;
  final String tag;
  final String category;
  final String duration;

  const PopularDestinationItem({
    required this.id,
    required this.title,
    required this.country,
    required this.code,
    required this.price,
    required this.originalPrice,
    required this.image,
    required this.rating,
    required this.reviews,
    required this.tag,
    required this.category,
    required this.duration,
  });
}

/// Écran 2 : Accueil (Home)
/// Fidèle aux maquettes VOYAGO :
/// - Header : Logo avion en papier + VOYAGO + Avatar (Mouhamed) + Cloche
/// - Message : "Bonjour Mouhamed, / Où souhaitez-vous aller aujourd'hui ?"
/// - Carte de recherche de vol :
///   - De : Abidjan (ABJ) + Bouton swap
///   - À : Destination / Paris (CDG)
///   - Date de départ : Sam. 25 oct. 2025 >
///   - Passagers : 1 adulte, Économique >
///   - Bouton bleu : [ 🔍 Rechercher un vol ]
/// - Section "Destinations populaires" enrichie (Paris, Dakar, Dubaï, New York, Tokyo, Marrakech)
/// - BottomNavigationBar : Accueil (actif), Rechercher, Mes vols, Profil
class HomeScreen extends StatefulWidget {
  final ThemeConfig config;
  const HomeScreen({super.key, required this.config});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _greetingFade;
  late final Animation<Offset> _greetingSlide;
  late final Animation<double> _cardFade;
  late final Animation<Offset> _cardSlide;
  late final Animation<double> _destFade;
  late final Animation<Offset> _destSlide;

  int _currentTab = 0;
  String _departureCity = 'Abidjan (ABJ)';
  String _destinationCity = 'Destination';
  final String _dateText = 'Sam. 25 oct. 2025';
  final String _passengersText = '1 adulte, Économique';

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _headerFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
    ));

    _greetingFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.15, 0.60, curve: Curves.easeOut),
    );
    _greetingSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.15, 0.60, curve: Curves.easeOutCubic),
    ));

    _cardFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.30, 0.80, curve: Curves.easeOut),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.30, 0.80, curve: Curves.easeOutCubic),
    ));

    _destFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.45, 1.0, curve: Curves.easeOut),
    );
    _destSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.45, 1.0, curve: Curves.easeOutCubic),
    ));

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  final Set<String> _favoriteDestinations = {'paris', 'dubai'};
  String _selectedDestCategory = 'Toutes';
  final List<String> _destCategories = const [
    'Toutes',
    'Populaires',
    'Soleil & Mer',
    'Luxe & VIP',
    'Urbain',
  ];

  final List<PopularDestinationItem> _popularDestinations = const [
    PopularDestinationItem(
      id: 'paris',
      title: 'Paris',
      country: 'France',
      code: 'CDG',
      price: '412 €',
      originalPrice: '510 €',
      image: 'assets/paris.jpg',
      rating: 4.9,
      reviews: 420,
      tag: '✨ Coup de cœur',
      category: 'Urbain',
      duration: '6h 20m direct',
    ),
    PopularDestinationItem(
      id: 'dakar',
      title: 'Dakar',
      country: 'Sénégal',
      code: 'DSS',
      price: '278 €',
      originalPrice: '350 €',
      image: 'assets/dakar.jpg',
      rating: 4.8,
      reviews: 310,
      tag: '🔥 Top Tendance',
      category: 'Soleil & Mer',
      duration: '3h 15m direct',
    ),
    PopularDestinationItem(
      id: 'dubai',
      title: 'Dubaï',
      country: 'Émirats AU',
      code: 'DXB',
      price: '540 €',
      originalPrice: '680 €',
      image: 'assets/dubai.jpg',
      rating: 4.94,
      reviews: 390,
      tag: '💎 Luxe & VIP',
      category: 'Luxe & VIP',
      duration: '7h 45m direct',
    ),
    PopularDestinationItem(
      id: 'newyork',
      title: 'New York',
      country: 'États-Unis',
      code: 'JFK',
      price: '620 €',
      originalPrice: '790 €',
      image: 'assets/newyork.jpg',
      rating: 4.95,
      reviews: 580,
      tag: '🗽 Incontournable',
      category: 'Urbain',
      duration: '8h 10m direct',
    ),
    PopularDestinationItem(
      id: 'tokyo',
      title: 'Tokyo',
      country: 'Japon',
      code: 'HND',
      price: '780 €',
      originalPrice: '920 €',
      image: 'assets/tokyo.jpg',
      rating: 4.98,
      reviews: 450,
      tag: '🌸 Aventure Zen',
      category: 'Populaires',
      duration: '13h 30m',
    ),
    PopularDestinationItem(
      id: 'marrakech',
      title: 'Marrakech',
      country: 'Maroc',
      code: 'RAK',
      price: '195 €',
      originalPrice: '260 €',
      image: 'assets/marrakech.jpg',
      rating: 4.86,
      reviews: 270,
      tag: '⭐ Meilleur Prix',
      category: 'Soleil & Mer',
      duration: '3h 10m direct',
    ),
  ];

  List<PopularDestinationItem> get _filteredDestinations {
    if (_selectedDestCategory == 'Toutes') return _popularDestinations;
    if (_selectedDestCategory == 'Populaires') {
      return _popularDestinations.where((d) => d.rating >= 4.9).toList();
    }
    return _popularDestinations.where((d) => d.category == _selectedDestCategory).toList();
  }

  void _toggleFavorite(PopularDestinationItem dest) {
    final wasFav = _favoriteDestinations.contains(dest.id);
    setState(() {
      if (wasFav) {
        _favoriteDestinations.remove(dest.id);
      } else {
        _favoriteDestinations.add(dest.id);
      }
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1400),
        backgroundColor: wasFav ? const Color(0xFF334155) : const Color(0xFFEF4444),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        content: Row(
          children: [
            Icon(
              wasFav ? Icons.favorite_border_rounded : Icons.favorite_rounded,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                wasFav
                    ? '${dest.title} retiré de vos coups de cœur'
                    : '❤️ ${dest.title} ajouté à vos coups de cœur !',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onSearchFlights({String? destCity, String? destCode}) {
    setState(() {
      if (destCity != null && destCity != 'Toutes' && destCity != 'ALL') {
        _destinationCity = destCity.contains('(') ? destCity : '$destCity (${destCode ?? 'CDG'})';
      }
      _currentTab = 1; // Bascule sur l'onglet Rechercher en conservant la BottomNavigationBar visible !
    });
  }

  void _onSwapCities() {
    setState(() {
      final temp = _departureCity;
      _departureCity = _destinationCity == 'Destination' ? 'Paris (CDG)' : _destinationCity;
      _destinationCity = temp;
    });
  }

  void _selectDestination() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choisir une destination',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.flight_land_rounded, color: Color(0xFF2563EB)),
                title: const Text('Paris (CDG) - France', style: TextStyle(fontWeight: FontWeight.w700)),
                onTap: () {
                  setState(() => _destinationCity = 'Paris (CDG)');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.flight_land_rounded, color: Color(0xFF2563EB)),
                title: const Text('Dakar (DSS) - Sénégal', style: TextStyle(fontWeight: FontWeight.w700)),
                onTap: () {
                  setState(() => _destinationCity = 'Dakar (DSS)');
                  Navigator.pop(ctx);
                },
              ),
              ListTile(
                leading: const Icon(Icons.flight_land_rounded, color: Color(0xFF2563EB)),
                title: const Text('New York (JFK) - États-Unis', style: TextStyle(fontWeight: FontWeight.w700)),
                onTap: () {
                  setState(() => _destinationCity = 'New York (JFK)');
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: IndexedStack(
          index: _currentTab,
          children: [
            // Onglet 0 : Accueil (Screen 2 dans la capture)
            _buildHomeContent(),

            // Onglet 1 : Rechercher (accès direct aux résultats avec BottomNavigationBar préservée)
            FlightResultsScreen(
              config: widget.config,
              departureCity: _departureCity.split(' ').first,
              departureCode: _departureCity.contains('(') ? _departureCity.split('(').last.replaceAll(')', '') : 'ABJ',
              destinationCity: _destinationCity == 'Destination' ? 'Paris' : _destinationCity.split(' ').first,
              destinationCode: _destinationCity == 'Destination' ? 'CDG' : (_destinationCity.contains('(') ? _destinationCity.split('(').last.replaceAll(')', '') : 'CDG'),
              dateText: _dateText,
              onBackToHome: () => setState(() => _currentTab = 0),
            ),

            // Onglet 2 : Mes vols
            _buildMyFlightsTab(),

            // Onglet 3 : Profil
            _buildProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header supérieur : Logo VOYAGO + Avatar + Cloche
          SlideTransition(
            position: _headerSlide,
            child: FadeTransition(
              opacity: _headerFade,
              child: Row(
                children: [
                  Image.asset(
                    'assets/logo-avion-en-papier.png',
                    width: 30,
                    height: 30,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'VOYAGO',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF0F172A),
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.8,
                    ),
                  ),
                  const Spacer(),
                  // Avatar utilisateur par défaut (cliquable pour aller sur Profil)
                  GestureDetector(
                    onTap: () => setState(() => _currentTab = 3),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFBFDBFE), width: 1.5),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Color(0xFF2563EB),
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Cloche de notifications avec pastille bleue
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.notifications_none_rounded,
                          color: Color(0xFF0F172A),
                          size: 20,
                        ),
                        Positioned(
                          top: 7,
                          right: 8,
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2563EB),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 22),

          // 2. Message de salutation : "Bonjour Mouhamed,"
          SlideTransition(
            position: _greetingSlide,
            child: FadeTransition(
              opacity: _greetingFade,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                      children: const [
                        TextSpan(
                          text: 'Bonjour ',
                          style: TextStyle(color: Color(0xFF0F172A)),
                        ),
                        TextSpan(
                          text: 'Mouhamed,',
                          style: TextStyle(color: Color(0xFF2563EB)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Où souhaitez-vous aller aujourd\'hui ?',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF64748B),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 3. Carte de recherche de vols (blanche, coins arrondis, ombres douces)
          SlideTransition(
            position: _cardSlide,
            child: FadeTransition(
              opacity: _cardFade,
              child: Container(
                padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Ligne Départ
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.flight_takeoff_rounded,
                        color: Color(0xFF0F172A),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'De',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF64748B),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _departureCity,
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF0F172A),
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Bouton de permutation (Swap)
                    GestureDetector(
                      onTap: _onSwapCities,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Icon(
                          Icons.swap_vert_rounded,
                          color: Color(0xFF2563EB),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),

                // Ligne Destination
                GestureDetector(
                  onTap: _selectDestination,
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.flight_land_rounded,
                          color: Color(0xFF0F172A),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'À',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF64748B),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _destinationCity,
                              style: GoogleFonts.plusJakartaSans(
                                color: _destinationCity == 'Destination'
                                    ? const Color(0xFF94A3B8)
                                    : const Color(0xFF0F172A),
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),

                // Ligne Date de départ
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.calendar_today_rounded,
                        color: Color(0xFF0F172A),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date de départ',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF64748B),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _dateText,
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF0F172A),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 18),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),

                // Ligne Passagers
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_outline_rounded,
                        color: Color(0xFF0F172A),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Passagers',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF64748B),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _passengersText,
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF0F172A),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 18),
                  ],
                ),

                const SizedBox(height: 20),

                // Bouton "Rechercher un vol"
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _onSearchFlights(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Rechercher un vol',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
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

          const SizedBox(height: 28),

          // 4. Section "Destinations populaires" enrichie
          SlideTransition(
            position: _destSlide,
            child: FadeTransition(
              opacity: _destFade,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête de section avec compteur et lien "Voir tout"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Destinations populaires',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF0F172A),
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_filteredDestinations.length} destinations d\'exception',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF64748B),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => _onSearchFlights(destCity: 'Toutes', destCode: 'ALL'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'Voir tout',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFF2563EB),
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 3),
                              const Icon(Icons.arrow_forward_rounded, color: Color(0xFF2563EB), size: 13),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Filtres de catégories de voyage (scroll horizontal fluide)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    clipBehavior: Clip.none,
                    child: Row(
                      children: _destCategories.map((cat) {
                        final isSelected = cat == _selectedDestCategory;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedDestCategory = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              cat,
                              style: GoogleFonts.plusJakartaSans(
                                color: isSelected ? Colors.white : const Color(0xFF64748B),
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Carousel horizontal avec les 6 destinations
                  SizedBox(
                    height: 275,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      clipBehavior: Clip.none,
                      itemCount: _filteredDestinations.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final dest = _filteredDestinations[index];
                        return _buildDestinationCard(dest);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDestinationCard(PopularDestinationItem dest) {
    final isFav = _favoriteDestinations.contains(dest.id);

    return GestureDetector(
      onTap: () => _onSearchFlights(
        destCity: dest.title,
        destCode: dest.code,
      ),
      child: Container(
        width: 215,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image avec Badges flottants, Dégradé sombre et Bouton Cœur
            SizedBox(
              height: 140,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    dest.image,
                    fit: BoxFit.cover,
                  ),
                  // Dégradé sombre doux pour faire ressortir les badges
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.42),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.58),
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                  // Tag / Badge en haut à gauche
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.48),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                      ),
                      child: Text(
                        dest.tag,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                  // Bouton Cœur interactif en haut à droite
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _toggleFavorite(dest),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isFav ? const Color(0xFFEF4444) : Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (isFav ? const Color(0xFFEF4444) : Colors.black).withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: isFav ? Colors.white : const Color(0xFF0F172A),
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                  // Pastille durée de vol & code aéroport en bas à gauche
                  Positioned(
                    bottom: 8,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.flight_takeoff_rounded, color: Colors.white, size: 11),
                          const SizedBox(width: 4),
                          Text(
                            '${dest.duration} · ${dest.code}',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Contenu texte, notes, prix et bouton d'action
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          dest.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF0F172A),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 15, color: Color(0xFFF59E0B)),
                          const SizedBox(width: 2),
                          Text(
                            dest.rating.toString(),
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF0F172A),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            ' (${dest.reviews})',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF94A3B8),
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${dest.country} · ${dest.category}',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF64748B),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'À partir de',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF94A3B8),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                dest.price,
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFF2563EB),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                dest.originalPrice,
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFF94A3B8),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Color(0xFF2563EB),
                          size: 15,
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
    );
  }

  Widget _buildMyFlightsTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mes réservations',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flight_takeoff_rounded, color: Color(0xFF2563EB)),
                    const SizedBox(width: 8),
                    Text(
                      'Abidjan → Paris (AF 703)',
                      style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text('Confirmé', style: TextStyle(color: Color(0xFF059669), fontSize: 11, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Départ : Sam. 25 oct. 2025 à 22:10 (Aéroport Félix-Houphouët-Boigny)', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    final isGuest = AuthService.instance.isGuest;
    final email = AuthService.instance.userEmail;
    final name = AuthService.instance.userName.isNotEmpty ? AuthService.instance.userName : 'Mouhamed Dicko';

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Avatar par défaut
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFBFDBFE), width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Color(0xFF2563EB),
              size: 46,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            name,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          if (!isGuest && email.isNotEmpty) ...[
            Text(
              '$email · Membre Gold',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF64748B),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ] else ...[
            Container(
              margin: const EdgeInsets.only(top: 8),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
                label: Text(
                  'Créer un compte ou se connecter',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => LoginScreen(config: widget.config)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            leading: const Icon(Icons.card_membership_rounded, color: Color(0xFF2563EB)),
            title: const Text('Programme Fidélité Voyago', style: TextStyle(fontWeight: FontWeight.w700)),
            subtitle: const Text('42 500 Miles cumulés'),
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
          const SizedBox(height: 12),
          ListTile(
            tileColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            leading: const Icon(Icons.settings_outlined, color: Color(0xFF2563EB)),
            title: const Text('Préférences de voyage', style: TextStyle(fontWeight: FontWeight.w700)),
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
          if (!isGuest && email.isNotEmpty) ...[
            const SizedBox(height: 20),
            TextButton.icon(
              icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 18),
              label: Text(
                'Se déconnecter',
                style: GoogleFonts.plusJakartaSans(color: const Color(0xFFEF4444), fontWeight: FontWeight.w700),
              ),
              onPressed: () {
                AuthService.instance.logout();
                setState(() {});
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentTab,
        onTap: (index) {
          if (index == 1) {
            _onSearchFlights();
          } else {
            setState(() => _currentTab = index);
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF2563EB),
        unselectedItemColor: const Color(0xFF94A3B8),
        selectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 11),
        unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500, fontSize: 11),
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Rechercher',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number_outlined),
            label: 'Mes vols',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
