import 'package:flutter/material.dart';
import 'package:flutter_book/tasks/task_model.dart';
import 'package:provider/provider.dart';

class TaskEntry extends StatefulWidget {
  const new({super.key});

  @override
  State<TaskEntry> createState() => _TaskEntryState();
}

class _TaskEntryState extends State<TaskEntry> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  @override
  void initState() {
    final taskList = context.read<TaskModel>().entryBeingEdited;
    _titleController.text = taskList?.title ?? '';
    _descriptionController.text = taskList?.description ?? '';
    super.initState();
  }  

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Center(
                  child: Column(
                    children: [
                      Material(
                        color: Colors.grey.withValues(alpha: .2),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: Column(
                            spacing: 10,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              TextFormField(
                                controller: _titleController,
                                maxLength: 20,
                                style: const TextStyle(color: Colors.white),
                                cursorColor: Colors.white,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  icon: Icon(Icons.title),
                                  label: Text('Title'),
                                  labelStyle: TextStyle(color: Colors.white),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a title';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: _descriptionController,
                                maxLength: 30,
                                style: const TextStyle(color: Colors.white),
                                cursorColor: Colors.white,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  enabledBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                  icon: Icon(Icons.info),
                                  label: Text('Description'),
                                  labelStyle: TextStyle(color: Colors.white),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter a description';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ) ,
                        )
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}