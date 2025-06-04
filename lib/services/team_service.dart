import 'package:hive/hive.dart';
import '../models/team_model.dart';

class TeamService {
  static const boxName = 'teamsBox';

  static Future<List<TeamModel>> getTeams() async {
    final box = await Hive.openBox<TeamModel>(boxName);
    return box.values.toList();
  }

  static Future<void> addTeam(String name) async {
    final box = await Hive.openBox<TeamModel>(boxName);
    final team = TeamModel(name: name, members: []);
    await box.put(name, team);
  }

  static Future<void> addPokemonToTeam(String teamName, dynamic pokemon) async {
    final box = await Hive.openBox<TeamModel>(boxName);
    final team = box.get(teamName);
    if (team != null) {
      team.members.add(pokemon);
      await team.save();
    }
  }

  static Future<void> updateTeam(TeamModel team) async {
    final box = await Hive.openBox<TeamModel>(boxName);
    await box.put(team.name, team);
    await team.save(); // Ensure changes are saved to Hive
  }
}
