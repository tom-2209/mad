import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;
import 'package:intl/intl.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ElectionSystem(),
      child: const ElectionApp(),
    ),
  );
}

// --- SYSTEM STATE (Handles Caching & News) ---
class ElectionSystem extends ChangeNotifier {
  final List<Map<String, String>> _newsFeed = [];
  final Map<String, String> _redisCache = {};
  bool _isSubscribed = false;

  List<Map<String, String>> get news => _newsFeed;
  bool get isSubscribed => _isSubscribed;

  void toggleSubscription() {
    _isSubscribed = !_isSubscribed;
    notifyListeners();
  }

  // Caching: Simulates high-speed data retrieval for multiple users
  String getCachedDetails(String zone) {
    if (_redisCache.containsKey(zone)) {
      debugPrint("SERVER: [CACHE HIT] Serving $zone from Redis");
      return _redisCache[zone]!;
    }
    debugPrint("SERVER: [CACHE MISS] Fetching Database for $zone");
    String detail = "Live Count: Leading Candidate has 52% of votes in $zone.";
    _redisCache[zone] = detail;
    return detail;
  }

  void pushBroadcast(String title, String zone) {
    _newsFeed.insert(0, {
      "title": title,
      "zone": zone,
      "time": DateFormat('HH:mm:ss').format(DateTime.now()),
    });
    notifyListeners();
  }
}

// --- SERVER HUB ---
class ServerHub {
  static Future<void> start(BuildContext context) async {
    final sys = Provider.of<ElectionSystem>(context, listen: false);
    final router = shelf_router.Router();

    router.post('/broadcast', (Request request) async {
      final data = jsonDecode(await request.readAsString());
      sys.pushBroadcast(data['news'], data['zone']);
      return Response.ok("News Pushed Successfully");
    });

    var handler = const Pipeline()
        .addMiddleware(logRequests())
        .addHandler(router.call);

    await io.serve(handler, 'localhost', 8080);
    debugPrint("Election Server Load Balanced on Port 8080");
  }
}

// --- UI NAVIGATION ---
class ElectionApp extends StatelessWidget {
  const ElectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.blueAccent,
        useMaterial3: true,
      ),
      home: const LoginPortal(),
    );
  }
}

// --- LOGIN PORTAL ---
class LoginPortal extends StatelessWidget {
  const LoginPortal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                begin: Alignment.topLeft,
              ),
            ),
          ),
          Center(
            child: Container(
              width: 350,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.security, size: 60, color: Colors.blueAccent),
                  const SizedBox(height: 20),
                  const Text("Election Cloud Login", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 30),
                  _roleBtn(context, "Admin Portal", Icons.admin_panel_settings, Colors.redAccent, const AdminDashboard()),
                  const SizedBox(height: 15),
                  _roleBtn(context, "User Dashboard", Icons.person, Colors.blueAccent, const UserDashboard()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _roleBtn(BuildContext context, String label, IconData icon, Color color, Widget page) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          ServerHub.start(context); // Start Server
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
        icon: Icon(icon),
        label: Text(label),
      ),
    );
  }
}

// --- ADMIN DASHBOARD ---
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _controller = TextEditingController();
  String _zone = "Central Constituency";

  @override
  Widget build(BuildContext context) {
    final sys = Provider.of<ElectionSystem>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text("Server Admin Console")),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            DropdownButtonFormField(
              value: _zone,
              items: ["Central Constituency", "North Sector", "South Valley"]
                  .map((z) => DropdownMenuItem(value: z, child: Text(z)))
                  .toList(),
              onChanged: (val) => setState(() => _zone = val!),
              decoration: const InputDecoration(labelText: "Target Constituency"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "Enter Breaking News Update...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (_controller.text.isNotEmpty) {
                    sys.pushBroadcast(_controller.text, _zone);
                    _controller.clear();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Broadcast Pushed to Server")));
                  }
                },
                child: const Text("PUSH BROADCAST"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- USER DASHBOARD ---
class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final sys = Provider.of<ElectionSystem>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Election Feed"),
        actions: [
          Row(
            children: [
              const Text("Subscribed", style: TextStyle(fontSize: 12)),
              Switch(value: sys.isSubscribed, onChanged: (v) => sys.toggleSubscription()),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.black87,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.sync, color: Colors.greenAccent, size: 14),
                Text("  Server: 127.0.0.1:8080 | Load Balancer: Healthy",
                    style: TextStyle(color: Colors.greenAccent, fontSize: 11)),
              ],
            ),
          ),
          Expanded(
            child: !sys.isSubscribed
                ? const Center(child: Text("Turn on Subscription to see updates"))
                : sys.news.isEmpty
                ? const Center(child: Text("No news updates yet..."))
                : ListView.builder(
              itemCount: sys.news.length,
              itemBuilder: (context, i) {
                final item = sys.news[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: const CircleAvatar(backgroundColor: Colors.blue, child: Icon(Icons.campaign, color: Colors.white)),
                    title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("${item['zone']} • ${item['time']}"),
                    onTap: () {
                      String detail = sys.getCachedDetails(item['zone']!);
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(item['zone']!),
                          content: Text(detail),
                          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}







//name: election_system_pro
// description: "High-performance Election News Server"
// publish_to: 'none'
// version: 1.0.0+1
//
// environment:
//   sdk: ^3.6.0
//
// dependencies:
//   flutter:
//     sdk: flutter
//   shelf: ^1.4.1
//   shelf_router: ^1.1.4
//   provider: ^6.1.1
//   intl: ^0.19.0
//
// flutter:
//   uses-material-design: true
