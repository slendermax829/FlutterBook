import 'package:flutter_book/base_model.dart';
import 'package:flutter_book/calculator/calculator_db.dart';

/// A saved calculation and its associated calculator identifier.
class CalculationHistory extends Entry {
  String? expression;
  String? result;
  String? operationType;
  int? calculatorId;

  CalculationHistory({
    super.id,
    this.expression,
    this.result,
    this.operationType,
    this.calculatorId,
  });
}

/// A named calculator that can have a history of calculations.
class SavedCalculator extends Entry with DateMixin {
  String? name;

  SavedCalculator({super.id, this.name, int? dateUnix}) {
    dateInUnix = dateUnix;
  }
}

/// Manages saved calculators, selection, and calculation history.
class CalculatorModel extends BaseModel<SavedCalculator> {
  final CalculatorDbWorker _calculatorWorker; // A another db worker that helps with CalculationHistory entries since it has its own properties
  SavedCalculator? _selectedCalculator;

  /// Creates a model using the supplied SQLite worker.
  CalculatorModel.withWorker(CalculatorDbWorker worker)
    : _calculatorWorker = worker, // Calcuation history foreign/child table
      super(worker) {
    worker.createTable().then((_) => loadData()); // same thing with parent table buts with the child table
  }

  /// Creates a model using the default calculator worker.
  factory CalculatorModel() => CalculatorModel.withWorker(CalculatorDbWorker());

  /// The currently selected calculator, if any.
  SavedCalculator? get selectedCal => _selectedCalculator;
  
  /// Changes the selected calculator and notifies listeners.
  set selectedCal(SavedCalculator? newCal) {
    _selectedCalculator = newCal;
    notifyListeners();
  }

  @override
  Future<void> deleteEntry(SavedCalculator entry) async {
    final index = entryList.indexWhere((item) => item.id == entry.id);
    final selected = _selectedCalculator?.id == entry.id ? _selectedCalculator : null;

    if (index != -1) entryList.removeAt(index); // remove from list for safe handling
    if (selected != null) _selectedCalculator = null; // changes selected calculator to null if it equals to the one being deleted
    notifyListeners();

    try {
      await worker.delete(entry); 
    } catch (_) {
      if (index != -1 && !entryList.any((item) => item.id == entry.id)) {
        entryList.insert(index < entryList.length ? index : entryList.length, entry);
      }
      if (selected != null && _selectedCalculator == null) {
        _selectedCalculator = selected;
      }
      notifyListeners();
      rethrow;
    }
  }

  /// Returns the selected calculator's history, newest first.
  ///
  /// Throws [StateError] when no calculator is selected.
  Future<List<CalculationHistory>> getCalculationHistoryFromSelected() async {
    final calculator = _selectedCalculator;

    if (calculator == null) {
      throw StateError('No calculator is selected.');
    }

    return await _calculatorWorker.getCalculationHistory(calculator);
  }

  /// Adds history to the selected saved calculator and returns its row ID.
  ///
  /// Throws [StateError] if no calculator is selected or it has not been saved.
  Future<int> insertHistoryToSelected(CalculationHistory entry) async {
    final calculator = _selectedCalculator;

    if (calculator == null) {
      throw StateError('No calculator is selected.');
    }
    if (calculator.isNew) {
      throw StateError('Save the calculator before adding history.');
    }

    int id = await _calculatorWorker.createHistory(calculator.id, entry);

    await loadData();

    return id;
  }

  /// Whether the selected calculator has no history.
  ///
  /// Throws [StateError] when no calculator is selected.
  Future<bool> get isHistoryEmpty async {
    final history = await getCalculationHistoryFromSelected();
    return history.isEmpty;
  }

  /// Deletes the selected calculator's history and returns the number deleted.
  ///
  /// Throws [StateError] if no calculator is selected or it has not been saved.
  Future<int> deleteHistoryFromSelected() async {
    final calculator = _selectedCalculator;

    if (calculator == null) {
      throw StateError('No calculator is selected.');
    }
    if (calculator.isNew) {
      throw StateError('Save the calculator before adding history.');
    }

    int id = await _calculatorWorker.deleteHistory(calculator.id);
    await loadData();
    return id;
  }
}
