import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: const PharmacyApp(),
    ),
  );
}

class PharmacyApp extends StatelessWidget {
  const PharmacyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pharmacy Store',
      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),
      home: const MedicineListScreen(),
    );
  }
}

// --- DATA MODELS ---
class Medicine {
  final String id, name, dosage, expiry;
  final double price;
  final bool prescriptionRequired;

  Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.expiry,
    required this.price,
    required this.prescriptionRequired,
  });
}

class CartItem {
  final Medicine medicine;
  int quantity;

  CartItem({required this.medicine, this.quantity = 1});
}

// --- STATE MANAGEMENT ---
class CartProvider extends ChangeNotifier {
  final List<Medicine> _catalog = [
    Medicine(id: '1', name: "Paracetamol", dosage: "500mg", expiry: "12/2026", price: 50.0, prescriptionRequired: false),
    Medicine(id: '2', name: "Amoxicillin", dosage: "250mg", expiry: "05/2025", price: 120.0, prescriptionRequired: true),
    Medicine(id: '3', name: "Cetirizine", dosage: "10mg", expiry: "10/2024", price: 30.0, prescriptionRequired: false),
    Medicine(id: '4', name: "Ibuprofen", dosage: "400mg", expiry: "08/2026", price: 45.0, prescriptionRequired: false),
    Medicine(id: '5', name: "Azithromycin", dosage: "500mg", expiry: "11/2024", price: 210.0, prescriptionRequired: true),
  ];

  final List<CartItem> _cart = [];
  List<Medicine> get catalog => _catalog;
  List<CartItem> get cart => _cart;

  void addToCart(Medicine med) {
    var existing = _cart.where((item) => item.medicine.id == med.id);
    if (existing.isEmpty) {
      _cart.add(CartItem(medicine: med));
    } else {
      existing.first.quantity++;
    }
    notifyListeners();
  }

  void updateQuantity(CartItem item, int delta) {
    item.quantity += delta;
    if (item.quantity <= 0) {
      _cart.remove(item);
    }
    notifyListeners();
  }

  double get subtotal => _cart.fold(0, (sum, item) => sum + (item.medicine.price * item.quantity));
  double get tax => subtotal * 0.12; // 12% Medical Tax
  double get total => subtotal + tax;

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }
}

// --- SCREEN 1: MEDICINE LIST ---
class MedicineListScreen extends StatelessWidget {
  const MedicineListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pharmacy Store"),
        actions: [
          IconButton(
            icon: Badge(
              label: Text(provider.cart.length.toString()),
              child: const Icon(Icons.shopping_cart),
            ),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen())),
          )
        ],
      ),
      body: ListView.builder(
        itemCount: provider.catalog.length,
        itemBuilder: (context, index) {
          final med = provider.catalog[index];
          // Alert if expiry is in 2024
          bool isExpiringSoon = med.expiry.contains("2024");

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            color: isExpiringSoon ? Colors.red.shade50 : Colors.white,
            child: ListTile(
              title: Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Dosage: ${med.dosage} | Expiry: ${med.expiry}"),
                  if (isExpiringSoon)
                    const Text("⚠️ EXPIRY ALERT: Use soon!", style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("₹${med.price}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                  if (med.prescriptionRequired)
                    const Text("Rx Required", style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
              onTap: () {
                provider.addToCart(med);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("${med.name} added to cart"), duration: const Duration(seconds: 1)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// --- SCREEN 2: CART PAGE ---
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Shopping Cart")),
      body: provider.cart.isEmpty
          ? const Center(child: Text("Your cart is empty!"))
          : Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: provider.cart.length,
              itemBuilder: (context, index) {
                final item = provider.cart[index];
                return ListTile(
                  title: Text(item.medicine.name),
                  subtitle: Text("₹${item.medicine.price} per unit"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () => provider.updateQuantity(item, -1),
                      ),
                      Text("${item.quantity}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                        onPressed: () => provider.updateQuantity(item, 1),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              children: [
                _rowValue("Subtotal:", provider.subtotal),
                _rowValue("Tax (12%):", provider.tax),
                const Divider(),
                _rowValue("Total Amount:", provider.total, isBold: true),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutScreen())),
                    child: const Text("Proceed to Checkout", style: TextStyle(fontSize: 18)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _rowValue(String label, double val, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text("₹${val.toStringAsFixed(2)}", style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}

// --- SCREEN 3: CHECKOUT PAGE ---
class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Final Invoice")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Order Summary", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: provider.cart.length,
                itemBuilder: (context, index) {
                  final item = provider.cart[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${item.medicine.name} x ${item.quantity}"),
                        Text("₹${(item.medicine.price * item.quantity).toStringAsFixed(2)}"),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(thickness: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Grand Total", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Text("₹${provider.total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
              ],
            ),
            const SizedBox(height: 30),

            // HEALTH DISCLAIMER BOX (FIXED: Removed 'const' to allow .shade900)
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "⚠️ HEALTH DISCLAIMER",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade900),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "1. Medicines once sold are not returnable.\n2. Please consult a registered medical practitioner before consumption.\n3. Keep out of reach of children.",
                    style: TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade800, foregroundColor: Colors.white),
                onPressed: () {
                  provider.clearCart();
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Success!"),
                      content: const Text("Your order has been placed successfully."),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                          child: const Text("Back to Store"),
                        )
                      ],
                    ),
                  );
                },
                child: const Text("Confirm & Place Order", style: TextStyle(fontSize: 18)),
              ),
            )
          ],
        ),
      ),
    );
  }
}









//name: pharmacy_shopping_store
// description: "A professional pharmacy shopping application with cart and checkout logic."
//
// # The following line prevents the package from being accidentally published to pub.dev.
// publish_to: 'none'
//
// version: 1.0.0+1
//
// environment:
//   sdk: ^3.6.0
//
// dependencies:
//   flutter:
//     sdk: flutter
//
//   # State management to handle cart logic across screens
//   provider: ^6.1.1
//
//   # Useful for currency and date formatting
//   intl: ^0.19.0
//
// dev_dependencies:
//   flutter_test:
//     sdk: flutter
//   flutter_lints: ^5.0.0
//
// # The following section is specific to Flutter.
// flutter:
//
//   # The following line ensures that the Material Icons font is
//   # included with your application, so that you can use the icons in
//   # the material Icons class.
//   uses-material-design: true
//
//   # To add assets to your application, add an assets section like this:
//   # assets:
//   #   - assets/images/medicine_placeholder.png
//
//   # An image asset can refer to one or more resolution-specific "variants", see
//   # https://flutter.dev/to/resolution-aware-images
//
//   # For details regarding fonts from package dependencies,
//   # see https://flutter.dev/custom-fonts/#from-packages
