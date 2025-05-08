import 'package:animated_background/animated_background.dart';
import 'package:flutter/material.dart';

class EpicAnimatedBackground extends StatefulWidget {
  const EpicAnimatedBackground({super.key, required this.child});

  final Widget child;

  @override
  State<EpicAnimatedBackground> createState() => _EpicAnimatedBackgroundState();
}

class _EpicAnimatedBackgroundState extends State<EpicAnimatedBackground>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBackground(
          behaviour: RandomParticleBehaviour(
            options: ParticleOptions(
              baseColor: Colors.tealAccent.withOpacity(0.7),
              spawnMinSpeed: 10,
              spawnMaxSpeed: 50,
              spawnMinRadius: 5,
              spawnMaxRadius: 15,
              particleCount: 80,
            ),
          ),
          vsync: this,
          child: Container(),
        ),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0D0D0D),
                Color(0xFF1F1F1F),
                Color(0xFF0D0D0D),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}
