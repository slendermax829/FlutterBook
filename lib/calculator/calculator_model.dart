import 'package:flutter_book/base_model.dart';
import 'package:flutter_book/calculator/calculator_db.dart';

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

class SavedCalculator extends Entry with DateMixin {
  String? name;

  SavedCalculator({super.id, this.name, int? dateUnix}) {
    dateInUnix = dateUnix;
  }
}

class CalculatorModel extends BaseModel<SavedCalculator> {
  final CalculatorDbWorker _calculatorWorker;
  SavedCalculator? _selectedCalculator;

  CalculatorModel.withWorker(CalculatorDbWorker worker)
    : _calculatorWorker = worker,
      super(worker) {
    worker.createTable().then((_) => loadData());
  }

  factory CalculatorModel() => CalculatorModel.withWorker(CalculatorDbWorker());

  SavedCalculator? get selectedCal => _selectedCalculator;
  
  set selectedCal(SavedCalculator? newCal) {
    _selectedCalculator = newCal;
    notifyListeners();
  }

  @override
  Future<void> deleteEntry(SavedCalculator entry) async {
    final index = entryList.indexWhere((item) => item.id == entry.id);
    final selected = _selectedCalculator?.id == entry.id ? _selectedCalculator : null;

    if (index != -1) entryList.removeAt(index);
    if (selected != null) _selectedCalculator = null;
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

  Future<List<CalculationHistory>> getCalculationHistoryFromSelected() async {
    final calculator = _selectedCalculator;

    if (calculator == null) {
      throw StateError('No calculator is selected.');
    }

    return await _calculatorWorker.getCalculationHistory(calculator);
  }

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

  Future<bool> get isHistoryEmpty async {
    final history = await getCalculationHistoryFromSelected();
    return history.isEmpty;
  }

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
