import 'package:flutter/material.dart';
import '../models/esport_game.dart';
import '../widgets/esport_game_card.dart';

class EsportsSelectionPage extends StatelessWidget {
  final Function(EsportGame) onGameSelected;

  const EsportsSelectionPage({
    super.key,
    required this.onGameSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Juego'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF0D0D0D),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        itemCount: EsportsData.popularGames.length,
        itemBuilder: (context, index) {
          final game = EsportsData.popularGames[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: EsportGameCard(
              game: game,
              onSelect: () => onGameSelected(game),
            ),
          );
        },
      ),
    );
  }
}
