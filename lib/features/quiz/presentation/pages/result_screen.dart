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
          if (state is QuizCompleted) {
            final result = state.result;
            
            return LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 600;
                
                return SafeArea(
                  child:  CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        expandedHeight: 200,
                        pinned: true,
                        flexibleSpace: FlexibleSpaceBar(
                          title: Text(
                            'Your Results',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          background: Container(
                            decoration:  BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Theme. of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.secondary,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child:  Padding(
                          padding:  EdgeInsets.all(isSmallScreen ? 16.0 : 32.0),
                          child: Center(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 800),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Personality Type Card
                                  Card(
                                    elevation: 8,
                                    shape:  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets. all(
                                        isSmallScreen ? 24.0 : 32.0,
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            _getIconForType(result.type),
                                            size: isSmallScreen ? 64 : 80,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            result.type,
                                            style: Theme.of(context)
                                                . textTheme
                                                . headlineMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height:  8),
                                          Text(
                                            result.title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .primary,
                                                ),
                                            textAlign: TextAlign. center,
                                          ),
                                          const SizedBox(height: 24),
                                          // Score
                                          TweenAnimationBuilder<double>(
                                            duration: const Duration(seconds: 1),
                                            tween: Tween(begin: 0, end: result.score),
                                            builder: (context, value, child) {
                                              return Column(
                                                children: [
                                                  Text(
                                                    '${value.toInt()}%',
                                                    style:  Theme.of(context)
                                                        .textTheme
                                                        .displaySmall
                                                        ?. copyWith(
                                                          fontWeight: FontWeight.bold,
                                                          color: Theme.of(context)
                                                              .colorScheme
                                                              .primary,
                                                        ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  LinearProgressIndicator(
                                                    value: value / 100,
                                                    minHeight: 10,
                                                    borderRadius: BorderRadius.circular(5),
                                                  ),
                                                ],
                                              );
                                            },
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
                                      style: Theme.of(context).textTheme.bodyLarge,
                                    ),
                                  ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Strengths
                                  _SectionCard(
                                    title:  'Your Strengths',
                                    icon: Icons.star,
                                    color: Colors.green,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: result.strengths
                                          .map((strength) => Padding(
                                                padding:  const EdgeInsets.only(bottom: 8),
                                                child: Row(
                                                  crossAxisAlignment: 
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Icon(
                                                      Icons.check_circle,
                                                      color: Colors.green,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Text(
                                                        strength,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge,
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
                                    icon: Icons.trending_up,
                                    color: Colors.orange,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: result.weaknesses
                                          .map((weakness) => Padding(
                                                padding:  const EdgeInsets.only(bottom: 8),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Icon(
                                                      Icons.arrow_circle_up,
                                                      color:  Colors.orange,
                                                      size: 20,
                                                    ),
                                                    const SizedBox(width:  12),
                                                    Expanded(
                                                      child: Text(
                                                        weakness,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyLarge,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                  
                                  const SizedBox(height:  32),
                                  
                                  // Action Buttons
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton. icon(
                                          onPressed: () {
                                            context.read<QuizBloc>().add(ResetQuizEvent());
                                            Navigator.of(context).popUntil((route) => route.isFirst);
                                          },
                                          icon: const Icon(Icons.refresh),
                                          label: const Text('Retake Quiz'),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.all(16),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: FilledButton.icon(
                                          onPressed: () {
                                            // Share results logic
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Share feature coming soon! '),
                                              ),
                                            );
                                          },
                                          icon: const Icon(Icons.share),
                                          label: const Text('Share'),
                                          style: FilledButton.styleFrom(
                                            padding: const EdgeInsets. all(16),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          
          return const Center(child: CircularProgressIndicator());
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
      'Leader': Icons. emoji_events,
      'Supporter': Icons.handshake,
    };
    return icons[type] ?? Icons. psychology;
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
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child:  Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: effectiveColor),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: effectiveColor,
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