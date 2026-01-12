import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/constants/app_constants.dart';
import '../models/question_model.dart';

abstract class QuizRemoteDataSource {
  Future<List<QuestionModel>> getQuestions();
  Future<String> getAIInsights(String personalityType, String description);
}

class QuizRemoteDataSourceImpl implements QuizRemoteDataSource {
  final http.Client client;

  QuizRemoteDataSourceImpl({required this.client});

  @override
  Future<List<QuestionModel>> getQuestions() async {
    // Check if API key is configured
    if (AppConstants.groqApiKey == 'YOUR_GROQ_API_KEY_HERE' || 
        AppConstants.groqApiKey. isEmpty) {
      print('⚠️ Groq API key not configured.  Using static questions.');
      return _getStaticQuestions();
    }

    try {
      print('🤖 Generating questions with Groq AI (Llama 3.1)...');
      return await _getGroqGeneratedQuestions();
    } catch (e) {
      print('❌ Groq API failed:  $e');
      print('📋 Falling back to static questions');
      return _getStaticQuestions();
    }
  }

  Future<List<QuestionModel>> _getGroqGeneratedQuestions() async {
    final prompt = '''
You are a professional psychologist. Generate exactly ${AppConstants.numberOfQuestions} personality assessment questions. 

CRITICAL:  Return ONLY a valid JSON array.  No markdown, no explanations, just the JSON array.

Each question must assess these personality traits:
- Extrovert vs Introvert
- Thinker vs Feeler
- Judger vs Perceiver
- Analytical vs Creative
- Leader vs Supporter

Use exactly these categories in order: 
1. Social Energy
2. Decision Making
3. Structure
4. Learning Style
5. Leadership
6. Energy Recovery
7. Communication
8. Planning
9. Work Style
10. Conflict Resolution

Required JSON structure:
[
  {
    "id": "q1",
    "text": "Your engaging question here? ",
    "category": "Social Energy",
    "answers": [
      {
        "id": "q1a1",
        "text": "First answer reflecting one trait",
        "personalityType": "Extrovert",
        "score": 5
      },
      {
        "id": "q1a2",
        "text": "Second answer reflecting opposite trait",
        "personalityType": "Introvert",
        "score": 5
      }
    ]
  }
]

Make questions thoughtful and relatable.  Return ONLY the JSON array.
''';

    final response = await client.post(
      Uri.parse(AppConstants.groqApiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':  'Bearer ${AppConstants.groqApiKey}',
      },
      body:  json.encode({
        'model': AppConstants. groqModel,
        'messages': [
          {
            'role': 'system',
            'content': 'You are a professional psychologist. Return only valid JSON arrays, no markdown.'
          },
          {
            'role': 'user',
            'content': prompt
          }
        ],
        'temperature': 0.7,
        'max_tokens': 3000,
      }),
    );

    print('📡 API Response Status: ${response. statusCode}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      if (data['choices'] == null || data['choices'].isEmpty) {
        throw Exception('Invalid response from Groq');
      }

      final content = data['choices'][0]['message']['content'] as String;
      print('📥 Raw response length: ${content.length}');
      
      // Extract JSON from response
      String jsonContent = content. trim();
      
      // Remove markdown code blocks if present
      if (jsonContent. contains('```json')) {
        final start = jsonContent.indexOf('```json') + 7;
        final end = jsonContent.lastIndexOf('```');
        if (end > start) {
          jsonContent = jsonContent.substring(start, end).trim();
        }
      } else if (jsonContent.contains('```')) {
        final start = jsonContent.indexOf('```') + 3;
        final end = jsonContent.lastIndexOf('```');
        if (end > start) {
          jsonContent = jsonContent.substring(start, end).trim();
        }
      }
      
      // Find JSON array boundaries
      final arrayStart = jsonContent.indexOf('[');
      final arrayEnd = jsonContent.lastIndexOf(']');
      
      if (arrayStart != -1 && arrayEnd != -1 && arrayEnd > arrayStart) {
        jsonContent = jsonContent.substring(arrayStart, arrayEnd + 1);
      }
      
      print('🔍 Cleaned JSON length: ${jsonContent.length}');
      
      // Parse JSON
      try {
        final questionsJson = json.decode(jsonContent) as List;
        final questions = questionsJson
            .map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
            .toList();
        
        print('✅ Successfully generated ${questions.length} questions with Groq!');
        return questions;
      } catch (e) {
        print('❌ JSON parsing error: $e');
        throw Exception('Failed to parse Groq response as JSON');
      }
    } else {
      final errorBody = response.body;
      print('❌ API Error Response: $errorBody');
      throw Exception('Groq API failed with status ${response.statusCode}');
    }
  }

  @override
  Future<String> getAIInsights(String personalityType, String description) async {
    // Check if API key is configured
    if (AppConstants.groqApiKey == 'YOUR_GROQ_API_KEY_HERE' || 
        AppConstants.groqApiKey.isEmpty) {
      return _getFallbackInsights(personalityType);
    }

    try {
      print('🤖 Generating insights with Groq AI.. .');
      
      final prompt = '''
You are a warm, empathetic personality analyst and life coach. 

A person has been identified as having a "$personalityType" personality type. 

Provide personalized, encouraging insights (400-500 words) including: 

1. Warm Opening - Make them feel understood and valued
2. Key Characteristics - What defines their personality
3. Career Recommendations - 4 specific career paths perfect for them
4. Strengths - What they naturally excel at
5. Growth Areas - Gentle suggestions for development
6. Relationships - How they interact with others
7. Daily Life Tips - Practical advice for everyday situations
8. Motivational Closing - Inspiring message about their potential

Use emojis sparingly for visual appeal. Be specific, actionable, and deeply personal. 
Make them excited about who they are!
''';

      final response = await client.post(
        Uri.parse(AppConstants.groqApiUrl),
        headers: {
          'Content-Type':  'application/json',
          'Authorization': 'Bearer ${AppConstants.groqApiKey}',
        },
        body: json.encode({
          'model':  AppConstants.groqModel,
          'messages': [
            {
              'role': 'system',
              'content': 'You are a warm, professional personality analyst and life coach.'
            },
            {
              'role': 'user',
              'content': prompt
            }
          ],
          'temperature': 0.9,
          'max_tokens':  1000,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['choices'] != null && data['choices'].isNotEmpty) {
          final insights = data['choices'][0]['message']['content'] as String;
          print('✅ Generated personalized insights with Groq!');
          return insights;
        }
      }
      
      print('❌ Failed to get AI insights');
      return _getFallbackInsights(personalityType);
    } catch (e) {
      print('❌ Error getting insights: $e');
      return _getFallbackInsights(personalityType);
    }
  }

  // High-quality static questions (fallback)
  List<QuestionModel> _getStaticQuestions() {
    return [
      const QuestionModel(
        id:  'q1',
        text: 'At social gatherings, you typically: ',
        category: 'Social Energy',
        answers: [
          AnswerModel(
            id: 'q1a1',
            text: 'Actively seek out new conversations and enjoy meeting strangers',
            personalityType: 'Extrovert',
            score: 5,
          ),
          AnswerModel(
            id: 'q1a2',
            text: 'Prefer deep conversations with a small group of close friends',
            personalityType: 'Introvert',
            score: 5,
          ),
        ],
      ),
      const QuestionModel(
        id: 'q2',
        text: 'When facing an important decision, you primarily rely on:',
        category: 'Decision Making',
        answers:  [
          AnswerModel(
            id: 'q2a1',
            text: 'Logical analysis, facts, and objective criteria',
            personalityType: 'Thinker',
            score: 5,
          ),
          AnswerModel(
            id: 'q2a2',
            text: 'Personal values, emotions, and impact on people',
            personalityType: 'Feeler',
            score: 5,
          ),
        ],
      ),
      const QuestionModel(
        id:  'q3',
        text: 'Your ideal work environment is:',
        category: 'Structure',
        answers: [
          AnswerModel(
            id: 'q3a1',
            text: 'Well-organized with clear schedules and deadlines',
            personalityType:  'Judger',
            score: 5,
          ),
          AnswerModel(
            id: 'q3a2',
            text: 'Flexible and adaptable with room for spontaneity',
            personalityType: 'Perceiver',
            score: 5,
          ),
        ],
      ),
      const QuestionModel(
        id: 'q4',
        text: 'When learning something new, you prefer to:',
        category: 'Learning Style',
        answers: [
          AnswerModel(
            id: 'q4a1',
            text: 'Break it down into steps, analyze details and data',
            personalityType: 'Analytical',
            score:  5,
          ),
          AnswerModel(
            id: 'q4a2',
            text: 'Explore possibilities, imagine applications and innovations',
            personalityType: 'Creative',
            score: 5,
          ),
        ],
      ),
      const QuestionModel(
        id: 'q5',
        text: 'In group projects, you naturally:',
        category: 'Leadership',
        answers: [
          AnswerModel(
            id: 'q5a1',
            text: 'Take initiative, organize tasks, and guide the team',
            personalityType:  'Leader',
            score:  5,
          ),
          AnswerModel(
            id: 'q5a2',
            text: 'Support others, ensure harmony, and help where needed',
            personalityType:  'Supporter',
            score: 5,
          ),
        ],
      ),
      const QuestionModel(
        id:  'q6',
        text: 'After a long week, you recharge by:',
        category:  'Energy Recovery',
        answers: [
          AnswerModel(
            id: 'q6a1',
            text:  'Going out with friends, attending events, being active',
            personalityType:  'Extrovert',
            score:  5,
          ),
          AnswerModel(
            id: 'q6a2',
            text: 'Having quiet time alone with a book, hobby, or movie',
            personalityType: 'Introvert',
            score: 5,
          ),
        ],
      ),
      const QuestionModel(
        id: 'q7',
        text: 'When someone shares a problem with you, you typically:',
        category: 'Communication',
        answers: [
          AnswerModel(
            id: 'q7a1',
            text: 'Analyze the situation and offer practical solutions',
            personalityType: 'Thinker',
            score: 5,
          ),
          AnswerModel(
            id:  'q7a2',
            text: 'Listen empathetically and provide emotional support',
            personalityType: 'Feeler',
            score: 5,
          ),
        ],
      ),
      const QuestionModel(
        id: 'q8',
        text: 'Your approach to planning a vacation is:',
        category:  'Planning',
        answers:  [
          AnswerModel(
            id: 'q8a1',
            text: 'Create detailed itineraries and book everything in advance',
            personalityType:  'Judger',
            score: 5,
          ),
          AnswerModel(
            id: 'q8a2',
            text: 'Keep it loose, decide activities as you go',
            personalityType: 'Perceiver',
            score: 5,
          ),
        ],
      ),
      const QuestionModel(
        id: 'q9',
        text: 'At work, you excel at:',
        category: 'Work Style',
        answers:  [
          AnswerModel(
            id: 'q9a1',
            text: 'Systematic processes, quality control, and precision',
            personalityType: 'Analytical',
            score: 5,
          ),
          AnswerModel(
            id: 'q9a2',
            text: 'Innovation, brainstorming, and creative problem-solving',
            personalityType:  'Creative',
            score:  5,
          ),
        ],
      ),
      const QuestionModel(
        id: 'q10',
        text:  'When conflicts arise in your team, you: ',
        category: 'Conflict Resolution',
        answers: [
          AnswerModel(
            id: 'q10a1',
            text: 'Take charge, address issues directly and decisively',
            personalityType:  'Leader',
            score:  5,
          ),
          AnswerModel(
            id: 'q10a2',
            text: 'Mediate, seek compromise, and maintain group harmony',
            personalityType:  'Supporter',
            score: 5,
          ),
        ],
      ),
    ];
  }

  String _getFallbackInsights(String personalityType) {
    final insights = {
      'Extrovert':  '''
🌟 **Congratulations on your Extrovert personality!**

You're a natural people person who thrives on social interaction and external stimulation. Your energy comes from connecting with others and engaging with the world around you. 

**Career Paths Perfect for You:**
• Sales & Business Development - Your charisma wins clients
• Event Management - You create unforgettable experiences
• Public Relations - You're the face people trust
• Teaching & Training - You inspire and energize learners

**Your Superpowers:**
✨ You excel at networking and building instant rapport
✨ Your enthusiasm is genuinely contagious
✨ You bring energy and life to any room
✨ You're a natural collaborator and team player

**Growth Opportunities:**
Remember to balance social time with quiet reflection.  Sometimes the best ideas emerge in moments of solitude.  Don't mistake alone time for loneliness—it's fuel for your next adventure!

**In Relationships:**
You bring warmth and excitement to friendships. Just ensure you're also listening as much as you're sharing. Your openness is a gift! 

**Daily Tips:**
• Schedule social activities to recharge
• Practice active listening in conversations
• Take brief quiet moments to process your thoughts
• Use your network to create positive change

**Remember:** Your ability to energize and inspire others is a rare gift. The world needs your light—shine on!  🌟
''',
      'Introvert': '''
🌙 **Congratulations on your Introvert personality!**

You possess a rich inner world and excel at deep thinking and meaningful connections. You recharge through solitude and focused, purposeful work.

**Career Paths Perfect for You:**
• Writing & Content Creation - Your depth shines through words
• Software Development - Deep focus is your superpower
• Research & Analysis - You uncover what others miss
• Design & Creative Arts - Your inner world creates beauty

**Your Superpowers:**
✨ You're an exceptional listener and observer
✨ Your thoughtfulness leads to wise decisions
✨ You form deep, meaningful relationships
✨ You can focus intensely on complex problems

**Growth Opportunities:**
Step outside your comfort zone occasionally for networking—it opens unexpected doors.  Remember, you don't need to be the loudest voice to make the biggest impact. 

**In Relationships:**
You offer depth and loyalty that's rare. Your friends know they can count on you for genuine understanding, not just surface-level chat.

**Daily Tips:**
• Protect your alone time—it's not selfish, it's essential
• Choose quality over quantity in friendships
• Communicate your need for quiet to others
• Leverage your listening skills professionally

**Remember:** Your depth and introspection are valuable assets. The world needs both voices that speak and ears that truly listen. 🌙
''',
      'Thinker': '''
🧠 **Congratulations on your Thinker personality!**

You approach life with logic and objectivity, making decisions based on facts and rational analysis. Your clear thinking cuts through confusion like a lighthouse through fog.

**Career Paths Perfect for You:**
• Engineering & Technology - You solve complex puzzles
• Finance & Accounting - Numbers speak your language
• Law & Legal Services - Logic is your courtroom weapon
• Strategic Planning - You see the chess moves ahead

**Your Superpowers:**
✨ You excel at objective problem-solving
✨ Your decisions are consistent and fair
✨ You spot logical flaws others miss
✨ You remain calm under pressure

**Growth Opportunities:**
Remember to consider emotional impacts—not all problems have purely logical solutions. Sometimes people need empathy more than answers.

**In Relationships:**
You show love through actions and solutions. Help others understand that your logical approach comes from a place of caring, not coldness.

**Daily Tips:**
• Practice empathetic listening without immediately problem-solving
• Acknowledge emotions (yours and others') as valid data
• Balance logic with intuition occasionally
• Explain your reasoning to help others understand

**Remember:** Your analytical mind is a powerful tool. Balance logic with empathy, and you become unstoppable! 🧠
''',
      'Feeler': '''
💝 **Congratulations on your Feeler personality!**

You navigate life through empathy and emotional intelligence, making decisions that honor values and relationships. You understand the human heart like few others can.

**Career Paths Perfect for You:**
• Counseling & Therapy - You heal hearts
• Human Resources - You bring out the best in people
• Healthcare & Nursing - Your compassion comforts
• Non-profit & Social Work - You change lives

**Your Superpowers:**
✨ You create harmony in groups effortlessly
✨ You understand unspoken emotions and needs
✨ You build strong, lasting relationships
✨ Your empathy helps others feel truly seen

**Growth Opportunities:**
Don't forget to set boundaries—caring for yourself isn't selfish, it's necessary. You can't pour from an empty cup. 

**In Relationships:**
You're the friend everyone calls in crisis. Just ensure your relationships are balanced—you deserve support too! 

**Daily Tips:**
• Practice saying "no" to protect your energy
• Recognize that not every emotion requires action
• Set clear boundaries with energy vampires
• Celebrate your empathy as strength, not weakness

**Remember:** Your empathy is a superpower, not a weakness. In a world that can be harsh, your compassion is revolutionary!  💝
''',
      'Judger': '''
📋 **Congratulations on your Judger personality!**

You thrive on structure, organization, and clear plans. You're decisive and love the satisfaction of checking items off your to-do list.  You turn chaos into order.

**Career Paths Perfect for You:**
• Project Management - You keep everything on track
• Operations & Logistics - Efficiency is your middle name
• Administration - You create the systems that work
• Quality Assurance - Details never escape you

**Your Superpowers:**
✨ You meet deadlines consistently
✨ You create reliable systems and processes
✨ You make decisions confidently and quickly
✨ You're the person people count on

**Growth Opportunities:**
Leave room for spontaneity—some of life's best moments are unplanned. Not everything needs a checklist! 

**In Relationships:**
Your reliability makes you invaluable. Just remember that not everyone operates on schedules—and that's okay too. 

**Daily Tips:**
• Schedule "unscheduled" time for spontaneity
• Practice flexibility when plans change
• Celebrate progress, not just completion
• Remember: done is better than perfect

**Remember:** Your reliability is a gift in an unpredictable world. Just remember to enjoy the journey, not just the destination! 📋
''',
      'Perceiver': '''
🦋 **Congratulations on your Perceiver personality!**

You embrace flexibility and adaptability, keeping your options open and flowing with life's changes. You're spontaneous, resourceful, and thrive in dynamic environments.

**Career Paths Perfect for You:**
• Entrepreneurship - You pivot with market changes
• Consulting - You adapt to each client's needs
• Creative Fields - You explore without boundaries
• Emergency Services - You excel under pressure

**Your Superpowers:**
✨ You adapt quickly to change
✨ You spot opportunities others miss
✨ You thrive in uncertainty
✨ Your flexibility opens unexpected doors

**Growth Opportunities:**
Sometimes commitment leads to freedom—not every door needs to stay open.  Finishing what you start can be liberating! 

**In Relationships:**
Your spontaneity keeps life exciting!  Just communicate when you need flexibility so others don't feel uncertain.

**Daily Tips:**
• Set flexible deadlines to stay on track
• Practice completing projects before starting new ones
• Communicate your need for options to others
• Use your adaptability as a career advantage

**Remember:** Your flexibility is an incredible asset in our rapidly changing world. Trust your ability to land on your feet! 🦋
''',
      'Analytical': '''
🔬 **Congratulations on your Analytical personality!**

You excel at breaking down complex problems, working with data, and finding systematic solutions. Details don't escape your notice—you see patterns where others see noise.

**Career Paths Perfect for You:**
• Data Science & Analytics - You find truth in numbers
• Research & Development - You answer the hard questions
• Financial Analysis - You predict market movements
• Systems Architecture - You design the infrastructure

**Your Superpowers:**
✨ You see patterns others completely miss
✨ You make evidence-based decisions
✨ You solve complex puzzles systematically
✨ Your precision prevents costly mistakes

**Growth Opportunities:**
Don't let perfect be the enemy of good—sometimes "good enough" is the right answer. Analysis paralysis is real!

**In Relationships:**
Your thoroughness is valued at work. In personal life, remember that emotions aren't always logical—and that's okay. 

**Daily Tips:**
• Set time limits on analysis to avoid overthinking
• Trust your gut occasionally
• Share your findings in simple terms
• Balance data with human intuition

**Remember:** Your precision is incredibly valuable. Balance thoroughness with timely action, and you're unstoppable! 🔬
''',
      'Creative':  '''
🎨 **Congratulations on your Creative personality!**

You see possibilities where others see obstacles.  Your imagination and innovation drive you to create, inspire, and push boundaries.  You make the world more beautiful and interesting.

**Career Paths Perfect for You:**
• Design & Visual Arts - You create beauty
• Innovation Management - You imagine the future
• Marketing & Advertising - You tell compelling stories
• Content Creation - You engage and inspire

**Your Superpowers:**
✨ You generate novel, original ideas
✨ You think outside every box
✨ You bring fresh perspectives to old problems
✨ Your vision inspires others to dream bigger

**Growth Opportunities:**
Learn to balance creativity with execution—ideas need implementation.  Finishing projects is as important as starting them! 

**In Relationships:**
Your imagination makes life exciting!  Share your creative process to help others understand your unique mind.

**Daily Tips:**
• Schedule time for both creation and execution
• Don't let perfectionism stop you from sharing
• Find systems that support your creative flow
• Collaborate with analytical types for balance

**Remember:** Your vision can change the world. Don't let fear of failure stop you from creating.  Every masterpiece started as an idea! 🎨
''',
      'Leader': '''
👑 **Congratulations on your Leader personality!**

You naturally step up, take charge, and guide others toward shared goals. People instinctively look to you for direction during uncertain times.  You make things happen.

**Career Paths Perfect for You:**
• Management & Executive Roles - You steer the ship
• Entrepreneurship - You build empires
• Politics & Advocacy - You champion causes
• Military & Law Enforcement - You protect and serve

**Your Superpowers:**
✨ You make difficult decisions confidently
✨ You inspire teams to achieve more
✨ You aren't afraid of responsibility
✨ Your vision rallies others to action

**Growth Opportunities:**
Great leaders also know when to follow—listen as much as you lead.  Shared leadership often achieves more than solo command.

**In Relationships:**
Your decisiveness is valued. Just ensure you're also creating space for others' input and ideas.

**Daily Tips:**
• Practice active listening before directing
• Delegate to develop others' skills
• Share credit generously
• Lead with empathy, not just authority

**Remember:** Leadership is service, not control. Your ability to guide others is both a responsibility and a privilege. Lead with heart!  👑
''',
      'Supporter': '''
🤝 **Congratulations on your Supporter personality!**

You excel at helping others succeed, creating team harmony, and ensuring everyone's voice is heard. You're the glue that holds groups together and the wind beneath others' wings.

**Career Paths Perfect for You:**
• Team Coordination - You connect the dots
• Customer Service - You create loyal fans
• Social Work - You change lives
• Healthcare - You heal through caring

**Your Superpowers:**
✨ You build consensus effortlessly
✨ You recognize others' needs before they ask
✨ You create inclusive environments
✨ Your support empowers others to shine

**Growth Opportunities:**
Don't forget to advocate for yourself—your needs matter too! Supporting others shouldn't mean sacrificing yourself.

**In Relationships:**
You're everyone's favorite team member.  Ensure your relationships are reciprocal—you deserve support too!

**Daily Tips:**
• Practice asking for help
• Set boundaries to prevent burnout
• Celebrate your contributions
• Remember: your needs are just as valid

**Remember:** Your support literally empowers others to achieve greatness. Behind every great leader is often an incredible supporter.  You're the unsung hero! 🤝
''',
    };

    return insights[personalityType] ??  '''
Thank you for completing the personality quiz! 

Your unique combination of traits makes you who you are. Remember that personality is fluid and can grow over time. 

**Key Insights:**
• Embrace your natural tendencies while remaining open to growth
• Your personality type has both strengths and areas for development
• Success comes from understanding and leveraging your authentic self

**Next Steps:**
• Reflect on how these results align with your self-perception
• Consider how to apply your strengths in daily life
• Work on developing areas that don't come naturally

Remember, self-awareness is the first step to personal growth! 
''';
  }
}