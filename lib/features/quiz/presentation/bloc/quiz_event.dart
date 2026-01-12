import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class QuizEvent extends Equatable {
  const QuizEvent();

  @override
  List<Object?> get props => [];
}

class LoadQuestionsEvent extends QuizEvent {}

class AnswerQuestionEvent extends QuizEvent {
  final String questionId;
  final String answerId;
  final String personalityType;
  final int score;

  const AnswerQuestionEvent({
    required this.questionId,
    required this.answerId,
    required this.personalityType,
    required this.score,
  });

  @override
  List<Object?> get props => [questionId, answerId, personalityType, score];
}

class SubmitQuizEvent extends QuizEvent {}

class SaveUserEvent extends QuizEvent {
  final User user;

  const SaveUserEvent(this.user);

  @override
  List<Object?> get props => [user];
}

class LoadAIInsightsEvent extends QuizEvent {}

class ResetQuizEvent extends QuizEvent {}