import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/question.dart';
import '../entities/personality_result.dart';
import '../entities/user.dart';

abstract class QuizRepository {
  Future<Either<Failure, List<Question>>> getQuestions();
  Future<Either<Failure, PersonalityResult>> calculateResult(
    Map<String, int> answers,
  );
  Future<Either<Failure, void>> saveUser(User user);
  Future<Either<Failure, User? >> getUser();
  Future<Either<Failure, String>> getAIInsights(PersonalityResult result);
}