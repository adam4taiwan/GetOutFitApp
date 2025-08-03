import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widgets/outfit_card.dart'; // 確保匯入 OutfitCard

// 引入您在 main.dart 中定義的 OutfitNotifier
import 'package:app/main.dart'; // 這裡假設您的專案名稱為 'app'

// 歷史穿搭紀錄頁面
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
