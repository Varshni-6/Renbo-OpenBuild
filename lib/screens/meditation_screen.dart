import 'package:flutter/material.dart';
import 'package:renbo/utils/theme.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'white_noise_synthesizer.dart';
import 'breathing_guide_page.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen>
    with SingleTickerProviderStateMixin {
  final player = AudioPlayer();
  Timer? _meditationTimer;

  Duration _meditationTime = Duration.zero;
  bool _meditationTimerIsRunning = false;

  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  final List<Map<String, String>> _tracks = [
    {
      'title': 'Zen Meditation',
      'artist': 'Inner Peace',
      'path': 'audio/zen.mp3',
    },
    {
      'title': 'Soul Music',
      'artist': 'Nature Sounds',
      'path': 'audio/soul.mp3',
    },
    {
      'title': 'Rain Melody',
      'artist': 'Relaxing Rain Rhythms',
      'path': 'audio/rain.mp3',
    },
  ];

  int? _selectedTrackIndex;

  @override
  void initState() {
    super.initState();
    player.onDurationChanged.listen((d) {
      if (mounted) setState(() => duration = d);
    });
    player.onPositionChanged.listen((p) {
      if (mounted) setState(() => position = p);
    });
    player.onPlayerComplete.listen((event) {
      if (mounted) {
        setState(() {
          isPlaying = false;
          position = Duration.zero;
        });
      }
    });
  }

  void _startMeditationTimer() {
    _meditationTimerIsRunning = true;
    _meditationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _meditationTime += const Duration(seconds: 1);
        });
      }
    });
  }

  void _pauseMeditationTimer() {
    if (_meditationTimerIsRunning) {
      _meditationTimerIsRunning = false;
      _meditationTimer?.cancel();
      if (mounted) setState(() {});
    }
  }

  void _resetMeditationTimer() {
    _meditationTimer?.cancel();
    setState(() {
      _meditationTime = Duration.zero;
      _meditationTimerIsRunning = false;
    });
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    player.dispose();
    _meditationTimer?.cancel();
    super.dispose();
  }

  void _selectTrack(int index) async {
    if (_selectedTrackIndex == index) {
      _togglePlayPause();
      return;
    }

    await player.stop();
    setState(() {
      _selectedTrackIndex = index;
      isPlaying = true;
      position = Duration.zero;
      duration = Duration.zero;
    });

    final selectedTrackPath = _tracks[index]['path']!;
    await player.setSource(AssetSource(selectedTrackPath));
    await player.setReleaseMode(ReleaseMode.loop);
    await player.resume();
  }

  void _togglePlayPause() async {
    if (_selectedTrackIndex == null) return;
    if (isPlaying) {
      await player.pause();
    } else {
      await player.resume();
    }
    setState(() => isPlaying = !isPlaying);
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          'Meditation',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionChip(context, 'Breathing', Icons.self_improvement, () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BreathingGuidePage()));
                }),
                _buildActionChip(context, 'White Noise', Icons.graphic_eq, () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WhiteNoiseSynthesizerScreen()));
                }),
              ],
            ),
            const SizedBox(height: 30),

            // Timer Card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Text(
                    _formatDuration(_meditationTime),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 2,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 🟢 Start/Pause Button (No "icon:" parameter used)
                      ElevatedButton(
                        onPressed: _meditationTimerIsRunning ? _pauseMeditationTimer : _startMeditationTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          foregroundColor: isDark ? AppTheme.darkBackground : Colors.white,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_meditationTimerIsRunning ? Icons.pause : Icons.play_arrow),
                            const SizedBox(width: 8),
                            Text(_meditationTimerIsRunning ? 'Pause' : 'Start'),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // 🔄 Reset Button (No "icon:" parameter used)
                      ElevatedButton(
                        onPressed: _resetMeditationTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.white10 : AppTheme.espresso.withOpacity(0.1),
                          foregroundColor: textColor,
                          shape: const StadiumBorder(),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          elevation: 0,
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.refresh, size: 20),
                            SizedBox(width: 8),
                            Text('Reset'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            Text(
              'Choose a track:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: _tracks.length,
                itemBuilder: (context, index) => _buildTrackCard(index),
              ),
            ),

            if (_selectedTrackIndex != null) _buildMiniPlayer(theme, primaryGreen),
          ],
        ),
      ),
    );
  }

  Widget _buildActionChip(BuildContext context, String label, IconData iconData, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ActionChip(
      onPressed: onTap,
      avatar: Icon(iconData, size: 18, color: Theme.of(context).colorScheme.primary),
      label: Text(label),
      backgroundColor: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
      shape: StadiumBorder(side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.2))),
    );
  }

  Widget _buildMiniPlayer(ThemeData theme, Color primaryGreen) {
    return Column(
      children: [
        Slider(
          min: 0,
          max: duration.inSeconds.toDouble(),
          value: position.inSeconds.toDouble(),
          onChanged: (value) async => await player.seek(Duration(seconds: value.toInt())),
          activeColor: primaryGreen,
          inactiveColor: primaryGreen.withOpacity(0.2),
        ),
        IconButton(
          onPressed: _togglePlayPause,
          iconSize: 64,
          color: primaryGreen,
          icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill),
        ),
      ],
    );
  }

  Widget _buildTrackCard(int index) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final track = _tracks[index];
    final isSelected = _selectedTrackIndex == index;
    final textColor = theme.textTheme.bodyLarge?.color;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: isSelected ? theme.colorScheme.primary.withOpacity(isDark ? 0.15 : 0.1) : theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isSelected ? theme.colorScheme.primary : Colors.transparent),
      ),
      child: InkWell(
        onTap: () => _selectTrack(index),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? theme.colorScheme.primary : theme.scaffoldBackgroundColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSelected ? Icons.graphic_eq : Icons.music_note_outlined,
                  color: isSelected ? (isDark ? AppTheme.darkBackground : Colors.white) : textColor?.withOpacity(0.5),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(track['title']!, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                    Text(track['artist']!, style: TextStyle(fontSize: 12, color: textColor?.withOpacity(0.6))),
                  ],
                ),
              ),
              if (isSelected && isPlaying) Icon(Icons.volume_up, color: theme.colorScheme.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}