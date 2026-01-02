import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:renbo/api/gemini_service.dart';
import 'package:renbo/utils/theme.dart';
import 'package:renbo/widgets/chat_bubble.dart';
import 'package:renbo/services/journal_storage.dart';
import 'package:renbo/screens/saved_threads_screen.dart';
import 'hotlines_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GeminiService _geminiService = GeminiService();

  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  bool _speechEnabled = false;

  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _speechToText.stop();
    _flutterTts.stop();
    super.dispose();
  }

  void _initSpeech() async {
    try {
      _speechEnabled = await _speechToText.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Speech init failed: $e");
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<bool> _showEndSessionDialog() async {
    if (_messages.isEmpty) return true;

    final theme = Theme.of(context);

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface, // Themed Background
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("End Session?", style: TextStyle(color: theme.textTheme.titleLarge?.color)),
        content: Text("Would you like to save this thread?", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
        actions: [
          TextButton(
            onPressed: () {
              JournalStorage.deleteTemporaryChat();
              Navigator.pop(context, true);
            },
            child: const Text("Discard", style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () async {
              await JournalStorage.saveChatThread(
                messages: _messages,
                summary:
                    "Session: ${DateTime.now().day}/${DateTime.now().month} ${DateTime.now().hour}:${DateTime.now().minute}",
              );
              if (mounted) Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary),
            child: Text("Save Thread",
                style: TextStyle(color: theme.brightness == Brightness.dark ? AppTheme.darkBackground : Colors.white)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final classifiedResponse = await _geminiService.generateAndClassify(text);
      if (mounted) {
        setState(() {
          _messages.add({'sender': 'bot', 'text': classifiedResponse.response});
          _isLoading = false;
        });
        _scrollToBottom();
        if (classifiedResponse.isHarmful) _showHotlineSuggestion();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(
              {'sender': 'bot', 'text': 'I am having trouble connecting. 😞'});
          _isLoading = false;
        });
      }
    }
  }

  void _showHotlineSuggestion() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: Text("You’re Not Alone", style: TextStyle(color: theme.textTheme.titleLarge?.color)),
        content: Text("Would you like to see help hotlines?", style: TextStyle(color: theme.textTheme.bodyMedium?.color)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Not Now")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary),
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => HotlinesScreen()));
            },
            child: Text("View Hotlines",
                style: TextStyle(color: theme.brightness == Brightness.dark ? AppTheme.darkBackground : Colors.white)),
          ),
        ],
      ),
    );
  }

  void _toggleListening() async {
    if (!_speechEnabled) return;
    if (_isListening) {
      await _speechToText.stop();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      await _speechToText.listen(onResult: (result) {
        setState(() => _controller.text = result.recognizedWords);
        if (result.finalResult) {
          setState(() => _isListening = false);
          _sendMessage();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _showEndSessionDialog();
        if (shouldExit && mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Renbot Chat',
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
          iconTheme: IconThemeData(color: textColor),
          actions: [
            IconButton(
              icon: const Icon(Icons.history_edu_rounded),
              tooltip: 'Saved Threads',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SavedThreadsScreen()),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isSender = message['sender'] == 'user';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Row(
                      mainAxisAlignment: isSender
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        Flexible(
                          child: ChatBubble(
                              text: message['text']!, isSender: isSender),
                        ),
                        if (!isSender)
                          IconButton(
                            icon: Icon(Icons.volume_up,
                                size: 18, color: theme.colorScheme.secondary.withOpacity(0.6)),
                            onPressed: () =>
                                _flutterTts.speak(message['text']!),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            if (_isLoading)
              const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator()),
            _buildMessageComposer(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageComposer() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(12),
      // ☕ Switches to darkSurface (Coffee Bean) in dark mode
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                // 🎨 Explicitly set text color to ensure visibility
                style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                decoration: InputDecoration(
                  hintText: _isListening ? "Listening..." : "Message...",
                  hintStyle: TextStyle(color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5)),
                  filled: true,
                  // 🌙 Bubbles contrast background
                  fillColor: isDark ? AppTheme.darkBackground : AppTheme.oatMilk,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none),
                ),
              ),
            ),
            IconButton(
              icon: Icon(_isListening ? Icons.mic : Icons.mic_none,
                  color: _isListening ? Colors.red : theme.colorScheme.primary),
              onPressed: _toggleListening,
            ),
            IconButton(
              icon: Icon(Icons.send, color: theme.colorScheme.primary),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }
}