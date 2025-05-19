import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'movie.dart';
import 'movie_list_screen.dart';
import 'settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(MovieAdapter());
  await Hive.openBox<Movie>('movies');
  
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  void _toggleTheme(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
    setState(() {
      _isDarkMode = isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Мои любимые фильмы',
      theme: _isDarkMode 
          ? ThemeData.dark().copyWith(
              primaryColor: Colors.blueGrey,
              hintColor: Colors.blueGrey[200],
            )
          : ThemeData.light().copyWith(
              primaryColor: Colors.blue,
              hintColor: Colors.lightBlue[200],
            ),
      home: MovieListScreen(),
      routes: {
        '/settings': (context) => SettingsScreen(
              isDarkMode: _isDarkMode,
              onThemeChanged: _toggleTheme,
            ),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}