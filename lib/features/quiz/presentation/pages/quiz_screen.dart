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
      appBar: AppBar(
        title: const Text('Personality Quiz'),
        centerTitle: true,
        elevation: 0,
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
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is QuizLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Loading questions...',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          if (state is QuestionsLoaded) {
            // FIX: Check if currentQuestionIndex is within bounds
            if (state.currentQuestionIndex >= state.questions.length) {
              // This shouldn't happen, but handle it gracefully
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final question = state.questions[state. currentQuestionIndex];
            
            return LayoutBuilder(
              builder: (context, constraints) {
                // Responsive design
                final isSmallScreen = constraints.maxWidth < 600;
                final padding = isSmallScreen ? 16.0 : 32.0;
                
                return Column(
                  children: [
                    // Progress Bar with Animation
                    TweenAnimationBuilder<double>(
                      duration: const Duration(milliseconds: 300),
                      tween: Tween(begin: 0, end: state.progress),
                      builder: (context, value, child) {
                        return LinearProgressIndicator(
                          value: value,
                          minHeight: 8,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        );
                      },
                    ),
                    
                    // Progress Text
                    Container(
                      padding: EdgeInsets.all(padding),
                      child:  Row(
                        mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'Question ${state.currentQuestionIndex + 1} of ${state. questions.length}',
                              style: Theme.of(context).textTheme.titleMedium?. copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer,
                              borderRadius:  BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${(state.progress * 100).toInt()}%',
                              style: Theme. of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme. of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Question Card
                    Expanded(
                      child: Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 800),
                          padding: EdgeInsets.symmetric(horizontal: padding),
                          child: QuestionCard(
                            question: question,
                            onAnswerSelected: (answer) {
                              context.read<QuizBloc>().add(
                                AnswerQuestionEvent(
                                  questionId: question.id,
                                  answerId: answer.id,
                                  personalityType: answer.personalityType,
                                  score: answer.score,
                                ),
                              );

                              // If last question, submit quiz after a short delay
                              if (state. isLastQuestion) {
                                Future.delayed(const Duration(milliseconds: 500), () {
                                  if (context.mounted) {
                                    context.read<QuizBloc>().add(SubmitQuizEvent());
                                  }
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size:  64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'Something went wrong',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed:  () {
                    context.read<QuizBloc>().add(LoadQuestionsEvent());
                  },
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}