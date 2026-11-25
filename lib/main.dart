
import 'package:flutter/material.dart';

void main() {
  runApp(const PulseApp());
}

const bg = Color(0xFF101116);
const panel = Color(0xFF191B24);
const accent = Color(0xFF8B5CF6);

class PulseApp extends StatelessWidget {
  const PulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PULSE',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.dark,
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;
  final servers = ['PULSE HQ', 'Gaming Zone', 'Friends'];
  final chats = ['Alex', 'Jordan', 'Taylor'];
  final messages = <String>[];

  void createServer() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: panel,
        title: const Text('Create a server'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Server name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() => servers.add(controller.text.trim()));
              }
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void editProfile() {
    final controller = TextEditingController(text: 'PULSE User');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: panel,
        title: const Text('Edit display name'),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              setState(() => displayName = controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  String displayName = 'PULSE User';

  @override
  Widget build(BuildContext context) {
    final pages = [
      serversPage(),
      chatsPage(),
      activityPage(),
      profilePage(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: bg,
        title: const Row(
          children: [
            Icon(Icons.bolt, color: accent, size: 28),
            SizedBox(width: 8),
            Text(
              'PULSE',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: pages[tab],
      bottomNavigationBar: NavigationBar(
        backgroundColor: panel,
        selectedIndex: tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view),
            label: 'Servers',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_none),
            label: 'Activity',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget serversPage() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'YOUR COMMUNITIES',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 12,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 14),
        ...servers.map((s) => Card(
              color: panel,
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: accent,
                  child: Icon(Icons.bolt, color: Colors.white),
                ),
                title: Text(s),
                subtitle: const Text('Community server'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: panel,
                    title: Text(s),
                    content: const Text(
                      '# general\n# announcements\n\nChannels coming soon.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ),
              ),
            )),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: createServer,
          icon: const Icon(Icons.add),
          label: const Text('Create a server'),
        ),
      ],
    );
  }

  Widget chatsPage() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'DIRECT MESSAGES',
          style: TextStyle(color: Colors.white54, letterSpacing: 2),
        ),
        const SizedBox(height: 12),
        ...chats.map((name) => Card(
              color: panel,
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(name),
                subtitle: const Text('Tap to open conversation'),
                onTap: () => openChat(name),
              ),
            )),
      ],
    );
  }

  void openChat(String name) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: panel,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 18,
          right: 18,
          top: 22,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(name, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 16),
            ...messages.map((m) => ListTile(
                  title: Text(m, textAlign: TextAlign.right),
                )),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Write a message...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (controller.text.trim().isNotEmpty) {
                      setState(() => messages.add(controller.text.trim()));
                      controller.clear();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget activityPage() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none, size: 55, color: accent),
          SizedBox(height: 12),
          Text('You are all caught up!'),
          Text('Your activity will appear here.',
              style: TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }

  Widget profilePage() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 42,
            backgroundColor: accent,
            child: Icon(Icons.person, size: 45),
          ),
          const SizedBox(height: 16),
          Text(displayName, style: const TextStyle(fontSize: 22)),
          const Text('Welcome to PULSE',
              style: TextStyle(color: Colors.white54)),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: editProfile,
            icon: const Icon(Icons.edit),
            label: const Text('Edit profile'),
          ),
        ],
      ),
    );
  }
}
