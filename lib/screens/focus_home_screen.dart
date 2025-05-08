// screens/focus_home_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../widgets/calendar_with_stamp.dart';
import '../widgets/reward_popup.dart';

class FocusHomeScreen extends StatefulWidget {
  const FocusHomeScreen({super.key});

  @override
  State<FocusHomeScreen> createState() => _FocusHomeScreenState();
}

class _FocusHomeScreenState extends State<FocusHomeScreen> {
  final SupabaseService _service = SupabaseService();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Set<DateTime> _stampDates = {};
  Map<String, dynamic>? _selectedFocusData;
  int _selectedPointTotal = 0;
  int _totalPoints = 0;
  int _todayFocusMinutes = 0;
  List<Map<String, dynamic>> _rewardItems = [];
  
  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final stampDates = await _service.fetchFocusDates(user.id);
    final totalPoints = await _service.fetchPointTotal(user.id);
    final rewards = await _service.fetchRewards();
    final todayMinutes = await _service.fetchTodayTotalMinutes(user.id);

    setState(() {
      _stampDates = stampDates.toSet();
      _totalPoints = totalPoints;
      _rewardItems = rewards;
      _todayFocusMinutes = todayMinutes;
    });
  }

  Future<void> _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final focusData = await _service.fetchFocusData(user.id, selectedDay);
    final pointTotal = await _service.fetchPointForDay(user.id, selectedDay);

    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
      _selectedFocusData = focusData;
      _selectedPointTotal = pointTotal;
    });
  }

  void _showRewardPopup() {
    showDialog(
      context: context,
      builder: (context) => RewardPopup(currentPoints: _totalPoints)
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffef9f3),
      appBar: AppBar(
        title: const Text("냥모도로"),
        backgroundColor: Colors.orange.shade400,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: "내 정보",
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSummaryBar(),
          CalendarWithStamp(
            focusedDay: _focusedDay,
            selectedDay: _selectedDay,
            stampDates: _stampDates,
            onDaySelected: _onDaySelected,
          ),
          _buildDayDetail(),
          _buildStartFocusButton(),
          _buildRewardBanner(),
        ],
      ),
    );
  }

  Widget _buildSummaryBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      color: Colors.orange.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("🐾 오늘의 집중 시간", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text("총 $_todayFocusMinutes분 집중 완료! 🎉", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text("💰 누적 포인트: $_totalPoints P", style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildDayDetail() {
    if (_selectedDay == null) return const SizedBox(height: 16);
    final dateStr = _selectedDay!.toLocal().toIso8601String().split('T').first;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("📆 $dateStr", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          if (_selectedFocusData != null)
            Text(
              "✅ 집중 ${_selectedFocusData!['sum_success_count']}회 (${_selectedFocusData!['sum_total_minutes']}분)",
              style: const TextStyle(fontSize: 16),
            )
          else
            const Text("😴 집중 기록 없음", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text("💰 포인트 적립: $_selectedPointTotal P", style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildStartFocusButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        icon: const Icon(Icons.timer),
        label: const Text("집중 시작하기"),
        onPressed: () {
          Navigator.pushNamed(context, '/focus-timer');
        },
      ),
    );
  }

  Widget _buildRewardBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("🎁 내 포인트: $_totalPoints P", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ElevatedButton(
            onPressed: _showRewardPopup,
            child: const Text("보상 보기"),
          ),
        ],
      ),
    );
  }
}
