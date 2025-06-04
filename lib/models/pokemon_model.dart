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

  @HiveField(4)
  final int baseExperience;
  PokemonModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.abilities = const [],
    required this.baseExperience,
  });

  PokemonModel copyWith({
    int? id,
    String? name,
    String? imageUrl,
    List<String>? abilities,
    int? baseExperience,
  }) {
    return PokemonModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      abilities: abilities ?? this.abilities,
      baseExperience: baseExperience ?? this.baseExperience,
    );
  }
}
