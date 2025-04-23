import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RewardPopup extends StatelessWidget {
  final int currentPoints;

  const RewardPopup({super.key, required this.currentPoints});

  final List<Map<String, dynamic>> rewards = const [
    {'name': '고양이 샤프', 'cost': 5000},
    {'name': '고양이 볼펜', 'cost': 5000},
    {'name': '고양이 필통', 'cost': 10000},
    {'name': '고양이 키링', 'cost': 10000},
  ];

  Future<void> _claimReward(BuildContext context, String name, int cost) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    if (cost > currentPoints) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("포인트가 부족해요 😢")),
      );
      return;
    }

    try {
      // 1. 유저 포인트 차감
      final res = await supabase
          .from('user_profiles')
          .select('total_points')
          .eq('id', user.id)
          .maybeSingle();

      final nowPoint = res['total_points'] ?? 0;
      final newPoint = nowPoint - cost;

      await supabase.from('user_profiles').update({
        'total_points': newPoint,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);

      // 2. 교환 내역 저장
      await supabase.from('rewards_claimed').insert({
        'user_id': user.id,
        'reward_name': name,
        'points_used': cost,
      });

      // 3. 피드백
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("🎁 '$name' 교환 완료!")),
      );
    } catch (e) {
      debugPrint("보상 교환 실패: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("교환 중 오류가 발생했어요.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("🎁 보상 교환소"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: rewards.map((reward) {
          final name = reward['name'];
          final cost = reward['cost'];
          final affordable = currentPoints >= cost;

          return ListTile(
            title: Text(name),
            subtitle: Text("필요 포인트: $cost P"),
            trailing: ElevatedButton(
              onPressed: affordable
                  ? () => _claimReward(context, name, cost)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: affordable ? Colors.orange : Colors.grey,
              ),
              child: const Text("교환"),
            ),
          );
        }).toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("닫기"),
        ),
      ],
    );
  }
}
