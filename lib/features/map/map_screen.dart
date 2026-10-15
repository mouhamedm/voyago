import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme_config.dart';
import '../destination/destination_detail_screen.dart';
import '../destination/destination_model.dart';

class MapScreen extends StatefulWidget {
  final ThemeConfig config;

  const MapScreen({super.key, required this.config});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  int _selectedAirportIndex = 0;

  final List<Map<String, dynamic>> _airports = [
    {'name': 'Lisbonne (LIS)', 'x': 0.28, 'y': 0.52, 'temp': '24°C', 'status': 'Ensoleillé', 'destId': 'lisbon'},
    {'name': 'Oslo (OSL)', 'x': 0.54, 'y': 0.22, 'temp': '12°C', 'status': 'Ciel clair', 'destId': 'fjords'},
    {'name': 'Marrakech (RAK)', 'x': 0.32, 'y': 0.76, 'temp': '29°C', 'status': 'Chaud', 'destId': 'marrakech'},
    {'name': 'Kyoto (KIX)', 'x': 0.82, 'y': 0.46, 'temp': '19°C', 'status': 'Brise douce', 'destId': 'kyoto'},
    {'name': 'Paris Hub (CDG)', 'x': 0.44, 'y': 0.42, 'temp': '18°C', 'status': 'Hub Principal', 'destId': 'lisbon'},
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final selectedAirport = _airports[_selectedAirportIndex];
    final selectedDest = DestinationItem.sampleDestinations.firstWhere(
      (d) => d.id == selectedAirport['destId'],
      orElse: () => DestinationItem.sampleDestinations.first,
    );

    return SafeArea(
      child: Stack(
        children: [
          // En-tête Carte
          Positioned(
            top: 16,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Radar Aérien Voyago',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: config.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Réseau mondial en direct · 4 hubs actifs',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0x180F4C81)),
                    boxShadow: [
                      BoxShadow(color: const Color(0xFF0F4C81).withValues(alpha: 0.08), blurRadius: 12),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.layers_rounded, size: 16, color: config.accent),
                      const SizedBox(width: 4),
                      Text('Lignes VIP', style: TextStyle(color: config.accent, fontWeight: FontWeight.w700, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Zone Carte Interactive avec Canvas des Routes Aériennes
          Positioned.fill(
            top: 76,
            bottom: 160,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final h = constraints.maxHeight;

                return Stack(
                  children: [
                    // Toile de fond avec grille radar
                    Container(
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9).withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: const Color(0x180F4C81), width: 1.2),
                      ),
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, _) {
                          return CustomPaint(
                            size: Size(w, h),
                            painter: _FlightRoutesPainter(
                              airports: _airports,
                              progress: _pulseController.value,
                              selectedIndex: _selectedAirportIndex,
                              accent: config.accent,
                              secondary: config.secondary,
                            ),
                          );
                        },
                      ),
                    ),

                    // Pins des aéroports
                    ...List.generate(_airports.length, (i) {
                      final apt = _airports[i];
                      final isSelected = _selectedAirportIndex == i;
                      final isHub = i == 4;

                      return Positioned(
                        left: apt['x'] * (w - 32),
                        top: apt['y'] * (h - 32),
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedAirportIndex = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: EdgeInsets.all(isSelected ? 10 : 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? config.accent
                                  : (isHub ? config.secondary : Colors.white),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.white : config.accent,
                                width: isSelected ? 2.5 : 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: (isSelected ? config.accent : Colors.black).withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.flight_takeoff_rounded,
                              size: isSelected ? 18 : 14,
                              color: isSelected || isHub ? Colors.white : config.accent,
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
          ),

          // Fiche Escale Active en bas
          Positioned(
            left: 20,
            right: 20,
            bottom: 95,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0x180F4C81), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F4C81).withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: selectedDest.gradientColors),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(selectedDest.icon, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          selectedAirport['name'],
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: config.textPrimary,
                          ),
                        ),
                        Text(
                          'Météo : ${selectedAirport['temp']} · ${selectedAirport['status']}',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: config.accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DestinationDetailScreen(item: selectedDest, config: config),
                        ),
                      );
                    },
                    child: const Text('Voir l\'escale', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlightRoutesPainter extends CustomPainter {
  final List<Map<String, dynamic>> airports;
  final double progress;
  final int selectedIndex;
  final Color accent;
  final Color secondary;

  _FlightRoutesPainter({
    required this.airports,
    required this.progress,
    required this.selectedIndex,
    required this.accent,
    required this.secondary,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final hub = Offset(airports[4]['x'] * (size.width - 32) + 16, airports[4]['y'] * (size.height - 32) + 16);

    for (var i = 0; i < 4; i++) {
      final target = Offset(airports[i]['x'] * (size.width - 32) + 16, airports[i]['y'] * (size.height - 32) + 16);
      final isSelected = selectedIndex == i;

      // Arc de vol incurvé
      final path = Path()..moveTo(hub.dx, hub.dy);
      final controlPoint = Offset(
        (hub.dx + target.dx) / 2 - (target.dy - hub.dy) * 0.25,
        (hub.dy + target.dy) / 2 - (target.dx - hub.dx) * 0.25,
      );
      path.quadraticBezierTo(controlPoint.dx, controlPoint.dy, target.dx, target.dy);

      final routePaint = Paint()
        ..color = isSelected ? accent : const Color(0xFF94A3B8).withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 2.5 : 1.2;

      canvas.drawPath(path, routePaint);

      // Avion animé le long du chemin
      final metrics = path.computeMetrics().first;
      final tangent = metrics.getTangentForOffset((progress * metrics.length) % metrics.length);
      if (tangent != null && isSelected) {
        final planePaint = Paint()..color = secondary;
        canvas.drawCircle(tangent.position, 4, planePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FlightRoutesPainter oldDelegate) => true;
}
