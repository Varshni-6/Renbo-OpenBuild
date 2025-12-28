import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/journal_entry.dart';

class JournalDetailScreen extends StatefulWidget {
  final JournalEntry entry;

  const JournalDetailScreen({
    required this.entry,
    Key? key,
  }) : super(key: key);

  @override
  State<JournalDetailScreen> createState() => _JournalDetailScreenState();
}

class _JournalDetailScreenState extends State<JournalDetailScreen> {
  late final AudioPlayer _audioPlayer;
  bool _audioAvailable = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // Handle audio (local only for now)
    if (widget.entry.audioPath != null &&
        !widget.entry.audioPath!.startsWith('http') &&
        File(widget.entry.audioPath!).existsSync()) {
      _audioPlayer.setFilePath(widget.entry.audioPath!);
      _audioAvailable = true;
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // =========================
  // IMAGE HANDLER (LOCAL + CLOUD)
  // =========================
  Widget _buildImage(String? path) {
    if (path == null || path.isEmpty) {
      return const SizedBox.shrink();
    }

    // 🌐 Cloud image (Firebase Storage URL)
    if (path.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          path,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.broken_image, size: 48),
        ),
      );
    }

    // 📁 Local image fallback
    final file = File(path);
    if (!file.existsSync()) {
      return const Icon(Icons.broken_image, size: 48);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.file(file, fit: BoxFit.cover),
    );
  }

  // =========================
  // AUDIO PLAYER
  // =========================
  Widget _buildAudioPlayer() {
    if (!_audioAvailable) {
      return Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          "Audio file not found.",
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StreamBuilder<PlayerState>(
            stream: _audioPlayer.playerStateStream,
            builder: (context, snapshot) {
              final playing = snapshot.data?.playing ?? false;
              return IconButton(
                icon: Icon(playing ? Icons.pause : Icons.play_arrow),
                iconSize: 48,
                onPressed: playing ? _audioPlayer.pause : _audioPlayer.play,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.stop),
            iconSize: 48,
            onPressed: () {
              _audioPlayer.stop();
              _audioPlayer.seek(Duration.zero);
            },
          ),
        ],
      ),
    );
  }

  // =========================
  // UI
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Journal Detail")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.entry.imagePath != null)
              _buildImage(widget.entry.imagePath),
            const SizedBox(height: 16),
            Text(
              widget.entry.content.isEmpty
                  ? "No text content."
                  : widget.entry.content,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              "Mood: ${widget.entry.emotion ?? 'Not specified'}",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),
            Text(
              widget.entry.timestamp.toString(),
              style: const TextStyle(color: Colors.grey),
            ),
            if (widget.entry.audioPath != null) _buildAudioPlayer(),
          ],
        ),
      ),
    );
  }
}
