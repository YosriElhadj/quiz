import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'core/theme/app_theme.dart';
import 'features/quiz/data/datasources/quiz_local_data_source.dart';
import 'features/quiz/data/datasources/quiz_remote_data_source.dart';
import 'features/quiz/data/repositories/quiz_repository_impl.dart';
import 'features/quiz/domain/usecases/calculate_result.dart';
import 'features/quiz/domain/usecases/get_questions.dart';
import 'features/quiz/domain/usecases/save_user.dart';
import 'features/quiz/presentation/bloc/quiz_bloc.dart';
import 'features/quiz/presentation/pages/welcome_screen.dart';
import 'features/quiz/presentation/pages/quiz_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialize dependencies
    final httpClient = http.Client();
    final remoteDataSource = QuizRemoteDataSourceImpl(client: httpClient);
    final localDataSource = QuizLocalDataSourceImpl(); // ✅ Now works!
    
    final repository = QuizRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
    );

    return BlocProvider(
      create: (context) => QuizBloc(
        getQuestions: GetQuestions(repository),
        saveUser: SaveUser(repository),
        calculateResult: CalculateResult(repository),
        repository: repository,
      ),
      child: MaterialApp(
        title: 'Personality Quiz',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: '/',
        routes: {
          '/': (context) => const WelcomeScreen(),
          '/quiz': (context) => const QuizScreen(),
        },
      ),
    );
  }
}