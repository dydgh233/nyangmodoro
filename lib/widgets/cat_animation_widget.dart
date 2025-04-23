import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CatAnimationWidget extends StatelessWidget {
  final String animationPath;

  const CatAnimationWidget({
    super.key,
    this.animationPath = 'assets/animations/nyang2.json', // 기본값
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Lottie.asset(
        animationPath,
        width: 200,
        height: 200,
        repeat: true,
      ),
    );
  }
}
