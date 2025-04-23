import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _totalFocusMinutes = 0;
  int _totalPoints = 0;
  int _totalStamps = 0;
  Map<String, int> _weeklyFocus = {};

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final today = DateTime.now();
    final weekStart = today.subtract(const Duration(days: 6));
    final dateList = List.generate(7, (i) => weekStart.add(Duration(days: i)));

    // 1. 집중 시간 조회
    final focusRes = await supabase
        .from('focus_sessions')
        .select('total_minutes, date')
        .eq('user_id', user.id);

    int focusTotal = 0;
    Map<String, int> weeklyMap = {};

    for (final row in focusRes) {
      final totalMin = row['total_minutes'] as int;
      focusTotal += totalMin;

      final dateStr = row['date'].toString().substring(0, 10);
      if (dateList.any((d) => d.toIso8601String().startsWith(dateStr))) {
        weeklyMap[dateStr] = (weeklyMap[dateStr] ?? 0) + totalMin;
      }
    }

    // 2. 누적 포인트
    final pointRes = await supabase
        .from('points')
        .select('points')
        .eq('user_id', user.id);

    int pointTotal = 0;
    for (final row in pointRes) {
      pointTotal += row['points'] as int;
    }

    // 3. 발도장 수
    final stampRes = await supabase
        .from('stamps')
        .select('date')
        .eq('user_id', user.id);

    setState(() {
      _totalFocusMinutes = focusTotal;
      _totalPoints = pointTotal;
      _totalStamps = stampRes.length;
      _weeklyFocus = weeklyMap;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("📊 통계")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStat("총 집중 시간", "$_totalFocusMinutes분 ⏱️"),
              _buildStat("누적 포인트", "$_totalPoints P 💰"),
              _buildStat("발도장 수", "$_totalStamps개 🐾"),
              const SizedBox(height: 24),
              const Text("📅 최근 7일 집중 기록", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildWeeklyBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text("• $label: ", style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildWeeklyBar() {
    final weekStart = DateTime.now().subtract(const Duration(days: 6));

    return Column(
      children: List.generate(7, (i) {
        final day = weekStart.add(Duration(days: i));
        final label = ["일", "월", "화", "수", "목", "금", "토"][day.weekday % 7];
        final dateKey = day.toIso8601String().substring(0, 10);
        final value = _weeklyFocus[dateKey] ?? 0;
        final barWidth = (value / 60.0) * 200;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              SizedBox(width: 24, child: Text(label)),
              Container(
                width: barWidth.clamp(1.0, 200.0),
                height: 16,
                color: Colors.orange.shade400,
              ),
              const SizedBox(width: 8),
              Text("$value분"),
            ],
          ),
        );
      }),
    );
  }
}
