// lib/services/ai_service.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

enum AIProvider {
  ollama,
  openai,
  anthropic,
  gemini
}

class AIService {
  late final String _apiKey;
  late final AIProvider _provider;
  late final String _baseUrl;
  late final String _model;
  
  static final AIService _instance = AIService._internal();
  
  factory AIService() {
    return _instance;
  }
  
  AIService._internal() {
    final providerName = dotenv.env['AI_PROVIDER']?.toLowerCase() ?? 'ollama';
    
    switch (providerName) {
      case 'ollama':
        _provider = AIProvider.ollama;
        _baseUrl = dotenv.env['OLLAMA_BASE_URL'] ?? 'http://10.0.2.2:11434';
        _model = dotenv.env['OLLAMA_MODEL'] ?? 'llama2';
        _apiKey = '';
        break;
        
      case 'openai':
        _provider = AIProvider.openai;
        // Check if using Groq (key starts with 'gsk_')
        _apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
        if (_apiKey.startsWith('gsk_')) {
          _baseUrl = 'https://api.groq.com/openai/v1';
          _model = dotenv.env['OPENAI_MODEL'] ?? 'llama-3.1-8b-instant';
          print('Using Groq API');
        } else {
          _baseUrl = 'https://api.openai.com/v1';
          _model = dotenv.env['OPENAI_MODEL'] ?? 'gpt-3.5-turbo';
          print('Using OpenAI API');
        }
        break;
        
      case 'anthropic':
        _provider = AIProvider.anthropic;
        _baseUrl = 'https://api.anthropic.com/v1';
        _model = dotenv.env['ANTHROPIC_MODEL'] ?? 'claude-3-haiku-20240307';
        _apiKey = dotenv.env['ANTHROPIC_API_KEY'] ?? '';
        break;
        
      case 'gemini':
      default:
        _provider = AIProvider.gemini;
        _baseUrl = 'https://generativelanguage.googleapis.com/v1beta';
        _model = 'gemini-pro';
        _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    }
    
    print('AI Service initialized: $_provider, model: $_model, url: $_baseUrl');
  }

  // Test connection to Ollama
  Future<bool> testOllamaConnection() async {
    try {
      final url = Uri.parse('$_baseUrl/api/tags');
      final response = await http.get(url).timeout(Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final models = data['models'] as List;
        print('Ollama is running. Available models: ${models.map((m) => m['name']).join(', ')}');
        
        // Check if our model is available
        bool modelExists = models.any((m) => m['name'].toString().contains(_model));
        if (!modelExists) {
          print('WARNING: Model "$_model" not found. Run: ollama pull $_model');
          return false;
        }
        return true;
      }
      return false;
    } catch (e) {
      print('Cannot connect to Ollama: $e');
      return false;
    }
  }

  Future<String> _callAI(String prompt) async {
    try {
      switch (_provider) {
        case AIProvider.ollama:
          return await _callOllama(prompt);
        case AIProvider.openai:
          return await _callOpenAI(prompt);
        case AIProvider.anthropic:
          return await _callAnthropic(prompt);
        case AIProvider.gemini:
          return await _callGemini(prompt);
      }
    } catch (e) {
      print('Error calling AI: $e');
      return 'Error: ${e.toString()}';
    }
  }

  // Ollama API with better error handling
  Future<String> _callOllama(String prompt) async {
    try {
      // First check connection
      final testUrl = Uri.parse('$_baseUrl/api/tags');
      try {
        await http.get(testUrl).timeout(Duration(seconds: 3));
      } catch (e) {
        return 'Cannot connect to Ollama at $_baseUrl\n\n'
               'Make sure:\n'
               '1. Ollama is installed (download from ollama.ai)\n'
               '2. Ollama is running (run "ollama serve" in terminal)\n'
               '3. Model is downloaded (run "ollama pull $_model")';
      }

      final url = Uri.parse('$_baseUrl/api/generate');
      
      print('Calling Ollama at: $url with model: $_model');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': _model,
          'prompt': prompt,
          'stream': false,
          'options': {
            'temperature': 0.7,
            'num_predict': 1024,  // Limit response length
          }
        }),
      ).timeout(Duration(seconds: 90));

      print('Ollama response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final responseText = data['response'] ?? '';
        
        if (responseText.isEmpty) {
          return 'Ollama returned empty response. Try a different model or check if model is properly loaded.';
        }
        
        return responseText;
      } else if (response.statusCode == 404) {
        return 'Model "$_model" not found in Ollama.\n\n'
               'Run this command to download it:\n'
               'ollama pull $_model\n\n'
               'Or try another model:\n'
               'ollama pull mistral\n'
               'ollama pull llama3.2';
      } else {
        final errorBody = response.body;
        print('Ollama error body: $errorBody');
        return 'Ollama error (${response.statusCode}): ${errorBody}\n\n'
               'Try running: ollama pull $_model';
      }
    } catch (e) {
      print('Ollama exception: $e');
      return 'Connection error: ${e.toString()}\n\n'
             'Make sure Ollama is running with: ollama serve';
    }
  }

  // OpenAI API
  Future<String> _callOpenAI(String prompt) async {
    final url = Uri.parse('$_baseUrl/chat/completions');
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': _model,
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.7,
        'max_tokens': 2048,
      }),
    ).timeout(Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('OpenAI error (${response.statusCode}): ${response.body}');
    }
  }

  // Anthropic Claude API
  Future<String> _callAnthropic(String prompt) async {
    final url = Uri.parse('$_baseUrl/messages');
    
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': _apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': _model,
        'max_tokens': 2048,
        'messages': [
          {'role': 'user', 'content': prompt}
        ],
      }),
    ).timeout(Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['content'][0]['text'];
    } else {
      throw Exception('Anthropic error (${response.statusCode}): ${response.body}');
    }
  }

  // Google Gemini API with better error handling
  Future<String> _callGemini(String prompt) async {
    final url = Uri.parse('$_baseUrl/models/$_model:generateContent?key=$_apiKey');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
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
    ).timeout(Duration(seconds: 30));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['candidates'][0]['content']['parts'][0]['text'];
    } else {
      throw Exception('Gemini error (${response.statusCode}): ${response.body}\n\n'
                     'Check if your API key is valid at: https://makersuite.google.com/app/apikey');
    }
  }

  // Doubt Solver
  Future<String> solveDoubt(String question) async {
    final prompt = 'You are a helpful study assistant. Answer this question clearly and concisely for a student:\n\n$question';
    return await _callAI(prompt);
  }

  // Quiz Generator
  Future<List<Map<String, dynamic>>> generateQuiz(String topic, int numQuestions) async {
    final prompt = '''Create $numQuestions multiple choice questions about: $topic

Return ONLY a JSON array in this exact format, with no other text:
[{"question":"Question text?","options":["A","B","C","D"],"correct":0}]

Rules:
- "correct" is the index (0-3) of the right answer
- Make questions clear and educational
- No markdown, no explanations, just the JSON array''';

    try {
      final response = await _callAI(prompt);
      
      // Extract JSON from response
      String cleaned = response.trim();
      cleaned = cleaned.replaceAll('```json', '').replaceAll('```', '').trim();
      
      // Find JSON array boundaries
      int start = cleaned.indexOf('[');
      int end = cleaned.lastIndexOf(']');
      
      if (start == -1 || end == -1) {
        throw Exception('No JSON array found in response');
      }
      
      cleaned = cleaned.substring(start, end + 1);
      
      final List<dynamic> quizData = jsonDecode(cleaned);
      return quizData.map((q) => {
        'question': q['question'].toString(),
        'options': List<String>.from(q['options']),
        'correct': int.parse(q['correct'].toString()),
        'selected': -1,
      }).toList();
    } catch (e) {
      print('Quiz parse error: $e');
      // Fallback sample data
      return List.generate(numQuestions, (i) => {
        'question': 'Sample question ${i + 1} about $topic',
        'options': ['Option A', 'Option B', 'Option C', 'Option D'],
        'correct': 0,
        'selected': -1,
      });
    }
  }

  // Notes Summarizer
  Future<String> summarizeNotes(String notes) async {
    final prompt = 'Summarize these notes into clear bullet points:\n\n$notes';
    return await _callAI(prompt);
  }

  // Flashcard Generator
  Future<List<Map<String, String>>> generateFlashcards(String topic, int count) async {
    final prompt = '''Create $count flashcards about: $topic

Return ONLY a JSON array, no other text:
[{"question":"Q1","answer":"A1"},{"question":"Q2","answer":"A2"}]''';

    try {
      final response = await _callAI(prompt);
      
      String cleaned = response.trim();
      cleaned = cleaned.replaceAll('```json', '').replaceAll('```', '').trim();
      
      int start = cleaned.indexOf('[');
      int end = cleaned.lastIndexOf(']');
      
      if (start != -1 && end != -1) {
        cleaned = cleaned.substring(start, end + 1);
      }
      
      final List<dynamic> data = jsonDecode(cleaned);
      return data.map((f) => {
        'question': f['question'].toString(),
        'answer': f['answer'].toString(),
      }).toList();
    } catch (e) {
      print('Flashcard parse error: $e');
      return List.generate(count, (i) => {
        'question': 'Question ${i + 1} about $topic',
        'answer': 'Answer ${i + 1}',
      });
    }
  }

  // Resource Finder
  Future<List<Map<String, String>>> findResources(String topic) async {
    final prompt = '''Suggest 5 learning resources for: $topic

Return ONLY a JSON array:
[{"title":"Title","type":"Article","source":"Source","description":"Desc"}]''';

    try {
      final response = await _callAI(prompt);
      
      String cleaned = response.trim();
      cleaned = cleaned.replaceAll('```json', '').replaceAll('```', '').trim();
      
      int start = cleaned.indexOf('[');
      int end = cleaned.lastIndexOf(']');
      
      if (start != -1 && end != -1) {
        cleaned = cleaned.substring(start, end + 1);
      }
      
      final List<dynamic> data = jsonDecode(cleaned);
      return data.map((r) => {
        'title': r['title'].toString(),
        'type': r['type'].toString(),
        'source': r['source'].toString(),
        'description': r['description'].toString(),
      }).toList();
    } catch (e) {
      print('Resource parse error: $e');
      return [
        {
          'title': 'Khan Academy - $topic',
          'type': 'Website',
          'source': 'khanacademy.org',
          'description': 'Free comprehensive tutorials'
        },
      ];
    }
  }
}