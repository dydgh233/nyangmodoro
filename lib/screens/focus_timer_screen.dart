import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/scheduler.dart';
import 'focus_home_screen.dart';
import 'package:lottie/lottie.dart';

class FocusTimerScreen extends StatefulWidget {
  const FocusTimerScreen({super.key});

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen>
    with SingleTickerProviderStateMixin {
  Duration _duration = const Duration(minutes: 1);
  late final Duration _initialDuration;
  late final Stopwatch _stopwatch;
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _initialDuration = _duration;
    _stopwatch = Stopwatch()..start();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final remaining = _initialDuration - elapsed;
    if (remaining <= Duration.zero) {
      _ticker.stop();
      _stopwatch.stop();
      _handleFocusSuccess(); // 집중 성공 처리
    } else {
      setState(() {
        _duration = remaining;
      });
    }
  }

  Future<void> _handleFocusSuccess() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final today = DateTime.now().toIso8601String().split('T').first;

    try {
      // 1. focus_sessions 기록
      await supabase.from('focus_sessions').upsert({
        'user_id': user.id,
        'date': today,
        'success_count': 1,
        'total_minutes': 25,
      });

      // 2. 포인트 적립
      await supabase.from('points').insert({
        'user_id': user.id,
        'points': 10,
        'source': '25분 집중 성공',
      });

      // 3. 발도장 저장
      await supabase.from('stamps').insert({
        'user_id': user.id,
        'date': today,
        'type': 'focus',
      });

      if (!mounted) return;

      // 4. 홈으로 이동
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const FocusHomeScreen()),
        (route) => false,
      );
    } catch (e) {
      debugPrint("🛑 집중 성공 저장 실패: $e");
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _stopwatch.stop();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  void _confirmExit(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("정말 포기할까요?"),
        content: const Text("지금 나가면 발도장과 포인트를 얻을 수 없어요!"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("계속 집중"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("포기하기"),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true) {
        Navigator.pop(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFE7C4),
      appBar: AppBar(
        title: const Text("집중 타이머"),
        backgroundColor: Colors.orange.shade400,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/cat_new.json',
              fit: BoxFit.cover, // 화면에 맞게 꽉 채움
            ),
            // 타이머
            Text(
              _formatDuration(_duration),
              style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 24),

            // 포기 버튼
            ElevatedButton(
              onPressed: () => _confirmExit(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text("포기하기", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
