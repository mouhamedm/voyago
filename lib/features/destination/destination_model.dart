import 'package:flutter/material.dart';

class DestinationItem {
  final String id;
  final String title;
  final String location;
  final String country;
  final int price;
  final int durationDays;
  final double rating;
  final int reviewCount;
  final String flightTime;
  final String flightCode;
  final String description;
  final List<String> highlights;
  final List<String> included;
  final List<Map<String, String>> itinerary;
  final IconData icon;
  final List<Color> gradientColors;
  bool isFavorite;

  DestinationItem({
    required this.id,
    required this.title,
    required this.location,
    required this.country,
    required this.price,
    required this.durationDays,
    required this.rating,
    required this.reviewCount,
    required this.flightTime,
    required this.flightCode,
    required this.description,
    required this.highlights,
    required this.included,
    required this.itinerary,
    required this.icon,
    required this.gradientColors,
    this.isFavorite = false,
  });

  static List<DestinationItem> sampleDestinations = [
    DestinationItem(
      id: 'lisbon',
      title: 'Lisbonne au soleil',
      location: 'Portugal',
      country: 'Europe',
      price: 420,
      durationDays: 5,
      rating: 4.9,
      reviewCount: 312,
      flightTime: '2h 30m direct',
      flightCode: 'VG-104',
      description:
          'Plongez dans les ruelles pavées de l\'Alfama, admirez les façades d\'azulejos et savourez les pastéis de nata face à l\'estuaire du Tage.',
      highlights: [
        'Vol direct première classe avec champagne à bord',
        'Suite de charme 5 étoiles dans l\'Alfama',
        'Dégustation privée de vins de la vallée du Douro',
        'Croisière au coucher du soleil sur le Tage',
      ],
      included: [
        'Billet aller-retour flexible',
        'Hébergement 5 étoiles avec petit-déjeuner',
        'Transferts aéroport privés en berline électrique',
        'Conciergerie Voyago 24/7',
      ],
      itinerary: [
        {'jour': 'Jour 1', 'titre': 'Arrivée & Douceur de l\'Alfama', 'desc': 'Accueil VIP à l\'aéroport et installation dans votre suite.'},
        {'jour': 'Jour 2', 'titre': 'Miradouros & Histoire', 'desc': 'Balade avec guide privé dans les plus beaux points de vue de la ville.'},
        {'jour': 'Jour 3', 'titre': 'Sintra & Côte Atlantique', 'desc': 'Excursion privée vers les palais romantiques de Sintra et Cabo da Roca.'},
        {'jour': 'Jour 4', 'titre': 'Gastronomie & Fado', 'desc': 'Dîner gastronomique avec concert privé de Fado traditionnel.'},
        {'jour': 'Jour 5', 'titre': 'Derniers éclats & Retour', 'desc': 'Matinée shopping d\'artisanat et vol retour serein.'},
      ],
      icon: Icons.wb_sunny_rounded,
      gradientColors: [const Color(0xFFF59E0B), const Color(0xFFEF4444)],
      isFavorite: true,
    ),
    DestinationItem(
      id: 'fjords',
      title: 'Les fjords de Norvège',
      location: 'Norvège',
      country: 'Scandinavie',
      price: 980,
      durationDays: 7,
      rating: 4.95,
      reviewCount: 184,
      flightTime: '3h 15m direct',
      flightCode: 'VG-208',
      description:
          'Une odyssée majestueuse entre falaises vertigineuses, cascades cristallines et nuits étoilées au cœur d\'une nature boréale préservée.',
      highlights: [
        'Survol panoramique des fjords en hélicoptère',
        'Lodge scandinave éco-luxe avec sauna panoramique',
        'Navigation silencieuse en yacht hybride sur le Geirangerfjord',
        'Randonnée guidée sur les crêtes de Trolltunga',
      ],
      included: [
        'Vols directs aller-retour Voyago',
        'Tous les hébergements en écolodge 5*',
        'Tous les repas préparés par un chef local',
        'Équipements grand froid et guides experts',
      ],
      itinerary: [
        {'jour': 'Jour 1', 'titre': 'Bergen la porte des fjords', 'desc': 'Arrivée et découverte du quartier historique de Bryggen.'},
        {'jour': 'Jour 2-3', 'titre': 'Navigation sur le Geirangerfjord', 'desc': 'Croisière exclusive le long des cascades des Sept Sœurs.'},
        {'jour': 'Jour 4-5', 'titre': 'Lodge & Aurores boréales', 'desc': 'Bain nordique sous les étoiles et observation des aurores.'},
        {'jour': 'Jour 6', 'titre': 'Glacier de Jostedalsbreen', 'desc': 'Exploration glaciaire sécurisée avec crampons.'},
        {'jour': 'Jour 7', 'titre': 'Vol retour', 'desc': 'Retour en vol VIP vers votre destination.'},
      ],
      icon: Icons.waves_rounded,
      gradientColors: [const Color(0xFF0284C7), const Color(0xFF0F4C81)],
      isFavorite: true,
    ),
    DestinationItem(
      id: 'marrakech',
      title: 'Marrakech authentique',
      location: 'Maroc',
      country: 'Afrique',
      price: 310,
      durationDays: 4,
      rating: 4.88,
      reviewCount: 420,
      flightTime: '3h 10m direct',
      flightCode: 'VG-312',
      description:
          'Laissez-vous envoûter par les parfums de jasmin, la splendeur des riads secrets et la magie intemporelle de la place Jemaa el-Fna.',
      highlights: [
        'Riad privatisé au cœur de la Médina avec patio et piscine',
        'Accès privé au Jardin Majorelle avant l\'ouverture au public',
        'Dîner sous les tentes nomades du désert d\'Agafay',
        'Soin spa traditionnel et hammam aux huiles d\'argan',
      ],
      included: [
        'Vols Voyago avec franchise bagages offerte',
        'Hébergement en suite de riad avec petit-déjeuner marocain',
        'Chauffeur privé dédié pour l\'ensemble du séjour',
        'Accompagnateur culturel francophone',
      ],
      itinerary: [
        {'jour': 'Jour 1', 'titre': 'Accueil oriental', 'desc': 'Thé à la menthe de bienvenue et installation au Riad.'},
        {'jour': 'Jour 2', 'titre': 'Jardins & Palais', 'desc': 'Palais de la Bahia, tombeaux Saadiens et Jardin Majorelle.'},
        {'jour': 'Jour 3', 'titre': 'Magie d\'Agafay', 'desc': 'Coucher de soleil dans les dunes de pierre et dîner étoilé.'},
        {'jour': 'Jour 4', 'titre': 'Souks & Départ', 'desc': 'Derniers achats d\'épices et transfert VIP retour.'},
      ],
      icon: Icons.nightlight_round,
      gradientColors: [const Color(0xFFEA580C), const Color(0xFFD97706)],
      isFavorite: false,
    ),
    DestinationItem(
      id: 'kyoto',
      title: 'Kyoto en fleurs',
      location: 'Japon',
      country: 'Asie',
      price: 1450,
      durationDays: 9,
      rating: 4.98,
      reviewCount: 260,
      flightTime: '12h 40m direct',
      flightCode: 'VG-707',
      description:
          'Un voyage hors du temps sous les cerisiers en fleurs, entre temples millénaires, jardins zen et sérénité absolue.',
      highlights: [
        'Vol long-courrier Voyago First Suite avec lit plat',
        'Séjour en Ryokan d\'exception avec Onsen thermal privé',
        'Cérémonie du thé authentique avec un grand maître',
        'Promenade matinale privée dans la forêt de bambous d\'Arashiyama',
      ],
      included: [
        'Billets Première Classe Voyago A/R',
        'Hébergements traditionnels de grand luxe',
        'Pass Shinkansen première classe inclus',
        'Assistance locale Voyago bilingue permanente',
      ],
      itinerary: [
        {'jour': 'Jour 1', 'titre': 'Envol vers le Soleil Levant', 'desc': 'Expérience de vol signature Voyago.'},
        {'jour': 'Jour 2-3', 'titre': 'Temples dorés & Pavillon d\'Argent', 'desc': 'Kinkaku-ji et promenades le long du chemin de la philosophie.'},
        {'jour': 'Jour 4-5', 'titre': 'Arashiyama & Jardins Zen', 'desc': 'Méditation zen et bambouseraie.'},
        {'jour': 'Jour 6-7', 'titre': 'Geishas & Quartier de Gion', 'desc': 'Dîner Kaiseki raffiné et découverte nocturne de Gion.'},
        {'jour': 'Jour 8', 'titre': 'Fushimi Inari au lever du jour', 'desc': 'Les milliers de Torii rouges sans la foule.'},
        {'jour': 'Jour 9', 'titre': 'Retour serein', 'desc': 'Vol retour avec service gastronomique.'},
      ],
      icon: Icons.park_rounded,
      gradientColors: [const Color(0xFFEC4899), const Color(0xFF8B5CF6)],
      isFavorite: false,
    ),
  ];
}
