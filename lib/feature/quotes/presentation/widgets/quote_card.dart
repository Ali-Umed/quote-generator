import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/model/quote_model.dart';

class QuoteCard extends StatelessWidget {
  final QuoteModel? quote;
  final bool isDarkMode;
  final Color accent;
  final bool isFavorited;
  final VoidCallback onFavorite;

  const QuoteCard({
    super.key,
    required this.quote,
    required this.isDarkMode,
    required this.accent,
    required this.isFavorited,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    if (quote == null) {
      return Center(
        child: Text(
          "No quote available at the moment. Please try again.",
          style: TextStyle(
            color: isDarkMode ? Colors.white70 : Colors.black54,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
    return Center(
      child: Container(
        padding: const EdgeInsets.all(22.0),
        margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
        decoration: BoxDecoration(
          gradient: isDarkMode
              ? LinearGradient(
                  colors: [Color(0xFF232526), Color(0xFF141E30)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [Color(0xFFe0eafc), Color(0xFFcfdef3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(18.0),
          border: Border.all(
            color: accent.withOpacity(0.18),
            width: 1.2,
          ),
        ),
        child: Column(
          key: ValueKey(quote!.q),
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.format_quote_rounded,
              color: accent,
              size: 32,
            ),
            const SizedBox(height: 10),
            Text(
              quote!.q ?? '',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                height: 1.5,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "- ${quote!.a ?? ''}",
              style: TextStyle(
                fontSize: 15,
                color: accent.withOpacity(0.85),
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.copy, color: accent),
                  tooltip: "Copy Quote",
                  onPressed: () async {
                    final text = '"${quote!.q}" - ${quote!.a}';
                    await Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Quote copied to clipboard!"),
                        backgroundColor: accent,
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(
                    isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: isFavorited
                        ? accent
                        : (isDarkMode ? Colors.white54 : Colors.black26),
                  ),
                  tooltip: isFavorited
                      ? "Remove from Favorites"
                      : "Add to Favorites",
                  onPressed: onFavorite,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
