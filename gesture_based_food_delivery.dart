import 'package:flutter/material.dart';

void main() {
  runApp(FoodApp());
}

class Food {
  final String name;
  final String image;
  String status;

  Food(this.name, this.image, this.status);
}

class FoodApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Food Delivery",
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: FoodScreen(),
    );
  }
}

class FoodScreen extends StatefulWidget {
  @override
  _FoodScreenState createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {

  List<Food> foods = [
    Food("Pizza", "https://picsum.photos/id/1080/400/200", "Preparing"),
    Food("Burger", "https://picsum.photos/id/292/400/200", "Preparing"),
    Food("Biryani", "https://picsum.photos/id/1060/400/200", "Preparing"),
  ];

  // 🔁 Double tap → reorder
  void reorder(String name) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("$name reordered successfully 🍽"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // 📍 Fake map (zoomable UI)
  void showLocation() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: 350,
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              Text(
                "Delivery Location",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),

              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: InteractiveViewer(
                    maxScale: 4,
                    child: Image.network(
                      "https://picsum.photos/600/400", // 📍 fake map image
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 10),
              Text("📍 Default Location (Zoom enabled)")
            ],
          ),
        );
      },
    );
  }

  // 🚚 Update order status step by step
  void updateStatus(int index) {
    setState(() {
      if (foods[index].status == "Preparing") {
        foods[index].status = "On the way";
      } else if (foods[index].status == "On the way") {
        foods[index].status = "Delivered";
      }
    });
  }

  // 🎨 Color based on status
  Color getColor(String status) {
    if (status == "Preparing") return Colors.orange;
    if (status == "On the way") return Colors.blue;
    return Colors.green;
  }

  Widget buildCard(int index) {
    final food = foods[index];

    return GestureDetector(
      onDoubleTap: () => reorder(food.name),

      onLongPress: () => showLocation(),

      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: getColor(food.status),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Card(
          color: Colors.transparent,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              // Image
              ClipRRect(
                borderRadius:
                BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(
                  food.image,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              // Details
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      food.name,
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),

                    SizedBox(height: 5),

                    Text(
                      "Status: ${food.status}",
                      style: TextStyle(
                          fontSize: 16, color: Colors.white),
                    ),

                    SizedBox(height: 5),

                    Text(
                      "👉 Swipe to update status",
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Food Delivery System"),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: foods.length,
        itemBuilder: (context, index) {

          return Dismissible(
            key: Key(foods[index].name),
            direction: DismissDirection.startToEnd,

            background: Container(
              margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              padding: EdgeInsets.only(left: 20),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(Icons.sync, color: Colors.white),
            ),

            confirmDismiss: (_) async {
              updateStatus(index); // 🚚 change status
              return false; // ❗ don’t delete
            },

            child: buildCard(index),
          );
        },
      ),
    );
  }
}

// no pubspec.yaml for this exercise