import 'package:flutter/material.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF3F8FE),
      ),
      home: const TodoListScreen(),
    );
  }
}

class TodoItem {
  String name;
  bool isDone;

  TodoItem({required this.name, this.isDone = false});
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<TodoItem> _tasks = [];
  int _selectedTaskIndex = -1;

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Center(child: Text('Delete Task?', style: TextStyle(fontWeight: FontWeight.bold))),
          content: Text("Are you sure you want to permanently delete '${_tasks[index].name}'?", textAlign: TextAlign.center),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() => _selectedTaskIndex = -1);
              },
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () {
                setState(() {
                  _tasks.removeAt(index);
                  _selectedTaskIndex = -1;
                });
                Navigator.of(context).pop();
              },
              child: const Text('DELETE', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isSelectionMode = _selectedTaskIndex != -1;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: isSelectionMode
            ? const Center(child: Text('1', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)))
            : null,
        title: isSelectionMode ? null : const Center(child: Text('To-Do App', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
        actions: [
          if (isSelectionMode) ...[
            IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => setState(() => _selectedTaskIndex = -1)),
            Container(
              color: Colors.blue,
              width: 56,
              child: IconButton(icon: const Icon(Icons.delete, color: Colors.white), onPressed: () => _showDeleteDialog(_selectedTaskIndex)),
            ),
          ] else ...[
            IconButton(icon: const Icon(Icons.menu, color: Colors.black), onPressed: () {}),
          ]
        ],
      ),
      body: _tasks.isEmpty
          ? const Center(child: Text('No tasks yet. Tap + to add one!', style: TextStyle(color: Colors.grey, fontSize: 16)))
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ListView.builder(
          itemCount: _tasks.length,
          itemBuilder: (context, index) {
            TodoItem currentTask = _tasks[index];
            bool isSelected = _selectedTaskIndex == index;

            Color cardBackgroundColor = Colors.white;
            if (isSelected) {
              cardBackgroundColor = const Color(0xFFD2E5F7);
            } else if (currentTask.isDone) {
              cardBackgroundColor = const Color(0xFFE8F5E9);
            }

            return Card(
              color: cardBackgroundColor,
              elevation: 1,
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
                side: isSelected ? const BorderSide(color: Colors.blue, width: 1.5) : BorderSide.none,
              ),
              child: ListTile(
                leading: isSelectionMode
                    ? Icon(isSelected ? Icons.check_circle : Icons.radio_button_unchecked, color: Colors.blue)
                    : Icon(
                  currentTask.isDone ? Icons.check_box : Icons.check_box_outline_blank,
                  color: currentTask.isDone ? Colors.green : Colors.grey,
                ),
                title: Text(
                  currentTask.name,
                  style: TextStyle(
                    fontSize: 16,
                    color: currentTask.isDone ? Colors.grey : Colors.black87,
                    decoration: currentTask.isDone ? TextDecoration.lineThrough : TextDecoration.none,
                  ),
                ),
                // CLICK TASK: Opens screen with BOTH Complete and Delete options
                onTap: isSelectionMode ? null : () async {
                  final dynamic result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskStatusScreen(taskName: currentTask.name),
                    ),
                  );

                  if (result == 'done') {
                    setState(() {
                      currentTask.isDone = true;
                    });
                  } else if (result == 'delete') {
                    setState(() {
                      _tasks.removeAt(index); // Deletes the mistaken task immediately
                    });
                  }
                },
                onLongPress: () {
                  setState(() {
                    _selectedTaskIndex = index;
                  });
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: isSelectionMode
          ? null
          : FloatingActionButton(
        onPressed: () async {
          final newTaskName = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTaskScreen()));
          if (newTaskName != null && newTaskName.toString().trim().isNotEmpty) {
            setState(() => _tasks.add(TodoItem(name: newTaskName)));
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class TaskStatusScreen extends StatelessWidget {
  final String taskName;
  const TaskStatusScreen({super.key, required this.taskName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Task Update', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                taskName,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text('What would you like to do with this task?', style: TextStyle(fontSize: 18, color: Colors.black54)),
              const SizedBox(height: 40),
              // Done and Cancel Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('BACK', style: TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () => Navigator.pop(context, 'done'),
                    child: const Text("YES, IT'S DONE", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 15),
              // Direct button to remove accidental tasks
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, 'delete'),
                icon: const Icon(Icons.delete_forever),
                label: const Text('Delete Accidental Task', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});
  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Add Task', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: const SizedBox(),
        actions: [
          IconButton(icon: const Icon(Icons.close, color: Colors.black), onPressed: () => Navigator.pop(context)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 40),
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Task Name',
                labelStyle: const TextStyle(color: Colors.teal),
                focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.teal, width: 1.5), borderRadius: BorderRadius.circular(4)),
                enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: Colors.grey, width: 1.0), borderRadius: BorderRadius.circular(4)),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
                onPressed: () => Navigator.pop(context, _controller.text),
                child: const Text('SAVE TASK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}