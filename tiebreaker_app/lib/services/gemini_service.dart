import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String apiKey = 'AIzaSyBKYiop8whrB2C1a8X-pAaIYIpy1viQ4GA';
  static const String model = 'gemini-2.5-flash-lite';
  
  Future<String> analyzeDecision(String decisionPrompt) async {
    try {
      final prompt = _buildPrompt(decisionPrompt);
      
      // The base URL is built automatically using the model name
      final response = await http.post(
        Uri.parse('https://generativelanguage.googleapis.com/v1/models/$model:generateContent?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 2048,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final text = data['candidates'][0]['content']['parts'][0]['text'];
        return text;
      } else {
        final errorData = json.decode(response.body);
        throw Exception('API Error: ${errorData['error']?['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      throw Exception('Failed to analyze decision: $e');
    }
  }

  String _buildPrompt(String decisionPrompt) {
    return '''You are an expert decision-making assistant. The user is trying to make a decision: "$decisionPrompt".

Please provide exactly 3 sections in markdown format:

## 1. PROS AND CONS
Provide a detailed pros and cons analysis. List pros with ✅ and cons with ❌. Be specific and thorough about the advantages and disadvantages of the main options.

## 2. COMPARISON TABLE
If applicable, provide a detailed comparison table comparing the main alternatives. Use markdown table format with clear columns (e.g., Feature, Option A, Option B, etc.). Include at least 5-7 comparison points. If there's only one main option being considered, provide a comparison of key factors to consider.

## 3. SWOT ANALYSIS
Provide a comprehensive SWOT (Strengths, Weaknesses, Opportunities, Threats) analysis for this decision. Format with clear headings and bullet points.

Make the analysis detailed, practical, and actionable. Focus on helping the user make an informed decision. Use emojis where appropriate for better readability.

Important: Analyze exactly what the user asked for. If they're comparing multiple options (like "fries or pizza"), compare those specifically. If it's a single decision (like "should I buy a car"), analyze that decision thoroughly.
''';
  }
}