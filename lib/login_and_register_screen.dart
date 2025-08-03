import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // For Future.delayed
import 'dart:developer' as developer; // For logging

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

  // 模擬註冊
  Future<void> register(String email, String password) async {
    developer.log(
      '嘗試註冊 email: $email, password: $password',
      name: 'AuthNotifier',
    );
    await Future.delayed(const Duration(seconds: 2));
    // 這裡可以加入實際的註冊邏輯
    setUser({'email': email, 'username': '新使用者'});
  }

  // 模擬登出
  Future<void> logout() async {
    await Future.delayed(const Duration(seconds: 1));
    setUser(null);
  }
}

// 穿搭狀態
class OutfitNotifier extends ChangeNotifier {
  Map<String, dynamic>? _currentOutfit;
  final List<Map<String, dynamic>> _history = []; // 修正：宣告為 final

  Map<String, dynamic>? get currentOutfit => _currentOutfit;
  List<Map<String, dynamic>> get history => _history;

  void setOutfit(Map<String, dynamic> newOutfit) {
    _currentOutfit = newOutfit;
    _history.insert(0, newOutfit); // 將新穿搭插入歷史紀錄最前面
    developer.log('當前穿搭已設定為: $newOutfit', name: 'OutfitNotifier');
    notifyListeners();
  }
}

// 幸運色狀態
class LuckyColorNotifier extends ChangeNotifier {
  Color _luckyColor = Colors.grey;

  Color get luckyColor => _luckyColor;

  void setLuckyColor(Color newColor) {
    _luckyColor = newColor;
    developer.log('幸運色已設定為: $newColor', name: 'LuckyColorNotifier');
    notifyListeners();
  }
}

// --- 2. 主應用程式進入點 ---

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthNotifier()),
        ChangeNotifierProvider(create: (_) => OutfitNotifier()),
        ChangeNotifierProvider(create: (_) => LuckyColorNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthNotifier>(
      builder: (context, authNotifier, child) {
        return MaterialApp(
          title: '穿搭指南',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: authNotifier.user == null
              ? const LoginScreen()
              : const MainScreen(),
        );
      },
    );
  }
}

// --- 3. 登入後的主畫面 ---

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // 頁面清單
  static final List<Widget> _widgetOptions = <Widget>[ // 修正：移除 const
    const HomeScreen(), // 首頁
    const AiRecommendationScreen(), // AI 穿搭建議
    const AICameraScreen(), // AI 相機
    const HistoryScreen(), // 歷史紀錄
    const SettingsPage(), // 設定頁面
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
        title: const Text('穿搭指南'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthNotifier>(context, listen: false).logout();
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
            icon: Icon(Icons.home),
            label: '首頁',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'AI 建議',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'AI 相機',
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

// --- 4. 各個頁面的 Widget ---

// 新增：首頁
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final outfitNotifier = Provider.of<OutfitNotifier>(context);
    final currentOutfit = outfitNotifier.currentOutfit;

    // 將背景圖片設定為 "Black Modern Phone Wallpaper.jpg"
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/Black Modern Phone Wallpaper.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (currentOutfit != null)
              OutfitCard(outfit: currentOutfit)
            else
              const Text('請透過 AI 建議或歷史紀錄設定今日穿搭',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

// AI 穿搭建議頁面
class AiRecommendationScreen extends StatefulWidget {
  const AiRecommendationScreen({super.key});

  @override
  State<AiRecommendationScreen> createState() => _AiRecommendationScreenState();
}

class _AiRecommendationScreenState extends State<AiRecommendationScreen> {
  final TextEditingController _activityController = TextEditingController();
  List<Map<String, dynamic>> aiRecommendations = [];
  String _selectedRecommendation = '';
  bool _isLoading = false;

  // 模擬從 AI 服務獲取建議
  Future<void> _getAIRecommendations(String activity) async {
    if (activity.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
      _selectedRecommendation = '';
    });

    try {
      await Future.delayed(const Duration(seconds: 2));
      
      // 在 await 呼叫之後，檢查 Widget 是否仍然掛載
      if (!mounted) return;

      final List<Map<String, dynamic>> generatedRecommendations = [
        {
          'id': 'rec1',
          'date': '2024-07-30',
          'activity': activity,
          'title': '休閒$activity 穿搭',
          'description': '舒適的T恤和牛仔褲，搭配運動鞋。',
          'image':
              'https://placehold.co/600x400/000000/FFFFFF?text=Outfit+1',
        },
        {
          'id': 'rec2',
          'date': '2024-07-30',
          'activity': activity,
          'title': '時尚$activity 穿搭',
          'description': '俐落的襯衫與卡其褲，搭配皮鞋。',
          'image':
              'https://placehold.co/600x400/000000/FFFFFF?text=Outfit+2',
        },
        {
          'id': 'rec3',
          'date': '2024-07-30',
          'activity': activity,
          'title': '正式$activity 穿搭',
          'description': '西裝外套與長褲，搭配正裝鞋。',
          'image':
              'https://placehold.co/600x400/000000/FFFFFF?text=Outfit+3',
        },
      ];
      setState(() {
        aiRecommendations = generatedRecommendations;
      });
    } catch (e) {
      developer.log('獲取 AI 建議失敗: $e', name: 'AiRecommendationScreen');
      // 在 await 呼叫之後，檢查 Widget 是否仍然掛載
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('獲取建議時發生錯誤。'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final outfitNotifier = Provider.of<OutfitNotifier>(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _activityController,
            decoration: InputDecoration(
              labelText: '請輸入活動或場合',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _getAIRecommendations(_activityController.text),
              ),
            ),
            onSubmitted: _getAIRecommendations,
          ),
          const SizedBox(height: 16),
          _isLoading
              ? const CircularProgressIndicator()
              : aiRecommendations.isNotEmpty
                  ? Expanded(
                      child: Column(
                        children: [
                          const Text('AI 推薦穿搭：',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          Expanded(
                            child: ListView.builder(
                              itemCount: aiRecommendations.length,
                              itemBuilder: (context, index) {
                                final recommendation = aiRecommendations[index];
                                final id = recommendation['id'];
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedRecommendation = id;
                                    });
                                  },
                                  child: Card(
                                    color: _selectedRecommendation == id
                                        ? Colors.deepPurple.shade100
                                        : null,
                                    margin: const EdgeInsets.only(bottom: 16),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Image.network(
                                            recommendation['image'],
                                            height: 150,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            recommendation['title'],
                                            style: const TextStyle(
                                                fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                          Text(recommendation['description']),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _selectedRecommendation.isNotEmpty
                                ? () {
                                    final selected = aiRecommendations.firstWhere(
                                        (rec) => rec['id'] == _selectedRecommendation);
                                    outfitNotifier.setOutfit(selected);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('已將選擇的穿搭設為今日穿搭！'),
                                      ),
                                    );
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 48, vertical: 12),
                            ),
                            child: const Text('確認顯示'),
                          ),
                        ],
                      ),
                    )
                  : const Center(
                      child: Text('請輸入活動以獲得 AI 建議。'),
                    ),
        ],
      ),
    );
  }
}

// 歷史紀錄頁面
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

// 幸運色頁面 (已移除)
// 這個頁面已從導航列中移除，但保留了原始程式碼，以供參考。
class LuckyColorScreen extends StatelessWidget {
  const LuckyColorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('幸運色頁面', style: TextStyle(fontSize: 24)),
    );
  }
}

// 天氣頁面 (已移除)
// 這個頁面已從導航列中移除，但保留了原始程式碼，以供參考。
class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('天氣頁面', style: TextStyle(fontSize: 24)),
    );
  }
}
