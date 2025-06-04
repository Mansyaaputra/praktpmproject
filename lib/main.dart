import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/pokemon_model.dart';
import 'models/team_model.dart';
import 'pages/home_page.dart';
import 'pages/favorites_page.dart';
import 'pages/team_page.dart';
import 'pages/battle_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(PokemonModelAdapter());
  Hive.registerAdapter(TeamModelAdapter());

  await Hive.openBox<PokemonModel>('favorite_pokemon');
  await Hive.openBox<TeamModel>('pokemon_teams');
  await Hive.openBox<TeamModel>('teamsBox'); // Box untuk tim

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokémon App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => const HomePage(),
        '/favorites': (_) => const FavoritesPage(),
        '/teams': (_) => const TeamPage(),
        '/battle': (_) => const BattlePage(),
      },
    );
  }
}
