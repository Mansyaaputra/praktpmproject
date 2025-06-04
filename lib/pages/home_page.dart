import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/pokemon_model.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String pokemonName = 'ditto';
  List<PokemonModel> pokemonList = [];
  final _apiService = ApiService();

  Future<void> _searchAndAddPokemon() async {
    final name = _searchController.text.trim().toLowerCase();
    if (name.isEmpty) return;

    final data = await _apiService.fetchPokemon(name);
    if (data != null) {
      final model = PokemonModel(
        id: data['id'],
        name: data['name'],
        imageUrl: data['sprites']['front_default'],
      );
      setState(() {
        pokemonList.add(model);
        _searchController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Pokémon tidak ditemukan")),
      );
    }
  }

  void _goToDetail(PokemonModel model) async {
    final data = await _apiService.fetchPokemon(model.name);
    if (data != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => DetailPage(data: data)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pokémon App"),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => Navigator.pushNamed(context, '/favorites'),
          ),
          IconButton(
            icon: const Icon(Icons.group),
            onPressed: () => Navigator.pushNamed(context, '/teams'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Cari Pokémon (cth: ditto)",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: _searchAndAddPokemon,
                ),
              ),
              onSubmitted: (_) => _searchAndAddPokemon(),
            ),
          ),
          const Divider(),
          Expanded(
            child: pokemonList.isEmpty
                ? const Center(child: Text("Belum ada Pokémon ditambahkan."))
                : ListView.builder(
                    itemCount: pokemonList.length,
                    itemBuilder: (context, index) {
                      final pokemon = pokemonList[index];
                      return ListTile(
                        leading: Image.network(pokemon.imageUrl),
                        title: Text(pokemon.name),
                        onTap: () => _goToDetail(pokemon),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
