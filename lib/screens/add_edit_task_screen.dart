import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;

  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  DateTime? selectedDate;
  String selectedStatus = "To-Do";
  String selectedPriority = "Medium";
  String? selectedBlockedBy;

  bool isLoading = false;

  final draftBox = Hive.box('draft');

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      titleController.text = widget.task!.title;
      descriptionController.text = widget.task!.description;
      selectedDate = widget.task!.dueDate;
      selectedBlockedBy = widget.task!.blockedBy;

      selectedStatus = widget.task!.status == TaskStatus.todo
          ? "To-Do"
          : widget.task!.status == TaskStatus.inProgress
              ? "In Progress"
              : "Done";

      selectedPriority = widget.task!.priority == TaskPriority.low
          ? "Low"
          : widget.task!.priority == TaskPriority.medium
              ? "Medium"
              : "High";
    } else {
      titleController.text = draftBox.get('title', defaultValue: "");
      descriptionController.text =
          draftBox.get('description', defaultValue: "");
      selectedStatus = draftBox.get('status', defaultValue: "To-Do");
      selectedBlockedBy = draftBox.get('blockedBy');
    }

    titleController.addListener(saveDraft);
    descriptionController.addListener(saveDraft);
  }

  void saveDraft() {
    if (widget.task != null) return;

    draftBox.put('title', titleController.text);
    draftBox.put('description', descriptionController.text);
    draftBox.put('status', selectedStatus);
    draftBox.put('blockedBy', selectedBlockedBy);
  }

  void clearDraft() {
    draftBox.clear();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // ✅ FINAL SAVE FUNCTION (WITH DELAY)
  Future<void> saveTask() async {
    if (!_formKey.currentState!.validate() || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    // ⏳ 2 second delay (MANDATORY)
    await Future.delayed(const Duration(seconds: 2));

    final task = Task(
      id: widget.task?.id ?? const Uuid().v4(),
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      dueDate: selectedDate!,
      status: selectedStatus == "To-Do"
          ? TaskStatus.todo
          : selectedStatus == "In Progress"
              ? TaskStatus.inProgress
              : TaskStatus.done,
      priority: selectedPriority == "Low"
          ? TaskPriority.low
          : selectedPriority == "Medium"
              ? TaskPriority.medium
              : TaskPriority.high,
      blockedBy: selectedBlockedBy,
    );

    final box = Hive.box('tasks');
    await box.put(task.id, task.toMap());

    clearDraft();

    setState(() => isLoading = false);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tasksBox = Hive.box('tasks');

    final allTasks = tasksBox.values
        .map((e) => Task.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    final formattedDate = selectedDate == null
        ? "Select Due Date"
        : DateFormat('dd MMM yyyy').format(selectedDate!);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? "Add Task" : "Edit Task"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // TITLE
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: "Title",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Enter title" : null,
                ),

                const SizedBox(height: 15),

                // DESCRIPTION
                TextFormField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: "Description",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Enter description" : null,
                ),

                const SizedBox(height: 15),

                // DATE
                ElevatedButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );

                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                      });
                    }
                  },
                  label: Text(formattedDate),
                ),

                const SizedBox(height: 15),

                // STATUS
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  items: ["To-Do", "In Progress", "Done"]
                      .map((e) =>
                          DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value!;
                      saveDraft();
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Status",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // PRIORITY
                DropdownButtonFormField<String>(
                  value: selectedPriority,
                  items: ["Low", "Medium", "High"]
                      .map((e) =>
                          DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedPriority = value!;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: "Priority",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // BLOCKED BY
                DropdownButtonFormField<String>(
                  value: selectedBlockedBy,
                  hint: const Text("Blocked By (Optional)"),
                  items: allTasks
                      .where((t) => t.id != widget.task?.id)
                      .map((task) => DropdownMenuItem(
                            value: task.id,
                            child: Text(task.title),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedBlockedBy = value;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // SAVE BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : saveTask,
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : Text(
                            widget.task == null
                                ? "Add Task"
                                : "Update Task",
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}