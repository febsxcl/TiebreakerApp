import 'package:flutter/material.dart';
import '../models/decision_model.dart';
import '../services/gemini_service.dart';

class DecisionProvider extends ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  DecisionAnalysis _analysis = DecisionAnalysis.initial();
  String _currentPrompt = '';

  DecisionAnalysis get analysis => _analysis;
  String get currentPrompt => _currentPrompt;
  bool get hasResults => 
      _analysis.prosAndCons.isNotEmpty || 
      _analysis.comparisonTable.isNotEmpty || 
      _analysis.swotAnalysis.isNotEmpty;

  Future<void> analyzeDecision(String prompt) async {
    if (prompt.trim().isEmpty) {
      _analysis = DecisionAnalysis.initial();
      notifyListeners();
      return;
    }

    _currentPrompt = prompt;
    _analysis = DecisionAnalysis.loading();
    notifyListeners();

    try {
      final result = await _geminiService.analyzeDecision(prompt);
      print('Raw AI Response: $result');
      
      // Parse the markdown sections
      final sections = _extractSections(result);
      
      // Fixed: Safe preview printing
      _safePrint('Extracted Pros & Cons', sections['prosAndCons']);
      _safePrint('Extracted Comparison', sections['comparisonTable']);
      _safePrint('Extracted SWOT', sections['swotAnalysis']);
      
      _analysis = DecisionAnalysis(
        prosAndCons: sections['prosAndCons'] ?? 'No pros and cons analysis available.',
        comparisonTable: sections['comparisonTable'] ?? 'No comparison table available.',
        swotAnalysis: sections['swotAnalysis'] ?? 'No SWOT analysis available.',
      );
    } catch (e) {
      _analysis = DecisionAnalysis.initial().copyWith(
        error: 'Error: ${e.toString()}',
      );
    }
    notifyListeners();
  }

  // Safe print function - hindi mag-eerror kahit maikli ang text
  void _safePrint(String title, String? text) {
    if (text == null || text.isEmpty) {
      print('$title: [EMPTY]');
      return;
    }
    int length = text.length > 100 ? 100 : text.length;
    print('$title: ${text.substring(0, length)}...');
  }

  Map<String, String> _extractSections(String text) {
    final Map<String, String> sections = {
      'prosAndCons': '',
      'comparisonTable': '',
      'swotAnalysis': '',
    };

    // Method 1: Split by headings
    final lines = text.split('\n');
    String currentSection = '';
    StringBuffer currentContent = StringBuffer();
    
    for (var line in lines) {
      final lowerLine = line.toLowerCase();
      
      // Check for PROS AND CONS
      if (lowerLine.contains('pros and cons') || 
          (lowerLine.contains('pros') && lowerLine.contains('cons'))) {
        if (currentSection.isNotEmpty) {
          sections[currentSection] = currentContent.toString().trim();
          currentContent.clear();
        }
        currentSection = 'prosAndCons';
        continue;
      } 
      // Check for COMPARISON TABLE
      else if (lowerLine.contains('comparison table') || 
               (lowerLine.contains('comparison') && lowerLine.contains('table'))) {
        if (currentSection.isNotEmpty) {
          sections[currentSection] = currentContent.toString().trim();
          currentContent.clear();
        }
        currentSection = 'comparisonTable';
        continue;
      }
      // ✅ PALAKASIN ANG SWOT DETECTION - ITO ANG BAGO
      else if (lowerLine.contains('swot') || 
               lowerLine.contains('swot analysis') ||
               lowerLine.contains('### strengths') ||
               lowerLine.contains('**strengths**') ||
               lowerLine.contains('strengths and weaknesses') ||
               (lowerLine.contains('strengths') && lowerLine.contains('weaknesses')) ||
               (lowerLine.contains('3.') && lowerLine.contains('swot'))) {
        if (currentSection.isNotEmpty) {
          sections[currentSection] = currentContent.toString().trim();
          currentContent.clear();
        }
        currentSection = 'swotAnalysis';
        continue;
      }
      
      // Add line to current section
      if (currentSection.isNotEmpty) {
        currentContent.writeln(line);
      }
    }
    
    // Save the last section
    if (currentSection.isNotEmpty) {
      sections[currentSection] = currentContent.toString().trim();
    }
    
    // Method 2: If still empty, try regex pattern
    if (sections['prosAndCons']!.isEmpty) {
      final prosRegex = RegExp(r'(?:###?\s*1\.?\s*PROS\s*AND\s*CONS|PROS\s*&\s*CONS)[\s\S]*?(?=###?\s*2\.?\s*COMPARISON|###?\s*SWOT|$)', caseSensitive: false);
      final match = prosRegex.firstMatch(text);
      if (match != null) {
        sections['prosAndCons'] = match.group(0)!.replaceAll(RegExp(r'^###?\s*.*$', multiLine: true), '').trim();
      }
    }
    
    if (sections['comparisonTable']!.isEmpty) {
      final tableRegex = RegExp(r'(?:###?\s*2\.?\s*COMPARISON\s*TABLE)[\s\S]*?(?=###?\s*3\.?\s*SWOT|$)', caseSensitive: false);
      final match = tableRegex.firstMatch(text);
      if (match != null) {
        sections['comparisonTable'] = match.group(0)!.replaceAll(RegExp(r'^###?\s*.*$', multiLine: true), '').trim();
      }
    }
    
    if (sections['swotAnalysis']!.isEmpty) {
      final swotRegex = RegExp(r'(?:###?\s*3\.?\s*SWOT\s*ANALYSIS|SWOT\s*ANALYSIS)[\s\S]*', caseSensitive: false);
      final match = swotRegex.firstMatch(text);
      if (match != null) {
        sections['swotAnalysis'] = match.group(0)!.replaceAll(RegExp(r'^###?\s*.*$', multiLine: true), '').trim();
      }
    }
    
    // ✅ ADDITIONAL FALLBACK: Hanapin ang Strengths/Weaknesses section
    if (sections['swotAnalysis']!.isEmpty) {
      // Hanapin kung saan nagsisimula ang Strengths
      final strengthsIndex = text.toLowerCase().indexOf('strengths');
      final weaknessesIndex = text.toLowerCase().indexOf('weaknesses');
      
      if (strengthsIndex != -1) {
        // Kunin mula sa Strengths hanggang dulo
        sections['swotAnalysis'] = text.substring(strengthsIndex);
      } else if (weaknessesIndex != -1) {
        sections['swotAnalysis'] = text.substring(weaknessesIndex);
      }
    }
    
    // Method 3: If still empty, just use the whole text for pros and cons
    if (sections['prosAndCons']!.isEmpty && text.isNotEmpty) {
      sections['prosAndCons'] = text;
    }
    
    return sections;
  }

  void reset() {
    _analysis = DecisionAnalysis.initial();
    _currentPrompt = '';
    notifyListeners();
  }
}