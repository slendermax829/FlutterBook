import 'package:flutter/material.dart';
import 'package:flutter_book/calculator/calculator_entry.dart';
import 'package:flutter_book/calculator/calculator_model.dart';
import 'package:flutter_book/calculator/calculator_view.dart';
import 'package:provider/provider.dart';

/// Switches between the calculator view and saved-calculator editor.
class Calculator extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CalculatorModel>();
    return IndexedStack(
      index: model.screen,
      children: [
        CalculatorView(),
        CalculatorEntry(key: ObjectKey(model.entryBeingEdited))
      ],
    );
  }
}