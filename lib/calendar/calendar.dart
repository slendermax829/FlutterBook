import 'package:flutter/material.dart';
import 'package:flutter_book/calendar/calendar_model.dart';
import 'package:flutter_book/calendar/calendar_view.dart';
import 'package:flutter_book/calendar/reminder_entry.dart';
import 'package:provider/provider.dart';

class Calendar extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<CalendarModel>();
    return IndexedStack(
      index: model.screen,
      children: [
        CalendarViewer(),
        ReminderEntry(),
      ],
    );
  }
}