import 'package:flutter/material.dart';
import 'package:flutter_book/calculator/calculator_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/// Displays the calculator and saved-calculator controls.
class CalculatorView extends StatefulWidget {
  const CalculatorView({super.key});

  @override
  State<CalculatorView> createState() => _CalculatorViewState();
}

class _CalculatorViewState extends State<CalculatorView> {
  final _scaffoldKey = GlobalKey<ScaffoldState>(); // key for drawer tabs

  String _display = '0';
  double? _storedValue; // whenever the value needs to be stored for calcuation
  String? _pendingOperator; // operator to calculate the two operands
  bool _startNewNumber = false;
  
  ///Enters or appends digits to the calcuator displayer
  void _inputDigit(String digit) {
    setState(() {
      if (_display == 'Error' || _startNewNumber) {
        _display = digit; // resets
        _startNewNumber = false;
      } else if (_display == '0') {
        _display = digit; //switches from 0
      } else {
        _display += digit; // appends
      }
    });
  }
  ///Enters a decimal when the decimal button is pressed
  void _inputDecimal() {
    setState(() {
      if (_display == 'Error' || _startNewNumber) {
        _display = '0.';
        _startNewNumber = false;
      } else if (!_display.contains('.')) {
        _display += '.';
      }
    });
  }

  /// Sets the operator to be use for calcuation
  void _chooseOperator(String operator) {
    final currentValue = double.tryParse(_display);
    if (currentValue == null) return;

    setState(() {
      if (_storedValue != null && _pendingOperator != null && !_startNewNumber) {
        _applyPendingOperation(currentValue); // applies operator to number that is displayed
      } else {
        _storedValue = currentValue; // stores the value from displayer
      }
      _pendingOperator = operator;
      _startNewNumber = true; // displays a new number after operator
    });
  }
  
  /// Calculates the final result and displays it
  void _calculate() {
    final currentValue = double.tryParse(_display);
    if (_storedValue == null ||
        _pendingOperator == null ||
        currentValue == null) {
      return;
    }

    setState(() {
      _applyPendingOperation(currentValue);
      _storedValue = null; // reset in case or error
      _pendingOperator = null;
      _startNewNumber = true;
    });
  }
  /// Applies the stored value with operator to make a calculation
  void _applyPendingOperation(double currentValue) {
    final leftValue = _storedValue!;
    final operator = _pendingOperator!;
    final result = switch (_pendingOperator) {
      '+' => _storedValue! + currentValue,
      '−' => _storedValue! - currentValue,
      '×' => _storedValue! * currentValue,
      '÷' => currentValue == 0 ? null : _storedValue! / currentValue, //anything is divided by 0 is a error
      _ => null, //default is null
    };

    _display = result == null ? 'Error' : _formatResult(result);
    // _history.insert(
    //   0,
    //   '${_formatResult(leftValue)} $operator '
    //   '${_formatResult(currentValue)} = $_display',
    // );

    final history = CalculationHistory(
      expression: '${_formatResult(leftValue)} $operator ${_formatResult(currentValue)} =',
      result: _display,
      operationType: operator
    ); // creates a new history 

    _saveHistory(history);

    _storedValue = result;
  }
  /// Toggles the digit either to negative or positive vice versa
  void _toggleSign() {
    final currentValue = double.tryParse(_display);
    if (currentValue == null || currentValue == 0) return;

    setState(() {
      _display = _formatResult(-currentValue);
    });
  }
  /// Changes value to a decimal form of a percentage
  void _applyPercent() {
    final currentValue = double.tryParse(_display);
    if (currentValue == null) return;

    setState(() {
      _display = _formatResult(currentValue / 100);
      _startNewNumber = true;
    });
  }
  /// Resets the value, stored value, and operator
  /// 
  /// Displays 0 at the end
  void _clear() {
    setState(() {
      _display = '0';
      _storedValue = null;
      _pendingOperator = null;
      _startNewNumber = false;
    });
  }
  /// Formats the result from the given value
  String _formatResult(double value) {
    if (!value.isFinite) return 'Error';

    final rounded = value.toStringAsPrecision(12);
    if (rounded.contains('e')) return rounded; // returns value if 'e' is from the string
    if (!rounded.contains('.')) return rounded; // returns whenever '.' is present from the string

    return rounded
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }
  /// Applies button logic for any button that is pressed
  /// 
  /// Calls other functions that are associated with the pressed button
  void _onButtonPressed(String label) {
    if (RegExp(r'^\d$').hasMatch(label)) {
      _inputDigit(label); // if a digit number is pressed
      return;
    }

    switch (label) {
      case 'AC':
        _clear();
      case '+/−':
        _toggleSign();
      case '%':
        _applyPercent();
      case '.':
        _inputDecimal();
      case '=':
        _calculate();
      default:
        _chooseOperator(label); // for operand buttons +-x÷
    }
  }

  void _openHistory() => _scaffoldKey.currentState?.openDrawer(); 

  void _openSavedCalculators() => _scaffoldKey.currentState?.openEndDrawer();

  /// Saves the history by creating [CalculationHistory] object a from the calcuation
  /// 
  /// Stores the object to the database
  Future<void> _saveHistory(CalculationHistory history) async {
    final model = context.read<CalculatorModel>();
    if (model.selectedCal == null) { // if no calcuator is selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a calculator to save history.')),
      );
      return;
    }

    try {
      await model.insertHistoryToSelected(history);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save history: $error')),
      );
    }
  }

  /// Clears the history from the selected calcuator
  Future<void> _clearHistory(CalculatorModel model) async {
    try {
      await model.deleteHistoryFromSelected();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not clear history: $error')),
      );
    }
  }

  /// Deletes the calculator from the model entry list
  /// 
  /// It also erases its calcuation history associated with it
  Future<void> _deleteCalculator(SavedCalculator calculator) async {
    try {
      await context.read<CalculatorModel>().deleteEntry(calculator);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deleted calculator: ${calculator.name}')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete calculator: $error')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final model = context.watch<CalculatorModel>();
    final selectedCal = model.selectedCal;
    
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        shape: BoxBorder.all(color: Colors.white),
        child: SafeArea(
          child: Column(
            children: [
              ListTile(
                title: const Text(
                  'History',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                trailing: IconButton(
                  tooltip: 'Clear history',
                  onPressed: selectedCal == null
                      ? null
                      : () => _clearHistory(model),
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: selectedCal == null
                    ? const Center(
                        child: Text('Select a calculator to view history'),
                      )
                    : FutureBuilder<List<CalculationHistory>>(
                  key: ValueKey(selectedCal.id),
                  future: model.getCalculationHistoryFromSelected(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Could not load history: ${snapshot.error}'));
                    }
                    final history = snapshot.data ?? const <CalculationHistory>[];
                    return history.isEmpty
                        ? const Center(child: Text('No calculations yet'))
                        : ListView.builder(
                            itemCount: history.length,
                            itemBuilder: (context, index) {
                              final hist = history[index];

                              return ListTile(
                              title: Text(hist.expression ?? '?'),
                              trailing: Text(hist.result ?? 'inf'),
                            );
                            },
                          );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      endDrawer: Drawer(
        shape: BoxBorder.all(color: Colors.white),
        child: SafeArea(
          child: Column(
            children: [
              ListTile(
                title: const Text(
                  'Your calculators',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Swipe to the right to edit or left to delete',style: TextStyle(fontSize: 10),),
              ),
              const Divider(height:  1,),
              Expanded(
                child: model.entryList.isEmpty
                    ? const Center(child: Text('No calculators yet\ntry adding one',textAlign: .center,))
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        itemCount: model.entriesLength,
                        itemBuilder: (context, index) {
                          final cal = model.entryList[index];
                          return _buildSavedCalculatorPanel(cal);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        leading: IconButton(
          onPressed: _openHistory,
          tooltip: 'Open history',
          icon: const Icon(Icons.history),
        ),
        title: Text(selectedCal?.name ?? 'Calculator'),
        actions: [
          IconButton(
            onPressed: _openSavedCalculators,
            tooltip: 'Switch calculator',
            icon: const Icon(Icons.swap_horiz_outlined),
          ),
          IconButton(
            onPressed: () {
              final now = DateTime.now();
              final unix = now.millisecondsSinceEpoch;

              model.setEntry(SavedCalculator(dateUnix: unix));
            },
            tooltip: 'Create new calculator',
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.bottomRight,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  child: Text(
                    _display,
                    key: const Key('calculator-display'),
                    maxLines: 1,
                    style: const TextStyle(fontSize: 72),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  _buildRow(['AC', '+/−', '%', '÷']),
                  _buildRow(['7', '8', '9', '×']),
                  _buildRow(['4', '5', '6', '−']),
                  _buildRow(['1', '2', '3', '+']),
                  Expanded(
                    child: Row(
                      children: [
                        _buildButtonSlot('0', flex: 2),
                        _buildButtonSlot('.'),
                        _buildButtonSlot('='),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  /// Builds a row of buttons by calling [_buildButtonSlot] from the length of [labels]
  Widget _buildRow(List<String> labels) {
    return Expanded(
      child: Row(
        children: [for (final label in labels) _buildButtonSlot(label)],
      ),
    );
  }

  /// Builds a button widget and assigns an operation depending if its a utility button or operator
  Widget _buildButtonSlot(String label, {int flex = 1}) {
    final isUtilityButton = label == 'AC' || label == '+/−' || label == '%';
    final isOperatorButton = const {'÷', '×', '−', '+', '='}.contains(label);

    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ElevatedButton(
          onPressed: () => _onButtonPressed(label),
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            backgroundColor: isOperatorButton
                ? Colors.amber.shade900
                : isUtilityButton
                ? Colors.grey.shade400
                : Colors.grey.shade900,
            foregroundColor: isUtilityButton ? Colors.black : Colors.white,
            padding: EdgeInsets.zero,
          ),
          child: FittedBox(
            child: Text(label, style: const TextStyle(fontSize: 32)),
          ),
        ),
      ),
    );
  }
  /// Builds a saved slidable calculator panel
  Widget _buildSavedCalculatorPanel(SavedCalculator savedCal){
    final date = DateFormat.yMMMd().format(savedCal.date ?? DateTime(2099,1,1));
    return Slidable(
      key: ValueKey(savedCal.id),
      endActionPane: ActionPane(
        motion: const DrawerMotion(), 
        dismissible: DismissiblePane(
          onDismissed: () => _deleteCalculator(savedCal),
        ),
        children: [
          SlidableAction(
            onPressed:(context) {},
            backgroundColor: Colors.redAccent.withValues(alpha: .3),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          )
        ],
      ),

      startActionPane: ActionPane(
        motion: const DrawerMotion(), 
        children: [
          SlidableAction(
            flex: 2,
            onPressed: (context){
              context.read<CalculatorModel>().setEntry(savedCal);
            },
            backgroundColor: Colors.lightGreenAccent.shade400.withValues(alpha: .3),
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Edit',
          )
        ]
      ),
      child: Card(
        shape: context.read<CalculatorModel>().selectedCal != null ? Border.all(color: Colors.white) : null,
        color: Colors.blue.withValues(alpha: .25),
        child: ListTile(
          leading: Icon(Icons.calculate_sharp),
          title: Text(savedCal.name ?? 'Unknown'),
          subtitle: Text(date),
          onTap: () {
            context.read<CalculatorModel>().selectedCal = savedCal;
          },
        ),
      ),
    );
  }
}
