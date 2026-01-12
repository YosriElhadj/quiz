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
      print('🧮 Starting result calculation...');
      print('📊 Answers received: $answers');
      
      // Validate answers
      if (answers. isEmpty) {
        print('❌ No answers provided');
        return Left(ServerFailure('No answers provided'));
      }

      // Calculate personality scores
      final Map<String, int> scores = {};
      
      answers.forEach((key, value) {
        scores[key] = (scores[key] ?? 0) + value;
      });

      print('📈 Calculated scores: $scores');

      // Find dominant personality type
      String dominantType = scores.entries
          .reduce((a, b) => a.value > b.value ?  a :  b)
          .key;

      print('🎯 Dominant personality type: $dominantType');

      // Get personality data
      final personalityData = _getPersonalityData(dominantType);
      
      // Calculate percentage score
      final totalScore = scores.values.fold(0, (a, b) => a + b);
      final dominantScore = scores[dominantType] ?? 0;
      final percentageScore = totalScore > 0 
          ? (dominantScore / totalScore) * 100 
          : 50.0;

      print('💯 Percentage score: ${percentageScore.toStringAsFixed(1)}%');

      final result = PersonalityResultModel(
        type: dominantType,
        title: personalityData['title']!,
        description:  personalityData['description']!,
        strengths: List<String>.from(personalityData['strengths']!),
        weaknesses: List<String>.from(personalityData['weaknesses']! ),
        score: percentageScore,
      );

      print('✅ Result calculated successfully');
      return Right(result);
    } catch (e, stackTrace) {
      print('❌ Error calculating result: $e');
      print('Stack trace: $stackTrace');
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
  Future<Either<Failure, User?>> getUser() async {
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
        result.type,
        result.description,
      );
      return Right(insights);
    } catch (e) {
      return Left(NetworkFailure('Failed to get AI insights: ${e.toString()}'));
    }
  }

  // Personality type data - COMPLETE LIST
  Map<String, dynamic> _getPersonalityData(String type) {
    final data = {
      'Extrovert': {
        'title': 'The Social Energizer',
        'description': 'You are outgoing, energetic, and thrive in social situations. You gain energy from being around others and enjoy being the center of attention.',
        'strengths': [
          'Great communicator and networker',
          'Enthusiastic and motivating',
          'Builds relationships easily',
          'Adaptable in social situations'
        ],
        'weaknesses': [
          'May dominate conversations',
          'Can be impulsive in decisions',
          'Needs external validation',
          'May struggle with solitude'
        ],
      },
      'Introvert':  {
        'title': 'The Thoughtful Observer',
        'description': 'You are thoughtful, introspective, and prefer deeper one-on-one connections.  You recharge through alone time and reflection.',
        'strengths': [
          'Deep thinker and analyzer',
          'Excellent listener',
          'Independent and self-sufficient',
          'Observant and detail-oriented'
        ],
        'weaknesses': [
          'May seem distant or reserved',
          'Can overthink situations',
          'Reluctant to speak up in groups',
          'May avoid networking opportunities'
        ],
      },
      'Thinker': {
        'title': 'The Logical Analyst',
        'description': 'You make decisions based on logic, facts, and objective analysis. You value truth and fairness above all.',
        'strengths': [
          'Logical and rational decision-maker',
          'Objective and fair',
          'Excellent problem-solver',
          'Direct and honest communicator'
        ],
        'weaknesses': [
          'May seem cold or insensitive',
          'Can be overly critical',
          'Struggles with emotional situations',
          'May overlook feelings of others'
        ],
      },
      'Feeler': {
        'title': 'The Empathetic Heart',
        'description': 'You prioritize people\'s feelings and values in decision-making. You seek harmony and deep connections in relationships.',
        'strengths': [
          'Empathetic and compassionate',
          'Excellent at conflict resolution',
          'Values-driven and authentic',
          'Builds strong, lasting relationships'
        ],
        'weaknesses': [
          'May avoid difficult decisions',
          'Can take criticism personally',
          'May be too accommodating',
          'Struggles with confrontation'
        ],
      },
      'Judger': {
        'title': 'The Organized Planner',
        'description':  'You prefer structure, planning, and organization. You like to have things decided and under control.',
        'strengths': [
          'Highly organized and efficient',
          'Consistently meets deadlines',
          'Decisive and action-oriented',
          'Reliable and responsible'
        ],
        'weaknesses': [
          'Can be rigid and inflexible',
          'May resist change',
          'Stressed by uncertainty',
          'May appear controlling'
        ],
      },
      'Perceiver': {
        'title': 'The Flexible Adapter',
        'description':  'You are flexible, spontaneous, and keep your options open. You adapt easily to changing circumstances.',
        'strengths': [
          'Flexible and adaptable',
          'Open to new information',
          'Spontaneous and creative',
          'Handles change with ease'
        ],
        'weaknesses': [
          'May procrastinate',
          'Can seem disorganized',
          'Difficulty with strict deadlines',
          'May be indecisive'
        ],
      },
      'Analytical': {
        'title': 'The Detail Master',
        'description': 'You focus on concrete facts, details, and systematic approaches. You excel at breaking down complex problems into manageable parts.',
        'strengths': [
          'Exceptional attention to detail',
          'Systematic problem-solver',
          'Data-driven decision maker',
          'Thorough and precise'
        ],
        'weaknesses': [
          'May get lost in details',
          'Can suffer from analysis paralysis',
          'May miss the big picture',
          'Can be perfectionistic'
        ],
      },
      'Creative': {
        'title': 'The Innovative Visionary',
        'description': 'You focus on patterns, possibilities, and the big picture.  You trust your instincts and imagination to see what could be.',
        'strengths':  [
          'Innovative and imaginative',
          'Sees possibilities others miss',
          'Future-oriented thinker',
          'Creative problem-solver'
        ],
        'weaknesses': [
          'May overlook important details',
          'Can be impractical at times',
          'May seem absent-minded',
          'Impatient with routine tasks'
        ],
      },
      'Leader': {
        'title': 'The Natural Commander',
        'description': 'You naturally take charge and guide others toward success. Your confidence and vision inspire those around you.',
        'strengths': [
          'Natural leadership abilities',
          'Confident decision-maker',
          'Inspires and motivates teams',
          'Strategic and goal-oriented'
        ],
        'weaknesses': [
          'Can be domineering',
          'May struggle to delegate',
          'Might not listen enough',
          'Can be impatient with others'
        ],
      },
      'Supporter': {
        'title': 'The Team Harmonizer',
        'description': 'You excel at helping others succeed and creating harmonious environments. Your support empowers those around you.',
        'strengths': [
          'Excellent team player',
          'Creates harmonious environments',
          'Empowers others to succeed',
          'Diplomatic and tactful'
        ],
        'weaknesses': [
          'May neglect own needs',
          'Can avoid necessary confrontation',
          'May struggle with self-advocacy',
          'Can be taken advantage of'
        ],
      },
    };

    // Return the personality data or a default if not found
    if (data.containsKey(type)) {
      print('✅ Found personality data for:  $type');
      return data[type]!;
    } else {
      print('⚠️ Personality type not found: $type, using default');
      return {
        'title': 'Unique Personality',
        'description':  'You have a unique combination of traits that makes you special.',
        'strengths': [
          'Versatile and adaptable',
          'Balanced perspective',
          'Open to growth',
          'Unique approach to challenges'
        ],
        'weaknesses': [
          'May lack clear direction',
          'Could benefit from self-reflection',
          'Might need to develop specific skills',
          'May struggle with identity'
        ],
      };
    }
  }
}