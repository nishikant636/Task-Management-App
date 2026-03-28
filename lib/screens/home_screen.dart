import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import 'add_edit_task_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  final bool isDark;

  const HomeScreen({
    super.key,
    required this.toggleTheme,
    required this.isDark,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchText = "";
  String filterStatus = "All";

  final TextEditingController searchController = TextEditingController();
  Timer? debounce;

  @override
  Widget build(BuildContext context) {
    final box = Hive.box('tasks');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Manager"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: widget.toggleTheme,
          )
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditTaskScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: "Search tasks...",
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    debounce?.cancel();
                    debounce = Timer(const Duration(milliseconds: 300), () {
                      setState(() => searchText = value);
                    });
                  },
                ),

                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: filterStatus,
                  items: ["All", "To-Do", "In Progress", "Done"]
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    setState(() => filterStatus = value!);
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: ValueListenableBuilder(
              valueListenable: box.listenable(),
              builder: (_, Box box, __) {
                final allTasks = box.values
                    .map((e) => Task.fromMap(Map<String, dynamic>.from(e)))
                    .toList();

                var tasks = allTasks.where((task) {
                  return task.title
                      .toLowerCase()
                      .contains(searchText.toLowerCase());
                }).toList();

                if (filterStatus != "All") {
                  tasks = tasks.where((task) {
                    if (filterStatus == "To-Do") {
                      return task.status == TaskStatus.todo;
                    } else if (filterStatus == "In Progress") {
                      return task.status == TaskStatus.inProgress;
                    } else {
                      return task.status == TaskStatus.done;
                    }
                  }).toList();
                }

                if (tasks.isEmpty) {
                  return const Center(child: Text("No Tasks Found"));
                }

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (_, i) =>
                      buildTaskCard(tasks[i], allTasks),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTaskCard(Task task, List<Task> allTasks) {
    final box = Hive.box('tasks');

    // 🔥 BLOCKED LOGIC
    Task? blockedTask;
    if (task.blockedBy != null) {
      try {
        blockedTask =
            allTasks.firstWhere((t) => t.id == task.blockedBy);
      } catch (_) {}
    }

    bool isBlocked =
        blockedTask != null && blockedTask.status != TaskStatus.done;

    // STATUS UI
    Color statusColor;
    String statusText;

    switch (task.status) {
      case TaskStatus.todo:
        statusColor = Colors.blue;
        statusText = "To-Do";
        break;
      case TaskStatus.inProgress:
        statusColor = Colors.orange;
        statusText = "In Progress";
        break;
      case TaskStatus.done:
        statusColor = Colors.green;
        statusText = "Done";
        break;
    }

    // PRIORITY UI
    Color priorityColor = task.priority == TaskPriority.high
        ? Colors.red
        : task.priority == TaskPriority.medium
            ? Colors.orange
            : Colors.green;

    return Opacity(
      opacity: isBlocked ? 0.5 : 1,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 6)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TITLE + STATUS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                        color: statusColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            Text(task.description),

            const SizedBox(height: 6),

            Text("Due: ${task.dueDate.toString().split(' ')[0]}"),

            const SizedBox(height: 8),

            // PRIORITY BADGE
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: priorityColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(task.priority.name.toUpperCase()),
            ),

            if (isBlocked)
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Text("⚠ Blocked",
                    style: TextStyle(color: Colors.red)),
              ),

            const SizedBox(height: 10),

            // BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: isBlocked
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AddEditTaskScreen(task: task),
                                ),
                              );
                            },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed:
                          isBlocked ? null : () => box.delete(task.id),
                    ),
                  ],
                ),

                ElevatedButton(
                  onPressed: isBlocked
                      ? null
                      : () => updateStatus(task, box),
                  child: Text(
                    task.status == TaskStatus.todo
                        ? "Start"
                        : task.status == TaskStatus.inProgress
                            ? "Mark Done"
                            : "Completed",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void updateStatus(Task task, Box box) {
    TaskStatus newStatus;

    if (task.status == TaskStatus.todo) {
      newStatus = TaskStatus.inProgress;
    } else if (task.status == TaskStatus.inProgress) {
      newStatus = TaskStatus.done;
    } else {
      return;
    }

    final updatedTask = Task(
      id: task.id,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      status: newStatus,
      priority: task.priority,
      blockedBy: task.blockedBy,
    );

    box.put(task.id, updatedTask.toMap());
  }
}