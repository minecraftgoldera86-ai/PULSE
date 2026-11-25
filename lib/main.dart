
import 'package:flutter/material.dart';

void main() {
  runApp(const PulseApp());
}

const Color bg = Color(0xFF101019);
const Color panel = Color(0xFF191925);
const Color purple = Color(0xFF8B5CF6);
const Color muted = Color(0xFF9A9AAF);

class PulseApp extends StatelessWidget {
  const PulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PULSE',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: purple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class PulseServer {
  String name;
  final List<String> channels;

  PulseServer(this.name, this.channels);
}

class PulseMessage {
  final String author;
  final String text;
  final bool mine;

  PulseMessage(this.author, this.text, this.mine);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;
  int selectedServer = 0;
  String username = 'PULSE User';

  final List<PulseServer> servers = [
    PulseServer('PULSE Community', ['general', 'memes', 'gaming']),
    PulseServer('Gaming Hub', ['chat', 'clips']),
  ];

  final List<PulseMessage> messages = [
    PulseMessage('PULSE Bot', 'Welcome to PULSE!', false),
    PulseMessage('Alex', 'Hey everyone!', false),
    PulseMessage('You', 'Hello 👋', true),
  ];

  final TextEditingController messageController =
      TextEditingController();

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add(PulseMessage(username, text, true));
      messageController.clear();
    });
  }

  void createServer() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
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
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  setState(() {
                    servers.add(
                      PulseServer(name, ['general']),
                    );
                    selectedServer = servers.length - 1;
                    tab = 0;
                  });
                }
                Navigator.pop(dialogContext);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void createChannel() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: panel,
          title: const Text('Create channel'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Channel name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final name = controller.text
                    .trim()
                    .replaceAll(' ', '-')
                    .toLowerCase();

                if (name.isNotEmpty && servers.isNotEmpty) {
                  setState(() {
                    servers[selectedServer].channels.add(name);
                  });
                }

                Navigator.pop(dialogContext);
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void editProfile() {
    final controller = TextEditingController(text: username);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: panel,
          title: const Text('Edit profile'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Display name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    username = controller.text.trim();
                  });
                }
                Navigator.pop(dialogContext);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      serversPage(),
      chatsPage(),
      activityPage(),
      profilePage(),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: tab,
          children: pages,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: panel,
        selectedIndex: tab,
        indicatorColor: purple.withAlpha(60),
        onDestinationSelected: (index) {
          setState(() => tab = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.hub_outlined),
            selectedIcon: Icon(Icons.hub),
            label: 'Servers',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Activity',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget serversPage() {
    return Column(
      children: [
        header('SERVERS', Icons.hub),
        Expanded(
          child: Row(
            children: [
              Container(
                width: 76,
                color: panel,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    ...List.generate(servers.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedServer = index;
                            });
                          },
                          child: CircleAvatar(
                            radius: 24,
                            backgroundColor:
                                selectedServer == index
                                    ? purple
                                    : const Color(0xFF303044),
                            child: Text(
                              servers[index].name[0].toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                    IconButton(
                      onPressed: createServer,
                      icon: const Icon(
                        Icons.add_circle,
                        color: purple,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: servers.isEmpty
                    ? const Center(
                        child: Text('Create your first server'),
                      )
                    : serverContent(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget serverContent() {
    final server = servers[selectedServer];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  server.name,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: createChannel,
                icon: const Icon(Icons.add),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            'TEXT CHANNELS',
            style: TextStyle(
              color: muted,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ...server.channels.map((channel) {
          return ListTile(
            leading: const Icon(
              Icons.tag,
              color: muted,
            ),
            title: Text(channel),
            onTap: () {
              setState(() => tab = 1);
            },
          );
        }),
        const Spacer(),
        const Padding(
          padding: EdgeInsets.all(18),
          child: Text(
            'PULSE COMMUNITY',
            style: TextStyle(color: muted),
          ),
        ),
      ],
    );
  }

  Widget chatsPage() {
    return Column(
      children: [
        header('MESSAGES', Icons.chat),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];

                    return Align(
                      alignment: message.mine
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        constraints: const BoxConstraints(
                          maxWidth: 290,
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: message.mine
                              ? purple.withAlpha(65)
                              : panel,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.author,
                              style: const TextStyle(
                                color: purple,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(message.text),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              messageInput(),
            ],
          ),
        ),
      ],
    );
  }

  Widget messageInput() {
    return Container(
      padding: const EdgeInsets.all(12),
      color: panel,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: messageController,
              onSubmitted: (_) => sendMessage(),
              decoration: InputDecoration(
                hintText: 'Write a message...',
                filled: true,
                fillColor: bg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
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
    );
  }

  Widget activityPage() {
    return Column(
      children: [
        header('ACTIVITY', Icons.notifications),
        const Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 65,
                  color: muted,
                ),
                SizedBox(height: 12),
                Text(
                  'You are all caught up!',
                  style: TextStyle(
                    color: muted,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget profilePage() {
    return Column(
      children: [
        header('YOUR PROFILE', Icons.person),
        const SizedBox(height: 40),
        const CircleAvatar(
          radius: 52,
          backgroundColor: purple,
          child: Icon(
            Icons.person,
            size: 55,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          username,
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          'PULSE member',
          style: TextStyle(color: muted),
        ),
        const SizedBox(height: 25),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: editProfile,
              icon: const Icon(Icons.edit),
              label: const Text('Edit profile'),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const ListTile(
          leading: Icon(Icons.settings_outlined),
          title: Text('Settings'),
          trailing: Icon(Icons.chevron_right),
        ),
        const ListTile(
          leading: Icon(Icons.privacy_tip_outlined),
          title: Text('Privacy'),
          trailing: Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget header(String title, IconData icon) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: panel,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF29293A),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: purple),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
