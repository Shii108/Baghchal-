import 'package:baghchal_app/screens/home_screen.dart';
import 'package:baghchal_app/screens/login_screen.dart';
import 'package:baghchal_app/screens/signup_screen.dart';
import 'package:baghchal_app/screens/play_with_friend_screen.dart';
import 'package:baghchal_app/services/api_service.dart';
import 'package:flutter/material.dart';

// ─── Main App ─────────────────────────────────────────────
class BaghchalApp extends StatefulWidget {
  const BaghchalApp({super.key});

  @override
  State<BaghchalApp> createState() => _BaghchalAppState();
}

class _BaghchalAppState extends State<BaghchalApp> {
  Future<Map<String, dynamic>> _checkAuthStatus() async {
    final token = await ApiService.getToken();
    final isGuest = await ApiService.isGuest();
    return {
      'isLoggedIn': token != null,
      'isGuest': isGuest,
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Baghchal',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0f1f13),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1a2e1f),
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFFf7f0dc),
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
      ),
      home: FutureBuilder<Map<String, dynamic>>(
        future: _checkAuthStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final data = snapshot.data ?? {};
          final isLoggedIn = data['isLoggedIn'] as bool? ?? false;
          final isGuest = data['isGuest'] as bool? ?? false;
          
          if (isLoggedIn || isGuest) {
            return const HomeScreen();
          }
          return const LoginScreen();
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/home': (context) => const HomeScreen(),
        '/play-with-friend': (context) => const PlayWithFriendScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

