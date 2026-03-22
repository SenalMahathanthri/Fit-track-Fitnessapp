class QAData {
  // Map of questions to answers
  static final Map<String, String> _qaMap = {
    // Nutrition/Meal Plan Questions
    'what should i eat before a workout':
        'Before a workout, aim to eat a balanced meal with carbs and protein 2-3 hours before. Great options include: banana with peanut butter, oatmeal with fruit, yogurt with granola, or a turkey sandwich. For workouts less than an hour away, choose easily digestible carbs like a banana or small smoothie.',

    'what should i eat after a workout':
        'After a workout, focus on protein and carbs within 45 minutes. Good options include: protein shake with banana, chicken with rice and vegetables, tuna sandwich, Greek yogurt with fruit, or eggs with toast. This helps with muscle recovery and glycogen replenishment.',

    'tell me about intermittent fasting':
        'Intermittent fasting involves cycling between eating and fasting periods. Common methods include 16:8 (16 hours fasting, 8 hours eating), 5:2 (5 normal days, 2 very low-calorie days), and alternate-day fasting. Benefits may include weight loss, improved insulin sensitivity, and cellular repair. Start gradually and consult a healthcare provider before beginning.',

    'what\'s a good protein intake for muscle gain':
        'For muscle gain, aim for 1.6-2.2g of protein per kg of body weight daily. If you weigh 70kg, that`s about 112-154g of protein per day. Spread your intake across meals, prioritizing complete protein sources like meat, fish, eggs, dairy, and plant-based combinations (beans with rice, etc.).',

    'how many calories should i eat to lose weight':
        'To lose weight, create a moderate calorie deficit of 500-750 calories below your maintenance level. For most adults, this means 1500-2000 calories for men and 1200-1500 for women, but it varies based on age, weight, height, and activity level. Focus on nutrient-dense foods and adjust based on results and energy levels.',

    'what is a balanced meal plan':
        'A balanced meal plan includes all major food groups: proteins (meat, fish, legumes), complex carbs (whole grains, vegetables), healthy fats (avocados, nuts, olive oil), and plenty of fruits and vegetables. Aim for 3 main meals and 1-2 snacks daily, with portion sizes based on your calorie needs. Hydration is also essential.',

    'are supplements necessary':
        'Supplements aren\'t necessary with a well-balanced diet, but can help fill nutritional gaps. Commonly beneficial ones include vitamin D (especially in low-sunlight regions), omega-3s, and possibly protein for very active individuals. Multivitamins can provide insurance against deficiencies. Always choose quality products and consult healthcare providers before starting supplements.',

    'what are good vegetarian protein sources':
        'Great vegetarian protein sources include: legumes (beans, lentils, chickpeas), tofu and tempeh, seitan, dairy products, eggs (for ovo-vegetarians), quinoa, nuts and nut butters, seeds (especially hemp and chia), and plant-based protein powders. Combining complementary proteins (beans with rice) improves amino acid profiles.',

    'how can i meal prep effectively':
        'For effective meal prep: 1) Plan your weekly menu and shop accordingly, 2) Batch cook staples like grains, proteins, and roasted vegetables, 3) Use versatile ingredients that work in multiple meals, 4) Invest in quality containers, 5) Designate 2-3 hours on one day for prep, 6) Consider freezing portions for later in the week, and 7) Keep sauces separate until serving for freshness.',

    'what should i eat for breakfast':
        'Nutritious breakfast options include: overnight oats with fruit and nuts, Greek yogurt with berries and granola, veggie omelet with whole-grain toast, whole-grain cereal with milk and fruit, protein smoothie with spinach and banana, or avocado toast with eggs. Focus on protein, fiber, and healthy fats for sustained energy.',

    // Workout Questions
    'what are good exercises for beginners':
        'For beginners, focus on foundational exercises: 1) Bodyweight squats, 2) Modified push-ups, 3) Walking lunges, 4) Plank holds, 5) Dumbbell rows, 6) Glute bridges, and 7) Wall sits. Start with 2-3 sets of 8-12 reps, with proper form prioritized over weight or reps. Allow 48 hours recovery between strength workouts of the same muscle groups.',

    'how can i lose weight effectively':
        'Effective weight loss combines: 1) Calorie deficit (500-750 calories below maintenance), 2) Regular exercise (both cardio and strength training), 3) High protein intake to preserve muscle, 4) Whole, unprocessed foods, 5) Adequate sleep and stress management, 6) Consistency over time, and 7) Realistic goals (1-2 pounds per week). Focus on sustainable lifestyle changes rather than quick fixes.',

    'how often should i work out':
        'Aim for 3-5 workout sessions per week with adequate recovery. For beginners, 3 full-body strength sessions with a day of rest between is ideal. As you advance, consider 4-5 weekly sessions, potentially splitting into upper/lower body or push/pull routines. Include 2-3 cardio sessions (can be on the same or different days) and avoid training the same muscle group on consecutive days.',

    'tell me about hiit workouts':
        'HIIT (High-Intensity Interval Training) involves short bursts of intense exercise alternated with recovery periods. A typical session lasts 20-30 minutes with work intervals of 20-60 seconds at 80-95% effort, followed by equal or longer recovery periods. Benefits include efficient calorie burning, improved cardiovascular health, and metabolic boost. Start with 1-2 sessions weekly and build up to 3-4, allowing full recovery between sessions.',

    'what\'s the best time to work out':
        'The best workout time is whenever you can consistently commit to it. Morning workouts may increase adherence and boost metabolism throughout the day, while evening workouts can leverage higher body temperature and strength peaks. Experiment to find what works with your schedule and energy patterns. Consistency matters more than timing.',

    'how to build muscle':
        'To build muscle: 1) Follow a progressive overload resistance training program (gradually increasing weight/volume), 2) Consume sufficient protein (1.6-2.2g per kg body weight), 3) Eat in a slight calorie surplus, 4) Train each muscle group 2-3 times weekly, 5) Prioritize compound exercises (squats, deadlifts, bench press), 6) Allow adequate recovery (48 hours per muscle group), and 7) Ensure quality sleep of 7-9 hours nightly.',

    'what is a good workout routine':
        'A balanced weekly routine includes: 3-4 strength training sessions (full body or split routines), 2-3 cardio sessions (mix of high and low intensity), 1-2 flexibility/mobility sessions, and at least 1 full rest day. For beginners, focus on full-body strength training 3 times weekly with a day of rest between, plus 2 days of moderate cardio. Adjust based on goals, fitness level, and recovery capacity.',

    'how can i improve my cardio fitness':
        'To improve cardio fitness: 1) Include both steady-state cardio (30-60 min at moderate intensity) and interval training, 2) Gradually increase duration and intensity over time, 3) Incorporate variety (running, cycling, swimming, rowing), 4) Aim for 150+ minutes weekly of moderate activity, 5) Include one longer session weekly to build endurance, and 6) Allow recovery days. Consistency is key for cardiovascular adaptations.',

    'what exercises burn the most calories':
        'Highest calorie-burning exercises include: running/sprinting, swimming (especially butterfly stroke), rowing, jumping rope, burpees, kettlebell circuits, hill climbing, and cross-country skiing. High-intensity interval training (HIIT) and circuit training with minimal rest maximize calorie burn during and after exercise through the EPOC effect. Choose activities you enjoy for better adherence.',

    'how can i stay motivated to exercise':
        'To maintain exercise motivation: 1) Set specific, measurable goals, 2) Find activities you genuinely enjoy, 3) Track progress with apps or journals, 4) Schedule workouts like appointments, 5) Find a workout buddy or community, 6) Mix up your routine to prevent boredom, 7) Reward yourself for consistency (non-food rewards), and 8) Focus on how exercise makes you feel mentally and physically, not just aesthetic changes.',

    // Hydration Questions
    'how much water should i drink daily':
        'Most adults need 2.7-3.7 liters (91-125 oz) of total water daily, including from beverages and food. A practical guideline is drinking enough so your urine is pale yellow. Increase intake during hot weather, high altitudes, illness, and when exercising. Listen to your body – thirst is a reliable indicator for most healthy adults.',

    'what are signs of dehydration':
        'Common dehydration signs include: thirst, dark yellow urine, dry mouth and lips, headache, fatigue, dizziness, reduced urination, and dry skin with poor elasticity. Severe dehydration may cause confusion, rapid heartbeat, very low urine output, and extreme thirst. Don`t wait for these signs – maintain regular fluid intake throughout the day.',

    'are sports drinks necessary':
        'Sports drinks are beneficial mainly for intense exercise lasting over 60-90 minutes or in extreme heat. They replace electrolytes lost through heavy sweating and provide carbohydrates for energy. For most moderate workouts under an hour, water is sufficient. Consider electrolyte tablets or homemade alternatives with less sugar for longer sessions.',

    // Sleep Questions
    'how can i improve my sleep quality':
        'To improve sleep quality: 1) Maintain consistent sleep-wake times, 2) Create a relaxing bedtime routine, 3) Make your bedroom dark, quiet, and cool (65-68°F/18-20°C), 4) Avoid screens 1-2 hours before bed, 5) Limit caffeine after noon and alcohol near bedtime, 6) Exercise regularly but not right before bed, 7) Get natural sunlight during the day, and 8) Consider relaxation techniques like meditation or deep breathing before sleep.',

    'how much sleep do i need':
        'Most adults need 7-9 hours of quality sleep per night. Athletes and very active individuals may benefit from 8-10 hours for optimal recovery. Teenagers need 8-10 hours, school-age children 9-12 hours. Individual needs vary based on genetics, activity level, and health status. Consistently waking refreshed without an alarm is a good indicator you`re getting enough sleep.',

    'does sleep affect weight loss':
        'Sleep significantly impacts weight management. Insufficient sleep (less than 7 hours) can increase hunger hormones (ghrelin), decrease satiety signals (leptin), lead to higher calorie consumption, reduce energy for exercise, impair glucose metabolism, and increase cortisol (stress hormone) which promotes fat storage. Prioritizing 7-9 hours of quality sleep can enhance weight loss efforts and workout recovery.',

    // Recovery Questions
    'how important is rest day':
        'Rest days are crucial for: muscle recovery and growth, preventing overtraining syndrome, replenishing energy stores, reducing injury risk, and maintaining psychological motivation. Include 1-2 weekly rest days, depending on training intensity. Active recovery (light walking, yoga, swimming) can enhance recovery while maintaining activity. Listen to your body – persistent fatigue or decreased performance signals need for additional rest.',

    'what are good recovery techniques':
        'Effective recovery techniques include: adequate sleep (7-9 hours), proper nutrition (especially protein and carbs post-workout), hydration, active recovery (light movement on rest days), foam rolling and stretching, contrast therapy (alternating hot and cold), compression garments, massage, and stress management techniques. Find what works best for you and implement consistently, especially after intense training sessions.',

    'how do i prevent muscle soreness':
        'To minimize muscle soreness: 1) Properly warm up before exercise, 2) Progress training intensity gradually, 3) Cool down with light movement and stretching, 4) Stay hydrated before, during, and after workouts, 5) Consume protein and carbs within the post-workout window, 6) Consider tart cherry juice for its anti-inflammatory properties, 7) Use foam rolling and massage techniques, and 8) Get adequate sleep. Some soreness is normal with new exercises – it typically peaks 24-72 hours post-workout.',

    // Additional Helpful Questions
    'how can i track my fitness progress':
        'Track fitness progress through multiple metrics: 1) Workout performance (weights, reps, speed, endurance), 2) Body measurements (more reliable than weight alone), 3) Progress photos, 4) Body composition tests, 5) Fitness assessments (timed runs, max reps, etc.), 6) Daily energy levels and recovery quality, 7) Sleep quality, and 8) Mood and stress levels. Use a combination of metrics and track consistently, typically every 2-4 weeks.',

    'what are signs of overtraining':
        'Overtraining signs include: persistent fatigue despite adequate rest, decreased performance and strength, prolonged muscle soreness, increased resting heart rate, sleep disturbances, irritability or mood changes, frequent injuries or illnesses, loss of motivation, and changes in appetite. If experiencing multiple symptoms, reduce training volume and intensity for 1-2 weeks, focusing on recovery, nutrition, and sleep.',

    'is it better to workout in the morning or evening':
        'Morning workouts may boost metabolism throughout the day, enhance consistency, and improve sleep quality. Evening workouts often allow better performance due to higher body temperature and hormone levels, potentially maximizing strength and endurance. The best time is when you can consistently train with good energy. Experiment to find what works with your schedule and body rhythms.',

    'what should my heart rate be during exercise':
        'Target heart rate zones depend on your goal: For moderate-intensity cardio, aim for 50-70% of max heart rate (roughly calculated as 220 minus your age). For vigorous exercise, aim for 70-85%. For fat burning, lower intensities (60-70%) may be effective. Heart rate zones are guidelines – also use perceived exertion (ability to talk) and adjust based on fitness level and medical conditions.',

    'how long should a workout last':
        'Effective workouts can range from 20-90 minutes depending on type and intensity. Strength training typically requires 45-60 minutes, including warm-up. HIIT can be effective in just 20-30 minutes. Moderate cardio benefits accumulate with 30+ minutes. Focus on quality over quantity – intense, focused 30-minute workouts can be more effective than unfocused 90-minute sessions. Adjust based on goals, available time, and recovery capacity.',

    'can i exercise while pregnant':
        'Most pregnant women can and should exercise, but consult your healthcare provider first. Generally, continue activities you were doing pre-pregnancy with modifications as pregnancy progresses. Aim for 150 minutes weekly of moderate activity. Safe options include walking, swimming, stationary cycling, and prenatal yoga. Avoid activities with falling risk, extreme exertion, or abdominal pressure, especially in later trimesters. Listen to your body and stay well-hydrated.',

    'what are the benefits of yoga':
        'Yoga offers numerous benefits: improved flexibility, strength, and balance, stress reduction and mental clarity, better posture and body awareness, enhanced breathing efficiency, potential pain relief (especially back pain), cardiovascular health improvements, and complementary benefits for other training. Different styles offer varying benefits – from the challenging strength focus of power yoga to the relaxation emphasis of restorative practices.',

    'how do i start running as a beginner':
        'For beginner runners: 1) Start with a walk-run approach (e.g., 1 min running, 2 min walking), 2) Gradually increase running intervals while decreasing walking, 3) Focus on time rather than distance initially, 4) Invest in proper running shoes, 5) Run on softer surfaces when possible, 6) Increase total volume by no more than 10% weekly, 7) Include rest days between runs, and 8) Consider a structured program like Couch to 5K for progression guidance.',
  };

  // Topic categorization for related questions
  static final Map<String, List<String>> _topicMap = {
    'nutrition': [
      'what should i eat before a workout',
      'what should i eat after a workout',
      'tell me about intermittent fasting',
      'what\'s a good protein intake for muscle gain',
      'how many calories should i eat to lose weight',
      'what is a balanced meal plan',
      'are supplements necessary',
      'what are good vegetarian protein sources',
      'how can i meal prep effectively',
      'what should i eat for breakfast',
    ],

    'workouts': [
      'what are good exercises for beginners',
      'how can i lose weight effectively',
      'how often should i work out',
      'tell me about hiit workouts',
      'what\'s the best time to work out',
      'how to build muscle',
      'what is a good workout routine',
      'how can i improve my cardio fitness',
      'what exercises burn the most calories',
      'how can i stay motivated to exercise',
    ],

    'hydration': [
      'how much water should i drink daily',
      'what are signs of dehydration',
      'are sports drinks necessary',
    ],

    'sleep': [
      'how can i improve my sleep quality',
      'how much sleep do i need',
      'does sleep affect weight loss',
    ],

    'recovery': [
      'how important is rest day',
      'what are good recovery techniques',
      'how do i prevent muscle soreness',
    ],

    'general': [
      'how can i track my fitness progress',
      'what are signs of overtraining',
      'is it better to workout in the morning or evening',
      'what should my heart rate be during exercise',
      'how long should a workout last',
      'can i exercise while pregnant',
      'what are the benefits of yoga',
      'how do i start running as a beginner',
    ],
  };

  // Keyword mapping to help match user questions to our predefined ones
  static final Map<String, List<String>> _keywordMap = {
    'eat before workout': ['what should i eat before a workout'],
    'pre workout meal': ['what should i eat before a workout'],
    'before workout': ['what should i eat before a workout'],
    'food before exercise': ['what should i eat before a workout'],

    'eat after workout': ['what should i eat after a workout'],
    'post workout meal': ['what should i eat after a workout'],
    'after exercise': ['what should i eat after a workout'],
    'recovery meal': ['what should i eat after a workout'],

    'intermittent fast': ['tell me about intermittent fasting'],
    'fasting': ['tell me about intermittent fasting'],
    'if diet': ['tell me about intermittent fasting'],
    '16 8': ['tell me about intermittent fasting'],

    'protein muscle': ['what\'s a good protein intake for muscle gain'],
    'protein intake': ['what\'s a good protein intake for muscle gain'],
    'how much protein': ['what\'s a good protein intake for muscle gain'],
    'protein per day': ['what\'s a good protein intake for muscle gain'],

    'calories lose weight': ['how many calories should i eat to lose weight'],
    'calorie deficit': ['how many calories should i eat to lose weight'],
    'calories for weight loss': [
      'how many calories should i eat to lose weight',
    ],
    'how many calories': ['how many calories should i eat to lose weight'],

    'meal plan': ['what is a balanced meal plan'],
    'balanced diet': ['what is a balanced meal plan'],
    'eating plan': ['what is a balanced meal plan'],
    'healthy eating': ['what is a balanced meal plan'],

    'supplements': ['are supplements necessary'],
    'vitamins': ['are supplements necessary'],
    'protein powder': ['are supplements necessary'],
    'need supplements': ['are supplements necessary'],

    'vegetarian protein': ['what are good vegetarian protein sources'],
    'vegan protein': ['what are good vegetarian protein sources'],
    'plant protein': ['what are good vegetarian protein sources'],
    'protein without meat': ['what are good vegetarian protein sources'],

    'meal prep': ['how can i meal prep effectively'],
    'prepare meals': ['how can i meal prep effectively'],
    'batch cooking': ['how can i meal prep effectively'],
    'food prep': ['how can i meal prep effectively'],

    'breakfast': ['what should i eat for breakfast'],
    'morning meal': ['what should i eat for breakfast'],
    'breakfast ideas': ['what should i eat for breakfast'],
    'healthy breakfast': ['what should i eat for breakfast'],

    'beginner exercises': ['what are good exercises for beginners'],
    'start exercising': ['what are good exercises for beginners'],
    'new to fitness': ['what are good exercises for beginners'],
    'beginner workout': ['what are good exercises for beginners'],

    'lose weight': ['how can i lose weight effectively'],
    'weight loss': ['how can i lose weight effectively'],
    'fat loss': ['how can i lose weight effectively'],
    'burn fat': ['how can i lose weight effectively'],

    'how often workout': ['how often should i work out'],
    'workout frequency': ['how often should i work out'],
    'training frequency': ['how often should i work out'],
    'days per week': ['how often should i work out'],

    'hiit': ['tell me about hiit workouts'],
    'high intensity': ['tell me about hiit workouts'],
    'interval training': ['tell me about hiit workouts'],
    'hiit workout': ['tell me about hiit workouts'],

    'best time workout': ['what\'s the best time to work out'],
    'morning or evening': [
      'what\'s the best time to work out',
      'is it better to workout in the morning or evening',
    ],
    'when to exercise': ['what\'s the best time to work out'],
    'workout timing': ['what\'s the best time to work out'],

    'build muscle': ['how to build muscle'],
    'gain muscle': ['how to build muscle'],
    'hypertrophy': ['how to build muscle'],
    'muscle growth': ['how to build muscle'],

    'workout routine': ['what is a good workout routine'],
    'training plan': ['what is a good workout routine'],
    'exercise program': ['what is a good workout routine'],
    'weekly routine': ['what is a good workout routine'],

    'improve cardio': ['how can i improve my cardio fitness'],
    'better endurance': ['how can i improve my cardio fitness'],
    'cardiovascular': ['how can i improve my cardio fitness'],
    'aerobic fitness': ['how can i improve my cardio fitness'],

    'burn calories': ['what exercises burn the most calories'],
    'calorie burning': ['what exercises burn the most calories'],
    'exercises burn fat': ['what exercises burn the most calories'],
    'best for calories': ['what exercises burn the most calories'],

    'stay motivated': ['how can i stay motivated to exercise'],
    'motivation': ['how can i stay motivated to exercise'],
    'exercise consistency': ['how can i stay motivated to exercise'],
    'motivation workout': ['how can i stay motivated to exercise'],

    'water': ['how much water should i drink daily'],
    'hydration': ['how much water should i drink daily'],
    'drink water': ['how much water should i drink daily'],
    'daily water': ['how much water should i drink daily'],

    'dehydration': ['what are signs of dehydration'],
    'dehydrated': ['what are signs of dehydration'],
    'thirsty': ['what are signs of dehydration'],
    'not enough water': ['what are signs of dehydration'],

    'sports drinks': ['are sports drinks necessary'],
    'electrolytes': ['are sports drinks necessary'],
    'gatorade': ['are sports drinks necessary'],
    'drink during workout': ['are sports drinks necessary'],

    'sleep quality': ['how can i improve my sleep quality'],
    'better sleep': ['how can i improve my sleep quality'],
    'insomnia': ['how can i improve my sleep quality'],
    'trouble sleeping': ['how can i improve my sleep quality'],

    'how much sleep': ['how much sleep do i need'],
    'sleep needs': ['how much sleep do i need'],
    'hours of sleep': ['how much sleep do i need'],
    'enough sleep': ['how much sleep do i need'],

    'sleep weight': ['does sleep affect weight loss'],
    'sleep metabolism': ['does sleep affect weight loss'],
    'sleep fat': ['does sleep affect weight loss'],
    'sleep diet': ['does sleep affect weight loss'],

    'rest day': ['how important is rest day'],
    'recovery day': ['how important is rest day'],
    'days off': ['how important is rest day'],
    'need rest': ['how important is rest day'],

    'recovery': ['what are good recovery techniques'],
    'recover faster': ['what are good recovery techniques'],
    'recovery methods': ['what are good recovery techniques'],
    'muscle recovery': ['what are good recovery techniques'],

    'muscle soreness': ['how do i prevent muscle soreness'],
    'doms': ['how do i prevent muscle soreness'],
    'sore muscles': ['how do i prevent muscle soreness'],
    'prevent soreness': ['how do i prevent muscle soreness'],

    'track progress': ['how can i track my fitness progress'],
    'measure progress': ['how can i track my fitness progress'],
    'track fitness': ['how can i track my fitness progress'],
    'fitness progress': ['how can i track my fitness progress'],

    'overtraining': ['what are signs of overtraining'],
    'training too much': ['what are signs of overtraining'],
    'exercise too much': ['what are signs of overtraining'],
    'burnout': ['what are signs of overtraining'],

    'morning evening': ['is it better to workout in the morning or evening'],
    'workout time': ['is it better to workout in the morning or evening'],
    'time of day': ['is it better to workout in the morning or evening'],
    'when workout': ['is it better to workout in the morning or evening'],

    'heart rate': ['what should my heart rate be during exercise'],
    'target heart': ['what should my heart rate be during exercise'],
    'heart zone': ['what should my heart rate be during exercise'],
    'bpm exercise': ['what should my heart rate be during exercise'],

    'workout length': ['how long should a workout last'],
    'workout duration': ['how long should a workout last'],
    'how long exercise': ['how long should a workout last'],
    'time workout': ['how long should a workout last'],

    'pregnant': ['can i exercise while pregnant'],
    'pregnancy': ['can i exercise while pregnant'],
    'exercise pregnant': ['can i exercise while pregnant'],
    'workout pregnant': ['can i exercise while pregnant'],

    'yoga benefits': ['what are the benefits of yoga'],
    'why yoga': ['what are the benefits of yoga'],
    'yoga good': ['what are the benefits of yoga'],
    'yoga help': ['what are the benefits of yoga'],

    'start running': ['how do i start running as a beginner'],
    'beginner running': ['how do i start running as a beginner'],
    'running beginner': ['how do i start running as a beginner'],
    'learn to run': ['how do i start running as a beginner'],
  };

  // Find the best matching question based on user input
  static String _findBestMatch(String userQuestion) {
    userQuestion = userQuestion.toLowerCase().trim();

    // Direct match
    if (_qaMap.containsKey(userQuestion)) {
      return userQuestion;
    }

    // Check for keyword matches
    for (var entry in _keywordMap.entries) {
      if (userQuestion.contains(entry.key)) {
        return entry.value.first; // Return the first matched question
      }
    }

    // If no matches found, return default response trigger
    return 'default';
  }

  // Get a response based on user question
  static String getResponse(String userQuestion) {
    final bestMatch = _findBestMatch(userQuestion);

    // Return matched response or default
    if (_qaMap.containsKey(bestMatch)) {
      return _qaMap[bestMatch]!;
    }

    // Default response if no match found
    return "I don't have specific information on that yet. Would you like to know about workouts, nutrition, hydration, or sleep instead?";
  }

  // Get related questions for a user query
  static List<String> getRelatedQuestions(String userQuery) {
    final bestMatch = _findBestMatch(userQuery);

    if (bestMatch == 'default') {
      // If no match found, return general suggestions
      return [
        'What are good exercises for beginners?',
        'How can I improve my sleep quality?',
        'What should I eat before a workout?',
        'How much water should I drink daily?',
      ];
    }

    // Find which topic the best match belongs to
    String? matchedTopic;
    for (var entry in _topicMap.entries) {
      if (entry.value.contains(bestMatch)) {
        matchedTopic = entry.key;
        break;
      }
    }

    if (matchedTopic != null) {
      // Get other questions from the same topic, excluding the current one
      final relatedQuestions =
          _topicMap[matchedTopic]!
              .where((q) => q != bestMatch)
              .map((q) => _capitalizeFirstLetter(q))
              .toList();

      return relatedQuestions;
    }

    // Fallback to general questions
    return [
      'How can I stay motivated to exercise?',
      'What\'s a good protein intake for muscle gain?',
      'What are good recovery techniques?',
    ];
  }

  // Helper to capitalize first letter of questions for display
  static String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1)}?';
  }
}
