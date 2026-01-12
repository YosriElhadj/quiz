import 'package:equatable/equatable.dart';
import '../../domain/entities/question.dart';

class QuestionModel extends Question {
  const QuestionModel({
    required super.id,
    required super. text,
    required super.category,
    required super.answers,
  });

  factory QuestionModel. fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      text: json['text'] as String,
      category:  json['category'] as String,
      answers: (json['answers'] as List)
          .map((a) => AnswerModel.fromJson(a as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text':  text,
      'category': category,
      'answers': answers. map((a) => (a as AnswerModel).toJson()).toList(),
    };
  }
}

class AnswerModel extends Answer {
  const AnswerModel({
    required super.id,
    required super.text,
    required super.personalityType,
    required super. score,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      id: json['id'] as String,
      text: json['text'] as String,
      personalityType: json['personalityType'] as String,
      score: json['score'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'personalityType': personalityType,
      'score': score,
    };
  }
}