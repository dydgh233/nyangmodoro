import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/user_info_screen.dart';
import 'screens/focus_home_screen.dart';
import 'screens/focus_timer_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/email-verified.dart';
import 'screens/user_profile_detaill_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://yykohltyrfrosnbmnchk.supabase.co', // ← 너 프로젝트 URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl5a29obHR5cmZyb3NuYm1uY2hrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUyMjE3ODgsImV4cCI6MjA2MDc5Nzc4OH0.a1wQAoPZI42-cxX5lX_d7qHkGE9pRqdA_sraOdgEnJs', // ← 너 프로젝트 anon key
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

@override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '냥모도로',
      theme: ThemeData(primarySwatch: Colors.orange),
      initialRoute: '/home',
      routes: {
        '/': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/userinfo': (context) => const UserInfoScreen(),
        '/home': (context) => const FocusHomeScreen(),
        '/focus-timer': (context) => const FocusTimerScreen(),
        '/stats': (context) => const StatsScreen(),
        '/email-verified': (context) => const EmailVerifiedScreen(),
        '/profile': (context) => const UserProfileDetailScreen(),
      },
    );
  }
}
