import 'dart:math';
import '/models/match.dart';
import '/models/tournament_format.dart';

class TournamentGenerator {
  static List<Match> generateMatches(
    List<dynamic> participants,
    TournamentSettings settings,
  ) {
    if (participants.isEmpty) {
      return [];
    }

    switch (settings.format) {
      case TournamentFormat.singleElimination:
        return _generateSingleElimination(participants, settings.numberOfSeeds);
      case TournamentFormat.doubleElimination:
        return _generateDoubleElimination(participants, settings.numberOfSeeds);
      case TournamentFormat.roundRobin:
        return _generateRoundRobin(participants);
      case TournamentFormat.groupStage:
        return _generateGroupStage(participants, settings);
    }
  }

  static List<Match> _generateSingleElimination(
    List<dynamic> participants,
    int numberOfSeeds,
  ) {
    var shuffledParticipants = List<dynamic>.from(participants);
    _seedParticipants(shuffledParticipants, numberOfSeeds);

    final numberOfRounds = (log(participants.length) / log(2)).ceil();
    List<Match> matches = [];
    int matchCount = 1;

    // First round matches
    for (var i = 0; i < shuffledParticipants.length; i += 2) {
      var match = Match(
        id: 'R1M$matchCount',
        participant1: shuffledParticipants[i],
        participant2: i + 1 < shuffledParticipants.length
            ? shuffledParticipants[i + 1]
            : null,
        roundNumber: 1,
        matchNumber: matchCount,
        type: MatchType.winnersRound,
        nextWinnerMatchId: 'R2M${(matchCount / 2).ceil()}',
      );
      matches.add(match);
      matchCount++;
    }

    // Generate subsequent rounds
    for (int round = 2; round <= numberOfRounds; round++) {
      int matchesInRound =
          (shuffledParticipants.length ~/ pow(2, round)).ceil();
      for (int i = 0; i < matchesInRound; i++) {
        matches.add(Match(
          id: 'R${round}M${i + 1}',
          participant1: null,
          participant2: null,
          roundNumber: round,
          matchNumber: i + 1,
          type: MatchType.winnersRound,
          nextWinnerMatchId: round < numberOfRounds
              ? 'R${round + 1}M${(i / 2).ceil() + 1}'
              : null,
        ));
      }
    }

    return matches;
  }

  static List<Match> _generateDoubleElimination(
    List<dynamic> participants,
    int numberOfSeeds,
  ) {
    var shuffledParticipants = List<dynamic>.from(participants);
    _seedParticipants(shuffledParticipants, numberOfSeeds);

    List<Match> matches = [];
    int totalRounds = (participants.length - 1).toInt();
    int matchCount = 1;

    // Winners bracket - First round
    for (int i = 0; i < shuffledParticipants.length; i += 2) {
      matches.add(Match(
        id: 'W1M$matchCount',
        participant1: shuffledParticipants[i],
        participant2: i + 1 < shuffledParticipants.length
            ? shuffledParticipants[i + 1]
            : null,
        roundNumber: 1,
        matchNumber: matchCount,
        type: MatchType.winnersRound,
        nextWinnerMatchId: 'W2M${(matchCount / 2).ceil()}',
        nextLoserMatchId: 'L1M$matchCount',
      ));
      matchCount++;
    }

    // Winners bracket - Subsequent rounds
    for (int round = 2; round <= totalRounds - 1; round++) {
      int matchesInRound =
          (shuffledParticipants.length ~/ pow(2, round)).ceil();
      for (int i = 0; i < matchesInRound; i++) {
        matches.add(Match(
          id: 'W${round}M${i + 1}',
          participant1: null,
          participant2: null,
          roundNumber: round,
          matchNumber: i + 1,
          type: MatchType.winnersRound,
          nextWinnerMatchId: round < totalRounds - 1
              ? 'W${round + 1}M${(i / 2).ceil() + 1}'
              : 'F1M1',
          nextLoserMatchId: 'L${round}M${i + 1}',
        ));
      }
    }

    // Losers bracket
    matchCount = 1;
    for (int round = 1; round <= totalRounds - 1; round++) {
      int matchesInRound =
          (shuffledParticipants.length ~/ pow(2, round)).ceil();
      for (int i = 0; i < matchesInRound; i++) {
        matches.add(Match(
          id: 'L${round}M$matchCount',
          participant1: null,
          participant2: null,
          roundNumber: round,
          matchNumber: matchCount,
          type: MatchType.losersRound,
          nextWinnerMatchId: round < totalRounds - 1
              ? 'L${round + 1}M${(matchCount / 2).ceil()}'
              : 'F1M1',
        ));
        matchCount++;
      }
    }

    // Finals
    matches.add(Match(
      id: 'F1M1',
      participant1: null,
      participant2: null,
      roundNumber: totalRounds,
      matchNumber: 1,
      type: MatchType.finals,
    ));

    return matches;
  }

  static List<Match> _generateRoundRobin(List<dynamic> participants) {
    List<Match> matches = [];
    int matchCount = 1;
    int roundCount = 1;

    for (int i = 0; i < participants.length; i++) {
      for (int j = i + 1; j < participants.length; j++) {
        matches.add(Match(
          id: 'RR${roundCount}M$matchCount',
          participant1: participants[i],
          participant2: participants[j],
          roundNumber: roundCount,
          matchNumber: matchCount,
          type: MatchType.groupStage,
        ));
        matchCount++;

        // Start a new round after every n matches
        if (matchCount > participants.length / 2) {
          roundCount++;
          matchCount = 1;
        }
      }
    }

    return matches;
  }

  static List<Match> _generateGroupStage(
    List<dynamic> participants,
    TournamentSettings settings,
  ) {
    if (participants.isEmpty || settings.numberOfGroups <= 0) {
      return [];
    }

    List<Match> allMatches = [];
    var shuffledParticipants = List<dynamic>.from(participants)..shuffle();

    // Calculate participants per group
    int baseParticipantsPerGroup =
        participants.length ~/ settings.numberOfGroups;
    int extraParticipants = participants.length % settings.numberOfGroups;

    int currentIndex = 0;

    for (int g = 0; g < settings.numberOfGroups; g++) {
      // Calculate actual participants for this group
      int groupSize =
          baseParticipantsPerGroup + (g < extraParticipants ? 1 : 0);

      if (currentIndex < shuffledParticipants.length) {
        var endIndex =
            min(currentIndex + groupSize, shuffledParticipants.length);
        var groupParticipants =
            shuffledParticipants.sublist(currentIndex, endIndex);

        // Generate matches for this group
        var groupMatches = _generateRoundRobin(groupParticipants);

        // Update match IDs to include group information
        for (int i = 0; i < groupMatches.length; i++) {
          var updatedMatch = groupMatches[i].copyWith(
            id: 'G${g + 1}M${i + 1}',
            type: MatchType.groupStage,
          );
          allMatches.add(updatedMatch);
        }

        currentIndex = endIndex;
      }
    }

    return allMatches;
  }

  static void _seedParticipants(List<dynamic> participants, int numberOfSeeds) {
    if (numberOfSeeds <= 0 || numberOfSeeds >= participants.length) return;

    var seededParticipants = participants.sublist(0, numberOfSeeds);
    var remainingParticipants = participants.sublist(numberOfSeeds);

    remainingParticipants.shuffle();

    participants
      ..clear()
      ..addAll(seededParticipants)
      ..addAll(remainingParticipants);
  }
}
