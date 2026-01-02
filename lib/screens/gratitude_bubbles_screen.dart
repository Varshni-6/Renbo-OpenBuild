import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:renbo/models/gratitude.dart';
import 'package:renbo/services/gratitude_storage.dart';
import 'package:renbo/utils/theme.dart';
import 'package:renbo/widgets/gratitude_bubbles_widget.dart';

class GratitudeBubblesScreen extends StatefulWidget {
  const GratitudeBubblesScreen({super.key});

  @override
  State<GratitudeBubblesScreen> createState() => _GratitudeBubblesScreenState();
}

class _GratitudeBubblesScreenState extends State<GratitudeBubblesScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late final AnimationController _animationController;
  final Random _random = Random();
  bool _showConfetti = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _addGratitude() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      await GratitudeStorage.addGratitude(text);
      _controller.clear();

      setState(() {
        _showConfetti = true;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showConfetti = false;
          });
        }
      });
    }
  }

  void _showAddGratitudeDialog() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // 🌓 Themed Dialog Background
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Add a Gratitude',
          style: TextStyle(color: theme.textTheme.titleLarge?.color),
        ),
        content: TextField(
          controller: _controller,
          autofocus: true,
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
          decoration: InputDecoration(
            hintText: 'What are you grateful for today?',
            hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
            filled: true,
            fillColor: isDark ? AppTheme.darkBackground : AppTheme.oatMilk,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (_) {
            _addGratitude();
            Navigator.of(context).pop();
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel',
                style: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7))),
          ),
          ElevatedButton(
            onPressed: () {
              _addGratitude();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: isDark ? AppTheme.darkBackground : Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text('Add', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color;

    return Scaffold(
      // 🌓 Dynamic Background
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Gratitude Bubbles',
            style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGratitudeDialog,
        // Using Primary Color for the FAB to keep it high-contrast but themed
        backgroundColor: theme.colorScheme.primary,
        child: Icon(Icons.add, color: isDark ? AppTheme.darkBackground : Colors.white),
      ),
      body: Stack(
        children: [
          StreamBuilder<List<Gratitude>>(
            stream: GratitudeStorage.getGratitudeStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Text(
                    'No gratitudes yet. Add one to see it float!',
                    style: TextStyle(fontSize: 16, color: textColor?.withOpacity(0.5)),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              final gratitudes = snapshot.data!;
              final screenWidth = MediaQuery.of(context).size.width;
              final screenHeight = MediaQuery.of(context).size.height;
              const double size = 60.0;

              return Stack(
                children: gratitudes.map((gratitude) {
                  final seed = gratitude.id.hashCode;
                  final random = Random(seed);

                  final double xOffset =
                      random.nextDouble() * (screenWidth - size);
                  final double yOffset =
                      random.nextDouble() * (screenHeight * 0.7 - size);

                  return Positioned(
                    left: xOffset,
                    top: yOffset,
                    child: GratitudeBubble(
                      gratitude: gratitude,
                      bubbleSize: size,
                      animation: _animationController,
                      xOffset: xOffset,
                      yOffset: yOffset,
                      onUpdated: () {}, 
                    ),
                  );
                }).toList(),
              );
            },
          ),

          if (_showConfetti)
            Center(
              child: Lottie.asset(
                'assets/lottie/confetti.json',
                repeat: false,
              ),
            ),
        ],
      ),
    );
  }
}