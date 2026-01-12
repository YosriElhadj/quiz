class AppConstants {
  // App Info
  static const String appName = 'Personality Quiz';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String userDataKey = 'user_data';
  static const String quizResultsKey = 'quiz_results';
  
  // API (for future AI integration)
  static const String aiApiKey = 'your_api_key_here';
  static const String aiApiUrl = 'https://api.openai.com/v1/chat/completions';
  
  // Quiz Settings
  static const int totalQuestions = 10;
  static const int questionTimeLimit = 30; // seconds
}