import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/calculate_result.dart';
import '../../domain/usecases/get_questions.dart';
import '../../domain/usecases/save_user.dart';
import '../../domain/repositories/quiz_repository.dart';
import 'quiz_event.dart';
import 'quiz_state.dart';

class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final GetQuestions getQuestions;
  final SaveUser saveUser;
  final CalculateResult calculateResult;
  final QuizRepository repository;

  QuizBloc({
    required this.getQuestions,
    required this.saveUser,
    required this.calculateResult,
    required this.repository,
  }) : super(QuizInitial()) {
    on<LoadQuestionsEvent>(_onLoadQuestions);
    on<AnswerQuestionEvent>(_onAnswerQuestion);
    on<SubmitQuizEvent>(_onSubmitQuiz);
    on<SaveUserEvent>(_onSaveUser);
    on<LoadAIInsightsEvent>(_onLoadAIInsights);
    on<ResetQuizEvent>(_onResetQuiz);
  }

  Future<void> _onLoadQuestions(
    LoadQuestionsEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());

    final result = await getQuestions(NoParams());

    result.fold(
      (failure) => emit(QuizError(failure.message)),
      (questions) => emit(QuestionsLoaded(questions: questions)),
    );
  }

  void _onAnswerQuestion(
    AnswerQuestionEvent event,
    Emitter<QuizState> emit,
  ) {
    if (state is QuestionsLoaded) {
      final currentState = state as QuestionsLoaded;
      
      final updatedAnswers = Map<String, int>.from(currentState.answers);
      updatedAnswers[event.personalityType] = 
          (updatedAnswers[event. personalityType] ?? 0) + event.score;

      final nextIndex = currentState.currentQuestionIndex + 1;

      emit(currentState.copyWith(
        currentQuestionIndex: nextIndex,
        answers: updatedAnswers,
      ));
    }
  }

  Future<void> _onSubmitQuiz(
    SubmitQuizEvent event,
    Emitter<QuizState> emit,
  ) async {
    if (state is QuestionsLoaded) {
      final currentState = state as QuestionsLoaded;
      emit(QuizLoading());

      final result = await calculateResult(currentState.answers);

      result.fold(
        (failure) => emit(QuizError(failure.message)),
        (personalityResult) => emit(QuizCompleted(result: personalityResult)),
      );
    }
  }

  Future<void> _onSaveUser(
    SaveUserEvent event,
    Emitter<QuizState> emit,
  ) async {
    emit(QuizLoading());

    final result = await saveUser(event.user);

    result.fold(
      (failure) => emit(QuizError(failure.message)),
      (_) => emit(UserSaved(event.user)),
    );
  }

  Future<void> _onLoadAIInsights(
    LoadAIInsightsEvent event,
    Emitter<QuizState> emit,
  ) async {
    if (state is QuizCompleted) {
      final currentState = state as QuizCompleted;
      
      final result = await repository.getAIInsights(currentState.result);

      result.fold(
        (failure) {
          // Keep current state even if AI fails
        },
        (insights) {
          emit(currentState.copyWith(aiInsights: insights));
        },
      );
    }
  }

  void _onResetQuiz(
    ResetQuizEvent event,
    Emitter<QuizState> emit,
  ) {
    emit(QuizInitial());
  }
}