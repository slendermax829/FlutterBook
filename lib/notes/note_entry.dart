import 'dart:convert';
import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_book/base_model.dart';
import 'package:flutter_book/notes/note_model.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';

class NoteEntry extends StatefulWidget {
  const NoteEntry({super.key});

  @override
  State<NoteEntry> createState() => _NoteEntryState();
}

class _NoteEntryState extends State<NoteEntry> with FileUploader, DateMixin, FireBaseUploader {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();

  Color _selectedColor = Colors.red;

  @override
  void initState() {
    final note = context.read<NoteModel>().entryBeingEdited;

    _titleController.text = note?.title ?? '';
    _descriptionController.text = note?.description ?? '';
    _selectedColor = note?.color ?? Colors.red;
    _contentController.text = note?.content ?? '';
    //date = note?.date;

    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _confirmSave() async{
    final confirm = await showDialog<bool>(
      context: context, 
      barrierDismissible: false,
      builder:(context){
        return AlertDialog(
          title: Text('Save Note?'),
          titleTextStyle: TextStyle(fontSize: 24),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Title: ${_titleController.text}'),
              Text('Description: ${_descriptionController.text}'),
              Text('Date: ${formattedDate ?? 'No Date Selected'}'),
              Text('Content: ${_contentController.text}')
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if(confirm ?? false){
      _saveNote();
    }
  }

  Future<void> _saveNote() async{
    final model = context.read<NoteModel>();
    final messenger = ScaffoldMessenger.of(context);
    final existing = model.entryBeingEdited;

    final dateMade = DateTime.now();

    model.entryBeingEdited = Note(
      id: existing?.id ?? Entry.noId,
      title: _titleController.text,
      description: _descriptionController.text,
      color: _selectedColor,
      content: _contentController.text,
      dateUnix: dateMade.millisecondsSinceEpoch,
    );

    final editedNote = model.entryBeingEdited;

    messenger.showSnackBar(
      SnackBar(
        content: editedNote!.isNew
                  ? Text('Success: New note created ${editedNote.title}')
                  : Text('Success: New note updated ${editedNote.title}'),
      )
    );

    await model.stopEntry(save: true);
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
                            Divider(color: Colors.white,),
                            _insertContent(),
                            Divider(color: Colors.white,),
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
                  onPressed: () {
                    resetFile();
                    model.stopEntry(save: false, notify: true);
                  },
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    if(_formKey.currentState!.validate()){
                      _confirmSave();
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

  Widget _insertContent(){
    return SizedBox(
      height: 200,
      child: TextFormField(
        expands: true,
        maxLines: null,
        minLines: null,
        controller: _contentController,
        maxLength: 100,
        cursorColor: Colors.white,
        textAlignVertical: TextAlignVertical.top,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
        border: OutlineInputBorder(),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        icon: Icon(Icons.edit),
        label: Text('Content'),
        labelStyle: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
