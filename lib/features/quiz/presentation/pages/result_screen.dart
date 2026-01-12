import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/quiz_bloc.dart';
import '../bloc/quiz_event.dart';
import '../bloc/quiz_state.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<QuizBloc, QuizState>(
        builder: (context, state) {
          // Handle loading state
          if (state is QuizLoading) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
              child: Center(
                child:  Column(
                  mainAxisAlignment:  MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Analyzing your personality...',
                      style: Theme.of(context).textTheme.titleLarge?. copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Handle completed state
          if (state is QuizCompleted) {
            final result = state.result;
            
            return Container(
              decoration:  BoxDecoration(
                gradient:  LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment. bottomRight,
                  colors:  [
                    Theme.of(context).colorScheme.primary. withOpacity(0.1),
                    Theme.of(context).colorScheme.secondary. withOpacity(0.1),
                  ],
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Your Results',
                            style: Theme. of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              context.read<QuizBloc>().add(ResetQuizEvent());
                              Navigator.of(context).pushReplacementNamed('/');
                            },
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Personality Type Card
                      Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin:  Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _getIconForType(result.type),
                                size: 80,
                                color: Colors. white,
                              ),
                              const SizedBox(height:  16),
                              Text(
                                result.type,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                result.title,
                                style: Theme. of(context)
                                    .textTheme
                                    .titleLarge
                                    ?. copyWith(
                                      color: Colors.white. withOpacity(0.9),
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              // Score
                              Text(
                                '${result.score. toInt()}%',
                                style: Theme. of(context)
                                    .textTheme
                                    .displayMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: result.score / 100,
                                minHeight: 8,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Description
                      _SectionCard(
                        title: 'About You',
                        icon: Icons.psychology,
                        child: Text(
                          result.description,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.6,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Strengths
                      _SectionCard(
                        title: 'Your Strengths',
                        icon: Icons.star,
                        color: Colors.green,
                        child: Column(
                          crossAxisAlignment:  CrossAxisAlignment.start,
                          children: result.strengths
                              .map((strength) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 20,
                                        ),
                                        const SizedBox(width:  12),
                                        Expanded(
                                          child:  Text(
                                            strength,
                                            style: Theme. of(context).textTheme.bodyLarge,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Weaknesses
                      _SectionCard(
                        title: 'Areas for Growth',
                        icon: Icons. trending_up,
                        color:  Colors.orange,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: result.weaknesses
                              .map((weakness) => Padding(
                                    padding:  const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment. start,
                                      children:  [
                                        Icon(
                                          Icons.arrow_circle_up,
                                          color: Colors.orange,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            weakness,
                                            style: Theme.of(context).textTheme.bodyLarge,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton. icon(
                              onPressed:  () {
                                context.read<QuizBloc>().add(ResetQuizEvent());
                                Navigator.of(context).pushReplacementNamed('/');
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retake Quiz'),
                              style:  OutlinedButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Share feature coming soon!'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.share),
                              label: const Text('Share'),
                              style: FilledButton.styleFrom(
                                padding: const EdgeInsets.all(16),
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          }
          
          // Fallback for error or unknown state
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size:  80,
                    color:  Colors.white,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Something went wrong',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<QuizBloc>().add(ResetQuizEvent());
                      Navigator.of(context).pushReplacementNamed('/');
                    },
                    child: const Text('Start Over'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getIconForType(String type) {
    final icons = {
      'Extrovert': Icons.groups,
      'Introvert':  Icons.person,
      'Thinker': Icons.lightbulb,
      'Feeler': Icons.favorite,
      'Judger':  Icons.rule,
      'Perceiver':  Icons.explore,
      'Analytical': Icons.analytics,
      'Creative': Icons.palette,
      'Leader': Icons.emoji_events,
      'Supporter': Icons.handshake,
    };
    return icons[type] ?? Icons.psychology;
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Color?  color;

  const _SectionCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.child,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    
    return Card(
      elevation:  2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: effectiveColor, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: effectiveColor,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}