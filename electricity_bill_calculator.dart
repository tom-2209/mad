import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => BillProvider(),
      child: const ElectricityApp(),
    ),
  );
}

class ElectricityApp extends StatelessWidget {
  const ElectricityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
      ),
      home: const CalculatorScreen(),
    );
  }
}

// --- LOGIC PROVIDER ---
class BillProvider extends ChangeNotifier {
  String selectedAppliance = 'Fan';
  double powerWatts = 75;
  double hoursPerDay = 8;
  int days = 30;
  double costPerUnit = 7.0; // Average ₹7 per unit (kWh) in India

  // Mathematical Calculations
  double get totalKWh => (powerWatts * hoursPerDay * days) / 1000;
  double get monthlyBill => totalKWh * costPerUnit;
  double get yearlyProjection => monthlyBill * 12;

  // Dynamic UI Color Logic
  Color get usageColor {
    if (monthlyBill > 2000) return Colors.redAccent;    // High Bill
    if (monthlyBill > 800) return Colors.orangeAccent;  // Medium Bill
    return Colors.greenAccent.shade700;                 // Economical
  }

  void updateAppliance(String? val) {
    selectedAppliance = val!;
    if (val == 'Fan') powerWatts = 75;
    if (val == 'Ac') powerWatts = 1800;
    if (val == 'Refrigerator') powerWatts = 250;
    if (val == 'Washing Machine') powerWatts = 600;
    notifyListeners();
  }

  void updatePower(double val) { powerWatts = val; notifyListeners(); }
  void updateHours(double val) { hoursPerDay = val; notifyListeners(); }
  void updateCost(double val) { costPerUnit = val; notifyListeners(); }
}

// --- UI SCREEN ---
class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BillProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("₹ Electricity Calculator"),
        backgroundColor: provider.usageColor.withOpacity(0.2),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 1. DYNAMIC ENERGY METER
            _buildEnergyMeter(provider),

            const SizedBox(height: 30),

            // 2. USER INPUTS (SLIDERS & DROPDOWN)
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: provider.selectedAppliance,
                      items: ['Fan', 'Ac', 'Refrigerator', 'Washing Machine']
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: provider.updateAppliance,
                      decoration: const InputDecoration(
                        labelText: "Select Appliance",
                        prefixIcon: Icon(Icons.electrical_services),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildSlider(
                      label: "Power Consumption",
                      valueText: "${provider.powerWatts.toInt()} Watts",
                      val: provider.powerWatts,
                      min: 10,
                      max: 4000,
                      onChanged: provider.updatePower,
                      activeColor: provider.usageColor,
                    ),
                    _buildSlider(
                      label: "Daily Usage",
                      valueText: "${provider.hoursPerDay.toStringAsFixed(1)} Hrs",
                      val: provider.hoursPerDay,
                      min: 0.5,
                      max: 24,
                      onChanged: provider.updateHours,
                      activeColor: provider.usageColor,
                    ),
                    _buildSlider(
                      label: "Electricity Rate (per Unit)",
                      valueText: "₹${provider.costPerUnit.toStringAsFixed(1)}",
                      val: provider.costPerUnit,
                      min: 1,
                      max: 20,
                      onChanged: provider.updateCost,
                      activeColor: provider.usageColor,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            // 3. RESULTS & YEARLY PROJECTION
            Row(
              children: [
                _resultCard("Monthly Bill", "₹${provider.monthlyBill.toStringAsFixed(0)}", provider.usageColor),
                const SizedBox(width: 15),
                _resultCard("Yearly Cost", "₹${provider.yearlyProjection.toStringAsFixed(0)}", Colors.blueGrey),
              ],
            ),

            const SizedBox(height: 25),

            // 4. DAY COUNTER / FOOTER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Text("Usage Stats for ${provider.days} Days", style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text("Total Units: ${provider.totalKWh.toStringAsFixed(2)} kWh", style: const TextStyle(color: Colors.grey)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEnergyMeter(BillProvider provider) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: 220,
          width: 220,
          child: CustomPaint(
            painter: MeterPainter(
              // Progress capped at ₹5000 for visual scale
              usagePercent: (provider.monthlyBill / 5000).clamp(0.0, 1.0),
              color: provider.usageColor,
            ),
          ),
        ),
        Column(
          children: [
            const Text("CURRENT BILL", style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
            Text(
              "₹${provider.monthlyBill.toStringAsFixed(0)}",
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: provider.usageColor),
            ),
            Text("${provider.totalKWh.toStringAsFixed(1)} kWh", style: const TextStyle(color: Colors.blueGrey)),
          ],
        ),
      ],
    );
  }

  Widget _buildSlider({required String label, required String valueText, required double val, required double min, required double max, required Function(double) onChanged, required Color activeColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 14, color: Colors.black54)),
              Text(valueText, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            ],
          ),
          Slider(
            value: val,
            min: min,
            max: max,
            activeColor: activeColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _resultCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 13)),
            const SizedBox(height: 5),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// --- CUSTOM GAUGE PAINTER ---
class MeterPainter extends CustomPainter {
  final double usagePercent;
  final Color color;
  MeterPainter({required this.usagePercent, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    double strokeWidth = 18.0;

    Paint bgPaint = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    Paint progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    Offset center = Offset(size.width / 2, size.height / 2);
    double radius = size.width / 2;

    // Background Shadow Arc (Grey)
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        math.pi * 0.8, math.pi * 1.4, false, bgPaint);

    // Active Progress Arc (Dynamic Color)
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        math.pi * 0.8, math.pi * 1.4 * usagePercent, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}









//name: electricity_calculator
// description: "A premium energy bill calculator"
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
//
// flutter:
//   uses-material-design: true
