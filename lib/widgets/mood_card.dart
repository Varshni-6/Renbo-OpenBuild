import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:renbo/utils/theme.dart';

class MoodCard extends StatelessWidget {
  final String title;
  final String content;
  final String image;

  const MoodCard({
    super.key,
    required this.title,
    required this.content,
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Check current theme brightness
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 🎨 Logic for ultra-clear text
    // If dark mode: pure white. If light mode: your standard espresso/gray.
    final Color titleColor = isDark ? Colors.white : AppTheme.espresso;
    final Color contentColor = isDark ? Colors.white.withOpacity(0.9) : AppTheme.darkGray;

    return Card(
      // Ensure the card background is also adaptive
      color: Colors.transparent, 
      elevation: 0,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Lottie.asset(image, width: 80, height: 80),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14, // Slightly smaller for "Thought of the day" label
                      fontWeight: FontWeight.bold,
                      color: titleColor, // High visibility
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.3,
                      color: contentColor, // High visibility
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}