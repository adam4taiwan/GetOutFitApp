import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 引入 main.dart 中的狀態管理和穿搭卡片
import 'main.dart';
import 'widgets/outfit_card.dart';

// 歷史紀錄頁面
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

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
