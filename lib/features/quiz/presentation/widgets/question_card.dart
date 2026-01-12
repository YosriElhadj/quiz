import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/entities/question.dart';

class QuestionCard extends StatelessWidget {
  final Question question;
  final Function(Answer) onAnswerSelected;

  const QuestionCard({
    Key? key,
    required this.question,
    required this. onAnswerSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Question Text
          Card(
            elevation: 4,
            child:  Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                question.text,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight. w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
          
          const SizedBox(height: 40),
          
          // Answer Options
          ... question.answers.asMap().entries.map((entry) {
            final index = entry.key;
            final answer = entry.value;
            
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _AnswerButton(
                answer: answer,
                onTap: () => onAnswerSelected(answer),
              ).animate(delay: (200 * index).ms)
                  .fadeIn(duration: 400.ms)
                  .slideX(begin: 0.3, end: 0),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _AnswerButton extends StatefulWidget {
  final Answer answer;
  final VoidCallback onTap;

  const _AnswerButton({
    required this.answer,
    required this.onTap,
  });

  @override
  State<_AnswerButton> createState() => _AnswerButtonState();
}

class _AnswerButtonState extends State<_AnswerButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() => _isPressed = true);
        Future.delayed(const Duration(milliseconds: 200), () {
          widget.onTap();
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isPressed
              ? Theme.of(context).colorScheme.primary
              :  Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20.0),
        child: Text(
          widget.answer.text,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: _isPressed ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}