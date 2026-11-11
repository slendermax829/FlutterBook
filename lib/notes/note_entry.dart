import 'dart:convert';
import 'dart:io';

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
  final _contentController = TextEditingController();
  
  NoteType? _noteType = NoteType.Content;
  Color _selectedColor = Colors.red;
  File? _audioFile;
  File? _videoFile;

  @override
  void initState() {
    final note = context.read<NoteModel>().entryBeingEdited;

    _titleController.text = note?.title ?? '';
    _descriptionController.text = note?.description ?? '';
    _noteType = note?.type ?? .Content;
    _selectedColor = note?.color ?? Colors.red;
    _contentController.text = note?.content ?? '';

    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _confirmSave(){
    final confirm = showDialog(
      context: context, 
      builder:(context){
        return AlertDialog(
          title: Text('Save Note?'),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

            ],
          ),
        );
      },
    );
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
                            Divider(color: Colors.white,),
                            _noteTypeContent(),
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

  Widget _noteTypeContent(){
    return SafeArea(
      child: RadioGroup<NoteType>(
        groupValue: _noteType,
        onChanged:(NoteType? type) {
          setState(() {
            _noteType = type;
          });
        }, 
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Type',style: TextStyle(fontSize: 24, color: Colors.white, decoration: TextDecoration.underline),),
            RadioListTile(
              value: NoteType.Content,
              title: const Text('Content'),
            ),
            RadioListTile(
              value: NoteType.Audio,
              title: const Text('Audio'),
            ),
            RadioListTile(
              value: NoteType.Video,
              title: const Text('Video'),
            )
          ],
        )
      ),
    );
  }

  Widget _insertContent(){
    switch (_noteType ?? .Content){
      case NoteType.Content:
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
      case NoteType.Audio:
        return Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                ElevatedButton.icon(
                  onPressed: () => debugPrint('uploading audio file'), 
                  icon: Icon(Icons.upload),
                  label: Text('Upload Audio File'),
                ),

              ],
            )
        );
      case NoteType.Video:
        return Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton.icon(
              onPressed: () => debugPrint('uploading video file'), 
              icon: Icon(Icons.upload),
              label: Text('Upload Video File'),
            )
        );
    }
  }
}
