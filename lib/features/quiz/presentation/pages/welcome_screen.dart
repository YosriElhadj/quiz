import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'user_info_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child:  Padding(
          padding: const EdgeInsets.all(24. 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App Logo/Icon
              Icon(
                Icons.psychology_rounded,
                size: 120,
                color: Theme.of(context).colorScheme.primary,
              ).animate().scale(duration: 600.ms, curve: Curves.easeOut),
              
              const SizedBox(height:  32),
              
              // Title
              Text(
                'Personality Quiz',
                style: Theme.of(context).textTheme.headlineLarge?. copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme. of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),
              
              const SizedBox(height: 16),
              
              // Subtitle
              Text(
                'Discover Your True Self',
                style: Theme. of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign. center,
              ).animate().fadeIn(delay: 400.ms),
              
              const SizedBox(height: 48),
              
              // Description Card
              Card(
                elevation:  2,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      _buildFeatureItem(
                        context,
                        Icons.quiz,
                        'Answer 10 quick questions',
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureItem(
                        context,
                        Icons.psychology,
                        'Get your personality type',
                      ),
                      const SizedBox(height: 16),
                      _buildFeatureItem(
                        context,
                        Icons.auto_awesome,
                        'Receive AI-powered insights',
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0),
              
              const SizedBox(height: 48),
              
              // Get Started Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:  (context) => const UserInfoScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(fontSize: 18),
                ),
              ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2, end: 0),
              
              const SizedBox(height: 16),
              
              // Info Text
              Text(
                'Takes only 2-3 minutes',
                style:  Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 1000.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
          size: 28,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            text,
            style:  Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}