import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart'; //основные виджеты
import 'package:firebase_auth/firebase_auth.dart';
import 'Screens/Auth/Authentication.dart';
import 'Screens/Home/home_screen.dart';
import 'Screens/Profile/profile_screen.dart';
import 'Screens/Profile/edit_profile_screen.dart';
import 'Screens/Favorites/favorites_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //инициализация виджетов приложения
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Auth App',
      theme: ThemeData(
        fontFamily: 'ShantellSans',
        primaryColor: Color(0xFF47C27A),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF47C27A),
          brightness: Brightness.light,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF3E875C),
            foregroundColor: Color(0xFFB6F3D4),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Color(0xFF3E875C),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => AuthGate(),
        '/home': (context) => const HomeScreen(),
        '/favorites': (context) => const FavoritesScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/edit_profile': (context) => const EditProfileScreen(),
      }
    );
  }
}

//следим за состоянием авторизации
class AuthGate extends StatelessWidget {

  //отрисовка интерфейса, передается окружение
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      //откуда данные
      stream: FirebaseAuth.instance.authStateChanges(),
      //что обновляем
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          //стандартный каркас Android прилодения
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return const HomeScreen();
        } else {
          return const Authentication();
        }
      },
    );
  }
}


