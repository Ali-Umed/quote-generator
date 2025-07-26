import 'package:flutter/material.dart';
import '../../data/model/quote_model.dart';

class HistoryModal extends StatelessWidget {
  final List<QuoteModel> quoteHistory;
  final bool isDarkMode;
  final Color accent;

  const HistoryModal({
    super.key,
    required this.quoteHistory,
    required this.isDarkMode,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Quote History",
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
            const SizedBox(height: 8),
            if (quoteHistory.isEmpty)
              Center(
                child: Text(
                  "No history yet.",
                  style: TextStyle(
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                    fontSize: 14,
                  ),
                ),
              )
            else
              SizedBox(
                height: 300,
                child: ListView.separated(
                  itemCount: quoteHistory.length,
                  separatorBuilder: (_, __) => Divider(),
                  itemBuilder: (context, i) {
                    final hist = quoteHistory[i];
                    return ListTile(
                      title: Text(
                        hist.q ?? '',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        "- ${hist.a ?? ''}",
                        style: TextStyle(
                          color: accent,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
