import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
  runApp(const MediqAiApp());
}

class AppController extends ChangeNotifier {
  bool isDarkMode = false;
  String language = 'العربية';
  String fontSizeLabel = 'متوسط';
  bool saveChats = true;
  bool notificationsEnabled = true;
  bool isLocalServerConnected = true;
  String selectedModel = 'Llama 3.1 (8B)';
  String userName = 'د. مستخدم';
  String userHandle = '@mediq_user';
  String searchQuery = '';
  bool showFavoritesOnly = false;

  double get fontScale {
    switch (fontSizeLabel) {
      case 'صغير':
        return 0.90;
      case 'كبير':
        return 1.14;
      default:
        return 1.0;
    }
  }

  final List<Map<String, dynamic>> chats = [
    {
      'id': 'diabetes',
      'category': 'الغدد والسكري',
      'title': 'معلومات شاملة عن السكري',
      'subtitle': 'السكري هو اضطراب مزمن في استقلاب الجلوكوز...',
      'time': 'اليوم 09:24 م',
      'icon': Icons.water_drop_rounded,
      'color': 0xFF0096C7,
      'isFavorite': true,
      'question': 'ما هي أبرز أعراض مرض السكري وكيف يتم تشخيصه؟',
      'answerIntro':
          'مرض السكري هو اضطراب أيضي يؤدي إلى ارتفاع مستويات الجلوكوز في الدم نتيجة نقص الأنسولين أو ضعف استجابة الخلايا له. من أبرز أعراضه السريرية:',
      'bullets': [
        'زيادة العطش بشكل مستمر وجفاف الفم والحلق.',
        'كثرة التبول خاصة خلال ساعات الليل.',
        'الشعور بالجوع الشديد رغم تناول الوجبات بانتظام.',
        'فقدان الوزن غير المبرر والشعور بالإجهاد السريع.',
        'تشوش الرؤية المؤقت وبطء التئام الجروح السطحية.',
      ],
      'footer':
          'يُنصح بإجراء فحص السكر الصائم وفحص السكر التراكمي (HbA1c) ومراجعة طبيب الباطنية والغدد الصماء لتحديد الخطة العلاجية.',
    },
    {
      'id': 'gastritis',
      'category': 'الجهاز الهضمي',
      'title': 'أعراض وأسباب التهاب المعدة',
      'subtitle': 'التهاب بطانة المعدة يسبب ألماً وحرقاناً علوياً...',
      'time': 'أمس 04:45 م',
      'icon': Icons.medical_information_rounded,
      'color': 0xFF10B981,
      'isFavorite': false,
      'question': 'ما هي أسباب التهاب المعدة المتكرر؟',
      'answerIntro':
          'يحدث التهاب المعدة نتيجة تهيج أو تآكل البطانة المخاطية التي تحمي جدار المعدة من العصارة الهضمية، وأهم أسبابه:',
      'bullets': [
        'العدوى البكتيرية بجرثومة المعدة (Helicobacter pylori).',
        'الإفراط في استخدام المسكنات ومضادات الالتهاب غير الستيرويدية.',
        'التوتر العصبي الشديد والضغوط النفسية المستمرة.',
        'تناول الأطعمة الدسمة والحارة والمشروبات الغازية بكثرة.',
      ],
      'footer':
          'للحصول على تشخيص دقيق ووصفة علاجية مناسبة، يرجى إجراء فحص جرثومة المعدة واستشارة طبيب الجهاز الهضمي.',
    },
    {
      'id': 'anemia',
      'category': 'أمراض الدم',
      'title': 'فقر الدم ونقص الحديد',
      'subtitle': 'انخفاض الهيموجلوبين يقلل وصول الأكسجين للأنسجة...',
      'time': 'منذ يومين',
      'icon': Icons.favorite_rounded,
      'color': 0xFFE11D48,
      'isFavorite': true,
      'question': 'ما هي أعراض فقر الدم الناتج عن نقص الحديد؟',
      'answerIntro':
          'يؤدي نقص الحديد إلى انخفاض إنتاج الهيموجلوبين الضروري لنقل الأكسجين في الدم، وتظهر الأعراض التالية تدريجياً:',
      'bullets': [
        'الإرهاق المستمر والضعف العام عند بذل مجهود بسيط.',
        'شحوب البشرة واللثة وبطانة الجفون الداخلية.',
        'تسارع ضربات القلب أو ضيق التنفس أثناء الحركة.',
        'برودة الأطراف وتكسر الأظافر أو تساقط الشعر.',
      ],
      'footer':
          'يوصى بإجراء تحليل صورة الدم الكاملة (CBC) ومخزون الحديد (Ferritin) قبل البدء بتناول مكملات الحديد.',
    },
  ];

  List<Map<String, dynamic>> get filteredChats {
    return chats.where((chat) {
      final matchesSearch = searchQuery.isEmpty ||
          chat['title'].toString().contains(searchQuery) ||
          chat['subtitle'].toString().contains(searchQuery) ||
          (chat['category']?.toString().contains(searchQuery) ?? false);
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
    selectedModel = selectedModel.contains('3.1')
        ? 'Meditron (7B)'
        : 'Llama 3.1 (8B)';
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

  void updateUserProfile(String n, String h) {
    if (n.trim().isNotEmpty) userName = n.trim();
    if (h.trim().isNotEmpty) {
      userHandle = h.trim().startsWith('@') ? h.trim() : '@${h.trim()}';
    }
    notifyListeners();
  }

  Map<String, dynamic> generateReply(String q) {
    final newChat = {
      'id': 'chat_${DateTime.now().millisecondsSinceEpoch}',
      'category': 'استشارة ذكية',
      'title': q.length > 28 ? '${q.substring(0, 28)}...' : q,
      'subtitle': 'تحليل طبي فوري عبر المحرك المحلي ($selectedModel)...',
      'time': 'الآن',
      'icon': Icons.health_and_safety_rounded,
      'color': 0xFF0077B6,
      'isFavorite': false,
      'question': q,
      'answerIntro':
          'بناءً على المعطيات الطبية في نموذج ($selectedModel) بخصوص سؤالك حول "$q"، إليك الإرشادات والتفاصيل العلمية:',
      'bullets': [
        'مراقبة الأعراض الحيوية بدقة وتدوين أوقات ظهورها أو زيادتها.',
        'الحفاظ على ترطيب الجسم بشرب كميات كافية من الماء وأخذ قسط وافر من الراحة.',
        'تجنب تناول أي أدوية تخصصية أو مضادات حيوية دون استشارة طبية مباشرة.',
        'مراجعة الطبيب المختص لإجراء الفحوصات السريرية والمخبرية اللازمة عند استمرار الأعراض.',
      ],
      'footer':
          'تنبيه طبي: هذه القراءة التحليلية مخصصة للتثقيف الصحي المبدئي ولا تغني عن الفحص الطبي المباشر.',
    };
    if (saveChats) {
      chats.insert(0, newChat);
      notifyListeners();
    }
    return newChat;
  }
}

final AppController appController = AppController();

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
            scaffoldBackgroundColor: const Color(0xFFF2F6FC),
            primaryColor: const Color(0xFF0066CC),
            cardColor: Colors.white,
            dividerColor: const Color(0xFFE2E8F0),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0066CC),
              secondary: Color(0xFF00B4D8),
              surface: Colors.white,
              onSurface: Color(0xFF0A192F),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF060F1E),
            primaryColor: const Color(0xFF00B4D8),
            cardColor: const Color(0xFF0E1E32),
            dividerColor: const Color(0xFF1E344E),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00B4D8),
              secondary: Color(0xFF00E5FF),
              surface: Color(0xFF0E1E32),
              onSurface: Colors.white,
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

// ==========================================
// الشعار والموجة النبضية (Logo & ECG Wave)
// ==========================================

class MediqLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool forceDark;

  const MediqLogo({
    super.key,
    this.size = 42,
    this.showText = true,
    this.forceDark = false,
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
                color: const Color(0xFF00B4D8).withOpacity(0.38),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.favorite_rounded,
                color: Colors.white.withOpacity(0.18),
                size: size * 0.72,
              ),
              Container(
                width: size * 0.54,
                height: size * 0.54,
                decoration: BoxDecoration(
                  color: const Color(0xFF061526).withOpacity(0.9),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.35),
                    width: 1.2,
                  ),
                ),
                child: Icon(
                  Icons.health_and_safety_rounded,
                  color: const Color(0xFF00E5FF),
                  size: size * 0.34,
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
                    letterSpacing: 0.6,
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
                'المساعد الطبي الذكي',
                style: TextStyle(
                  fontSize: size * 0.24,
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
      ..color = color.withOpacity(0.18)
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
    final end = math.min(metric.length, start + len);
    final extract = metric.extractPath(math.max(0, start), end);
    canvas.drawPath(extract, paintGlow);
  }

  @override
  bool shouldRepaint(covariant EcgPainter old) => old.progress != progress;
}

// ==========================================
// شاشة البداية (Splash Screen)
// ==========================================

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
              colors: [Color(0xFF040B16), Color(0xFF08203E), Color(0xFF040B16)],
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
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF00E5FF).withOpacity(0.06),
                    border: Border.all(
                      color: const Color(0xFF00E5FF).withOpacity(0.18),
                      width: 1.5,
                    ),
                  ),
                  child: const MediqLogo(size: 115, showText: false),
                ),
                const SizedBox(height: 28),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
                    children: [
                      TextSpan(
                        text: 'MEDIQ ',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text: 'AI',
                        style: TextStyle(color: Color(0xFF00E5FF)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'NEXT-GEN MEDICAL AI ASSISTANT',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                const Text(
                  'اسأل ... افهم ... اطمئن',
                  style: TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
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
                  'جاري تشغيل المحرك الطبي الذكي...',
                  style: TextStyle(color: Colors.white60, fontSize: 13),
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

// ==========================================
// الهيكل الرئيسي للتطبيق (Main Shell)
// ==========================================

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _navIndex = 0;
  String? _selectedChatId;

  void _openChat(Map<String, dynamic> chat) {
    final isDesktop = MediaQuery.of(context).size.width >= 950;
    if (isDesktop) {
      setState(() {
        _selectedChatId = chat['id'];
        _navIndex = 2;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChatScreen(chatData: chat)),
      );
    }
  }

  void _newChat([String? initialQuestion]) {
    final newChat = {
      'id': 'new',
      'title': 'استشارة طبية جديدة',
      'question': initialQuestion ?? '',
      'answerIntro': '',
      'bullets': <String>[],
      'footer': '',
    };
    final isDesktop = MediaQuery.of(context).size.width >= 950;
    if (isDesktop) {
      setState(() {
        _selectedChatId = 'new';
        _navIndex = 2;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ChatScreen(chatData: newChat)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 950;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDesktop) {
      final activeChat = appController.chats.firstWhere(
        (c) => c['id'] == (_selectedChatId ?? 'diabetes'),
        orElse: () => {
          'id': 'new',
          'title': 'استشارة طبية جديدة',
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
              width: 285,
              child: SidebarDrawer(
                onNewChat: () => _newChat(),
                onSelectSettings: () => setState(() => _navIndex = 3),
                onSelectHome: () {
                  appController.setShowFavoritesOnly(false);
                  setState(() => _navIndex = 0);
                },
                onSelectFav: () {
                  appController.setShowFavoritesOnly(true);
                  setState(() => _navIndex = 0);
                },
              ),
            ),
            Expanded(
              flex: 3,
              child: _navIndex == 3
                  ? const SettingsScreen(embedded: true)
                  : _navIndex == 1
                      ? ExploreScreen(onAskQuestion: (q) => _newChat(q))
                      : _navIndex == 0
                          ? HomeScreen(
                              onOpenChat: _openChat,
                              onNewChat: () => _newChat(),
                            )
                          : ChatScreen(
                              chatData: activeChat,
                              embedded: true,
                              onOpenSettings: () => setState(() => _navIndex = 3),
                            ),
            ),
            Container(
              width: 315,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0A1626) : Colors.white,
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

    return Scaffold(
      drawer: Drawer(
        backgroundColor: const Color(0xFF061222),
        child: SidebarDrawer(
          onNewChat: () {
            Navigator.pop(context);
            _newChat();
          },
          onSelectSettings: () {
            Navigator.pop(context);
            setState(() => _navIndex = 3);
          },
          onSelectHome: () {
            Navigator.pop(context);
            appController.setShowFavoritesOnly(false);
            setState(() => _navIndex = 0);
          },
          onSelectFav: () {
            Navigator.pop(context);
            appController.setShowFavoritesOnly(true);
            setState(() => _navIndex = 0);
          },
        ),
      ),
      body: IndexedStack(
        index: _navIndex,
        children: [
          HomeScreen(onOpenChat: _openChat, onNewChat: () => _newChat()),
          ExploreScreen(onAskQuestion: (q) => _newChat(q)),
          ChatScreen(
            chatData: appController.chats.isNotEmpty
                ? appController.chats.first
                : {
                    'id': 'new',
                    'title': 'استشارة طبية جديدة',
                    'question': '',
                    'answerIntro': '',
                    'bullets': <String>[],
                    'footer': '',
                  },
            embedded: true,
          ),
          const SettingsScreen(embedded: true),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0A1626) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _navIndex,
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

// ==========================================
// الشاشة الرئيسية (Home Screen)
// ==========================================

class HomeScreen extends StatelessWidget {
  final Function(Map<String, dynamic>) onOpenChat;
  final VoidCallback onNewChat;
  const HomeScreen({
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
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                InkWell(
                  onTap: () => Scaffold.maybeOf(context)?.openDrawer(),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
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
                const SizedBox(width: 12),
                const Expanded(child: MediqLogo(size: 38)),
                IconButton(
                  onPressed: appController.toggleTheme,
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
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
                // بطاقة الترحيب وحالة المحرك المحلي
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF03045E), Color(0xFF0077B6), Color(0xFF00B4D8)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0077B6).withOpacity(0.32),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: appController.isLocalServerConnected
                                        ? const Color(0xFF10B981)
                                        : Colors.amber,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  appController.isLocalServerConnected
                                      ? 'متصل محلياً • ${appController.selectedModel}'
                                      : 'الخادم المحلي في وضع الاستعداد',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: appController.toggleServerStatus,
                            child: const Icon(
                              Icons.sync_rounded,
                              color: Colors.white70,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'أهلاً بك، ${appController.userName} 👋',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'مساعدك الطبي الذكي جاهز لتحليل الأعراض وتقديم الإرشادات الصحية بخصوصية تامة وبدون إنترنت.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.5,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: onNewChat,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF023E8A),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.add_comment_rounded, size: 20),
                          label: const Text(
                            'بدء استشارة طبية جديدة',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // شريط البحث
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: appController.setSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'ابحث في الاستشارات والمواضيع الطبية...',
                      hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13.5,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF0077B6),
                      ),
                      suffixIcon: appController.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
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

                const SizedBox(height: 20),

                // عنوان القائمة مع أزرار الفلترة
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0096C7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          appController.showFavoritesOnly
                              ? 'الاستشارات المفضلة ⭐'
                              : 'السجل الطبي الأخير',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF0A192F),
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () => appController.setShowFavoritesOnly(
                        !appController.showFavoritesOnly,
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF0077B6),
                      ),
                      icon: Icon(
                        appController.showFavoritesOnly
                            ? Icons.view_list_rounded
                            : Icons.star_rounded,
                        size: 18,
                      ),
                      label: Text(
                        appController.showFavoritesOnly ? 'عرض الكل' : 'المفضلة فقط',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                if (chats.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(36),
                    alignment: Alignment.center,
                    child: Column(
                      children: [
                        Icon(
                          Icons.folder_off_outlined,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'لا توجد محادثات مطابقة للبحث',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),

                // بطاقات المحادثات
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
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.025),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: InkWell(
                      onTap: () => onOpenChat(chat),
                      borderRadius: BorderRadius.circular(18),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Icon(
                                chat['icon'] as IconData,
                                color: accentColor,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: accentColor.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          chat['category'] ?? 'عام',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: accentColor,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        chat['time'],
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    chat['title'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF0A192F),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    chat['subtitle'],
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () =>
                                  appController.toggleFavorite(chat['id']),
                              icon: Icon(
                                isFav
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                color: isFav
                                    ? const Color(0xFFFFB703)
                                    : const Color(0xFF94A3B8),
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// شاشة استكشاف المواضيع الطبية (Explore Screen)
// ==========================================

class ExploreScreen extends StatelessWidget {
  final Function(String) onAskQuestion;
  const ExploreScreen({super.key, required this.onAskQuestion});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topics = [
      {
        'title': 'صحة القلب والشرايين',
        'sub': 'ضغط الدم، الكوليسترول، وتخطيط القلب',
        'icon': Icons.monitor_heart_rounded,
        'color': 0xFFE11D48,
        'q': 'ما هي أعراض ارتفاع ضغط الدم وكيف أحافظ على صحة القلب؟',
      },
      {
        'title': 'السكري والغدد الصماء',
        'sub': 'تنظيم السكر، الأنسولين، والغدة الدرقية',
        'icon': Icons.water_drop_rounded,
        'color': 0xFF0096C7,
        'q': 'كيف يمكنني تنظيم مستوى السكر التراكمي في الدم طبيعياً؟',
      },
      {
        'title': 'الجهاز الهضمي والتغذية',
        'sub': 'جرثومة المعدة، القولون العصبي، والفيتامينات',
        'icon': Icons.restaurant_menu_rounded,
        'color': 0xFF10B981,
        'q': 'ما هي أفضل النصائح لعلاج القولون العصبي وحموضة المعدة؟',
      },
      {
        'title': 'المناعة والفيتامينات',
        'sub': 'فيتامين D، الحديد، الزنك، وتقوية المناعة',
        'icon': Icons.shield_rounded,
        'color': 0xFFF59E0B,
        'q': 'ما هي أعراض نقص فيتامين D والحديد في الجسم؟',
      },
      {
        'title': 'الأعصاب والصداع',
        'sub': 'الصداع النصفي، التوتر، وجودة النوم',
        'icon': Icons.psychology_rounded,
        'color': 0xFF8B5CF6,
        'q': 'ما هي أسباب الصداع النصفي المتكرر وكيف أتغلب على الأرق؟',
      },
      {
        'title': 'الإسعافات الأولية',
        'sub': 'إرشادات التعامل مع الحالات الطارئة',
        'icon': Icons.medical_services_rounded,
        'color': 0xFFEC4899,
        'q': 'ما هي أهم خطوات الإسعافات الأولية لحالات الإغماء أو الحروق البسيطة؟',
      },
    ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'الموسوعة والاستكشاف الطبي',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : const Color(0xFF0A192F),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'اختر أي قسم طبي لبدء محادثة تحليلية فورية مع المساعد الذكي:',
            style: TextStyle(fontSize: 13.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 20),
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
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
                        child: Icon(t['icon'] as IconData, color: c, size: 26),
                      ),
                      const Spacer(),
                      Text(
                        t['title'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5,
                          color: isDark ? Colors.white : const Color(0xFF0A192F),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        t['sub'] as String,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF64748B),
                        ),
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

// ==========================================
// القائمة الجانبية (Sidebar Drawer)
// ==========================================

class SidebarDrawer extends StatelessWidget {
  final VoidCallback onNewChat;
  final VoidCallback onSelectSettings;
  final VoidCallback onSelectHome;
  final VoidCallback onSelectFav;

  const SidebarDrawer({
    super.key,
    required this.onNewChat,
    required this.onSelectSettings,
    required this.onSelectHome,
    required this.onSelectFav,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF061222),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MediqLogo(size: 40, forceDark: true),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(0xFF0077B6),
                      child: Icon(Icons.person_rounded, color: Colors.white),
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
              const SizedBox(height: 16),
              InkWell(
                onTap: onNewChat,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0096C7), Color(0xFF023E8A)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add_comment_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'استشارة طبية جديدة',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _item(Icons.history_rounded, 'سجل المحادثات', onSelectHome),
              _item(Icons.star_rounded, 'الاستشارات المفضلة', onSelectFav),
              _item(Icons.settings_rounded, 'إعدادات النظام', onSelectSettings),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1F36),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF00E5FF).withOpacity(0.22),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 9,
                          height: 9,
                          decoration: BoxDecoration(
                            color: appController.isLocalServerConnected
                                ? const Color(0xFF10B981)
                                : Colors.amber,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          appController.isLocalServerConnected
                              ? 'متصل بالخادم المحلي'
                              : 'وضع عدم الاتصال',
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.verified_user_rounded,
                          color: Color(0xFF00E5FF),
                          size: 16,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'المحرك: ${appController.selectedModel}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'خصوصية تامة • معالجة محلية 100%',
                      style: TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'MEDIQ AI PRO • v2.0',
                  style: TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      onTap: onTap,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 6),
      leading: Icon(icon, color: const Color(0xFF00B4D8), size: 21),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ==========================================
// شاشة المحادثة (Chat Screen)
// ==========================================

class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> chatData;
  final bool embedded;
  final VoidCallback? onOpenSettings;
  const ChatScreen({
    super.key,
    required this.chatData,
    this.embedded = false,
    this.onOpenSettings,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final List<Map<String, dynamic>> _exchanges = [];
  bool _loading = false;
  int _reaction = 0;

  @override
  void initState() {
    super.initState();
    final initialQ = widget.chatData['question']?.toString() ?? '';
    if (widget.chatData['id'] == 'new' && initialQ.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _send(initialQ);
      });
    }
  }

  void _send([String? preset]) async {
    final txt = preset ?? _ctrl.text.trim();
    if (txt.isEmpty || _loading) return;
    _ctrl.clear();
    setState(() => _loading = true);

    await Future.delayed(const Duration(milliseconds: 650));
    final reply = appController.generateReply(txt);
    if (mounted) {
      setState(() {
        _loading = false;
        _exchanges.add(reply);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasInitialBuiltInAnswer =
        widget.chatData['id'] != 'new' &&
        (widget.chatData['question'] as String).isNotEmpty;
    final isNew = !hasInitialBuiltInAnswer && _exchanges.isEmpty && !_loading;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0,
        automaticallyImplyLeading: !widget.embedded,
        title: Row(
          children: [
            const MediqLogo(size: 34, showText: false),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.chatData['title'] ?? 'استشارة طبية',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0A192F),
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
                      Text(
                        'متصل • ${appController.selectedModel}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.w600,
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
              onPressed: () {
                appController.toggleFavorite(widget.chatData['id']);
                setState(() {});
              },
              icon: Icon(
                widget.chatData['isFavorite'] == true
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: widget.chatData['isFavorite'] == true
                    ? const Color(0xFFFFB703)
                    : null,
              ),
            ),
          if (_exchanges.isNotEmpty)
            IconButton(
              tooltip: 'بدء محادثة جديدة',
              onPressed: () => setState(() => _exchanges.clear()),
              icon: const Icon(Icons.refresh_rounded, size: 20),
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
            child: isNew
                ? _buildWelcomeView(isDark)
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (hasInitialBuiltInAnswer) ...[
                        _userBubble(widget.chatData['question']),
                        const SizedBox(height: 16),
                        _aiBubble(widget.chatData, isDark),
                      ],
                      ..._exchanges.map(
                        (ex) => Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Column(
                            children: [
                              _userBubble(ex['question']),
                              const SizedBox(height: 16),
                              _aiBubble(ex, isDark),
                            ],
                          ),
                        ),
                      ),
                      if (_loading)
                        Padding(
                          padding: const EdgeInsets.all(18),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(16),
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
                                Text(
                                  'جاري تحليل السؤال الطبي وصياغة الإرشادات...',
                                  style: TextStyle(
                                    color: Color(0xFF0096C7),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
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

  Widget _buildWelcomeView(bool isDark) {
    final list = [
      {
        't': 'ما هي أعراض ارتفاع ضغط الدم؟',
        'sub': 'القلب والأوعية',
        'i': Icons.favorite_rounded,
        'c': 0xFFE11D48,
      },
      {
        't': 'كيف أقوي الجهاز المناعي طبيعياً؟',
        'sub': 'المناعة والتغذية',
        'i': Icons.shield_rounded,
        'c': 0xFF10B981,
      },
      {
        't': 'ما فائدة فيتامين D وما أعراض نقصه؟',
        'sub': 'الفيتامينات',
        'i': Icons.wb_sunny_rounded,
        'c': 0xFFF59E0B,
      },
      {
        't': 'ما أسباب الصداع المستمر والإرهاق؟',
        'sub': 'الأعصاب',
        'i': Icons.psychology_rounded,
        'c': 0xFF0096C7,
      },
    ];
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            const MediqLogo(size: 72, showText: false),
            const SizedBox(height: 16),
            Text(
              'كيف يمكنني مساعدتك صحياً اليوم؟',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0A192F),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'اختر أحد الأسئلة الشائعة أو اكتب استشارتك بالأسفل',
              style: TextStyle(fontSize: 13.5, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: list.map((item) {
                final c = Color(item['c'] as int);
                return InkWell(
                  onTap: () => _send(item['t'] as String),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: 165,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: c.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(item['i'] as IconData, color: c, size: 20),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item['sub'] as String,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: c,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item['t'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
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
          ],
        ),
      ),
    );
  }

  Widget _userBubble(String txt) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF0077B6), Color(0xFF023E8A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(4),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0077B6).withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              txt,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 6),
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.done_all_rounded, size: 14, color: Color(0xFF00E5FF)),
                SizedBox(width: 4),
                Text(
                  'تم الإرسال',
                  style: TextStyle(fontSize: 10, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _aiBubble(Map<String, dynamic> data, bool isDark) {
    final bullets = (data['bullets'] as List).cast<String>();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const MediqLogo(size: 28, showText: false),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF0096C7).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  appController.selectedModel,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: Color(0xFF0096C7),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 22),
          Text(
            data['answerIntro'],
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          ...bullets.map(
            (b) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withOpacity(0.03)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF0096C7),
                    size: 18,
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
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFF59E0B).withOpacity(0.30),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.gpp_maybe_rounded,
                  color: Color(0xFFD97706),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    data['footer'],
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFFFDE68A)
                          : const Color(0xFF92400E),
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
              _actionBtn(
                icon: _reaction == 1
                    ? Icons.thumb_up_alt_rounded
                    : Icons.thumb_up_alt_outlined,
                label: 'مفيد',
                active: _reaction == 1,
                onTap: () => setState(() => _reaction = _reaction == 1 ? 0 : 1),
              ),
              _actionBtn(
                icon: _reaction == -1
                    ? Icons.thumb_down_alt_rounded
                    : Icons.thumb_down_alt_outlined,
                active: _reaction == -1,
                onTap: () =>
                    setState(() => _reaction = _reaction == -1 ? 0 : -1),
              ),
              _actionBtn(
                icon: Icons.copy_rounded,
                label: 'نسخ التقرير',
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text:
                          '${data['answerIntro']}\n${bullets.join("\n")}\n${data['footer']}',
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم نسخ الإجابة الطبية إلى الحافظة ✓'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
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
    bool active = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active
              ? const Color(0xFF0077B6).withOpacity(0.15)
              : Colors.grey.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? const Color(0xFF0077B6) : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: active ? const Color(0xFF0077B6) : const Color(0xFF64748B),
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: active
                      ? const Color(0xFF0077B6)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _inputBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF060F1E)
                      : const Color(0xFFF2F6FC),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark ? Colors.white12 : const Color(0xFFDCE4F0),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.medical_services_outlined,
                      color: Color(0xFF0096C7),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        onSubmitted: (_) => _send(),
                        decoration: const InputDecoration(
                          hintText: 'اكتب سؤالك أو الأعراض التي تشعر بها...',
                          hintStyle: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 13.5,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
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
                    colors: [Color(0xFF00B4D8), Color(0xFF0077B6)],
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
          ],
        ),
      ),
    );
  }
}

// ==========================================
// شاشة الإعدادات (Settings Screen)
// ==========================================

class SettingsScreen extends StatelessWidget {
  final bool embedded;
  const SettingsScreen({super.key, this.embedded = false});

  void _showEditProfileDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: appController.userName);
    final handleCtrl = TextEditingController(text: appController.userHandle);
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text(
            'تعديل الملف الشخصي',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
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
                decoration: const InputDecoration(labelText: 'المعرف (@handle)'),
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
        automaticallyImplyLeading: !embedded,
        title: Text(
          'الإعدادات والتخصيص',
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(0xFF0077B6),
                  child: Icon(Icons.person_rounded, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appController.userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        appController.userHandle,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showEditProfileDialog(context),
                  icon: const Icon(Icons.edit_rounded, size: 16),
                  label: const Text('تعديل'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'المظهر والعرض',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
          const SizedBox(height: 10),
          _switchTile(
            context,
            icon: isDark ? Icons.dark_mode_rounded : Icons.wb_sunny_rounded,
            title: 'الوضع الداكن المريح للعين',
            subtitle: isDark ? 'مفعل حالياً' : 'الوضع الفاتح مفعل',
            value: isDark,
            onChanged: (_) => appController.toggleTheme(),
          ),
          _tile(
            context,
            Icons.text_fields_rounded,
            'حجم الخط في التطبيق',
            appController.fontSizeLabel,
            appController.cycleFontSize,
          ),
          _tile(
            context,
            Icons.language_rounded,
            'لغة الواجهة والمحادثة',
            appController.language,
            () {},
          ),
          const SizedBox(height: 20),
          const Text(
            'الخصوصية والتنبيهات',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
          const SizedBox(height: 10),
          _switchTile(
            context,
            icon: Icons.history_edu_rounded,
            title: 'حفظ سجل الاستشارات تلقائياً',
            subtitle: 'تخزين المحادثات محلياً على جهازك فقط',
            value: appController.saveChats,
            onChanged: (_) => appController.toggleSaveChats(),
          ),
          _switchTile(
            context,
            icon: Icons.notifications_active_outlined,
            title: 'التنبيهات الصحية الذكية',
            subtitle: 'تذكيرات دورية وإشعارات النظام',
            value: appController.notificationsEnabled,
            onChanged: (_) => appController.toggleNotifications(),
          ),
          const SizedBox(height: 20),
          const Text(
            'محرك الذكاء الاصطناعي المحلي',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
          const SizedBox(height: 10),
          _tile(
            context,
            Icons.memory_rounded,
            'النموذج الطبي النشط',
            appController.selectedModel,
            appController.cycleModel,
          ),
          _tile(
            context,
            Icons.dns_rounded,
            'حالة الخادم المحلي',
            appController.isLocalServerConnected ? 'متصل ●' : 'متوقف ○',
            appController.toggleServerStatus,
          ),
          const SizedBox(height: 22),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE11D48).withOpacity(0.25),
              ),
            ),
            child: ListTile(
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SplashScreen()),
              ),
              leading: const Icon(Icons.restart_alt_rounded, color: Color(0xFFE11D48)),
              title: const Text(
                'إعادة تشغيل النظام الطبي',
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
    required String subtitle,
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
        secondary: Icon(icon, color: const Color(0xFF0077B6)),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
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
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF0077B6).withOpacity(0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
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
              const SizedBox(width: 6),
              const Icon(
                Icons.swap_horiz_rounded,
                size: 15,
                color: Color(0xFF0077B6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// اللوحة الجانبية للمعلومات (Info Panel)
// ==========================================

class InfoPanel extends StatelessWidget {
  const InfoPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF102A45), const Color(0xFF0B1C30)]
                  : [const Color(0xFFE0F2FE), const Color(0xFFF0F9FF)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.monitor_heart_rounded,
                color: Color(0xFF0096C7),
                size: 46,
              ),
              const SizedBox(height: 12),
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
                'قراءة تحليلية مبنية على أحدث النماذج الطبية المحلية.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _feat(
          Icons.verified_user_rounded,
          'معطيات طبية منظمة',
          'إرشادات مبنية على مراجع صحية',
          isDark,
        ),
        _feat(
          Icons.translate_rounded,
          'دعم كامل للغة العربية',
          'شرح واضح ومبسط للمصطلحات',
          isDark,
        ),
        _feat(
          Icons.wifi_off_rounded,
          'يعمل محلياً 100%',
          'استجابة فورية بدون اتصال بالإنترنت',
          isDark,
        ),
        _feat(
          Icons.lock_rounded,
          'خصوصية وأمان تام',
          'بياناتك الصحية تبقى داخل جهازك',
          isDark,
        ),
        const SizedBox(height: 24),
        const Center(
          child: AnimatedEcgWave(
            width: 180,
            height: 34,
            color: Color(0xFF0096C7),
          ),
        ),
      ],
    );
  }

  Widget _feat(IconData icon, String title, String sub, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0096C7).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF0096C7), size: 20),
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
                    color: isDark ? Colors.white : const Color(0xFF0A192F),
                  ),
                ),
                Text(
                  sub,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF64748B),
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

