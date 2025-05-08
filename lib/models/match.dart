class Match {
  final String id;
  final dynamic participant1;
  final dynamic participant2;
  dynamic winner;
  final int roundNumber;
  final int matchNumber;
  bool isCompleted;

  Match({
    required this.id,
    required this.participant1,
    required this.participant2,
    this.winner,
    required this.roundNumber,
    required this.matchNumber,
    this.isCompleted = false,
  });

  Match copyWith({
    String? id,
    dynamic participant1,
    dynamic participant2,
    dynamic winner,
    int? roundNumber,
    int? matchNumber,
    bool? isCompleted,
  }) {
    return Match(
      id: id ?? this.id,
      participant1: participant1 ?? this.participant1,
      participant2: participant2 ?? this.participant2,
      winner: winner ?? this.winner,
      roundNumber: roundNumber ?? this.roundNumber,
      matchNumber: matchNumber ?? this.matchNumber,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
