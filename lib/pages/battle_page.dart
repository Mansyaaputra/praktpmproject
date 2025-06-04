import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/team_model.dart';
import '../models/pokemon_model.dart';
import '../services/team_service.dart';

class BattlePage extends StatefulWidget {
  const BattlePage({super.key});

  @override
  State<BattlePage> createState() => _BattlePageState();
}

class _BattlePageState extends State<BattlePage> {
  TeamModel? team1;
  TeamModel? team2;

  int _calculateTeamPower(TeamModel team) {
    return team.members
        .fold<int>(0, (sum, pokemon) => sum + pokemon.baseExperience);
  }

  Future<void> _startBattle() async {
    if (team1 == null || team2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih dua tim untuk bertanding!')),
      );
      return;
    }

    if (team1!.members.isEmpty || team2!.members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kedua tim harus memiliki Pokemon!')),
      );
      return;
    }

    // Reload latest team data
    final box = await Hive.openBox<TeamModel>('teamsBox');
    final updatedTeam1 = box.get(team1!.name);
    final updatedTeam2 = box.get(team2!.name);

    if (updatedTeam1 == null || updatedTeam2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Tim tidak ditemukan')),
      );
      return;
    }
    setState(() {
      team1 = updatedTeam1;
      team2 = updatedTeam2;
    });

    final power1 = _calculateTeamPower(team1!);
    final power2 = _calculateTeamPower(team2!);

    TeamModel? winnerTeam;
    if (power1 > power2) {
      winnerTeam = team1;
    } else if (power2 > power1) {
      winnerTeam = team2;
    }

    if (winnerTeam != null) {
      // Update base experience untuk tim pemenang
      final updatedMembers = winnerTeam.members.map((pokemon) {
        if (pokemon is PokemonModel) {
          final baseExpIncrement = (pokemon.baseExperience ~/ 100) * 10;
          return pokemon.copyWith(
            baseExperience: pokemon.baseExperience + baseExpIncrement,
          );
        }
        return pokemon;
      }).toList();

      winnerTeam.members.clear();
      winnerTeam.members.addAll(updatedMembers);
      await box.put(winnerTeam.name, winnerTeam);
    }
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Hasil Pertandingan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hasil Battle',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Divider(),
              Text(
                team1!.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Total Power: $power1'),
              const SizedBox(height: 8),
              Text(
                team2!.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('Total Power: $power2'),
              const SizedBox(height: 16),
              if (power1 == power2)
                const Text(
                  'Pertandingan Seri!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                )
              else if (winnerTeam != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pemenang: ${winnerTeam.name}!',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pokemon dalam tim pemenang mendapat tambahan base experience!',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  team1 = null;
                  team2 = null;
                });
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTeamSelector(
      String label, TeamModel? selectedTeam, Function(TeamModel?) onSelect) {
    return FutureBuilder<List<TeamModel>>(
      future: TeamService.getTeams(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final teams = snapshot.data!;
        if (teams.isEmpty) {
          return const Text('Tidak ada tim tersedia');
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButton<TeamModel>(
              value: selectedTeam,
              hint: const Text('Pilih Tim'),
              isExpanded: true,
              items: teams
                  .where((team) =>
                      team.members.isNotEmpty && // Only show teams with Pokemon
                      team !=
                          (selectedTeam == team1
                              ? team2
                              : team1)) // Prevent duplicate selection
                  .map((team) => DropdownMenuItem(
                        value: team,
                        child: Text(
                            '${team.name} (${team.members.length} Pokemon)'),
                      ))
                  .toList(),
              onChanged: (team) => onSelect(team),
            ),
            if (selectedTeam != null) ...[
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total Power: ${_calculateTeamPower(selectedTeam)}'),
                      const Divider(),
                      ...selectedTeam.members.map((pokemon) => ListTile(
                            leading: Image.network(pokemon.imageUrl, width: 40),
                            title: Text(pokemon.name),
                            subtitle:
                                Text('Base Exp: ${pokemon.baseExperience}'),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Battle Arena')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTeamSelector(
                'Tim 1', team1, (team) => setState(() => team1 = team)),
            const SizedBox(height: 20),
            _buildTeamSelector(
                'Tim 2', team2, (team) => setState(() => team2 = team)),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: team1 != null && team2 != null ? _startBattle : null,
              icon: const Icon(Icons.sports_kabaddi),
              label: const Text('Mulai Battle!'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
