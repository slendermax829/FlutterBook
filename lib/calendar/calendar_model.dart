
import 'package:flutter/material.dart';
import 'package:flutter_book/base_model.dart';
import 'package:flutter_book/calendar/calendar_db.dart';

/// A reminder that belongs to a calendar day ([date], from [DateMixin]).
class CalendarReminder extends Entry with DateMixin{
  String? title;
  String? notes;
  DateTime? startTime;
  DateTime? endDate;
  Color? color;
  bool isCompleted;

  CalendarReminder({
    super.id,
    this.title,
    this.notes,
    this.startTime,
    this.endDate,
    this.color,
    this.isCompleted = false,
    DateTime? reminderDate,
  }){
    date = reminderDate;
  }

  int get colorInt => (color ?? Colors.red).toARGB32();
}

class CalendarModel extends BaseModel<CalendarReminder>{
  DateTime _selectedDate = DateUtils.dateOnly(DateTime.now());

  CalendarModel():super(CalendarDbWorker()){
    worker.createTable().then((_) => loadData());
  }

  DateTime get selectedDate => _selectedDate;

  List<CalendarReminder> get remindersForSelectedDate => remindersOn(_selectedDate);

  List<CalendarReminder> remindersOn(DateTime day){
    return entryList
      .where((r) => r.date != null && DateUtils.isSameDay(r.date, day))
      .toList();
  }

  void selectDate(DateTime day){
    _selectedDate = DateUtils.dateOnly(day);
    notifyListeners();
  }
}