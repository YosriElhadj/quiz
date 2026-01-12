import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/personality_result.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/quiz_repository.dart';
import '../datasources/quiz_local_data_source.dart';
import '../datasources/quiz_remote_data_source.dart';
import '../models/personality_result_model.dart';
import '../models/user_model.dart';

class QuizRepositoryImpl implements QuizRepository {
  final QuizRemoteDataSource remoteDataSource;
  final QuizLocalDataSource localDataSource;

  QuizRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Question>>> getQuestions() async {
    try {
      final questions = await remoteDataSource. getQuestions();
      return Right(questions);
    } catch (e) {
      return Left(ServerFailure('Failed to load questions: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, PersonalityResult>> calculateResult(
    Map<String, int> answers,
  ) async {
    try {
      // Calculate personality scores
      final Map<String, int> scores = {};
      
      answers.forEach((key, value) {
        scores[key] = (scores[key] ?? 0) + value;
      });

      // Find dominant personality type
      String dominantType = scores.entries
          .reduce((a, b) => a.value > b.value ? a :  b)
          .key;

      // Get personality data
      final personalityData = _getPersonalityData(dominantType);
      
      // Calculate percentage score
      final totalScore = scores.values.fold(0, (a, b) => a + b);
      final maxPossibleScore = scores.length * 5;
      final percentageScore = (scores[dominantType]! / maxPossibleScore) * 100;

      final result = PersonalityResultModel(
        type: dominantType,
        title: personalityData['title']!,
        description: personalityData['description']!,
        strengths: List<String>.from(personalityData['strengths']!),
        weaknesses: List<String>.from(personalityData['weaknesses']! ),
        score: percentageScore,
      );

      return Right(result);
    } catch (e) {
      return Left(ServerFailure('Failed to calculate result: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> saveUser(User user) async {
    try {
      final userModel = UserModel. fromEntity(user);
      await localDataSource.cacheUser(userModel);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to save user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User? >> getUser() async {
    try {
      final user = await localDataSource.getCachedUser();
      return Right(user);
    } catch (e) {
      return Left(CacheFailure('Failed to get user: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> getAIInsights(PersonalityResult result) async {
    try {
      final insights = await remoteDataSource.getAIInsights(
        result. type,
        result.description,
      );
      return Right(insights);
    } catch (e) {
      return Left(NetworkFailure('Failed to get AI insights: ${e.toString()}'));
    }
  }

  // Personality type data
  Map<String, dynamic> _getPersonalityData(String type) {
    final data = {
      'Extrovert': {
        'title': 'The Energizer',
        'description': 'You are outgoing, energetic, and thrive in social situations. You gain energy from being around others and enjoy being the center of attention.',
        'strengths': [
          'Great communicator',
          'Enthusiastic and motivating',
          'Builds networks easily',
          'Adaptable in social situations'
        ],
        'weaknesses': [
          'May dominate conversations',
          'Can be impulsive',
          'Needs external validation',
          'May struggle with solitude'
        ],
      },
      'Introvert':  {
        'title': 'The Thinker',
        'description':  'You are thoughtful, introspective, and prefer deeper one-on-one connections. You recharge through alone time and reflection.',
        'strengths': [
          'Deep thinker',
          'Great listener',
          'Independent worker',
          'Observant and analytical'
        ],
        'weaknesses': [
          'May seem distant',
          'Can overthink situations',
          'Reluctant to speak up',
          'May avoid networking'
        ],
      },
      'Thinker': {
        'title': 'The Analyst',
        'description': 'You make decisions based on logic, facts, and objective analysis. You value truth and fairness above all.',
        'strengths':  [
          'Logical and rational',
          'Objective decision-maker',
          'Problem-solver',
          'Direct communicator'
        ],
        'weaknesses': [
          'May seem cold or insensitive',
          'Can be overly critical',
          'Struggles with emotions',
          'May overlook feelings'
        ],
      },
      'Feeler': {
        'title': 'The Harmonizer',
        'description':  'You prioritize people\'s feelings and values in decision-making. You seek harmony and connection in relationships.',
        'strengths': [
          'Empathetic and caring',
          'Great at conflict resolution',
          'Values-driven',
          'Builds strong relationships'
        ],
        'weaknesses': [
          'May avoid difficult decisions',
          'Can take criticism personally',
          'May be too accommodating',
          'Struggles with confrontation'
        ],
      },
      'Judger': {
        'title': 'The Organizer',
        'description': 'You prefer structure, planning, and organization. You like to have things decided and under control.',
        'strengths':  [
          'Organized and efficient',
          'Meets deadlines',
          'Decisive',
          'Reliable and responsible'
        ],
        'weaknesses': [
          'Can be rigid',
          'May resist change',
          'Stressed by uncertainty',
          'May be controlling'
        ],
      },
      'Perceiver': {
        'title': 'The Adapter',
        'description': 'You are flexible, spontaneous, and keep your options open. You adapt easily to changing circumstances.',
        'strengths': [
          'Flexible and adaptable',
          'Open to new information',
          'Spontaneous',
          'Handles change well'
        ],
        'weaknesses': [
          'May procrastinate',
          'Can seem disorganized',
          'Difficulty with deadlines',
          'May be indecisive'
        ],
      },
      'Sensor':  {
        'title': 'The Realist',
        'description': 'You focus on concrete facts, details, and practical applications. You trust what you can see and experience.',
        'strengths': [
          'Practical and realistic',
          'Detail-oriented',
          'Lives in the present',
          'Good with facts'
        ],
        'weaknesses': [
          'May miss the big picture',
          'Can be too focused on details',
          'Resistant to abstract ideas',
          'May lack vision'
        ],
      },
      'Intuitive': {
        'title': 'The Visionary',
        'description':  'You focus on patterns, possibilities, and the big picture. You trust your instincts and imagination.',
        'strengths': [
          'Innovative and creative',
          'Sees possibilities',
          'Future-oriented',
          'Strategic thinker'
        ],
        'weaknesses': [
          'May overlook details',
          'Can be impractical',
          'May seem absent-minded',
          'Impatient with routine'
        ],
      },
    };

    return data[type] ?? data['Extrovert']!;
  }
}