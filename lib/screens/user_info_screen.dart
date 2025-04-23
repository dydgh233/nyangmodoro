import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'focus_home_screen.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  DateTime? _birthDate;
  String? _gender;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkUserProfile();
  }

  Future<void> _checkUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final res = await Supabase.instance.client
        .from('user_profiles')
        .select('id')
        .eq('id', user.id)
        .maybeSingle();

    if (res != null && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const FocusHomeScreen()),
      );
    }
  }

  Future<void> _submit() async {
    print("🚀 Submit 버튼 클릭됨");
    final formattedDate = DateFormat('yyyy-MM-dd').format(_birthDate!);
    print("_birthDate: $formattedDate");
    print("_gender: $_gender");
    print("이름: ${_nameController.text}, 주소: ${_addressController.text}, 전화: ${_phoneController.text}");
    if (!_formKey.currentState!.validate() || _birthDate == null || _gender == null) return;

    final user = Supabase.instance.client.auth.currentUser;
    print("user: $user");
    if (user == null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(_birthDate!);
      await Supabase.instance.client.from('user_profiles').upsert({
        'id': user.id,
        'name': _nameController.text,
        'address': _addressController.text,
        'phone': _phoneController.text,
        'birth_date': formattedDate,
        'gender': _gender,
        'email': user.email,
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("🎉 사용자 정보가 등록되었습니다!")),
      );

      await Future.delayed(const Duration(milliseconds: 600)); // 약간의 여유
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const FocusHomeScreen()),
      );
    } catch (e) {
      setState(() {
        _error = "❗ 저장 중 오류가 발생했습니다: $e";
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("사용자 정보 입력")),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // 터치 시 키보드 닫기
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: const Text(
                      "📢 이 정보를 입력하는 이유는?\n\n"
                      "- 포인트로 교환한 상품을 택배로 보내드릴 때 사용 한다냥!\n"
                      "- 문자로 배송 알림을 받을 수 있어옹.\n"
                      "- 입력한 정보는 외부에 공개되지 않으며 안전하게 보호된다냥",
                      style: TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: '이름'),
                    validator: (value) => value!.isEmpty ? '이름을 입력해주세요' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(labelText: '주소'),
                    validator: (value) => value!.isEmpty ? '주소를 입력해주세요' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: '전화번호'),
                    keyboardType: TextInputType.phone,
                    validator: (value) => value!.isEmpty ? '전화번호를 입력해주세요' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text("생년월일: "),
                      Text(
                        _birthDate == null
                            ? '선택 안됨'
                            : DateFormat('yyyy년 MM월 dd일').format(_birthDate!),
                      ),
                      TextButton(
                        onPressed: _pickBirthDate,
                        child: const Text("선택하기"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _gender,
                    items: const [
                      DropdownMenuItem(value: 'male', child: Text("남성")),
                      DropdownMenuItem(value: 'female', child: Text("여성"))
                    ],
                    onChanged: (value) => setState(() => _gender = value),
                    decoration: const InputDecoration(labelText: '성별'),
                    validator: (value) => value == null ? '성별을 선택해주세요' : null,
                  ),
                  const SizedBox(height: 24),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(_error!,
                          style: const TextStyle(color: Colors.red)),
                    ),
                  ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("정보 제출 후 시작하기"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
