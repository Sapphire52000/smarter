import 'package:flutter/material.dart';

/// 색상 선택 위젯
class ColorSelectorWidget extends StatelessWidget {
  final Color selectedColor;
  final Function(Color, String) onColorSelected;

  const ColorSelectorWidget({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('일정 색상'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildColorOption(
              Colors.blue,
              '#4285F4',
              selectedColor,
              onColorSelected,
            ),
            _buildColorOption(
              Colors.red,
              '#EA4335',
              selectedColor,
              onColorSelected,
            ),
            _buildColorOption(
              Colors.green,
              '#34A853',
              selectedColor,
              onColorSelected,
            ),
            _buildColorOption(
              Colors.amber,
              '#FBBC05',
              selectedColor,
              onColorSelected,
            ),
            _buildColorOption(
              Colors.purple,
              '#A142F4',
              selectedColor,
              onColorSelected,
            ),
          ],
        ),
      ],
    );
  }

  // 색상 선택 옵션 위젯
  Widget _buildColorOption(
    Color color,
    String hex,
    Color selectedColor,
    Function(Color, String) onSelect,
  ) {
    final isSelected = color.value == selectedColor.value;

    return GestureDetector(
      onTap: () => onSelect(color, hex),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
        child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
      ),
    );
  }
}
