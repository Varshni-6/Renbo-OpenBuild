import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:renbo/utils/constants.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// A data class to hold the structured response from the Gemini API.
class GeminiClassifiedResponse {
  final bool isHarmful;
  final String response;

  GeminiClassifiedResponse({
    this.isHarmful = false,
    this.response = "Sorry, I couldn't connect. Please try again.",
  });
}

class GeminiService {
  final String _apiKey = AppConstants.geminiApiKey;

  // Use the stable 1.5-flash model for better reliability and speed
  final String _modelName = 'gemini-1.5-flash';

  // The GenerativeModel from the SDK (used for Thought of the Day)
  final GenerativeModel _model;

  GeminiService()
      : _model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: AppConstants.geminiApiKey,
        );

  /// Method for chat classification using manual HTTP for precise JSON control
  Future<GeminiClassifiedResponse> generateAndClassify(String prompt) async {
    final headers = {'Content-Type': 'application/json'};
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/$_modelName:generateContent?key=$_apiKey';

    final systemPrompt = """
You are Renbot, a supportive and non-judgmental AI assistant. Your role is to provide a safe space for users to express their thoughts and feelings. 
First, create an empathetic and supportive response to the user's message. 
Second, classify the user's message for self-harm or suicidal ideation.

**Core Principles:**
- Be calm, neutral, and non-judgmental.
- Listen and validate the user's feelings.
- Keep replies simple, crisp, and conversational.
- If the user uses a regional Indian language, reply in that same language.
- If the conversation is concluding, provide parting support.

**Safety Classification:**
- "isHarmful": true only if there is an indication of self-harm, suicide, or immediate physical danger.

You MUST respond in valid JSON format:
{
  "isHarmful": boolean,
  "response": "your empathetic message here"
}

User's message: "$prompt"
""";

    final body = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": systemPrompt}
          ]
        }
      ],
      "generationConfig": {
        "responseMimeType": "application/json",
      }
    });

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final jsonString = data['candidates'][0]['content']['parts'][0]['text'];
        final Map<String, dynamic> classifiedData = jsonDecode(jsonString);

        return GeminiClassifiedResponse(
          isHarmful: classifiedData['isHarmful'] ?? false,
          response: classifiedData['response'] ??
              "I'm listening. Tell me more about that.",
        );
      } else {
        print("API Error: ${response.statusCode} - ${response.body}");
        return GeminiClassifiedResponse();
      }
    } catch (e) {
      print("Network/Parsing Error: $e");
      return GeminiClassifiedResponse(
          response:
              "Something went wrong. Please check your internet connection. 😞");
    }
  }

  /// Generates the "Thought of the Day" using the Google AI SDK
  Future<String> generateThoughtOfTheDay() async {
    try {
      const prompt =
          'Generate a short, positive, and insightful thought of the day for a mental wellness app. Make it concise (under 20 words) and uplifting.';

      final response = await _model.generateContent([Content.text(prompt)]);

      if (response.text != null) {
        return response.text!.trim();
      } else {
        return "The best way to predict the future is to create it.";
      }
    } catch (e) {
      print("Error generating thought: $e");
      return "Every day is a fresh start to find peace within yourself.";
    }
  }
}
