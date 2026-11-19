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

  CalculatorModel._(CalculatorDbWorker worker)
    : _calculatorWorker = worker,
      super(worker) {
    worker.createTable().then((_) => loadData());
  }

  factory CalculatorModel() => CalculatorModel._(CalculatorDbWorker());

  SavedCalculator get selectedCal => _selectedCalculator!;
  set selectedCal(SavedCalculator newCal) => _selectedCalculator = newCal;

  Future<List<CalculationHistory>> getCalculationHistoryFromSelected() async {
    final calculator = _selectedCalculator;

    if (calculator == null) {
      throw StateError('No calculator is selected.');
    }

    return _calculatorWorker.getCalculationHistory(calculator);
  }

  Future<int> insertHistoryToSelected(CalculationHistory entry) async {
    final calculator = _selectedCalculator;

    if (calculator == null) {
      throw StateError('No calculator is selected.');
    }
    if (calculator.isNew) {
      throw StateError('Save the calculator before adding history.');
    }

    return _calculatorWorker.createHistory(calculator.id, entry);
  }

  Future<int> deleteHistoryFromSelected() async {
    final calculator = _selectedCalculator;

    if (calculator == null) {
      throw StateError('No calculator is selected.');
    }
    if (calculator.isNew) {
      throw StateError('Save the calculator before adding history.');
    }

    return _calculatorWorker.deleteHistory(calculator.id);
  }
}
