class AppConstants {
  // Groq API Configuration (FREE & FAST!)
  static const String groqApiKey = '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'; // Paste your Groq key
  static const String groqApiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  
  // UPDATED: Use current model (llama-3.3-70b-versatile is the latest!)
  static const String groqModel = 'llama-3.3-70b-versatile'; 
  
  // Alternative models that work: 
  // static const String groqModel = 'llama-3.1-8b-instant'; // Faster, smaller
  // static const String groqModel = 'mixtral-8x7b-32768'; // Also good
  
  // Local Storage Keys
  static const String userDataKey = 'user_data';
  static const String quizResultsKey = 'quiz_results';
  
 // App Settings - UPDATED FOR BETTER ASSESSMENT
  static const int numberOfQuestions = 25; // Increased from 10
  static const int answersPerQuestion = 4; // Multiple choice options
  static const Duration animationDuration = Duration(milliseconds: 300);
  
  // Theme Colors - Beautiful gradient
  static const primaryColor = 0xFF6366F1; // Indigo
  static const secondaryColor = 0xFF8B5CF6; // Purple
  static const accentColor = 0xFFEC4899; // Pink
  static const backgroundColor = 0xFFF8FAFC;
}