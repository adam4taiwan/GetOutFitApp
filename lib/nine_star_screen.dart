import 'package:flutter/material.dart';

// 九星建議頁面
// 提供一個文字輸入框，讓使用者輸入問題，並模擬 AI 提供的回答。
class NineStarScreen extends StatefulWidget {
  const NineStarScreen({super.key});

  @override
  State<NineStarScreen> createState() => _NineStarScreenState();
}

class _NineStarScreenState extends State<NineStarScreen> {
  final TextEditingController _questionController = TextEditingController();
  bool _isLoading = false;

  // 模擬 AI 應答
  Future<void> _getAIResponse() async {
    // 檢查輸入框是否為空
    if (_questionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請輸入您的問題！')),
      );
      return;
    }

    // 顯示載入指示器
    setState(() {
      _isLoading = true;
    });

    try {
      // 這裡是一個模擬的 API 呼叫，實際應用中應替換為真實的 AI 服務
      await Future.delayed(const Duration(seconds: 2));

      // 根據輸入問題提供一個簡單的模擬回答
      String responseText;
      if (_questionController.text.contains('顏色')) {
        responseText = '根據今日九星運勢，今天最適合您的幸運色是藍色和白色。';
      } else if (_questionController.text.contains('運氣')) {
        responseText = '您今日的運氣不錯，適合進行需要溝通協調的活動。';
      } else {
        responseText = '您的問題很好，九星建議您保持樂觀，好運自然會來！';
      }

      // 顯示回答框
      if (mounted) {
        _showResponseDialog(responseText);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('發生錯誤: ${e.toString()}')),
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

  // 顯示 AI 回答的對話框
  void _showResponseDialog(String response) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('九星建議的回答'),
          content: SingleChildScrollView(
            child: Text(response),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('確定'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // 頂部輸入框
          TextFormField(
            controller: _questionController,
            decoration: const InputDecoration(
              labelText: '請輸入您的問題 (例如: 今天適合穿什麼顏色)',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          // 發送按鈕
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _getAIResponse,
              icon: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send),
              label: Text(_isLoading ? '正在思考...' : '獲得建議'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
