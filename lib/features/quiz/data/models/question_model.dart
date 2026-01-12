import '../../domain/entities/question.dart';

class QuestionModel extends Question {
  const QuestionModel({
    required super.id,
    required super. text,
    required super.answers,
    required super.category,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      text: json['text'] as String,
      answers: (json['answers'] as List)
          .map((answer) => AnswerModel.fromJson(answer))
          .toList(),
      category: json['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'answers': answers
          .map((answer) => (answer as AnswerModel).toJson())
          .toList(),
      'category': category,
    };
  }
}

class AnswerModel extends Answer {
  const AnswerModel({
    required super.id,
    required super.text,
    required super.personalityType,
    required super.score,
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
      'text':  text,
      'personalityType': personalityType,
      'score': score,
    };
  }
}