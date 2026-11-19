import 'package:flutter/material.dart';
import 'package:flutter_book/calculator/calculator_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CalculatorView extends StatefulWidget {
  const CalculatorView({super.key});

  @override
  State<CalculatorView> createState() => _CalculatorViewState();
}

class _CalculatorViewState extends State<CalculatorView> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<String> _history = [];

  String _display = '0';
  double? _storedValue;
  String? _pendingOperator;
  bool _startNewNumber = false;

  void _inputDigit(String digit) {
    setState(() {
      if (_display == 'Error' || _startNewNumber) {
        _display = digit;
        _startNewNumber = false;
      } else if (_display == '0') {
        _display = digit;
      } else {
        _display += digit;
      }
    });
  }

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

  void _chooseOperator(String operator) {
    final currentValue = double.tryParse(_display);
    if (currentValue == null) return;

    setState(() {
      if (_storedValue != null &&
          _pendingOperator != null &&
          !_startNewNumber) {
        _applyPendingOperation(currentValue);
      } else {
        _storedValue = currentValue;
      }
      _pendingOperator = operator;
      _startNewNumber = true;
    });
  }

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

  void _applyPendingOperation(double currentValue) {
    final leftValue = _storedValue!;
    final operator = _pendingOperator!;
    final result = switch (_pendingOperator) {
      '+' => _storedValue! + currentValue,
      '−' => _storedValue! - currentValue,
      '×' => _storedValue! * currentValue,
      '÷' => currentValue == 0 ? null : _storedValue! / currentValue,
      _ => null,
    };

    _display = result == null ? 'Error' : _formatResult(result);
    _history.insert(
      0,
      '${_formatResult(leftValue)} $operator '
      '${_formatResult(currentValue)} = $_display',
    );
    _storedValue = result;
  }

  void _toggleSign() {
    final currentValue = double.tryParse(_display);
    if (currentValue == null || currentValue == 0) return;

    setState(() {
      _display = _formatResult(-currentValue);
    });
  }

  void _applyPercent() {
    final currentValue = double.tryParse(_display);
    if (currentValue == null) return;

    setState(() {
      _display = _formatResult(currentValue / 100);
      _startNewNumber = true;
    });
  }

  void _clear() {
    setState(() {
      _display = '0';
      _storedValue = null;
      _pendingOperator = null;
      _startNewNumber = false;
    });
  }

  String _formatResult(double value) {
    if (!value.isFinite) return 'Error';

    final rounded = value.toStringAsPrecision(12);
    if (rounded.contains('e')) return rounded;
    if (!rounded.contains('.')) return rounded;

    return rounded
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  void _onButtonPressed(String label) {
    if (RegExp(r'^\d$').hasMatch(label)) {
      _inputDigit(label);
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
      case '+':
      case '−':
      case '×':
      case '÷':
        _chooseOperator(label);
    }
  }

  void _openHistory() {
    _scaffoldKey.currentState?.openDrawer();
  }

  void _openSavedCalculators() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  void _clearHistory() {
    setState(_history.clear);
  }

  Future<void> _deleteCalculator(SavedCalculator calculator) async {
    try {
      await context.read<CalculatorModel>().deleteEntry(calculator);
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
                  onPressed: _history.isEmpty ? null : _clearHistory,
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: FutureBuilder<List<CalculationHistory>>(
                  future: model.getCalculationHistoryFromSelected(),
                  builder: (context, snapshot) {
                    final history = snapshot.data ?? const <CalculationHistory>[];
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return history.isEmpty
                        ? const Center(child: Text('No calculations yet'))
                        : ListView.builder(
                            itemCount: history.length,
                            itemBuilder: (context, index) => ListTile(
                              title: Text(history[index].toString()),
                            ),
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
                          return _buildCalPanel(cal);
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

  Widget _buildRow(List<String> labels) {
    return Expanded(
      child: Row(
        children: [for (final label in labels) _buildButtonSlot(label)],
      ),
    );
  }

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

  Widget _buildCalPanel(SavedCalculator savedCal){
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
            label: 'Edit Calculator',
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
