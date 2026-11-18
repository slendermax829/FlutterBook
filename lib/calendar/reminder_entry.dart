import 'package:flutter/material.dart';
import 'package:flutter_book/calendar/calendar_model.dart';
import 'package:provider/provider.dart';

class ReminderEntry extends StatefulWidget {
  const new({super.key});

  @override
  State<ReminderEntry> createState() => _ReminderEntryState();
}

class _ReminderEntryState extends State<ReminderEntry> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  
  Color _selectedColor = Colors.red;

  DateTime? _selectedStartTime;
  DateTime? _selectedEndDate;

  @override
  void initState() {
    final reminder = context.read<CalendarModel>().entryBeingEdited;

    _titleController.text = reminder?.title ?? '';
    _noteController.text = reminder?.notes ?? '';
    _selectedColor = reminder?.color ?? Colors.red;
    _selectedStartTime = reminder?.startTime;
    _selectedEndDate = reminder?.endDate;

    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CalendarModel>();
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(30),
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
                            mainAxisAlignment: .spaceAround,
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
                                controller: _noteController,
                                maxLength: 40,
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
                                  icon: Icon(Icons.notes),
                                  label: Text('Notes'),
                                  labelStyle: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    model.stopEntry(save: false, notify: true);
                  },
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    if(_formKey.currentState!.validate()){
                      //_confirmSave();
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSelector(){
    return Placeholder();
  }

  Widget _buildEndDateSelector(){
    return Placeholder();
  }
}