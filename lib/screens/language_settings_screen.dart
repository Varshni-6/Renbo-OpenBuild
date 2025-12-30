import 'package:flutter/material.dart';
import '../services/settings_service.dart';
import '../utils/theme.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  final SettingsService _settingsService = SettingsService();
  String _selectedLanguage = "English";
  bool _isSaving = false;

  final List<Map<String, String>> _languages = [
    {"name": "English", "code": "en"},
    {"name": "Hindi (हिन्दी)", "code": "hi"},
    {"name": "Spanish (Español)", "code": "es"},
    {"name": "French (Français)", "code": "fr"},
    {"name": "Arabic (العربية)", "code": "ar"},
    {"name": "Bengali (বাংলা)", "code": "bn"},
    {"name": "Portuguese (Português)", "code": "pt"},
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  void _loadCurrentLanguage() async {
    final lang = await _settingsService.getLanguagePreference();
    setState(() => _selectedLanguage = lang);
  }

  void _handleLanguageChange(String? language) async {
    if (language == null) return;
    setState(() => _isSaving = true);
    
    await _settingsService.saveLanguagePreference(language);
    
    setState(() {
      _selectedLanguage = language;
      _isSaving = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Renbot will now speak in $language")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Regional Language"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Choose your preferred language",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Renbot will adapt its support and responses to your chosen regional language.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: _languages.length,
                itemBuilder: (context, index) {
                  final lang = _languages[index]['name']!;
                  return RadioListTile<String>(
                    title: Text(lang, style: const TextStyle(fontSize: 18)),
                    value: lang,
                    groupValue: _selectedLanguage,
                    activeColor: AppTheme.primaryColor,
                    onChanged: _isSaving ? null : _handleLanguageChange,
                  );
                },
              ),
            ),
            if (_isSaving)
              const Center(child: CircularProgressIndicator())
          ],
        ),
      ),
    );
  }
}