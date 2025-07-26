import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:quote_app/api.dart';
import 'package:quote_app/quote_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool inProgress = false;
  QuoteModel? quote;
  String? errorMessage;
  bool isDarkMode = true;

  @override
  void initState() {
    super.initState();
    _fetchQuote();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF181A20) : const Color(0xFFF6F8FB),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [Color(0xFF232526), Color(0xFF414345), Color(0xFF141E30)]
                : [Color(0xFFe0eafc), Color(0xFFcfdef3), Color(0xFFf8ffae)],
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
                          color: isDarkMode
                              ? Colors.amberAccent
                              : Colors.blueAccent,
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
                            shadows: isDarkMode
                                ? [
                                    Shadow(
                                        color: Colors.black54,
                                        blurRadius: 4,
                                        offset: Offset(1, 2))
                                  ]
                                : [
                                    Shadow(
                                        color: Colors.white70,
                                        blurRadius: 2,
                                        offset: Offset(1, 1))
                                  ],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.white10 : Colors.black12,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: isDarkMode
                                ? Colors.black26
                                : Colors.grey.withOpacity(0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          isDarkMode
                              ? CupertinoIcons.sun_max_fill
                              : CupertinoIcons.moon_fill,
                          color: isDarkMode
                              ? Colors.amberAccent
                              : Colors.blueAccent,
                        ),
                        onPressed: _toggleTheme,
                        tooltip: isDarkMode
                            ? "Switch to Light Mode"
                            : "Switch to Dark Mode",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: inProgress
                        ? Center(
                            child: CupertinoActivityIndicator(
                              radius: 18,
                              color: isDarkMode
                                  ? Colors.amberAccent
                                  : Colors.blueAccent,
                            ),
                          )
                        : errorMessage != null
                            ? _buildErrorState()
                            : _buildQuoteCard(),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: isDarkMode
                            ? Colors.amberAccent.withOpacity(0.18)
                            : Colors.blueAccent.withOpacity(0.13),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: CupertinoButton(
                    color: isDarkMode ? Colors.amberAccent : Colors.blueAccent,
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

  Widget _buildQuoteCard() {
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
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.amberAccent.withOpacity(0.13)
                  : Colors.blueAccent.withOpacity(0.10),
              blurRadius: 18,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: isDarkMode
                ? Colors.amberAccent.withOpacity(0.18)
                : Colors.blueAccent.withOpacity(0.13),
            width: 1.2,
          ),
        ),
        child: Column(
          key: ValueKey(quote!.q),
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.format_quote_rounded,
              color: isDarkMode ? Colors.amberAccent : Colors.blueAccent,
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
                shadows: isDarkMode
                    ? [
                        Shadow(
                            color: Colors.black54,
                            blurRadius: 4,
                            offset: Offset(1, 2))
                      ]
                    : [
                        Shadow(
                            color: Colors.white70,
                            blurRadius: 2,
                            offset: Offset(1, 1))
                      ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              "- ${quote!.a}",
              style: TextStyle(
                fontSize: 15,
                color: isDarkMode
                    ? Colors.amberAccent.withOpacity(0.85)
                    : Colors.blueAccent.withOpacity(0.85),
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline,
          color: Colors.redAccent,
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
          color: Colors.redAccent,
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
