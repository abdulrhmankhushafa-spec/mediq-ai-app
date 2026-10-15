import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MediqAiApp());
}

// ============================================================================
// 1. مدير الحالة والعمليات الخلفية المبدئية (App Backend Controller)
// ============================================================================
class AppController extends ChangeNotifier {
  bool isDarkMode = false;
  String language = 'العربية';
  String fontSizeLabel = 'متوسط'; // صغير، متوسط، كبير
  bool saveChats = true;
  bool notificationsEnabled = true;
  bool isLocalServerConnected = true;
  String selectedModel = 'Llama 3.1 (8B)';
  String userName = 'مستخدم';
  String userHandle = 'mediq_user';
  String searchQuery = '';
  bool showFavoritesOnly = false;

  double get fontScale {
    switch (fontSizeLabel) {
      case 'صغير':
        return 0.88;
      case 'كبير':
        return 1.15;
      default:
        return 1.0;
    }
  }

  final List<Map<String, dynamic>> chats = [
    {
      'id': 'diabetes',
      'title': 'معلومات عن السكري',
      'subtitle': 'السكري هو اضطراب في استقلاب الجلوكوز...',
      'time': 'اليوم 09:24',
      'icon': Icons.water_drop_outlined,
      'isFavorite': true,
      'question': 'ما هي أعراض مرض السكري؟',
      'answerIntro':
          'مرض السكري هو اضطراب في استقلاب الجلوكوز في الجسم، ويؤدي إلى ارتفاع مستوى السكر في الدم. من أبرز أعراضه:',
      'bullets': [
        'زيادة العطش وجفاف الفم.',
        'كثرة التبول خاصة في الليل.',
        'الجوع المستمر رغم تناول الطعام.',
        'فقدان الوزن غير المبرر.',
        'التعب والإرهاق العام.',
        'تشوش الرؤية وبطء التئام الجروح.',
      ],
      'footer':
          'من المهم ملاحظة أن هذه الأعراض قد تختلف من شخص لآخر، ويجب استشارة الطبيب وإجراء فحص السكر التراكمي (HbA1c) للتشخيص الدقيق.',
    },
    {
      'id': 'gastritis',
      'title': 'أعراض التهاب المعدة',
      'subtitle': 'التهاب المعدة قد يسبب ألماً في الجزء العلوي...',
      'time': 'أمس 16:45',
      'icon': Icons.medical_information_outlined,
      'isFavorite': false,
      'question': 'ما هي أسباب التهاب المعدة؟',
      'answerIntro': 'التهاب المعدة يمكن أن يحدث نتيجة عدة أسباب، من أبرزها:',
      'bullets': [
        '1. العدوى البكتيرية (مثل جرثومة المعدة هيليكوباكتر بيلوري).',
        '2. الاستخدام المفرط للأدوية المسكنة والمضادة للالتهاب مثل الإيبوبروفين.',
        '3. التوتر العصبي والضغط النفسي الشديد.',
        '4. تناول الأطعمة الحارة أو الدهنية بكثرة.',
        '5. الإفراط في شرب الكافيين أو التدخين.',
        '6. بعض الحالات الطبية المناعية الأخرى.',
      ],
      'footer': 'للحصول على تشخيص دقيق، من الأفضل مراجعة الطبيب المختص.',
    },
    {
      'id': 'anemia',
      'title': 'أعراض فقر الدم (الأنيميا)',
      'subtitle': 'التعب والإرهاق المستمر وشحوب الجلد...',
      'time': 'أمس 10:25',
      'icon': Icons.bloodtype_outlined,
      'isFavorite': true,
      'question': 'ما هي أعراض فقر الدم؟',
      'answerIntro':
          'أعراض فقر الدم (الأنيميا) تختلف من شخص لآخر حسب السبب وشدة الحالة، ولكن بشكل عام تشمل الأعراض الأكثر شيوعاً ما يلي:',
      'bullets': [
        'التعب والإرهاق المستمر والضعف العام.',
        'شحوب الجلد، خاصة في الوجه والشفاه.',
        'الدوخة أو الشعور بالدوار والصداع المتكرر.',
        'تساقط الشعر وتقصف الأظافر وبرودة الأطراف.',
        'ضيق في التنفس وخفقان القلب عند بذل مجهود بسيط.',
      ],
      'footer':
          'مهم: هذه الأعراض قد تكون مشابهة لأمراض أخرى، ولا يمكن تشخيص فقر الدم بدون فحوصات طبية وتحاليل دم مثل صورة الدم الكاملة (CBC) ومستوى الفيريتين.',
    },
    {
      'id': 'vitamind',
      'title': 'فيتامين D وأهميته',
      'subtitle': 'فيتامين D مهم لصحة العظام والمناعة...',
      'time': 'أمس 12:30',
      'icon': Icons.wb_sunny_outlined,
      'isFavorite': false,
      'question': 'ما فائدة فيتامين D للجسم؟',
      'answerIntro':
          'فيتامين D يلعب دوراً حيوياً في الحفاظ على صحة الجسم، ومن أهم فوائده:',
      'bullets': [
        'تعزيز امتصاص الكالسيوم والفوسفور لبناء العظام والأسنان.',
        'دعم وتقوية الجهاز المناعي لمقاومة العدوى.',
        'تحسين الحالة المزاجية والوقاية من الخمول والاكتئاب.',
        'الحفاظ على صحة العضلات والأعصاب.',
      ],
      'footer':
          'يُنصح بالتعرض المعتدل لأشعة الشمس وفحص مستوى الفيتامين قبل تناول المكملات.',
    },
    {
      'id': 'general',
      'title': 'أسئلة عامة في الطب',
      'subtitle': 'يمكن أن تتضمن الأسئلة مجالات المناعة والوقاية...',
      'time': 'السبت 20:15',
      'icon': Icons.assignment_outlined,
      'isFavorite': false,
      'question': 'كيف يعمل الجهاز المناعي؟',
      'answerIntro':
          'الجهاز المناعي هو شبكة معقدة من الخلايا والأنسجة والأعضاء التي تعمل معاً للدفاع عن الجسم:',
      'bullets': [
        'خط الدفاع الأول: الجلد والأغشية المخاطية لمنع دخول الميكروبات.',
        'المناعة الفطرية: استجابة سريعة فورية ضد أي جسم غريب.',
        'المناعة المكتسبة: تنتج أجساماً مضادة مخصصة للقضاء على الفيروسات والبكتيريا.',
      ],
      'footer':
          'النوم الجيد والتغذية المتوازنة يساعدان في الحفاظ على كفاءة جهازك المناعي.',
    },
  ];

  List<Map<String, dynamic>> get filteredChats {
    return chats.where((chat) {
      final matchesSearch = searchQuery.isEmpty ||
          chat['title'].toString().contains(searchQuery) ||
          chat['subtitle'].toString().contains(searchQuery) ||
          chat['question'].toString().contains(searchQuery);
      final matchesFav = !showFavoritesOnly || (chat['isFavorite'] == true);
      return matchesSearch && matchesFav;
    }).toList();
  }

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  void cycleFontSize() {
    if (fontSizeLabel == 'صغير') {
      fontSizeLabel = 'متوسط';
    } else if (fontSizeLabel == 'متوسط') {
      fontSizeLabel = 'كبير';
    } else {
      fontSizeLabel = 'صغير';
    }
    notifyListeners();
  }

  void cycleModel() {
    const models = ['Llama 3.1 (8B)', 'Meditron (7B)', 'BioMistral (7B)'];
    final nextIndex = (models.indexOf(selectedModel) + 1) % models.length;
    selectedModel = models[nextIndex];
    notifyListeners();
  }

  void toggleServerStatus() {
    isLocalServerConnected = !isLocalServerConnected;
    notifyListeners();
  }

  void toggleSaveChats() {
    saveChats = !saveChats;
    notifyListeners();
  }

  void toggleNotifications() {
    notificationsEnabled = !notificationsEnabled;
    notifyListeners();
  }

  void toggleFavorite(String id) {
    final index = chats.indexWhere((c) => c['id'] == id);
    if (index != -1) {
      chats[index]['isFavorite'] = !(chats[index]['isFavorite'] ?? false);
      notifyListeners();
    }
  }

  void deleteChat(String id) {
    chats.removeWhere((c) => c['id'] == id);
    notifyListeners();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void setShowFavoritesOnly(bool val) {
    showFavoritesOnly = val;
    notifyListeners();
  }

  void updateUserProfile(String name, String handle) {
    if (name.trim().isNotEmpty) userName = name.trim();
    if (handle.trim().isNotEmpty) userHandle = handle.trim();
    notifyListeners();
  }

  // توليد رد طبي ذكي وحفظ المحادثة
  Map<String, dynamic> generateMedicalReply(String question) {
    String intro =
        'بناءً على قاعدة البيانات الطبية المحلية (${selectedModel})، إليك المعلومات المتعلقة بسؤالك حول "$question":';
    List<String> bullets = [
      'تقييم الأعراض الأولية ومراقبة توقيت ظهورها وشدتها.',
      'الحفاظ على شرب كميات كافية من الماء والراحة الجسدية.',
      'تجنب تناول أي أدوية أو مضادات حيوية دون وصفة طبية.',
      'مراجعة التاريخ الصحي وإجراء الفحوصات المخبرية اللازمة عند الحاجة.',
    ];
    String footer =
        'تنويه: هذه المعلومات إرشادية للتثقيف الطبي فقط ولا تغني عن الفحص السريري لدى الطبيب المختص.';

    if (question.contains('ضغط')) {
      intro =
          'ارتفاع ضغط الدم غالباً ما يكون بدون أعراض واضحة (القاتل الصامت)، ولكن عند ارتفاعه بشدة قد يظهر الآتي:';
      bullets = [
        'صداع شديد خاصة في مؤخرة الرأس صباحاً.',
        'دوخة وتشوش في الرؤية أو طنين في الأذن.',
        'ألم في الصدر أو ضيق في التنفس.',
        'ينصح بتقليل الملح وممارسة المشي وقياس الضغط بانتظام.',
      ];
    } else if (question.contains('صداع')) {
      intro = 'الصداع له أنواع متعددة منها التوتري والشقيقة (النصفي)، ومن أهم أسبابه وطرق التعامل معه:';
      bullets = [
        'الجفاف وقلة شرب الماء أو قلة النوم.',
        'إجهاد العين بسبب الشاشات أو التوتر النفسي.',
        'الراحة في غرفة هادئة ومظلمة وتناول السوائل الدافئة.',
      ];
    }

    final newChat = {
      'id': 'chat_${DateTime.now().millisecondsSinceEpoch}',
      'title': question.length > 25 ? '${question.substring(0, 25)}...' : question,
      'subtitle': intro,
      'time': 'الآن',
      'icon': Icons.health_and_safety_outlined,
      'isFavorite': false,
      'question': question,
      'answerIntro': intro,
      'bullets': bullets,
      'footer': footer,
    };

    if (saveChats) {
      chats.insert(0, newChat);
      notifyListeners();
    }
    return newChat;
  }
}

final AppController appController = AppController();

// ============================================================================
// 2. التطبيق الرئيسي ودعم الثيم (الفاتح / الداكن) وتحجيم الخط
// ============================================================================
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
            scaffoldBackgroundColor: const Color(0xFFF2F6FA),
            primaryColor: const Color(0xFF0078D4),
            cardColor: Colors.white,
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0078D4),
              secondary: Color(0xFF00C6FF),
              surface: Colors.white,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF071524),
            primaryColor: const Color(0xFF00B4DB),
            cardColor: const Color(0xFF0E2238),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00B4DB),
              secondary: Color(0xFF00E1FF),
              surface: Color(0xFF0E2238),
            ),
          ),
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.rtl,
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(appController.fontScale),
                ),
                child: child!,
              ),
            );
          },
          home: const SplashScreen(),
        );
      },
    );
  }
}

// ============================================================================
// 3. الرسومات الهندسية المخصصة (الشعار الطبي + النبض المتحرك + الخلفية)
// ============================================================================
class MediqLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool forceDarkText;

  const MediqLogo({
    super.key,
    this.size = 44,
    this.showText = true,
    this.forceDarkText = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = forceDarkText || Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: MediqShieldPainter(),
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
                    letterSpacing: 0.8,
                  ),
                  children: [
                    TextSpan(
                      text: 'MEDIQ ',
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF071A2C),
                      ),
                    ),
                    const TextSpan(
                      text: 'AI',
                      style: TextStyle(color: Color(0xFF00C6FF)),
                    ),
                  ],
                ),
              ),
              Text(
                'مساعدك الطبي الذكي',
                style: TextStyle(
                  fontSize: size * 0.25,
                  color: isDark ? Colors.white70 : const Color(0xFF5A7184),
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

// رسام الشعار الاحترافي (حاوية بأجنحة متدرجة + الدماغ الإلكتروني + الصليب الطبي)
class MediqShieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // توهج خلفي
    final shadowPaint = Paint()
      ..color = const Color(0xFF00C6FF).withOpacity(0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.08, h * 0.12, w * 0.84, h * 0.82),
        Radius.circular(w * 0.28),
      ),
      shadowPaint,
    );

    // الخلفية المتدرجة (شكل حرف M / الدرع الطبي)
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00E5FF), Color(0xFF0078D4), Color(0xFF004BA0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h));

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.04, h * 0.04, w * 0.92, h * 0.92),
      Radius.circular(w * 0.28),
    );
    canvas.drawRRect(rrect, bgPaint);

    // خطوط الدوائر الذكية (Circuit nodes)
    final nodePaint = Paint()
      ..color = Colors.white.withOpacity(0.45)
      ..strokeWidth = w * 0.03
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w / 2, h / 2), radius: w * 0.34),
      -math.pi * 0.8,
      math.pi * 1.3,
      false,
      nodePaint,
    );

    // الدائرة الداكنة الوسطى
    final innerCirclePaint = Paint()..color = const Color(0xFF061A2E);
    canvas.drawCircle(Offset(w / 2, h / 2), w * 0.27, innerCirclePaint);

    // علامة (+) الطبية البيضاء في المنتصف
    final crossPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final cw = w * 0.11;
    final cl = w * 0.30;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w / 2, h / 2), width: cl, height: cw),
        Radius.circular(cw * 0.3),
      ),
      crossPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w / 2, h / 2), width: cw, height: cl),
        Radius.circular(cw * 0.3),
      ),
      crossPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// موجة تخطيط القلب المتحركة (Animated ECG Wave)
class AnimatedEcgWave extends StatefulWidget {
  final double width;
  final double height;
  final Color color;

  const AnimatedEcgWave({
    super.key,
    this.width = 220,
    this.height = 45,
    this.color = const Color(0xFF00E1FF),
  });

  @override
  State<AnimatedEcgWave> createState() => _AnimatedEcgWaveState();
}

class _AnimatedEcgWaveState extends State<AnimatedEcgWave>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: EcgLinePainter(
              progress: _controller.value,
              color: widget.color,
            ),
          );
        },
      ),
    );
  }
}

class EcgLinePainter extends CustomPainter {
  final double progress;
  final Color color;

  EcgLinePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final basePaint = Paint()
      ..color = color.withOpacity(0.25)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = color
      ..strokeWidth = 2.6
      ..style = PaintingStyle.stroke;

    final path = Path();
    final midY = size.height / 2;
    path.moveTo(0, midY);
    path.lineTo(size.width * 0.30, midY);
    path.lineTo(size.width * 0.36, midY - 7);
    path.lineTo(size.width * 0.41, midY + 7);
    path.lineTo(size.width * 0.46, midY - 22);
    path.lineTo(size.width * 0.51, midY + 18);
    path.lineTo(size.width * 0.56, midY - 10);
    path.lineTo(size.width * 0.62, midY);
    path.lineTo(size.width, midY);

    canvas.drawPath(path, basePaint);

    final metrics = path.computeMetrics().first;
    final extractLength = metrics.length * 0.35;
    final start = (metrics.length * progress) - (extractLength / 2);
    final extracted = metrics.extractPath(
      math.max(0, start),
      math.min(metrics.length, start + extractLength),
    );
    canvas.drawPath(extracted, glowPaint);
  }

  @override
  bool shouldRepaint(covariant EcgLinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// خلفية الأشكال السداسية والسماعة الطبية التجميلية
class MedicalPatternPainter extends CustomPainter {
  final bool isDark;
  MedicalPatternPainter({this.isDark = true});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? const Color(0xFF00E1FF) : const Color(0xFF0078D4))
          .withOpacity(0.07)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // رسم دوائر وسماعة طبية رمزية في الأسفل
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.85),
      35,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.85),
      22,
      paint,
    );

    final arcPath = Path()
      ..moveTo(size.width * 0.75 - 35, size.height * 0.85)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.95,
        size.width * 0.2,
        size.height * 0.70,
      );
    canvas.drawPath(arcPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// 4. شاشة البداية (Splash Screen) مع الرسوم المتحركة
// ============================================================================
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
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainShell()),
          );
        },
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF030D19), Color(0xFF0A2742), Color(0xFF03101F)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: CustomPaint(
            painter: MedicalPatternPainter(isDark: true),
            child: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(flex: 2),
                  // الشعار الكبير المتوهج
                  const MediqLogo(size: 135, showText: false),
                  const SizedBox(height: 28),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                      children: [
                        TextSpan(
                          text: 'MEDIQ ',
                          style: TextStyle(color: Colors.white),
                        ),
                        TextSpan(
                          text: 'AI',
                          style: TextStyle(color: Color(0xFF00E1FF)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your Medical AI Assistant',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'اسأل ... افهم ... تعلّم',
                    style: TextStyle(
                      color: Color(0xFF00E1FF),
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const AnimatedEcgWave(width: 240, height: 48),
                  const Spacer(flex: 2),
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Color(0xFF00E1FF),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'جاري تهيئة المساعد الطبي الذكي...',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 5. الهيكل الرئيسي المتجاوب (الهاتف + الحاسوب)
// ============================================================================
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _bottomNavIndex = 0;
  String? _selectedChatId;

  void _openChat(Map<String, dynamic> chatData) {
    final isDesktop = MediaQuery.of(context).size.width >= 950;
    if (isDesktop) {
      setState(() {
        _selectedChatId = chatData['id'];
        _bottomNavIndex = 2;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailScreen(chatData: chatData),
        ),
      );
    }
  }

  void _startNewChat() {
    final newChatData = {
      'id': 'new',
      'title': 'محادثة جديدة',
      'question': '',
      'answerIntro': '',
      'bullets': <String>[],
      'footer': '',
    };
    final isDesktop = MediaQuery.of(context).size.width >= 950;
    if (isDesktop) {
      setState(() {
        _selectedChatId = 'new';
        _bottomNavIndex = 2;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatDetailScreen(chatData: newChatData),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 950;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDesktop) {
      final activeChat = appController.chats.firstWhere(
        (c) => c['id'] == (_selectedChatId ?? 'anemia'),
        orElse: () => {
          'id': 'new',
          'title': 'استفسار طبي',
          'question': '',
          'answerIntro': '',
          'bullets': <String>[],
          'footer': '',
        },
      );

      return Scaffold(
        body: Row(
          children: [
            SizedBox(
              width: 280,
              child: DarkSidebarDrawer(
                onSelectNewChat: _startNewChat,
                onSelectSettings: () => setState(() => _bottomNavIndex = 3),
                onSelectHome: () {
                  appController.setShowFavoritesOnly(false);
                  setState(() => _bottomNavIndex = 0);
                },
                onSelectFavorites: () {
                  appController.setShowFavoritesOnly(true);
                  setState(() => _bottomNavIndex = 0);
                },
              ),
            ),
            Expanded(
              flex: 3,
              child: _bottomNavIndex == 3
                  ? const SettingsScreen(isEmbedded: true)
                  : _bottomNavIndex == 0
                      ? MobileHomeScreen(
                          onOpenChat: _openChat,
                          onNewChat: _startNewChat,
                        )
                      : ChatDetailScreen(
                          chatData: activeChat,
                          isEmbedded: true,
                          onOpenSettings: () =>
                              setState(() => _bottomNavIndex = 3),
                        ),
            ),
            Container(
              width: 310,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0A1B2E) : const Color(0xFFF7FAFC),
                border: Border(
                  right: BorderSide(
                    color: isDark ? Colors.white10 : Colors.grey.shade200,
                  ),
                ),
              ),
              child: const DesktopInfoPanel(),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      drawer: Drawer(
        backgroundColor: const Color(0xFF061626),
        child: DarkSidebarDrawer(
          onSelectNewChat: () {
            Navigator.pop(context);
            _startNewChat();
          },
          onSelectSettings: () {
            Navigator.pop(context);
            setState(() => _bottomNavIndex = 3);
          },
          onSelectHome: () {
            Navigator.pop(context);
            appController.setShowFavoritesOnly(false);
            setState(() => _bottomNavIndex = 0);
          },
          onSelectFavorites: () {
            Navigator.pop(context);
            appController.setShowFavoritesOnly(true);
            setState(() => _bottomNavIndex = 0);
          },
        ),
      ),
      body: IndexedStack(
        index: _bottomNavIndex,
        children: [
          MobileHomeScreen(
            onOpenChat: _openChat,
            onNewChat: _startNewChat,
          ),
          const ChatDetailScreen(
            chatData: {
              'id': 'new',
              'title': 'استكشاف الأسئلة الطبية',
              'question': '',
              'answerIntro': '',
              'bullets': <String>[],
              'footer': '',
            },
            isEmbedded: true,
          ),
          ChatDetailScreen(
            chatData: appController.chats.isNotEmpty
                ? appController.chats.first
                : const {
                    'id': 'new',
                    'title': 'محادثة جديدة',
                    'question': '',
                    'answerIntro': '',
                    'bullets': <String>[],
                    'footer': '',
                  },
            isEmbedded: true,
          ),
          const SettingsScreen(isEmbedded: true),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (index) => setState(() => _bottomNavIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? const Color(0xFF0A1B2E) : Colors.white,
        selectedItemColor: const Color(0xFF0078D4),
        unselectedItemColor: const Color(0xFF7A8FA6),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline_rounded),
            label: 'استكشاف',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_rounded),
            label: 'المحادثات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 6. الشاشة الرئيسية التفاعلية (البحث الفوري + المفضلة + حالة الخادم)
// ============================================================================
class MobileHomeScreen extends StatelessWidget {
  final Function(Map<String, dynamic>) onOpenChat;
  final VoidCallback onNewChat;

  const MobileHomeScreen({
    super.key,
    required this.onOpenChat,
    required this.onNewChat,
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Scaffold.maybeOf(context)?.openDrawer(),
                  child: const CircleAvatar(
                    radius: 19,
                    backgroundColor: Color(0xFF0A2540),
                    child: Icon(Icons.person_rounded, color: Color(0xFF00E1FF)),
                  ),
                ),
                const MediqLogo(size: 38),
                IconButton(
                  onPressed: () => Scaffold.maybeOf(context)?.openDrawer(),
                  icon: Icon(
                    Icons.menu_open_rounded,
                    color: isDark ? Colors.white : const Color(0xFF0A2540),
                    size: 28,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // بطاقة حالة الاتصال المحلي (تتغير بالضغط عليها)
                InkWell(
                  onTap: () => appController.toggleServerStatus(),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF0E2942)
                          : const Color(0xFFE6F3FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF0078D4).withOpacity(0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 11,
                          height: 11,
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
                                    ? 'يعمل محلياً (${appController.selectedModel})'
                                    : 'الخادم المحلي متوقف مؤقتاً',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF0A2540),
                                ),
                              ),
                              Text(
                                appController.isLocalServerConnected
                                    ? 'المساعد المحلي متصل وجاهز للإجابة'
                                    : 'اضغط هنا لإعادة الاتصال بالخادم المحلي',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isDark
                                      ? Colors.white70
                                      : const Color(0xFF5A7184),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.dns_outlined,
                          color: isDark ? Colors.white70 : const Color(0xFF0A2540),
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // شريط البحث الفوري
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: appController.setSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'ابحث في المحادثات...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF9FB1C1),
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF5A7184),
                      ),
                      suffixIcon: appController.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () => appController.setSearchQuery(''),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // زر محادثة جديدة
                InkWell(
                  onTap: onNewChat,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0088CC), Color(0xFF005599)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0078D4).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Icon(Icons.add_rounded, color: Colors.white, size: 24),
                        Text(
                          'محادثة جديدة',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(width: 24),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ترويسة المحادثات الأخيرة مع فلتر المفضلة
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      appController.showFavoritesOnly
                          ? 'المحادثات المفضلة ⭐'
                          : 'المحادثات الأخيرة',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF0A2540),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => appController.setShowFavoritesOnly(
                        !appController.showFavoritesOnly,
                      ),
                      icon: Icon(
                        appController.showFavoritesOnly
                            ? Icons.list_rounded
                            : Icons.star_rounded,
                        size: 18,
                      ),
                      label: Text(
                        appController.showFavoritesOnly
                            ? 'عرض الكل'
                            : 'المفضلة فقط',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (chats.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text(
                        'لا توجد محادثات مطابقة للبحث',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),

                // قائمة المحادثات
                ...chats.map((chat) {
                  final isFav = chat['isFavorite'] == true;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      onTap: () => onOpenChat(chat),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      leading: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF163452)
                              : const Color(0xFFE6F4FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          chat['icon'] as IconData,
                          color: const Color(0xFF0078D4),
                          size: 25,
                        ),
                      ),
                      title: Text(
                        chat['title'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                          color: isDark ? Colors.white : const Color(0xFF0A2540),
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          chat['subtitle'],
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF7A8FA6),
                          ),
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            chat['time'],
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFF9FB1C1),
                            ),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () =>
                                appController.toggleFavorite(chat['id']),
                            child: Icon(
                              isFav
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: isFav ? Colors.amber : Colors.grey,
                              size: 20,
                            ),
                          ),
                        ],
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

// ============================================================================
// 7. القائمة الجانبية الداكنة (Dark Sidebar Drawer)
// ============================================================================
class DarkSidebarDrawer extends StatelessWidget {
  final VoidCallback onSelectNewChat;
  final VoidCallback onSelectSettings;
  final VoidCallback onSelectHome;
  final VoidCallback onSelectFavorites;

  const DarkSidebarDrawer({
    super.key,
    required this.onSelectNewChat,
    required this.onSelectSettings,
    required this.onSelectHome,
    required this.onSelectFavorites,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF061626),
      child: CustomPaint(
        painter: MedicalPatternPainter(isDark: true),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: MediqLogo(size: 40, forceDarkText: true),
                ),
                const SizedBox(height: 16),

                // بطاقة المستخدم
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFF0078D4),
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appController.userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              appController.userHandle,
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // زر محادثة جديدة
                InkWell(
                  onTap: onSelectNewChat,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0088FF), Color(0xFF005299)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.chat_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'محادثة جديدة',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Icon(Icons.add_rounded, color: Colors.white, size: 22),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                _buildMenuItem(
                  icon: Icons.history_rounded,
                  title: 'المحادثات السابقة',
                  onTap: onSelectHome,
                ),
                _buildMenuItem(
                  icon: Icons.search_rounded,
                  title: 'البحث في المحادثات',
                  onTap: onSelectHome,
                ),
                _buildMenuItem(
                  icon: Icons.star_border_rounded,
                  title: 'المفضلة',
                  onTap: onSelectFavorites,
                ),
                _buildMenuItem(
                  icon: Icons.menu_book_rounded,
                  title: 'المعلومات الطبية',
                  onTap: onSelectHome,
                ),
                _buildMenuItem(
                  icon: Icons.settings_outlined,
                  title: 'الإعدادات',
                  onTap: onSelectSettings,
                ),

                const Spacer(),

                // حالة الاتصال المحلي
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A243C),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF00C6FF).withOpacity(0.25),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: appController.isLocalServerConnected
                                  ? const Color(0xFF10B981)
                                  : Colors.orange,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            appController.isLocalServerConnected
                                ? 'يعمل محلياً'
                                : 'غير متصل',
                            style: TextStyle(
                              color: appController.isLocalServerConnected
                                  ? const Color(0xFF10B981)
                                  : Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.wifi_off_rounded,
                            color: Colors.white54,
                            size: 18,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'النموذج متصل بالشبكة المحلية (بدون إنترنت)',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // بطاقة النموذج
                InkWell(
                  onTap: () => appController.cycleModel(),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.memory_rounded,
                          color: Color(0xFF00C6FF),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'النموذج المستخدم (اضغط للتبديل)',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10.5,
                              ),
                            ),
                            Text(
                              appController.selectedModel,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'MEDIQ AI v1.0.0',
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                    Icon(Icons.verified_rounded, color: Colors.white38, size: 15),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Icon(icon, color: Colors.white70, size: 21),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}

// ============================================================================
// 8. شاشة المحادثة التفاعلية (نسخ، تقييم، إعادة توليد، رد ذكي)
// ============================================================================
class ChatDetailScreen extends StatefulWidget {
  final Map<String, dynamic> chatData;
  final bool isEmbedded;
  final VoidCallback? onOpenSettings;

  const ChatDetailScreen({
    super.key,
    required this.chatData,
    this.isEmbedded = false,
    this.onOpenSettings,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _sessionExchanges = [];
  bool _isGenerating = false;
  int _reactionState = 0; // 0: بدون، 1: إعجاب، -1: عدم إعجاب
  int _regenerationCount = 0;

  void _sendMessage([String? presetText]) async {
    final text = presetText ?? _controller.text.trim();
    if (text.isEmpty || _isGenerating) return;
    _controller.clear();

    setState(() {
      _isGenerating = true;
    });

    await Future.delayed(const Duration(milliseconds: 900));
    final generated = appController.generateMedicalReply(text);

    if (mounted) {
      setState(() {
        _isGenerating = false;
        _sessionExchanges.add(generated);
      });
    }
  }

  void _copyResponse(Map<String, dynamic> data) {
    final bullets = (data['bullets'] as List).join('\n• ');
    final fullText =
        '${data['answerIntro']}\n• $bullets\n\n${data['footer']}';
    Clipboard.setData(ClipboardData(text: fullText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ الإجابة الطبية إلى الحافظة بنجاح ✓'),
        duration: Duration(seconds: 2),
        backgroundColor: Color(0xFF0078D4),
      ),
    );
  }

  void _regenerateResponse() async {
    setState(() => _isGenerating = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() {
        _isGenerating = false;
        _regenerationCount++;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم إعادة توليد الإجابة بواسطة ${appController.selectedModel}',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isNewChat =
        widget.chatData['id'] == 'new' && _sessionExchanges.isEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0.5,
        automaticallyImplyLeading: !widget.isEmbedded,
        title: Row(
          children: [
            const MediqLogo(size: 34, showText: false),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chatData['title'] ?? 'محادثة طبية',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0A2540),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: appController.isLocalServerConnected
                              ? const Color(0xFF10B981)
                              : Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        appController.isLocalServerConnected
                            ? 'متصل محلياً • ${appController.selectedModel}'
                            : 'غير متصل بالخادم المحلي',
                        style: TextStyle(
                          fontSize: 11,
                          color: appController.isLocalServerConnected
                              ? const Color(0xFF10B981)
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (widget.chatData['id'] != 'new')
            IconButton(
              onPressed: () =>
                  appController.toggleFavorite(widget.chatData['id']),
              icon: Icon(
                widget.chatData['isFavorite'] == true
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: widget.chatData['isFavorite'] == true
                    ? Colors.amber
                    : null,
              ),
            ),
          if (widget.onOpenSettings != null)
            IconButton(
              onPressed: widget.onOpenSettings,
              icon: const Icon(Icons.settings_outlined),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: isNewChat
                ? _buildWelcomePromptView(isDark)
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if ((widget.chatData['question'] as String)
                          .isNotEmpty) ...[
                        _buildUserBubble(widget.chatData['question']),
                        const SizedBox(height: 16),
                        _buildAiStructuredResponse(widget.chatData, isDark),
                      ],
                      ..._sessionExchanges.map((exchange) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Column(
                            children: [
                              _buildUserBubble(exchange['question']),
                              const SizedBox(height: 16),
                              _buildAiStructuredResponse(exchange, isDark),
                            ],
                          ),
                        );
                      }),
                      if (_isGenerating)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'جاري تحليل السؤال الطبي بواسطة ${appController.selectedModel}...',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF0078D4),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
          _buildBottomInputBar(isDark),
        ],
      ),
    );
  }

  Widget _buildWelcomePromptView(bool isDark) {
    final suggestions = [
      {'title': 'ما هي أعراض\nارتفاع ضغط الدم؟', 'icon': Icons.favorite_border},
      {'title': 'كيف يعمل\nالجهاز المناعي؟', 'icon': Icons.shield_outlined},
      {'title': 'ما فائدة فيتامين\nD للجسم؟', 'icon': Icons.wb_sunny_outlined},
      {'title': 'ما أسباب الصداع\nالمستمر؟', 'icon': Icons.psychology_outlined},
    ];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const MediqLogo(size: 72, showText: false),
            const SizedBox(height: 14),
            Text(
              'MEDIQ AI',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0A2540),
              ),
            ),
            const Text(
              'مساعدك الطبي الذكي',
              style: TextStyle(fontSize: 14, color: Color(0xFF5A7184)),
            ),
            const SizedBox(height: 24),
            Text(
              'كيف يمكنني مساعدتك اليوم؟',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0A2540),
              ),
            ),
            const SizedBox(height: 28),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: suggestions.map((item) {
                return InkWell(
                  onTap: () => _sendMessage(
                    (item['title'] as String).replaceAll('\n', ' '),
                  ),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 160,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark
                            ? Colors.white12
                            : const Color(0xFFE1ECF4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          color: const Color(0xFF0078D4),
                          size: 22,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item['title'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0A2540),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserBubble(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 330),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Color(0xFFD0EBFF),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: const TextStyle(
                color: Color(0xFF0A2540),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.done_all_rounded, size: 14, color: Color(0xFF0078D4)),
                SizedBox(width: 4),
                Text(
                  '10:24 م',
                  style: TextStyle(fontSize: 10, color: Color(0xFF5A7184)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiStructuredResponse(Map<String, dynamic> data, bool isDark) {
    final bullets = (data['bullets'] as List).cast<String>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'MEDIQ AI',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isDark ? Colors.white : const Color(0xFF0A2540),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _regenerationCount > 0
                          ? 'تم التحديث (#$_regenerationCount)'
                          : '10:25 م',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  data['answerIntro'],
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),
                ...bullets.map(
                  (point) => Padding(
                    padding: const EdgeInsets.only(bottom: 8, right: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(
                            color: Color(0xFF0078D4),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            point,
                            style: TextStyle(
                              fontSize: 13.5,
                              height: 1.5,
                              color: isDark
                                  ? Colors.white70
                                  : const Color(0xFF334155),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF122C46)
                        : const Color(0xFFF0F7FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF0078D4).withOpacity(0.25),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_rounded,
                        color: Color(0xFF0078D4),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          data['footer'],
                          style: TextStyle(
                            fontSize: 12.5,
                            height: 1.5,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0A2540),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildActionButton(
                      icon: _reactionState == 1
                          ? Icons.thumb_up_alt_rounded
                          : Icons.thumb_up_alt_outlined,
                      label: '',
                      isActive: _reactionState == 1,
                      onTap: () => setState(
                        () => _reactionState = _reactionState == 1 ? 0 : 1,
                      ),
                    ),
                    _buildActionButton(
                      icon: _reactionState == -1
                          ? Icons.thumb_down_alt_rounded
                          : Icons.thumb_down_alt_outlined,
                      label: '',
                      isActive: _reactionState == -1,
                      onTap: () => setState(
                        () => _reactionState = _reactionState == -1 ? 0 : -1,
                      ),
                    ),
                    _buildActionButton(
                      icon: Icons.copy_rounded,
                      label: 'نسخ الإجابة',
                      onTap: () => _copyResponse(data),
                    ),
                    _buildActionButton(
                      icon: Icons.refresh_rounded,
                      label: 'إعادة التوليد',
                      onTap: _regenerateResponse,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        const MediqLogo(size: 34, showText: false),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF0078D4).withOpacity(0.15)
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? const Color(0xFF0078D4) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isActive
                  ? const Color(0xFF0078D4)
                  : const Color(0xFF5A7184),
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBottomInputBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            InkWell(
              onTap: () => _sendMessage(),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0088FF), Color(0xFF0055CC)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF071524)
                      : const Color(0xFFF3F7FB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white12 : const Color(0xFFE1ECF4),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: const InputDecoration(
                          hintText: 'اكتب سؤالك الطبي هنا...',
                          hintStyle: TextStyle(
                            color: Color(0xFF9FB1C1),
                            fontSize: 13.5,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('ميزة الإدخال الصوتي جاهزة للربط قريباً'),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.mic_none_rounded,
                        color: Color(0xFF5A7184),
                        size: 20,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.image_outlined,
                        color: Color(0xFF5A7184),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 9. شاشة الإعدادات التفاعلية الكاملة (Settings Screen)
// ============================================================================
class SettingsScreen extends StatelessWidget {
  final bool isEmbedded;

  const SettingsScreen({super.key, this.isEmbedded = false});

  void _showEditProfileDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: appController.userName);
    final handleCtrl = TextEditingController(text: appController.userHandle);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تعديل بيانات المستخدم'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'الاسم'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: handleCtrl,
              decoration: const InputDecoration(labelText: 'اسم المستخدم'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              appController.updateUserProfile(nameCtrl.text, handleCtrl.text);
              Navigator.pop(ctx);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: !isEmbedded,
        title: Text(
          'الإعدادات',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF0A2540),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // بطاقة المستخدم (قابلة للتعديل)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              onTap: () => _showEditProfileDialog(context),
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFF0078D4),
                child: Icon(Icons.person, color: Colors.white, size: 28),
              ),
              title: Text(
                appController.userName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                appController.userHandle,
                style: const TextStyle(color: Color(0xFF7A8FA6), fontSize: 13),
              ),
              trailing: const Icon(
                Icons.edit_outlined,
                size: 18,
                color: Color(0xFF0078D4),
              ),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'إعدادات التطبيق (اضغط للتغيير)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 10),

          _buildSettingsTile(
            context: context,
            icon: isDark ? Icons.dark_mode_outlined : Icons.wb_sunny_outlined,
            title: 'المظهر',
            trailingText: isDark ? 'الوضع الداكن' : 'الوضع الفاتح',
            onTap: appController.toggleTheme,
          ),
          _buildSettingsTile(
            context: context,
            icon: Icons.language_rounded,
            title: 'اللغة',
            trailingText: appController.language,
            onTap: () {},
          ),
          _buildSettingsTile(
            context: context,
            icon: Icons.text_fields_rounded,
            title: 'حجم الخط',
            trailingText: appController.fontSizeLabel,
            onTap: appController.cycleFontSize,
          ),
          _buildSettingsTile(
            context: context,
            icon: Icons.save_outlined,
            title: 'حفظ المحادثات',
            trailingText: appController.saveChats ? 'تفعيل' : 'إيقاف',
            isConnectedStatus: appController.saveChats,
            onTap: appController.toggleSaveChats,
          ),
          _buildSettingsTile(
            context: context,
            icon: Icons.notifications_none_rounded,
            title: 'الإشعارات',
            trailingText: appController.notificationsEnabled ? 'تفعيل' : 'إيقاف',
            isConnectedStatus: appController.notificationsEnabled,
            onTap: appController.toggleNotifications,
          ),

          const SizedBox(height: 20),

          const Text(
            'معلومات النموذج المحلي',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 10),
          _buildSettingsTile(
            context: context,
            icon: Icons.memory_rounded,
            title: 'اسم النموذج',
            trailingText: appController.selectedModel,
            highlightTrailing: true,
            onTap: appController.cycleModel,
          ),
          _buildSettingsTile(
            context: context,
            icon: Icons.dns_outlined,
            title: 'حالة الخادم المحلي',
            trailingText:
                appController.isLocalServerConnected ? 'متصل ●' : 'غير متصل ○',
            isConnectedStatus: appController.isLocalServerConnected,
            onTap: appController.toggleServerStatus,
          ),

          const SizedBox(height: 24),

          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SplashScreen()),
                );
              },
              leading: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFE11D48),
              ),
              title: const Text(
                'إعادة تشغيل / تسجيل الخروج',
                style: TextStyle(
                  color: Color(0xFFE11D48),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String trailingText,
    required VoidCallback onTap,
    bool highlightTrailing = false,
    bool isConnectedStatus = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: const Color(0xFF0078D4), size: 22),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              trailingText,
              style: TextStyle(
                fontSize: 13,
                fontWeight: highlightTrailing || isConnectedStatus
                    ? FontWeight.bold
                    : null,
                color: isConnectedStatus
                    ? const Color(0xFF10B981)
                    : highlightTrailing
                        ? const Color(0xFF0078D4)
                        : const Color(0xFF7A8FA6),
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.Sync_alt_rounded,
              size: 15,
              color: Color(0xFF9FB1C1),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 10. اللوحة التعريفية الجانبية (Desktop Info Panel)
// ============================================================================
class DesktopInfoPanel extends StatelessWidget {
  const DesktopInfoPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomPaint(
      painter: MedicalPatternPainter(isDark: isDark),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF122C46)
                  : const Color(0xFFEBF5FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.monitor_heart_rounded,
                  color: Color(0xFF00B4DB),
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'مساعدك الطبي الذكي',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : const Color(0xFF0A2540),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'احصل على إجابات دقيقة وموثوقة لأسئلتك الطبية.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF5A7184)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          _buildFeatureItem(
            icon: Icons.verified_user_outlined,
            title: 'معلومات طبية موثوقة',
            subtitle: 'مبنية على مصادر طبية معتمدة',
            isDark: isDark,
          ),
          _buildFeatureItem(
            icon: Icons.language_rounded,
            title: 'دعم اللغة العربية',
            subtitle: 'تواصل بسهولة بلغتك الأم',
            isDark: isDark,
          ),
          _buildFeatureItem(
            icon: Icons.wifi_tethering_off_rounded,
            title: 'يعمل محلياً',
            subtitle: 'بدون الحاجة للإنترنت',
            isDark: isDark,
          ),
          _buildFeatureItem(
            icon: Icons.lock_outline_rounded,
            title: 'خصوصيتك تهمنا',
            subtitle: 'لا يتم إرسال بياناتك لأي جهة خارجية',
            isDark: isDark,
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF122C46)
                  : const Color(0xFFE6F3FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF0078D4).withOpacity(0.25),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.info_outline, color: Color(0xFF0078D4), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'تنويه مهم',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0078D4),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'المعلومات المقدمة في هذا التطبيق للتثقيف الطبي فقط، ولا تغني عن استشارة الطبيب المختص.\n\nفي حالات الطوارئ، يرجى التوجه مباشرة إلى أقرب مركز طبي.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.6,
                    color: isDark ? Colors.white70 : const Color(0xFF0A2540),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: AnimatedEcgWave(
              width: 180,
              height: 32,
              color: Color(0xFF0078D4),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'معاً نحو صحة أفضل',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0A2540),
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Center(child: MediqLogo(size: 36, showText: true)),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF122C46)
                  : const Color(0xFFE6F4FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF0078D4), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? Colors.white : const Color(0xFF0A2540),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF7A8FA6),
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

