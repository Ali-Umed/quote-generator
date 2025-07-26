import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quote_app/feature/quotes/data/datasource/quote_remote_datasource.dart';
import 'package:quote_app/feature/quotes/data/model/quote_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/quote_card.dart';
import '../widgets/favorites_modal.dart';
import '../widgets/history_modal.dart';
import '../widgets/accent_color_picker.dart';
import '../widgets/error_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _loadPrefs().then((_) => _fetchQuote());
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? true;
      selectedAccentIndex = prefs.getInt('selectedAccentIndex') ?? 0;
      final favs = prefs.getStringList('favoriteQuotes') ?? [];
      favoriteQuotes = favs.map((s) {
        final parts = s.split('|||');
        return QuoteModel(q: parts[0], a: parts.length > 1 ? parts[1] : '');
      }).toList();
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
    await prefs.setInt('selectedAccentIndex', selectedAccentIndex);
    final favs = favoriteQuotes.map((q) => '${q.q}|||${q.a}').toList();
    await prefs.setStringList('favoriteQuotes', favs);
  }

  List<QuoteModel> favoriteQuotes = [];
  List<QuoteModel> quoteHistory = [];
  void _showHistoryModal() {
    final Color accent = accentColors[selectedAccentIndex];
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? const Color(0xFF232526) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => HistoryModal(
        quoteHistory: quoteHistory,
        isDarkMode: isDarkMode,
        accent: accent,
      ),
    );
  }

  bool inProgress = false;
  QuoteModel? quote;
  String? errorMessage;
  bool isDarkMode = true;
  final List<Color> accentColors = [
    Color(0xFF42A5F5),
    Color(0xFF66BB6A),
    Color(0xFFAB47BC),
    Color(0xFFEF5350),
  ];
  int selectedAccentIndex = 0;

  void _showAccentColorPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? const Color(0xFF232526) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) => AccentColorPicker(
        accentColors: accentColors,
        selectedAccentIndex: selectedAccentIndex,
        isDarkMode: isDarkMode,
        onSelect: (i) async {
          setState(() {
            selectedAccentIndex = i;
          });
          await _savePrefs();
          Navigator.of(context).pop();
        },
      ),
    );
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
                        Text(
                          "Quotes",
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
                          icon: Icon(Icons.history_rounded, color: accent),
                          tooltip: "Quote History",
                          onPressed:
                              quoteHistory.isEmpty ? null : _showHistoryModal,
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
    _savePrefs();
  }

  Widget _buildQuoteCard(Color accent) {
    final bool isFavorited =
        favoriteQuotes.any((q) => q.q == quote?.q && q.a == quote?.a);
    return QuoteCard(
      quote: quote,
      isDarkMode: isDarkMode,
      accent: accent,
      isFavorited: isFavorited,
      onFavorite: () async {
        setState(() {
          if (isFavorited) {
            favoriteQuotes
                .removeWhere((q) => q.q == quote!.q && q.a == quote!.a);
          } else {
            favoriteQuotes.add(QuoteModel(q: quote!.q, a: quote!.a));
          }
        });
        await _savePrefs();
      },
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
      builder: (context) => FavoritesModal(
        favoriteQuotes: favoriteQuotes,
        isDarkMode: isDarkMode,
        accent: accent,
        onRemove: (i) async {
          setState(() {
            favoriteQuotes.removeAt(i);
          });
          await _savePrefs();
          if (favoriteQuotes.isEmpty) Navigator.of(context).pop();
        },
      ),
    );
  }

  Widget _buildErrorState(Color accent) {
    return ErrorState(
      errorMessage: errorMessage,
      accent: accent,
      onRetry: _fetchQuote,
      isDarkMode: isDarkMode,
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
        if (fetchedQuote.q != null && fetchedQuote.a != null) {
          final alreadyInHistory = quoteHistory
              .any((q) => q.q == fetchedQuote.q && q.a == fetchedQuote.a);
          if (!alreadyInHistory) {
            quoteHistory.insert(
                0, QuoteModel(q: fetchedQuote.q, a: fetchedQuote.a));
          }
        }
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
