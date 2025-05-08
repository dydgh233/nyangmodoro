// widgets/calendar_with_stamp.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';

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
    final formatter = DateFormat('yyyy-MM-dd');
    final normalizedStampDates = stampDates
      .map((d) => formatter.format(d))
      .toSet();

    return TableCalendar(
      // 달력 범위 설정
      firstDay: DateTime.utc(2023, 1, 1),
      lastDay:  DateTime.utc(2030, 12, 31),
      focusedDay: focusedDay,

      // 선택된 날짜 강조
      selectedDayPredicate: (day) => isSameDay(selectedDay, day),
      onDaySelected: onDaySelected,

      // 헤더의 '2weeks' 토글 버튼 숨기기
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
      ),

      // ② eventLoader: stampDates에 포함된 날짜만 이벤트로 반환
      eventLoader: (day) {
        final key = formatter.format(day);
        return normalizedStampDates.contains(key) ? [key] : [];
      },

      calendarBuilders: CalendarBuilders(
        markerBuilder: (context, day, events) {
          if (events.isEmpty) return const SizedBox.shrink();
          return Align(
            alignment: Alignment.bottomCenter,
            child: Icon(
              Icons.pets,            // 고양이 발바닥 아이콘
              size: 16,              // 크기는 취향껏 조절
              color: Colors.grey[700], // 색상도 마음대로 바꿔봐
            ),
          );
        },
      ),

      // 오늘/선택된 날 스타일
      calendarStyle: CalendarStyle(
        todayDecoration: BoxDecoration(
          color: Colors.orange.shade300,
          shape: BoxShape.circle,
        ),
        selectedDecoration: const BoxDecoration(
          color: Colors.deepOrange,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
