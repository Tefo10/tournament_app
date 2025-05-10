import 'package:flutter/material.dart';
import '../models/esport_game.dart';

class EsportGameCard extends StatelessWidget {
  final EsportGame game;
  final VoidCallback onSelect;

  const EsportGameCard({
    super.key,
    required this.game,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    game.icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          game.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${game.playersPerTeam} jugadores por equipo',
                          style: TextStyle(
                            color: Colors.tealAccent.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                game.description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Torneos populares:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.tealAccent,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                children: game.popularTournaments.map((tournament) {
                  return Chip(
                    label: Text(
                      tournament,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: Colors.tealAccent.withOpacity(0.7),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
