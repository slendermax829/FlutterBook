
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
  /// Gets the instance's color 32 bit integer value
  int get colorInt => (color ?? Colors.red).toARGB32();
}

/// Manages reminders and the calendar's selected day.
class CalendarModel extends BaseModel<CalendarReminder>{
  DateTime _selectedDate = DateUtils.dateOnly(DateTime.now()); // defaults to today whenever app is launched

  CalendarModel():super(CalendarDbWorker()){
    worker.createTable().then((_) => loadData());
  }

  /// Gets the selected day from [_selectedDate]
  DateTime get selectedDate => _selectedDate;

  /// Reminders whose dates fall on the selected day.
  List<CalendarReminder> get remindersForSelectedDate => remindersOn(_selectedDate);

  /// Returns loaded reminders whose dates fall on the selected [day].
  List<CalendarReminder> remindersOn(DateTime day){
    return entryList
      .where((r) => r.date != null && DateUtils.isSameDay(r.date, day))
      .toList();
  }

  /// Selects and sets the calendar day and notifies listeners.
  void selectDate(DateTime day){
    _selectedDate = DateUtils.dateOnly(day);
    notifyListeners();
  }
}