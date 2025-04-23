import 'dart:async';

class FocusTimer {
  int totalSeconds;
  late Timer _timer;
  Function onTick;
  Function onFinish;

  FocusTimer({
    required this.totalSeconds,
    required this.onTick,
    required this.onFinish,
  });

  void start() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      totalSeconds--;
      onTick(totalSeconds);

      if (totalSeconds <= 0) {
        _timer.cancel();
        onFinish();
      }
    });
  }

  void stop() {
    _timer.cancel();
  }
}