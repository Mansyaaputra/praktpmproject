import 'package:flutter/material.dart';
import '../models/pokemon_model.dart';
import '../models/team_model.dart';
import '../services/team_service.dart';

class TeamDialog extends StatefulWidget {
  final PokemonModel pokemon;
  final List<TeamModel> teams;

  const TeamDialog({super.key, required this.pokemon, required this.teams});

  @override
  State<TeamDialog> createState() => _TeamDialogState();
}

class _TeamDialogState extends State<TeamDialog> {
  final TextEditingController teamNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Tambah ke Tim"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...widget.teams.map((team) => ListTile(
            title: Text(team.name),
            onTap: () async {
              await TeamService.addPokemonToTeam(team.name, widget.pokemon);
              Navigator.pop(context);
            },
          )),
          const Divider(),
          TextField(
            controller: teamNameController,
            decoration: const InputDecoration(labelText: 'Tim baru'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () async {
            final name = teamNameController.text.trim();
            if (name.isNotEmpty) {
              await TeamService.addTeam(name);
              await TeamService.addPokemonToTeam(name, widget.pokemon);
              Navigator.pop(context);
            }
          },
          child: const Text("Buat dan Tambah"),
        ),
      ],
    );
  }
}
