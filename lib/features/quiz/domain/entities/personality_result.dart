import 'package:equatable/equatable.dart';

class PersonalityResult extends Equatable {
  final String type;
  final String title;
  final String description;
  final List<String> strengths;
  final List<String> weaknesses;
  final double score;

  const PersonalityResult({
    required this.type,
    required this.title,
    required this.description,
    required this.strengths,
    required this.weaknesses,
    required this.score,
  });

  @override
  List<Object> get props => [type, title, description, strengths, weaknesses, score];
}