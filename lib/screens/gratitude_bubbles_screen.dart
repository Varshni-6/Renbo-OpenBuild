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

  // 🔥 Firestore version: Just push to DB, StreamBuilder handles the rest
  void _addGratitude() async {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      await GratitudeStorage.addGratitude(text);
      _controller.clear();

      // Trigger confetti animation
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Add a Gratitude',
          style: TextStyle(color: AppTheme.darkGray),
        ),
        content: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'What are you grateful for today?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
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
            child: const Text('Cancel',
                style: TextStyle(color: AppTheme.mediumGray)),
          ),
          ElevatedButton(
            onPressed: () {
              _addGratitude();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
            ),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Gratitude Bubbles',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGratitudeDialog,
        backgroundColor: const Color.fromARGB(255, 129, 167, 199),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Stack(
        children: [
          // 🔥 REAL-TIME STREAM: Listens to Firestore changes
          StreamBuilder<List<Gratitude>>(
            stream: GratitudeStorage.getGratitudeStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'No gratitudes yet. Add one to see it float!',
                    style: TextStyle(fontSize: 16, color: AppTheme.mediumGray),
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
                  // Generate stable random positions based on the document ID
                  // (using seed so bubbles don't jump around on every refresh)
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
                      onUpdated: () {}, // Stream handles updates now
                    ),
                  );
                }).toList(),
              );
            },
          ),

          // Confetti overlay
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
