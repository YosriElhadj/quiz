import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String fullName;
  final DateTime dateOfBirth;
  final String? email;
  final String? gender;

  const User({
    required this.fullName,
    required this.dateOfBirth,
    this.email,
    this. gender,
  });

  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth. month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  @override
  List<Object? > get props => [fullName, dateOfBirth, email, gender];
}