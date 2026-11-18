import 'package:flutter/material.dart';
import 'package:flutter_book/tasks/task_model.dart';
import 'package:provider/provider.dart';

class TaskEntryViewer extends StatefulWidget {
  
  const new({super.key});

  @override
  State<TaskEntryViewer> createState() => _TaskEntryViewerState();
}

class _TaskEntryViewerState extends State<TaskEntryViewer> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  Future<void> _miniTaskListForm() async{
    final model = context.read<TaskModel>();
    final taskList = model.entryBeingEdited;
    _titleController.text = taskList?.title ?? '';
    _descriptionController.text = taskList?.description ?? '';

    final save = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Task List'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 10,
              children: [
                TextFormField(
                  controller: _titleController,
                  maxLength: 20,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Please enter a title' : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  maxLength: 30,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (save ?? false) {
      await model.updateListDetails(
        title: _titleController.text,
        description: _descriptionController.text,
      );
    }
  }

  Future<void> _miniTaskForm() async{

  }

  @override
  void initState() {
    final taskList = context.read<TaskModel>().entryBeingEdited;
    _titleController.text = taskList?.title ?? '';
    _descriptionController.text = taskList?.description ?? 'Unknown';
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<TaskModel>();
    final tasks = model.entryTasks;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.grey.withValues(alpha: .15),
        title: Text('${model.entryBeingEdited?.title ?? 'New Task List'}: Tasks'),
        actionsPadding: EdgeInsets.symmetric(horizontal: 15),
        shape: Border.all(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () => model.stopEntry(save: false),
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back),
          ),
          IconButton(
            onPressed: () => _miniTaskListForm(),
            tooltip: 'Edit task list',
            icon: const Icon(Icons.create)
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Material(
              color: Colors.grey.withValues(alpha: .2),
              child: Text('${model.entryBeingEdited?.title ?? 'New Description'}')
            ),
            Center(
              child: Material(
                color: Colors.grey.withValues(alpha: .2),
                child: tasks.isEmpty
                    ? const Center(child: Text('No tasks in this list yet'))
                    : ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return CheckboxListTile(
                            value: task.isComplete,
                            onChanged: (_) => model.toggleTask(task),
                            controlAffinity: ListTileControlAffinity.leading,
                            title: Text(
                              task.name ?? '',
                              style: TextStyle(
                                decoration: task.isComplete ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            subtitle: (task.description?.isNotEmpty ?? false)
                                ? Text(task.description!)
                                : null,
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _miniTaskForm(),
        tooltip: 'Add new task',
        child: Icon(Icons.add_box_outlined),
      ),
    );
  }
}