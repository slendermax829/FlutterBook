import 'package:flutter/material.dart';
import 'package:flutter_book/notes/note_model.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

class NoteEntry extends StatefulWidget {
  const NoteEntry({super.key});

  @override
  State<NoteEntry> createState() => _NoteEntryState();
}

class _NoteEntryState extends State<NoteEntry> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late Color _selectedColor;

  @override
  void initState() {
    final note = context.read<NoteModel>().entryBeingEdited;

    _titleController.text = note?.title ?? '';
    _descriptionController.text = note?.description ?? '';
    _selectedColor = note?.color ?? Colors.red;

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
    final model = context.watch<NoteModel>();
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
                      Container(
                        padding: EdgeInsets.all(15),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: .2),
                          borderRadius: BorderRadius.circular(10),
                        ),
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
                            ),
                            ColorPicker(
                              colorPickerWidth: 175,
                              pickerAreaHeightPercent: 1.2,
                              pickerColor: _selectedColor,
                              onColorChanged: (value) {
                                _selectedColor = value;
                              },
                            ),
                          ],
                        ),
                      ),
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
                  onPressed: () => model.stopEntry(save: false, notify: true),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () => debugPrint('saving new note'),
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
