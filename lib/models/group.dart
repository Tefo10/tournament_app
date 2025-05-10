class Group {
  final String name;
  final List<dynamic> participants;
  final List<Match> matches;
  final Map<dynamic, int> points;
  final Map<dynamic, int> goalsFor;
  final Map<dynamic, int> goalsAgainst;

  Group({
    required this.name,
    required this.participants,
    List<Match>? matches,
    Map<dynamic, int>? points,
    Map<dynamic, int>? goalsFor,
    Map<dynamic, int>? goalsAgainst,
  })  : matches = matches ?? [],
        points = points ?? {},
        goalsFor = goalsFor ?? {},
        goalsAgainst = goalsAgainst ?? {};

  void initializeStats() {
    for (var participant in participants) {
      points[participant] = 0;
      goalsFor[participant] = 0;
      goalsAgainst[participant] = 0;
    }
  }

  int getGoalDifference(dynamic participant) {
    return (goalsFor[participant] ?? 0) - (goalsAgainst[participant] ?? 0);
  }
}
