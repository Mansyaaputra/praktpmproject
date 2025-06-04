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
}
