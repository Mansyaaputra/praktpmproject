import 'package:flutter/material.dart';
import '../services/local_storage_service.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Favorite Pokémon")),
      body: FutureBuilder(
        future: LocalStorageService.getFavorites(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final pokemons = snapshot.data!;
            if (pokemons.isEmpty) {
              return const Center(child: Text("No favorites yet."));
            }
            return ListView.builder(
              itemCount: pokemons.length,
              itemBuilder: (context, index) {
                final poke = pokemons[index];
                return ListTile(
                  leading: Image.network(poke.imageUrl),
                  title: Text(poke.name),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
