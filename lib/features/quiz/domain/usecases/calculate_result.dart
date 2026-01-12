import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/personality_result.dart';
import '../repositories/quiz_repository.dart';

class CalculateResult implements UseCase<PersonalityResult, Map<String, int>> {
  final QuizRepository repository;

  CalculateResult(this.repository);

  @override
  Future<Either<Failure, PersonalityResult>> call(Map<String, int> answers) async {
    return await repository.calculateResult(answers);
  }
}