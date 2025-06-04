import 'package:hive/hive.dart';
import 'pokemon_model.dart';

part 'team_model.g.dart';

@HiveType(typeId: 1)
class TeamModel extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<PokemonModel> members;
  TeamModel({required this.name, required this.members});

  @override
  String toString() => name; // Membantu DropdownButton menampilkan nama tim
}
