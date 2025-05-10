import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/match.dart';
import '../models/team.dart';
import '../models/esport_game.dart';
import '../models/tournament_format.dart';
import '../services/tournament_generator.dart';
import '../models/esports_tournament_generator.dart';

class TournamentBracket extends StatefulWidget {
  final List<dynamic> participants;
  final bool isTeamMode;
  final bool isEsportsMode;
  final EsportGame? selectedGame;
  final TournamentFormat tournamentFormat;

  const TournamentBracket({
    super.key,
    required this.participants,
    this.isTeamMode = false,
    this.isEsportsMode = false,
    this.selectedGame,
    required this.tournamentFormat,
  });

  @override
  State<TournamentBracket> createState() => _TournamentBracketState();
}

class _TournamentBracketState extends State<TournamentBracket>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shuffleAnimation;
  List<dynamic> _shuffledParticipants = [];
  List<Match> _matches = [];
  bool _showMatches = false;
  int _currentRound = 1;
  int _totalRounds = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _shuffleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutBack,
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showMatches = true;
        });
      }
    });

    _shuffledParticipants = List.from(widget.participants);
    _totalRounds = (log(widget.participants.length) / log(2)).ceil();

    Future.delayed(const Duration(milliseconds: 300), () {
      _startBracketAnimation();
    });
  }

  void _startBracketAnimation() {
    setState(() {
      _shuffledParticipants = List.from(widget.participants);
      _showMatches = false;
      _currentRound = 1;
    });

    _controller.reset();
    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1200), () {
      setState(() {
        _shuffledParticipants.shuffle();

        final settings = TournamentSettings(
          format: widget.tournamentFormat,
          numberOfGroups: 4,
          numberOfSeeds: widget.participants.length >= 8 ? 4 : 2,
        );

        _matches = widget.isEsportsMode && widget.selectedGame != null
            ? EsportsTournamentGenerator.generateMatches(
                _shuffledParticipants,
                settings,
                widget.selectedGame!,
              )
            : TournamentGenerator.generateMatches(
                _shuffledParticipants,
                settings,
              );
      });
    });
  }

  void _declareWinner(Match match, dynamic winner) {
    setState(() {
      final matchIndex = _matches.indexWhere((m) => m.id == match.id);
      if (matchIndex != -1) {
        // Determine the loser
        final loser = winner == match.participant1
            ? match.participant2
            : match.participant1;

        _matches[matchIndex] = match.copyWith(
          winner: winner,
          loser: loser,
          isCompleted: true,
        );

        // Update next matches
        if (match.nextWinnerMatchId != null) {
          final nextWinnerMatch = _matches.firstWhere(
            (m) => m.id == match.nextWinnerMatchId,
          );

          final nextMatchIndex = _matches.indexOf(nextWinnerMatch);
          if (nextMatchIndex != -1) {
            _matches[nextMatchIndex] = nextWinnerMatch.copyWith(
              participant1: nextWinnerMatch.participant1 ?? winner,
              participant2: nextWinnerMatch.participant2 == null
                  ? winner
                  : nextWinnerMatch.participant2,
            );
          }
        }

        if (match.nextLoserMatchId != null && loser != null) {
          final nextLoserMatch = _matches.firstWhere(
            (m) => m.id == match.nextLoserMatchId,
          );

          final nextMatchIndex = _matches.indexOf(nextLoserMatch);
          if (nextMatchIndex != -1) {
            _matches[nextMatchIndex] = nextLoserMatch.copyWith(
              participant1: nextLoserMatch.participant1 ?? loser,
              participant2: nextLoserMatch.participant2 == null
                  ? loser
                  : nextLoserMatch.participant2,
            );
          }
        }

        // Check if current round is complete
        final currentRoundMatches =
            _matches.where((m) => m.roundNumber == _currentRound);
        final allMatchesComplete =
            currentRoundMatches.every((m) => m.isCompleted);

        if (allMatchesComplete && _currentRound < _totalRounds) {
          _currentRound++;
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!_showMatches) _buildShufflingAnimation(),
        if (_showMatches) _buildMatchesDisplay(),
        const SizedBox(height: 20),
        if (_showMatches)
          Text(
            widget.tournamentFormat == TournamentFormat.groupStage
                ? 'Fase de Grupos'
                : 'Ronda $_currentRound de $_totalRounds',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.tealAccent,
            ),
          ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _startBracketAnimation,
          icon: const Icon(Icons.shuffle),
          label: const Text('Sortear de nuevo'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildShufflingAnimation() {
    return AnimatedBuilder(
      animation: _shuffleAnimation,
      builder: (context, child) {
        return SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: List.generate(
              widget.participants.length.clamp(0, 8),
              (index) {
                final random = Random(index);
                final xOffset = sin((_shuffleAnimation.value * 5 + index) *
                        (random.nextDouble() * 2)) *
                    100;
                final yOffset = cos((_shuffleAnimation.value * 5 + index) *
                        (random.nextDouble() * 2)) *
                    50;
                final rotation = sin(_shuffleAnimation.value * 3 + index) * 0.3;
                final scale = 0.8 + sin(_shuffleAnimation.value * pi * 2) * 0.2;

                return Positioned(
                  left: MediaQuery.of(context).size.width / 2 - 75 + xOffset,
                  top: 100 + yOffset,
                  child: Transform.rotate(
                    angle: rotation,
                    child: Transform.scale(
                      scale: scale,
                      child: TournamentCard(
                        participant: index < widget.participants.length
                            ? widget.participants[index]
                            : (widget.isTeamMode
                                ? Team(name: '', members: [])
                                : ''),
                        isTeamMode: widget.isTeamMode,
                        isEsportsMode: widget.isEsportsMode,
                        selectedGame: widget.selectedGame,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildMatchesDisplay() {
    final currentRoundMatches =
        _matches.where((m) => m.roundNumber == _currentRound).toList();

    return AnimationLimiter(
      child: Column(
        children: AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 675),
          childAnimationBuilder: (widget) => SlideAnimation(
            horizontalOffset: 50.0,
            child: FadeInAnimation(
              child: widget,
            ),
          ),
          children: currentRoundMatches.map((match) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: MatchupCard(
                match: match,
                isTeamMode: widget.isTeamMode,
                isEsportsMode: widget.isEsportsMode,
                selectedGame: widget.selectedGame,
                onWinnerSelected: _declareWinner,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class TournamentCard extends StatelessWidget {
  final dynamic participant;
  final bool isTeamMode;
  final bool isEsportsMode;
  final EsportGame? selectedGame;

  const TournamentCard({
    super.key,
    required this.participant,
    required this.isTeamMode,
    this.isEsportsMode = false,
    this.selectedGame,
  });

  @override
  Widget build(BuildContext context) {
    String displayName = '';
    String? subtitle;

    if (isTeamMode) {
      if (participant is Team) {
        displayName = participant.name;
        subtitle =
            '${participant.members.length} ${isEsportsMode ? 'jugadores' : 'miembros'}';
      }
    } else {
      displayName = participant.toString();
    }

    return Card(
      elevation: 8,
      shadowColor: Colors.tealAccent.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Colors.tealAccent.withOpacity(0.8),
          width: 2,
        ),
      ),
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isEsportsMode && selectedGame != null) ...[
              Text(
                selectedGame!.icon,
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 4),
            ],
            Text(
              displayName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class MatchupCard extends StatelessWidget {
  final Match match;
  final bool isTeamMode;
  final bool isEsportsMode;
  final EsportGame? selectedGame;
  final Function(Match, dynamic) onWinnerSelected;

  const MatchupCard({
    super.key,
    required this.match,
    required this.isTeamMode,
    this.isEsportsMode = false,
    this.selectedGame,
    required this.onWinnerSelected,
  });

  String _getParticipantName(dynamic participant) {
    if (isTeamMode) {
      if (participant is Team) {
        return participant.name;
      }
      return "BYE";
    }
    return participant?.toString() ?? "BYE";
  }

  @override
  Widget build(BuildContext context) {
    final name1 = _getParticipantName(match.participant1);
    final name2 = _getParticipantName(match.participant2);

    return Card(
      elevation: 10,
      shadowColor: Colors.tealAccent.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1F1F1F),
              const Color(0xFF2A2A2A),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Encuentro #${match.matchNumber}',
                  style: TextStyle(
                    color: Colors.tealAccent.withOpacity(0.7),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (isEsportsMode && selectedGame != null)
                  Text(
                    selectedGame!.icon,
                    style: const TextStyle(fontSize: 20),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildParticipantSection(
                    name1,
                    match.participant1,
                    match.winner == match.participant1,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.tealAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'VS',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Colors.tealAccent,
                    ),
                  ),
                ),
                Expanded(
                  child: _buildParticipantSection(
                    name2,
                    match.participant2,
                    match.winner == match.participant2,
                  ),
                ),
              ],
            ),
            if (!match.isCompleted && name2 != "BYE")
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () =>
                          onWinnerSelected(match, match.participant1),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent.withOpacity(0.2),
                        foregroundColor: Colors.tealAccent,
                      ),
                      child: const Text('Ganador 1'),
                    ),
                    ElevatedButton(
                      onPressed: () =>
                          onWinnerSelected(match, match.participant2),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent.withOpacity(0.2),
                        foregroundColor: Colors.tealAccent,
                      ),
                      child: const Text('Ganador 2'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticipantSection(
      String name, dynamic participant, bool isWinner) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isWinner ? Colors.tealAccent.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(8),
        border:
            isWinner ? Border.all(color: Colors.tealAccent, width: 2) : null,
      ),
      child: Column(
        children: [
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: isWinner ? Colors.tealAccent : Colors.white,
            ),
          ),
          if (isTeamMode &&
              participant is Team &&
              participant.members.isNotEmpty)
            Text(
              '${participant.members.length} ${isEsportsMode ? 'jugadores' : 'miembros'}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          if (isWinner)
            const Icon(
              Icons.emoji_events,
              color: Colors.tealAccent,
              size: 20,
            ),
        ],
      ),
    );
  }
}
