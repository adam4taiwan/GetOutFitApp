import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // For Future.delayed
import 'dart:developer' as developer; // For logging

// 匯入新的頁面檔案和主檔案
import 'main.dart';
import 'nine_star_screen.dart'; 

// 引入 widgets
import 'widgets/outfit_card.dart';

// AI 推薦頁面
// 此頁面現在包含了 TabBar，用於切換「AI推薦」和「九星建議」兩個子頁面。
class AIRecScreen extends StatefulWidget {
  const AIRecScreen({super.key});

  @override
  State<AIRecScreen> createState() => _AIRecScreenState();
}

class _AIRecScreenState extends State<AIRecScreen> {
  final TextEditingController _activityController = TextEditingController();
  bool _isLoading = false;
  String _selectedRecommendation = '';
  List<Map<String, dynamic>> aiRecommendations = [];

  // 根據活動生成模擬的 AI 穿搭建議
  Future<void> _getAIRecommendations() async {
    if (_activityController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請輸入活動以獲得建議！')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      aiRecommendations = [];
      _selectedRecommendation = '';
    });

    try {
      // 模擬 AI 穿搭生成，實際應用中應替換為真實的 API 呼叫
      await Future.delayed(const Duration(seconds: 2));

      // 模擬生成 3 個不同的穿搭建議
      aiRecommendations = List.generate(3, (index) {
        return {
          'id': 'rec_$index',
          'title': '${_activityController.text} 穿搭 ${index + 1}',
          'description': '這是為您量身打造的穿搭建議。',
          'items': [
            {'name': '白色T恤', 'color': 'White'},
            {'name': '牛仔褲', 'color': 'Blue'},
            {'name': '運動鞋', 'color': 'Gray'},
          ],
        };
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI 建議已生成！')),
        );
      }
    } catch (e) {
      developer.log('AI 穿搭建議失敗: $e', name: 'AIRecScreen');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('生成建議失敗: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 這裡使用 DefaultTabController 來管理 TabBar 和 TabBarView
    return DefaultTabController(
      length: 2, // 兩個 Tab：「AI建議」和「九星建議」
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // 隱藏返回按鈕，因為這是主頁面之一
          title: const Text('穿搭建議'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'AI建議'),
              Tab(text: '九星建議'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 第一個 Tab 的內容：原來的 AI 穿搭建議功能
            _buildAIRecommendationContent(),
            // 第二個 Tab 的內容：新加入的九星建議頁面
            const NineStarScreen(),
          ],
        ),
      ),
    );
  }

  // 獨立出 AI 穿搭建議的內容
  Widget _buildAIRecommendationContent() {
    final outfitNotifier = Provider.of<OutfitNotifier>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _activityController,
            decoration: const InputDecoration(
              labelText: '請輸入您要參加的活動 (例如: 辦公室, 戶外野餐)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _getAIRecommendations,
            icon: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(_isLoading ? '正在生成...' : '生成 AI 建議'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 24),
          if (aiRecommendations.isNotEmpty)
            Column(
              children: [
                ...aiRecommendations.map(
                  (rec) {
                    final isSelected = _selectedRecommendation == rec['id'];
                    return OutfitCard(
                      outfit: rec,
                      onTap: () {
                        setState(() {
                          _selectedRecommendation = isSelected ? '' : rec['id'];
                        });
                      },
                      isSelected: isSelected,
                    );
                  },
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
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                  ),
                  child: const Text('確認顯示'),
                ),
              ],
            )
          else
            const Center(
              child: Text('請輸入活動以獲得 AI 建議。'),
            ),
        ],
      ),
    );
  }
}
