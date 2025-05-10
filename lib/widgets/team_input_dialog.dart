import 'package:flutter/material.dart';
import '../models/team.dart';
import '../models/esport_game.dart';

class TeamInputDialog extends StatefulWidget {
  final Team? initialTeam;
  final int playersPerTeam;
  final bool isEsportsMode;
  final EsportGame? selectedGame;

  const TeamInputDialog({
    super.key,
    this.initialTeam,
    required this.playersPerTeam,
    this.isEsportsMode = false,
    this.selectedGame,
  });

  @override
  State<TeamInputDialog> createState() => _TeamInputDialogState();
}

class _TeamInputDialogState extends State<TeamInputDialog> {
  late TextEditingController _teamNameController;
  late List<TextEditingController> _memberControllers;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    _teamNameController = TextEditingController(
      text: widget.initialTeam?.name ?? '',
    );

    // Initialize member controllers
    if (widget.initialTeam != null && widget.initialTeam!.members.isNotEmpty) {
      _memberControllers = widget.initialTeam!.members
          .map((name) => TextEditingController(text: name))
          .toList();
    } else {
      _memberControllers = List.generate(
        widget.playersPerTeam,
        (_) => TextEditingController(),
      );
    }
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    for (var controller in _memberControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addMemberField() {
    if (_memberControllers.length < widget.playersPerTeam) {
      setState(() {
        _memberControllers.add(TextEditingController());
      });
    }
  }

  void _removeMemberField(int index) {
    if (_memberControllers.length > 1) {
      setState(() {
        _memberControllers[index].dispose();
        _memberControllers.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 16,
      backgroundColor: const Color(0xFF1F1F1F),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.initialTeam != null ? 'Editar Equipo' : 'Nuevo Equipo',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (widget.isEsportsMode && widget.selectedGame != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.selectedGame!.name,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.tealAccent.withOpacity(0.7),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              TextFormField(
                controller: _teamNameController,
                decoration: InputDecoration(
                  labelText: 'Nombre del Equipo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.group),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa el nombre del equipo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Miembros del Equipo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (widget.isEsportsMode) ...[
                    Text(
                      '${_memberControllers.length}/${widget.playersPerTeam}',
                      style: TextStyle(
                        color:
                            _memberControllers.length == widget.playersPerTeam
                                ? Colors.tealAccent
                                : Colors.orange,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              ...List.generate(
                _memberControllers.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _memberControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Jugador ${index + 1}',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.person),
                          ),
                          validator: widget.isEsportsMode
                              ? (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Nombre del jugador requerido';
                                  }
                                  return null;
                                }
                              : null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.remove_circle),
                        color: Colors.redAccent,
                        onPressed: () => _removeMemberField(index),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (_memberControllers.length < widget.playersPerTeam)
                ElevatedButton.icon(
                  onPressed: _addMemberField,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar Jugador'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.tealAccent.withOpacity(0.2),
                    foregroundColor: Colors.tealAccent,
                  ),
                ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        if (widget.isEsportsMode &&
                            _memberControllers.length !=
                                widget.playersPerTeam) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Se requieren exactamente ${widget.playersPerTeam} jugadores'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        // Create team and return it
                        final team = Team(
                          name: _teamNameController.text.trim(),
                          members: _memberControllers
                              .map((c) => c.text.trim())
                              .where((text) => text.isNotEmpty)
                              .toList(),
                        );
                        Navigator.pop(context, team);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00FFE0),
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
