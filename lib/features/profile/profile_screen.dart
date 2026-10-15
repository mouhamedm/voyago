import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme_config.dart';
import '../auth/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  final ThemeConfig config;
  final VoidCallback onLogout;

  const ProfileScreen({
    super.key,
    required this.config,
    required this.onLogout,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  bool _carbonOffset = true;
  String _selectedCurrency = 'EUR (€)';

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            'Se déconnecter',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
          ),
          content: const Text(
            'Êtes-vous sûr de vouloir vous déconnecter de votre compte Voyago ?',
            style: TextStyle(color: Color(0xFF475569)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                await AuthService.instance.logout();
                widget.onLogout();
              },
              child: const Text('Déconnexion', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final config = widget.config;
    final userName = AuthService.instance.userName;
    final userEmail = AuthService.instance.userEmail;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
        children: [
          // Titre de section
          Text(
            'Votre Compte VIP',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: config.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 18),

          // Carte Profil
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [config.accent, const Color(0xFF1E3A8A)],
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: config.accent.withValues(alpha: 0.25),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Text(
                        userName.isNotEmpty ? userName[0] : 'A',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: config.accent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            userEmail,
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '✦ VOYAGO BLACK TIER',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 16),
                // Solde de Miles
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Solde Miles Privilège', style: TextStyle(color: Colors.white70, fontSize: 13)),
                    Text(
                      '48 250 Miles',
                      style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Statistiques rapides
          Row(
            children: [
              _statCard('18', 'Vols effectués', Icons.flight_takeoff_rounded, config),
              const SizedBox(width: 12),
              _statCard('12', 'Pays visités', Icons.public_rounded, config),
              const SizedBox(width: 12),
              _statCard('4.9★', 'Note Passager', Icons.verified_rounded, config),
            ],
          ),
          const SizedBox(height: 24),

          // Carte d'embarquement à venir
          const Text(
            'Prochain départ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(18),
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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PARIS (CDG)', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w800)),
                        const Text('14 Nov · 10:45', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                      ],
                    ),
                    Icon(Icons.flight_takeoff_rounded, color: config.secondary, size: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('LISBONNE (LIS)', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w800)),
                        const Text('14 Nov · 12:15', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    _InfoBadge('VOL', 'VG-104'),
                    _InfoBadge('SIÈGE', '01A'),
                    _InfoBadge('PORTE', 'B22'),
                    _InfoBadge('CLASSE', 'First'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Préférences & Réglages
          const Text(
            'Préférences',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
          ),
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0x180F4C81), width: 1.2),
              ),
              child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Notifications de vol & alertes prix', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Alertes en temps réel sur les réservations', style: TextStyle(fontSize: 12)),
                  activeThumbColor: config.accent,
                  value: _notificationsEnabled,
                  onChanged: (val) => setState(() => _notificationsEnabled = val),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                SwitchListTile(
                  title: const Text('Compensation Carbone Voyago', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Contribution automatique à chaque vol', style: TextStyle(fontSize: 12)),
                  activeThumbColor: const Color(0xFF10B981),
                  value: _carbonOffset,
                  onChanged: (val) => setState(() => _carbonOffset = val),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.currency_exchange_rounded),
                  title: const Text('Devise d\'affichage', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  trailing: DropdownButton<String>(
                    value: _selectedCurrency,
                    underline: const SizedBox(),
                    items: ['EUR (€)', 'USD (\$)'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedCurrency = val);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

          // Bouton Déconnexion
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFEF2F2),
              foregroundColor: const Color(0xFFDC2626),
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFFCA5A5)),
              ),
            ),
            icon: const Icon(Icons.logout_rounded, size: 20),
            label: const Text(
              'Se déconnecter',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            onPressed: _confirmLogout,
          ),
        ],
      ),
    );
  }

  Widget _statCard(String value, String label, IconData icon, ThemeConfig config) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0x180F4C81)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F4C81).withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: config.secondary),
            const SizedBox(height: 6),
            Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w800, color: config.textPrimary)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final String label;
  final String value;
  const _InfoBadge(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
      ],
    );
  }
}
