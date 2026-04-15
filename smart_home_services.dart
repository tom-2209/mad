import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ServiceProvider(),
      child: const SmartHomeApp(),
    ),
  );
}

// --- DATA MODELS ---
class HomeService {
  final String name;
  final double price;
  final double rating;
  final IconData icon;

  HomeService({required this.name, required this.price, required this.rating, required this.icon});
}

class Order {
  final HomeService service;
  final DateTime date;
  final String timeSlot;
  String status; // Pending, Confirmed, Solved

  Order({required this.service, required this.date, required this.timeSlot, this.status = "Pending"});
}

// --- STATE MANAGEMENT ---
class ServiceProvider extends ChangeNotifier {
  final List<HomeService> availableServices = [
    HomeService(name: "AC Repair", price: 1200.0, rating: 4.8, icon: Icons.ac_unit),
    HomeService(name: "Deep Cleaning", price: 2500.0, rating: 4.9, icon: Icons.clean_hands),
    HomeService(name: "Plumbing", price: 800.0, rating: 4.5, icon: Icons.plumbing),
    HomeService(name: "Electrical", price: 950.0, rating: 4.7, icon: Icons.electrical_services),
    HomeService(name: "Pest Control", price: 1800.0, rating: 4.6, icon: Icons.bug_report),
  ];

  final List<Order> _orders = [];
  List<Order> get orders => _orders;

  double get cumulativeTotal => _orders.fold(0, (sum, item) => sum + item.service.price);

  void placeOrder(HomeService service, DateTime date, String slot) {
    _orders.add(Order(service: service, date: date, timeSlot: slot));
    notifyListeners();
  }

  void updateStatus(int index) {
    if (_orders[index].status == "Pending") {
      _orders[index].status = "Confirmed";
    } else if (_orders[index].status == "Confirmed") {
      _orders[index].status = "Solved";
    }
    notifyListeners();
  }
}

// --- UI SECTIONS ---
class SmartHomeApp extends StatelessWidget {
  const SmartHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.blueAccent, useMaterial3: true),
      home: const ServiceMarketplace(),
    );
  }
}

class ServiceMarketplace extends StatelessWidget {
  const ServiceMarketplace({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ServiceProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Home Services"),
        actions: [
          IconButton(
            icon: Badge(
              label: Text(provider.orders.length.toString()),
              child: const Icon(Icons.receipt_long),
            ),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderHistoryPage())),
          )
        ],
      ),
      body: Column(
        children: [
          // Cumulative Bill Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.blueAccent.withOpacity(0.1),
            child: Column(
              children: [
                const Text("Cumulative Bill Amount", style: TextStyle(fontSize: 14, color: Colors.blueGrey)),
                Text("₹${provider.cumulativeTotal.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: provider.availableServices.length,
              itemBuilder: (context, index) {
                final service = provider.availableServices[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(child: Icon(service.icon)),
                    title: Text(service.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        Text(" ${service.rating}  •  ₹${service.price}"),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => _showBookingSheet(context, service),
                      child: const Text("Book"),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingSheet(BuildContext context, HomeService service) {
    DateTime selectedDate = DateTime.now();
    String selectedSlot = "10:00 AM - 12:00 PM";
    final slots = ["08:00 AM - 10:00 AM", "10:00 AM - 12:00 PM", "02:00 PM - 04:00 PM", "04:00 PM - 06:00 PM"];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Book ${service.name}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ListTile(
                title: Text("Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  if (picked != null) setSheetState(() => selectedDate = picked);
                },
              ),
              const Text("Select Time Slot:", style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 10,
                children: slots.map((s) => ChoiceChip(
                  label: Text(s),
                  selected: selectedSlot == s,
                  onSelected: (val) => setSheetState(() => selectedSlot = s),
                )).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, foregroundColor: Colors.white),
                  onPressed: () {
                    Provider.of<ServiceProvider>(context, listen: false).placeOrder(service, selectedDate, selectedSlot);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Service Booked Successfully!")));
                  },
                  child: const Text("Confirm Booking"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ServiceProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Final Orders & Status")),
      body: provider.orders.isEmpty
          ? const Center(child: Text("No bookings yet"))
          : ListView.builder(
        itemCount: provider.orders.length,
        itemBuilder: (context, index) {
          final order = provider.orders[index];
          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text(order.service.name),
              subtitle: Text("${DateFormat('dd MMM').format(order.date)} | ${order.timeSlot}"),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _statusChip(order.status),
                  const SizedBox(height: 4),
                  if (order.status != "Solved")
                    GestureDetector(
                      onTap: () => provider.updateStatus(index),
                      child: const Text("Next Step", style: TextStyle(fontSize: 10, color: Colors.blue)),
                    )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _statusChip(String status) {
    Color color = Colors.orange;
    if (status == "Confirmed") color = Colors.blue;
    if (status == "Solved") color = Colors.green;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Text(status, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }
}








//name: smart_home_services
// description: "Smart Home Service Booking App"
// publish_to: 'none'
// version: 1.0.0+1
//
// environment:
//   sdk: ^3.6.0
//
// dependencies:
//   flutter:
//     sdk: flutter
//   provider: ^6.1.1
//   intl: ^0.19.0
//
// flutter:
//   uses-material-design: true
