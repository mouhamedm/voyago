import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme_config.dart';
import '../../shared/widgets/animated_button.dart';
import '../auth/auth_service.dart';
import 'flight_model.dart';

/// Écran 3 : Résultats de vols ("Abidjan → Paris")
/// Fidèle à la troisième capture d'écran avec filtres interactifs et bottom navigation préservée :
/// - AppBar : <  Abidjan → Paris (Sam. 25 oct. 2025 · 1 adulte)  [Tune]
/// - Bandeau de dates horizontal : Jeu 23, Ven 24, Sam 25 (Sélectionné en bleu), Dim 26, Lun 27
/// - Filtres interactifs avec menus déroulants : Trier, Escales, Compagnies
/// - Cartes de vols détaillées avec sheet de réservation sans aucun débordement (overflow-free)
class FlightResultsScreen extends StatefulWidget {
  final ThemeConfig config;
  final String departureCity;
  final String departureCode;
  final String destinationCity;
  final String destinationCode;
  final String dateText;
  final VoidCallback? onBackToHome;

  const FlightResultsScreen({
    super.key,
    required this.config,
    this.departureCity = 'Abidjan',
    this.departureCode = 'ABJ',
    this.destinationCity = 'Paris',
    this.destinationCode = 'CDG',
    this.dateText = 'Sam. 25 oct. 2025',
    this.onBackToHome,
  });

  @override
  State<FlightResultsScreen> createState() => _FlightResultsScreenState();
}

class _FlightResultsScreenState extends State<FlightResultsScreen> {
  int _selectedDateIndex = 2; // Sam. 25
  String _selectedSort = 'Prix le plus bas';
  String _selectedStops = 'Tous';
  String _selectedAirline = 'Toutes';

  final List<Map<String, dynamic>> _dateItems = [
    {'day': 'Jeu', 'date': '23', 'price': '420 €'},
    {'day': 'Ven', 'date': '24', 'price': '398 €'},
    {'day': 'Sam', 'date': '25', 'price': '376 €'},
    {'day': 'Dim', 'date': '26', 'price': '412 €'},
    {'day': 'Lun', 'date': '27', 'price': '425 €'},
  ];

  List<FlightTicket> get _filteredFlights {
    var list = List<FlightTicket>.from(FlightTicket.sampleFlights);

    // Filtre compagnies
    if (_selectedAirline != 'Toutes') {
      list = list.where((f) => f.airline.toLowerCase().contains(_selectedAirline.toLowerCase())).toList();
    }

    // Filtre escales
    if (_selectedStops == 'Direct uniquement') {
      list = list.where((f) => f.stops.toLowerCase().contains('direct')).toList();
    } else if (_selectedStops == '1 escale max') {
      list = list.where((f) => f.stops.toLowerCase().contains('direct') || f.stops.toLowerCase().contains('1 escale')).toList();
    }

    // Tri
    if (_selectedSort == 'Prix le plus bas') {
      list.sort((a, b) => a.price.compareTo(b.price));
    } else if (_selectedSort == 'Durée la plus courte') {
      list.sort((a, b) => a.duration.compareTo(b.duration));
    } else if (_selectedSort == 'Départ le plus tôt') {
      list.sort((a, b) => a.departureTime.compareTo(b.departureTime));
    }

    return list;
  }

  void _showSortModal() {
    _showSelectionSheet(
      title: 'Trier les vols',
      currentValue: _selectedSort,
      options: const [
        'Prix le plus bas',
        'Durée la plus courte',
        'Départ le plus tôt',
      ],
      onSelect: (val) => setState(() => _selectedSort = val),
    );
  }

  void _showStopsModal() {
    _showSelectionSheet(
      title: 'Nombre d\'escales',
      currentValue: _selectedStops,
      options: const [
        'Tous',
        'Direct uniquement',
        '1 escale max',
      ],
      onSelect: (val) => setState(() => _selectedStops = val),
    );
  }

  void _showAirlinesModal() {
    _showSelectionSheet(
      title: 'Compagnies aériennes',
      currentValue: _selectedAirline,
      options: const [
        'Toutes',
        'AIRFRANCE',
        'Royal Air Maroc',
        'Lufthansa',
        'Emirates',
      ],
      onSelect: (val) => setState(() => _selectedAirline = val),
    );
  }

  void _showSelectionSheet({
    required String title,
    required String currentValue,
    required List<String> options,
    required ValueChanged<String> onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              ...options.map((opt) {
                final isSel = opt.toLowerCase() == currentValue.toLowerCase();
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                  title: Text(
                    opt,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                      color: isSel ? const Color(0xFF2563EB) : const Color(0xFF0F172A),
                    ),
                  ),
                  trailing: isSel
                      ? const Icon(Icons.check_circle_rounded, color: Color(0xFF2563EB), size: 22)
                      : const Icon(Icons.radio_button_unchecked_rounded, color: Color(0xFFCBD5E1), size: 22),
                  onTap: () {
                    onSelect(opt);
                    Navigator.pop(ctx);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showBookingSheet(FlightTicket flight) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _FlightBookingDetailSheet(flight: flight, config: widget.config),
    );
  }

  @override
  Widget build(BuildContext context) {
    final flights = _filteredFlights;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 18),
          onPressed: () {
            if (widget.onBackToHome != null) {
              widget.onBackToHome!();
            } else if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
          },
        ),
        centerTitle: true,
        title: Column(
          children: [
            Text(
              '${widget.departureCity} → ${widget.destinationCity}',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF0F172A),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${widget.dateText} · 1 adulte',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF64748B),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.tune_rounded, color: Color(0xFF0F172A), size: 20),
              onPressed: () {
                _showSortModal();
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Bandeau horizontal des dates avec prix
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_dateItems.length, (index) {
                final item = _dateItems[index];
                final isSelected = index == _selectedDateIndex;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDateIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                        width: 1.2,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${item['day']} ${item['date']}',
                          style: GoogleFonts.plusJakartaSans(
                            color: isSelected ? Colors.white : const Color(0xFF0F172A),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item['price'] as String,
                          style: GoogleFonts.plusJakartaSans(
                            color: isSelected ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF64748B),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          // 2. Filtres rapides interactifs : Trier, Escales, Compagnies
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    label: _selectedSort == 'Prix le plus bas' ? 'Trier' : _selectedSort,
                    isActive: _selectedSort != 'Prix le plus bas',
                    onTap: _showSortModal,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: _selectedStops == 'Tous' ? 'Escales' : _selectedStops,
                    isActive: _selectedStops != 'Tous',
                    onTap: _showStopsModal,
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    label: _selectedAirline == 'Toutes' ? 'Compagnies' : _selectedAirline,
                    isActive: _selectedAirline != 'Toutes',
                    onTap: _showAirlinesModal,
                  ),
                  if (_selectedSort != 'Prix le plus bas' || _selectedStops != 'Tous' || _selectedAirline != 'Toutes') ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedSort = 'Prix le plus bas';
                          _selectedStops = 'Tous';
                          _selectedAirline = 'Toutes';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, size: 14, color: Color(0xFF64748B)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 3. Liste des vols disponibles
          Expanded(
            child: flights.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.flight_takeoff_rounded, size: 48, color: Color(0xFF94A3B8)),
                        const SizedBox(height: 12),
                        Text(
                          'Aucun vol ne correspond à vos filtres',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF0F172A),
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedSort = 'Prix le plus bas';
                              _selectedStops = 'Tous';
                              _selectedAirline = 'Toutes';
                            });
                          },
                          child: const Text('Réinitialiser les filtres'),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: flights.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final flight = flights[index];
                      return _buildFlightCard(flight);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: isActive ? const Color(0xFF2563EB) : const Color(0xFF0F172A),
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: isActive ? const Color(0xFF2563EB) : const Color(0xFF64748B),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlightCard(FlightTicket flight) {
    return GestureDetector(
      onTap: () => _showBookingSheet(flight),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: flight.isBestChoice ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0),
            width: flight.isBestChoice ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: flight.isBestChoice ? 0.08 : 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Ligne supérieure : Logo/Nom de compagnie + Tag "Meilleur choix" + Prix
            Row(
              children: [
                _buildAirlineLogo(flight.airlineCode, flight.airline),
                const SizedBox(width: 10),
                Text(
                  flight.airline,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF0F172A),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (flight.isBestChoice) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Text(
                      'Meilleur choix',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF2563EB),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  '${flight.price} €',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF2563EB),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Ligne horaire et trajet : Départ -> Ligne pointillée -> Arrivée
            Row(
              children: [
                // Départ
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flight.departureTime,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF0F172A),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      flight.departureCode,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF64748B),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                // Trajet au centre : Durée + Escales + Ligne avec avion
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Text(
                          flight.duration,
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF64748B),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 1.5,
                              color: const Color(0xFFCBD5E1),
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.flight_rounded,
                                size: 14,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          flight.stops,
                          style: GoogleFonts.plusJakartaSans(
                            color: flight.stops.toLowerCase().contains('direct')
                                ? const Color(0xFF059669)
                                : const Color(0xFFD97706),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Arrivée
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      flight.arrivalTime,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF0F172A),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      flight.arrivalCode,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF64748B),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAirlineLogo(String code, String airline) {
    Color bg = const Color(0xFFF1F5F9);
    Color text = const Color(0xFF0F172A);

    if (code == 'AF') {
      bg = const Color(0xFF002157);
      text = Colors.white;
    } else if (code == 'RAM') {
      bg = const Color(0xFF990000);
      text = Colors.white;
    } else if (code == 'LH') {
      bg = const Color(0xFF05164D);
      text = const Color(0xFFFFB612);
    } else if (code == 'EK') {
      bg = const Color(0xFFD71920);
      text = Colors.white;
    }

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        code,
        style: GoogleFonts.plusJakartaSans(
          color: text,
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Feuille modale détaillée pour la confirmation d'un vol
/// 100% sans overflow (SingleChildScrollView + SafeArea + text wrapping)
class _FlightBookingDetailSheet extends StatefulWidget {
  final FlightTicket flight;
  final ThemeConfig config;

  const _FlightBookingDetailSheet({required this.flight, required this.config});

  @override
  State<_FlightBookingDetailSheet> createState() => _FlightBookingDetailSheetState();
}

class _FlightBookingDetailSheetState extends State<_FlightBookingDetailSheet> {
  final _bookingButtonKey = GlobalKey<PillActionButtonState>();
  bool _isProcessing = false;

  Future<void> _handleBooking() async {
    if (_isProcessing) return;
    _isProcessing = true;

    // 1. Déclenchement instantané de la contraction en cercle et du spinner blanc
    await _bookingButtonKey.currentState?.collapse(withLoader: true);

    // Bref temps de réflexion (1,2s)
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    // 2. Transformation en V de succès (coche verte animée)
    await _bookingButtonKey.currentState?.playSuccess();
    if (!mounted) return;

    // Bref délai pour apprécier le V avant de fermer la feuille
    await Future.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Réservation confirmée pour ${widget.flight.departureCode} → ${widget.flight.arrivalCode} !',
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

  @override
  Widget build(BuildContext context) {
    final flight = widget.flight;
    final userName = AuthService.instance.userName.isNotEmpty ? AuthService.instance.userName : 'Mouhamed Dicko';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    flight.airline,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${flight.price} €',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Vol ${flight.flightNumber} · Classe Économique Standard',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF64748B),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Itinéraire', '${flight.departureCode} → ${flight.arrivalCode} (${flight.stops})'),
                    const Divider(height: 20, color: Color(0xFFE2E8F0)),
                    _buildInfoRow('Horaires', '${flight.departureTime} - ${flight.arrivalTime} (${flight.duration})'),
                    const Divider(height: 20, color: Color(0xFFE2E8F0)),
                    _buildInfoRow('Bagages', '1 bagage cabine (12 kg) + 1 accessoire inclus'),
                    const Divider(height: 20, color: Color(0xFFE2E8F0)),
                    _buildInfoRow('Passager', userName),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: PillActionButton(
                  key: _bookingButtonKey,
                  label: 'Confirmer et Réserver (${flight.price} €)',
                  accent: const Color(0xFF2563EB),
                  width: MediaQuery.of(context).size.width - 48,
                  height: 54,
                  showArrow: true,
                  onPressed: _handleBooking,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF64748B),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF0F172A),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
