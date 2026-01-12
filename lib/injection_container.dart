import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'features/quiz/data/datasources/quiz_local_data_source.dart';
import 'features/quiz/data/datasources/quiz_remote_data_source.dart';
import 'features/quiz/data/repositories/quiz_repository_impl.dart';
import 'features/quiz/domain/repositories/quiz_repository.dart';
import 'features/quiz/domain/usecases/calculate_result.dart';
import 'features/quiz/domain/usecases/get_questions.dart';
import 'features/quiz/domain/usecases/save_user.dart';
import 'features/quiz/presentation/bloc/quiz_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //!  Features - Quiz
  
  // Bloc
  sl.registerFactory(
    () => QuizBloc(
      getQuestions: sl(),
      saveUser: sl(),
      calculateResult: sl(),
      repository: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetQuestions(sl()));
  sl.registerLazySingleton(() => SaveUser(sl()));
  sl.registerLazySingleton(() => CalculateResult(sl()));

  // Repository
  sl.registerLazySingleton<QuizRepository>(
    () => QuizRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<QuizRemoteDataSource>(
    () => QuizRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<QuizLocalDataSource>(
    () => QuizLocalDataSourceImpl(sharedPreferences:  sl()),
  );

  //! Core

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
}