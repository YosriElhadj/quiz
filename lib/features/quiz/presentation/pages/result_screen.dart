import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import '../bloc/quiz_bloc.dart';
import '../bloc/quiz_event.dart';
import '../bloc/quiz_state.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<QuizBloc, QuizState>(
        builder: (context, state) {
          if (state is QuizLoading) {
            return _buildLoadingState(context);
          }

          if (state is QuizCompleted) {
            return _buildResultContent(context, state);
          }
          
          return _buildErrorState(context);
        },
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context) {
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
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 3,
            ),
            SizedBox(height: 24),
            Text(
              'Analyzing your personality...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultContent(BuildContext context, QuizCompleted state) {
    final result = state.result;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.05),
            Colors.white,
          ],
        ),
      ),
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: Theme.of(context).colorScheme.primary,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'Your Personality Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background: Container(
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
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: () {
                      _showShareDialog(context, result);
                    },
                  ),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildMainPersonalityCard(context, result),
                      const SizedBox(height: 24),
                      _buildScoreBreakdown(context, result),
                      const SizedBox(height: 24),
                      _buildPersonalityRadar(context, result),
                      const SizedBox(height: 24),
                      _buildDetailedDescription(context, result),
                      const SizedBox(height: 24),
                      _buildStrengthsSection(context, result),
                      const SizedBox(height: 24),
                      _buildGrowthAreasSection(context, result),
                      const SizedBox(height: 24),
                      _buildCareerPaths(context, result),
                      const SizedBox(height: 24),
                      _buildFamousPeople(context, result),
                      const SizedBox(height: 24),
                      _buildCompatibility(context, result),
                      const SizedBox(height: 24),
                      _buildDailyTips(context, result),
                      const SizedBox(height: 32),
                      _buildActionButtons(context),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainPersonalityCard(BuildContext context, dynamic result) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Card(
            elevation: 12,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                    Theme.of(context).colorScheme.tertiary,
                  ],
                ),
              ),
              child: Column(
                children: [
                  TweenAnimationBuilder<double>(
                    duration: const Duration(seconds: 2),
                    tween: Tween(begin: 0.0, end: 2 * math.pi),
                    builder: (context, angle, child) {
                      return Transform.rotate(
                        angle: angle,
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _getIconForType(result.type as String),
                            size: 64,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    result.type as String,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result.title as String,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white.withOpacity(0.95),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 1500),
                    tween: Tween(begin: 0.0, end: (result.score as num).toDouble()),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Column(
                        children: [
                          Text(
                            '${value.toInt()}%',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Personality Match',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: value / 100,
                              minHeight: 12,
                              backgroundColor: Colors.white.withOpacity(0.3),
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildScoreBreakdown(BuildContext context, dynamic result) {
    final scores = {
      'Extroversion': result.type == 'Extrovert' ? 85.0 : 35.0,
      'Thinking': result.type == 'Thinker' ? 80.0 : 40.0,
      'Judging': result.type == 'Judger' ? 75.0 : 45.0,
      'Analytical': result.type == 'Analytical' ? 90.0 : 30.0,
      'Leadership': result.type == 'Leader' ? 85.0 : 40.0,
    };

    return _SectionCard(
      title: 'Trait Breakdown',
      icon: Icons.analytics,
      child: Column(
        children: scores.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildTraitBar(context, entry.key, entry.value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTraitBar(BuildContext context, String trait, double score) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              trait,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${score.toInt()}%',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 1000),
          tween: Tween(begin: 0.0, end: score),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: value / 100,
                minHeight: 10,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getColorForScore(value),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPersonalityRadar(BuildContext context, dynamic result) {
    return _SectionCard(
      title: 'Personality Dimensions',
      icon: Icons.radar,
      child: SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.insights,
                size: 80,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
              const SizedBox(height: 16),
              Text(
                '5-Dimension Personality Map',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Visual representation of your trait balance',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedDescription(BuildContext context, dynamic result) {
    return _SectionCard(
      title: 'About Your Personality',
      icon: Icons.psychology,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            result.description as String,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This personality type represents approximately ${_getPopulationPercentage(result.type as String)}% of the population.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthsSection(BuildContext context, dynamic result) {
    return _SectionCard(
      title: 'Your Superpowers',
      icon: Icons.emoji_events,
      color: Colors.green,
      child: Column(
        children: [
          ...(result.strengths as List).asMap().entries.map((entry) {
            final index = entry.key;
            final strength = entry.value as String;
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 300 + (index * 100)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              strength,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGrowthAreasSection(BuildContext context, dynamic result) {
    return _SectionCard(
      title: 'Growth Opportunities',
      icon: Icons.trending_up,
      color: Colors.orange,
      child: Column(
        children: [
          ...(result.weaknesses as List).asMap().entries.map((entry) {
            final index = entry.key;
            final weakness = entry.value as String;
            return TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 300 + (index * 100)),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, 20 * (1 - value)),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_upward,
                              color: Colors.orange,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              weakness,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCareerPaths(BuildContext context, dynamic result) {
    final careers = _getCareerPaths(result.type as String);
    
    return _SectionCard(
      title: 'Ideal Career Paths',
      icon: Icons.work,
      color: Colors.blue,
      child: Column(
        children: careers.map((career) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.1),
                  Colors.blue.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    career['icon'] as IconData,
                    color: Colors.blue,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        career['title'] as String,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        career['description'] as String,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFamousPeople(BuildContext context, dynamic result) {
    final famousPeople = _getFamousPeople(result.type as String);
    
    return _SectionCard(
      title: 'Famous People Like You',
      icon: Icons.stars,
      color: Colors.purple,
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        children: famousPeople.map((person) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.withOpacity(0.2),
                  Colors.purple.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.purple.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person, color: Colors.purple, size: 20),
                const SizedBox(width: 8),
                Text(
                  person,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCompatibility(BuildContext context, dynamic result) {
    final compatible = _getCompatibleTypes(result.type as String);
    
    return _SectionCard(
      title: 'Personality Compatibility',
      icon: Icons.favorite,
      color: Colors.pink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Most Compatible With:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.pink,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: compatible['best']!.map((type) {
              return Chip(
                avatar: const Icon(Icons.favorite, size: 16, color: Colors.pink),
                label: Text(type),
                backgroundColor: Colors.pink.withOpacity(0.1),
                side: BorderSide(color: Colors.pink.withOpacity(0.3)),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            'May Challenge You:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: compatible['challenging']!.map((type) {
              return Chip(
                avatar: const Icon(Icons.people, size: 16, color: Colors.grey),
                label: Text(type),
                backgroundColor: Colors.grey.withOpacity(0.1),
                side: BorderSide(color: Colors.grey.withOpacity(0.3)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTips(BuildContext context, dynamic result) {
    final tips = _getDailyTips(result.type as String);
    
    return _SectionCard(
      title: 'Daily Success Tips',
      icon: Icons.tips_and_updates,
      color: Colors.amber,
      child: Column(
        children: tips.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Colors.amber,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${entry.key + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.value,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  context.read<QuizBloc>().add(ResetQuizEvent());
                  Navigator.of(context).pushReplacementNamed('/');
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retake Quiz'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  _showShareDialog(context, null);
                },
                icon: const Icon(Icons.share),
                label: const Text('Share'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('PDF download coming soon!'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          icon: const Icon(Icons.download),
          label: const Text('Download Full Report'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(16),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context) {
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
            const Icon(Icons.error_outline, size: 80, color: Colors.white),
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
  }

  // Helper methods
  IconData _getIconForType(String type) {
    final icons = {
      'Extrovert': Icons.groups,
      'Introvert': Icons.person,
      'Thinker': Icons.lightbulb,
      'Feeler': Icons.favorite,
      'Judger': Icons.rule,
      'Perceiver': Icons.explore,
      'Analytical': Icons.analytics,
      'Creative': Icons.palette,
      'Leader': Icons.emoji_events,
      'Supporter': Icons.handshake,
    };
    return icons[type] ?? Icons.psychology;
  }

  Color _getColorForScore(double score) {
    if (score >= 75) return Colors.green;
    if (score >= 50) return Colors.blue;
    if (score >= 25) return Colors.orange;
    return Colors.red;
  }

  String _getPopulationPercentage(String type) {
    final percentages = {
      'Extrovert': '50-74',
      'Introvert': '25-40',
      'Thinker': '40-50',
      'Feeler': '40-50',
      'Judger': '45-55',
      'Perceiver': '45-55',
      'Analytical': '20-30',
      'Creative': '15-25',
      'Leader': '10-15',
      'Supporter': '30-40',
    };
    return percentages[type] ?? '20-30';
  }

  List<Map<String, dynamic>> _getCareerPaths(String type) {
    final careers = {
      'Extrovert': [
        {'icon': Icons.business, 'title': 'Sales & Marketing', 'description': 'Your charisma wins clients'},
        {'icon': Icons.event, 'title': 'Event Management', 'description': 'Create unforgettable experiences'},
        {'icon': Icons.campaign, 'title': 'Public Relations', 'description': 'Be the face people trust'},
      ],
      'Introvert': [
        {'icon': Icons.code, 'title': 'Software Development', 'description': 'Deep focus is your superpower'},
        {'icon': Icons.edit, 'title': 'Writing & Research', 'description': 'Your depth shines through words'},
        {'icon': Icons.design_services, 'title': 'Design', 'description': 'Your inner world creates beauty'},
      ],
      'Thinker': [
        {'icon': Icons.engineering, 'title': 'Engineering', 'description': 'Solve complex technical puzzles'},
        {'icon': Icons.account_balance, 'title': 'Finance & Law', 'description': 'Logic is your weapon'},
        {'icon': Icons.science, 'title': 'Research', 'description': 'Discover through analysis'},
      ],
      'Leader': [
        {'icon': Icons.business_center, 'title': 'Management', 'description': 'Guide teams to success'},
        {'icon': Icons.rocket_launch, 'title': 'Entrepreneurship', 'description': 'Build your empire'},
        {'icon': Icons.military_tech, 'title': 'Executive Roles', 'description': 'Make strategic decisions'},
      ],
    };
    return careers[type] ?? careers['Extrovert']!;
  }

  List<String> _getFamousPeople(String type) {
    final famous = {
      'Extrovert': ['Oprah Winfrey', 'Bill Clinton', 'Robin Williams', 'Tom Hanks'],
      'Introvert': ['Bill Gates', 'J.K. Rowling', 'Albert Einstein', 'Mark Zuckerberg'],
      'Thinker': ['Elon Musk', 'Marie Curie', 'Isaac Newton', 'Bill Gates'],
      'Leader': ['Winston Churchill', 'Steve Jobs', 'Margaret Thatcher', 'Napoleon Bonaparte'],
      'Creative': ['Pablo Picasso', 'Leonardo da Vinci', 'Salvador Dalí', 'Frida Kahlo'],
    };
    return famous[type] ?? ['Various inspirational figures'];
  }

  Map<String, List<String>> _getCompatibleTypes(String type) {
    return {
      'best': ['Supporter', 'Feeler', 'Creative'],
      'challenging': ['Judger', 'Analytical'],
    };
  }

  List<String> _getDailyTips(String type) {
    final tips = {
      'Extrovert': [
        'Schedule social activities to maintain your energy',
        'Balance networking with quiet reflection time',
        'Use your enthusiasm to motivate others',
        'Practice active listening in conversations',
      ],
      'Introvert': [
        'Protect your alone time for recharging',
        'Choose quality over quantity in friendships',
        'Leverage your deep thinking in decision-making',
        'Communicate your need for space to others',
      ],
      'Leader': [
        'Practice delegating to develop others',
        'Listen before directing',
        'Share credit generously with your team',
        'Lead with empathy, not just authority',
      ],
    };
    return tips[type] ?? tips['Extrovert']!;
  }

  void _showShareDialog(BuildContext context, dynamic result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Your Results'),
        content: const Text('Share your personality profile with friends!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing feature coming soon!')),
              );
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }
}

// Section Card Widget
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Color? color;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Theme.of(context).colorScheme.primary;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: effectiveColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: effectiveColor, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: effectiveColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}