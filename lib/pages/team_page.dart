import 'package:flutter/material.dart';
import '../models/team_model.dart';
import '../services/team_service.dart';

class TeamPage extends StatelessWidget {
  const TeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tim Pokémon")),
      body: FutureBuilder<List<TeamModel>>(
        future: TeamService.getTeams(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Gagal memuat tim."));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada tim."));
          } else {
            final teams = snapshot.data!;
            return ListView.builder(
              itemCount: teams.length,
              itemBuilder: (context, index) {
                final team = teams[index];
                final totalBaseExp = team.members.fold<int>(
                    0, (sum, pokemon) => sum + pokemon.baseExperience);

                return ExpansionTile(
                  title: Row(
                    children: [
                      Expanded(child: Text(team.name)),
                      Text(
                        'Total Base Exp: $totalBaseExp',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  children: team.members
                      .map((member) => ListTile(
                            leading: Image.network(member.imageUrl, width: 50),
                            title: Text(member.name),
                            subtitle:
                                Text('Base Exp: ${member.baseExperience}'),
                          ))
                      .toList(),
                );
              },
            );
          }
        },
      ),
    );
  }
}
