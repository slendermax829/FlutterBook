import 'package:flutter_book/base_model.dart';
import 'package:flutter_book/calculator/calculator_db.dart';

class CalculationHistory extends Entry{
  String? expression;
  String? result;
  String? operationType;

  CalculationHistory({
    super.id,
    this.expression,
    this.result,
    this.operationType
  });
}

class SavedCalculator extends Entry with DateMixin{
  String? name;
  List<CalculationHistory>? history;

  SavedCalculator({
    super.id,
    this.name,
    int? dateUnix
  }){
    dateInUnix = dateUnix;
  }
}

class CalculatorModel extends BaseModel<SavedCalculator>{
  CalculatorModel():super(CalculatorDbWorker()){
    worker.createTable().then((_) => loadData());
  }

}