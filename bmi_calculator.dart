import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => BMIProvider(),
      child: const BMIDashboardApp(),
    ),
  );
}

class BMIDashboardApp extends StatelessWidget {
  const BMIDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const BMIScreen(),
    );
  }
}

// --- STATE MANAGEMENT ---
class BMIProvider extends ChangeNotifier {
  double height = 175.0; // Initial height in cm
  double weight = 72.0;  // Initial weight in kg

  double get bmi => weight / pow(height / 100, 2);

  String get category {
    if (bmi < 18.5) return "Underweight";
    if (bmi < 25) return "Normal Weight";
    if (bmi < 30) return "Overweight";
    return "Obesity";
  }

  String get advice {
    if (bmi < 18.5) return "Focus on nutrient-dense foods and strength training.";
    if (bmi < 25) return "Perfect! Keep maintaining your current activity levels.";
    if (bmi < 30) return "Try increasing cardio and monitoring portion sizes.";
    return "Consider consulting a professional for a personalized health plan.";
  }

  // FIXED: Lowercase 'directions_run'
  IconData get logo {
    if (bmi < 18.5) return Icons.warning_amber_rounded;
    if (bmi < 25) return Icons.check_circle_outline;
    if (bmi < 30) return Icons.directions_run;
    return Icons.monitor_weight_rounded;
  }

  Color get statusColor {
    if (bmi < 18.5) return Colors.lightBlue;
    if (bmi < 25) return Colors.green.shade600;
    if (bmi < 30) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  void updateHeight(double val) {
    height = val;
    notifyListeners();
  }

  void updateWeight(double val) {
    weight = val;
    notifyListeners();
  }
}

// --- DASHBOARD UI ---
class BMIScreen extends StatelessWidget {
  const BMIScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<BMIProvider>(context);

    return Scaffold(
      backgroundColor: provider.statusColor.withOpacity(0.05),
      appBar: AppBar(
        title: const Text("Health Analytics", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: Column(
          children: [
            // 1. DYNAMIC RESULT CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(35),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: provider.statusColor.withOpacity(0.2),
                    blurRadius: 30,
                    offset: const Offset(0, 15),
                  )
                ],
              ),
              child: Column(
                children: [
                  // Animated Icon/Logo
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      provider.logo,
                      key: ValueKey(provider.logo),
                      size: 80,
                      color: provider.statusColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    provider.bmi.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      color: provider.statusColor,
                    ),
                  ),
                  Text(
                    provider.category.toUpperCase(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: provider.statusColor,
                      letterSpacing: 2,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(),
                  ),
                  Text(
                    provider.advice,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.blueGrey.shade700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 2. INPUT SLIDERS
            _buildInputControl(
              label: "Height",
              value: "${provider.height.toInt()} cm",
              current: provider.height,
              min: 100,
              max: 220,
              onChanged: provider.updateHeight,
              activeColor: provider.statusColor,
            ),

            const SizedBox(height: 20),

            _buildInputControl(
              label: "Weight",
              value: "${provider.weight.toInt()} kg",
              current: provider.weight,
              min: 30,
              max: 180,
              onChanged: provider.updateWeight,
              activeColor: provider.statusColor,
            ),

            const SizedBox(height: 30),

            // 3. STATS FOOTER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _miniStat("Category", provider.category),
                const SizedBox(width: 10, child: VerticalDivider()),
                _miniStat("Ideal Range", "18.5 - 24.9"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputControl({
    required String label,
    required String value,
    required double current,
    required double min,
    required double max,
    required Function(double) onChanged,
    required Color activeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blueGrey)),
              Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: activeColor)),
            ],
          ),
          const SizedBox(height: 10),
          Slider(
            value: current,
            min: min,
            max: max,
            activeColor: activeColor,
            inactiveColor: activeColor.withOpacity(0.1),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
      ],
    );
  }
}










//name: bmi_pro_dashboard
// description: "A premium BMI calculator with dynamic UI"
// publish_to: 'none'
// version: 1.0.0+1
//
// environment:
//   sdk: '^3.6.0'
//
// dependencies:
//   flutter:
//     sdk: flutter
//   provider: ^6.1.1
//
// flutter:
//   uses-material-design: true
