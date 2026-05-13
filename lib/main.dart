import 'package:flutter/material.dart';
import 'package:peso_pantry/config/app_theme.dart';
import 'package:peso_pantry/pages/auth/login_page.dart';
import 'package:peso_pantry/pages/auth/register_page.dart';
import 'package:peso_pantry/pages/home/home_page.dart';
import 'package:peso_pantry/pages/home/recipe_detail_page.dart';
import 'package:peso_pantry/pages/home/budget_filter_page.dart';
import 'package:peso_pantry/pages/user/profile_page.dart';
import 'package:peso_pantry/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PesoPantry',
      theme: AppTheme.lightTheme(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
        '/budget-filter': (context) => const BudgetFilterPage(),
        '/profile': (context) => const ProfilePage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/recipe-detail') {
          final recipeId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => RecipeDetailPage(recipeId: recipeId),
          );
        }
        return null;
      },
    );
  }
}
