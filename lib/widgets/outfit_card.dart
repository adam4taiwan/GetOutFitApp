import 'package:flutter/material.dart';

// 穿搭卡片小工具
// 這裡新增了 isSelected 和 onTap 參數，以支援可選取功能。
class OutfitCard extends StatelessWidget {
  final Map<String, dynamic> outfit;
  final bool isSelected;
  final VoidCallback? onTap;

  const OutfitCard({
    super.key,
    required this.outfit,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 使用 GestureDetector 包裝卡片，以處理點擊事件
    return GestureDetector(
      onTap: onTap,
      child: Card(
        // 根據 isSelected 狀態改變邊框樣式
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: isSelected
              ? BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 3.0,
                )
              : BorderSide.none,
        ),
        elevation: isSelected ? 8 : 2, // 選取時陰影加深
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '穿搭名稱: ${outfit['name']}',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '天氣建議: ${outfit['weather']}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '場合: ${outfit['occasion']}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              // 圖片顯示（這裡使用佔位符）
              const SizedBox(height: 16),
              Center(
                child: Container(
                  width: 150,
                  height: 150,
                  color: outfit['imageColor'],
                  child: Center(
                    child: Text(
                      '穿搭圖片\n(佔位符)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
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
