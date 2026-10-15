import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(const MediqAiApp());
}

// مفتاح عام لضمان فتح القائمة الجانبية من أي شاشة في التطبيق
final GlobalKey<ScaffoldState> mainScaffoldKey = GlobalKey<ScaffoldState>();

// ================= وحدة التحكم بالحالة والبيانات (MVVM ViewModel) =================
class AppController extends ChangeNotifier {
  bool isDarkMode = false;
  String language = 'العربية';
  String fontSizeLabel = 'متوسط';
  bool saveChats = true;
  bool notificationsEnabled = true;
  bool isLocalServerConnected = true;
  String selectedModel = 'Llama 3.1 (8B)';
  String ggufModelPath = '/storage/emulated/0/Models/llama-3.1-8b-med-q4_k_m.gguf';
  String knowledgeVersion = 'v2.4.0 (2026-10)';
  String userName = 'مستخدم';
  String userHandle = 'mediq_user';
  String userRole = 'مستخدم محلي (Local User)'; // أو مدير المعرفة (Knowledge Admin)
  String searchQuery = '';
  bool showFavoritesOnly = false;

  // الهوية الطبية والعلامات الحيوية
  Map<String, String> medicalId = {
    'name': 'عبدالرحمن خشافه',
    'blood': 'O+',
    'allergies': 'لا توجد حساسية معروفة',
    'conditions': 'لا توجد أمراض مزمنة',
    'contact': 'طوارئ: 997',
  };

  List<Map<String, dynamic>> vitalsLog = [
    {'date': 'اليوم', 'type': 'ضغط الدم', 'val': '120/80', 'status': 'طبيعي'},
    {'date': 'أمس', 'type': 'نبض القلب', 'val': '74 نبضة/د', 'status': 'طبيعي'},
    {'date': 'قبل يومين', 'type': 'السكر الصائم', 'val': '98 mg/dl', 'status': 'طبيعي'},
  ];

  List<Map<String, dynamic>> medsList = [
    {'name': 'فيتامين D3 (1000 IU)', 'time': '09:00 ص', 'status': false},
    {'name': 'أسبرين وقائي (81 mg)', 'time': '02:00 م', 'status': true},
  ];

  // سجل وثائق قاعدة المعرفة المحلية (Knowledge Ingestion & Versioning)
  List<Map<String, String>> knowledgeDocs = [
    {'title': 'الدليل السريري لأمراض الغدد والسكري.pdf', 'chunks': '142 فقرة', 'status': 'مفهرس (FTS5 + Vector)', 'version': 'v2.4'},
    {'title': 'موسوعة أمراض الدم والأنيميا الشاملة.pdf', 'chunks': '98 فقرة', 'status': 'مفهرس (FTS5 + Vector)', 'version': 'v2.4'},
    {'title': 'بروتوكولات الجهاز الهضمي وجرثومة المعدة.pdf', 'chunks': '115 فقرة', 'status': 'مفهرس (FTS5 + Vector)', 'version': 'v2.3'},
    {'title': 'دليل الفيتامينات والمكملات الغذائية.pdf', 'chunks': '76 فقرة', 'status': 'مفهرس (FTS5 + Vector)', 'version': 'v2.2'},
  ];

  double get fontScale {
    switch (fontSizeLabel) {
      case 'صغير':
        return 0.90;
      case 'كبير':
        return 1.12;
      default:
        return 1.0;
    }
  }

  // المحادثات الأساسية المطابقة للصور المرفقة تماماً
  final List<Map<String, dynamic>> chats = [
    {
      'id': 'anemia',
      'category': 'أمراض الدم',
      'title': 'ما هي أعراض فقر الدم؟',
      'subtitle': 'أعراض فقر الدم (الأنيميا) تختلف من شخص لآخر...',
      'time': 'اليوم 10:24 م',
      'icon': Icons.bloodtype_rounded,
      'color': 0xFFE11D48,
      'isFavorite': true,
      'isEmergency': false,
      'source': 'موسوعة أمراض الدم والأنيميا الشاملة (FTS5 Chunk #42)',
      'question': 'ما هي أعراض فقر الدم؟',
      'answerIntro': 'أعراض فقر الدم (الأنيميا) تختلف من شخص لآخر حسب السبب وشدة الحالة، ولكن بشكل عام تشمل الأعراض الأكثر شيوعاً ما يلي:',
      'sections': [
        {
          'heading': '1. الأعراض العامة:',
          'items': [
            'التعب والإرهاق المستمر.',
            'الضعف العام وقلة النشاط.',
            'شحوب الجلد، خاصة في الوجه والشفاه.',
            'الدوخة أو الشعور بالدوار.',
            'الصداع المتكرر.',
          ],
        },
        {
          'heading': '2. الأعراض المرتبطة بنقص الحديد (وهو النوع الأكثر شيوعاً):',
          'items': [
            'تساقط الشعر.',
            'تقصف الأظافر.',
            'الشعور بالبرد بسهولة.',
            'رغبة غير طبيعية في تناول مواد غير غذائية (مثل الثلج أو الطين).',
          ],
        },
        {
          'heading': '3. أعراض أخرى قد تظهر حسب السبب:',
          'items': [
            'ضيق في التنفس عند بذل مجهود بسيط.',
            'خفقان القلب.',
            'ألم في الصدر (في الحالات الشديدة).',
          ],
        },
      ],
      'bullets': [
        'التعب والإرهاق المستمر والضعف العام.',
        'شحوب الجلد والشفاه والدوخة المتكررة.',
        'تساقط الشعر وتقصف الأظافر وبرودة الأطراف.',
        'ضيق التنفس وخفقان القلب عند بذل مجهود.',
      ],
      'importantNote': 'هذه الأعراض قد تكون مشابهة لأمراض أخرى، ولا يمكن تشخيص فقر الدم بدون فحوصات طبية وتحاليل دم مثل صورة الدم الكاملة (CBC) ومستوى الحديد والفيريتين.',
      'footer': 'إذا كنت تعاني من هذه الأعراض، يُنصح بمراجعة الطبيب لتقييم حالتك وتحديد السبب بدقة.',
    },
    {
      'id': 'diabetes',
      'category': 'الغدد والسكري',
      'title': 'معلومات عن السكري',
      'subtitle': 'السكري هو اضطراب في استقلاب الجلوكوز...',
      'time': 'اليوم 09:24 م',
      'icon': Icons.water_drop_rounded,
      'color': 0xFF0096C7,
      'isFavorite': true,
      'isEmergency': false,
      'source': 'الدليل السريري لأمراض الغدد والسكري (FTS5 Chunk #18)',
      'question': 'ما هي أعراض مرض السكري؟',
      'answerIntro': 'مرض السكري هو اضطراب في استقلاب الجلوكوز في الجسم، ويؤدي إلى ارتفاع مستوى السكر في الدم. من أبرز أعراضه:',
      'bullets': [
        'زيادة العطش المستمر وجفاف الفم.',
        'كثرة التبول وخاصة في ساعات الليل.',
        'الجوع المستمر رغم تناول الطعام.',
        'فقدان الوزن غير المبرر.',
        'التعب والإرهاق السريع.',
        'تشوش الرؤية.',
      ],
      'importantNote': 'من المهم ملاحظة أن هذه الأعراض قد تختلف من شخص لآخر، ويجب استشارة الطبيب وإجراء فحص السكر التراكمي (HbA1c) للتشخيص الدقيق.',
      'footer': 'توجيه تثقيفي: المحافظة على نمط غذائي متوازن والنشاط البدني يساعدان في ضبط مستويات السكر.',
    },
    {
      'id': 'gastritis',
      'category': 'الجهاز الهضمي',
      'title': 'أعراض التهاب المعدة',
      'subtitle': 'التهاب المعدة قد يسبب ألماً في الجزء العلوي...',
      'time': 'أمس 16:45 م',
      'icon': Icons.medical_information_rounded,
      'color': 0xFF10B981,
      'isFavorite': false,
      'isEmergency': false,
      'source': 'بروتوكولات الجهاز الهضمي وجرثومة المعدة (FTS5 Chunk #64)',
      'question': 'ما هي أسباب التهاب المعدة؟',
      'answerIntro': 'التهاب المعدة يمكن أن يحدث نتيجة عدة أسباب، من أبرزها:',
      'bullets': [
        '1. العدوى البكتيرية (مثل هيليكوباكتر بيلوري H. pylori).',
        '2. الاستخدام المفرط للأدوية المضادة للالتهاب مثل الإيبوبروفين (NSAIDs).',
        '3. التوتر والضغط النفسي الشديد.',
        '4. تناول الأطعمة الحارة أو الدهنية بكثرة.',
        '5. الإفراط في شرب الكافيين أو التدخين.',
        '6. بعض الحالات الطبية المناعية الأخرى.',
      ],
      'importantNote': 'للحصول على تشخيص دقيق، من الأفضل إجراء فحص جرثومة المعدة ومراجعة الطبيب المختص.',
      'footer': 'تنويه: تجنب تناول مسكنات الألم على معدة فارغة لتقليل تهيج جدار المعدة.',
    },
    {
      'id': 'vitamind',
      'category': 'الفيتامينات والمناعة',
      'title': 'فيتامين D وأهميته',
      'subtitle': 'فيتامين D مهم لصحة العظام والمناعة...',
      'time': 'أمس 12:30 م',
      'icon': Icons.wb_sunny_rounded,
      'color': 0xFFF59E0B,
      'isFavorite': false,
      'isEmergency': false,
      'source': 'دليل الفيتامينات والمكملات الغذائية (FTS5 Chunk #11)',
      'question': 'ما فائدة فيتامين D للجسم؟',
      'answerIntro': 'يلعب فيتامين D دوراً حيوياً في الحفاظ على صحة الجسم العامة، وتتمثل أهم فوائده في:',
      'bullets': [
        'تعزيز امتصاص الكالسيوم والفوسفور لبناء عظام وأسنان قوية.',
        'دعم كفاءة الجهاز المناعي في مقاومة العدوى الفيروسية والبكتيرية.',
        'تحسين وظائف العضلات وتقليل الشعور بالخمول وآلام المفاصل.',
        'المساهمة في تحسين المزاج والوقاية من التقلبات المزاجية.',
      ],
      'importantNote': 'يُحدد مقدار الجرعة التعويضية بناءً على نتيجة التحليل المخبري (25-OH Vitamin D) وتحت إشراف الطبيب.',
      'footer': 'التعرض المعتدل لأشعة الشمس الصباحية وتناول الأسماك الدهنية يساعدان في دعم مخزون فيتامين D.',
    },
    {
      'id': 'general_med',
      'category': 'تثقيف طبي',
      'title': 'أسئلة عامة في الطب',
      'subtitle': 'يمكن أن تتضمن الأسئلة مجالات الوقاية والفحوصات...',
      'time': 'السبت 08:15 م',
      'icon': Icons.menu_book_rounded,
      'color': 0xFF6366F1,
      'isFavorite': false,
      'isEmergency': false,
      'source': 'قاعدة المعرفة الطبية المحلية الموحدة (RAG Engine)',
      'question': 'اشرح هذا المصطلح الطبي: الفحص الدوري الشامل وأهميته؟',
      'answerIntro': 'الفحص الطبي الدوري هو مجموعة من الفحوصات السريرية والمخبرية التي تُجرى للاطمئنان على الوظائف الحيوية والكشف المبكر عن أي اضطرابات صحية:',
      'bullets': [
        'فحص صورة الدم الكاملة (CBC) للكشف عن الأنيميا أو الالتهابات.',
        'فحص السكر الصائم والتراكمي (HbA1c) لتقييم استقلاب الجلوكوز.',
        'تحليل دهون الدم (Lipid Profile) ووظائف الكبد والكلى.',
        'قياس ضغط الدم الشرياني ومؤشر كتلة الجسم (BMI).',
      ],
      'importantNote': 'الكشف المبكر يرفع نسب الوقاية والسيطرة على الأمراض المزمنة قبل ظهور المضاعفات.',
      'footer': 'يُنصح بإجراء الفحص الروتيني مرة واحدة سنوياً على الأقل.',
    },
  ];

  List<Map<String, dynamic>> get filteredChats {
    return chats.where((chat) {
      final q = searchQuery.trim();
      final matchesSearch = q.isEmpty ||
          chat['title'].toString().contains(q) ||
          chat['subtitle'].toString().contains(q) ||
          chat['question'].toString().contains(q) ||
          (chat['category']?.toString().contains(q) ?? false);
      final matchesFav = !showFavoritesOnly || (chat['isFavorite'] == true);
      return matchesSearch && matchesFav;
    }).toList();
  }

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  void cycleFontSize() {
    fontSizeLabel = fontSizeLabel == 'صغير'
        ? 'متوسط'
        : fontSizeLabel == 'متوسط'
            ? 'كبير'
            : 'صغير';
    notifyListeners();
  }

  void cycleModel() {
    selectedModel = selectedModel.contains('Llama')
        ? 'Meditron (7B) - GGUF'
        : selectedModel.contains('Meditron')
            ? 'Gemma 2 (9B) - Med'
            : 'Llama 3.1 (8B)';
    notifyListeners();
  }

  void toggleRole() {
    userRole = userRole.contains('مدير')
        ? 'مستخدم محلي (Local User)'
        : 'مدير المعرفة (Knowledge Admin)';
    notifyListeners();
  }

  void toggleServerStatus() {
    isLocalServerConnected = !isLocalServerConnected;
    notifyListeners();
  }

  void toggleSaveChats(bool v) {
    saveChats = v;
    notifyListeners();
  }

  void toggleNotifications(bool v) {
    notificationsEnabled = v;
    notifyListeners();
  }

  void toggleFavorite(String id) {
    final idx = chats.indexWhere((c) => c['id'] == id);
    if (idx != -1) {
      chats[idx]['isFavorite'] = !(chats[idx]['isFavorite'] ?? false);
      notifyListeners();
    }
  }

  void setSearchQuery(String q) {
    searchQuery = q;
    notifyListeners();
  }

  void setShowFavoritesOnly(bool v) {
    showFavoritesOnly = v;
    notifyListeners();
  }

  void addVital(String type, String val, String status) {
    vitalsLog.insert(0, {'date': 'الآن', 'type': type, 'val': val, 'status': status});
    notifyListeners();
  }

  void toggleMed(int index) {
    medsList[index]['status'] = !medsList[index]['status'];
    notifyListeners();
  }

  void addKnowledgeDocument(String title, String chunks) {
    knowledgeDocs.insert(0, {
      'title': title,
      'chunks': chunks,
      'status': 'مفهرس (FTS5 + Vector)',
      'version': 'v2.5-local',
    });
    knowledgeVersion = 'v2.5.0 (محدث محلياً)';
    notifyListeners();
  }

  // طبقة الأمان والفلترة الطبية (Medical Safety Guardrails) + محرك RAG الهجين
  Map<String, dynamic> generateReply(String q) {
    final emergencyKeywords = [
      'جلطة',
      'نزيف حاد',
      'تسمم',
      'انتحار',
      'ألم صدر شديد',
      'توقف التنفس',
      'فقدان وعي',
      'غيبوبة',
      'ذبحة صدرية',
    ];
    final dosageKeywords = [
      'كم جرعة',
      'اعطني وصفة',
      'اكتب لي دواء',
      'جرعة دقيقة',
      'كم حبة آخذ',
    ];

    final isEmergency = emergencyKeywords.any((k) => q.contains(k));
    final isDosageRequest = dosageKeywords.any((k) => q.contains(k));

    if (isEmergency) {
      final emergencyChat = {
        'id': 'emerg_${DateTime.now().millisecondsSinceEpoch}',
        'category': 'تنبيه طوارئ حرج',
        'title': 'تحذير سلامة طبية طارئة',
        'subtitle': 'تم رصد مؤشرات طارئة تتطلب تدخلاً إسعافياً فورياً...',
        'time': 'الآن',
        'icon': Icons.warning_amber_rounded,
        'color': 0xFFDC2626,
        'isFavorite': false,
        'isEmergency': true,
        'source': 'بروتوكول طبقة الأمان الطبي (Safety Guardrails Layer - D1/D4)',
        'question': q,
        'answerIntro': '⚠️ تنبيه طوارئ طبي فوري: استفسارك يتضمن أعراضاً حرجة وعالية الخطورة لا يجب التعامل معها عبر المحادثة النصية:',
        'bullets': [
          'يرجى الاتصال فوراً بالإسعاف والطوارئ الطبية (997) أو التوجه لأقرب قسم طوارئ.',
          'لا تنتظر، وتجنب القيادة بنفسك إذا كنت تشعر بدوار أو ألم في الصدر.',
          'أبقِ المريض في وضعية مريحة وتأكد من استمرارية التنفس والوعي حتى وصول المسعفين.',
        ],
        'importantNote': 'تم إيقاف التوليد التلقائي بواسطة طبقة السلامة الطبية (Medical Safety Layer) حفاظاً على سلامتك، حيث تتطلب هذه الحالة تدخلاً سريرياً عاجلاً.',
        'footer': 'أرقام الطوارئ المعتمدة: الإسعاف 997 | الطوارئ الموحد 911.',
      };
      if (saveChats) {
        chats.insert(0, emergencyChat);
        notifyListeners();
      }
      return emergencyChat;
    }

    if (isDosageRequest) {
      final dosageChat = {
        'id': 'guard_${DateTime.now().millisecondsSinceEpoch}',
        'category': 'ضوابط السلامة الدوائية',
        'title': q.length > 26 ? '${q.substring(0, 26)}...' : q,
        'subtitle': 'ضوابط وصف الجرعات الدوائية الفردية...',
        'time': 'الآن',
        'icon': Icons.medication_liquid_rounded,
        'color': 0xFFF59E0B,
        'isFavorite': false,
        'isEmergency': false,
        'source': 'ضوابط الاستخدام الآمن للأدوية (Medical Safety Guardrails)',
        'question': q,
        'answerIntro': 'بناءً على بروتوكول الأمان الطبي للنظام بخصوص "$q":',
        'bullets': [
          'يختص النظام بتقديم التثقيف الطبي والمعلومات الدوائية العامة والآثار الجانبية.',
          'يُمنع برمجياً تحديد جرعات دوائية فردية أو إصدار وصفات علاجية شخصية دون فحص سريري.',
          'تعتمد الجرعة الآمنة على العمر، الوزن، وظائف الكبد والكلى، والأدوية الأخرى المتناولة.',
        ],
        'importantNote': 'يرجى مراجعة الطبيب المختص أو الصيدلي السريري لتحديد الجرعة المناسبة لحالتك الصحية بدقة.',
        'footer': 'تنويه: المعلومات المقدمة للتثقيف الطبي فقط ولا تغني عن استشارة الطبيب المختص.',
      };
      if (saveChats) {
        chats.insert(0, dosageChat);
        notifyListeners();
      }
      return dosageChat;
    }

    final newChat = {
      'id': 'chat_${DateTime.now().millisecondsSinceEpoch}',
      'category': 'استشارة ذكية (RAG)',
      'title': q.length > 28 ? '${q.substring(0, 28)}...' : q,
      'subtitle': 'تحليل طبي مسترجع من قاعدة المعرفة المحلية...',
      'time': 'الآن',
      'icon': Icons.health_and_safety_rounded,
      'color': 0xFF0077B6,
      'isFavorite': false,
      'isEmergency': false,
      'source': 'البحث الهجين SQLite FTS5 + Vector Similarity (الإصدار $knowledgeVersion)',
      'question': q,
      'answerIntro': 'بناءً على السياق الطبي المسترجع من قاعدة المعرفة المحلية عبر تقنية (RAG) بخصوص "$q"، إليك المعلومات الطبية المنظمة:',
      'bullets': [
        'التعريف والتقييم المبدئي: يُنصح بمراقبة الأعراض الحيوية وتدوين وقت بدايتها ومدى تطورها.',
        'الإرشادات الوقائية: الالتزام بالراحة الكافية، شرب السوائل بانتظام، وتجنب المسببات المهيجة.',
        'الفحوصات المقترحة: قد يتطلب التقييم السريري إجراء تحاليل مخبرية أساسية لتأكيد السبب بدقة.',
        'الاستخدام الدوائي: تجنب أخذ أي مضادات حيوية أو أدوية تخصصية دون وصفة طبية معتمدة.',
      ],
      'importantNote': 'هذه المعلومات مستخرجة محلياً عبر نموذج ($selectedModel) لأغراض التثقيف الصحي العام، ولا تُعد تشخيصاً طبياً نهائياً.',
      'footer': 'إذا استمرت الأعراض أو ازدادت حدتها، يُنصح بمراجعة الطبيب المختص لإجراء الفحص السريري.',
    };

    if (saveChats) {
      chats.insert(0, newChat);
      notifyListeners();
    }
    return newChat;
  }
}

final AppController appController = AppController();

// ================= التطبيق الرئيسي =================
class MediqAiApp extends StatelessWidget {
  const MediqAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appController,
      builder: (context, _) {
        final isDark = appController.isDarkMode;
        return MaterialApp(
          title: 'MEDIQ AI',
          debugShowCheckedModeBanner: false,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF3F7FC),
            primaryColor: const Color(0xFF0077B6),
            cardColor: Colors.white,
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0077B6),
              secondary: Color(0xFF00B4D8),
              surface: Colors.white,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF06101E),
            primaryColor: const Color(0xFF00B4D8),
            cardColor: const Color(0xFF0D1D31),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00B4D8),
              secondary: Color(0xFF00E5FF),
              surface: Color(0xFF0D1D31),
            ),
          ),
          builder: (context, child) => Directionality(
            textDirection: TextDirection.rtl,
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(appController.fontScale),
              ),
              child: child!,
            ),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}

// ================= الشعار الطبي وموجة تخطيط القلب (Logo & ECG) =================
class MediqLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool forceDark;
  final String? customSubtitle;

  const MediqLogo({
    super.key,
    this.size = 42,
    this.showText = true,
    this.forceDark = false,
    this.customSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = forceDark || Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.30),
            gradient: const LinearGradient(
              colors: [Color(0xFF00E5FF), Color(0xFF0077B6), Color(0xFF023E8A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00B4D8).withOpacity(0.28),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.chat_bubble_rounded,
                color: Colors.white.withOpacity(0.18),
                size: size * 0.74,
              ),
              Container(
                width: size * 0.56,
                height: size * 0.56,
                decoration: BoxDecoration(
                  color: const Color(0xFF051324).withOpacity(0.92),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_box_rounded,
                  color: const Color(0xFF00E5FF),
                  size: size * 0.36,
                ),
              ),
            ],
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: size * 0.42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
                  ),
                  children: [
                    TextSpan(
                      text: 'MEDIQ ',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0A192F),
                      ),
                    ),
                    const TextSpan(
                      text: 'AI',
                      style: TextStyle(color: Color(0xFF00B4D8)),
                    ),
                  ],
                ),
              ),
              Text(
                customSubtitle ?? 'مساعدك الطبي الذكي',
                style: TextStyle(
                  fontSize: size * 0.23,
                  color: isDark ? Colors.white70 : const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class AnimatedEcgWave extends StatefulWidget {
  final double width;
  final double height;
  final Color color;
  const AnimatedEcgWave({
    super.key,
    this.width = 220,
    this.height = 45,
    this.color = const Color(0xFF00E5FF),
  });

  @override
  State<AnimatedEcgWave> createState() => _AnimatedEcgWaveState();
}

class _AnimatedEcgWaveState extends State<AnimatedEcgWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          painter: EcgPainter(progress: _ctrl.value, color: widget.color),
        ),
      ),
    );
  }
}

class EcgPainter extends CustomPainter {
  final double progress;
  final Color color;
  EcgPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paintBase = Paint()
      ..color = color.withOpacity(0.20)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final paintGlow = Paint()
      ..color = color
      ..strokeWidth = 2.8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final mid = size.height / 2;
    path.moveTo(0, mid);
    path.lineTo(size.width * 0.28, mid);
    path.lineTo(size.width * 0.34, mid - 6);
    path.lineTo(size.width * 0.39, mid + 6);
    path.lineTo(size.width * 0.45, mid - (size.height * 0.48));
    path.lineTo(size.width * 0.51, mid + (size.height * 0.42));
    path.lineTo(size.width * 0.57, mid - 9);
    path.lineTo(size.width * 0.63, mid);
    path.lineTo(size.width, mid);

    canvas.drawPath(path, paintBase);
    final metric = path.computeMetrics().first;
    final len = metric.length * 0.38;
    final start = (metric.length * progress) - (len / 2);
    final extract = metric.extractPath(
      math.max(0, start),
      math.min(metric.length, start + len),
    );
    canvas.drawPath(extract, paintGlow);
  }

  @override
  bool shouldRepaint(covariant EcgPainter old) => old.progress != progress;
}

// ================= شاشة البداية (SplashScreen - مطابقة للصورة 4) =================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainShell()),
        ),
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF040C18), Color(0xFF082242), Color(0xFF040B16)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00E5FF).withOpacity(0.06),
                    border: Border.all(
                      color: const Color(0xFF00E5FF).withOpacity(0.22),
                      width: 1.5,
                    ),
                  ),
                  child: const MediqLogo(size: 112, showText: false),
                ),
                const SizedBox(height: 26),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                    children: [
                      TextSpan(text: 'MEDIQ ', style: TextStyle(color: Colors.white)),
                      TextSpan(text: 'AI', style: TextStyle(color: Color(0xFF00E5FF))),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Your Medical AI Assistant',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'اسأل ... افهم ... تعلّم',
                  style: TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 28),
                const AnimatedEcgWave(width: 240, height: 48),
                const Spacer(flex: 2),
                const SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Color(0xFF00E5FF),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'جاري تهيئة المساعد الطبي الذكي...',
                  style: TextStyle(color: Colors.white70, fontSize: 13.5),
                ),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================= الهيكل الرئيسي للتطبيق (MainShell) =================
class MainShell extends StatefulWidget {
  // يبدأ افتراضياً على واجهة المحادثة التفاعلية (index 2) كما طلب المستخدم وفي الصورة 1 و 2
  final int initialIndex;
  const MainShell({super.key, this.initialIndex = 2});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _navIndex;
  Map<String, dynamic>? _activeChatData;

  @override
  void initState() {
    super.initState();
    _navIndex = widget.initialIndex;
    // تحميل محادثة ترحيبية جديدة أو أول محادثة
    _activeChatData = {
      'id': 'new',
      'title': 'استفسار طبي',
      'question': '',
      'answerIntro': '',
      'bullets': <String>[],
      'footer': '',
    };
  }

  void _openSpecificChat(Map<String, dynamic> chat) {
    setState(() {
      _activeChatData = Map<String, dynamic>.from(chat);
      _navIndex = 2; // الانتقال مباشرة إلى تبويب واجهة المحادثة
    });
  }

  void _startNewChat([String? initialQuestion]) {
    setState(() {
      _activeChatData = {
        'id': 'new_${DateTime.now().millisecondsSinceEpoch}',
        'isNewSession': true,
        'title': 'استفسار طبي جديد',
        'question': initialQuestion ?? '',
        'answerIntro': '',
        'bullets': <String>[],
        'footer': '',
      };
      _navIndex = 2; // فتح واجهة المحادثة فوراً
    });
  }

  void _openDrawer() {
    mainScaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 960;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final currentChat = _activeChatData ??
        (appController.chats.isNotEmpty
            ? appController.chats.first
            : {
                'id': 'new',
                'isNewSession': true,
                'title': 'استفسار طبي',
                'question': '',
                'answerIntro': '',
                'bullets': <String>[],
                'footer': '',
              });

    final pages = [
      HomeScreen(
        onOpenChat: _openSpecificChat,
        onNewChat: () => _startNewChat(),
        onOpenDrawer: _openDrawer,
      ),
      ExploreScreen(
        onAskQuestion: (q) => _startNewChat(q),
        onOpenDrawer: _openDrawer,
      ),
      ChatScreen(
        key: ValueKey(currentChat['id']),
        chatData: currentChat,
        embedded: true,
        onOpenDrawer: _openDrawer,
        onOpenSettings: () => setState(() => _navIndex = 5),
        onSelectChatFromHistory: _openSpecificChat,
        onStartNewChat: () => _startNewChat(),
      ),
      MedicalToolsScreen(
        embedded: true,
        onOpenDrawer: _openDrawer,
      ),
      MedicalStudentHubScreen(
        embedded: true,
        onOpenDrawer: _openDrawer,
      ),
      SettingsScreen(
        embedded: true,
        onOpenDrawer: _openDrawer,
      ),
    ];

    // واجهة سطح المكتب والشاشات العريضة (3 أعمدة مطابقة للصورة 1 و 2)
    if (isDesktop) {
      return Scaffold(
        key: mainScaffoldKey,
        body: Row(
          children: [
            SizedBox(
              width: 280,
              child: SidebarDrawer(
                selectedIndex: _navIndex,
                onNewChat: () => _startNewChat(),
                onSelectNav: (idx) => setState(() => _navIndex = idx),
                onSelectChat: _openSpecificChat,
              ),
            ),
            Expanded(
              flex: 3,
              child: pages[_navIndex],
            ),
            Container(
              width: 310,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF091524) : Colors.white,
                border: Border(
                  right: BorderSide(
                    color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                  ),
                ),
              ),
              child: const InfoPanel(),
            ),
          ],
        ),
      );
    }

    // واجهة الهاتف والأجهزة اللوحية (مع عمل القائمة الجانبية في جميع الصفحات)
    return Scaffold(
      key: mainScaffoldKey,
      drawer: Drawer(
        width: 295,
        backgroundColor: const Color(0xFF061222),
        child: SidebarDrawer(
          selectedIndex: _navIndex,
          onNewChat: () {
            Navigator.pop(context);
            _startNewChat();
          },
          onSelectNav: (idx) {
            Navigator.pop(context);
            setState(() => _navIndex = idx);
          },
          onSelectChat: (chat) {
            Navigator.pop(context);
            _openSpecificChat(chat);
          },
        ),
      ),
      body: IndexedStack(
        index: _navIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF091524) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _navIndex > 5 ? 0 : _navIndex,
          onDestinationSelected: (i) => setState(() => _navIndex = i),
          backgroundColor: Colors.transparent,
          elevation: 0,
          height: 68,
          indicatorColor: const Color(0xFF0077B6).withOpacity(isDark ? 0.30 : 0.14),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: Color(0xFF0096C7)),
              label: 'الرئيسية',
            ),
            NavigationDestination(
              icon: Icon(Icons.explore_outlined),
              selectedIcon: Icon(Icons.explore_rounded, color: Color(0xFF0096C7)),
              label: 'استكشاف',
            ),
            NavigationDestination(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              selectedIcon: Icon(Icons.chat_bubble_rounded, color: Color(0xFF0096C7)),
              label: 'المحادثات',
            ),
            NavigationDestination(
              icon: Icon(Icons.medical_services_outlined),
              selectedIcon: Icon(Icons.medical_services_rounded, color: Color(0xFF0096C7)),
              label: 'الحاسبات',
            ),
            NavigationDestination(
              icon: Icon(Icons.school_outlined),
              selectedIcon: Icon(Icons.school_rounded, color: Color(0xFF0096C7)),
              label: 'الطلاب',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded, color: Color(0xFF0096C7)),
              label: 'الإعدادات',
            ),
          ],
        ),
      ),
    );
  }
}

// ================= القائمة الجانبية الموحدة (SidebarDrawer - مطابقة للصورة 1 و 2 و 4) =================
class SidebarDrawer extends StatelessWidget {
  final int selectedIndex;
  final VoidCallback onNewChat;
  final Function(int) onSelectNav;
  final Function(Map<String, dynamic>) onSelectChat;

  const SidebarDrawer({
    super.key,
    required this.selectedIndex,
    required this.onNewChat,
    required this.onSelectNav,
    required this.onSelectChat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF061222),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الشعار العلوي
              const MediqLogo(
                size: 40,
                forceDark: true,
                customSubtitle: 'مساعدك الطبي الذكي',
              ),
              const SizedBox(height: 14),

              // بطاقة المستخدم
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xFF0077B6),
                      child: Icon(Icons.person_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appController.userName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                          ),
                          Text(
                            appController.userHandle,
                            style: const TextStyle(color: Colors.white54, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // زر محادثة جديدة (مطابق للصورة 1 و 2 و 4)
              InkWell(
                onTap: onNewChat,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0077B6), Color(0xFF0096C7)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0077B6).withOpacity(0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'محادثة جديدة',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                      Icon(Icons.add_rounded, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // حقل البحث في المحادثات داخل القائمة الجانبية (مطابق للصورة 2)
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: TextField(
                  onChanged: appController.setSearchQuery,
                  style: const TextStyle(color: Colors.white, fontSize: 12.5),
                  decoration: const InputDecoration(
                    hintText: 'البحث في المحادثات...',
                    hintStyle: TextStyle(color: Colors.white54, fontSize: 12),
                    prefixIcon: Icon(Icons.search_rounded, color: Colors.white54, size: 18),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // عناصر القائمة الجانبية + سجل المحادثات السريع
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    _navItem(
                      icon: Icons.history_rounded,
                      title: 'المحادثات السابقة',
                      active: selectedIndex == 0 && !appController.showFavoritesOnly,
                      onTap: () {
                        appController.setShowFavoritesOnly(false);
                        onSelectNav(0);
                      },
                    ),
                    _navItem(
                      icon: Icons.chat_rounded,
                      title: 'واجهة المحادثة الذكية',
                      active: selectedIndex == 2,
                      onTap: () => onSelectNav(2),
                    ),
                    _navItem(
                      icon: Icons.manage_search_rounded,
                      title: 'البحث في المعلومة الطبية',
                      active: selectedIndex == 1,
                      onTap: () => onSelectNav(1),
                    ),
                    _navItem(
                      icon: Icons.star_outline_rounded,
                      title: 'المفضلة',
                      active: selectedIndex == 0 && appController.showFavoritesOnly,
                      onTap: () {
                        appController.setShowFavoritesOnly(true);
                        onSelectNav(0);
                      },
                    ),
                    _navItem(
                      icon: Icons.menu_book_rounded,
                      title: 'الملاحظات والحاسبات الطبية',
                      active: selectedIndex == 3,
                      onTap: () => onSelectNav(3),
                    ),
                    _navItem(
                      icon: Icons.school_outlined,
                      title: 'بوابة طالب الطب (OSCE & GCS)',
                      active: selectedIndex == 4,
                      onTap: () => onSelectNav(4),
                    ),
                    _navItem(
                      icon: Icons.settings_outlined,
                      title: 'الإعدادات',
                      active: selectedIndex == 5,
                      onTap: () => onSelectNav(5),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(color: Colors.white12, height: 1),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 6, right: 4),
                      child: Text(
                        'آخر الاستشارات المحفوظة:',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...appController.filteredChats.take(4).map(
                          (c) => ListTile(
                            onTap: () => onSelectChat(c),
                            dense: true,
                            visualDensity: const VisualDensity(vertical: -3),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 6),
                            leading: Icon(
                              c['icon'] as IconData? ?? Icons.chat_bubble_outline,
                              color: const Color(0xFF00B4D8),
                              size: 16,
                            ),
                            title: Text(
                              c['title'].toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ),
                        ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              // بطاقة حالة العمل المحلي (مطابقة للصورة 2 و 4)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A1E36),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF00B4D8).withOpacity(0.25)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: appController.isLocalServerConnected
                            ? const Color(0xFF10B981)
                            : Colors.orange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appController.isLocalServerConnected
                                ? 'يعمل محلياً'
                                : 'الوضع الاحتياطي',
                            style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const Text(
                            'بدون إنترنت • النموذج متصل بالشبكة المحلية',
                            style: TextStyle(color: Colors.white60, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.wifi_off_rounded, color: Colors.white54, size: 16),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // بطاقة النموذج المستخدم (مطابقة للصورة 2)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A1E36),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.memory_rounded, color: Color(0xFF00E5FF), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'النموذج المستخدم',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11.5,
                            ),
                          ),
                          Text(
                            appController.selectedModel,
                            style: const TextStyle(color: Colors.white60, fontSize: 10.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // تذييل الإصدار (MEDIQ AI v1.0.0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'MEDIQ AI v1.0.0',
                    style: TextStyle(
                      color: Color(0xFF38BDF8),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  InkWell(
                    onTap: () => onSelectNav(5),
                    child: const Icon(
                      Icons.settings_outlined,
                      color: Colors.white54,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String title,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF0077B6).withOpacity(0.22) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        dense: true,
        visualDensity: const VisualDensity(vertical: -2),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        leading: Icon(
          icon,
          color: active ? const Color(0xFF00E5FF) : Colors.white70,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: active ? Colors.white : Colors.white70,
            fontSize: 13,
            fontWeight: active ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ================= الشاشة الرئيسية وسجل المحادثات (HomeScreen - مطابقة للصورة 4) =================
class HomeScreen extends StatelessWidget {
  final Function(Map<String, dynamic>) onOpenChat;
  final VoidCallback onNewChat;
  final VoidCallback onOpenDrawer;

  const HomeScreen({
    super.key,
    required this.onOpenChat,
    required this.onNewChat,
    required this.onOpenDrawer,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chats = appController.filteredChats;

    return SafeArea(
      child: Column(
        children: [
          // الشريط العلوي
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                InkWell(
                  onTap: onOpenDrawer,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Icon(
                      Icons.menu_rounded,
                      color: isDark ? Colors.white : const Color(0xFF0A192F),
                      size: 22,
                    ),
                  ),
                ),
                const Spacer(),
                const MediqLogo(size: 36),
                const Spacer(),
                IconButton(
                  onPressed: appController.toggleTheme,
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: Icon(
                    isDark ? Icons.wb_sunny_rounded : Icons.dark_mode_rounded,
                    color: isDark ? const Color(0xFFFFB703) : const Color(0xFF023E8A),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                // شريط حالة العمل المحلي (مطابق للصورة 4)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'يعمل محلياً',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13.5,
                                color: isDark ? Colors.white : const Color(0xFF0A192F),
                              ),
                            ),
                            const Text(
                              'المساعد المحلي متصل • قاعدة المعرفة جاهزة',
                              style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.dns_rounded, color: Color(0xFF0077B6), size: 22),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // حقل البحث في المحادثات
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: TextField(
                    onChanged: appController.setSearchQuery,
                    decoration: const InputDecoration(
                      hintText: 'ابحث في المحادثات...',
                      hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
                      prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF0077B6)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // زر محادثة جديدة العريض (مطابق للصورة 4)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: onNewChat,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0077B6),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: const Text(
                      'محادثة جديدة',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // عنوان المحادثات الأخيرة
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      appController.showFavoritesOnly
                          ? 'المحادثات المفضلة ⭐'
                          : 'المحادثات الأخيرة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF0A192F),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => appController
                          .setShowFavoritesOnly(!appController.showFavoritesOnly),
                      icon: Icon(
                        appController.showFavoritesOnly
                            ? Icons.view_list_rounded
                            : Icons.star_rounded,
                        size: 18,
                      ),
                      label: Text(
                        appController.showFavoritesOnly ? 'عرض الكل' : 'المفضلة فقط',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // قائمة المحادثات
                ...chats.map((chat) {
                  final isFav = chat['isFavorite'] == true;
                  final accentColor = Color(chat['color'] as int? ?? 0xFF0077B6);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: InkWell(
                      onTap: () => onOpenChat(chat),
                      borderRadius: BorderRadius.circular(18),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                chat['icon'] as IconData? ?? Icons.medical_services,
                                color: accentColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    chat['title'].toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14.5,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF0A192F),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    chat['subtitle'].toString(),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  chat['time'].toString(),
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      appController.toggleFavorite(chat['id'].toString()),
                                  icon: Icon(
                                    isFav ? Icons.star_rounded : Icons.star_border_rounded,
                                    color: isFav
                                        ? const Color(0xFFFFB703)
                                        : const Color(0xFF94A3B8),
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================= شاشة الموسوعة والاستكشاف (ExploreScreen) =================
class ExploreScreen extends StatelessWidget {
  final Function(String) onAskQuestion;
  final VoidCallback onOpenDrawer;

  const ExploreScreen({
    super.key,
    required this.onAskQuestion,
    required this.onOpenDrawer,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topics = [
      {
        'title': 'صحة القلب والشرايين',
        'sub': 'ضغط الدم، ECG، والكوليسترول',
        'icon': Icons.monitor_heart_rounded,
        'color': 0xFFE11D48,
        'q': 'ما هي أعراض ارتفاع ضغط الدم؟'
      },
      {
        'title': 'السكري والغدد',
        'sub': 'مستوى السكر، HbA1c، والأنسولين',
        'icon': Icons.water_drop_rounded,
        'color': 0xFF0096C7,
        'q': 'ما هي أعراض مرض السكري؟'
      },
      {
        'title': 'المناعة والفيتامينات',
        'sub': 'فيتامين D، الحديد، والمناعة',
        'icon': Icons.shield_rounded,
        'color': 0xFF10B981,
        'q': 'كيف يعمل الجهاز المناعي وما فائدة فيتامين D للجسم؟'
      },
      {
        'title': 'الجهاز الهضمي',
        'sub': 'جرثومة المعدة والقولون',
        'icon': Icons.restaurant_menu_rounded,
        'color': 0xFFF59E0B,
        'q': 'ما هي أسباب التهاب المعدة؟'
      },
      {
        'title': 'أمراض الدم والأنيميا',
        'sub': 'نقص الحديد، الهيموجلوبين، CBC',
        'icon': Icons.bloodtype_rounded,
        'color': 0xFF8B5CF6,
        'q': 'ما هي أعراض فقر الدم؟'
      },
      {
        'title': 'الإسعافات والسلامة الطبية',
        'sub': 'التنبيهات الحرجة والطوارئ',
        'icon': Icons.medical_services_rounded,
        'color': 0xFFEC4899,
        'q': 'ما هي الإسعافات الأولية لحالات الإغماء وانخفاض السكر؟'
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.menu_rounded,
            color: isDark ? Colors.white : const Color(0xFF0A192F),
          ),
          onPressed: onOpenDrawer,
        ),
        title: Text(
          'الموسوعة والبحث في المعلومة الطبية',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w900,
            color: isDark ? Colors.white : const Color(0xFF0A192F),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'اختر أي تخصص طبي لبدء استرجاع المعرفة وتوليد الإجابة عبر محرك (RAG) المحلي:',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: topics.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.05,
            ),
            itemBuilder: (context, i) {
              final t = topics[i];
              final c = Color(t['color'] as int);
              return InkWell(
                onTap: () => onAskQuestion(t['q'] as String),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: c.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(t['icon'] as IconData, color: c, size: 24),
                      ),
                      const Spacer(),
                      Text(
                        t['title'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: isDark ? Colors.white : const Color(0xFF0A192F),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t['sub'] as String,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ================= واجهة المحادثة التفاعلية (ChatScreen - مطابقة للصورة 1 و 2 و 4) =================
class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> chatData;
  final bool embedded;
  final VoidCallback? onOpenDrawer;
  final VoidCallback? onOpenSettings;
  final Function(Map<String, dynamic>)? onSelectChatFromHistory;
  final VoidCallback? onStartNewChat;

  const ChatScreen({
    super.key,
    required this.chatData,
    this.embedded = false,
    this.onOpenDrawer,
    this.onOpenSettings,
    this.onSelectChatFromHistory,
    this.onStartNewChat,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final List<Map<String, dynamic>> _exchanges = [];
  bool _loading = false;
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      if (mounted) {
        setState(() => _charCount = _ctrl.text.length);
      }
    });

    final initialQ = widget.chatData['question']?.toString() ?? '';
    final isNewSession = widget.chatData['isNewSession'] == true ||
        widget.chatData['id'].toString().startsWith('new');
    if (isNewSession && initialQ.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _send(initialQ));
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _send([String? preset]) async {
    final txt = preset ?? _ctrl.text.trim();
    if (txt.isEmpty || _loading) return;
    _ctrl.clear();

    // التحقق مما إذا كان السؤال يطابق إحدى المحادثات المخزنة مسبقاً لعرض تفاصيلها الكاملة
    Map<String, dynamic>? matchedPrebuilt;
    for (final c in appController.chats) {
      if (c['question'].toString().trim() == txt ||
          txt.contains('فقر الدم') && c['id'] == 'anemia' ||
          txt.contains('السكري') && c['id'] == 'diabetes' ||
          txt.contains('التهاب المعدة') && c['id'] == 'gastritis' ||
          txt.contains('فيتامين D') && c['id'] == 'vitamind') {
        matchedPrebuilt = Map<String, dynamic>.from(c);
        matchedPrebuilt['question'] = txt;
        break;
      }
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 650));

    final reply = matchedPrebuilt ?? appController.generateReply(txt);
    if (mounted) {
      setState(() {
        _loading = false;
        _exchanges.add(reply);
      });
    }
  }

  void _showAttachmentSheet(String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم فتح معالج استيراد $type المحلي (Offline OCR / Document Ingestion)'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNewSession = widget.chatData['isNewSession'] == true ||
        widget.chatData['id'].toString().startsWith('new');
    final hasInitialBuiltInAnswer =
        !isNewSession && (widget.chatData['question']?.toString().isNotEmpty ?? false);
    final showWelcome = !hasInitialBuiltInAnswer && _exchanges.isEmpty && !_loading;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        leading: IconButton(
          tooltip: 'القائمة الجانبية',
          icon: Icon(
            Icons.menu_rounded,
            color: isDark ? Colors.white : const Color(0xFF0A192F),
          ),
          onPressed: () {
            if (widget.onOpenDrawer != null) {
              widget.onOpenDrawer!();
            } else {
              mainScaffoldKey.currentState?.openDrawer();
            }
          },
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.edit_outlined, size: 14, color: Color(0xFF0077B6)),
                  const SizedBox(width: 5),
                  Text(
                    widget.chatData['title']?.toString() ?? 'استفسار طبي',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0A192F),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      'يعمل محلياً • ${appController.selectedModel}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (!showWelcome)
            IconButton(
              tooltip: 'بدء محادثة جديدة',
              onPressed: () {
                setState(() => _exchanges.clear());
                if (widget.onStartNewChat != null) widget.onStartNewChat!();
              },
              icon: const Icon(Icons.add_comment_outlined, size: 20),
            ),
          IconButton(
            tooltip: 'معلومات النظام والتنويه الطبي',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Theme.of(context).cardColor,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (_) => const SizedBox(height: 520, child: InfoPanel()),
              );
            },
            icon: const Icon(Icons.info_outline_rounded, size: 20),
          ),
          if (widget.onOpenSettings != null)
            IconButton(
              tooltip: 'الإعدادات',
              onPressed: widget.onOpenSettings,
              icon: const Icon(Icons.settings_outlined, size: 20),
            ),
        ],
      ),
      body: Column(
        children: [
          // لافتة التنويه الطبي الثابتة (الفصل الرابع - قسم 4.7.5 Disclaimer Banner)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            color: const Color(0xFF0077B6).withOpacity(isDark ? 0.18 : 0.08),
            child: const Row(
              children: [
                Icon(Icons.verified_user_outlined, size: 15, color: Color(0xFF0077B6)),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'مساعد طبي محلي (Offline RAG): المعلومات للتثقيف الطبي العام ولا تغني عن استشارة الطبيب.',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0077B6),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: showWelcome
                ? _buildWelcomeView(isDark)
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (hasInitialBuiltInAnswer) ...[
                        _userBubble(
                          widget.chatData['question'].toString(),
                          widget.chatData['time']?.toString() ?? '10:24 م',
                        ),
                        const SizedBox(height: 14),
                        _aiBubble(widget.chatData, isDark),
                      ],
                      ..._exchanges.map(
                        (ex) => Padding(
                          padding: const EdgeInsets.only(top: 18),
                          child: Column(
                            children: [
                              _userBubble(
                                ex['question'].toString(),
                                ex['time']?.toString() ?? 'الآن',
                              ),
                              const SizedBox(height: 14),
                              _aiBubble(ex, isDark),
                            ],
                          ),
                        ),
                      ),
                      if (_loading)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: const Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Color(0xFF0096C7),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'جاري البحث الهجين (SQLite FTS5 + Vector) وتوليد الإجابة محلياً...',
                                    style: TextStyle(
                                      color: Color(0xFF0096C7),
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
          _inputBar(isDark),
        ],
      ),
    );
  }

  // شاشة الترحيب المركزية المطابقة للصورة 1 تماماً
  Widget _buildWelcomeView(bool isDark) {
    final quickCards = [
      {
        't': 'ما هي أعراض ارتفاع ضغط الدم؟',
        'sub': 'القلب والشرايين',
        'i': Icons.favorite_border_rounded,
        'c': 0xFF0077B6
      },
      {
        't': 'كيف يعمل الجهاز المناعي؟',
        'sub': 'المناعة والوقاية',
        'i': Icons.shield_outlined,
        'c': 0xFF0096C7
      },
      {
        't': 'ما فائدة فيتامين D للجسم؟',
        'sub': 'الفيتامينات',
        'i': Icons.medication_outlined,
        'c': 0xFF10B981
      },
      {
        't': 'ما هي أعراض فقر الدم؟',
        'sub': 'أمراض الدم (الأنيميا)',
        'i': Icons.bloodtype_outlined,
        'c': 0xFFE11D48
      },
    ];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const MediqLogo(size: 74, showText: false),
            const SizedBox(height: 12),
            RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                children: [
                  TextSpan(
                    text: 'MEDIQ ',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF0A192F),
                    ),
                  ),
                  const TextSpan(
                    text: 'AI',
                    style: TextStyle(color: Color(0xFF00B4D8)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'مساعدك الطبي الذكي',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'كيف يمكنني مساعدتك اليوم؟',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0A192F),
              ),
            ),
            const SizedBox(height: 20),

            // البطاقات التفاعلية الأربع المطابقة للصورة 1
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: quickCards.map((item) {
                final c = Color(item['c'] as int);
                return InkWell(
                  onTap: () => _send(item['t'] as String),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 162,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: c.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(item['i'] as IconData, color: c, size: 18),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.arrow_outward_rounded,
                              size: 14,
                              color: Color(0xFF94A3B8),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item['t'] as String,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            height: 1.35,
                            color: isDark ? Colors.white : const Color(0xFF0A192F),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 22),
            // اختصارات المحادثات السابقة للوصول السريع
            if (appController.chats.isNotEmpty) ...[
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'أو استكمل إحدى المحادثات الطبية السابقة:',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : const Color(0xFF475569),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: appController.chats.map((c) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ActionChip(
                        avatar: Icon(
                          c['icon'] as IconData? ?? Icons.chat_bubble_outline,
                          size: 16,
                          color: const Color(0xFF0077B6),
                        ),
                        label: Text(
                          c['title'].toString(),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        onPressed: () {
                          if (widget.onSelectChatFromHistory != null) {
                            widget.onSelectChatFromHistory!(c);
                          } else {
                            _send(c['question'].toString());
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // فقاعة سؤال المستخدم (مطابقة للصورة 2 و 4)
  Widget _userBubble(String txt, String time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CircleAvatar(
          radius: 17,
          backgroundColor: Color(0xFFDBEAFE),
          child: Icon(Icons.person_rounded, color: Color(0xFF0284C7), size: 20),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFDCEBFA),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(4),
                bottomLeft: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 4),
                Text(
                  txt,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.w800,
                    fontSize: 14.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // بطاقة إجابة المساعد الطبي الذكي (مطابقة للصورة 2 و 4 مع المصادر وأزرار التفاعل)
  Widget _aiBubble(Map<String, dynamic> data, bool isDark) {
    final sections = data['sections'] as List?;
    final bullets = (data['bullets'] as List?)?.cast<String>() ?? [];
    final isEmergency = data['isEmergency'] == true;
    final importantNote = data['importantNote']?.toString() ?? '';
    final source = data['source']?.toString() ?? 'قاعدة المعرفة الطبية المحلية (SQLite FTS5)';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEmergency
              ? Colors.redAccent
              : (isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
          width: isEmergency ? 1.6 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ترويسة البطاقة
          Row(
            children: [
              const MediqLogo(size: 30, showText: false),
              const SizedBox(width: 8),
              Text(
                'MEDIQ AI',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13.5,
                  color: isDark ? Colors.white : const Color(0xFF0A192F),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                data['time']?.toString() ?? '10:25 م',
                style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF0096C7).withOpacity(0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'RAG المحلي',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0096C7),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 22),

          // المقدمة
          Text(
            data['answerIntro']?.toString() ?? '',
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              fontWeight: FontWeight.w700,
              color: isEmergency
                  ? Colors.redAccent
                  : (isDark ? Colors.white : const Color(0xFF1E293B)),
            ),
          ),
          const SizedBox(height: 12),

          // عرض الأقسام التفصيلية (إن وجدت مثل محادثة فقر الدم في الصورة 2)
          if (sections != null && sections.isNotEmpty)
            ...sections.map((sec) {
              final mapSec = sec as Map<String, dynamic>;
              final secItems = (mapSec['items'] as List).cast<String>();
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mapSec['heading'].toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 13.5,
                        color: isDark
                            ? const Color(0xFF38BDF8)
                            : const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    ...secItems.map(
                      (itm) => Padding(
                        padding: const EdgeInsets.only(bottom: 5, right: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '• ',
                              style: TextStyle(
                                color: Color(0xFF0096C7),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                itm,
                                style: TextStyle(
                                  fontSize: 13.5,
                                  height: 1.45,
                                  color: isDark
                                      ? Colors.white.withOpacity(0.9)
                                      : const Color(0xFF334155),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            })
          else
            // عرض النقاط القياسية
            ...bullets.map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: 7, right: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Icon(Icons.circle, color: Color(0xFF0096C7), size: 7),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        b,
                        style: TextStyle(
                          fontSize: 13.5,
                          height: 1.5,
                          color: isDark
                              ? Colors.white.withOpacity(0.88)
                              : const Color(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 10),

          // صندوق "مهم:" الأزرق المطابق للصورة 2
          if (importantNote.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isEmergency
                    ? Colors.red.withOpacity(0.10)
                    : const Color(0xFF0284C7).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isEmergency
                      ? Colors.redAccent.withOpacity(0.4)
                      : const Color(0xFF0284C7).withOpacity(0.25),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_rounded,
                    color: isEmergency ? Colors.redAccent : const Color(0xFF0284C7),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.5,
                          color: isDark ? Colors.white : const Color(0xFF1E3A8A),
                        ),
                        children: [
                          const TextSpan(
                            text: 'مهم: ',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          TextSpan(text: importantNote),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // الخاتمة والتوجيه
          if (data['footer'] != null && data['footer'].toString().isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              data['footer'].toString(),
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : const Color(0xFF475569),
              ),
            ),
          ],

          const SizedBox(height: 10),
          // سطر المصدر الطبي المسترجع (تحقيق الهدف 8 من الفصل الأول)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.04) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.library_books_outlined, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'المصدر المرجعي: $source',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          // شريط أزرار الإجراءات السفلية المطابق للصورة 2 و 4 (إعجاب، عدم إعجاب، نسخ، إعادة توليد)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _actionBtn(
                icon: Icons.thumb_up_alt_outlined,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('شكراً لتقييمك الإيجابي للإجابة الطبية ✓')),
                  );
                },
              ),
              _actionBtn(
                icon: Icons.thumb_down_alt_outlined,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم تسجيل ملاحظتك لتحسين دقة الاسترجاع')),
                  );
                },
              ),
              _actionBtn(
                icon: Icons.copy_rounded,
                label: 'نسخ الإجابة',
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text:
                          '${data['answerIntro']}\n${bullets.join("\n")}\n$importantNote\n${data['footer']}',
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم نسخ الإجابة الطبية إلى الحافظة ✓')),
                  );
                },
              ),
              _actionBtn(
                icon: Icons.refresh_rounded,
                label: 'إعادة التوليد',
                onTap: () => _send(data['question'].toString()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({
    required IconData icon,
    String label = '',
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFCBD5E1).withOpacity(0.6)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: const Color(0xFF64748B)),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // شريط الإدخال السفلي المطابق للصورة 2 و 4 (مع المرفقات وعداد الأحرف 0/4000)
  Widget _inputBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF06101E) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isDark ? Colors.white12 : const Color(0xFFDCE4F0),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _ctrl,
                      maxLines: 3,
                      minLines: 1,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'اكتب سؤالك الطبي هنا...',
                        hintStyle: TextStyle(fontSize: 13.5, color: Color(0xFF94A3B8)),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                    Row(
                      children: [
                        InkWell(
                          onTap: () => _showAttachmentSheet('ملف طبي'),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.attach_file_rounded, size: 18, color: Color(0xFF64748B)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () => _showAttachmentSheet('صورة تحاليل / أشعة'),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.image_outlined, size: 18, color: Color(0xFF64748B)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () => _showAttachmentSheet('تقرير PDF'),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.description_outlined, size: 18, color: Color(0xFF64748B)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () => _showAttachmentSheet('إدخال صوتي'),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.mic_none_rounded, size: 18, color: Color(0xFF64748B)),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '$_charCount/4000',
                          style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: () => _send(),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0096C7), Color(0xFF0077B6)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= الحاسبات والأدوات الطبية المتقدمة (جميع التبويبات الـ 5 كاملة) =================
class MedicalToolsScreen extends StatefulWidget {
  final bool embedded;
  final VoidCallback? onOpenDrawer;

  const MedicalToolsScreen({
    super.key,
    this.embedded = false,
    this.onOpenDrawer,
  });

  @override
  State<MedicalToolsScreen> createState() => _MedicalToolsScreenState();
}

class _MedicalToolsScreenState extends State<MedicalToolsScreen> {
  int _selectedTab = 0; // 0: BMI, 1: Vitals, 2: Lab, 3: Water & Meds, 4: Interactions

  final TextEditingController _weightCtrl = TextEditingController(text: '70');
  final TextEditingController _heightCtrl = TextEditingController(text: '175');
  String _bmiResult = '';

  final TextEditingController _bpCtrl = TextEditingController(text: '120/80');
  String _labType = 'السكر التراكمي (HbA1c)';
  final TextEditingController _labValCtrl = TextEditingController(text: '5.8');
  String _labResult = '';
  int _waterCups = 5;

  @override
  void dispose() {
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _bpCtrl.dispose();
    _labValCtrl.dispose();
    super.dispose();
  }

  void _calcBmi() {
    final w = double.tryParse(_weightCtrl.text) ?? 0;
    final h = double.tryParse(_heightCtrl.text) ?? 0;
    if (w <= 0 || h <= 0) return;
    final hm = h / 100;
    final bmi = w / (hm * hm);
    String status = '';
    if (bmi < 18.5) {
      status = 'وزن منخفض (Underweight)';
    } else if (bmi < 25) {
      status = 'وزن مثالي وطبيعي (Normal) ✅';
    } else if (bmi < 30) {
      status = 'زيادة وزن (Overweight)';
    } else {
      status = 'سمنة (Obese) - يُنصح بالمتابعة الغذائية';
    }
    setState(() {
      _bmiResult = 'مؤشر كتلة الجسم (BMI): ${bmi.toStringAsFixed(1)}\nالتصنيف السريري: $status';
    });
  }

  void _interpretLab() {
    final v = double.tryParse(_labValCtrl.text) ?? 0;
    String res = '';
    if (_labType.contains('HbA1c')) {
      if (v < 5.7) {
        res = 'طبيعي (سليم) ✅';
      } else if (v < 6.5) {
        res = 'مرحلة ما قبل السكري (Prediabetes) - يُنصح بتعديل النمط الغذائي والرياضي.';
      } else {
        res = 'مرتفع (مؤشر لمرض السكري) - يرجى مراجعة طبيب الغدد الصماء.';
      }
    } else if (_labType.contains('فيتامين D')) {
      if (v < 20) {
        res = 'نقص حاد (Deficient) - يتطلب مكملات علاجية بإشراف طبي.';
      } else if (v < 30) {
        res = 'نقص غير كافٍ (Insufficient).';
      } else {
        res = 'مستوى طبيعي ومطمئن (Sufficient) ✅';
      }
    } else {
      if (v >= 12 && v <= 16) {
        res = 'مستوى الهيموجلوبين طبيعي ✅';
      } else if (v < 12) {
        res = 'انخفاض في الهيموجلوبين (احتمال فقر دم / أنيميا) - يُنصح بفحص مخزون الحديد Ferritin.';
      } else {
        res = 'ارتفاع فوق المعدل المعتاد - يُنصح بمراجعة الطبيب.';
      }
    }
    setState(() => _labResult = res);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.menu_rounded,
            color: isDark ? Colors.white : const Color(0xFF0A192F),
          ),
          onPressed: () {
            if (widget.onOpenDrawer != null) {
              widget.onOpenDrawer!();
            } else {
              mainScaffoldKey.currentState?.openDrawer();
            }
          },
        ),
        title: Text(
          'الملاحظات والحاسبات الطبية السريرية',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 17,
            color: isDark ? Colors.white : const Color(0xFF0A192F),
          ),
        ),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _tabBtn('حاسبة BMI', 0),
                _tabBtn('سجل العلامات الحيوية', 1),
                _tabBtn('مفسر التحاليل المخبرية', 2),
                _tabBtn('الماء والأدوية اليومية', 3),
                _tabBtn('التعارضات والبطاقة الطبية', 4),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_selectedTab == 0) _buildBmiCard(isDark),
                if (_selectedTab == 1) _buildVitalsCard(isDark),
                if (_selectedTab == 2) _buildLabCard(isDark),
                if (_selectedTab == 3) _buildWaterAndMedsCard(isDark),
                if (_selectedTab == 4) _buildInteractionsAndIdCard(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabBtn(String label, int index) {
    final active = _selectedTab == index;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: active,
        onSelected: (_) => setState(() => _selectedTab = index),
        selectedColor: const Color(0xFF0077B6),
        labelStyle: TextStyle(
          color: active ? Colors.white : null,
          fontWeight: FontWeight.bold,
          fontSize: 12.5,
        ),
      ),
    );
  }

  Widget _buildBmiCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'حاسبة مؤشر كتلة الجسم والوزن المثالي (BMI)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _weightCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'الوزن بالكيلوجرام (kg)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _heightCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'الطول بالسنتيمتر (cm)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _calcBmi,
              icon: const Icon(Icons.calculate_rounded),
              label: const Text('احسب المؤشر الآن'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0077B6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          if (_bmiResult.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0096C7).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _bmiResult,
                style: const TextStyle(fontWeight: FontWeight.bold, height: 1.5),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVitalsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تسجيل قراءة ضغط الدم أو السكر أو النبض',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _bpCtrl,
            decoration: const InputDecoration(
              labelText: 'القراءة (مثال: 120/80 أو 95 mg/dl)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () {
              if (_bpCtrl.text.trim().isEmpty) return;
              appController.addVital('قياس حيوي', _bpCtrl.text.trim(), 'مسجل');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تم حفظ القراءة في السجل الحيوي المحلي ✓')),
              );
              setState(() {});
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('حفظ في السجل الحيوي'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'سجل القراءات السابقة:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          ...appController.vitalsLog.map(
            (v) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.monitor_heart_rounded, color: Color(0xFF0077B6)),
              title: Text('${v['type']}: ${v['val']}', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('التوقيت: ${v['date']}'),
              trailing: Chip(
                label: Text(v['status'].toString(), style: const TextStyle(fontSize: 11)),
                backgroundColor: Colors.green.withOpacity(0.12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'مفسر التحاليل المخبرية السريع',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _labType,
            items: const [
              DropdownMenuItem(
                value: 'السكر التراكمي (HbA1c)',
                child: Text('السكر التراكمي (HbA1c %)'),
              ),
              DropdownMenuItem(
                value: 'فيتامين D (Vit D)',
                child: Text('فيتامين D (ng/mL)'),
              ),
              DropdownMenuItem(
                value: 'الهيموجلوبين (Hemoglobin)',
                child: Text('الهيموجلوبين (g/dL) - فقر الدم'),
              ),
            ],
            onChanged: (val) => setState(() => _labType = val!),
            decoration: const InputDecoration(
              labelText: 'نوع التحليل المخبري',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _labValCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'النتيجة الرقمية للتحليل',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: _interpretLab,
            icon: const Icon(Icons.biotech_rounded),
            label: const Text('قراءة النتيجة المخبرية'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0077B6),
              foregroundColor: Colors.white,
            ),
          ),
          if (_labResult.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _labResult,
                style: const TextStyle(fontWeight: FontWeight.bold, height: 1.5),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWaterAndMedsCard(bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              const Text(
                'عدّاد شرب الماء اليومي (Hydration Tracker)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => setState(() => _waterCups = math.max(0, _waterCups - 1)),
                    icon: const Icon(Icons.remove_circle_rounded, size: 32, color: Colors.redAccent),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '$_waterCups / 8 أكواب',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0077B6),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() => _waterCups += 1),
                    icon: const Icon(Icons.add_circle_rounded, size: 32, color: Colors.green),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: (_waterCups / 8).clamp(0.0, 1.0),
                minHeight: 10,
                borderRadius: BorderRadius.circular(10),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'منبه المكملات والأدوية اليومية',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              ...List.generate(appController.medsList.length, (i) {
                final med = appController.medsList[i];
                return CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(med['name'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('الموعد: ${med['time']}'),
                  value: med['status'] as bool,
                  onChanged: (_) => setState(() => appController.toggleMed(i)),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInteractionsAndIdCard(bool isDark) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'دليل التعارضات الدوائية والغذائية الهامة',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              SizedBox(height: 10),
              Text(
                '• حبوب الحديد والكالسيوم: لا تتناولها مع الشاي أو القهوة في نفس الوقت لأن التانينات تقلل امتصاص الحديد.\n'
                '• المسكنات (NSAIDs مثل الإيبوبروفين): تؤخذ بعد الطعام لحماية الغشاء المخاطي للمعدة.\n'
                '• أدوية السيولة (الوارفارين): تتطلب ثبات كمية الخضروات الورقية الغنية بفيتامين K.\n'
                '• المضادات الحيوية (التتراسيكلين/السيبروفلوكساسين): تجنب تناولها مع الحليب ومشتقات الألبان.',
                style: TextStyle(height: 1.6, fontSize: 13.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.badge_rounded, color: Color(0xFFE11D48)),
                  SizedBox(width: 8),
                  Text(
                    'بطاقة الهوية الطبية للطوارئ (Medical ID)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
              const Divider(height: 20),
              Text('الاسم: ${appController.medicalId['name']}'),
              Text('فصيلة الدم: ${appController.medicalId['blood']}'),
              Text('الحساسية الدوائية: ${appController.medicalId['allergies']}'),
              Text('الأمراض المزمنة: ${appController.medicalId['conditions']}'),
              Text('رقم الطوارئ: ${appController.medicalId['contact']}'),
            ],
          ),
        ),
      ],
    );
  }
}

// ================= بوابة طالب الطب والتدريب السريري (جميع التبويبات الـ 4 كاملة) =================
class MedicalStudentHubScreen extends StatefulWidget {
  final bool embedded;
  final VoidCallback? onOpenDrawer;

  const MedicalStudentHubScreen({
    super.key,
    this.embedded = false,
    this.onOpenDrawer,
  });

  @override
  State<MedicalStudentHubScreen> createState() => _MedicalStudentHubScreenState();
}

class _MedicalStudentHubScreenState extends State<MedicalStudentHubScreen> {
  int _tab = 0; // 0: GCS, 1: Abbreviations, 2: ECG & XRay, 3: Flashcards
  int _gcsE = 4;
  int _gcsV = 5;
  int _gcsM = 6;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalGcs = _gcsE + _gcsV + _gcsM;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.menu_rounded,
            color: isDark ? Colors.white : const Color(0xFF0A192F),
          ),
          onPressed: () {
            if (widget.onOpenDrawer != null) {
              widget.onOpenDrawer!();
            } else {
              mainScaffoldKey.currentState?.openDrawer();
            }
          },
        ),
        title: Text(
          'بوابة طالب الطب والتدريب السريري (OSCE)',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 17,
            color: isDark ? Colors.white : const Color(0xFF0A192F),
          ),
        ),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _tabBtn('مقياس الوعي GCS', 0),
                _tabBtn('الاختصارات الطبية', 1),
                _tabBtn('منهجية ECG والأشعة', 2),
                _tabBtn('بطاقات OSCE السريرية', 3),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_tab == 0)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'حاسبة غلاسكو للغيبوبة (GCS Score): $totalGcs / 15',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                            color: Color(0xFF0077B6),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          totalGcs >= 13
                              ? 'التقييم: إصابة خفيفة / وعي جيد (Mild)'
                              : totalGcs >= 9
                                  ? 'التقييم: إصابة متوسطة (Moderate)'
                                  : 'التقييم: غيبوبة / إصابة شديدة حرجة (Severe ≤ 8)',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 14),
                        _gcsDropdown(
                          'استجابة فتح العين (Eye Opening - E)',
                          _gcsE,
                          {
                            4: 'تلقائية (Spontaneous)',
                            3: 'عند المناداة (To Speech)',
                            2: 'عند الألم (To Pain)',
                            1: 'لا توجد استجابة (None)'
                          },
                          (v) => setState(() => _gcsE = v),
                        ),
                        _gcsDropdown(
                          'الاستجابة اللفظية (Verbal Response - V)',
                          _gcsV,
                          {
                            5: 'مدرك للزمان والمكان (Oriented)',
                            4: 'مشوش الذهن (Confused)',
                            3: 'كلمات غير مترابطة (Inappropriate words)',
                            2: 'أصوات غير مفهومة (Incomprehensible sounds)',
                            1: 'لا توجد استجابة (None)'
                          },
                          (v) => setState(() => _gcsV = v),
                        ),
                        _gcsDropdown(
                          'الاستجابة الحركية (Motor Response - M)',
                          _gcsM,
                          {
                            6: 'يطيع الأوامر الحركية (Obeys commands)',
                            5: 'يحدد موضع الألم (Localizes pain)',
                            4: 'يسحب الطرف عند الألم (Normal withdrawal)',
                            3: 'انثناء غير طبيعي (Decorticate flexion)',
                            2: 'انبساط غير طبيعي (Decerebrate extension)',
                            1: 'لا توجد استجابة (None)'
                          },
                          (v) => setState(() => _gcsM = v),
                        ),
                      ],
                    ),
                  ),
                if (_tab == 1)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'قاموس الاختصارات الطبية السريرية (Medical Abbreviations)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 12),
                        Text(
                          '• OD / QD: مرة واحدة يومياً (Once daily)\n'
                          '• BID: مرتان يومياً كل 12 ساعة (Twice a day)\n'
                          '• TID: ثلاث مرات يومياً كل 8 ساعات (Three times a day)\n'
                          '• QID: أربع مرات يومياً كل 6 ساعات\n'
                          '• PRN: عند اللزوم فقط (As needed)\n'
                          '• STAT: فوراً وبشكل طارئ وعاجل (Immediately)\n'
                          '• NPO: صائم تماماً عن الفم (Nothing by mouth)\n'
                          '• PO / IV / IM / SC: فموي / وريدي / عضلي / تحت الجلد\n'
                          '• SOB: ضيق التنفس (Shortness of breath)\n'
                          '• CBC / LFT / RFT: صورة الدم الكاملة / وظائف الكبد / وظائف الكلى',
                          style: TextStyle(height: 1.65, fontSize: 13.5),
                        ),
                      ],
                    ),
                  ),
                if (_tab == 2)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'منهجية قراءة تخطيط القلب (ECG) وأشعة الصدر (CXR)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15.5,
                            color: Color(0xFF0077B6),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'أولاً: خطوات قراءة تخطيط القلب (ECG):\n'
                          '1. السرعة (Rate): 300 مقسومة على عدد المربعات الكبيرة بين قمتي R-R.\n'
                          '2. النظم (Rhythm): انتظام المسافات R-R ووجود موجة P قبل كل QRS.\n'
                          '3. المحور الكهربائي (Axis): فحص اتجاه QRS في الاتجاهين Lead I و aVF.\n'
                          '4. الفواصل (PR & QT Intervals) وعرض مركب QRS.\n'
                          '5. قطعة ST (ST-Segment): البحث عن أي ارتفاع (STEMI) أو انخفاض (Ischemia).\n\n'
                          'ثانياً: منهجية أشعة الصدر (ABCDEF):\n'
                          '• A (Airways): استقامة القصبة الهوائية في المنتصف.\n'
                          '• B (Bones): الأضلاع والترقوة والفقرات.\n'
                          '• C (Cardiac): حجم ظل القلب (CTR < 50%).\n'
                          '• D (Diaphragm): الحجاب الحاجز والزوايا الضلعية الحجابية.\n'
                          '• E (Effusion / Edges) & F (Lung Fields): نقاء الساحتين الرئويتين.',
                          style: TextStyle(height: 1.55, fontSize: 13.5),
                        ),
                      ],
                    ),
                  ),
                if (_tab == 3)
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'بطاقات العلامات السريرية السريعة (Clinical Flashcards)',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        SizedBox(height: 12),
                        Text(
                          '• علامة ميرفي (Murphy\'s Sign): توقف الشهيق بسبب الألم عند جس الربع العلوي الأيمن للبطن -> التهاب المرارة الحاد (Acute Cholecystitis).\n\n'
                          '• نقطة ماكبرني (McBurney\'s Point): ألم ارتدادي في الربع السفلي الأيمن -> التهاب الزائدة الدودية الحاد (Acute Appendicitis).\n\n'
                          '• علامة بابينسكي (Babinski Sign): انبساط أصابع القدم للأعلى عند البالغين -> إصابة العصبون الحركي العلوي (UMN Lesion).\n\n'
                          '• ثالوث بيك (Beck\'s Triad): انخفاض الضغط + احتقان أوردة العنق + خفوت أصوات القلب -> الاندحاس القلبي (Cardiac Tamponade).',
                          style: TextStyle(height: 1.6, fontSize: 13.5),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabBtn(String label, int index) {
    final active = _tab == index;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: active,
        onSelected: (_) => setState(() => _tab = index),
        selectedColor: const Color(0xFF0077B6),
        labelStyle: TextStyle(
          color: active ? Colors.white : null,
          fontWeight: FontWeight.bold,
          fontSize: 12.5,
        ),
      ),
    );
  }

  Widget _gcsDropdown(
    String title,
    int currentVal,
    Map<int, String> options,
    Function(int) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF0096C7),
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<int>(
            value: currentVal,
            items: options.entries
                .map(
                  (e) => DropdownMenuItem(
                    value: e.key,
                    child: Text('${e.key} - ${e.value}', style: const TextStyle(fontSize: 13)),
                  ),
                )
                .toList(),
            onChanged: (val) => onChanged(val!),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= شاشة الإعدادات وإدارة المعرفة والنماذج (مطابقة للصورة 4 + الفصل الرابع) =================
class SettingsScreen extends StatelessWidget {
  final bool embedded;
  final VoidCallback? onOpenDrawer;

  const SettingsScreen({
    super.key,
    this.embedded = false,
    this.onOpenDrawer,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAdmin = appController.userRole.contains('مدير');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.menu_rounded,
            color: isDark ? Colors.white : const Color(0xFF0A192F),
          ),
          onPressed: () {
            if (onOpenDrawer != null) {
              onOpenDrawer!();
            } else {
              mainScaffoldKey.currentState?.openDrawer();
            }
          },
        ),
        title: Text(
          'الإعدادات',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0A192F),
            fontWeight: FontWeight.w900,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // بطاقة المستخدم العلوية (مطابقة للصورة 4)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  backgroundColor: Color(0xFF0077B6),
                  child: Icon(Icons.person_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appController.userName,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                      ),
                      Text(
                        appController.userHandle,
                        style: const TextStyle(color: Color(0xFF64748B), fontSize: 12.5),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'الصلاحية (RBAC): ${appController.userRole}',
                        style: const TextStyle(
                          color: Color(0xFF0096C7),
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: appController.toggleRole,
                  child: const Text('تبديل الدور', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // قسم إعدادات التطبيق (مطابق للصورة 4 تماماً)
          const Padding(
            padding: EdgeInsets.only(bottom: 8, right: 4),
            child: Text(
              'إعدادات التطبيق',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
            ),
          ),
          _tile(
            context,
            isDark ? Icons.dark_mode_outlined : Icons.wb_sunny_outlined,
            'المظهر',
            isDark ? 'الوضع الداكن' : 'الوضع الفاتح',
            appController.toggleTheme,
          ),
          _tile(
            context,
            Icons.language_rounded,
            'اللغة',
            appController.language,
            () {},
          ),
          _tile(
            context,
            Icons.text_fields_rounded,
            'حجم الخط',
            appController.fontSizeLabel,
            appController.cycleFontSize,
          ),
          _switchTile(
            context,
            icon: Icons.save_outlined,
            title: 'حفظ المحادثات محلياً (SQLite)',
            value: appController.saveChats,
            onChanged: appController.toggleSaveChats,
          ),
          _switchTile(
            context,
            icon: Icons.notifications_none_rounded,
            title: 'الإشعارات والتنبيهات الطبية',
            value: appController.notificationsEnabled,
            onChanged: appController.toggleNotifications,
          ),

          const SizedBox(height: 16),
          // قسم معلومات النموذج المحلي (مطابق للصورة 4)
          const Padding(
            padding: EdgeInsets.only(bottom: 8, right: 4),
            child: Text(
              'معلومات النموذج والمحرك المحلي',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
            ),
          ),
          _tile(
            context,
            Icons.memory_rounded,
            'اسم النموذج (Local LLM)',
            appController.selectedModel,
            appController.cycleModel,
          ),
          _tile(
            context,
            Icons.dns_outlined,
            'حالة الخادم المحلي (llama.cpp)',
            appController.isLocalServerConnected ? 'متصل ●' : 'متوقف ○',
            appController.toggleServerStatus,
          ),
          _tile(
            context,
            Icons.storage_rounded,
            'إصدار قاعدة المعرفة الطبية',
            appController.knowledgeVersion,
            () {},
          ),

          // قسم إدارة المعرفة والنماذج (Knowledge Admin Dashboard - الفصل الرابع 4.7.4 و 4.8.2)
          if (isAdmin) ...[
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.only(bottom: 8, right: 4),
              child: Text(
                'لوحة مدير المعرفة (Knowledge Admin & Ingestion)',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: Color(0xFF0077B6),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF0077B6).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'مسار ملف النموذج المكمم (GGUF Model Path):',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    appController.ggufModelPath,
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'الوثائق الطبية المفهرسة (FTS5 + Vectors):',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          appController.addKnowledgeDocument(
                            'تحديث البروتوكول العلاجي ${DateTime.now().minute}.pdf',
                            '64 فقرة',
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'تم استيراد الملف وتقسيمه (Chunking) وفهرسته في قاعدة المعرفة ✓',
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.upload_file_rounded, size: 16),
                        label: const Text('استيراد PDF طبي', style: TextStyle(fontSize: 11.5)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0077B6),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...appController.knowledgeDocs.map(
                    (doc) => ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.picture_as_pdf_rounded, color: Colors.redAccent, size: 20),
                      title: Text(doc['title']!, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                      subtitle: Text('${doc['chunks']} • ${doc['status']}'),
                      trailing: Text(
                        doc['version']!,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),
          // زر تسجيل الخروج / إعادة تهيئة الجلسة (مطابق للصورة 4)
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE11D48).withOpacity(0.25)),
            ),
            child: ListTile(
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SplashScreen()),
              ),
              leading: const Icon(Icons.logout_rounded, color: Color(0xFFE11D48)),
              title: const Text(
                'تسجيل الخروج / إعادة تهيئة النظام',
                style: TextStyle(
                  color: Color(0xFFE11D48),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _switchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: SwitchListTile.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF0096C7),
        secondary: Icon(icon, color: const Color(0xFF0077B6), size: 22),
        title: Text(
          title,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String title,
    String trailing,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: const Color(0xFF0077B6), size: 22),
        title: Text(
          title,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              trailing,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF0077B6),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }
}

// ================= اللوحة الجانبية التعريفية والتنويه الطبي (InfoPanel - مطابقة للصورة 2 تماماً) =================
class InfoPanel extends StatelessWidget {
  const InfoPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF10243A) : const Color(0xFFF0F7FF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Icon(Icons.monitor_heart_rounded, color: Color(0xFF0096C7), size: 46),
              const SizedBox(height: 10),
              Text(
                'مساعدك الطبي الذكي',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: isDark ? Colors.white : const Color(0xFF0A192F),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'احصل على إجابات دقيقة وموثوقة لأسئلتك الطبية.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _feat(
          Icons.verified_user_outlined,
          'معلومات طبية موثوقة',
          'مبنية على مصادر طبية معتمدة',
          isDark,
        ),
        _feat(
          Icons.language_rounded,
          'دعم اللغة العربية',
          'تواصل بسهولة بلغتك الأم',
          isDark,
        ),
        _feat(
          Icons.wifi_off_rounded,
          'يعمل محلياً',
          'بدون الحاجة للإنترنت',
          isDark,
        ),
        _feat(
          Icons.shield_outlined,
          'خصوصيتك تهمنا',
          'لا يتم إرسال بياناتك لأي جهة خارجية',
          isDark,
        ),
        const SizedBox(height: 12),

        // صندوق "تنويه مهم" الأزرق المطابق للصورة 2 تماماً
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF0284C7).withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF0284C7).withOpacity(0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Color(0xFF0284C7), size: 18),
                  SizedBox(width: 6),
                  Text(
                    'تنويه مهم',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13.5,
                      color: Color(0xFF0284C7),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'المعلومات المقدمة في هذا التطبيق للتثقيف الطبي فقط، ولا تغني عن استشارة الطبيب المختص.\n\n'
                'في حالات الطوارئ، يرجى التوجه مباشرة إلى أقرب مركز طبي.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.5,
                  color: isDark ? Colors.white70 : const Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Center(
          child: AnimatedEcgWave(
            width: 180,
            height: 34,
            color: Color(0xFF0096C7),
          ),
        ),
        const SizedBox(height: 8),
        const Center(
          child: Text(
            'معاً نحو صحة أفضل',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Center(child: MediqLogo(size: 32, showText: true)),
      ],
    );
  }

  Widget _feat(IconData icon, String title, String sub, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFF0096C7).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF0096C7), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: isDark ? Colors.white : const Color(0xFF0A192F),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
