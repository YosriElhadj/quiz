import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../models/question_model.dart';

abstract class QuizRemoteDataSource {
  Future<List<QuestionModel>> getQuestions();
  Future<String> getAIInsights(String personalityType, String description);
}

class QuizRemoteDataSourceImpl implements QuizRemoteDataSource {
  final http.Client client;

  QuizRemoteDataSourceImpl({required this.client});

  @override
  Future<List<QuestionModel>> getQuestions() async {
    if (AppConstants.groqApiKey == 'YOUR_GROQ_API_KEY_HERE' || 
        AppConstants.groqApiKey. isEmpty) {
      print('⚠️ Groq API key not configured.  Using enhanced static questions.');
      return _getEnhancedStaticQuestions();
    }

    try {
      print('🤖 Generating ${AppConstants.numberOfQuestions} questions with Groq AI...');
      return await _getGroqGeneratedQuestions();
    } catch (e) {
      print('❌ Groq API failed: $e');
      print('📋 Falling back to enhanced static questions');
      return _getEnhancedStaticQuestions();
    }
  }

  Future<List<QuestionModel>> _getGroqGeneratedQuestions() async {
    final prompt = '''
You are a professional psychologist specializing in personality assessment. Generate exactly ${AppConstants.numberOfQuestions} comprehensive personality quiz questions. 

CRITICAL:  Return ONLY a valid JSON array.  No markdown, no explanations. 

Create questions that assess these personality dimensions:
- Extroversion vs Introversion (social energy)
- Thinking vs Feeling (decision-making)
- Judging vs Perceiving (lifestyle structure)
- Sensing vs Intuition (information processing)
- Assertiveness vs Accommodation (conflict style)
- Analytical vs Creative (problem-solving)
- Leadership vs Support (team dynamics)
- Spontaneity vs Planning (approach to life)

Each question should have ${AppConstants.answersPerQuestion} answer options that range across a spectrum.

JSON structure:
[
  {
    "id": "q1",
    "text": "Nuanced, scenario-based question? ",
    "category": "Social Energy & Interaction",
    "answers": [
      {
        "id": "q1a1",
        "text": "Strongly extroverted answer",
        "personalityType": "Extrovert",
        "score": 5
      },
      {
        "id": "q1a2",
        "text": "Moderately extroverted answer",
        "personalityType": "Extrovert",
        "score":  3
      },
      {
        "id": "q1a3",
        "text":  "Moderately introverted answer",
        "personalityType": "Introvert",
        "score": 3
      },
      {
        "id": "q1a4",
        "text": "Strongly introverted answer",
        "personalityType": "Introvert",
        "score":  5
      }
    ]
  }
]

Make questions: 
- Scenario-based and realistic
- Varied across all dimensions
- Clear and unambiguous
- Relatable to everyday life
- Progressive in complexity

Return ONLY the JSON array.
''';

    final response = await client. post(
      Uri.parse(AppConstants.groqApiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${AppConstants.groqApiKey}',
      },
      body: json.encode({
        'model': AppConstants. groqModel,
        'messages': [
          {
            'role': 'system',
            'content': 'You are a professional psychologist.  Return only valid JSON arrays, no markdown.'
          },
          {
            'role': 'user',
            'content': prompt
          }
        ],
        'temperature': 0.8,
        'max_tokens':  4000,
      }),
    );

    print('📡 API Response Status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      if (data['choices'] == null || data['choices'].isEmpty) {
        throw Exception('Invalid response from Groq');
      }

      final content = data['choices'][0]['message']['content'] as String;
      print('📥 Raw response length: ${content.length}');
      
      String jsonContent = content. trim();
      
      // Remove markdown code blocks
      if (jsonContent.contains('```json')) {
        final start = jsonContent.indexOf('```json') + 7;
        final end = jsonContent.lastIndexOf('```');
        if (end > start) {
          jsonContent = jsonContent.substring(start, end).trim();
        }
      } else if (jsonContent.contains('```')) {
        final start = jsonContent.indexOf('```') + 3;
        final end = jsonContent.lastIndexOf('```');
        if (end > start) {
          jsonContent = jsonContent.substring(start, end).trim();
        }
      }
      
      // Find JSON array
      final arrayStart = jsonContent.indexOf('[');
      final arrayEnd = jsonContent.lastIndexOf(']');
      
      if (arrayStart != -1 && arrayEnd != -1 && arrayEnd > arrayStart) {
        jsonContent = jsonContent.substring(arrayStart, arrayEnd + 1);
      }
      
      print('🔍 Cleaned JSON length: ${jsonContent.length}');
      
      try {
        final questionsJson = json.decode(jsonContent) as List;
        final questions = questionsJson
            .map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
            .toList();
        
        print('✅ Successfully generated ${questions.length} questions with Groq! ');
        return questions;
      } catch (e) {
        print('❌ JSON parsing error: $e');
        throw Exception('Failed to parse Groq response as JSON');
      }
    } else {
      final errorBody = response.body;
      print('❌ API Error Response: $errorBody');
      throw Exception('Groq API failed with status ${response.statusCode}');
    }
  }

  @override
  Future<String> getAIInsights(String personalityType, String description) async {
    if (AppConstants.groqApiKey == 'YOUR_GROQ_API_KEY_HERE' || 
        AppConstants.groqApiKey.isEmpty) {
      return _getFallbackInsights(personalityType);
    }

    try {
      print('🤖 Generating insights with Groq AI...');
      
      final prompt = '''
You are a warm, empathetic personality analyst and certified life coach with 15+ years of experience. 

A person has been identified as having a "$personalityType" dominant personality type. 

Provide deeply personalized, encouraging insights (500-600 words) with this structure: 

1. **Warm, Validating Opening** (2-3 sentences)
   - Make them feel truly understood and valued
   - Acknowledge their unique perspective

2. **Core Characteristics** (1 paragraph)
   - What fundamentally defines their personality
   - How they experience and interact with the world

3. **Career Recommendations** (detailed section)
   - 5 specific career paths with brief explanations
   - Include emerging fields and modern roles
   - Explain WHY these suit their personality

4. **Natural Strengths** (bullet points)
   - 5-6 specific strengths with context
   - Real-world applications

5. **Growth Opportunities** (gentle, constructive)
   - 3-4 areas for development
   - Practical strategies for growth
   - Frame as opportunities, not weaknesses

6. **Relationships & Communication** (1 paragraph)
   - How they connect with others
   - Tips for deeper relationships
   - Communication strengths

7. **Daily Life Integration** (practical tips)
   - 4-5 specific, actionable daily practices
   - How to leverage their strengths
   - Energy management

8. **Inspirational Closing** (2-3 sentences)
   - Motivating message about their potential
   - Encouragement for their journey

Use: 
- 2-3 relevant emojis for visual appeal
- Specific, actionable advice
- Warm, professional tone
- Evidence-based insights
- Personal examples

Make it feel like a one-on-one consultation with a trusted advisor.
''';

      final response = await client.post(
        Uri.parse(AppConstants.groqApiUrl),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer ${AppConstants.groqApiKey}',
        },
        body: json.encode({
          'model':  AppConstants.groqModel,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a warm, professional personality analyst and certified life coach.'
            },
            {
              'role': 'user',
              'content': prompt
            }
          ],
          'temperature':  0.9,
          'max_tokens':  1200,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          final insights = data['choices'][0]['message']['content'] as String;
          print('✅ Generated personalized insights with Groq!');
          return insights;
        }
      }
      
      print('❌ Failed to get AI insights');
      return _getFallbackInsights(personalityType);
    } catch (e) {
      print('❌ Error getting insights: $e');
      return _getFallbackInsights(personalityType);
    }
  }

  // ENHANCED static questions - 25 professional-grade questions
  List<QuestionModel> _getEnhancedStaticQuestions() {
    return [
      // Social Energy (Questions 1-5)
      const QuestionModel(
        id:  'q1',
        text: 'At a large social event, after a few hours you typically:',
        category: 'Social Energy & Interaction',
        answers: [
          AnswerModel(
            id: 'q1a1',
            text: 'Feel energized and want to meet even more people',
            personalityType: 'Extrovert',
            score: 5,
          ),
          AnswerModel(
            id: 'q1a2',
            text: 'Feel good but ready to leave soon',
            personalityType: 'Extrovert',
            score: 2,
          ),
          AnswerModel(
            id: 'q1a3',
            text: 'Feel drained and need quiet time',
            personalityType:  'Introvert',
            score: 3,
          ),
          AnswerModel(
            id: 'q1a4',
            text: 'Feel exhausted and overwhelmed',
            personalityType:  'Introvert',
            score: 5,
          ),
        ],
      ),
      
      const QuestionModel(
        id:  'q2',
        text: 'When you have free time, you prefer to:',
        category: 'Leisure & Recharge',
        answers: [
          AnswerModel(
            id: 'q2a1',
            text: 'Call friends and organize a group activity',
            personalityType:  'Extrovert',
            score: 5,
          ),
          AnswerModel(
            id: 'q2a2',
            text: 'Meet up with one or two close friends',
            personalityType: 'Extrovert',
            score: 2,
          ),
          AnswerModel(
            id: 'q2a3',
            text: 'Enjoy a solo hobby or quiet activity',
            personalityType: 'Introvert',
            score: 3,
          ),
          AnswerModel(
            id: 'q2a4',
            text: 'Spend time alone with no interruptions',
            personalityType:  'Introvert',
            score: 5,
          ),
        ],
      ),

      const QuestionModel(
        id:  'q3',
        text: 'In a group discussion, you are most likely to:',
        category: 'Communication Style',
        answers: [
          AnswerModel(
            id: 'q3a1',
            text: 'Speak up frequently and share ideas immediately',
            personalityType: 'Extrovert',
            score: 5,
          ),
          AnswerModel(
            id: 'q3a2',
            text: 'Contribute when you have something important to say',
            personalityType: 'Extrovert',
            score: 2,
          ),
          AnswerModel(
            id: 'q3a3',
            text: 'Listen carefully and speak only when asked',
            personalityType: 'Introvert',
            score: 3,
          ),
          AnswerModel(
            id: 'q3a4',
            text: 'Prefer to observe and reflect privately',
            personalityType: 'Introvert',
            score: 5,
          ),
        ],
      ),

      const QuestionModel(
        id:  'q4',
        text: 'Your ideal weekend getaway would be:',
        category: 'Social Preferences',
        answers: [
          AnswerModel(
            id: 'q4a1',
            text: 'A lively city with lots of activities and nightlife',
            personalityType:  'Extrovert',
            score: 5,
          ),
          AnswerModel(
            id: 'q4a2',
            text: 'A small town with interesting people and local events',
            personalityType: 'Extrovert',
            score: 2,
          ),
          AnswerModel(
            id: 'q4a3',
            text: 'A peaceful cabin with beautiful nature',
            personalityType: 'Introvert',
            score: 3,
          ),
          AnswerModel(
            id: 'q4a4',
            text: 'A completely isolated retreat with no one around',
            personalityType: 'Introvert',
            score: 5,
          ),
        ],
      ),

      const QuestionModel(
        id:  'q5',
        text: 'When meeting new people, you: ',
        category: 'Social Approach',
        answers: [
          AnswerModel(
            id: 'q5a1',
            text: 'Feel excited and introduce yourself first',
            personalityType: 'Extrovert',
            score: 5,
          ),
          AnswerModel(
            id: 'q5a2',
            text: 'Feel comfortable and respond warmly',
            personalityType:  'Extrovert',
            score: 2,
          ),
          AnswerModel(
            id: 'q5a3',
            text: 'Feel cautious and wait for them to approach',
            personalityType: 'Introvert',
            score: 3,
          ),
          AnswerModel(
            id: 'q5a4',
            text: 'Feel anxious and prefer to avoid it',
            personalityType: 'Introvert',
            score: 5,
          ),
        ],
      ),

      // Decision Making (Questions 6-10)
      const QuestionModel(
        id: 'q6',
        text: 'When making an important decision, you primarily:',
        category: 'Decision-Making Approach',
        answers: [
          AnswerModel(
            id: 'q6a1',
            text: 'Analyze all facts and data objectively',
            personalityType:  'Thinker',
            score: 5,
          ),
          AnswerModel(
            id:  'q6a2',
            text: 'Consider logic but also practical implications',
            personalityType:  'Thinker',
            score: 2,
          ),
          AnswerModel(
            id: 'q6a3',
            text: 'Think about how it affects people involved',
            personalityType: 'Feeler',
            score: 3,
          ),
          AnswerModel(
            id: 'q6a4',
            text: 'Follow your heart and personal values',
            personalityType:  'Feeler',
            score: 5,
          ),
        ],
      ),

      const QuestionModel(
        id: 'q7',
        text: 'When someone shares a problem with you, your first instinct is to:',
        category: 'Empathy & Problem-Solving',
        answers:  [
          AnswerModel(
            id: 'q7a1',
            text: 'Identify the logical solution immediately',
            personalityType: 'Thinker',
            score: 5,
          ),
          AnswerModel(
            id: 'q7a2',
            text: 'Ask clarifying questions about the facts',
            personalityType: 'Thinker',
            score: 2,
          ),
          AnswerModel(
            id: 'q7a3',
            text: 'Acknowledge their feelings first',
            personalityType: 'Feeler',
            score: 3,
          ),
          AnswerModel(
            id: 'q7a4',
            text: 'Provide emotional support and empathy',
            personalityType:  'Feeler',
            score: 5,
          ),
        ],
      ),

      const QuestionModel(
        id: 'q8',
        text: 'In a heated debate, you tend to:',
        category: 'Conflict Style',
        answers: [
          AnswerModel(
            id: 'q8a1',
            text: 'Focus on winning with logic and evidence',
            personalityType: 'Thinker',
            score: 5,
          ),
          AnswerModel(
            id: 'q8a2',
            text: 'Stay calm and present rational arguments',
            personalityType:  'Thinker',
            score: 2,
          ),
          AnswerModel(
            id: 'q8a3',
            text: 'Seek compromise and common ground',
            personalityType:  'Feeler',
            score: 3,
          ),
          AnswerModel(
            id: 'q8a4',
            text: 'Avoid conflict and preserve harmony',
            personalityType: 'Feeler',
            score: 5,
          ),
        ],
      ),

      const QuestionModel(
        id:  'q9',
        text: 'When giving feedback to someone, you: ',
        category: 'Communication & Feedback',
        answers: [
          AnswerModel(
            id: 'q9a1',
            text: 'Be direct and honest about issues',
            personalityType: 'Thinker',
            score: 5,
          ),
          AnswerModel(
            id: 'q9a2',
            text: 'State facts but remain professional',
            personalityType: 'Thinker',
            score: 2,
          ),
          AnswerModel(
            id: 'q9a3',
            text: 'Start with positives before concerns',
            personalityType: 'Feeler',
            score: 3,
          ),
          AnswerModel(
            id: 'q9a4',
            text: 'Focus heavily on encouragement',
            personalityType: 'Feeler',
            score:  5,
          ),
        ],
      ),

      const QuestionModel(
        id: 'q10',
        text:  'When evaluating a new idea, you focus on:',
        category: 'Evaluation Criteria',
        answers: [
          AnswerModel(
            id: 'q10a1',
            text: 'Whether it makes logical sense',
            personalityType: 'Thinker',
            score: 5,
          ),
          AnswerModel(
            id: 'q10a2',
            text:  'Its practical efficiency',
            personalityType: 'Thinker',
            score: 2,
          ),
          AnswerModel(
            id: 'q10a3',
            text: 'How people will respond to it',
            personalityType: 'Feeler',
            score: 3,
          ),
          AnswerModel(
            id: 'q10a4',
            text: 'Whether it aligns with your values',
            personalityType: 'Feeler',
            score: 5,
          ),
        ],
      ),

      // Structure & Planning (Questions 11-15)
      const QuestionModel(
        id: 'q11',
        text: 'Your approach to planning a vacation is:',
        category: 'Planning & Organization',
        answers: [
          AnswerModel(
            id: 'q11a1',
            text: 'Create detailed itineraries weeks in advance',
            personalityType: 'Judger',
            score: 5,
          ),
          AnswerModel(
            id: 'q11a2',
            text: 'Make basic reservations but stay flexible',
            personalityType: 'Judger',
            score: 2,
          ),
          AnswerModel(
            id: 'q11a3',
            text: 'Book essentials and decide the rest as you go',
            personalityType: 'Perceiver',
            score: 3,
          ),
          AnswerModel(
            id: 'q11a4',
            text: 'Prefer completely spontaneous trips',
            personalityType: 'Perceiver',
            score: 5,
          ),
        ],
      ),

      const QuestionModel(
        id: 'q12',
        text: 'Your workspace is typically: ',
        category: 'Organization & Environment',
        answers: [
          AnswerModel(
            id: 'q12a1',
            text: 'Meticulously organized with everything labeled',
            personalityType: 'Judger',
            score: 5,
          ),
          AnswerModel(
            id: 'q12a2',
            text: 'Neat and organized in a practical way',
            personalityType:  'Judger',
            score: 2,
          ),
          AnswerModel(
            id: 'q12a3',
            text: 'Organized chaos - you know where things are',
            personalityType:  'Perceiver',
            score: 3,
          ),
          AnswerModel(
            id: 'q12a4',
            text: 'Creatively messy with items everywhere',
            personalityType:  'Perceiver',
            score: 5,
          ),
        ],
      ),

      const QuestionModel(
        id: 'q13',
        text: 'When facing a deadline, you: ',
        category: 'Time Management',
        answers: [
          AnswerModel(
            id: 'q13a1',
            text: 'Finish well ahead of time',
            personalityType: 'Judger',
            score: 5,
          ),
          AnswerModel(
            id: 'q13a2',
            text: 'Complete it with a few days to spare',
            personalityType:  'Judger',
            score: 2,
          ),
          AnswerModel(
            id: 'q13a3',
            text: 'Work up until the deadline',
            personalityType: 'Perceiver',
            score: 3,
          ),
          AnswerModel(
            id: 'q13a4',
            text: 'Thrive under last-minute pressure',
            personalityType: 'Perceiver',
            score: 5,
          ),
        ],
      ),

      const QuestionModel(
        id: 'q14',
        text: 'When plans suddenly change, you:',
        category: 'Adaptability',
        answers: [
          AnswerModel(
            id: 'q14a1',
            text: 'Feel stressed and try to restore original plan',
            personalityType: 'Judger',
            score: 5,
          ),
          AnswerModel(
            id: 'q14a2',
            text: 'Feel uncomfortable but adjust',
            personalityType: 'Judger',
            score:  2,
          ),
          AnswerModel(
            id: 'q14a3',
            text: 'Accept it and adapt easily',
            personalityType: 'Perceiver',
            score: 3,
          ),
          AnswerModel(
            id: 'q14a4',
            text: 'Welcome the spontaneity',
            personalityType:  'Perceiver',
            score: 5,
          ),
        ],
      ),

      const QuestionModel(
        id: 'q15',
        text: 'Your daily routine is: ',
        category: 'Lifestyle Structure',
        answers: [
          AnswerModel(
            id: 'q15a1',
            text: 'Strictly scheduled down to the hour',
            personalityType: 'Judger',
            score: 5,
          ),
          AnswerModel(
            id: 'q15a2',
            text: 'Generally consistent with some structure',
            personalityType: 'Judger',
            score: 2,
          ),
          AnswerModel(
            id: 'q15a3',
            text: 'Loosely planned but flexible',
            personalityType: 'Perceiver',
            score: 3,
          ),
          AnswerModel(
            id: 'q15a4',
            text: 'Completely spontaneous and varied',
            personalityType: 'Perceiver',
            score: 5,
          ),
        ],
      ),

      // Problem-Solving Style (Questions 16-20)
      const QuestionModel(
        id: 'q16',
        text: 'When solving a complex problem, you prefer to:',
        category: 'Problem-Solving Approach',
        answers: [
          AnswerModel(
            id:  'q16a1',
            text: 'Break it down into systematic steps',
            personalityType:  'Analytical',
            score: 5,
          ),
          AnswerModel(
            id: 'q16a2',
            text: 'Analyze the data and find patterns',
            personalityType: 'Analytical',
            score:  2,
          ),
          AnswerModel(
            id: 'q16a3',
            text: 'Brainstorm creative solutions',
            personalityType:  'Creative',
            score: 3,
          ),
          AnswerModel(
            id: 'q16a4',
            text: 'Think outside the box entirely',
            personalityType: 'Creative',
            score: 5,
          ),
        ],
      ),

      const QuestionModel(
        id: 'q17',
        text: 'At work, you excel at:',
        category: 'Work Strengths',
        answers: [
          AnswerModel(
            id: 'q17a1',
            text: 'Quality control and attention to detail',
            personalityType: 'Analytical',
            score: 5,
          ),
          AnswerModel(
            id: 'q17a2',
            text:  'Systematic processes and procedures',
            personalityType: 'Analytical',
            score:  2,
          ),
          AnswerModel(
            id: 'q17a3',
            text: 'Innovative ideas and fresh perspectives',
            personalityType:  'Creative',
            score:  3,
          ),
          AnswerModel(
            id: 'q17a4',
            text: 'Artistic vision and originality',
            personalityType:  'Creative',
            score:  5,
          ),
        ],
      ),

      const QuestionModel(
        id: 'q18',
        text:  'When learning something new, you:',
        category: 'Learning Style',
        answers: [
          AnswerModel(
            id: 'q18a1',
            text: 'Study the fundamentals thoroughly',
            personalityType: 'Analytical',
            score: 5,
          ),
          AnswerModel(
            id: 'q18a2',
            text: 'Follow step-by-step instructions',
            personalityType: 'Analytical',
            score: 2,
          ),
          AnswerModel(
            id: 'q18a3',
            text: 'Experiment and discover through trial',
            personalityType: 'Creative',
            score: 3,
          ),
          AnswerModel(
            id:  'q18a4',
            text: 'Dive in and improvise completely',
            personalityType: 'Creative',
            score: 5,
          ),
        ],
      ),

      const QuestionModel(
        id: 'q19',
        text: 'Your ideal project would involve:',
        category: 'Work Preferences',
        answers: [
          AnswerModel(
            id: 'q19a1',
            text: 'Precise data analysis and reporting',
            personalityType: 'Analytical',
            score:  5,
          ),
          AnswerModel(
            id: 'q19a2',
            text: 'Research and systematic investigation',
            personalityType:  'Analytical',
            score: 2,
          ),
          AnswerModel(
            id: 'q19a3',
            text: 'Design and creative development',
            personalityType: 'Creative',
            score: 3,
          ),
          AnswerModel(
            id:  'q19a4',
            text: 'Artistic expression and innovation',
            personalityType: 'Creative',
            score: 5,
          ),
        ],
      ),

      const QuestionModel(
        id: 'q20',
        text: 'When faced with ambiguity, you:',
        category: 'Handling Uncertainty',
        answers: [
          AnswerModel(
            id: 'q20a1',
            text: 'Gather more data to clarify',
            personalityType: 'Analytical',
            score: 5,
          ),
          AnswerModel(
            id: 'q20a2',
            text: 'Break it down into knowable parts',
            personalityType: 'Analytical',
            score:  2,
          ),
          AnswerModel(
            id: 'q20a3',
            text: 'See possibilities and potential',
            personalityType: 'Creative',
            score: 3,
          ),
          AnswerModel(
            id: 'q20a4',
            text: 'Embrace it as creative opportunity',
            personalityType: 'Creative',
            score: 5,
          ),
        ],
      ),

      // Team Dynamics (Questions 21-25)
      const QuestionModel(
        id: 'q21',
        text: 'In a team project, you naturally: ',
        category: 'Team Role',
        answers: [
          AnswerModel(
            id: 'q21a1',
            text: 'Take charge and direct the team',
            personalityType: 'Leader',
            score: 5,
          ),
          AnswerModel(
            id: 'q21a2',
            text: 'Coordinate tasks and keep things moving',
            personalityType:  'Leader',
            score:  2,
          ),
          AnswerModel(
            id: 'q21a3',
            text: 'Help others and ensure everyone contributes',
            personalityType:  'Supporter',
            score: 3,
          ),
          AnswerModel(
            id: 'q21a4',
            text: 'Focus on team harmony and morale',
            personalityType:  'Supporter',
            score: 5,
          ),
        ],
      ),

      const QuestionModel(
        id:  'q22',
        text: 'When conflicts arise in your team, you:',
        category: 'Conflict Resolution',
        answers: [
          AnswerModel(
            id: 'q22a1',
            text: 'Address issues directly and decisively',
            personalityType:  'Leader',
            score:  5,
          ),
          AnswerModel(
            id: 'q22a2',
            text: 'Mediate and find practical solutions',
            personalityType:  'Leader',
            score:  2,
          ),
          AnswerModel(
            id: 'q22a3',
            text: 'Listen to all sides and seek consensus',
            personalityType: 'Supporter',
            score:  3,
          ),
          AnswerModel(
            id: 'q22a4',
            text: 'Prioritize maintaining relationships',
            personalityType: 'Supporter',
            score:  5,
          ),
        ],
      ),

      const QuestionModel(
        id: 'q23',
        text:  'Your communication style in meetings is:',
        category: 'Leadership Communication',
        answers: [
          AnswerModel(
            id: 'q23a1',
            text: 'Assertive and commanding attention',
            personalityType: 'Leader',
            score: 5,
          ),
          AnswerModel(
            id:  'q23a2',
            text: 'Clear and direct when needed',
            personalityType:  'Leader',
            score:  2,
          ),
          AnswerModel(
            id: 'q23a3',
            text: 'Diplomatic and inclusive',
            personalityType: 'Supporter',
            score:  3,
          ),
          AnswerModel(
            id: 'q23a4',
            text: 'Encouraging and facilitating others',
            personalityType: 'Supporter',
            score:  5,
          ),
        ],
      ),

      const QuestionModel(
        id: 'q24',
        text:  'When someone on your team struggles, you:',
        category:  'Team Support',
        answers: [
          AnswerModel(
            id: 'q24a1',
            text:  'Set clear expectations for improvement',
            personalityType: 'Leader',
            score: 5,
          ),
          AnswerModel(
            id:  'q24a2',
            text: 'Provide guidance on what to do',
            personalityType: 'Leader',
            score: 2,
          ),
          AnswerModel(
            id: 'q24a3',
            text: 'Offer help and encouragement',
            personalityType: 'Supporter',
            score: 3,
          ),
          AnswerModel(
            id: 'q24a4',
            text: 'Give emotional support and mentoring',
            personalityType: 'Supporter',
            score:  5,
          ),
        ],
      ),

      const QuestionModel(
        id: 'q25',
        text:  'Your satisfaction in teamwork comes from:',
        category: 'Team Motivation',
        answers: [
          AnswerModel(
            id: 'q25a1',
            text: 'Achieving ambitious goals and winning',
            personalityType: 'Leader',
            score: 5,
          ),
          AnswerModel(
            id:  'q25a2',
            text: 'Efficiently completing the mission',
            personalityType: 'Leader',
            score: 2,
          ),
          AnswerModel(
            id:  'q25a3',
            text: 'Seeing everyone contribute successfully',
            personalityType: 'Supporter',
            score:  3,
          ),
          AnswerModel(
            id: 'q25a4',
            text: 'Building strong team relationships',
            personalityType:  'Supporter',
            score: 5,
          ),
        ],
      ),
    ];
  }

  String _getFallbackInsights(String personalityType) {
    // ...  (keep the same fallback insights from before)
    return '''Your personality type:  $personalityType

This is a fallback message.  For detailed insights, make sure your API key is configured. ''';
  }
}