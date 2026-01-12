import 'package:flutter/material.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _floatingController;
  late AnimationController _fadeController;
  late Animation<double> _floatingAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _floatingAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(parent: _floatingController, curve:  Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _floatingController. dispose();
    _fadeController. dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin:  Alignment.topLeft,
            end: Alignment. bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
              Theme.of(context).colorScheme.tertiary,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity:  _fadeAnimation,
            child:  LayoutBuilder(
              builder: (context, constraints) {
                final isSmallScreen = constraints.maxWidth < 600;
                
                return SingleChildScrollView(
                  child:  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 24.0 : 48.0,
                      vertical: 32.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: isSmallScreen ? 40 : 60),
                        
                        // Floating Icon
                        AnimatedBuilder(
                          animation: _floatingAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _floatingAnimation.value),
                              child: child,
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(isSmallScreen ? 20 : 32),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 30,
                                  spreadRadius:  5,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.psychology,
                              size: isSmallScreen ? 50 : 70,
                              color: Colors. white,
                            ),
                          ),
                        ),

                        SizedBox(height: isSmallScreen ? 24 : 40),

                        // Title
                        Text(
                          'Discover Your\nTrue Self',
                          style: (isSmallScreen 
                            ? Theme.of(context).textTheme.headlineMedium
                            : Theme.of(context).textTheme.displaySmall
                          )?.copyWith(
                            color: Colors. white,
                            fontWeight:  FontWeight.bold,
                            height: 1.2,
                          ),
                          textAlign:  TextAlign.center,
                        ),

                        SizedBox(height: isSmallScreen ? 12 : 20),

                        // Subtitle
                        Container(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: Text(
                            'Take our AI-powered personality assessment to uncover your unique traits, strengths, and potential.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        SizedBox(height: isSmallScreen ? 24 : 40),

                        // Features
                        Container(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: Column(
                            children: [
                              _FeatureItem(
                                icon: Icons.auto_awesome,
                                title:  'AI-Generated Questions',
                                subtitle: 'Dynamic, personalized assessment',
                                isSmall: isSmallScreen,
                              ),
                              const SizedBox(height: 12),
                              _FeatureItem(
                                icon: Icons.insights,
                                title: 'Deep Insights',
                                subtitle:  'Comprehensive personality analysis',
                                isSmall: isSmallScreen,
                              ),
                              const SizedBox(height: 12),
                              _FeatureItem(
                                icon: Icons.trending_up,
                                title:  'Actionable Advice',
                                subtitle: 'Career and life recommendations',
                                isSmall:  isSmallScreen,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: isSmallScreen ? 32 : 48),

                        // Start Button
                        Container(
                          constraints: const BoxConstraints(maxWidth: 400),
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacementNamed(context, '/quiz');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Theme.of(context).colorScheme.primary,
                              padding: EdgeInsets.symmetric(
                                vertical: isSmallScreen ? 16 : 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              elevation: 8,
                            ),
                            child: Row(
                              mainAxisAlignment:  MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Start Your Journey',
                                  style:  (isSmallScreen 
                                    ? Theme.of(context).textTheme.titleMedium
                                    : Theme.of(context).textTheme.titleLarge
                                  )?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.arrow_forward_rounded),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Duration Info
                        Text(
                          '⏱️ Takes only 5 minutes',
                          style: Theme.of(context).textTheme.bodyMedium?. copyWith(
                            color:  Colors.white.withOpacity(0.8),
                          ),
                        ),
                        
                        SizedBox(height: isSmallScreen ? 40 : 60),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSmall;

  const _FeatureItem({
    Key? key,
    required this. icon,
    required this.title,
    required this.subtitle,
    this.isSmall = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 14 : 18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmall ? 8 : 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child:  Icon(
              icon,
              color: Colors.white,
              size: isSmall ? 22 : 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: (isSmall 
                    ?  Theme.of(context).textTheme.titleSmall
                    : Theme.of(context).textTheme.titleMedium
                  )?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height:  3),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}