import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/pokemon_model.dart';
import '../models/team_model.dart';
import '../services/team_service.dart';
import '../widgets/team_dialog.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<PokemonModel> pokemonList = [];
  List<PokemonModel> filteredList = [];
  final _apiService = ApiService();
  bool _isLoading = false;
  int _offset = 0;
  static const int _limit = 20;
  bool _isSearching = false;
  List<TeamModel> teams = [];

  @override
  void initState() {
    super.initState();
    _loadPokemon();
    _loadTeams();
  }

  Future<void> _loadPokemon() async {
    if (_isLoading || _isSearching) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final pokemonData =
          await _apiService.fetchPokemonList(limit: _limit, offset: _offset);
      final newPokemon = pokemonData
          .map(
            (data) => PokemonModel(
              id: data['id'],
              name: data['name'],
              imageUrl: data['sprites']['front_default'],
              abilities: (data['abilities'] as List)
                  .map((ability) => ability['ability']['name'].toString())
                  .toList(),
              baseExperience: data['base_experience'] ?? 0,
            ),
          )
          .toList();

      setState(() {
        pokemonList.addAll(newPokemon);
        if (!_isSearching) {
          filteredList = List.from(pokemonList);
        }
        _offset += _limit;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal memuat Pokemon")),
        );
      }
    }
  }

  Future<void> _searchPokemon() async {
    final name = _searchController.text.trim().toLowerCase();
    if (name.isEmpty) {
      setState(() {
        _isSearching = false;
        filteredList = List.from(pokemonList);
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _isLoading = true;
      filteredList = [];
    });

    try {
      final data = await _apiService.fetchPokemon(name);
      if (data != null) {
        final model = PokemonModel(
          id: data['id'],
          name: data['name'],
          imageUrl: data['sprites']['front_default'],
          abilities: (data['abilities'] as List)
              .map((ability) => ability['ability']['name'].toString())
              .toList(),
          baseExperience: data['base_experience'] ?? 0,
        );
        setState(() {
          filteredList = [model];
          _isLoading = false;
        });
      } else {
        setState(() {
          filteredList = [];
          _isLoading = false;
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Pokémon tidak ditemukan")),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal mencari Pokemon")),
        );
      }
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

  Future<void> _loadTeams() async {
    final loadedTeams = await TeamService.getTeams();
    setState(() {
      teams = loadedTeams;
    });
  }

  void _showTeamDialog(PokemonModel pokemon) async {
    await showDialog(
      context: context,
      builder: (context) => TeamDialog(
        pokemon: pokemon,
        teams: teams,
      ),
    );
    _loadTeams(); // Reload teams after dialog is closed
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
          IconButton(
            icon: const Icon(Icons.sports_kabaddi),
            onPressed: () => Navigator.pushNamed(context, '/battle'),
            tooltip: 'Battle Arena',
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
                labelText: "Cari Pokémon (cth: pikachu)",
                border: const OutlineInputBorder(),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _searchPokemon();
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _searchPokemon,
                    ),
                  ],
                ),
              ),
              onSubmitted: (_) => _searchPokemon(),
              onChanged: (value) {
                if (value.isEmpty) {
                  _searchPokemon();
                }
              },
            ),
          ),
          const Divider(),
          Expanded(
            child: NotificationListener<ScrollNotification>(
              onNotification: (ScrollNotification scrollInfo) {
                if (!_isLoading &&
                    !_isSearching &&
                    scrollInfo.metrics.pixels ==
                        scrollInfo.metrics.maxScrollExtent) {
                  _loadPokemon();
                }
                return true;
              },
              child: _isLoading && filteredList.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : filteredList.isEmpty
                      ? const Center(
                          child: Text("Tidak ada Pokemon ditemukan"),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: filteredList.length +
                              (!_isSearching && _isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == filteredList.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }

                            final pokemon = filteredList[index];
                            return Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: InkWell(
                                onTap: () => _goToDetail(pokemon),
                                borderRadius: BorderRadius.circular(15),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Stack(
                                      alignment: Alignment.topRight,
                                      children: [
                                        Hero(
                                          tag: 'pokemon-${pokemon.id}',
                                          child: Image.network(
                                            pokemon.imageUrl,
                                            height: 100,
                                            width: 100,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add_circle),
                                          onPressed: () =>
                                              _showTeamDialog(pokemon),
                                          tooltip: 'Tambah ke Tim',
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      pokemon.name.toUpperCase(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Base Exp: ${pokemon.baseExperience}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      child: Text(
                                        pokemon.abilities.join(", "),
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                        maxLines: 2,
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
