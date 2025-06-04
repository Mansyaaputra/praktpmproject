import 'package:flutter/material.dart';
import '../models/pokemon_model.dart';
import '../services/local_storage_service.dart';
import '../utils/shared_prefs.dart';
import '../services/team_service.dart';
import '../widgets/team_dialog.dart';

class DetailPage extends StatefulWidget {
  final Map<String, dynamic> data;
  const DetailPage({super.key, required this.data});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool isFavorite = false;

  late final PokemonModel model;

  @override
  void initState() {
    super.initState();
    model = PokemonModel(
      id: widget.data['id'],
      name: widget.data['name'],
      imageUrl: widget.data['sprites']['front_default'],
      abilities: (widget.data['abilities'] as List)
          .map((ability) => ability['ability']['name'].toString())
          .toList(),
      baseExperience: widget.data['base_experience'] ?? 0,
    );
    _checkFavorite();
  }

  void _checkFavorite() async {
    final fav = await SharedPrefs.getFavoriteStatus();
    setState(() => isFavorite = fav);
  }

  void _toggleFavorite() async {
    if (!isFavorite) {
      await LocalStorageService.addPokemon(model);
    } else {
      await LocalStorageService.deletePokemon(model.name);
    }
    await SharedPrefs.setFavoriteStatus(!isFavorite);
    setState(() => isFavorite = !isFavorite);
  }

  void _showTeamDialog() async {
    final teams = await TeamService.getTeams();
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (_) => TeamDialog(pokemon: model, teams: teams),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    return Scaffold(
      appBar: AppBar(title: Text(data['name'].toUpperCase())),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(data['sprites']['front_default'], height: 120),
            const SizedBox(height: 20),
            Text("Height: ${data['height']}"),
            Text("Weight: ${data['weight']}"),
            Text("Base Experience: ${data['base_experience']}"),
            const SizedBox(height: 10),
            const Text("Abilities:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Column(
              children: (data['abilities'] as List)
                  .map((ability) => Text(ability['ability']['name']))
                  .toList()
                  .cast<Widget>(),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.red,
                  ),
                  label: Text(isFavorite ? "Hapus Favorit" : "Tambah Favorit"),
                  onPressed: _toggleFavorite,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.group_add),
                  label: const Text("Tambah ke Tim"),
                  onPressed: _showTeamDialog,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
