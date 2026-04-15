import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => WasteManagementSystem(),
      child: const CorporateWasteApp(),
    ),
  );
}

class CorporateWasteApp extends StatelessWidget {
  const CorporateWasteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, primary: Colors.teal),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}

// --- UPDATED STATE MANAGEMENT (With Sender Info) ---
class WasteManagementSystem extends ChangeNotifier {
  String _specialDriveInfo = "No active special drives.";
  String _driverAlert = "Trucks are running on schedule.";
  String _lastDriverName = "Main Fleet";
  final List<Map<String, String>> _schedules = [];
  final List<String> _complaints = [];
  double _balanceDue = 50.00;

  // Getters
  String get specialDrive => _specialDriveInfo;
  String get driverAlert => _driverAlert;
  String get driverName => _lastDriverName;
  List<Map<String, String>> get schedules => _schedules;
  List<String> get complaints => _complaints;
  double get balanceDue => _balanceDue;

  void assignZone(String zone, DateTime date, String supervisorName) {
    String formattedDate = DateFormat('EEE, MMM d').format(date);
    _schedules.insert(0, {"zone": zone, "date": formattedDate, "by": supervisorName});
    notifyListeners();
  }

  void sendDelayAlert(String reason, String driverName) {
    _driverAlert = reason;
    _lastDriverName = driverName;
    notifyListeners();
  }

  void postComplaint(String text) {
    _complaints.add(text);
    notifyListeners();
  }

  void processPayment() {
    _balanceDue = 0.00;
    notifyListeners();
  }

  void updateSpecialDrive(String driveType) {
    _specialDriveInfo = "UPCOMING: $driveType collection drive!";
    notifyListeners();
  }
}

// --- PRETTIER LOGIN SCREEN ---
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.teal, Colors.tealAccent],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 80),
            const Icon(Icons.recycling, size: 80, color: Colors.white),
            const Text(
              "EcoSync",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2),
            ),
            const Text("Corporate Waste Management", style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 50),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text("Select User Portal", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      _roleCard(context, "Admin", Icons.admin_panel_settings, Colors.deepPurple, const AdminDashboard()),
                      _roleCard(context, "Supervisor", Icons.supervisor_account, Colors.blue, const SupervisorDashboard()),
                      _roleCard(context, "Driver", Icons.local_shipping, Colors.orange, const DriverDashboard()),
                      _roleCard(context, "Resident", Icons.home_work, Colors.green, const ResidentDashboard()),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleCard(BuildContext context, String title, IconData icon, Color color, Widget nextScreen) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withOpacity(0.2), child: Icon(icon, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Access $title tools"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => nextScreen)),
      ),
    );
  }
}

// --- RESIDENT DASHBOARD (With Source Details) ---
class ResidentDashboard extends StatelessWidget {
  const ResidentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<WasteManagementSystem>(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(title: const Text("Resident Portal"), actions: [_logoutBtn(context)]),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildAlertTile("Live Traffic Alert", provider.driverAlert, "Sender: ${provider.driverName}", Colors.orange),
          _buildAlertTile("Special Announcement", provider.specialDrive, "Sender: Admin Office", Colors.blue),
          const SizedBox(height: 20),
          const Text("Pickup Schedules", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...provider.schedules.map((s) => Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.teal),
              title: Text(s['zone']!),
              subtitle: Text("Date: ${s['date']}"),
              trailing: Text("By: ${s['by']}", style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic)),
            ),
          )),
          const Divider(height: 40),
          Card(
            color: Colors.teal.shade700,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Due Payments", style: TextStyle(color: Colors.white70)),
                      Text("\$${provider.balanceDue}", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: provider.balanceDue > 0 ? () => provider.processPayment() : null,
                    child: Text(provider.balanceDue > 0 ? "Pay Now" : "Paid"),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertTile(String title, String msg, String sender, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
              Text(sender, style: const TextStyle(color: Colors.grey, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 5),
          Text(msg, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// --- SUPERVISOR DASHBOARD (Date Picker Fixed) ---
class SupervisorDashboard extends StatefulWidget {
  const SupervisorDashboard({super.key});
  @override
  State<SupervisorDashboard> createState() => _SupervisorDashboardState();
}

class _SupervisorDashboardState extends State<SupervisorDashboard> {
  final TextEditingController _zone = TextEditingController();
  DateTime? _date;

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<WasteManagementSystem>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: const Text("Supervisor"), actions: [_logoutBtn(context)]),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(controller: _zone, decoration: const InputDecoration(labelText: "Zone/Area", border: OutlineInputBorder())),
            const SizedBox(height: 15),
            ListTile(
              tileColor: Colors.teal.withOpacity(0.1),
              title: Text(_date == null ? "Select Schedule Date" : DateFormat('yyyy-MM-dd').format(_date!)),
              trailing: const Icon(Icons.edit_calendar),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2027),
                );
                if (picked != null) setState(() => _date = picked);
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                onPressed: () {
                  if (_date != null && _zone.text.isNotEmpty) {
                    p.assignZone(_zone.text, _date!, "Supervisor John");
                    Navigator.pop(context);
                  }
                },
                child: const Text("Broadcast to Residents"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- DRIVER DASHBOARD ---
class DriverDashboard extends StatelessWidget {
  const DriverDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Driver Portal"), actions: [_logoutBtn(context)]),
      body: GridView.count(
        padding: const EdgeInsets.all(20),
        crossAxisCount: 2,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        children: [
          _driverAction(context, "Heavy Traffic", Colors.orange, Icons.traffic),
          _driverAction(context, "Truck Issue", Colors.red, Icons.build),
          _driverAction(context, "Road Block", Colors.brown, Icons.block),
          _driverAction(context, "On Time", Colors.green, Icons.check_circle),
        ],
      ),
    );
  }

  Widget _driverAction(BuildContext context, String reason, Color color, IconData icon) {
    return InkWell(
      onTap: () {
        Provider.of<WasteManagementSystem>(context, listen: false).sendDelayAlert(reason, "Driver - Truck #402");
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Alert Sent: $reason")));
      },
      child: Container(
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(icon, color: Colors.white, size: 40), const SizedBox(height: 10), Text(reason, style: const TextStyle(color: Colors.white))],
        ),
      ),
    );
  }
}

// --- ADMIN DASHBOARD ---
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Panel"), actions: [_logoutBtn(context)]),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text("Manage Special Drives", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          _adminTile(context, "E-Waste Collection", Icons.battery_alert, Colors.blue),
          _adminTile(context, "Plastic Drive", Icons.eco, Colors.green),
          _adminTile(context, "Chemical Waste", Icons.science, Colors.red),
        ],
      ),
    );
  }

  Widget _adminTile(BuildContext context, String type, IconData icon, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(type),
      onTap: () {
        Provider.of<WasteManagementSystem>(context, listen: false).updateSpecialDrive(type);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Broadcast Updated")));
      },
    );
  }
}

Widget _logoutBtn(BuildContext context) {
  return IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.logout, color: Colors.black));
}



//yaml
//name: corporate_waste_mgmt
// description: "A new Flutter project for corporate waste management."
// publish_to: 'none'
//
// version: 1.0.0+1
//
// environment:
//   sdk: ^3.6.0  # <--- THIS IS THE FIX FOR YOUR ERROR
//
// dependencies:
//   flutter:
//     sdk: flutter
//   provider: ^6.1.1
//   intl: ^0.19.0
//   cupertino_icons: ^1.0.8
//
// dev_dependencies:
//   flutter_test:
//     sdk: flutter
//   flutter_lints: ^5.0.0
//
// flutter:
//   uses-material-design: true
