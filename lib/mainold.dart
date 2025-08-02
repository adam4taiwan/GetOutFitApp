import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math'; // For random color generation
import 'dart:async'; // For Future.delayed
import 'package:image_picker/image_picker.dart'; // 新增: 引入 image_picker 套件
import 'dart:io'; // 新增: 引入 dart:io 用於 File 類別
import 'dart:developer' as developer; // 新增: 引入 developer 函式庫用於日誌記錄

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
  final List<Map<String, dynamic>> _history = []; // 將 _history 宣告為 final

  List<Map<String, dynamic>> get history => _history;

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
  const MyApp({super.key});

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
    CameraScreen(), // 相機頁面
  ];

  // 將 _onItemTapped 方法公開，讓其他 Widget 可以呼叫
  void onItemTapped(int index) {
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
            BottomNavigationBarItem(
              // 新增相機導航按鈕
              icon: Icon(Icons.camera_alt),
              label: '拍照搭配',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.purple[800],
          unselectedItemColor: Colors.grey[600],
          onTap: onItemTapped,
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
  const HomeScreen({super.key});

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
  const OutfitsScreen({super.key});

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
                  ? Center(
                      child: Text(
                        '您還沒有任何穿搭記錄。快去創造您的第一套穿搭吧！',
                        style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                        textAlign: TextAlign.center,
                      ),
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
  const LuckyColorScreen({super.key});

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
                        color: Colors.black.withAlpha((255 * 0.2).round()),
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
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  Map<String, String>? _weather;
  final String _location = '台北';

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    // 模擬獲取天氣數據
    await Future.delayed(const Duration(seconds: 1)); // 模擬網路延遲
    // 由於此處沒有使用 BuildContext，所以無需 mounted 檢查
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
  const ProfileScreen({super.key});

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
                    color: Colors.black.withAlpha((255 * 0.2).round()),
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
                          onChanged: (text) => _nameController.text = text,
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
                          readOnly: true,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _handleSaveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[500],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            minimumSize: const Size(double.infinity, 0),
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
                            backgroundColor: Colors.red[500],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            minimumSize: const Size(double.infinity, 0),
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
                            backgroundColor: Colors.green[500],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            minimumSize: const Size(double.infinity, 0),
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

// 相機頁面：已根據您的需求和截圖進行大幅修改
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  String _message = '點擊下方按鈕啟動相機';
  XFile? _selectedImage; // 用於儲存選擇的圖片檔案

  // 使用相機拍照
  void _handleCapturePhoto() async {
    setState(() {
      _message = '正在開啟相機...';
      _selectedImage = null; // 清除之前的圖片
    });

    final ImagePicker picker = ImagePicker();
    try {
      // 使用 ImageSource.camera 打開相機
      final XFile? image = await picker.pickImage(source: ImageSource.camera);

      if (!mounted) return; // 修正：在異步間隙後檢查 mounted 狀態

      if (image != null) {
        setState(() {
          _selectedImage = image; // 儲存拍攝的圖片
          _message = '照片已拍攝！正在分析穿搭...';
        });
        // 備註：此處照片預設存在應用程式的暫存目錄。
        // 如果需要永久保存到相簿，可以額外使用 `gallery_saver` 等套件。
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('照片已拍攝並顯示！')));
      } else {
        setState(() {
          _message = '未拍攝照片。';
        });
      }
    } catch (e) {
      // 修正: 使用 developer.log 替換 print
      developer.log('開啟相機失敗或權限問題: $e', name: 'CameraScreen');
      if (!mounted) return; // 修正：在異步間隙後檢查 mounted 狀態
      setState(() {
        _message = '開啟相機失敗或權限問題: $e';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('錯誤: 無法開啟相機，請檢查權限。')));
    }
  }

  // 從相簿上傳照片
  void _handleUploadPhoto() async {
    setState(() {
      _message = '正在開啟相簿...';
      _selectedImage = null;
    });

    final ImagePicker picker = ImagePicker();
    try {
      // 從相簿中選擇圖片
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (!mounted) return; // 修正：在異步間隙後檢查 mounted 狀態

      if (image != null) {
        setState(() {
          _selectedImage = image; // 儲存選擇的圖片
          _message = '照片已選擇！正在分析穿搭...';
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('照片已選擇並顯示！')));
      } else {
        setState(() {
          _message = '未選擇照片。';
        });
      }
    } catch (e) {
      // 修正: 使用 developer.log 替換 print
      developer.log('開啟相簿失敗或權限問題: $e', name: 'CameraScreen');
      if (!mounted) return; // 修正：在異步間隙後檢查 mounted 狀態
      setState(() {
        _message = '開啟相簿失敗或權限問題: $e';
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('錯誤: 無法開啟相簿，請檢查權限。')));
    }
  }

  void _handleSaveOutfit() {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('請先拍攝或選擇一張照片！')));
      return;
    }
    final outfitNotifier = Provider.of<OutfitNotifier>(context, listen: false);
    // 模擬生成一個穿搭並保存到歷史記錄
    final newOutfit = {
      'name': 'AI 智慧推薦穿搭',
      'description': '這是一套基於您的照片和 AI 分析的推薦穿搭。',
      'date': DateTime.now().toLocal().toString().split(' ')[0], // 格式化日期
      'imageUrl':
          'https://placehold.co/300x200/A0BBE0/FFFFFF?text=AI推薦穿搭', // 模擬推薦圖片
    };
    outfitNotifier.addHistory(newOutfit);
    setState(() {
      _message = '穿搭已存入衣櫃！';
      _selectedImage = null; // 清除已選圖片
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('穿搭已保存到「我的穿搭」！')));
  }

  void _handleClear() {
    setState(() {
      _message = '畫面已清除。';
      _selectedImage = null; // 清除後隱藏圖片
    });
  }

  void _handleGoHome() {
    final myAppState = context.findAncestorStateOfType<_MyAppState>();
    myAppState?.onItemTapped(0);
    _message = '已返回首頁。';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF0F4C3),
            Color(0xFFC8E6C9),
          ], // Light green/yellow gradient
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text(
                  '拍照搭配',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    // 左側的圖片預覽區
                    Expanded(
                      flex: 3,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(
                            color: Colors.grey[400]!,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  File(_selectedImage!.path),
                                  fit: BoxFit.cover, // 這裡已經使用了 BoxFit.cover
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Text(
                                        '圖片載入失敗',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.camera_alt,
                                      size: 80,
                                      color: Colors.grey[500],
                                    ),
                                    const SizedBox(height: 16),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                      ),
                                      child: Text(
                                        _message,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[700],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // 右側的功能按鈕區
                    Expanded(
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildFunctionButton(
                            context,
                            '拍照',
                            _handleCapturePhoto,
                          ),
                          _buildFunctionButton(
                            context,
                            '上傳照片',
                            _handleUploadPhoto,
                          ),
                          _buildFunctionButton(
                            context,
                            '存入衣櫃',
                            _handleSaveOutfit,
                          ),
                          _buildFunctionButton(context, '清除', _handleClear),
                          _buildFunctionButton(context, '回首頁', _handleGoHome),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFunctionButton(
    BuildContext context,
    String text,
    VoidCallback onPressed,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 5,
          minimumSize: const Size.fromHeight(50),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          if (title == '拍照搭配') {
            final myAppState = context.findAncestorStateOfType<_MyAppState>();
            myAppState?.onItemTapped(5);
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('點擊了 $title 功能！')));
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.purple[700]),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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

  const OutfitCard({super.key, required this.outfit});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            outfit['imageUrl'] ??
                'https://placehold.co/300x200/E0E0E0/333333?text=穿搭圖片',
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
