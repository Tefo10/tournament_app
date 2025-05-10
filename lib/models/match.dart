enum MatchType {
  groupStage,
  winnersRound,
  losersRound,
  final_,
  finals,
}

class Match {
  final String id;
  final dynamic participant1;
  final dynamic participant2;
  dynamic winner;
  dynamic loser;
  final int roundNumber;
  final int matchNumber;
  bool isCompleted;
  final MatchType type;
  int? score1;
  int? score2;
  String? nextWinnerMatchId;
  String? nextLoserMatchId;

  Match({
    required this.id,
    required this.participant1,
    required this.participant2,
    this.winner,
    this.loser,
    required this.roundNumber,
    required this.matchNumber,
    this.isCompleted = false,
    this.type = MatchType.winnersRound,
    this.score1,
    this.score2,
    this.nextWinnerMatchId,
    this.nextLoserMatchId,
  });

  Match copyWith({
    String? id,
    dynamic participant1,
    dynamic participant2,
    dynamic winner,
    dynamic loser,
    int? roundNumber,
    int? matchNumber,
    bool? isCompleted,
    MatchType? type,
    int? score1,
    int? score2,
    String? nextWinnerMatchId,
    String? nextLoserMatchId,
  }) {
    return Match(
      id: id ?? this.id,
      participant1: participant1 ?? this.participant1,
      participant2: participant2 ?? this.participant2,
      winner: winner ?? this.winner,
      loser: loser ?? this.loser,
      roundNumber: roundNumber ?? this.roundNumber,
      matchNumber: matchNumber ?? this.matchNumber,
      isCompleted: isCompleted ?? this.isCompleted,
      type: type ?? this.type,
      score1: score1 ?? this.score1,
      score2: score2 ?? this.score2,
      nextWinnerMatchId: nextWinnerMatchId ?? this.nextWinnerMatchId,
      nextLoserMatchId: nextLoserMatchId ?? this.nextLoserMatchId,
    );
  }
}
