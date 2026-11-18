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

class _NoteEntryState extends State<NoteEntry> with FileUploader, DateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();
  
  NoteType? _noteType = NoteType.Content;
  Color _selectedColor = Colors.red;

  @override
  void initState() {
    final note = context.read<NoteModel>().entryBeingEdited;

    _titleController.text = note?.title ?? '';
    _descriptionController.text = note?.description ?? '';
    _noteType = note?.type ?? .Content;
    _selectedColor = note?.color ?? Colors.red;
    _contentController.text = note?.content ?? '';
    date = note?.date;

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
              _noteType == .Content
                ? Text('Content: ${_contentController.text}')
                : Text('${_noteType!.name} File: ${selectedFileName ?? 'No File Selected'}')
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

  void _saveNote(){
    //debugPrint('Saving Note');
    final Note newNote = Note(
      title: _titleController.text,
      description: _descriptionController.text,
      color: _selectedColor,
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
                            _dateField(),
                            Divider(color: Colors.white,),
                            _noteTypeContent(),
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
                  onPressed: () => _confirmSave(),
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateField(){
    return ListTile(
      leading: const Icon(Icons.calendar_today, color: Colors.white),
      title: Text(
        formattedDate ?? 'No date selected',
        style: const TextStyle(color: Colors.white),
      ),
      trailing: hasDate
          ? IconButton(
              icon: const Icon(Icons.clear, color: Colors.white),
              onPressed: () => setState(() => date = null),
            )
          : null,
      onTap: () async {
        final picked = await pickDate(context);
        if (picked != null && mounted) setState(() {});
      },
    );
  }

  Widget _noteTypeContent(){
    return SafeArea(
      child: RadioGroup<NoteType>(
        groupValue: _noteType,
        onChanged:(NoteType? type) {
          setState(() {
            resetFile();
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
        return _buildFileUploader(fileType: .Audio);
      case NoteType.Video:
        return _buildFileUploader(fileType: .Video);
    }
  }

  Widget _buildFileUploader({required NoteType fileType}){
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      highlightColor: Colors.grey.withValues(alpha: .2),
      splashColor: Colors.grey.withValues(alpha: .4),
      onTap: () async {
        final picked = fileType == .Audio
            ? await pickAudioFile()
            : await pickVideoFile();
        if (picked && mounted) setState(() {});
      },
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          spacing: 20,
          children: [
            SizedBox(
              width: .infinity,
              child: DottedBorder(
                options: RectDottedBorderOptions(
                  color: Colors.white,
                  dashPattern: [6,4],
                  strokeWidth: 2,
                  padding: EdgeInsets.all(20),
                ),
                child: Center(
                  child: Column(
                    spacing: 12,
                    mainAxisAlignment: .center,
                    children: [
                      const Icon(Icons.upload, size: 46,),
                      fileType == _noteType 
                        ? Text(selectedFileName ?? 'Upload File Here')
                        : Text('Upload File Here')
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
