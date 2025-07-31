import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math'; // For random color generation
import 'dart:async'; // For Future.delayed

// --- 1. 狀態管理 (使用 ChangeNotifier 和 Provider) ---

// Auth 狀態
class AuthNotifier extends ChangeNotifier {
  Map<String, String>? _user;

  Map<String, String>? get user => _user;

  void setUser(Map<String, String>? newUser) {
    _user = newUser;
    notifyListeners(); // 通知所有監聽者狀態已改變
  }
}

// Outfit 狀態
class OutfitNotifier extends ChangeNotifier {
  Map<String, dynamic>? _currentOutfit;
  List<Map<String, dynamic>> _history = [];

  Map<String, dynamic>? get currentOutfit => _currentOutfit;
  List<Map<String, dynamic>> get history => _history;

  void setOutfit(Map<String, dynamic>? newOutfit) {
    _currentOutfit = newOutfit;
    notifyListeners();
  }

  void addHistory(Map<String, dynamic> outfit) {
    _history.add(outfit);
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

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0; // 當前選中的底部導航索引

  // 頁面列表
  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    OutfitsScreen(),
    LuckyColorScreen(),
    WeatherScreen(),
    ProfileScreen(),
    CameraScreen(), // 相機頁面，雖然是模擬的
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Wardrobe App',
      theme: ThemeData(
        primarySwatch: Colors.purple, // 主題顏色
        fontFamily: 'Inter', // 設置字體，需要確保在 pubspec.yaml 中引入
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        body: IndexedStack(
          // 使用 IndexedStack 保持頁面狀態
          index: _selectedIndex,
          children: _widgetOptions,
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: '首頁'),
            BottomNavigationBarItem(
              icon: Icon(Icons.dry_cleaning), // 👗
              label: '穿搭',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.color_lens), // 🌈
              label: '幸運色',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.cloud), // ☁️
              label: '天氣',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person), // 👤
              label: '我的',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.purple[800],
          unselectedItemColor: Colors.grey[600],
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed, // 固定底部導航欄樣式
          backgroundColor: Colors.white,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        ),
      ),
    );
  }
}

// --- 3. 頁面組件 ---

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 使用 Consumer 監聽 AuthNotifier 的變化
    final authNotifier = Provider.of<AuthNotifier>(context);
    final user = authNotifier.user;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFEDE7F6),
            Color(0xFFE3F2FD),
          ], // from-purple-100 to-blue-100
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          // 允許內容滾動
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.only(bottom: 24),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text(
                        '歡迎來到 AI Wardrobe',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      user != null
                          ? Text(
                              '哈囉, ${user['name']}！準備好今天的穿搭了嗎？',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[700],
                              ),
                              textAlign: TextAlign.center,
                            )
                          : Text(
                              '請登入以獲得個人化體驗！',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[700],
                              ),
                              textAlign: TextAlign.center,
                            ),
                    ],
                  ),
                ),
              ),
              GridView.count(
                shrinkWrap: true, // 讓 GridView 根據內容自動調整高度
                physics:
                    const NeverScrollableScrollPhysics(), // 禁用 GridView 自身的滾動
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: const [
                  FeatureCard(
                    title: '每日穿搭建議',
                    description: '根據天氣和您的偏好提供每日穿搭建議。',
                    icon: Icons.wb_sunny,
                  ),
                  FeatureCard(
                    title: '幸運顏色',
                    description: '查看您今天的幸運顏色，讓您好運一整天！',
                    icon: Icons.emoji_events,
                  ),
                  FeatureCard(
                    title: '我的衣櫃',
                    description: '管理您的衣物清單，輕鬆搭配。',
                    icon: Icons.checkroom,
                  ),
                  FeatureCard(
                    title: '拍照搭配',
                    description: '使用相機拍攝衣物，AI 幫您分析搭配。',
                    icon: Icons.camera_alt,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OutfitsScreen extends StatelessWidget {
  const OutfitsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final outfitNotifier = Provider.of<OutfitNotifier>(context);
    final outfits = outfitNotifier.history;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFCE4EC),
            Color(0xFFFFEBEE),
          ], // from-pink-100 to-red-100
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '我的穿搭',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            Expanded(
              child: outfits.isEmpty
                  ? Text(
                      '您還沒有任何穿搭記錄。快去創造您的第一套穿搭吧！',
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2, // 兩列
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                            childAspectRatio: 0.7, // 調整卡片長寬比
                          ),
                      itemCount: outfits.length,
                      itemBuilder: (context, index) {
                        return OutfitCard(outfit: outfits[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class LuckyColorScreen extends StatefulWidget {
  const LuckyColorScreen({Key? key}) : super(key: key);

  @override
  State<LuckyColorScreen> createState() => _LuckyColorScreenState();
}

class _LuckyColorScreenState extends State<LuckyColorScreen> {
  Color _luckyColor = Colors.transparent;
  String _colorName = '';

  @override
  void initState() {
    super.initState();
    _fetchLuckyColor();
  }

  void _fetchLuckyColor() {
    final colors = [
      {'name': '紅色', 'hex': 0xFFFF0000},
      {'name': '藍色', 'hex': 0xFF0000FF},
      {'name': '綠色', 'hex': 0xFF00FF00},
      {'name': '黃色', 'hex': 0xFFFFFF00},
      {'name': '紫色', 'hex': 0xFF800080},
      {'name': '橙色', 'hex': 0xFFFFA500},
    ];
    final random = Random();
    final randomColorData = colors[random.nextInt(colors.length)];
    setState(() {
      _luckyColor = Color(randomColorData['hex'] as int);
      _colorName = randomColorData['name'] as String;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFF9C4),
            Color(0xFFE8F5E9),
          ], // from-yellow-100 to-green-100
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '今日幸運顏色',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_luckyColor != Colors.transparent) // 只有當顏色載入後才顯示
              GestureDetector(
                onTap: _fetchLuckyColor, // 點擊圓圈可以重新生成顏色
                child: Container(
                  width: 192, // w-48 * 4 (Tailwind unit to Flutter approx)
                  height: 192, // h-48 * 4
                  decoration: BoxDecoration(
                    color: _luckyColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 4,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _colorName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28, // text-3xl
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Text(
              '您的幸運顏色是：',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[800],
              ), // text-2xl
            ),
            Text(
              _colorName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: _luckyColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '穿上它，今天一定好運連連！',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ), // text-lg
            ),
          ],
        ),
      ),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Map<String, String>? _weather;
  String _location = '台北'; // 模擬位置

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    // 模擬獲取天氣數據
    await Future.delayed(const Duration(seconds: 1)); // 模擬網路延遲
    setState(() {
      _weather = {
        'city': _location,
        'temperature': '28°C',
        'condition': '晴朗',
        'icon': '☀️',
        'description': '今天天氣晴朗，適合外出活動。',
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFE3F2FD),
            Color(0xFFE0F7FA),
          ], // from-blue-100 to-cyan-100
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '天氣資訊',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _weather != null
                ? Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Text(
                            _weather!['city']!,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _weather!['icon']!,
                            style: const TextStyle(fontSize: 64),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _weather!['temperature']!,
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[900],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _weather!['condition']!,
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _weather!['description']!,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '根據天氣，建議穿著輕便透氣的衣物。',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : Text(
                    '載入天氣資訊中...',
                    style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                  ),
          ],
        ),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    // 初始化時從狀態中獲取用戶資訊
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
      if (authNotifier.user != null) {
        _nameController.text = authNotifier.user!['name'] ?? '';
        _emailController.text = authNotifier.user!['email'] ?? '';
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _overlayEntry?.remove(); // 確保 overlay 被移除
    super.dispose();
  }

  void _showCustomMessage(String message) {
    _overlayEntry?.remove(); // 移除之前的 overlay
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 100,
        left: 0,
        right: 0,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(_overlayEntry!);

    Future.delayed(const Duration(seconds: 3), () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  void _handleLogin() {
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    authNotifier.setUser({'name': '訪客', 'email': 'guest@example.com'});
    _nameController.text = authNotifier.user!['name'] ?? '';
    _emailController.text = authNotifier.user!['email'] ?? '';
    _showCustomMessage('已登入為訪客！');
  }

  void _handleLogout() {
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    authNotifier.setUser(null);
    _nameController.clear();
    _emailController.clear();
    _showCustomMessage('已登出！');
  }

  void _handleSaveProfile() {
    final authNotifier = Provider.of<AuthNotifier>(context, listen: false);
    authNotifier.setUser({
      'name': _nameController.text,
      'email': _emailController.text,
    });
    _showCustomMessage('個人資料已儲存！');
  }

  @override
  Widget build(BuildContext context) {
    final authNotifier = Provider.of<AuthNotifier>(context);
    final user = authNotifier.user;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF5F5F5),
            Color(0xFFEEEEEE),
          ], // from-gray-100 to-gray-200
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '個人資料',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      if (user != null) ...[
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: '姓名',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.person),
                          ),
                          onChanged: (text) =>
                              _nameController.text = text, // 更新控制器文本
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.email),
                          ),
                          readOnly: true, // Email 通常不可編輯
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _handleSaveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[500], // bg-blue-500
                            foregroundColor: Colors.white, // text-white
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                30,
                              ), // rounded-full
                            ),
                            minimumSize: const Size(
                              double.infinity,
                              0,
                            ), // w-full
                            elevation: 4,
                          ),
                          child: const Text(
                            '儲存個人資料',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _handleLogout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[500], // bg-red-500
                            foregroundColor: Colors.white, // text-white
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                30,
                              ), // rounded-full
                            ),
                            minimumSize: const Size(
                              double.infinity,
                              0,
                            ), // w-full
                            elevation: 4,
                          ),
                          child: const Text(
                            '登出',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ] else ...[
                        ElevatedButton(
                          onPressed: _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[500], // bg-green-500
                            foregroundColor: Colors.white, // text-white
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                30,
                              ), // rounded-full
                            ),
                            minimumSize: const Size(
                              double.infinity,
                              0,
                            ), // w-full
                            elevation: 4,
                          ),
                          child: const Text(
                            '登入',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  String _message = '點擊下方按鈕啟動相機';

  void _handleLaunchCamera() {
    setState(() {
      _message = '正在啟動相機... (此為模擬功能)';
    });
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _message = '相機已準備就緒！';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFEEEEEE),
            Color(0xFFE0E0E0),
          ], // from-gray-200 to-gray-300
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '相機',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    const Icon(
                      Icons.camera_alt,
                      size: 64,
                      color: Colors.grey,
                    ), // 📸
                    const SizedBox(height: 16),
                    Text(
                      _message,
                      style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _handleLaunchCamera,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[500], // bg-purple-500
                        foregroundColor: Colors.white, // text-white
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 24,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            30,
                          ), // rounded-full
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        '啟動相機',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '（此功能在實際 Flutter 環境中才可運作）',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 4. 可重用組件 ---

class FeatureCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const FeatureCard({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6, // shadow-md
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ), // rounded-xl
      child: InkWell(
        // 提供點擊效果
        onTap: () {
          // TODO: 點擊後導航到相應功能頁面
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('點擊了 $title 功能！')));
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.purple[700]), // text-5xl
              const SizedBox(height: 12), // mb-3
              Text(
                title,
                style: TextStyle(
                  fontSize: 18, // text-xl
                  fontWeight: FontWeight.bold, // font-semibold
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ), // text-sm
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OutfitCard extends StatelessWidget {
  final Map<String, dynamic> outfit;

  const OutfitCard({Key? key, required this.outfit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6, // shadow-md
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ), // rounded-xl
      clipBehavior: Clip.antiAlias, // 確保圖片圓角
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            outfit['imageUrl'] ??
                'https://placehold.co/300x200/E0E0E0/333333?text=穿搭圖片',
            width: double.infinity,
            height: 160, // h-48
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
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  outfit['name'] ?? '未知穿搭',
                  style: TextStyle(
                    fontSize: 16, // text-lg
                    fontWeight: FontWeight.bold, // font-semibold
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  outfit['description'] ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ), // text-sm
                ),
                const SizedBox(height: 8),
                Text(
                  '日期: ${outfit['date'] ?? '未知'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ), // text-xs
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
