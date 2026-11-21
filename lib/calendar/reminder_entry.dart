import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_book/calendar/calendar_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

/// Form for creating or editing a calendar reminder.
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

  /// Get the date only no timestamp included
  DateTime get _reminderDay => DateUtils.dateOnly(
    context.read<CalendarModel>().entryBeingEdited?.date ?? DateTime.now(),
  );

  /// Sub menu to select start time for the start date
  Future<void> _pickStartTime() async {
    final initial = _selectedStartTime ?? DateTime.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (picked == null || !mounted) return;
    final day = _reminderDay;
    setState(() {
      _selectedStartTime = DateTime(day.year, day.month, day.day, picked.hour, picked.minute,);
    });
  }
  /// Sub menu to select the end date including time
  Future<void> _pickEndDate() async {
    final day = _reminderDay;
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ?? day,
      firstDate: day,
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() => _selectedEndDate = picked);
  }
  /// Saves the entry being edited and placed into the table in the database
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final model = context.read<CalendarModel>();
    final reminder = model.entryBeingEdited!
      ..title = _titleController.text
      ..notes = _noteController.text
      ..color = _selectedColor
      ..startTime = _selectedStartTime
      ..endDate = _selectedEndDate;
    reminder.date ??= model.selectedDate;
    await model.stopEntry(save: true);
  }
  /// Builds the containers to select the date for the entry
  Widget _pickerRow({
    required IconData icon,
    required String text,
    required VoidCallback onPick,
    required VoidCallback onClear,
    required bool hasValue,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(text, style: const TextStyle(color: Colors.white)),
      trailing: hasValue
          ? IconButton(
              icon: const Icon(Icons.clear, color: Colors.white),
              onPressed: onClear,
            )
          : null,
      onTap: onPick,
    );
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
                              const Divider(height: 1,),
                              _pickerRow(
                                icon: Icons.access_time,
                                text: _selectedStartTime == null
                                    ? 'No start time'
                                    : 'Start: ${DateFormat('h:mm a').format(_selectedStartTime!)}',
                                hasValue: _selectedStartTime != null,
                                onPick: _pickStartTime,
                                onClear: () => setState(() => _selectedStartTime = null),
                              ),
                              _pickerRow(
                                icon: Icons.event,
                                text: _selectedEndDate == null
                                    ? 'No end date'
                                    : 'Ends: ${DateFormat.yMMMd().format(_selectedEndDate!)}',
                                hasValue: _selectedEndDate != null,
                                onPick: _pickEndDate,
                                onClear: () => setState(() => _selectedEndDate = null),
                              ),
                              const Divider(height: 1),
                              ColorPicker(
                                colorPickerWidth: 175,
                                pickerAreaHeightPercent: 1.2,
                                pickerColor: _selectedColor,
                                onColorChanged: (value) => _selectedColor = value,
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
                  onPressed: _save,
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
