// screens/signup_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_info_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

Future<void> _signUp() async {
  setState(() {
    _loading = true;
    _error = null;
  });

  try {
    final supabase = Supabase.instance.client;

    // 1. 회원가입
    final signUpRes = await supabase.auth.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    // 2. 로그인
    final loginRes = await supabase.auth.signInWithPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    final user = loginRes.user;
    if (user == null) {
      setState(() {
        _error = "로그인 실패: 사용자 정보가 없습니다.";
      });
      return;
    }

    // 3. 사용자 정보 입력 페이지로 이동
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const UserInfoScreen()),
    );
  } on AuthException catch (e) {
    setState(() {
      _error = e.message;
    });
  } catch (e) {
    setState(() {
      _error = "예상치 못한 오류가 발생했습니다: $e";
    });
  } finally {
    setState(() {
      _loading = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("회원가입")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: '이메일'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: '비밀번호'),
            ),
            const SizedBox(height: 24),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ElevatedButton(
              onPressed: _loading ? null : _signUp,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("회원가입 완료"),
            ),
          ],
        ),
      ),
    );
  }
}