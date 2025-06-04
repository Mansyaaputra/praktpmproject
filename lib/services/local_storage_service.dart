import 'package:hive/hive.dart';
import '../models/pokemon_model.dart';

class LocalStorageService {
  static const boxName = 'pokemonBox';

  static Future<void> addPokemon(PokemonModel pokemon) async {
    final box = await Hive.openBox<PokemonModel>(boxName);
    await box.put(pokemon.name, pokemon);
  }

  static Future<List<PokemonModel>> getFavorites() async {
    final box = await Hive.openBox<PokemonModel>(boxName);
    return box.values.toList();
  }

  static Future<void> deletePokemon(String name) async {
    final box = await Hive.openBox<PokemonModel>(boxName);
    await box.delete(name);
  }

  static Future<bool> exists(String name) async {
    final box = await Hive.openBox<PokemonModel>(boxName);
    return box.containsKey(name);
  }
}
