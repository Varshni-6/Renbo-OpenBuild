import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:renbo/providers/theme_provider.dart';
import 'package:renbo/services/journal_storage.dart';
import 'package:renbo/api/gemini_service.dart';
import 'package:renbo/utils/theme.dart';

// Screen Imports
import 'package:renbo/screens/chat_screen.dart';
import 'package:renbo/screens/meditation_screen.dart';
import 'package:renbo/screens/hotlines_screen.dart';
import 'package:renbo/screens/stress_tap_game.dart'; 
import 'package:renbo/screens/settings_page.dart';
import 'package:renbo/screens/gratitude_bubbles_screen.dart';
import 'package:renbo/screens/calendar_screen.dart';
import 'package:renbo/screens/capsule_vault_screen.dart';
import 'package:renbo/screens/non_verbal_screen.dart';
import 'package:renbo/screens/mood_pulse_screen.dart';

// Widget Imports
import 'package:renbo/widgets/mood_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = "User";
  String _thoughtOfTheDay = "Loading a new thought...";
  final GeminiService _geminiService = GeminiService();

  bool _isMigrating = false;
  final PageController _aftercareController = PageController();
  int _currentAftercarePage = 0;

  @override
  void initState() {
    super.initState();
    _fetchThoughtOfTheDay();
    _loadUserData();
  }

  @override
  void dispose() {
    _aftercareController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    FirebaseAuth.instance.authStateChanges().listen((user) async {
      if (mounted && user != null) {
        setState(() {
          _userName = user.displayName ?? "User";
        });

        if (!_isMigrating) {
          _isMigrating = true;
          await _runMigration();
        }
      }
    });
  }

  Future<void> _runMigration() async {
    try {
      await JournalStorage.migrateHiveToFirestore();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cloud Sync Complete"),
            duration: Duration(seconds: 2),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
      }
    } catch (e) {
      debugPrint("Migration failed: $e");
    }
  }

  void _fetchThoughtOfTheDay() async {
    try {
      final thought = await _geminiService.generateThoughtOfTheDay();
      if (mounted) {
        setState(() => _thoughtOfTheDay = thought);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _thoughtOfTheDay =
            "The best way to predict the future is to create it.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = theme.textTheme.bodyLarge?.color;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Renbo',
          style: TextStyle(
            color: theme.appBarTheme.titleTextStyle?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              return IconButton(
                icon: Icon(themeProvider.isDarkMode
                    ? Icons.light_mode_rounded
                    : Icons.dark_mode_rounded),
                onPressed: () {
                  themeProvider.toggleTheme(!themeProvider.isDarkMode);
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const SettingsPage())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $_userName!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),

              // ✨ NEW BRIGHT THOUGHT OF THE DAY BLOCK
              _buildBrightThoughtCard(isDark, textColor),

              const SizedBox(height: 24),

              Text(
                'Self-Care Check-in',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor?.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: 12),
              _buildAftercareSection(isDark, textColor),

              const SizedBox(height: 24),
              _buildMainButtons(context, theme),
              const SizedBox(height: 24),

              Center(
                child: SizedBox(
                  height: 180,
                  child: Lottie.asset('assets/lottie/help.json'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- HELPER FOR BRIGHT THOUGHT CARD ---
  Widget _buildBrightThoughtCard(bool isDark, Color? textColor) {
    // 🎨 Using your primary Matcha color for the "glow" effect
    final Color baseColor = AppTheme.matchaGreen;
    final Color cardBg = isDark ? baseColor.withOpacity(0.15) : baseColor.withOpacity(0.1);
    final Color cardBorder = isDark ? baseColor.withOpacity(0.5) : baseColor.withOpacity(0.4);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: cardBorder, width: 1.5),
      ),
      child: MoodCard(
        title: 'Thought of the day',
        content: _thoughtOfTheDay,
        image: 'assets/lottie/axolotl.json',
      ),
    );
  }

  Widget _buildAftercareSection(bool isDark, Color? textColor) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView(
            controller: _aftercareController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (int index) =>
                setState(() => _currentAftercarePage = index),
            children: [
              _buildAftercareItem(
                isDark: isDark,
                textColor: textColor,
                icon: Icons.local_drink_rounded,
                label: 'Hydrate',
                baseColor: Colors.blue,
                subtitle: 'Water is fuel for resilience. Even a small sip can help clear the fog.',
              ),
              _buildAftercareItem(
                isDark: isDark,
                textColor: textColor,
                icon: Icons.restaurant_rounded,
                label: 'Nourish',
                baseColor: Colors.orange,
                subtitle: 'Your body needs energy to process big feelings. A gentle snack is self-love.',
              ),
              _buildAftercareItem(
                isDark: isDark,
                textColor: textColor,
                icon: Icons.bedtime_rounded,
                label: 'Rest',
                baseColor: Colors.purple,
                subtitle: 'It is okay to hit the pause button. Recovery requires quiet moments.',
              ),
              _buildAftercareItem(
                isDark: isDark,
                textColor: textColor,
                icon: Icons.air_rounded,
                label: 'Breathe',
                baseColor: Colors.green,
                subtitle: 'Take one deep breath, just for you. Let the air ground you.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) => _buildDotIndicator(index)),
        ),
      ],
    );
  }

  Widget _buildDotIndicator(int index) {
    bool isActive = _currentAftercarePage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.primaryColor
            : Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildAftercareItem({
    required bool isDark,
    required Color? textColor,
    required IconData icon,
    required String label,
    required Color baseColor,
    required String subtitle,
  }) {
    final Color iconColor = isDark 
        ? Color.lerp(baseColor, Colors.white, 0.4)! 
        : Color.lerp(baseColor, Colors.black, 0.4)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: baseColor.withOpacity(isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: baseColor.withOpacity(isDark ? 0.4 : 0.3), 
          width: 1.5
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: iconColor,
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: textColor?.withOpacity(0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainButtons(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        _buttonRow(context, theme, Icons.edit_note, 'Journal', const CalendarScreen(),
            Icons.chat_bubble_outline, 'Chat with Ren', const ChatScreen()),
        const SizedBox(height: 16),
        _buttonRow(
            context,
            theme,
            Icons.headphones_outlined,
            'Meditation',
            const MeditationScreen(),
            Icons.videogame_asset_outlined,
            'Game',
            const RelaxGame()),
        const SizedBox(height: 16),
        _buttonRow(
            context,
            theme,
            Icons.bubble_chart,
            'Gratitude',
            const GratitudeBubblesScreen(),
            Icons.auto_awesome_motion,
            'Vault',
            const CapsuleVaultScreen()),
        const SizedBox(height: 16),
        _buttonRow(
            context,
            theme,
            Icons.fingerprint,
            'Zen Space',
            const NonVerbalSessionScreen(),
            Icons.vibration,
            'Mood Pulse',
            const MoodPulseScreen()),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildButton(
              context,
              theme,
              icon: Icons.phone_in_talk,
              label: 'Hotlines',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => HotlinesScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buttonRow(
    BuildContext context,
    ThemeData theme,
    IconData i1,
    String l1,
    Widget s1,
    IconData i2,
    String l2,
    Widget s2,
  ) {
    return Row(
      children: [
        _buildButton(context, theme,
            icon: i1,
            label: l1,
            onTap: () =>
                Navigator.push(context, MaterialPageRoute(builder: (_) => s1))),
        const SizedBox(width: 16),
        _buildButton(context, theme,
            icon: i2,
            label: l2,
            onTap: () =>
                Navigator.push(context, MaterialPageRoute(builder: (_) => s2))),
      ],
    );
  }

  Widget _buildButton(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Card(
        color: theme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20.0),
            child: Column(
              children: [
                Icon(icon, size: 40, color: theme.colorScheme.primary),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}