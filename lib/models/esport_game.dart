class EsportGame {
  final String name;
  final String icon;
  final int playersPerTeam;
  final String description;
  final List<String> popularTournaments;

  const EsportGame({
    required this.name,
    required this.icon,
    required this.playersPerTeam,
    required this.description,
    required this.popularTournaments,
  });
}

class EsportsData {
  static const List<EsportGame> popularGames = [
    EsportGame(
      name: 'League of Legends',
      icon: '🎮',
      playersPerTeam: 5,
      description: 'MOBA estratégico 5v5',
      popularTournaments: ['Worlds', 'MSI', 'LCS', 'LEC', 'LLA'],
    ),
    EsportGame(
      name: 'CS:GO',
      icon: '🎯',
      playersPerTeam: 5,
      description: 'FPS táctico 5v5',
      popularTournaments: [
        'Major Championships',
        'ESL Pro League',
        'BLAST Premier'
      ],
    ),
    EsportGame(
      name: 'Dota 2',
      icon: '⚔️',
      playersPerTeam: 5,
      description: 'MOBA complejo 5v5',
      popularTournaments: [
        'The International',
        'Major Championships',
        'ESL One'
      ],
    ),
    EsportGame(
      name: 'Valorant',
      icon: '🔫',
      playersPerTeam: 5,
      description: 'FPS táctico con habilidades',
      popularTournaments: ['Champions Tour', 'Masters', 'Challengers'],
    ),
    EsportGame(
      name: 'Rocket League',
      icon: '⚽',
      playersPerTeam: 3,
      description: 'Fútbol con coches',
      popularTournaments: ['RLCS World Championship', 'Regional Championships'],
    ),
    EsportGame(
      name: 'Overwatch',
      icon: '🦸',
      playersPerTeam: 5,
      description: 'FPS por equipos con héroes',
      popularTournaments: ['Overwatch League', 'Contenders', 'World Cup'],
    ),
    EsportGame(
      name: 'FIFA',
      icon: '⚽',
      playersPerTeam: 1,
      description: 'Simulador de fútbol competitivo',
      popularTournaments: [
        'FIFAe World Cup',
        'Global Series',
        'eChampions League'
      ],
    ),
    EsportGame(
      name: 'Rainbow Six Siege',
      icon: '🛡️',
      playersPerTeam: 5,
      description: 'FPS táctico de asedio',
      popularTournaments: [
        'Six Invitational',
        'Major Championships',
        'Pro League'
      ],
    ),
  ];
}
