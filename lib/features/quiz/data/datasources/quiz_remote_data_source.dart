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
    // Use Open Trivia Database API for real questions
    try {
      final response = await client.get(
        Uri.parse('https://opentdb.com/api.php?amount=10&type=multiple'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;
        
        // Convert trivia questions to personality quiz format
        return results.asMap().entries.map((entry) {
          final index = entry. key;
          final question = entry.value;
          
          // Decode HTML entities
          final questionText = _decodeHtmlEntities(question['question']);
          final correctAnswer = _decodeHtmlEntities(question['correct_answer']);
          final incorrectAnswers = (question['incorrect_answers'] as List)
              .map((a) => _decodeHtmlEntities(a))
              .toList();
          
          // Map to personality types based on question index
          final personalityTypes = [
            'Extrovert', 'Introvert', 'Thinker', 'Feeler',
            'Judger', 'Perceiver', 'Analytical', 'Creative',
            'Leader', 'Supporter'
          ];
          
          return QuestionModel(
            id:  'q${index + 1}',
            text:  questionText,
            category: question['category'],
            answers: [
              AnswerModel(
                id: 'q${index + 1}a1',
                text: correctAnswer,
                personalityType: personalityTypes[index % personalityTypes.length],
                score: 5,
              ),
              AnswerModel(
                id: 'q${index + 1}a2',
                text: incorrectAnswers[0],
                personalityType: personalityTypes[(index + 1) % personalityTypes.length],
                score: 3,
              ),
            ],
          );
        }).toList();
      } else {
        // Fallback to static questions if API fails
        return _getStaticQuestions();
      }
    } catch (e) {
      // Fallback to static questions if network fails
      return _getStaticQuestions();
    }
  }

  String _decodeHtmlEntities(String text) {
    return text
        .replaceAll('&quot;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&apos;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&#039;', "'")
        .replaceAll('&ldquo;', '"')
        .replaceAll('&rdquo;', '"');
  }

  @override
  Future<String> getAIInsights(String personalityType, String description) async {
    // AI Integration - Example with OpenAI
    try {
      final response = await client.post(
        Uri.parse(AppConstants.aiApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConstants.aiApiKey}',
        },
        body: json.encode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a professional personality analyst.'
            },
            {
              'role': 'user',
              'content': 
                  'Provide detailed insights and recommendations for someone with $personalityType personality. $description'
            }
          ],
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = json. decode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to get AI insights');
      }
    } catch (e) {
      // Return fallback insights if AI fails
      return _getFallbackInsights(personalityType);
    }
  }

  // Static questions as fallback
  List<QuestionModel> _getStaticQuestions() {
    return [
      const QuestionModel(
        id:  'q1',
        text: 'At a party, you usually:',
        category: 'Social',
        answers: [
          AnswerModel(
            id: 'q1a1',
            text: 'Interact with many people, including strangers',
            personalityType: 'Extrovert',
            score: 5,
          ),
          AnswerModel(
            id: 'q1a2',
            text:  'Interact with a few close friends',
            personalityType: 'Introvert',
            score: 5,
          ),
        ],
      ),
      const QuestionModel(
        id: 'q2',
        text:  'When making decisions, you rely more on:',
        category: 'Thinking',
        answers: [
          AnswerModel(
            id: 'q2a1',
            text: 'Logic and objective analysis',
            personalityType:  'Thinker',
            score: 5,
          ),
          AnswerModel(
            id: 'q2a2',
            text: 'Personal values and feelings',
            personalityType: 'Feeler',
            score: 5,
          ),
        ],
      ),
      const QuestionModel(
        id:  'q3',
        text: 'You prefer to:',
        category: 'Planning',
        answers: [
          AnswerModel(
            id: 'q3a1',
            text: 'Have things decided and organized',
            personalityType:  'Judger',
            score: 5,
          ),
          AnswerModel(
            id: 'q3a2',
            text: 'Keep options open and flexible',
            personalityType: 'Perceiver',
            score: 5,
          ),
        ],
      ),
      const QuestionModel(
        id:  'q4',
        text: 'When learning something new, you prefer:',
        category: 'Learning',
        answers: [
          AnswerModel(
            id: 'q4a1',
            text: 'Concrete facts and details',
            personalityType: 'Analytical',
            score:  5,
          ),
          AnswerModel(
            id: 'q4a2',
            text: 'Abstract concepts and theories',
            personalityType: 'Creative',
            score: 5,
          ),
        ],
      ),
      const QuestionModel(
        id: 'q5',
        text: 'In a group project, you tend to:',
        category: 'Leadership',
        answers: [
          AnswerModel(
            id: 'q5a1',
            text: 'Take charge and lead',
            personalityType: 'Leader',
            score: 5,
          ),
          AnswerModel(
            id: 'q5a2',
            text: 'Support and assist others',
            personalityType:  'Supporter',
            score: 5,
          ),
        ],
      ),
      const QuestionModel(
        id: 'q6',
        text: 'Your ideal weekend involves:',
        category: 'Lifestyle',
        answers: [
          AnswerModel(
            id: 'q6a1',
            text: 'Going out and socializing',
            personalityType:  'Extrovert',
            score:  5,
          ),
          AnswerModel(
            id: 'q6a2',
            text: 'Staying in and relaxing',
            personalityType: 'Introvert',
            score: 5,
          ),
        ],
      ),
      const QuestionModel(
        id: 'q7',
        text: 'When faced with a problem, you: ',
        category: 'Problem-Solving',
        answers:  [
          AnswerModel(
            id: 'q7a1',
            text: 'Analyze it systematically',
            personalityType:  'Thinker',
            score: 5,
          ),
          AnswerModel(
            id:  'q7a2',
            text: 'Trust your gut feeling',
            personalityType: 'Feeler',
            score: 5,
          ),
        ],
      ),
      const QuestionModel(
        id:  'q8',
        text: 'You are more comfortable with:',
        category: 'Structure',
        answers: [
          AnswerModel(
            id: 'q8a1',
            text: 'Plans and schedules',
            personalityType:  'Judger',
            score: 5,
          ),
          AnswerModel(
            id: 'q8a2',
            text: 'Spontaneity and flexibility',
            personalityType: 'Perceiver',
            score: 5,
          ),
        ],
      ),
      const QuestionModel(
        id: 'q9',
        text: 'Your approach to work is:',
        category: 'Work Style',
        answers: [
          AnswerModel(
            id: 'q9a1',
            text: 'Detail-oriented and precise',
            personalityType: 'Analytical',
            score: 5,
          ),
          AnswerModel(
            id: 'q9a2',
            text: 'Big-picture and innovative',
            personalityType: 'Creative',
            score: 5,
          ),
        ],
      ),
      const QuestionModel(
        id: 'q10',
        text: 'In conflicts, you prefer to:',
        category: 'Conflict Resolution',
        answers:  [
          AnswerModel(
            id: 'q10a1',
            text: 'Address issues directly',
            personalityType:  'Leader',
            score:  5,
          ),
          AnswerModel(
            id: 'q10a2',
            text: 'Find compromise and harmony',
            personalityType: 'Supporter',
            score:  5,
          ),
        ],
      ),
    ];
  }

  String _getFallbackInsights(String personalityType) {
    return '''
Based on your $personalityType personality type: 

• You have unique strengths that set you apart
• Consider leveraging your natural tendencies in your daily life
• Balance is key - work on areas that don't come as naturally
• Your personality type suggests certain career paths may be more fulfilling
• Remember, personality is fluid and can develop over time

For more detailed insights, consider taking additional assessments or consulting with a professional. 
    ''';
  }
}