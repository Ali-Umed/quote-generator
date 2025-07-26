import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ErrorState extends StatelessWidget {
  final String? errorMessage;
  final Color accent;
  final VoidCallback onRetry;
  final bool isDarkMode;

  const ErrorState({
    super.key,
    required this.errorMessage,
    required this.accent,
    required this.onRetry,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
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
          onPressed: onRetry,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: const Text(
            "Retry",
            style: TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}
