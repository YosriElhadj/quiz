import 'package:flutter/material.dart';
import '../../domain/entities/question.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  final Function(Answer) onAnswerSelected;

  const QuestionCard({
    Key? key,
    required this. question,
    required this.onAnswerSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;
        
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius:  BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.all(isSmallScreen ? 20.0 : 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment. center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Category Badge
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      question. category. toUpperCase(),
                      style:  Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: isSmallScreen ? 24 : 32),
                
                // Question Text
                Text(
                  question.text,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                  textAlign:  TextAlign.center,
                ),
                
                SizedBox(height: isSmallScreen ? 32 : 48),
                
                // Answer Options
                ... question.answers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final answer = entry.value;
                  
                  return Padding(
                    padding: EdgeInsets. only(
                      bottom: index < question.answers.length - 1 ? 16.0 : 0,
                    ),
                    child: _AnswerButton(
                      answer: answer,
                      onPressed: () => onAnswerSelected(answer),
                      isSmallScreen: isSmallScreen,
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _AnswerButton extends StatefulWidget {
  final Answer answer;
  final VoidCallback onPressed;
  final bool isSmallScreen;

  const _AnswerButton({
    Key? key,
    required this.answer,
    required this.onPressed,
    required this.isSmallScreen,
  }) : super(key: key);

  @override
  State<_AnswerButton> createState() => _AnswerButtonState();
}

class _AnswerButtonState extends State<_AnswerButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: ElevatedButton(
        onPressed: () {
          setState(() => _isPressed = true);
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              widget. onPressed();
            }
          });
        },
        style:  ElevatedButton.styleFrom(
          padding: EdgeInsets.all(widget.isSmallScreen ?  20.0 : 24.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        child: Text(
          widget.answer. text,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}