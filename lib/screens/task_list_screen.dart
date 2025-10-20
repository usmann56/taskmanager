import 'package:flutter/material.dart';
import '../constants/priority_enum.dart';
import '../models/task.dart';
import '../database/database_helper.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final List<Task> _tasks = [];
  final TextEditingController _taskController = TextEditingController();
  Priority _selectedPriority = Priority.medium;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // Load tasks from database
  Future<void> _loadTasks() async {
    try {
      final tasks = await DatabaseHelper.instance.getAllTasks();
      setState(() {
        _tasks.clear();
        _tasks.addAll(tasks);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading tasks: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Get sorted tasks by priority (high to low)
  List<Task> get _sortedTasks {
    final sorted = List<Task>.from(_tasks);
    sorted.sort((a, b) => b.priority.sortValue.compareTo(a.priority.sortValue));
    return sorted;
  }

  // Add a new task
  Future<void> _addTask() async {
    if (_taskController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a task name')));
      return;
    }

    final task = Task(
      name: _taskController.text.trim(),
      priority: _selectedPriority,
    );

    try {
      final id = await DatabaseHelper.instance.insertTask(task);
      setState(() {
        task.id = id;
        _tasks.add(task);
        _taskController.clear();
      });
    } catch (e) {
      print('Error adding task: $e');
    }
  }

  // Toggle task completion status
  Future<void> _toggleTaskCompletion(Task task) async {
    try {
      task.isCompleted = !task.isCompleted;
      await DatabaseHelper.instance.updateTask(task);
      setState(() {});
    } catch (e) {
      print('Error updating task: $e');
    }
  }

  // Change task priority
  Future<void> _changePriority(Task task, Priority newPriority) async {
    try {
      task.priority = newPriority;
      await DatabaseHelper.instance.updateTask(task);
      setState(() {});
    } catch (e) {
      print('Error changing priority: $e');
    }
  }

  // Delete a task
  Future<void> _deleteTask(Task task) async {
    try {
      if (task.id != null) {
        await DatabaseHelper.instance.deleteTask(task.id!);
        setState(() {
          _tasks.remove(task);
        });
      }
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task Manager'), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Input section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _taskController,
                              decoration: InputDecoration(
                                hintText: 'Enter a task name',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              onSubmitted: (_) => _addTask(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _addTask,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                            ),
                            child: const Text('Add'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text(
                            'Priority: ',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Expanded(
                            child: DropdownButton<Priority>(
                              value: _selectedPriority,
                              isExpanded: true,
                              items: Priority.values.map((priority) {
                                return DropdownMenuItem(
                                  value: priority,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: priority.color,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(priority.displayName),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (priority) {
                                if (priority != null) {
                                  setState(() {
                                    _selectedPriority = priority;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Tasks list section
                Expanded(
                  child: _tasks.isEmpty
                      ? Center(
                          child: Text(
                            'No tasks yet. Add one to get started!',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _sortedTasks.length,
                          itemBuilder: (context, index) {
                            final task = _sortedTasks[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              child: ListTile(
                                leading: Checkbox(
                                  value: task.isCompleted,
                                  onChanged: (_) => _toggleTaskCompletion(task),
                                ),
                                title: Text(
                                  task.name,
                                  style: TextStyle(
                                    decoration: task.isCompleted
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    color: task.isCompleted
                                        ? Colors.grey
                                        : Colors.black,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: task.priority.color
                                              .withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          border: Border.all(
                                            color: task.priority.color,
                                          ),
                                        ),
                                        child: PopupMenuButton<Priority>(
                                          onSelected: (priority) =>
                                              _changePriority(task, priority),
                                          itemBuilder: (context) =>
                                              Priority.values.map((p) {
                                                return PopupMenuItem(
                                                  value: p,
                                                  child: Row(
                                                    children: [
                                                      Container(
                                                        width: 12,
                                                        height: 12,
                                                        decoration:
                                                            BoxDecoration(
                                                              color: p.color,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(p.displayName),
                                                    ],
                                                  ),
                                                );
                                              }).toList(),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 10,
                                                height: 10,
                                                decoration: BoxDecoration(
                                                  color: task.priority.color,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                task.priority.displayName,
                                                style: TextStyle(
                                                  color: task.priority.color,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _deleteTask(task),
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
}
