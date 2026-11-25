
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const PulseApp());
}

const bg = Color(0xFF101218);
const panel = Color(0xFF191D27);
const accent = Color(0xFF8B5CF6);
const muted = Color(0xFF9298A8);

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
          seedColor: accent,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class ChatMessage {
  final String sender;
  final String text;
  final bool mine;

  ChatMessage(this.sender, this.text, {this.mine = false});
}

class PulseServer {
  final String name;
  final IconData icon;
  final List<String> channels;

  PulseServer(this.name, this.icon, this.channels);
}

Widget pulseAvatar(String? path, String name, double radius) {
  return CircleAvatar(
    radius: radius,
    backgroundColor: accent.withOpacity(0.25),
    backgroundImage: path != null ? FileImage(File(path)) : null,
    child: path == null
        ? Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: radius * 0.8,
            ),
          )
        : null,
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;
  String username = 'PULSE User';
  String? avatarPath;

  final picker = ImagePicker();

  final List<PulseServer> servers = [
    PulseServer('PULSE HQ', Icons.bolt, ['general', 'announcements']),
    PulseServer('Gaming', Icons.sports_esports, ['chat', 'clips']),
  ];

  final List<String> friends = ['Alex', 'Jordan', 'Taylor', 'Morgan'];

  Future<void> changeAvatar() async {
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 900,
    );

    if (image != null && mounted) {
      setState(() => avatarPath = image.path);
    }
  }

  void createServer() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: panel,
        title: const Text('Create server'),
        content: TextField(
          controller: controller,
          autofocus: true,
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
                    PulseServer(name, Icons.groups, ['general']),
                  );
                });
              }

              Navigator.pop(dialogContext);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void editName() {
    final controller = TextEditingController(text: username);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: panel,
        title: const Text('Display name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Your name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() => username = controller.text.trim());
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget header(String title, {Widget? action}) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      color: panel,
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const Spacer(),
          if (action != null) action,
        ],
      ),
    );
  }

  Widget serversPage() {
    return Column(
      children: [
        header(
          'SERVERS',
          action: IconButton(
            onPressed: createServer,
            icon: const Icon(Icons.add),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(14),
            children: [
              for (final server in servers)
                Card(
                  color: panel,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: accent.withOpacity(0.2),
                      child: Icon(server.icon, color: accent),
                    ),
                    title: Text(
                      server.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('${server.channels.length} channels'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ServerPage(server: server),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: createServer,
                icon: const Icon(Icons.add),
                label: const Text('Create a server'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget chatsPage() {
    return Column(
      children: [
        header('DIRECT MESSAGES'),
        Expanded(
          child: ListView(
            children: [
              for (final friend in friends)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 5,
                  ),
                  leading: pulseAvatar(null, friend, 24),
                  title: Text(friend),
                  subtitle: const Text(
                    'Tap to open conversation',
                    style: TextStyle(color: muted),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DirectPage(friend: friend),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget activityPage() {
    return Column(
      children: [
        header('ACTIVITY'),
        const Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.notifications_none, size: 55, color: muted),
                SizedBox(height: 12),
                Text('You are all caught up!'),
                SizedBox(height: 5),
                Text(
                  'New activity will appear here.',
                  style: TextStyle(color: muted),
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
        header('YOUR PROFILE'),
        const SizedBox(height: 35),
        GestureDetector(
          onTap: changeAvatar,
          child: Stack(
            children: [
              pulseAvatar(avatarPath, username, 55),
              const Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: accent,
                  child: Icon(Icons.edit, size: 16),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Text(
          username,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          'Tap your photo to change it',
          style: TextStyle(color: muted),
        ),
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Card(
            color: panel,
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Display name'),
                  subtitle: Text(username),
                  trailing: const Icon(Icons.edit),
                  onTap: editName,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.photo_outlined),
                  title: const Text('Change profile photo'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: changeAvatar,
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.settings_outlined),
                  title: Text('Settings'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
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
      body: SafeArea(child: pages[tab]),
      bottomNavigationBar: NavigationBar(
        backgroundColor: panel,
        selectedIndex: tab,
        indicatorColor: accent.withOpacity(0.25),
        onDestinationSelected: (index) {
          setState(() => tab = index);
        },
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
}

class DirectPage extends StatefulWidget {
  final String friend;

  const DirectPage({super.key, required this.friend});

  @override
  State<DirectPage> createState() => _DirectPageState();
}

class _DirectPageState extends State<DirectPage> {
  final controller = TextEditingController();
  final List<ChatMessage> messages = [];

  @override
  void initState() {
    super.initState();
    messages.addAll([
      ChatMessage(widget.friend, 'Hey! Welcome to PULSE.'),
      ChatMessage('You', 'Thanks! This looks awesome.', mine: true),
      ChatMessage(widget.friend, 'Ready to chat?'),
    ]);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void sendMessage() {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add(ChatMessage('You', text, mine: true));
      controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: panel,
        title: Row(
          children: [
            pulseAvatar(null, widget.friend, 18),
            const SizedBox(width: 10),
            Text(widget.friend),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      pulseAvatar(
                        null,
                        message.mine ? 'Y' : widget.friend,
                        20,
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.sender,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(message.text),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          messageInput(controller, sendMessage),
        ],
      ),
    );
  }
}

class ServerPage extends StatefulWidget {
  final PulseServer server;

  const ServerPage({super.key, required this.server});

  @override
  State<ServerPage> createState() => _ServerPageState();
}

class _ServerPageState extends State<ServerPage> {
  int selectedChannel = 0;
  final controller = TextEditingController();
  final Map<String, List<ChatMessage>> channelMessages = {};

  @override
  void initState() {
    super.initState();

    for (final channel in widget.server.channels) {
      channelMessages[channel] = [
        ChatMessage('PULSE Bot', 'Welcome to #$channel!'),
        ChatMessage('Alex', 'Hey everyone!'),
      ];
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void addChannel() {
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: panel,
        title: const Text('Create channel'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'channel-name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text
                  .trim()
                  .toLowerCase()
                  .replaceAll(' ', '-');

              if (name.isNotEmpty &&
                  !widget.server.channels.contains(name)) {
                setState(() {
                  widget.server.channels.add(name);
                  channelMessages[name] = [];
                  selectedChannel = widget.server.channels.length - 1;
                });
              }

              Navigator.pop(dialogContext);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void sendMessage() {
    final text = controller.text.trim();
    if (text.isEmpty) return;

    final channel = widget.server.channels[selectedChannel];

    setState(() {
      channelMessages[channel]!.add(
        ChatMessage('You', text, mine: true),
      );
      controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final channel = widget.server.channels[selectedChannel];
    final messages = channelMessages[channel] ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: panel,
        title: Text(widget.server.name),
      ),
      body: Row(
        children: [
          SizedBox(
            width: 126,
            child: Container(
              color: panel,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'CHANNELS',
                      style: TextStyle(
                        fontSize: 11,
                        color: muted,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.server.channels.length,
                      itemBuilder: (context, index) {
                        final name = widget.server.channels[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          child: Material(
                            color: selectedChannel == index
                                ? accent.withOpacity(0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                setState(() => selectedChannel = index);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.tag,
                                      size: 15,
                                      color: muted,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        name,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  IconButton(
                    onPressed: addChannel,
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: 'Add channel',
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.centerLeft,
                  decoration: const BoxDecoration(
                    border: Border(
    
