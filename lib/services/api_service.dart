import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  Future<Map<String, dynamic>?> fetchPokemon(String name) async {
    final response = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon/${name.toLowerCase()}'));
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> fetchPokemonList(
      {int limit = 20, int offset = 0}) async {
    final response = await http.get(Uri.parse(
        'https://pokeapi.co/api/v2/pokemon?limit=$limit&offset=$offset'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final results = data['results'] as List;

      List<Map<String, dynamic>> pokemonDetails = [];
      for (var pokemon in results) {
        final details = await fetchPokemon(pokemon['name']);
        if (details != null) {
          pokemonDetails.add(details);
        }
      }
      return pokemonDetails;
    }
    return [];
  }
}
