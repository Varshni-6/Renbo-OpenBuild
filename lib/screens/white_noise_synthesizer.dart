import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:renbo/utils/theme.dart';

class WhiteNoiseSynthesizerScreen extends StatefulWidget {
  const WhiteNoiseSynthesizerScreen({super.key});

  @override
  _WhiteNoiseSynthesizerScreenState createState() =>
      _WhiteNoiseSynthesizerScreenState();
}

class _WhiteNoiseSynthesizerScreenState
    extends State<WhiteNoiseSynthesizerScreen> {
  final List<String> _noiseFrequencies = [
    'white',
    'pink',
    'brown',
  ];

  final Map<String, AudioPlayer> _players = {};
  final Map<String, double> _volumes = {
    'white': 0.0,
    'pink': 0.0,
    'brown': 0.0,
  };

  @override
  void initState() {
    super.initState();
    _initPlayers();
  }

  void _initPlayers() async {
    for (var frequency in _noiseFrequencies) {
      final player = AudioPlayer();
      await player.setSource(AssetSource('audio/${frequency}_noise.mp3'));
      await player.setReleaseMode(ReleaseMode.loop);
      _players[frequency] = player;
    }
  }

  @override
  void dispose() {
    for (var player in _players.values) {
      player.dispose();
    }
    super.dispose();
  }

  void _updateVolume(String frequency, double newVolume) async {
    setState(() {
      _volumes[frequency] = newVolume;
    });

    final player = _players[frequency];
    if (player != null) {
      await player.setVolume(newVolume);
      if (newVolume > 0 && player.state != PlayerState.playing) {
        await player.resume();
      } else if (newVolume == 0 && player.state == PlayerState.playing) {
        await player.pause();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.titleLarge?.color;
    final primaryGreen = theme.colorScheme.primary;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'White Noise Synthesizer',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Mix your desired frequency:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _noiseFrequencies.length,
                itemBuilder: (context, index) {
                  final frequency = _noiseFrequencies[index];
                  return _buildVolumeSlider(frequency, textColor, primaryGreen);
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? theme.colorScheme.surface : AppTheme.espresso,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeSlider(String frequency, Color? textColor, Color primaryGreen) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${frequency.toUpperCase()} Noise',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            // Updated SliderTheme without the problematic line
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: primaryGreen,
                inactiveTrackColor: primaryGreen.withOpacity(0.2),
                thumbColor: primaryGreen,
                overlayColor: primaryGreen.withOpacity(0.1),
                showValueIndicator: ShowValueIndicator.always,
                // The value indicator will now use the default primary color
                valueIndicatorTextStyle: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark 
                    ? AppTheme.darkBackground 
                    : Colors.white,
                ),
              ),
              child: Slider(
                value: _volumes[frequency]!,
                min: 0.0,
                max: 1.0,
                divisions: 10,
                label: _volumes[frequency]!.toStringAsFixed(1),
                onChanged: (value) => _updateVolume(frequency, value),
              ),
            ),
          ],
        ),
      ),
    );
  }
}