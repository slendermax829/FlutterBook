import 'package:flutter/material.dart';
import 'package:flutter_book/calendar/calendar_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

/// Adds reminder completion handling to the calendar model.
extension Completion on CalendarModel{
  /// Toggles a reminder's completion state, persists it, and reloads reminders.
  void toggleCompleted(CalendarReminder remider) async{
    remider.isCompleted = !remider.isCompleted;
    await worker.update(remider);
    await loadData(); //resets ui view and loads new data
  }
}

/// Displays the calendar and reminders for its selected day.
class CalendarViewer extends StatefulWidget {
  const new({super.key});

  @override
  State<CalendarViewer> createState() => _CalendarViewerState();
}

class _CalendarViewerState extends State<CalendarViewer> {
  /// The controller for the calendar
  final _calendarController = CalendarController();

  String dateFormat(DateTime date) => DateFormat.yMMMd().format(date);

  @override
  void initState() {
    super.initState();
    final selected = context.read<CalendarModel>().selectedDate; // defaults for today upon initialization

    _calendarController.displayDate = selected;
    _calendarController.selectedDate = selected;
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  void _onDateSelected(CalendarTapDetails details) {
    final date = details.date;
    if (date == null || details.targetElement != CalendarElement.calendarCell) return;
    context.read<CalendarModel>().selectDate(date); 
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
  
  /// Builds bottom panel for reminders based on the day selected from the calendar
  /// 
  /// Panels are displayed for each day the reminder is set for
  Widget _remindersPanel() {
    final model = context.watch<CalendarModel>();
    final reminders = model.remindersForSelectedDate; // gets reminders for selected date

    return Material(
      color: Colors.grey.withValues(alpha: .2),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Column(
        children: [
          ListTile(
            title: Text(
              dateFormat(model.selectedDate),
              style: const TextStyle(fontSize: 20),
            ),
            subtitle: const Text('Reminders'),
            trailing: IconButton(
              icon: const Icon(Icons.add),
              tooltip: 'Add new reminder',
              onPressed: () => model.setEntry(CalendarReminder(reminderDate: model.selectedDate)),
            ),
          ),
          const Divider(height: 1, color: Colors.white),
          Expanded(
            child: reminders.isEmpty
                    ? Center(child: const Text('No Reminders added for this day'))
                    : ListView.builder(
                      itemCount: reminders.length,
                      itemBuilder:(context, index) =>
                        _buildSlideableCard(reminders[index]),
                    ),
          ),
        ],
      ),
    );
  }
  /// Builds slidable panel for each reminder
  Widget _buildSlideableCard(CalendarReminder reminder){
    final model = context.read<CalendarModel>();
    return Slidable(
      key: ValueKey(reminder.id),
      startActionPane: ActionPane(
        motion: const ScrollMotion(),
        dismissible: DismissiblePane(
          onDismissed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Deleted reminder: ${reminder.title}'))
            );
            model.deleteEntry(reminder);
          },
        ),
        children: [
          SlidableAction(
            onPressed: (context) {
              
            },
            backgroundColor: const Color(0xFFFE4A49),
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ]
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => model.toggleCompleted(reminder),
            backgroundColor: const Color(0xFF7BC043),
            foregroundColor: Colors.white,
            icon: reminder.isCompleted ? Icons.undo : Icons.check,
            label: reminder.isCompleted ? 'Undo' : 'Complete',
          ),
        ]
      ),
      child: Card(
        color: reminder.color?.withValues(alpha: .35),
        child: ListTile(
          leading: Icon(
            reminder.isCompleted ? Icons.check_circle : Icons.date_range_rounded,
          ),
          title: Text(
            reminder.title ?? '',
            style: TextStyle(
              decoration: reminder.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Text(reminder.isCompleted ? 'Completed' : 'Not Completed'),
          onTap: () => model.setEntry(reminder),
        ),
      ),
    );
  }
}