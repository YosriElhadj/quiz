import 'package:equatable/equatable.dart';

class Question extends Equatable {
  final String id;
  final String text;
  final List<Answer> answers;
  final String category;

  const Question({
    required this.id,
    required this. text,
    required this.answers,
    required this.category,
  });

  @override
  List<Object> get props => [id, text, answers, category];
}

class Answer extends Equatable {
  final String id;
  final String text;
  final String personalityType;
  final int score;

  const Answer({
    required this.id,
    required this.text,
    required this.personalityType,
    required this.score,
  });

  @override
  List<Object> get props => [id, text, personalityType, score];
}