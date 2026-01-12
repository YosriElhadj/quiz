import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/quiz_repository.dart';

class SaveUser implements UseCase<void, User> {
  final QuizRepository repository;

  SaveUser(this.repository);

  @override
  Future<Either<Failure, void>> call(User user) async {
    return await repository.saveUser(user);
  }
}