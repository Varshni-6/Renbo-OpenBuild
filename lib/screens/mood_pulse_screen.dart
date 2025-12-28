import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:renbo/utils/theme.dart';

class MoodPulseScreen extends StatefulWidget {
  const MoodPulseScreen({super.key});

  @override
  State<MoodPulseScreen> createState() => _MoodPulseScreenState();
}

class _MoodPulseScreenState extends State<MoodPulseScreen> {
  double _intensity = 0.5; // Arousal: Soft to Intense
  double _valence = 0.5; // Sentiment: Negative to Positive
  double _clarity = 0.5; // Cognitive: Foggy to Clear

  String _aiFeedback = "Move the sliders to show how you're feeling right now.";
  String _comfortAdvice = "We can take it one step at a time.";

  // Dynamic feedback based on Intensity, Valence, and Clarity
  void _updateFeedback() {
    setState(() {
      // 1. DISTRESSED / OVERWHELMED (Negative + High Intensity)
      if (_valence < 0.4 && _intensity > 0.6) {
        if (_clarity < 0.4) {
          _aiFeedback =
              "Everything feels loud and blurry right now. It's high-intensity chaos.";
          _comfortAdvice =
              "Advice: Your only job right now is to breathe. Try the 5-4-3-2-1 grounding technique: name 5 things you see, 4 things you can touch.";
        } else {
          _aiFeedback =
              "You're feeling a sharp, clear sense of distress or frustration.";
          _comfortAdvice =
              "Advice: This energy needs an exit. Try a 'cold water shock' on your face or a quick, vigorous movement to reset your nervous system.";
        }
      }
      // 2. HEAVY / NUMB (Negative + Low Intensity)
      else if (_valence < 0.4 && _intensity <= 0.6) {
        if (_clarity < 0.4) {
          _aiFeedback =
              "You're carrying a heavy, foggy weight. It feels hard to even identify the 'why'.";
          _comfortAdvice =
              "Advice: Don't fight the fog. Just focus on small comforts—a warm drink, a soft blanket, or dimming the lights.";
        } else {
          _aiFeedback =
              "There is a quiet, clear sadness or disappointment present.";
          _comfortAdvice =
              "Advice: It's okay to sit with this. Try writing down just three words that describe this weight. Validating it helps it pass.";
        }
      }
      // 3. SCATTERED / TIRED (Neutral + Foggy)
      else if (_valence >= 0.4 && _valence <= 0.6 && _clarity < 0.4) {
        _aiFeedback =
            "You're in a bit of a mental haze. Things feel a bit disconnected.";
        _comfortAdvice =
            "Advice: Your brain might be overstimulated. Try a 10-minute 'digital fast'—put the phone away and look at something distant out a window.";
      }
      // 4. PEACEFUL / FOCUSED (Positive + Clear)
      else if (_valence > 0.6 && _clarity > 0.6) {
        _aiFeedback = "You're in a beautiful state of flow and clarity.";
        _comfortAdvice =
            "Advice: This is a great time for creativity or connection. Carry this light with you into your next task.";
      }
      // 5. CALM / DREAMY (Positive + Foggy)
      else if (_valence > 0.6 && _clarity <= 0.6) {
        _aiFeedback = "You're feeling a gentle, dreamy kind of happiness.";
        _comfortAdvice =
            "Advice: Let yourself daydream. You don't need to be productive right now. Just enjoy the warmth.";
      }
      // DEFAULT
      else {
        _aiFeedback = "You're finding your balance in a steady, middle space.";
        _comfortAdvice =
            "Advice: Keep checking in with your body. Notice if your shoulders are tense and let them drop.";
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title:
            const Text("Mood Pulse", style: TextStyle(fontFamily: 'Poppins')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Dynamic Visual Indicator (The Pulse)
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.5, end: _intensity),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, child) {
                  return Container(
                    height: 120 + (value * 80),
                    width: 120 + (value * 80),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _getMoodColor(_valence),
                          _getMoodColor(_valence).withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _getMoodColor(_valence).withOpacity(0.4),
                          // Blur is now tied to Clarity: Foggy (low clarity) = more blur
                          blurRadius: 20 + ((1 - _clarity) * 40),
                          spreadRadius: 5 + (value * 10),
                        )
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        _valence < 0.4
                            ? Icons.cloud_queue
                            : (_valence > 0.6
                                ? Icons.wb_sunny
                                : Icons.favorite),
                        size: 30 + (value * 30),
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),

              // AI Analysis Block
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Container(
                  key: ValueKey(_aiFeedback),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _aiFeedback,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkGray,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _comfortAdvice,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: Colors.blueGrey[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // 1. CLARITY SLIDER (Foggy to Clear)
              _buildSliderLabel("Foggy", "Clear"),
              _buildSlider(
                value: _clarity,
                onChanged: (val) => setState(() {
                  _clarity = val;
                  _updateFeedback();
                }),
                gradient: const [Colors.blueGrey, Colors.cyanAccent],
              ),
              const SizedBox(height: 25),

              // 2. VALENCE SLIDER (Negative to Positive)
              _buildSliderLabel("Negative", "Positive"),
              _buildSlider(
                value: _valence,
                onChanged: (val) => setState(() {
                  _valence = val;
                  _updateFeedback();
                }),
                gradient: const [
                  Colors.blueGrey,
                  Colors.blueAccent,
                  Colors.greenAccent,
                  Colors.yellowAccent
                ],
              ),
              const SizedBox(height: 25),

              // 3. INTENSITY SLIDER (Soft to Intense)
              _buildSliderLabel("Soft Energy", "High Intensity"),
              _buildSlider(
                value: _intensity,
                onChanged: (val) => setState(() {
                  _intensity = val;
                  _updateFeedback();
                }),
                gradient: [
                  _getMoodColor(_valence).withOpacity(0.5),
                  _getMoodColor(_valence)
                ],
              ),

              const SizedBox(height: 40),

              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  side: const BorderSide(color: Color(0xFF8E97FD)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: const Text("I feel heard",
                    style: TextStyle(color: Color(0xFF8E97FD))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliderLabel(String left, String right) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(left,
            style: const TextStyle(
                color: Colors.blueGrey,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
        Text(right,
            style: const TextStyle(
                color: Colors.blueGrey,
                fontSize: 12,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildSlider({
    required double value,
    required ValueChanged<double> onChanged,
    required List<Color> gradient,
  }) {
    return Container(
      height: 12,
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(colors: gradient),
      ),
      child: SliderTheme(
        data: SliderTheme.of(context).copyWith(
          trackHeight: 0,
          thumbColor: Colors.white,
          overlayColor: Colors.white.withOpacity(0.2),
          thumbShape:
              const RoundSliderThumbShape(enabledThumbRadius: 12, elevation: 3),
        ),
        child: Slider(
          value: value,
          onChanged: (val) {
            HapticFeedback.selectionClick();
            onChanged(val);
          },
        ),
      ),
    );
  }

  Color _getMoodColor(double value) {
    if (value < 0.3) return Colors.blueGrey;
    if (value < 0.5) return Colors.blueAccent;
    if (value < 0.7) return Colors.greenAccent;
    return Colors.orangeAccent;
  }
}
