class FlightTicket {
  final String id;
  final String airline;
  final String airlineCode;
  final String departureTime;
  final String arrivalTime;
  final String departureCode;
  final String arrivalCode;
  final String duration;
  final String stops;
  final int price;
  final bool isRoundTrip;
  final bool isBestChoice;
  final bool isNextDay;
  final String flightNumber;

  const FlightTicket({
    required this.id,
    required this.airline,
    required this.airlineCode,
    required this.departureTime,
    required this.arrivalTime,
    required this.departureCode,
    required this.arrivalCode,
    required this.duration,
    required this.stops,
    required this.price,
    this.isRoundTrip = true,
    this.isBestChoice = false,
    this.isNextDay = true,
    required this.flightNumber,
  });

  static const List<FlightTicket> sampleFlights = [
    FlightTicket(
      id: 'af703',
      airline: 'AIRFRANCE',
      airlineCode: 'AF',
      departureTime: '22:10',
      arrivalTime: '06:55',
      departureCode: 'ABJ',
      arrivalCode: 'CDG',
      duration: '7h 45',
      stops: 'Direct',
      price: 376,
      isBestChoice: true,
      flightNumber: 'AF 703',
    ),
    FlightTicket(
      id: 'ram554',
      airline: 'Royal Air Maroc',
      airlineCode: 'AT',
      departureTime: '13:25',
      arrivalTime: '07:55',
      departureCode: 'ABJ',
      arrivalCode: 'CDG',
      duration: '9h 30',
      stops: '1 escale (CMN)',
      price: 428,
      flightNumber: 'AT 554',
    ),
    FlightTicket(
      id: 'lh569',
      airline: 'Lufthansa',
      airlineCode: 'LH',
      departureTime: '18:40',
      arrivalTime: '10:00',
      departureCode: 'ABJ',
      arrivalCode: 'CDG',
      duration: '11h 20',
      stops: '1 escale (FRA)',
      price: 512,
      flightNumber: 'LH 569',
    ),
    FlightTicket(
      id: 'ek788',
      airline: 'Emirates',
      airlineCode: 'EK',
      departureTime: '01:15',
      arrivalTime: '15:25',
      departureCode: 'ABJ',
      arrivalCode: 'CDG',
      duration: '14h 10',
      stops: '1 escale (DXB)',
      price: 587,
      flightNumber: 'EK 788',
    ),
  ];
}
