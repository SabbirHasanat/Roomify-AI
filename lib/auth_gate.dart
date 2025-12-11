import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/auth_service.dart';
import 'screens/auth/sign_in_page.dart';
import 'screens/rooms/room_list_page.dart';

class AuthGate extends StatelessWidget {
  final AuthService _authService = AuthService();

  AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData) {
          return const SignInPage();
        }
        return const RoomListPage();
      },
    );
  }
}
