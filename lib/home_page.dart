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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [Color(0xFF141E30), Color(0xFF243B55)]
                : [Color(0xFFE0EAFC), Color(0xFFCFDEF3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "✨ Daily Inspiration",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black87,
                      letterSpacing: 1.0,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      isDarkMode
                          ? CupertinoIcons.sun_max_fill
                          : CupertinoIcons.moon_fill,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                    onPressed: _toggleTheme,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: inProgress
                      ? const Center(
                          child: CupertinoActivityIndicator(
                            radius: 15,
                            color: Colors.white,
                          ),
                        )
                      : errorMessage != null
                          ? _buildErrorState()
                          : _buildQuoteCard(),
                ),
              ),
              CupertinoButton(
                color: const Color.fromARGB(255, 47, 134, 148),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                onPressed: _fetchQuote,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      CupertinoIcons.refresh,
                      size: 16,
                      color: Colors.white,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "New Quote",
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
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
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: isDarkMode
              ? Colors.white.withOpacity(0.1)
              : const Color.fromARGB(255, 190, 220, 232).withOpacity(0.9),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.2)
                  : Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 3,
            ),
          ],
        ),
        child: Column(
          key: ValueKey(quote!.q),
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              quote!.q as String,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                height: 1.4,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "- ${quote!.a}",
              style: TextStyle(
                fontSize: 14,
                color: isDarkMode ? Colors.white60 : Colors.black54,
                fontStyle: FontStyle.italic,
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
