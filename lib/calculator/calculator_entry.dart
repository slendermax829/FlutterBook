import 'package:flutter/material.dart';
import 'package:flutter_book/calculator/calculator_model.dart';
import 'package:provider/provider.dart';

class CalculatorEntry extends StatefulWidget {
  const CalculatorEntry({super.key});

  @override
  State<CalculatorEntry> createState() => _CalculatorEntryState();
}

class _CalculatorEntryState extends State<CalculatorEntry> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void initState() {
    final saved = context.read<CalculatorModel>().entryBeingEdited;
    _nameController.text = saved?.name ?? '';
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CalculatorModel>();
    return Form(
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
                    'New Calculator',
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
                            model.entryBeingEdited
                              ?..name = _nameController.text;
                              
                            model.stopEntry(save: true, notify: true);
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
    );
  }
}