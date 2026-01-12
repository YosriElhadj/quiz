import '../../domain/entities/personality_result.dart';

class PersonalityResultModel extends PersonalityResult {
  const PersonalityResultModel({
    required super.type,
    required super.title,
    required super.description,
    required super.strengths,
    required super.weaknesses,
    required super.score,
  });

  factory PersonalityResultModel.fromJson(Map<String, dynamic> json) {
    return PersonalityResultModel(
      type:  json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      strengths: List<String>.from(json['strengths'] as List),
      weaknesses: List<String>.from(json['weaknesses'] as List),
      score: (json['score'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'title': title,
      'description': description,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'score': score,
    };
  }
}