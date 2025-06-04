import 'package:hive/hive.dart';

part 'pokemon_model.g.dart';

@HiveType(typeId: 0)
class PokemonModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;
  @HiveField(2)
  final String imageUrl;

  @HiveField(3)
  final List<String> abilities;

  PokemonModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.abilities = const [],
  });
}
