import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quote_app/api.dart';
import 'package:quote_app/quote_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<QuoteModel> favoriteQuotes = [];
  bool inProgress = false;
  QuoteModel? quote;
  String? errorMessage;
  bool isDarkMode = true;
  final List<Color> accentColors = [
    Color(0xFFFFB300),
    Color(0xFF42A5F5),
    Color(0xFF66BB6A),
    Color(0xFFAB47BC),
    Color(0xFFEF5350),
  ];
  int selectedAccentIndex = 0;

  void _showAccentColorPicker() {
    final Color accent = accentColors[selectedAccentIndex];
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? const Color(0xFF232526) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
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
                      onTap: () {
                        setState(() {
                          selectedAccentIndex = i;
                        });
                        Navigator.of(context).pop();
                      },
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
                                color:
                                    isDarkMode ? Colors.white : Colors.black87)
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
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchQuote();
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = accentColors[selectedAccentIndex];
    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF181A20) : const Color(0xFFF6F8FB),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [Color(0xFF232526), Color(0xFF414345), Color(0xFF141E30)]
                : [
                    Color(0xFFe0eafc),
                    Color.fromARGB(255, 167, 176, 188),
                    Color.fromARGB(255, 197, 200, 156)
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.format_quote_rounded,
                          color: accent,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "Daily Inspiration",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: Icon(Icons.favorite,
                              color: favoriteQuotes.isNotEmpty
                                  ? accent
                                  : (isDarkMode
                                      ? Colors.white54
                                      : Colors.black26)),
                          tooltip: "View Favorites",
                          onPressed: favoriteQuotes.isEmpty
                              ? null
                              : _showFavoritesModal,
                        ),
                        IconButton(
                          icon: Icon(Icons.palette_rounded, color: accent),
                          tooltip: "Choose Accent Color",
                          onPressed: _showAccentColorPicker,
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.white10 : Colors.black12,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: IconButton(
                        icon: Icon(
                          isDarkMode
                              ? CupertinoIcons.sun_max_fill
                              : CupertinoIcons.moon_fill,
                          color: accent,
                        ),
                        onPressed: _toggleTheme,
                        tooltip: isDarkMode
                            ? "Switch to Light Mode"
                            : "Switch to Dark Mode",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: inProgress
                        ? Center(
                            child: CupertinoActivityIndicator(
                              radius: 18,
                              color: accent,
                            ),
                          )
                        : errorMessage != null
                            ? _buildErrorState(accent)
                            : _buildQuoteCard(accent),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: CupertinoButton(
                    color: accent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    onPressed: _fetchQuote,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.refresh,
                          size: 18,
                          color: isDarkMode ? Colors.black : Colors.white,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "New Quote",
                          style: TextStyle(
                            fontSize: 15,
                            color: isDarkMode ? Colors.black : Colors.white,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  Widget _buildQuoteCard(Color accent) {
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

    final bool isFavorited =
        favoriteQuotes.any((q) => q.q == quote!.q && q.a == quote!.a);

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
              quote!.q as String,
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
              "- ${quote!.a}",
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
                  onPressed: () {
                    setState(() {
                      if (isFavorited) {
                        favoriteQuotes.removeWhere(
                            (q) => q.q == quote!.q && q.a == quote!.a);
                      } else {
                        favoriteQuotes
                            .add(QuoteModel(q: quote!.q, a: quote!.a));
                      }
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFavoritesModal() {
    final Color accent = accentColors[selectedAccentIndex];
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? const Color(0xFF232526) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
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
                            onPressed: () {
                              setState(() {
                                favoriteQuotes.removeAt(i);
                              });
                              if (favoriteQuotes.isEmpty)
                                Navigator.of(context).pop();
                            },
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(Color accent) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          color: accent,
          size: 30,
        ),
        const SizedBox(height: 10),
        Text(
          errorMessage ?? "Something went wrong.",
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        CupertinoButton(
          color: accent,
          onPressed: _fetchQuote,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: const Text(
            "Retry",
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }

  Future<void> _fetchQuote() async {
    setState(() {
      inProgress = true;
      errorMessage = null;
    });

    try {
      final fetchedQuote = await Api.fetchRandomQuote();
      setState(() {
        quote = fetchedQuote;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Failed to fetch quote. Please try again later.";
      });
    } finally {
      setState(() {
        inProgress = false;
      });
    }
  }
}
