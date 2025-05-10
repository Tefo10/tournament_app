class Sport {
  final String name;
  final String icon;
  final int minPlayersPerTeam;
  final int maxPlayersPerTeam;
  final int defaultPlayersPerTeam;

  const Sport({
    required this.name,
    required this.icon,
    required this.minPlayersPerTeam,
    required this.maxPlayersPerTeam,
    this.defaultPlayersPerTeam = 2,
  });
}
