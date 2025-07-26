import 'package:flutter/material.dart';

class AccentColorPicker extends StatelessWidget {
  final List<Color> accentColors;
  final int selectedAccentIndex;
  final bool isDarkMode;
  final void Function(int) onSelect;

  const AccentColorPicker({
    super.key,
    required this.accentColors,
    required this.selectedAccentIndex,
    required this.isDarkMode,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent = accentColors[selectedAccentIndex];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Choose Accent Color",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: accent,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: accent),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 18,
              runSpacing: 18,
              children: List.generate(accentColors.length, (i) {
                return GestureDetector(
                  onTap: () => onSelect(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: selectedAccentIndex == i ? 44 : 36,
                    height: selectedAccentIndex == i ? 44 : 36,
                    decoration: BoxDecoration(
                      color: accentColors[i],
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selectedAccentIndex == i
                            ? (isDarkMode ? Colors.white : Colors.black87)
                            : Colors.transparent,
                        width: 3,
                      ),
                      boxShadow: [
                        if (selectedAccentIndex == i)
                          BoxShadow(
                            color: accentColors[i].withOpacity(0.4),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                      ],
                    ),
                    child: selectedAccentIndex == i
                        ? Icon(Icons.check,
                            color: isDarkMode ? Colors.white : Colors.black87)
                        : null,
                  ),
                );
              }),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}
