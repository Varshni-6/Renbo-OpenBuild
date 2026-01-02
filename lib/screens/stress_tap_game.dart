import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:renbo/utils/theme.dart';

class RelaxGame extends StatefulWidget {
  const RelaxGame({super.key});

  @override
  State<RelaxGame> createState() => _RelaxGameState();
}

class _RelaxGameState extends State<RelaxGame> {
  double posX = 150;
  double posY = 150;
  final Random _random = Random();

  void _moveBall() {
    setState(() {
      // Use MediaQuery to get screen bounds minus the ball size (80)
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      
      posX = _random.nextDouble() * (screenWidth - 80);
      posY = _random.nextDouble() * (screenHeight - 200); // 200 to keep away from top/bottom bars
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 Dynamic Theme Colors
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.titleLarge?.color;
    final primaryGreen = theme.colorScheme.primary;

    return Scaffold(
      // 🌓 Dynamic Background - Midnight Mocha or Oat Milk
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Instructions in the center
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Tap the ball to move it.',
                  style: TextStyle(
                    fontSize: 22, 
                    fontWeight: FontWeight.w600,
                    color: textColor?.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Just relax and enjoy.',
                  style: TextStyle(
                    fontSize: 16, 
                    color: textColor?.withOpacity(0.4),
                  ),
                ),
              ],
            ),
          ),

          // 🏀 THE BALL (Reverted to standard Positioned for teleporting)
          Positioned(
            top: posY,
            left: posX,
            child: GestureDetector(
              onTap: _moveBall,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: primaryGreen, 
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primaryGreen.withOpacity(isDark ? 0.4 : 0.2),
                      blurRadius: 20,
                      spreadRadius: 5,
                    )
                  ],
                  // Added a subtle gradient to make it look 3D and high-quality
                  gradient: RadialGradient(
                    colors: [
                      primaryGreen.withOpacity(0.8),
                      primaryGreen,
                    ],
                    center: const Alignment(-0.3, -0.3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}