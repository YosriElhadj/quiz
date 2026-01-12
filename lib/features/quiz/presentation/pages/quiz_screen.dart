import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/quiz_bloc.dart';
import '../bloc/quiz_event.dart';
import '../bloc/quiz_state.dart';
import '../widgets/question_card.dart';
import 'result_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key?  key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  void initState() {
    super.initState();
    context.read<QuizBloc>().add(LoadQuestionsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
        title: const Text('Personality Quiz'),
        centerTitle:  true,
      ),
      body: BlocConsumer<QuizBloc, QuizState>(
        listener: (context, state) {
          if (state is QuizCompleted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const ResultScreen(),
              ),
            );
          } else if (state is QuizError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state. message)),
            );
          }
        },
        builder: (context, state) {
          if (state is QuizLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is QuestionsLoaded) {
            final question = state.questions[state.currentQuestionIndex];
            
            return Column(
              children:  [
                // Progress Bar
                LinearProgressIndicator(
                  value: state.progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey[200],
                ),
                
                // Progress Text
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Question ${state.currentQuestionIndex + 1} of ${state. questions.length}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        '${(state.progress * 100).toInt()}%',
                        style:  Theme.of(context).textTheme.titleMedium?. copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Question Card
                Expanded(
                  child: QuestionCard(
                    question:  question,
                    onAnswerSelected: (answer) {
                      context.read<QuizBloc>().add(
                        AnswerQuestionEvent(
                          questionId: question.id,
                          answerId: answer. id,
                          personalityType: answer.personalityType,
                          score: answer.score,
                        ),
                      );

                      // If last question, submit quiz
                      if (state.isLastQuestion) {
                        Future.delayed(const Duration(milliseconds: 300), () {
                          context.read<QuizBloc>().add(SubmitQuizEvent());
                        });
                      }
                    },
                  ),
                ),
              ],
            );
          }

          return const Center(
            child: Text('Something went wrong'),
          );
        },
      ),
    );
  }
}