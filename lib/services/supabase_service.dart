import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<DateTime>> fetchFocusDates(String userId) async {
    final res = await _client
        .from('focus_sessions')
        .select('date')
        .eq('user_id', userId);

    return res.map<DateTime>((row) {
      try {
        return DateTime.parse(row['date']);
      } catch (e) {
        return DateTime.now(); // fallback
      }
    }).toList();
  }

  Future<Map<String, dynamic>?> fetchFocusData(String userId, DateTime date) async {
    final dayStr = date.toIso8601String().split('T').first;

    final res = await _client
        .from('focus_sessions')
        .select('success_count, total_minutes')
        .eq('user_id', userId)
        .eq('date', dayStr)
        .maybeSingle();

    return res is Map<String, dynamic> ? res : null;
  }

  Future<int> fetchPointTotal(String userId) async {
    final res = await _client
        .from('points')
        .select('points, user_id');

    return res
        .where((row) => row['user_id'] == userId)
        .fold<int>(0, (sum, item) => sum + ((item['points'] ?? 0) as int));
  }

  Future<int> fetchPointForDay(String userId, DateTime date) async {
    final dayStr = date.toIso8601String().split('T').first;

    final res = await _client
        .from('points')
        .select('points, created_at')
        .eq('user_id', userId);

    // 🔧 먼저 int 리스트로 변환
    final todayPoints = res
        .where((row) => row['created_at'].toString().startsWith(dayStr))
        .map<int>((item) => (item['points'] ?? 0) as int)
        .toList();

    // ✅ 안전하게 fold
    return todayPoints.fold(0, (sum, p) => sum + p);
  }

  Future<List<Map<String, dynamic>>> fetchRewards() async {
    final res = await _client
        .from('rewards')
        .select('name, cost, image_url');

    return List<Map<String, dynamic>>.from(res);
  }

  Future<int> fetchTodayTotalMinutes(String userId) async {
    final today = DateTime.now().toIso8601String().split('T').first;

    final res = await Supabase.instance.client
        .from('focus_sessions')
        .select('total_minutes')
        .eq('user_id', userId)
        .eq('date', today);

    return res
        .map((row) => (row['total_minutes'] ?? 0) as int)
        .fold(0, (sum, item) => sum + item); // ✅ 타입 일치
  }
}
