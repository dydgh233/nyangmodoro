// widgets/calendar_with_stamp.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarWithStamp extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final Set<DateTime> stampDates;
  final Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;

  const CalendarWithStamp({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.stampDates,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime.utc(2023, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: focusedDay,
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      onDaySelected: onDaySelected,
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, _) {
          bool hasStamp = stampDates.any((d) => isSameDay(d, day));
          if (hasStamp) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Text('${day.day}', style: const TextStyle(color: Colors.black)),
                const Positioned(
                  bottom: 4,
                  child: Text("🐾", style: TextStyle(fontSize: 14)),
                ),
              ],
            );
          }
          return null;
        },
      ),
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.orange.shade300,
          shape: BoxShape.circle,
        ),
        selectedDecoration: BoxDecoration(
          color: Colors.deepOrange,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
