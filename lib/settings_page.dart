import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 引入 main.dart 中的狀態管理
import 'main.dart';

// 設定頁面，包含個人資訊輸入表單
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String? _gender;
  DateTime? _birthDate;
  final TextEditingController _cityController = TextEditingController();
  String? _exclusiveNineStar;

  // 模擬九星列表
  final List<String> nineStars = [
    '一白水星', '二黑土星', '三碧木星', '四綠木星',
    '五黃土星', '六白金星', '七赤金星', '八白土星',
    '九紫火星'
  ];

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthNotifier>(context, listen: false).user;
    if (user != null) {
      _emailController.text = user['email'] ?? '';
      _nameController.text = user['username'] ?? '';
      // 這裡可以載入其他儲存的資訊，例如性別、出生日期等。
      // 目前我們只使用佔位符。
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  // 處理日期選擇
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  // 處理表單提交
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // 在這裡處理表單資料，例如更新使用者資訊到後端或狀態管理
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('個人資訊已更新！')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            Text(
              '我的設定',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: '電子郵件',
                border: OutlineInputBorder(),
              ),
              enabled: false, // 電子郵件通常不允許修改
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '姓名',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '請輸入您的姓名';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '性別',
                border: OutlineInputBorder(),
              ),
              value: _gender,
              items: ['男', '女', '不透露']
                  .map((String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ))
                  .toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _gender = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: '出生日期',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _birthDate != null
                      ? '${_birthDate!.year}/${_birthDate!.month}/${_birthDate!.day}'
                      : '請選擇出生日期',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: '城市',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '專屬九星',
                border: OutlineInputBorder(),
              ),
              value: _exclusiveNineStar,
              items: nineStars
                  .map((String value) => DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      ))
                  .toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _exclusiveNineStar = newValue;
                });
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                '儲存',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
