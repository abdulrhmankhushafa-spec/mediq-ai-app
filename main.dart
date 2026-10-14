import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(const MediqAiApp());
}

class MediqAiApp extends StatelessWidget {
  const MediqAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MEDIQ AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF3F7FB),
        primaryColor: const Color(0xFF0078D4),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0078D4),
          primary: const Color(0xFF0078D4),
          secondary: const Color(0xFF00C6FF),
          surface: Colors.white,
        ),
      ),
      // إجبار التطبيق بالكامل على الاتجاه من اليمين إلى اليسار (RTL)
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }
}

// ============================================================================
// 1. شعار التطبيق المبرمج (ليعمل بدون الحاجة لملفات صور خارجية)
// ============================================================================
class MediqLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool isDark;

  const MediqLogo({
    super.key,
    this.size = 42,
    this.showText = true,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.28),
            gradient: const LinearGradient(
              colors: [Color(0xFF00D2FF), Color(0xFF0066CC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00C6FF).withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.psychology_alt_rounded,
                color: Colors.white.withOpacity(0.25),
                size: size * 0.8,
              ),
              Container(
                padding: EdgeInsets.all(size * 0.14),
                decoration: const BoxDecoration(
                  color: Color(0xFF071A2C),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: size * 0.4,
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
                      style: TextStyle(color: Color(0xFF00B4DB)),
                    ),
                  ],
                ),
              ),
              Text(
                'مساعدك الطبي الذكي',
                style: TextStyle(
                  fontSize: size * 0.26,
                  color: isDark ? Colors.white70 : const Color(0xFF5A7184),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ============================================================================
// 2. شاشة البداية (Splash Screen)
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
              colors: [Color(0xFF04101E), Color(0xFF0A2742), Color(0xFF041222)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                // الشعار الدائري المتوهج
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00E1FF), Color(0xFF0052D4)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00D2FF).withOpacity(0.4),
                        blurRadius: 35,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        color: Color(0xFF071E36),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 65,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
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
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'اسأل ... افهم ... تعلّم',
                  style: TextStyle(
                    color: Color(0xFF00E1FF),
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 30),
                // خط نبض القلب التجميلي
                SizedBox(
                  width: 220,
                  height: 45,
                  child: CustomPaint(
                    painter: EcgLinePainter(),
                  ),
                ),
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
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EcgLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00E1FF)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final midY = size.height / 2;
    path.moveTo(0, midY);
    path.lineTo(size.width * 0.35, midY);
    path.lineTo(size.width * 0.40, midY - 8);
    path.lineTo(size.width * 0.44, midY + 8);
    path.lineTo(size.width * 0.48, midY - 22);
    path.lineTo(size.width * 0.52, midY + 18);
    path.lineTo(size.width * 0.56, midY - 10);
    path.lineTo(size.width * 0.60, midY);
    path.lineTo(size.width, midY);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============================================================================
// 3. الهيكل الرئيسي المتجاوب (الهاتف + الكمبيوتر)
// ============================================================================
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _bottomNavIndex = 0;
  String? _selectedChatTopic; // إذا كانت null نعرض الشاشة الرئيسية أو شاشة محادثة جديدة

  // بيانات المحادثات الجاهزة المطابقة للصور
  final List<Map<String, dynamic>> _chatsList = [
    {
      'id': 'diabetes',
      'title': 'معلومات عن السكري',
      'subtitle': 'السكري هو اضطراب في استقلاب...',
      'time': 'اليوم 09:24',
      'icon': Icons.water_drop_outlined,
      'question': 'ما هي أعراض مرض السكري؟',
      'answerIntro':
          'مرض السكري هو اضطراب في استقلاب الجلوكوز في الجسم، ويؤدي إلى ارتفاع مستوى السكر في الدم. من أبرز أعراضه:',
      'bullets': [
        'زيادة العطش.',
        'كثرة التبول.',
        'الجوع المستمر.',
        'فقدان الوزن غير المبرر.',
        'التعب والإرهاق.',
        'تشوش الرؤية.',
      ],
      'footer':
          'من المهم ملاحظة أن هذه الأعراض قد تختلف من شخص لآخر، ويجب استشارة الطبيب للتشخيص الدقيق.',
    },
    {
      'id': 'gastritis',
      'title': 'أعراض التهاب المعدة',
      'subtitle': 'التهاب المعدة قد يسبب ألماً في...',
      'time': 'أمس 16:45',
      'icon': Icons.medical_information_outlined,
      'question': 'ما هي أسباب التهاب المعدة؟',
      'answerIntro': 'التهاب المعدة يمكن أن يحدث نتيجة عدة أسباب، من أبرزها:',
      'bullets': [
        '1. العدوى البكتيرية (مثل هيليكوباكتر بيلوري).',
        '2. الاستخدام المفرط للأدوية المضادة للالتهاب مثل الإيبوبروفين.',
        '3. التوتر والضغط النفسي.',
        '4. تناول الأطعمة الحارة أو الدهنية.',
        '5. الإفراط في شرب الكافيين أو الكحول.',
        '6. بعض الحالات الطبية الأخرى.',
      ],
      'footer': 'للحصول على تشخيص دقيق، من الأفضل مراجعة الطبيب المختص.',
    },
    {
      'id': 'anemia',
      'title': 'أعراض فقر الدم (الأنيميا)',
      'subtitle': 'التعب والإرهاق المستمر وشحوب الجلد...',
      'time': 'أمس 10:25',
      'icon': Icons.bloodtype_outlined,
      'question': 'ما هي أعراض فقر الدم؟',
      'answerIntro':
          'أعراض فقر الدم (الأنيميا) تختلف من شخص لآخر حسب السبب وشدة الحالة، ولكن بشكل عام تشمل الأعراض الأكثر شيوعاً ما يلي:',
      'bullets': [
        'التعب والإرهاق المستمر.',
        'الضعف العام وقلة النشاط.',
        'شحوب الجلد، خاصة في الوجه والشفاه.',
        'الدوخة أو الشعور بالدوار.',
        'الصداع المتكرر.',
        'تساقط الشعر وتقصف الأظافر (في نقص الحديد).',
      ],
      'footer':
          'مهم: هذه الأعراض قد تكون مشابهة لأمراض أخرى، ولا يمكن تشخيص فقر الدم بدون فحوصات طبية وتحاليل دم مثل صورة الدم الكاملة (CBC).',
    },
    {
      'id': 'vitamind',
      'title': 'فيتامين D وأهميته',
      'subtitle': 'فيتامين D مهم لصحة العظام...',
      'time': 'أمس 12:30',
      'icon': Icons.wb_sunny_outlined,
      'question': 'ما فائدة فيتامين D للجسم؟',
      'answerIntro':
          'فيتامين D يلعب دوراً حيوياً في الحفاظ على صحة الجسم، ومن أهم فوائده:',
      'bullets': [
        'تعزيز امتصاص الكالسيوم والفوسفور لبناء العظام.',
        'دعم وتقوية الجهاز المناعي لمقاومة العدوى.',
        'تحسين الحالة المزاجية والوقاية من الاكتئاب.',
        'الحفاظ على صحة العضلات والأعصاب.',
      ],
      'footer':
          'يُنصح بالتعرض المعتدل لأشعة الشمس وفحص مستوى الفيتامين قبل تناول المكملات.',
    },
    {
      'id': 'general',
      'title': 'أسئلة عامة في الطب',
      'subtitle': 'يمكن أن تتضمن الأسئلة مجالات...',
      'time': 'السبت 20:15',
      'icon': Icons.assignment_outlined,
      'question': 'كيف يعمل الجهاز المناعي؟',
      'answerIntro':
          'الجهاز المناعي هو شبكة معقدة من الخلايا والأنسجة والأعضاء التي تعمل معاً للدفاع عن الجسم ضد الميكروبات:',
      'bullets': [
        'خط الدفاع الأول: الجلد والأغشية المخاطية.',
        'المناعة الفطرية: استجابة سريعة وغير مخصصة ضد أي جسم غريب.',
        'المناعة المكتسبة: تنتج أجساماً مضادة مخصصة للقضاء على الفيروسات والبكتيريا.',
      ],
      'footer':
          'النوم الجيد والتغذية المتوازنة يساعدان في الحفاظ على كفاءة جهازك المناعي.',
    },
  ];

  void _openChat(Map<String, dynamic> chatData) {
    final isDesktop = MediaQuery.of(context).size.width >= 950;
    if (isDesktop) {
      setState(() {
        _selectedChatTopic = chatData['id'];
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
        _selectedChatTopic = 'new';
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

    // تصميم الشاشات الكبيرة (كمبيوتر / تابلت - 3 أعمدة كما في الصورة الثانية والثالثة)
    if (isDesktop) {
      final activeChat = _chatsList.firstWhere(
        (c) => c['id'] == (_selectedChatTopic ?? 'anemia'),
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
            // القائمة الجانبية الداكنة
            SizedBox(
              width: 280,
              child: DarkSidebarDrawer(
                onSelectNewChat: _startNewChat,
                onSelectSettings: () {
                  setState(() => _bottomNavIndex = 3);
                },
                onSelectHome: () {
                  setState(() {
                    _bottomNavIndex = 0;
                    _selectedChatTopic = null;
                  });
                },
              ),
            ),
            // القسم الأوسط (المحادثة أو الإعدادات أو شاشة الترحيب)
            Expanded(
              flex: 3,
              child: _bottomNavIndex == 3
                  ? const SettingsScreen(isEmbedded: true)
                  : ChatDetailScreen(
                      chatData: activeChat,
                      isEmbedded: true,
                      onOpenSettings: () => setState(() => _bottomNavIndex = 3),
                    ),
            ),
            // اللوحة الجانبية اليسرى (معلومات المميزات والتنويه الطبي)
            Container(
              width: 310,
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAFC),
                border: Border(
                  right: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: const DesktopInfoPanel(),
            ),
          ],
        ),
      );
    }

    // تصميم شاشات الهاتف المحمول (Mobile UI)
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
            setState(() => _bottomNavIndex = 0);
          },
        ),
      ),
      body: IndexedStack(
        index: _bottomNavIndex,
        children: [
          // 0: الرئيسية (قائمة المحادثات والبحث)
          MobileHomeScreen(
            chats: _chatsList,
            onOpenChat: _openChat,
            onNewChat: _startNewChat,
          ),
          // 1: استكشاف (شاشة الترحيب والأسئلة المقترحة)
          ChatDetailScreen(
            chatData: const {
              'id': 'new',
              'title': 'استكشاف الأسئلة الطبية',
              'question': '',
              'answerIntro': '',
              'bullets': <String>[],
              'footer': '',
            },
            isEmbedded: true,
          ),
          // 2: المحادثات (تعرض محادثة السكري كنموذج مباشر)
          ChatDetailScreen(
            chatData: _chatsList.first,
            isEmbedded: true,
          ),
          // 3: الإعدادات
          const SettingsScreen(isEmbedded: true),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _bottomNavIndex,
          onTap: (index) => setState(() => _bottomNavIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF0066CC),
          unselectedItemColor: const Color(0xFF7A8FA6),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
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
      ),
    );
  }
}

// ============================================================================
// 4. الشاشة الرئيسية للهاتف (المحادثات الأخيرة + البحث)
// ============================================================================
class MobileHomeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> chats;
  final Function(Map<String, dynamic>) onOpenChat;
  final VoidCallback onNewChat;

  const MobileHomeScreen({
    super.key,
    required this.chats,
    required this.onOpenChat,
    required this.onNewChat,
  });

  @override
  Widget build(BuildContext context) {
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
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: const CircleAvatar(
                    radius: 19,
                    backgroundColor: Color(0xFF0A2540),
                    child: Icon(Icons.person_rounded, color: Colors.white),
                  ),
                ),
                const MediqLogo(size: 38),
                IconButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                  icon: const Icon(
                    Icons.menu_open_rounded,
                    color: Color(0xFF0A2540),
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
                // بطاقة "يعمل محلياً"
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6F3FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF0078D4).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.dns_outlined,
                        color: Color(0xFF0A2540),
                        size: 22,
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: const [
                          Text(
                            'يعمل محلياً',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF0A2540),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'المساعد المحلي متصل',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF5A7184),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // شريط البحث
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'ابحث في المحادثات...',
                      hintStyle: TextStyle(
                        color: Color(0xFF9FB1C1),
                        fontSize: 14,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Color(0xFF5A7184),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
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
                const SizedBox(height: 22),

                // عنوان المحادثات الأخيرة
                const Text(
                  'المحادثات الأخيرة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0A2540),
                  ),
                ),
                const SizedBox(height: 12),

                // قائمة المحادثات
                ...chats.map((chat) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
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
                        vertical: 8,
                      ),
                      leading: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F4FA),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          chat['icon'] as IconData,
                          color: const Color(0xFF0078D4),
                          size: 26,
                        ),
                      ),
                      title: Text(
                        chat['title'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Color(0xFF0A2540),
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
                      trailing: Text(
                        chat['time'],
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF9FB1C1),
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

// ============================================================================
// 5. القائمة الجانبية الداكنة (Dark Sidebar / Drawer)
// ============================================================================
class DarkSidebarDrawer extends StatelessWidget {
  final VoidCallback onSelectNewChat;
  final VoidCallback onSelectSettings;
  final VoidCallback onSelectHome;

  const DarkSidebarDrawer({
    super.key,
    required this.onSelectNewChat,
    required this.onSelectSettings,
    required this.onSelectHome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF061626),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الشعار
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: MediqLogo(size: 40, isDark: true),
            ),
            const SizedBox(height: 16),

            // معلومات المستخدم
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'مستخدم',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'mediq_user',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // زر محادثة جديدة المضيء
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
                    colors: [Color(0xFF0078D4), Color(0xFF005299)],
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
            const SizedBox(height: 16),

            // عناصر القائمة
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
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.menu_book_rounded,
              title: 'المعلومات الطبية',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.settings_outlined,
              title: 'الإعدادات',
              onTap: onSelectSettings,
            ),

            const Spacer(),

            // بطاقة يعمل محلياً السفلية
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
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'يعمل محلياً',
                        style: TextStyle(
                          color: Color(0xFF10B981),
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

            // بطاقة النموذج المستخدم
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
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
                    children: const [
                      Text(
                        'النموذج المستخدم',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                      Text(
                        'Llama 3.1 (8B)',
                        style: TextStyle(
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
            const SizedBox(height: 14),

            // رقم الإصدار
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'MEDIQ AI v1.0.0',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
                Icon(Icons.settings, color: Colors.white38, size: 16),
              ],
            ),
          ],
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      leading: Icon(icon, color: Colors.white70, size: 21),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}

// ============================================================================
// 6. شاشة المحادثة التفصيلية + شاشة الترحيب (Chat Screen)
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
  final List<Map<String, dynamic>> _customMessages = [];

  void _sendMessage([String? presetText]) {
    final text = presetText ?? _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _customMessages.add({
        'isUser': true,
        'text': text,
        'time': 'الآن',
      });
      _customMessages.add({
        'isUser': false,
        'text':
            'هذه معاينة لواجهة المستخدم. سيتم ربط هذا الرد قريباً بالنموذج الطبي المحلي Llama 3.1 للإجابة على سؤالك: "$text" بشكل دقيق ومفصل.',
        'time': 'الآن',
      });
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final bool isNewChat =
        widget.chatData['id'] == 'new' && _customMessages.isEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: !widget.isEmbedded,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFF0A2540),
              child: Icon(
                Icons.health_and_safety_rounded,
                color: Color(0xFF00E1FF),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chatData['title'] ?? 'محادثة طبية',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0A2540),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'متصل محلياً • Llama 3.1 (8B)',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF10B981),
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
          if (widget.onOpenSettings != null)
            IconButton(
              onPressed: widget.onOpenSettings,
              icon: const Icon(
                Icons.settings_outlined,
                color: Color(0xFF0A2540),
              ),
            ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF0A2540)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: isNewChat
                ? _buildWelcomePromptView()
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if ((widget.chatData['question'] as String)
                          .isNotEmpty) ...[
                        // سؤال المستخدم الأساسي
                        _buildUserBubble(widget.chatData['question']),
                        const SizedBox(height: 16),
                        // إجابة المساعد الذكي المنسقة
                        _buildAiStructuredResponse(widget.chatData),
                      ],
                      // الرسائل الإضافية التي يكتبها المستخدم أثناء التجربة
                      ..._customMessages.map((msg) {
                        if (msg['isUser'] == true) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: _buildUserBubble(msg['text']),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: _buildAiSimpleBubble(msg['text']),
                          );
                        }
                      }),
                    ],
                  ),
          ),

          // شريط إدخال الرسالة السفلي
          _buildBottomInputBar(),
        ],
      ),
    );
  }

  // واجهة الترحيب (كيف يمكنني مساعدتك اليوم؟) المطابقة للصورة الثالثة
  Widget _buildWelcomePromptView() {
    final suggestions = [
      {'title': 'ما هي أعراض\nارتفاع ضغط الدم؟', 'icon': Icons.favorite_border},
      {
        'title': 'كيف يعمل\nالجهاز المناعي؟',
        'icon': Icons.shield_outlined,
      },
      {
        'title': 'ما فائدة فيتامين\nD للجسم؟',
        'icon': Icons.medication_outlined,
      },
      {
        'title': 'اشرح هذا\nالمصطلح الطبي',
        'icon': Icons.menu_book_outlined,
      },
    ];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const MediqLogo(size: 64, showText: false),
            const SizedBox(height: 14),
            const Text(
              'MEDIQ AI',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0A2540),
              ),
            ),
            const Text(
              'مساعدك الطبي الذكي',
              style: TextStyle(fontSize: 14, color: Color(0xFF5A7184)),
            ),
            const SizedBox(height: 24),
            const Text(
              'كيف يمكنني مساعدتك اليوم؟',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0A2540),
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE1ECF4)),
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
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0A2540),
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
        constraints: const BoxConstraints(maxWidth: 320),
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
                  '09:24 م',
                  style: TextStyle(fontSize: 10, color: Color(0xFF5A7184)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiStructuredResponse(Map<String, dynamic> data) {
    final bullets = (data['bullets'] as List).cast<String>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
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
                // ترويسة البطاقة
                Row(
                  children: const [
                    Text(
                      'MEDIQ AI',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF0A2540),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '10:25 م',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // المقدمة
                Text(
                  data['answerIntro'],
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 12),

                // النقاط الطبية
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
                            style: const TextStyle(
                              fontSize: 13.5,
                              height: 1.5,
                              color: Color(0xFF334155),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // صندوق التنويه الداخلي
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F7FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF0078D4).withOpacity(0.2),
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
                          style: const TextStyle(
                            fontSize: 12.5,
                            height: 1.5,
                            color: Color(0xFF0A2540),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // أزرار التفاعل السفلية (إعجاب، نسخ، إعادة توليد)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildActionButton(Icons.thumb_up_alt_outlined, ''),
                    _buildActionButton(Icons.thumb_down_alt_outlined, ''),
                    _buildActionButton(Icons.copy_rounded, 'نسخ الإجابة'),
                    _buildActionButton(Icons.refresh_rounded, 'إعادة التوليد'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        const CircleAvatar(
          radius: 18,
          backgroundColor: Color(0xFF0A2540),
          child: Icon(
            Icons.medical_services_rounded,
            color: Color(0xFF00E1FF),
            size: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildAiSimpleBubble(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 14, height: 1.6),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F7FB),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF5A7184)),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF0A2540),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomInputBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
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
            // زر الإرسال الدائري الأزرق
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

            // حقل الكتابة والأيقونات المرفقة
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F7FB),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE1ECF4)),
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
                      onPressed: () {},
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
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(
                        Icons.attach_file_rounded,
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
// 7. شاشة الإعدادات (Settings Screen)
// ============================================================================
class SettingsScreen extends StatelessWidget {
  final bool isEmbedded;

  const SettingsScreen({super.key, this.isEmbedded = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: !isEmbedded,
        title: const Text(
          'الإعدادات',
          style: TextStyle(
            color: Color(0xFF0A2540),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // بطاقة حساب المستخدم
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                ),
              ],
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                radius: 24,
                backgroundColor: Color(0xFF0078D4),
                child: Icon(Icons.person, color: Colors.white, size: 28),
              ),
              title: const Text(
                'مستخدم',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0A2540),
                ),
              ),
              subtitle: const Text(
                'mediq_user',
                style: TextStyle(color: Color(0xFF7A8FA6), fontSize: 13),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Color(0xFF9FB1C1),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // قسم إعدادات التطبيق
          const Text(
            'إعدادات التطبيق',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF0A2540),
            ),
          ),
          const SizedBox(height: 10),
          _buildSettingsTile(
            icon: Icons.wb_sunny_outlined,
            title: 'المظهر',
            trailingText: 'الوضع الفاتح',
          ),
          _buildSettingsTile(
            icon: Icons.language_rounded,
            title: 'اللغة',
            trailingText: 'العربية',
          ),
          _buildSettingsTile(
            icon: Icons.text_fields_rounded,
            title: 'حجم الخط',
            trailingText: 'متوسط',
          ),
          _buildSettingsTile(
            icon: Icons.save_outlined,
            title: 'حفظ المحادثات',
            trailingText: 'تفعيل',
          ),
          _buildSettingsTile(
            icon: Icons.notifications_none_rounded,
            title: 'الإشعارات',
            trailingText: 'تفعيل',
          ),

          const SizedBox(height: 20),

          // قسم معلومات النموذج
          const Text(
            'معلومات النموذج',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF0A2540),
            ),
          ),
          const SizedBox(height: 10),
          _buildSettingsTile(
            icon: Icons.memory_rounded,
            title: 'اسم النموذج',
            trailingText: 'Llama 3.1 (8B)',
            highlightTrailing: true,
          ),
          _buildSettingsTile(
            icon: Icons.dns_outlined,
            title: 'حالة الخادم المحلي',
            trailingText: 'متصل ●',
            isConnectedStatus: true,
          ),

          const SizedBox(height: 24),

          // زر تسجيل الخروج
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: ListTile(
              onTap: () {},
              leading: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFE11D48),
              ),
              title: const Text(
                'تسجيل الخروج',
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
    required IconData icon,
    required String title,
    required String trailingText,
    bool highlightTrailing = false,
    bool isConnectedStatus = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF0078D4), size: 22),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0A2540),
          ),
        ),
        trailing: Text(
          trailingText,
          style: TextStyle(
            fontSize: 13,
            fontWeight:
                highlightTrailing || isConnectedStatus ? FontWeight.bold : null,
            color: isConnectedStatus
                ? const Color(0xFF10B981)
                : highlightTrailing
                    ? const Color(0xFF0078D4)
                    : const Color(0xFF7A8FA6),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// 8. اللوحة التعريفية الجانبية لشاشات الكمبيوتر (Desktop Info Panel)
// ============================================================================
class DesktopInfoPanel extends StatelessWidget {
  const DesktopInfoPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // بطاقة الترحيب العلوية
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFEBF5FF),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: const [
              Icon(
                Icons.Monitor_heart_rounded,
                color: Color(0xFF00B4DB),
                size: 48,
              ),
              SizedBox(height: 12),
              Text(
                'مساعدك الطبي الذكي',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF0A2540),
                ),
              ),
              SizedBox(height: 6),
              Text(
                'احصل على إجابات دقيقة وموثوقة لأسئلتك الطبية.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: Color(0xFF5A7184)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // قائمة المميزات
        _buildFeatureItem(
          icon: Icons.verified_user_outlined,
          title: 'معلومات طبية موثوقة',
          subtitle: 'مبنية على مصادر طبية معتمدة',
        ),
        _buildFeatureItem(
          icon: Icons.language_rounded,
          title: 'دعم اللغة العربية',
          subtitle: 'تواصل بسهولة بلغتك الأم',
        ),
        _buildFeatureItem(
          icon: Icons.wifi_tethering_off_rounded,
          title: 'يعمل محلياً',
          subtitle: 'بدون الحاجة للإنترنت',
        ),
        _buildFeatureItem(
          icon: Icons.lock_outline_rounded,
          title: 'خصوصيتك تهمنا',
          subtitle: 'لا يتم إرسال بياناتك لأي جهة خارجية',
        ),

        const SizedBox(height: 20),

        // صندوق التنويه الطبي المهم
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE6F3FF),
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
              const Text(
                'المعلومات المقدمة في هذا التطبيق للتثقيف الطبي فقط، ولا تغني عن استشارة الطبيب المختص.\n\nفي حالات الطوارئ، يرجى التوجه مباشرة إلى أقرب مركز طبي.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.6,
                  color: Color(0xFF0A2540),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),

        // الشعار السفلي
        const Center(
          child: Text(
            'معاً نحو صحة أفضل',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF0A2540),
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Center(child: MediqLogo(size: 36, showText: true)),
      ],
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE6F4FA),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF0A2540),
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

