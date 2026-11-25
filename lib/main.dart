
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const bg = Color(0xFF0B0D17);
const panel = Color(0xFF171A2B);
const accent = Color(0xFF8B5CF6);
const muted = Color(0xFF9A9AAF);

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
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          surface: panel,
        ),
        useMaterial3: true,
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
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return snapshot.data == null
            ? const LoginScreen()
            : const PulseHome();
      },
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  final name = TextEditingController();

  bool creating = false;
  bool loading = false;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    name.dispose();
    super.dispose();
  }

  void notify(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> submit() async {
    final mail = email.text.trim();
    final pass = password.text;

    if (mail.isEmpty || pass.length < 6 ||
        (creating && name.text.trim().isEmpty)) {
      notify('Preencha os campos. A senha precisa ter 6 caracteres.');
      return;
    }

    setState(() => loading = true);

    try {
      if (creating) {
        final result = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: mail,
          password: pass,
        );

        final user = result.user!;
        final displayName = name.text.trim();

        await user.updateDisplayName(displayName);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'uid': user.uid,
          'displayName': displayName,
          'email': mail,
          'bio': '',
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
          'text': 'Bem-vindo à sua primeira comunidade!',
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: mail,
          password: pass,
        );
      }
    } on FirebaseAuthException catch (e) {
      notify(authError(e.code));
    } catch (e) {
      notify('Erro: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.bolt, size: 65, color: accent),
                const SizedBox(height: 10),
                const Text(
                  'PULSE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  creating
                      ? 'Crie sua conta.'
                      : 'Sua comunidade. Seu espaço.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: muted),
                ),
                const SizedBox(height: 35),

                if (creating) ...[
                  TextField(
                    controller: name,
                    decoration: const InputDecoration(
                      labelText: 'Nome de exibição',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                TextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: password,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                const SizedBox(height: 22),

                FilledButton(
                  onPressed: loading ? null : submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: accent,
                    padding: const EdgeInsets.all(16),
                  ),
                  child: loading
                      ? const CircularProgressIndicator()
                      : Text(creating ? 'CRIAR CONTA' : 'ENTRAR'),
                ),

                TextButton(
                  onPressed: loading
                      ? null
                      : () => setState(() => creating = !creating),
                  child: Text(
                    creating
                        ? 'Já tenho uma conta'
                        : 'Criar uma conta',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PulseHome extends StatefulWidget {
  const PulseHome({super.key});

  @override
  State<PulseHome> createState() => _PulseHomeState();
}

class _PulseHomeState extends State<PulseHome> {
  String? selectedServer;

  User get user => FirebaseAuth.instance.currentUser!;

  Future<void> createServer() async {
    final controller = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Criar servidor'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Nome do servidor',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              controller.text.trim(),
            ),
            child: const Text('Criar'),
          ),
        ],
      ),
    );

    if (name == null || name.isEmpty) return;

    try {
      final ref = await FirebaseFirestore.instance
          .collection('servers')
          .add({
        'name': name,
        'ownerId': user.uid,
        'memberIds': [user.uid],
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() => selectedServer = ref.id);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final serverQuery = FirebaseFirestore.instance
        .collection('servers')
        .where('memberIds', arrayContains: user.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '⚡ PULSE',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accent,
        onPressed: createServer,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: serverQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Erro: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final servers = snapshot.data!.docs;

          if (servers.isEmpty) {
            return const Center(
              child: Text('Toque em + para criar seu primeiro servidor.'),
            );
          }

          final active = servers.firstWhere(
            (server) => server.id == selectedServer,
            orElse: () => servers.first,
          );

          final serverName =
              active.data()['name'] as String? ?? 'Servidor';

          return Column(
            children: [
              SizedBox(
                height: 75,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final server in servers)
                      Padding(
                        padding: const EdgeInsets.all(9),
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: server.id == active.id
                                ? accent
                                : panel,
                          ),
                          onPressed: () {
                            setState(() => selectedServer = server.id);
                          },
                          child: Text(
                            server.data()['name'] as String? ?? 'Servidor',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ServerChat(
                  key: ValueKey(active.id),
                  serverId: active.id,
                  serverName: serverName,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ServerChat extends StatefulWidget {
  final String serverId;
  final String serverName;

  const ServerChat({
    super.key,
    required this.serverId,
    required this.serverName,
  });

  @override
  State<ServerChat> createState() => _ServerChatState();
}

class _ServerChatState extends State<ServerChat> {
  final message = TextEditingController();

  User get user => FirebaseAuth.instance.currentUser!;

  @override
  void dispose() {
    message.dispose();
    super.dispose();
  }

  Future<void> sendMessage() async {
    final text = message.text.trim();

    if (text.isEmpty) return;

    message.clear();

    try {
      await FirebaseFirestore.instance
          .collection('servers')
          .doc(widget.serverId)
          .collection('messages')
          .add({
        'uid': user.uid,
        'displayName': user.displayName ??
            user.email?.split('@').first ??
            'User',
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = FirebaseFirestore.instance
        .collection('servers')
        .doc(widget.serverId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .snapshots();

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          child: Text(
            '# ${widget.serverName}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: messages,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Erro: ${snapshot.error}'),
                );
              }

              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final docs = snapshot.data!.docs;

              if (docs.isEmpty) {
                return const Center(
                  child: Text('Nenhuma mensagem ainda. Diga oi!'),
                );
              }

              return ListView.builder(
                reverse: true,
                padding: const EdgeInsets.all(12),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data();
                  final mine = data['uid'] == user.uid;

                  return Align(
                    alignment: mine
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.all(12),
                      constraints: BoxConstraints(
                        maxWidth:
                            MediaQuery.of(context).size.width * .75,
                      ),
                      decoration: BoxDecoration(
                        color: mine
                            ? const Color(0xFF49328A)
                            : panel,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mine
                                ? 'Você'
                                : data['displayName'] ?? 'Usuário',
                            style: const TextStyle(
                              color: Color(0xFFC5B5FF),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(data['text'] ?? ''),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: message,
                    minLines: 1,
                    maxLines: 4,
                    onSubmitted: (_) => sendMessage(),
                    decoration: const InputDecoration(
                      hintText: 'Enviar mensagem...',
                      filled: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: sendMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final name = TextEditingController();
  final bio = TextEditingController();
  bool loaded = false;

  User get user => FirebaseAuth.instance.currentUser!;

  @override
  void dispose() {
    name.dispose();
    bio.dispose();
    super.dispose();
  }

  Future<void> saveProfile() async {
    final displayName = name.text.trim();

    if (displayName.isEmpty) return;

    try {
      await user.updateDisplayName(displayName);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'displayName': displayName,
        'email': user.email,
        'bio': bio.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu perfil')),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get(),
        builder: (context, snapshot) {
          if (!loaded && snapshot.hasData) {
            final data = snapshot.data!.data() ?? {};

            name.text = data['displayName'] as String? ??
                user.displayName ??
                user.email?.split('@').first ??
                '';

            bio.text = data['bio'] as String? ?? '';
            loaded = true;
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const CircleAvatar(
                radius: 45,
                backgroundColor: accent,
                child: Icon(Icons.person, size: 45),
              ),
              const SizedBox(height: 25),
              TextField(
                controller: name,
 
