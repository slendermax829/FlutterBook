import 'package:flutter/material.dart';
import 'package:flutter_book/bookmark/bookmark_model.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

/// Form for creating or editing a bookmark.
class BookmarkEntry extends StatefulWidget {
  const BookmarkEntry({super.key});

  @override
  State<BookmarkEntry> createState() => _BookmarkEntryState();
}

class _BookmarkEntryState extends State<BookmarkEntry> {
  /// Boolean variable to check if link is valid or not
  bool _isCheckingURL = false;

  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _urlController = TextEditingController();

  String get _formattedURL{
    return _urlController.text.startsWith('http') 
              ? _urlController.text
              : 'https://${_urlController.text}';
  }

  @override
  void initState() {
    final bookmark = context.read<BookmarkModel>().entryBeingEdited;
    _nameController.text = bookmark?.name ?? '';
    _urlController.text = bookmark?.url ?? '';
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    super.dispose();
  }
  
  /// Validates if the url link is true or not
  Future<bool> _validateURL() async {
    setState(() => _isCheckingURL = true,);

    final formatted = _formattedURL;

    try{
      final url = Uri.parse(formatted);
      final response = await http.get(url);

      if(!mounted) return false;

      final isValid = response.statusCode >= 200 && response.statusCode < 400;

      if(!isValid){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Link returned ${response.statusCode}')),
        );
      }

      return isValid;

    }catch(e) {
      if (!mounted) return false;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid or unreachable link')),
      );

      return false;

    } finally{
      if(mounted){
        setState(() => _isCheckingURL = false);
      }
    }
  }

  /// Inner functionally to save bookmark
  /// 
  /// Will be called if and only if [_validateURL] is `true`
  void _saveBookmark() async{
    if(!await _validateURL()) return;
    if (!mounted) return;

    final model = context.read<BookmarkModel>();
    final messenger = ScaffoldMessenger.of(context);
    final existing = model.entryBeingEdited;
    if (existing == null) {
      messenger.showSnackBar(const SnackBar(content: Text('No bookmark to save')));
      return;
    }

    final isNew = existing.isNew;
    existing.name = _nameController.text;
    existing.url = _formattedURL;
    existing.date = DateTime.now();
    try {
      await model.stopEntry(save: true, notify: true);
      if (messenger.mounted) {
        messenger.showSnackBar(SnackBar(
          content: Text(isNew
              ? 'Success: New bookmark created ${existing.name}'
              : 'Success: Bookmark updated ${existing.name}'),
        ));
      }
    } catch (e) {
      debugPrint('Error saving bookmark: $e');
      if (messenger.mounted) {
        messenger.showSnackBar(SnackBar(content: Text('Error saving bookmark: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<BookmarkModel>();
    return Stack(
      children: [
          Form(
          key: _formKey,
          child: Center(
            child: Padding(
              padding: const EdgeInsetsGeometry.all(50),
              child: Material(
                color: Colors.grey.withValues(alpha: .2),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsetsGeometry.all(15),
                  child: Column(
                    mainAxisAlignment: .spaceEvenly,
                    children: [
                      Text(
                        'New Bookmark',
                        textAlign: .left,
                        style: TextStyle(
                          letterSpacing: 5,
                          fontSize: 36
                        ),
                      ),
                      TextFormField(
                        controller: _nameController,
                        maxLength: 15,
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
                            icon: Icon(Icons.create_sharp),
                            label: Text('Name'),
                            labelStyle: TextStyle(color: Colors.white),
                        ),
                        validator: (value) {
                          if(value == null || value.isEmpty){
                            return 'A name must be provided';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _urlController,
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
                            icon: Icon(Icons.language),
                            label: Text('Url Link'),
                            labelStyle: TextStyle(color: Colors.white),
                        ),
                        validator: (value) {
                          if(value == null || value.isEmpty){
                            return 'A url link must be provided';
                          }
                          return null;
                        },
                      ),
                      Row(
                        mainAxisAlignment: .end,
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
                                model.entryBeingEdited?.name = _nameController.text;
                                _saveBookmark();
                              }
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        if(_isCheckingURL)
          Container(
            color: Colors.black.withValues(alpha: .4),
            child: const Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.blue,
              ),
            ),
          )
      ]
    );
  }
}