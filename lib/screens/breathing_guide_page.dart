import 'package:flutter/material.dart';
import 'dart:async';
import 'package:renbo/utils/theme.dart';

class BreathingGuidePage extends StatefulWidget {
  const BreathingGuidePage({super.key});

  @override
  _BreathingGuidePageState createState() => _BreathingGuidePageState();
}

class _BreathingGuidePageState extends State<BreathingGuidePage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  Timer? _breathingTimer; // Made nullable for safety
  int _countdown = 4;
  String _instruction = "Breathe in";
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  void _startBreathing() {
    setState(() {
      _isAnimating = true;
      _instruction = "Breathe in";
      _countdown = 4;
    });
    
    _animationController.forward(from: 0.0);

    _breathingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _countdown--;
        if (_countdown < 0) {
          if (_instruction == "Breathe in") {
            _instruction = "Hold";
            _countdown = 2;
            _animationController.stop(); 
          } else if (_instruction == "Hold") {
            _instruction = "Breathe out";
            _countdown = 6;
            _animationController.duration = const Duration(seconds: 6);
            _animationController.reverse(from: 1.0);
          } else if (_instruction == "Breathe out") {
            _instruction = "Breathe in";
            _countdown = 4;
            _animationController.duration = const Duration(seconds: 4);
            _animationController.forward(from: 0.0);
          }
        }
      });
    });
  }

  void _pauseBreathing() {
    _breathingTimer?.cancel();
    _animationController.stop();
    setState(() {
      _isAnimating = false;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _breathingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 🎨 Dynamic Theme Colors
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.titleLarge?.color;
    final primaryGreen = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // Adaptive background
      appBar: AppBar(
        title: Text(
          "Breathing Guide",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        // 🌓 Fixed Header: Background turns dark in dark mode
        backgroundColor: Colors.transparent, 
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _instruction,
              style: TextStyle(
                fontSize: 32.0, 
                fontWeight: FontWeight.bold,
                color: textColor, // Adaptive text
              ),
            ),
            const SizedBox(height: 100),
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                double scale = 1.0;
                if (_instruction == "Breathe in") {
                  scale = 1.0 + _animationController.value;
                } else if (_instruction == "Breathe out") {
                  scale = 2.0 - _animationController.value;
                } else {
                  scale = 2.0; 
                }
                
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      // 🌿 Using primary green with opacity for the "lung" effect
                      color: primaryGreen.withOpacity(isDark ? 0.3 : 0.5),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryGreen.withOpacity(0.2),
                          blurRadius: 30,
                          spreadRadius: 10,
                        )
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _countdown > 0 ? '$_countdown' : '',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: isDark ? theme.colorScheme.onSurface : Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 100),
            // Themed Start/Pause Button
            SizedBox(
              width: 250,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? theme.colorScheme.surface : AppTheme.espresso,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
                onPressed: _isAnimating ? _pauseBreathing : _startBreathing,
                child: Text(
                  _isAnimating ? 'Pause' : 'Start Breathing',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}