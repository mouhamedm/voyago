import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme_config.dart';
import 'flight_model.dart';

/// Écran 3 : Résultats de vols ("Abidjan → Paris")
/// Fidèle à la troisième capture d'écran :
/// - AppBar : <  Abidjan → Paris (Sam. 25 oct. 2025 · 1 adulte)  [Tune]
/// - Bandeau de dates horizontal : Jeu 23, Ven 24, Sam 25 (Sélectionné en bleu), Dim 26, Lun 27
/// - Filtres : Trier v, Escales v, Compagnies v
/// - Cartes de vols détaillées : AIRFRANCE, Royal Air Maroc, Lufthansa, Emirates
class FlightResultsScreen extends StatefulWidget {
  final ThemeConfig config;
  final String departureCity;
  final String departureCode;
  final String destinationCity;
  final String destinationCode;
  final String dateText;

  const FlightResultsScreen({
    super.key,
    required this.config,
    this.departureCity = 'Abidjan',
    this.departureCode = 'ABJ',
    this.destinationCity = 'Paris',
    this.destinationCode = 'CDG',
    this.dateText = 'Sam. 25 oct. 2025',
  });

  @override
  State<FlightResultsScreen> createState() => _FlightResultsScreenState();
}

class _FlightResultsScreenState extends State<FlightResultsScreen> {
  int _selectedDateIndex = 2; // Sam. 25

  final List<Map<String, dynamic>> _dateItems = [
    {'day': 'Jeu', 'date': '23', 'price': '420 €'},
    {'day': 'Ven', 'date': '24', 'price': '398 €'},
    {'day': 'Sam', 'date': '25', 'price': '376 €'},
    {'day': 'Dim', 'date': '26', 'price': '412 €'},
    {'day': 'Lun', 'date': '27', 'price': '425 €'},
  ];

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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 18),
          onPressed: () => Navigator.of(context).pop(),
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
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.tune_rounded, color: Color(0xFF0F172A), size: 20),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Filtres avancés : durée maximale, horaires, alliances.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
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
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_dateItems.length, (index) {
                final item = _dateItems[index];
                final isSelected = _selectedDateIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDateIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: (MediaQuery.of(context).size.width - 32 - 32) / 5,
                    padding: const EdgeInsets.symmetric(vertical: 10),
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

          // 2. Filtres rapides : Trier, Escales, Compagnies
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Row(
              children: [
                _buildFilterChip('Trier', Icons.keyboard_arrow_down_rounded),
                const SizedBox(width: 8),
                _buildFilterChip('Escales', Icons.keyboard_arrow_down_rounded),
                const SizedBox(width: 8),
                _buildFilterChip('Compagnies', Icons.keyboard_arrow_down_rounded),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 3. Liste des vols disponibles
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: FlightTicket.sampleFlights.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final flight = FlightTicket.sampleFlights[index];
                return _buildFlightCard(flight);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF0F172A),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          Icon(icon, color: const Color(0xFF64748B), size: 16),
        ],
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
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ligne 1 : Logo compagnie & Badge meilleur choix
            Row(
              children: [
                _buildAirlineLogo(flight.airline),
                const SizedBox(width: 8),
                Text(
                  flight.airline,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF0F172A),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                if (flight.isBestChoice)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
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
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 18),
              ],
            ),
            const SizedBox(height: 16),

            // Ligne 2 : Horaires, durée et prix
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Heure départ
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      flight.departureTime,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF0F172A),
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      flight.departureCode,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 14),

                // Ligne de vol avec durée
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        flight.duration,
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF94A3B8),
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 1.5,
                              color: const Color(0xFFCBD5E1),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(Icons.flight_rounded, color: Color(0xFF2563EB), size: 16),
                          ),
                          Expanded(
                            child: Container(
                              height: 1.5,
                              color: const Color(0xFFCBD5E1),
                            ),
                          ),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF94A3B8),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        flight.stops,
                        style: GoogleFonts.plusJakartaSans(
                          color: flight.stops == 'Direct'
                              ? const Color(0xFF059669)
                              : const Color(0xFF64748B),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 14),

                // Heure arrivée
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          flight.arrivalTime,
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFF0F172A),
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (flight.isNextDay)
                          Padding(
                            padding: const EdgeInsets.only(left: 2),
                            child: Text(
                              '+1',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF2563EB),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      flight.arrivalCode,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 20),

                // Prix
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${flight.price} €',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF0F172A),
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'A/R',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF94A3B8),
                        fontSize: 11,
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

  Widget _buildAirlineLogo(String airline) {
    if (airline.contains('AIRFRANCE')) {
      return Container(
        width: 22,
        height: 18,
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Center(
          child: Icon(Icons.flight, color: Colors.white, size: 12),
        ),
      );
    } else if (airline.contains('Royal')) {
      return Container(
        width: 22,
        height: 18,
        decoration: BoxDecoration(
          color: const Color(0xFFDC2626),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Center(
          child: Icon(Icons.star, color: Colors.white, size: 12),
        ),
      );
    } else if (airline.contains('Lufthansa')) {
      return Container(
        width: 22,
        height: 18,
        decoration: BoxDecoration(
          color: const Color(0xFF032B69),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Center(
          child: Icon(Icons.circle, color: Color(0xFFFDB913), size: 10),
        ),
      );
    } else {
      return Container(
        width: 22,
        height: 18,
        decoration: BoxDecoration(
          color: const Color(0xFFB91C1C),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Center(
          child: Icon(Icons.flight_takeoff, color: Colors.white, size: 12),
        ),
      );
    }
  }
}

class _FlightBookingDetailSheet extends StatefulWidget {
  final FlightTicket flight;
  final ThemeConfig config;

  const _FlightBookingDetailSheet({required this.flight, required this.config});

  @override
  State<_FlightBookingDetailSheet> createState() => _FlightBookingDetailSheetState();
}

class _FlightBookingDetailSheetState extends State<_FlightBookingDetailSheet> {
  bool _booked = false;

  @override
  Widget build(BuildContext context) {
    final flight = widget.flight;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(10),
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
                _buildInfoRow('Passager principal', 'Mouhamed Dicko'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _booked
                  ? null
                  : () {
                      setState(() => _booked = true);
                      Future.delayed(const Duration(milliseconds: 700), () {
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF059669),
                            content: Text(
                              'Réservation confirmée pour ${flight.departureCode} → ${flight.arrivalCode} !',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      });
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 4,
              ),
              child: _booked
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : Text(
                      'Confirmer et Réserver (${flight.price} €)',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF64748B),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF0F172A),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
