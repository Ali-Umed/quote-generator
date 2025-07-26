import 'package:flutter/material.dart';
import '../../data/model/quote_model.dart';

class FavoritesModal extends StatelessWidget {
  final List<QuoteModel> favoriteQuotes;
  final bool isDarkMode;
  final Color accent;
  final void Function(int) onRemove;

  const FavoritesModal({
    super.key,
    required this.favoriteQuotes,
    required this.isDarkMode,
    required this.accent,
    required this.onRemove,
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
                  "Favorite Quotes",
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
            if (favoriteQuotes.isEmpty)
              Center(
                child: Text(
                  "No favorites yet.",
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
                  itemCount: favoriteQuotes.length,
                  separatorBuilder: (_, __) => Divider(),
                  itemBuilder: (context, i) {
                    final fav = favoriteQuotes[i];
                    return ListTile(
                      title: Text(
                        fav.q ?? '',
                        style: TextStyle(
                          color: isDarkMode ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        "- ${fav.a ?? ''}",
                        style: TextStyle(
                          color: accent,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: accent),
                        tooltip: "Remove from Favorites",
                        onPressed: () => onRemove(i),
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
