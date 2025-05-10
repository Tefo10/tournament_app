class Sport {
  final String name;
  final String icon;
  final int playersPerTeam;
  final String description;

  const Sport({
    required this.name,
    required this.icon,
    required this.playersPerTeam,
    required this.description,
  });
}

class SportsData {
  static const List<Sport> popularSports = [
    Sport(
      name: 'Fútbol',
      icon: '⚽',
      playersPerTeam: 11,
      description: 'El deporte más popular del mundo',
    ),
    Sport(
      name: 'Baloncesto',
      icon: '🏀',
      playersPerTeam: 5,
      description: 'Deporte de alta intensidad y precisión',
    ),
    Sport(
      name: 'Voleibol',
      icon: '🏐',
      playersPerTeam: 6,
      description: 'Deporte de equipo dinámico',
    ),
    Sport(
      name: 'Rugby',
      icon: '🏉',
      playersPerTeam: 15,
      description: 'Deporte de contacto y estrategia',
    ),
    Sport(
      name: 'Hockey',
      icon: '🏑',
      playersPerTeam: 6,
      description: 'Deporte de velocidad y habilidad',
    ),
    Sport(
      name: 'Béisbol',
      icon: '⚾',
      playersPerTeam: 9,
      description: 'El pasatiempo americano',
    ),
  ];
}
