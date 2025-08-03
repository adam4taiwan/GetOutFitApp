import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // 用於 Future.delayed
import 'dart:developer' as developer; // 用於日誌記錄

// 引入登入頁面檔案
import 'login_screen.dart';
// 引入新的頁面檔案
import 'ai_camera_screen.dart';
import 'ai_recommendation_screen.dart';
import 'settings_screen.dart';
import 'widgets/outfit_card.dart';

// --- 1. 狀態管理 (使用 ChangeNotifier 和 Provider) ---

// Auth 狀態
class AuthNotifier extends ChangeNotifier {
  Map<String, String>? _user;

  Map<String, String>? get user => _user;

  void setUser(Map<String, String>? newUser) {
    _user = newUser;
    developer.log('使用者已設定為: $newUser', name: 'AuthNotifier');
    notifyListeners();
  }

  // 模擬登入
  Future<void> login(String email, String password) async {
    developer.log(
      '嘗試登入 email: $email, password: $password',
      name: 'AuthNotifier',
    );
    await Future.delayed(const Duration(seconds: 2));

    if (email == 'test@example.com' && password == 'password') {
      setUser({'email': email, 'username': '測試使用者'});
    } else {
      throw Exception('無效的電子郵件或密碼');
    }
  }

  // 模擬註冊 (新增此方法)
  Future<void> register(String email, String password) async {
    developer.log(
      '嘗試註冊 email: $email, password: $password',
      name: 'AuthNotifier',
    );
    await Future.delayed(const Duration(seconds: 2));
    // 在真實應用中，這裡會呼叫後端 API 進行註冊
    // 這裡我們假設註冊成功，並直接登入使用者
    setUser({'email': email, 'username': '新註冊使用者'});
  }

  // 模擬登出
  void logout() {
    setUser(null);
  }
}

// 穿搭狀態
class OutfitNotifier extends ChangeNotifier {
  Map<String, dynamic>? _currentOutfit;
  final List<Map<String, dynamic>> _history = [];

  Map<String, dynamic>? get currentOutfit => _currentOutfit;
  List<Map<String, dynamic>> get history => _history;

  void setOutfit(Map<String, dynamic> outfit) {
    _currentOutfit = outfit;
    // 檢查歷史紀錄中是否已存在相同的穿搭
    final existingIndex = _history.indexWhere((o) => o['id'] == outfit['id']);
    if (existingIndex == -1) {
      _history.add(outfit);
      developer.log('新增穿搭至歷史紀錄', name: 'OutfitNotifier');
    } else {
      developer.log('穿搭已存在於歷史紀錄中', name: 'OutfitNotifier');
    }

    notifyListeners();
  }

  void clearHistory() {
    _history.clear();
    notifyListeners();
  }
}

// 主應用程式
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthNotifier()),
        ChangeNotifierProvider(create: (_) => OutfitNotifier()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Consumer<AuthNotifier>(
          builder: (context, auth, child) {
            if (auth.user == null) {
              return const LoginScreen();
            } else {
              return const MainAppScreen();
            }
          },
        ),
      ),
    );
  }
}

// 主頁面
class MainAppScreen extends StatefulWidget {
  const MainAppScreen({super.key});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    // 1. 首頁 (目前為占位符)
    const Center(
      child: Text('首頁', style: TextStyle(fontSize: 24)),
    ),
    // 2. AI 拍照
    const AICameraScreen(),
    // 3. AI 建議
    const AIRecScreen(),
    // 4. 歷史紀錄
    const HistoryScreen(),
    // 5. 設定
    const SettingsScreen(),
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
        title: const Text('我的穿搭應用'),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首頁',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'AI 拍照',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb),
            label: 'AI 建議',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: '歷史紀錄',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '設定',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // 確保所有項目都可見
      ),
    );
  }
}

// 穿搭歷史紀錄頁面
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = Provider.of<OutfitNotifier>(context).history;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '歷史穿搭紀錄',
            style: Theme.of(context).textTheme.headlineMedium,
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

// 應用程式的主要進入點
void main() {
  runApp(const MainApp());
}
