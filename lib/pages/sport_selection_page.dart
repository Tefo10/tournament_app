// lib/pages/sport_selection_page.dart
import 'package:flutter/material.dart';
import '../constants/sports.dart';
import '../widgets/sport_card.dart';

class SportSelectionPage extends StatelessWidget {
  final Function(Sport) onSportSelected;

  const SportSelectionPage({
    super.key,
    required this.onSportSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Deporte'),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
            ],
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: SportsData.popularSports.length,
          itemBuilder: (context, index) {
            final sport = SportsData.popularSports[index];
            return AnimatedOpacity(
              opacity: 1.0,
              duration: Duration(milliseconds: 300 + (index * 100)),
              child: AnimatedPadding(
                duration: Duration(milliseconds: 300 + (index * 100)),
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: SportCard(
                  sport: sport,
                  onSelect: () => onSportSelected(sport),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
