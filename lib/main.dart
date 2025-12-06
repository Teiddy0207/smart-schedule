import 'package:flutter/material.dart';
import 'core/api_client.dart';
import 'services/auth_service.dart';
import 'repositories/auth_repository.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize API client and services
    final apiClient = ApiClient();
    final authService = AuthService(apiClient);
    final authRepository = AuthRepository(authService);

    return MaterialApp(
      title: 'Smart schedule',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7C3AED),
        ),
        useMaterial3: true,
      ),
      home: LoginScreen(authRepository: authRepository),
    );
  }
}

