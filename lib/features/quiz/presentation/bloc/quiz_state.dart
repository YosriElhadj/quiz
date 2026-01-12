import 'package:equatable/equatable.dart';
import '../../domain/entities/personality_result.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/user.dart';

abstract class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object?> get props => [];
}

class QuizInitial extends QuizState {}

class QuizLoading extends QuizState {}

class QuestionsLoaded extends QuizState {
  final List<Question> questions;
  final int currentQuestionIndex;
  final Map<String, int> answers;

  const QuestionsLoaded({
    required this.questions,
    this.currentQuestionIndex = 0,
    this.answers = const {},
  });

  @override
  List<Object?> get props => [questions, currentQuestionIndex, answers];

  QuestionsLoaded copyWith({
    List<Question>? questions,
    int? currentQuestionIndex,
    Map<String, int>? answers,
  }) {
    return QuestionsLoaded(
      questions: questions ?? this.questions,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      answers: answers ?? this.answers,
    );
  }

  bool get isLastQuestion => currentQuestionIndex >= questions.length - 1;
  double get progress => (currentQuestionIndex + 1) / questions.length;
}

class UserSaved extends QuizState {
  final User user;

  const UserSaved(this.user);

  @override
  List<Object?> get props => [user];
}

class QuizCompleted extends QuizState {
  final PersonalityResult result;
  final String?  aiInsights;

  const QuizCompleted({
    required this. result,
    this.aiInsights,
  });

  @override
  List<Object?> get props => [result, aiInsights];

  QuizCompleted copyWith({
    PersonalityResult? result,
    String? aiInsights,
  }) {
    return QuizCompleted(
      result: result ?? this.result,
      aiInsights: aiInsights ?? this.aiInsights,
    );
  }
}

class QuizError extends QuizState {
  final String message;

  const QuizError(this.message);

  @override
  List<Object?> get props => [message];
}