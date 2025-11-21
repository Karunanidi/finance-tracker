import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class CategorySelector extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  static const categories = [
    {'name': 'Food', 'icon': Icons.restaurant, 'color': Color(0xFFEC4899)},
    {
      'name': 'Transport',
      'icon': Icons.directions_car,
      'color': Color(0xFF6366F1),
    },
    {
      'name': 'Shopping',
      'icon': Icons.shopping_bag,
      'color': Color(0xFF8B5CF6),
    },
    {'name': 'Entertainment', 'icon': Icons.movie, 'color': Color(0xFFF59E0B)},
    {
      'name': 'Health',
      'icon': Icons.medical_services,
      'color': Color(0xFF10B981),
    },
    {'name': 'Bills', 'icon': Icons.receipt_long, 'color': Color(0xFFEF4444)},
    {
      'name': 'Salary',
      'icon': Icons.account_balance_wallet,
      'color': Color(0xFF14B8A6),
    },
    {'name': 'Other', 'icon': Icons.category, 'color': Color(0xFF64748B)},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final isSelected = selectedCategory == category['name'];

        return GestureDetector(
          onTap: () => onCategorySelected(category['name'] as String),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? (category['color'] as Color).withValues(alpha: 0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? (category['color'] as Color)
                    : Colors.grey.withValues(alpha: 0.1),
                width: 2,
              ),
              boxShadow: [
                if (!isSelected)
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  category['icon'] as IconData,
                  color: category['color'] as Color,
                  size: 28,
                ),
                const SizedBox(height: 4),
                AutoSizeText(
                  category['name'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1F2937),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  minFontSize: 8,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
