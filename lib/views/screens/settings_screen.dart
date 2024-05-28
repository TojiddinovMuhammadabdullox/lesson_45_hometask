import 'package:flutter/material.dart';
import 'package:lesson_45_hometask/models/todo.dart';
import 'dart:math';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final List<Todo> _todos = [];

  DateTime selectedDate = DateTime.now();

  String _formatDate(DateTime date) {
    return '${date.year}-${_addLeadingZero(date.month)}-${_addLeadingZero(date.day)} ${_addLeadingZero(date.hour)}:${_addLeadingZero(date.minute)}';
  }

  String _addLeadingZero(int value) {
    if (value < 10) {
      return '0$value';
    }
    return '$value';
  }

  void _addOrEditTodo({Todo? todo}) async {
    final result = await showModalBottomSheet<Todo>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final titleController = TextEditingController(text: todo?.title ?? '');
        final descriptionController =
            TextEditingController(text: todo?.description ?? '');
        selectedDate = todo?.date ?? DateTime.now();

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'Date: ${_formatDate(selectedDate)}',
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null && pickedDate != selectedDate) {
                          setState(() {
                            selectedDate = pickedDate;
                          });
                        }
                      },
                      child: const Text('Select date'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final newTodo = Todo(
                      id: todo?.id ?? Random().nextInt(1000).toString(),
                      title: titleController.text,
                      description: descriptionController.text,
                      date: selectedDate,
                      isCompleted: todo?.isCompleted ?? false,
                      notes: todo?.notes ?? [],
                    );
                    Navigator.of(context).pop(newTodo);
                  },
                  child: Text(todo == null ? 'Add Todo' : 'Edit Todo'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (result != null) {
      setState(() {
        if (todo == null) {
          _todos.add(result);
        } else {
          final index = _todos.indexWhere((t) => t.id == todo.id);
          if (index != -1) {
            _todos[index] = result;
          }
        }
      });
    }
  }

  void _deleteTodo(String id) {
    setState(() {
      _todos.removeWhere((todo) => todo.id == id);
    });
  }

  void _toggleTodoStatus(String id) {
    setState(() {
      final index = _todos.indexWhere((todo) => todo.id == id);
      if (index != -1) {
        _todos[index].isCompleted = !_todos[index].isCompleted;
      }
    });
  }

  void _addNoteToTodoDialog(String todoId) async {
    final newNote = await _showNoteDialog();
    if (newNote != null) {
      setState(() {
        final index = _todos.indexWhere((todo) => todo.id == todoId);
        if (index != -1) {
          _todos[index].notes.add(newNote);
        }
      });
    }
  }

  Future<Note?> _showNoteDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    return showDialog<Note>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(labelText: 'Content'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newNote = Note(
                  id: Random().nextInt(1000).toString(),
                  title: titleController.text,
                  content: contentController.text,
                  createDate: DateTime.now(),
                );
                Navigator.of(context).pop(newNote);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: _todos.isEmpty
          ? const Center(
              child: Text('No todos yet'),
            )
          : ListView.builder(
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                final todo = _todos[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                      todo.title,
                      style: TextStyle(
                        decoration: todo.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(todo.description),
                        Text('Due Date: ${_formatDate(todo.date)}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: todo.isCompleted,
                          onChanged: (value) {
                            _toggleTodoStatus(todo.id);
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.green,
                          ),
                          onPressed: () {
                            _addOrEditTodo(todo: todo);
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            _deleteTodo(todo.id);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      _addNoteToTodoDialog(todo.id);
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addOrEditTodo();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
