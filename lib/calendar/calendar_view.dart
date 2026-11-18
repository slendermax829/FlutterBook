import 'package:flutter/material.dart';
import 'package:flutter_book/calendar/calendar_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarViewer extends StatefulWidget {
  const new({super.key});

  @override
  State<CalendarViewer> createState() => _CalendarViewerState();
}

class _CalendarViewerState extends State<CalendarViewer> {
  final _calendarController = CalendarController();
  late DateTime _selectedDate;

  DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

  String dateFormat(DateTime date) => DateFormat.yMMMd().format(date);

  @override
  void initState() {
    super.initState();
    _selectedDate = dateOnly(DateTime.now());
    _calendarController.displayDate = _selectedDate;
    _calendarController.selectedDate = _selectedDate;
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  void _onDateSelected(CalendarTapDetails details) {
    final date = details.date;
    if (date == null || details.targetElement != CalendarElement.calendarCell) return;
    setState(() => _selectedDate = dateOnly(date));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: SfCalendar(
            showTodayButton: true,
            controller: _calendarController,
            view: CalendarView.month,
            backgroundColor: Colors.black,
            cellBorderColor: Colors.white24,
            selectionDecoration: BoxDecoration(
              border: BoxBorder.all(color: Colors.blue)
            ),
            todayHighlightColor: Colors.blue,
            headerStyle: const CalendarHeaderStyle(
              backgroundColor: Colors.black,
              textStyle: TextStyle(color: Colors.white, fontSize: 18),
            ),
            viewHeaderStyle: const ViewHeaderStyle(
              backgroundColor: Colors.black,
              dayTextStyle: TextStyle(color: Colors.white),
            ),
            monthViewSettings: const MonthViewSettings(
              monthCellStyle: MonthCellStyle(
                textStyle: TextStyle(color: Colors.white),
                trailingDatesTextStyle: TextStyle(color: Colors.white54),
                leadingDatesTextStyle: TextStyle(color: Colors.white54),
              ),
            ),
            onTap: _onDateSelected,
          ),
        ),
        Expanded(
          flex: 2,
          child: _remindersPanel(),
        ),
      ],
    );
  }

  Widget _remindersPanel() {
    final model = context.watch<CalendarModel>();
    return Material(
      color: Colors.grey.withValues(alpha: .2),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Column(
        children: [
          ListTile(
            title: Text(
              dateFormat(_selectedDate),
              style: const TextStyle(fontSize: 20),
            ),
            subtitle: const Text('Reminders'),
            trailing: IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add new reminder',
              onPressed: () => model.setEntry(CalendarReminder(reminderDate: _selectedDate)),
            ),
          ),
          const Divider(height: 1, color: Colors.white),
          Expanded(
            child: model.remindersForSelectedDate.isEmpty
                    ? Center(child: const Text('No Reminders added for this day'))
                    : ListView.builder(
                      itemCount: model.remindersForSelectedDate.length,
                      itemBuilder:(context, index) {
                        final reminder = model.remindersForSelectedDate[index];
                        return Card(
                          color: reminder.color?.withValues(alpha: .35),
                          child: ListTile(
                            leading: Icon(Icons.date_range_rounded),
                            title: Text(reminder.title ?? ''),
                            subtitle: Text('${reminder.isCompleted}'),
                            onTap: () => debugPrint('Reviewing Reminder'),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}