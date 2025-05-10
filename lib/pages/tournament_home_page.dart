import 'package:flutter/material.dart';
import 'package:stepper_touch/stepper_touch.dart';
import '../models/team.dart';
import '../models/esport_game.dart';
import '../models/tournament_format.dart';
import '../widgets/custom_loading_animation.dart';
import '../widgets/epic_animated_background.dart';
import '../widgets/tournament_bracket.dart';
import '../widgets/team_input_dialog.dart';
import 'esport_selection_page.dart';
import '/constants/sports.dart';
import 'sport_selection_page.dart';

class TournamentHomePage extends StatefulWidget {
  const TournamentHomePage({super.key});

  @override
  State<TournamentHomePage> createState() => _TournamentHomePageState();
}

class _TournamentHomePageState extends State<TournamentHomePage>
    with TickerProviderStateMixin {
  int _currentStep = 0;
  int _participants = 2;
  int _playersPerTeam = 2;
  final List<dynamic> _participantsList = [];
  final List<String> _playerNames = [];
  bool _isLoading = false;
  bool _isTeamMode = false;
  bool _isAutoSort = false;
  bool _isEsportsMode = false;
  EsportGame? _selectedGame;
  Sport? _selectedSport;
  TournamentFormat _tournamentFormat = TournamentFormat.singleElimination;

  // Animation controllers
  late AnimationController _revealController;
  late Animation<double> _revealAnimation;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();

  // Getters para cálculos importantes
  int get requiredPlayers => _participants * _playersPerTeam;
  int get remainingPlayers => requiredPlayers - _playerNames.length;
  bool get canFormTeams => _playerNames.length >= _playersPerTeam;
  int get possibleTeams => _playerNames.length ~/ _playersPerTeam;

  @override
  void initState() {
    super.initState();

    _revealController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _revealAnimation = CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeInOut,
    );
  }

  void _selectSport() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SportSelectionPage(
          onSportSelected: (sport) {
            setState(() {
              _selectedSport = sport;
              _isTeamMode = true;
              _playersPerTeam = sport.playersPerTeam;
            });
            Navigator.pop(context);
          },
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedSport = result;
        _isTeamMode = true;
        _playersPerTeam = result.playersPerTeam;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  void _selectEsportGame() async {
    final result = await Navigator.of(context).push<EsportGame>(
      MaterialPageRoute(
        builder: (context) => EsportsSelectionPage(
          onGameSelected: (game) {
            setState(() {
              _selectedGame = game;
              _isEsportsMode = true;
              _isTeamMode = true;
              _playersPerTeam = game.playersPerTeam;
            });
            Navigator.of(context).pop(game);
          },
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedGame = result;
        _isEsportsMode = true;
        _isTeamMode = true;
        _playersPerTeam = result.playersPerTeam;
      });
    }
  }

  void _nextStep() {
    setState(() {
      if (_currentStep < 2) {
        // Validación específica para el paso 0
        if (_currentStep == 0) {
          // Si no estamos en modo automático, podemos avanzar directamente
          if (!_isAutoSort) {
            _currentStep++;
            return;
          }
        }

        // Validación específica para el paso 1
        if (_currentStep == 1) {
          if (_isAutoSort) {
            // En modo automático, verificamos si tenemos suficientes jugadores
            if (_playerNames.length < requiredPlayers) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Faltan $remainingPlayers jugadores para formar todos los equipos'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }
            _autoSortTeamsIfNeeded();
          } else {
            // En modo manual, verificamos si tenemos suficientes participantes
            if (_participantsList.length < _participants) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No hay suficientes participantes'),
                  backgroundColor: Colors.orange,
                ),
              );
              return;
            }
          }
        }

        _currentStep++;

        if (_currentStep == 2) {
          _startBracketReveal();
        }
      }
    });
  }

  void _previousStep() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep--;
      }
    });
  }

  void _startBracketReveal() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() {
        _isLoading = false;
      });

      _revealController.reset();
      _revealController.forward();
    });
  }

  void _addParticipant() {
    if (_isAutoSort) {
      _addPlayerForAutoSort();
    } else if (_isTeamMode) {
      _showTeamInputDialog();
    } else {
      _addIndividualParticipant();
    }
  }

  void _addPlayerForAutoSort() {
    if (_nameController.text.isEmpty) return;

    if (_playerNames.length >= requiredPlayers) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Ya se ha alcanzado el número máximo de jugadores necesarios'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _playerNames.add(_nameController.text.trim());
      _nameController.clear();
    });

    if (_playerNames.length == requiredPlayers) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Se han agregado todos los jugadores necesarios!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _addIndividualParticipant() {
    if (_nameController.text.isEmpty) return;

    if (_participantsList.length >= _participants) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ya se ha alcanzado el número máximo de participantes'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _participantsList.add(_nameController.text.trim());
      _nameController.clear();
    });

    if (_participantsList.length == _participants) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Todos los participantes han sido agregados!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _showTeamInputDialog() async {
    if (_participantsList.length >= _participants) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ya se ha alcanzado el número máximo de equipos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final result = await showDialog<Team>(
      context: context,
      builder: (context) => TeamInputDialog(
        playersPerTeam: _playersPerTeam,
        isEsportsMode: _isEsportsMode,
        selectedGame: _selectedGame,
      ),
    );

    if (result != null) {
      setState(() {
        _participantsList.add(result);
      });

      if (_participantsList.length == _participants) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Todos los equipos han sido agregados!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _toggleMode() {
    if (_participantsList.isNotEmpty || _playerNames.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cambiar Modo'),
          content: const Text(
              'Cambiar el modo borrará todos los participantes agregados. ¿Deseas continuar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetAndToggleMode();
              },
              child: const Text('Continuar'),
            ),
          ],
        ),
      );
    } else {
      _resetAndToggleMode();
    }
  }

  void _resetAndToggleMode() {
    setState(() {
      _isTeamMode = !_isTeamMode;
      _isAutoSort = false;
      _participantsList.clear();
      _playerNames.clear();
      _currentStep = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isTeamMode
            ? 'Modo Equipos activado. Agrega equipos al torneo.'
            : 'Modo Individual activado. Agrega participantes al torneo.'),
        backgroundColor: Colors.blueAccent,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _toggleAutoSort() {
    if (_participantsList.isNotEmpty || _playerNames.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cambiar Modo de Sorteo'),
          content: const Text(
              'Cambiar el modo de sorteo borrará todos los participantes agregados. ¿Deseas continuar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetAndToggleAutoSort();
              },
              child: const Text('Continuar'),
            ),
          ],
        ),
      );
    } else {
      _resetAndToggleAutoSort();
    }
  }

  void _resetAndToggleAutoSort() {
    setState(() {
      _isAutoSort = !_isAutoSort;
      _participantsList.clear();
      _playerNames.clear();
      _currentStep = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isAutoSort
            ? 'Modo Sorteo Automático activado. Agrega jugadores para formar equipos automáticamente.'
            : 'Modo Manual activado. Agrega equipos manualmente.'),
        backgroundColor: Colors.blueAccent,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _autoSortTeamsIfNeeded() {
    if (!_isAutoSort || _playerNames.isEmpty) return;

    if (_playerNames.length < requiredPlayers) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Faltan $remainingPlayers jugadores para formar todos los equipos'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Mezclar jugadores aleatoriamente
    final shuffledPlayers = List<String>.from(_playerNames)..shuffle();

    // Formar equipos
    setState(() {
      _participantsList.clear();

      for (var i = 0; i < shuffledPlayers.length; i += _playersPerTeam) {
        if (i + _playersPerTeam <= shuffledPlayers.length) {
          final teamMembers = shuffledPlayers.sublist(i, i + _playersPerTeam);
          final teamName = 'Equipo ${(_participantsList.length + 1)}';
          _participantsList.add(Team(name: teamName, members: teamMembers));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: EpicAnimatedBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (_selectedGame == null && _selectedSport == null)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _selectSport,
                          icon: const Icon(Icons.sports),
                          label: const Text('Deportes Tradicionales'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _selectEsportGame,
                          icon: const Icon(Icons.sports_esports),
                          label: const Text('Esports'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Expanded(
                    child: Stepper(
                      type: StepperType.vertical,
                      currentStep: _currentStep,
                      onStepContinue: _nextStep,
                      onStepCancel: _previousStep,
                      controlsBuilder: (context, details) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 20.0),
                          child: Row(
                            children: [
                              if (details.currentStep < 2)
                                ElevatedButton(
                                  onPressed: details.onStepContinue,
                                  child: const Text('Siguiente'),
                                ),
                              if (details.currentStep > 0) ...[
                                const SizedBox(width: 12),
                                TextButton(
                                  onPressed: details.onStepCancel,
                                  child: const Text('Anterior'),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                      steps: [
                        Step(
                          title: const Text('Configurar Torneo'),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Juego seleccionado: ${_selectedGame?.name}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Jugadores por equipo: ${_selectedGame?.playersPerTeam}',
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 24),
                              if (_isAutoSort) ...[
                                SwitchListTile(
                                  title: const Text('Sorteo Automático'),
                                  subtitle: Text(_isAutoSort
                                      ? 'Los equipos se formarán automáticamente'
                                      : 'Crear equipos manualmente'),
                                  value: _isAutoSort,
                                  onChanged: (_) => _toggleAutoSort(),
                                  activeColor: Colors.tealAccent,
                                ),
                              ],
                              const SizedBox(height: 16),
                              const Text(
                                'Número de Participantes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child: StepperTouch(
                                  initialValue: _participants,
                                  onChanged: (value) {
                                    if (value >= 2 && value <= 32) {
                                      setState(() => _participants = value);
                                    }
                                  },
                                  direction: Axis.horizontal,
                                ),
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<TournamentFormat>(
                                value: _tournamentFormat,
                                decoration: const InputDecoration(
                                  labelText: 'Formato del Torneo',
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: TournamentFormat.singleElimination,
                                    child: Text('Eliminación Simple'),
                                  ),
                                  DropdownMenuItem(
                                    value: TournamentFormat.doubleElimination,
                                    child: Text('Eliminación Doble'),
                                  ),
                                  DropdownMenuItem(
                                    value: TournamentFormat.roundRobin,
                                    child: Text('Todos contra Todos'),
                                  ),
                                  DropdownMenuItem(
                                    value: TournamentFormat.groupStage,
                                    child: Text('Fase de Grupos'),
                                  ),
                                ],
                                onChanged: (format) {
                                  if (format != null) {
                                    setState(() => _tournamentFormat = format);
                                  }
                                },
                              ),
                            ],
                          ),
                          isActive: _currentStep >= 0,
                        ),
                        Step(
                          title: Text(_isAutoSort
                              ? 'Ingresar Jugadores'
                              : 'Ingresar Equipos'),
                          content: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                if (!_isTeamMode || _isAutoSort) ...[
                                  TextFormField(
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                      labelText: _isAutoSort
                                          ? 'Nombre del jugador'
                                          : 'Nombre del participante',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      prefixIcon: const Icon(Icons.person),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                ElevatedButton.icon(
                                  onPressed: _addParticipant,
                                  icon: Icon(_isTeamMode && !_isAutoSort
                                      ? Icons.groups
                                      : Icons.person_add),
                                  label: Text(_isAutoSort
                                      ? 'Agregar Jugador'
                                      : (_isTeamMode
                                          ? 'Agregar Equipo'
                                          : 'Agregar Nombre')),
                                ),
                                const SizedBox(height: 24),
                                if (_isAutoSort && _playerNames.isNotEmpty) ...[
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Jugadores agregados:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ...List.generate(
                                    _playerNames.length,
                                    (index) => ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            Colors.tealAccent.withOpacity(0.2),
                                        child: Text('${index + 1}'),
                                      ),
                                      title: Text(
                                        _playerNames[index],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.redAccent),
                                        onPressed: () {
                                          setState(() {
                                            _playerNames.removeAt(index);
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Jugadores: ${_playerNames.length}/$requiredPlayers\n'
                                    'Equipos posibles: $possibleTeams/${_participants}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ] else if (_participantsList.isNotEmpty) ...[
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  Text(
                                    _isTeamMode
                                        ? 'Equipos agregados:'
                                        : 'Participantes agregados:',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ...List.generate(
                                    _participantsList.length,
                                    (index) => ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor:
                                            Colors.tealAccent.withOpacity(0.2),
                                        child: Text('${index + 1}'),
                                      ),
                                      title: Text(
                                        _isTeamMode
                                            ? (_participantsList[index] as Team)
                                                .name
                                            : _participantsList[index]
                                                .toString(),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w500),
                                      ),
                                      subtitle: _isTeamMode
                                          ? Text(
                                              '${(_participantsList[index] as Team).members.length} miembros')
                                          : null,
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete,
                                            color: Colors.redAccent),
                                        onPressed: () {
                                          setState(() {
                                            _participantsList.removeAt(index);
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    '${_isTeamMode ? "Equipos" : "Participantes"} agregados: ${_participantsList.length}/$_participants',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          isActive: _currentStep >= 1,
                        ),
                        Step(
                          title: const Text('Llaves del Torneo'),
                          content: _isLoading
                              ? const CustomLoadingAnimation()
                              : Column(
                                  children: [
                                    FadeTransition(
                                      opacity: _revealAnimation,
                                      child: SlideTransition(
                                        position: Tween<Offset>(
                                          begin: const Offset(0, 0.5),
                                          end: Offset.zero,
                                        ).animate(_revealAnimation),
                                        child: TournamentBracket(
                                          participants: _participantsList,
                                          isTeamMode: _isTeamMode,
                                          isEsportsMode: _isEsportsMode,
                                          selectedGame: _selectedGame,
                                          tournamentFormat: _tournamentFormat,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                          isActive: _currentStep >= 2,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _selectedGame != null
          ? FloatingActionButton(
              onPressed: _selectEsportGame,
              child: const Icon(Icons.sports_esports),
            )
          : null,
    );
  }
}
