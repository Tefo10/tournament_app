enum TournamentFormat {
  singleElimination,
  doubleElimination,
  roundRobin,
  groupStage
}

class TournamentSettings {
  final TournamentFormat format;
  final int numberOfGroups;
  final int numberOfSeeds;

  const TournamentSettings({
    required this.format,
    this.numberOfGroups = 4,
    this.numberOfSeeds = 0,
  });
}
