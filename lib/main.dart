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
}class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final displayName = TextEditingController();

  bool creating = false;
  bool busy = false;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    displayName.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final mail = email.text.trim();
    final pass = password.text;

    if (mail.isEmpty ||
        pass.length < 6 ||
        (creating && displayName.text.trim().isEmpty)) {
      showMessage(context, 'Preencha todos os campos corretamente.');
      return;
    }

    setState(() => busy = true);

    try {
      if (creating) {
        final credential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: mail,
          password: pass,
        );

        final user = credential.user!;
        final name = displayName.text.trim();

        await user.updateDisplayName(name);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'uid': user.uid,
          'displayName': name,
          'email': mail,
          'createdAt': FieldValue.serverTimestamp(),
        });

        final server = await FirebaseFirestore.instance
            .collection('servers')
            .add({
          'name': 'PULSE Lounge',
          'ownerId': user.uid,
          'memberIds': [user.uid],
          'createdAt': FieldValue.serverTimestamp(),
        });

        await server.collection('messages').add({
          'uid': 'system',
          'displayName': 'PULSE',
          'text': 'Bem-vindo ao PULSE!',
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: mail,
          password: pass,
        );

        final user = credential.user!;

        final profile = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid);

        if (!(await profile.get()).exists) {
          await profile.set({
            'uid': user.uid,
            'displayName': user.displayName ?? mail.split('@').first,
            'email': mail,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
      }
    } on FirebaseAuthException catch (e) {
      showMessage(context, authError(e.code));
    } catch (e) {
      showMessage(context, 'Erro: $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.bolt_rounded,
                    color: pulseAccent,
                    size: 58,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'PULSE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 5,
                      color: pulseText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    creating
                        ? 'Crie sua conta e entre na comunidade.'
                        : 'Sua comunidade. Seu espaço.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: pulseMuted),
                  ),
                  const SizedBox(height: 34),

                  if (creating) ...[
                    TextField(
                      controller: displayName,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.person_outline),
                        hintText: 'Nome de exibição',
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  TextField(
                    controller: email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.mail_outline),
                      hintText: 'E-mail',
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: password,
                    obscureText: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.lock_outline),
                      hintText: 'Senha (mínimo 6 caracteres)',
                    ),
                  ),
                  const SizedBox(height: 20),

                  FilledButton(
                    onPressed: busy ? null : submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: pulseAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: busy
                        ? const CircularProgressIndicator()
                        : Text(creating ? 'CRIAR CONTA' : 'ENTRAR'),
                  ),

                  TextButton(
                    onPressed: busy
                        ? null
                        : () => setState(() => creating = !creating),
                    child: Text(
                      creating
                          ? 'Já tenho uma conta — entrar'
                          : 'Não tenho conta — criar agora',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
