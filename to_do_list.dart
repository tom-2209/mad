import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));
  runApp(
    ChangeNotifierProvider(
      create: (context) => TodoProvider(),
      child: const PremiumTodoApp(),
    ),
  );
}

class PremiumTodoApp extends StatelessWidget {
  const PremiumTodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const TodoDashboard(),
    );
  }
}

// --- DATA MODEL ---
class Task {
  String id;
  String title;
  bool isDone;
  Task({required this.id, required this.title, this.isDone = false});
}

// --- STATE MANAGEMENT ---
class TodoProvider extends ChangeNotifier {
  final List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  void addTask(String title) {
    _tasks.insert(0, Task(id: DateTime.now().toString(), title: title));
    notifyListeners();
  }

  void toggleDone(int index) {
    _tasks[index].isDone = !_tasks[index].isDone;
    notifyListeners();
  }

  void removeTask(int index) {
    _tasks.removeAt(index);
    notifyListeners();
  }

  void reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final Task item = _tasks.removeAt(oldIndex);
    _tasks.insert(newIndex, item);
    notifyListeners();
  }
}

// --- UI DASHBOARD ---
class TodoDashboard extends StatelessWidget {
  const TodoDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);
    final textController = TextEditingController();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A237E), Color(0xFF3949AB), Colors.white],
            stops: [0.0, 0.3, 0.5],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("My Tasks",
                        style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    Text("${todoProvider.tasks.where((t) => !t.isDone).length} pending today",
                        style: const TextStyle(color: Colors.white70, fontSize: 16)),
                  ],
                ),
              ),

              // Glassmorphism Input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    color: Colors.white.withOpacity(0.15),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: TextField(
                      controller: textController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "What's next?",
                        hintStyle: const TextStyle(color: Colors.white60),
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.white, size: 30),
                          onPressed: () {
                            if (textController.text.isNotEmpty) {
                              todoProvider.addTask(textController.text);
                              textController.clear();
                            }
                          },
                        ),
                      ),
                      onSubmitted: (val) {
                        if (val.isNotEmpty) {
                          todoProvider.addTask(val);
                          textController.clear();
                        }
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Task List
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                    child: ReorderableListView.builder(
                      padding: const EdgeInsets.only(top: 20, bottom: 80),
                      itemCount: todoProvider.tasks.length,
                      onReorder: todoProvider.reorder,
                      itemBuilder: (context, index) {
                        final task = todoProvider.tasks[index];
                        return _buildTodoItem(context, task, index, todoProvider);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodoItem(BuildContext context, Task task, int index, TodoProvider provider) {
    // Removed 'const' here because 'task' and 'index' are dynamic variables
    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(20)),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 25),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) => provider.removeTask(index),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 300),
        scale: task.isDone ? 0.96 : 1.0,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: task.isDone ? 0.4 : 1.0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: GestureDetector(
                onTap: () => provider.toggleDone(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: task.isDone ? Colors.green : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: task.isDone ? Colors.green : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: task.isDone
                        ? const Icon(Icons.check, size: 20, color: Colors.white)
                        : const Icon(Icons.circle, size: 20, color: Colors.transparent),
                  ),
                ),
              ),
              title: Text(
                task.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: task.isDone ? Colors.grey : Colors.black87,
                  decoration: task.isDone ? TextDecoration.lineThrough : null,
                ),
              ),
              // FIXED: Removed 'const' from ReorderableDragStartListener
              trailing: ReorderableDragStartListener(
                index: index,
                child: const Icon(Icons.drag_indicator, color: Colors.grey),
              ),
            ),
          ),
        ),
      ),
    );
  }
}





//name: todo_app
// description: "A dynamic todo list app."
// publish_to: 'none'
// version: 1.0.0+1
//
// environment:
//   sdk: ^3.6.0  # This line fixes the error you're seeing
//
// dependencies:
//   flutter:
//     sdk: flutter
//   provider: ^6.1.1
//   cupertino_icons: ^1.0.8
//
// dev_dependencies:
//   flutter_test:
//     sdk: flutter
//   flutter_lints: ^5.0.0
//
// flutter:
//   uses-material-design: true
