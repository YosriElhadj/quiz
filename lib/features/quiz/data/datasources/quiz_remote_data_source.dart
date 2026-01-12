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
    // For now, return static questions.  Later we can fetch from API
    return _getStaticQuestions();
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
        final data = json.decode(response. body);
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('Failed to get AI insights');
      }
    } catch (e) {
      // Return fallback insights if AI fails
      return _getFallbackInsights(personalityType);
    }
  }

  // Static questions for the quiz
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
            score:  5,
          ),
          AnswerModel(
            id: 'q1a2',
            text: 'Interact with a few close friends',
            personalityType:  'Introvert',
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
            id:  'q2a2',
            text: 'Personal values and feelings',
            personalityType: 'Feeler',
            score: 5,
          ),
        ],
      ),
      const QuestionModel(
        id: 'q3',
        text: 'You prefer to:',
        category: 'Planning',
        answers: [
          AnswerModel(
            id: 'q3a1',
            text: 'Have things decided and organized',
            personalityType: 'Judger',
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
        id: 'q4',
        text: 'You are more interested in:',
        category:  'Information',
        answers: [
          AnswerModel(
            id: 'q4a1',
            text: 'Concrete facts and details',
            personalityType: 'Sensor',
            score: 5,
          ),
          AnswerModel(
            id: 'q4a2',
            text: 'Patterns and possibilities',
            personalityType: 'Intuitive',
            score: 5,
          ),
        ],
      ),
      const QuestionModel(
        id: 'q5',
        text: 'In your free time, you: ',
        category: 'Social',
        answers: [
          AnswerModel(
            id: 'q5a1',
            text: 'Seek adventure and new experiences',
            personalityType: 'Extrovert',
            score: 4,
          ),
          AnswerModel(
            id: 'q5a2',
            text: 'Enjoy quiet activities alone or with close friends',
            personalityType:  'Introvert',
            score: 4,
          ),
        ],
      ),
      const QuestionModel(
        id: 'q6',
        text: 'When working on a project, you:',
        category:  'Planning',
        answers: [
          AnswerModel(
            id: 'q6a1',
            text: 'Create a detailed plan and stick to it',
            personalityType: 'Judger',
            score: 5,
          ),
          AnswerModel(
            id: 'q6a2',
            text: 'Go with the flow and adapt as needed',
            personalityType: 'Perceiver',
            score:  5,
          ),
        ],
      ),
      const QuestionModel(
        id: 'q7',
        text: 'You are more comfortable with:',
        category: 'Thinking',
        answers: [
          AnswerModel(
            id: 'q7a1',
            text: 'Debating ideas and being direct',
            personalityType: 'Thinker',
            score: 5,
          ),
          AnswerModel(
            id: 'q7a2',
            text: 'Maintaining harmony and being tactful',
            personalityType:  'Feeler',
            score: 5,
          ),
        ],
      ),
      const QuestionModel(
        id: 'q8',
        text: 'You learn best through:',
        category:  'Information',
        answers:  [
          AnswerModel(
            id: 'q8a1',
            text: 'Hands-on experience and practice',
            personalityType: 'Sensor',
            score:  5,
          ),
          AnswerModel(
            id: 'q8a2',
            text: 'Theory and conceptual understanding',
            personalityType: 'Intuitive',
            score: 5,
          ),
        ],
      ),
      const QuestionModel(
        id: 'q9',
        text: 'After a long week, you feel recharged by:',
        category:  'Social',
        answers:  [
          AnswerModel(
            id: 'q9a1',
            text: 'Going out and socializing',
            personalityType: 'Extrovert',
            score: 5,
          ),
          AnswerModel(
            id: 'q9a2',
            text: 'Spending time alone to reflect',
            personalityType: 'Introvert',
            score: 5,
          ),
        ],
      ),
      const QuestionModel(
        id:  'q10',
        text: 'You are drawn to ideas that are:',
        category: 'Information',
        answers: [
          AnswerModel(
            id: 'q10a1',
            text: 'Practical and proven',
            personalityType: 'Sensor',
            score:  5,
          ),
          AnswerModel(
            id: 'q10a2',
            text: 'Novel and innovative',
            personalityType: 'Intuitive',
            score: 5,
          ),
        ],
      ),
    ];
  }

  String _getFallbackInsights(String personalityType) {
    final insights = {
      'Extrovert':  'You thrive in social situations and gain energy from interactions.  Consider careers in sales, teaching, or event management.',
      'Introvert': 'You excel in focused, deep work and recharge through solitude. Consider careers in writing, research, or programming.',
      'Thinker': 'You make decisions based on logic and objective analysis.  Great for careers in engineering, law, or data science.',
      'Feeler':  'You value harmony and consider people\'s feelings.  Excellent for counseling, HR, or social work.',
      'Judger': 'You prefer structure and planning. Perfect for project management, accounting, or administration.',
      'Perceiver':  'You adapt easily and keep options open. Great for entrepreneurship, creative fields, or consulting.',
      'Sensor': 'You focus on concrete facts and details. Ideal for healthcare, construction, or quality assurance.',
      'Intuitive': 'You see patterns and possibilities.  Perfect for strategy, innovation, or research roles.',
    };
    
    return insights[personalityType] ?? 'You have a unique personality with many strengths!';
  }
}