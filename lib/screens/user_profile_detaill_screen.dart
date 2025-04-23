// lib/screens/user_profile_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfileDetailScreen extends StatefulWidget {
  const UserProfileDetailScreen({super.key});

  @override
  State<UserProfileDetailScreen> createState() => _UserProfileDetailScreenState();
}

class _UserProfileDetailScreenState extends State<UserProfileDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _gender;
  DateTime? _birthDate;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final res = await Supabase.instance.client
        .from('user_profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (res != null) {
      setState(() {
        _nameController.text = res['name'] ?? '';
        _addressController.text = res['address'] ?? '';
        _phoneController.text = res['phone'] ?? '';
        _gender = res['gender'];
        _birthDate = DateTime.tryParse(res['birth_date'] ?? '');
        _loading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      await Supabase.instance.client.from('user_profiles').update({
        'name': _nameController.text,
        'address': _addressController.text,
        'phone': _phoneController.text,
        'gender': _gender,
        'birth_date': _birthDate?.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', user.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ 사용자 정보가 수정되었습니다.")),
      );

      await Future.delayed(const Duration(milliseconds: 500)); // 잠깐 여유 주고

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } catch (e) {
      setState(() {
        _error = "❗ 저장 중 오류 발생: $e";
      });
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 18),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text("내 정보")),
      body: Padding(
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
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: '전화번호'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text("생년월일: "),
                    Text(
                      _birthDate == null
                          ? '선택 안됨'
                          : _birthDate!.toLocal().toIso8601String().split("T").first,
                    ),
                    TextButton(
                      onPressed: _pickBirthDate,
                      child: const Text("변경"),
                    ),
                  ],
                ),
                DropdownButtonFormField<String>(
                  value: _gender,
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text("남성")),
                    DropdownMenuItem(value: 'female', child: Text("여성")),
                  ],
                  onChanged: (value) => setState(() => _gender = value),
                  decoration: const InputDecoration(labelText: '성별'),
                ),
                const SizedBox(height: 24),
                if (_error != null)
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ElevatedButton(
                  onPressed: _updateProfile,
                  child: const Text("정보 수정하기"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
