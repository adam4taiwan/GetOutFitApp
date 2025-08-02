import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math'; // For random color generation
import 'dart:async'; // For Future.delayed
import 'dart:io'; // For File class
import 'package:image_picker/image_picker.dart'; // Import image_picker package
import 'dart:developer' as developer; // Import developer for logging

// --- 1. 狀態管理 (使用 ChangeNotifier 和 Provider) ---

// Auth State
class AuthNotifier extends ChangeNotifier {
  Map<String, String>? _user;

  Map<String, String>? get user => _user;

  void setUser(Map<String, String>? newUser) {
    _user = newUser;
    developer.log('User set to: $newUser', name: 'AuthNotifier');
    notifyListeners(); // Notify all listeners that state has changed
  }
}

// Outfit State
class OutfitNotifier extends ChangeNotifier {
  Map<String, dynamic>? _currentOutfit;
  final List<Map<String, dynamic>> _history = [];

  Map<String, dynamic>? get currentOutfit => _currentOutfit;
  List<Map<String, dynamic>> get history => _history;

  void setOutfit(Map<String, dynamic>? newOutfit) {
    _currentOutfit = newOutfit;
    developer.log('New outfit selected: $newOutfit', name: 'OutfitNotifier');
    notifyListeners();
  }

  void addHistory(Map<String, dynamic> outfit) {
    _history.add(outfit);
    developer.log('Outfit added to history: $outfit', name: 'OutfitNotifier');
    notifyListeners();
  }
}

// --- 2. 主應用程式結構 ---

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthNotifier()),
        ChangeNotifierProvider(create: (_) => OutfitNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.watch<AuthNotifier>();
    final isAuthenticated = authNotifier.user != null;

    return MaterialApp(
      title: '穿搭日誌',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: isAuthenticated ? const MainScreen() : const LoginScreen(),
    );
  }
}

// --- 3. 登入頁面 (來自 Login.vsdx) ---

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authNotifier = context.read<AuthNotifier>();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('登入'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '歡迎回來',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: '電子郵件',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                labelText: '密碼',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // 模擬登入成功
                  authNotifier.setUser({'name': 'UserA', 'email': emailController.text});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('登入', style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // 導航到忘記密碼頁面
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ForgotPasswordScreen(),
                  ),
                );
              },
              child: const Text('忘記密碼？'),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 4. 忘記密碼頁面 (新增) ---

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('忘記密碼'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '請輸入您的電子郵件地址，我們會發送密碼重設連結給您。',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: '電子郵件',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // 模擬發送密碼重設郵件
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('密碼重設連結已發送到 ${emailController.text}'),
                    ),
                  );
                  // 返回登入頁面
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('發送重設連結', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 5. 主畫面 (來自 formMain.vsdx) ---

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    OutfitGeneratorScreen(),
    HistoryScreen(),
    LuckyColorScreen(),
    WeatherScreen(),
    AICameraScreen(),
    AIWardrobeScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('穿搭日誌'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // 登出
              context.read<AuthNotifier>().setUser(null);
            },
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.palette),
            label: '穿搭日誌',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: '歷史紀錄',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: '幸運色',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.cloud),
            label: '天氣',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'AI 拍照',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.checkroom),
            label: 'AI 衣櫃',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // 確保所有圖示都顯示
      ),
    );
  }
}

// --- 6. 穿搭生成器畫面 ---

class OutfitGeneratorScreen extends StatefulWidget {
  const OutfitGeneratorScreen({super.key});

  @override
  State<OutfitGeneratorScreen> createState() => _OutfitGeneratorScreenState();
}

class _OutfitGeneratorScreenState extends State<OutfitGeneratorScreen> {
  File? _imageFile;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        context.read<OutfitNotifier>().setOutfit(null);
      });
    }
  }

  Future<Map<String, dynamic>> _generateRandomOutfit() async {
    await Future.delayed(const Duration(seconds: 1));
    final outfits = [
      {
        'name': '休閒牛仔風',
        'description': '白色 T 恤搭配牛仔外套和緊身褲。',
        'imageUrl': 'https://placehold.co/600x400/1e88e5/ffffff?text=休閒牛仔風',
        'date': '2025-08-01',
      },
      {
        'name': '優雅都會風',
        'description': '黑色洋裝搭配高跟鞋和手提包。',
        'imageUrl': 'https://placehold.co/600x400/43a047/ffffff?text=優雅都會風',
        'date': '2025-08-01',
      },
      {
        'name': '夏日海灘風',
        'description': '花朵圖案長裙搭配涼鞋和草帽。',
        'imageUrl': 'https://placehold.co/600x400/fdd835/000000?text=夏日海灘風',
        'date': '2025-08-01',
      },
    ];
    final random = Random();
    return outfits[random.nextInt(outfits.length)];
  }

  @override
  Widget build(BuildContext context) {
    final outfitNotifier = context.read<OutfitNotifier>();
    final currentOutfit = context.watch<OutfitNotifier>().currentOutfit;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_imageFile != null)
              SizedBox(
                height: 300,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(_imageFile!, fit: BoxFit.cover),
                ),
              )
            else if (currentOutfit != null)
              SizedBox(
                height: 300,
                child: OutfitCard(outfit: currentOutfit),
              )
            else
              const SizedBox(
                height: 300,
                child: Center(
                  child: Text('點擊按鈕來生成今天的穿搭或上傳照片！'),
                ),
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('拍照'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('上傳照片'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  _imageFile = null;
                });
                final newOutfit = await _generateRandomOutfit();
                outfitNotifier.setOutfit(newOutfit);
              },
              child: const Text('生成穿搭'),
            ),
            if (currentOutfit != null || _imageFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_imageFile != null) {
                      final newOutfit = {
                        'name': '自選穿搭',
                        'description': '從相簿或相機上傳的圖片。',
                        'imagePath': _imageFile!.path,
                        'date': '2025-08-01',
                      };
                      outfitNotifier.addHistory(newOutfit);
                    } else if (currentOutfit != null) {
                      outfitNotifier.addHistory(currentOutfit);
                    }
                    setState(() {
                      _imageFile = null;
                    });
                    outfitNotifier.setOutfit(null);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('穿搭已儲存到歷史紀錄！')),
                    );
                  },
                  child: const Text('存入衣櫃'),
                ),
              ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _imageFile = null;
                });
                outfitNotifier.setOutfit(null);
              },
              child: const Text('清除'),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 7. 穿搭卡片 Widget ---

class OutfitCard extends StatelessWidget {
  final Map<String, dynamic> outfit;

  const OutfitCard({super.key, required this.outfit});

  @override
  Widget build(BuildContext context) {
    final imageUrl = outfit['imageUrl'];
    final imagePath = outfit['imagePath'];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: (imageUrl != null)
                ? Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 160,
                        color: Colors.grey[300],
                        child: Center(
                          child: Text(
                            '圖片載入失敗',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      );
                    },
                  )
                : (imagePath != null)
                    ? Image.file(
                        File(imagePath),
                        width: double.infinity,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 160,
                            color: Colors.grey[300],
                            child: Center(
                              child: Text(
                                '本地圖片載入失敗',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        width: double.infinity,
                        height: 160,
                        color: Colors.grey[300],
                        child: Center(
                          child: Text(
                            '無圖片',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  outfit['name'] ?? '未知穿搭',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  outfit['description'] ?? '',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  '日期: ${outfit['date'] ?? '未知'}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- 8. 其他頁面 (預留給其他功能) ---

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<OutfitNotifier>().history;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '穿搭歷史紀錄',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: history.isEmpty
                ? const Center(child: Text('還沒有歷史穿搭紀錄'))
                : ListView.builder(
                    itemCount: history.length,
                    itemBuilder: (context, index) {
                      final outfit = history[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: OutfitCard(outfit: outfit),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class LuckyColorScreen extends StatelessWidget {
  const LuckyColorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('幸運色頁面', style: TextStyle(fontSize: 24)),
    );
  }
}

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('天氣頁面', style: TextStyle(fontSize: 24)),
    );
  }
}

class AICameraScreen extends StatelessWidget {
  const AICameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('AI 拍照頁面', style: TextStyle(fontSize: 24)),
    );
  }
}

class AIWardrobeScreen extends StatelessWidget {
  const AIWardrobeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('AI 衣櫃頁面', style: TextStyle(fontSize: 24)),
    );
  }
}
