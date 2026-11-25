import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

const Color pulseBg = Color(0xFF0B0D17);
const Color pulsePanel = Color(0xFF151827);
const Color pulseAccent = Color(0xFF8B5CF6);
const Color pulseText = Color(0xFFF4F2FF);
const Color pulseMuted = Color(0xFF9A9AAF);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyDP2fRwJHoRKUW-roX45fIxYrOEF3zornU',
      appId: '1:809504128222:android:89ca5d8f66527bc130164f',
      messagingSenderId: '809504128222',
      projectId: 'pulse-bad0e',
      storageBucket: 'pulse-bad0e.firebasestorage.app',
    ),
  );

  runApp(const PulseApp());
}

class PulseApp extends StatelessWidget {
  const PulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PULSE',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: pulseBg,
        colorScheme: const ColorScheme.dark(
          primary: pulseAccent,
          surface: pulsePanel,
        ),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: pulsePanel,
          hintStyle: const TextStyle(color: pulseMuted),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        }
        if (snapshot.data == null) {
          return const LoginScreen();
        }
        return const PulseHome();
      },
    );
  }
}

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: pulseAccent),
      ),
    );
  }
}
