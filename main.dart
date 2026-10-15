import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
  runApp(const MediqAiApp());
}

class AppController extends ChangeNotifier {
  bool isDarkMode = false;
  String language = 'العربية';
  String fontSizeLabel = 'متوسط';
  bool saveChats = true;
  bool notificationsEnabled = true;
  bool isLocalServerConnected = true;
  String selectedModel = 'Llama 3.1 (8B) - Med';
  String userName = 'د. مستخدم';
  String userHandle = '@mediq_doctor';
  String searchQuery = '';
  bool showFavoritesOnly = false;
  String pinCode = '';
  bool isLocked = false;

  // Medical ID & Vitals
  Map<String, String> medicalId = {
    'name': 'د. مستخدم',
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
    {'name': 'فيتامين D3', 'time': '09:00 ص', 'status': false},
    {'name': 'أسبرين أطفال', 'time': '02:00 م', 'status': true},
  ];

  double get fontScale {
    switch (fontSizeLabel) {
      case 'صغير': return 0.90;
      case 'كبير': return 1.14;
      default: return 1.0;
    }
  }

  final List<Map<String, dynamic>> chats = [
    {
      'id': 'diabetes',
      'category': 'الغدد والسكري',
      'title': 'أعراض وتشخيص السكري',
      'subtitle': 'اضطراب مزمن في استقلاب الجلوكوز...',
      'time': 'اليوم 09:24 م',
      'icon': Icons.water_drop_rounded,
      'color': 0xFF0096C7,
      'isFavorite': true,
      'question': 'ما هي أبرز أعراض مرض السكري وكيف يتم تشخيصه؟',
      'answerIntro': 'مرض السكري هو اضطراب أيضي يؤدي لارتفاع السكر في الدم. من أبرز أعراضه:',
      'bullets': [
        'زيادة العطش المستمر وجفاف الفم.',
        'كثرة التبول وخاصة ليلاً.',
        'الجوع الشديد وفقدان الوزن غير المبرر.',
        'الإرهاق السريع وتشوش الرؤية.',
      ],
      'footer': 'يُنصح بإجراء فحص السكر التراكمي (HbA1c) ومراجعة طبيب الغدد الصماء.',
    },
    {
      'id': 'gastritis',
      'category': 'الجهاز الهضمي',
      'title': 'التهاب المعدة والأسباب',
      'subtitle': 'تهيج وتآكل البطانة المخاطية...',
      'time': 'أمس 04:45 م',
      'icon': Icons.medical_information_rounded,
      'color': 0xFF10B981,
      'isFavorite': false,
      'question': 'ما هي أسباب التهاب المعدة المتكرر؟',
      'answerIntro': 'يحدث التهاب المعدة نتيجة تهيج البطانة المخاطية، وأهم أسبابه:',
      'bullets': [
        'العدوى بجرثومة المعدة (H. pylori).',
        'الإفراط في تناول المسكنات (NSAIDs).',
        'التوتر العصبي والضغط النفسي الشديد.',
        'تناول الأطعمة الحارة والدهنية بكثرة.',
      ],
      'footer': 'يُرجى إجراء فحص الجرثومة ومراجعة طبيب الجهاز الهضمي.',
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

  void toggleTheme() { isDarkMode = !isDarkMode; notifyListeners(); }
  void cycleFontSize() {
    fontSizeLabel = fontSizeLabel == 'صغير' ? 'متوسط' : fontSizeLabel == 'متوسط' ? 'كبير' : 'صغير';
    notifyListeners();
  }
  void cycleModel() {
    selectedModel = selectedModel.contains('3.1') ? 'Meditron (7B)' : 'Llama 3.1 (8B) - Med';
    notifyListeners();
  }
  void toggleServerStatus() { isLocalServerConnected = !isLocalServerConnected; notifyListeners(); }
  void toggleSaveChats() { saveChats = !saveChats; notifyListeners(); }
  void toggleNotifications() { notificationsEnabled = !notificationsEnabled; notifyListeners(); }
  void toggleFavorite(String id) {
    final idx = chats.indexWhere((c) => c['id'] == id);
    if (idx != -1) {
      chats[idx]['isFavorite'] = !(chats[idx]['isFavorite'] ?? false);
      notifyListeners();
    }
  }
  void setSearchQuery(String q) { searchQuery = q; notifyListeners(); }
  void setShowFavoritesOnly(bool v) { showFavoritesOnly = v; notifyListeners(); }
  
  void updateMedicalId(Map<String, String> newId) {
    medicalId = newId;
    notifyListeners();
  }

  void addVital(String type, String val, String status) {
    vitalsLog.insert(0, {'date': 'اليوم', 'type': type, 'val': val, 'status': status});
    notifyListeners();
  }

  void toggleMed(int index) {
    medsList[index]['status'] = !medsList[index]['status'];
    notifyListeners();
  }

  Map<String, dynamic> generateReply(String q) {
    final newChat = {
      'id': 'chat_${DateTime.now().millisecondsSinceEpoch}',
      'category': 'استشارة ذكية',
      'title': q.length > 28 ? '${q.substring(0, 28)}...' : q,
      'subtitle': 'تحليل طبي فوري عبر المحرك المحلي...',
      'time': 'الآن',
      'icon': Icons.health_and_safety_rounded,
      'color': 0xFF0077B6,
      'isFavorite': false,
      'question': q,
      'answerIntro': 'بناءً على معطيات المحرك الطبي بخصوص "$q"، إليك التحليل الإرشادي:',
      'bullets': [
        'مراقبة الأعراض الحيوية وتدوين أي تغيرات طارئة بدقة.',
        'الالتزام بالراحة التامة وترطيب الجسم بشرب السوائل المفيدة.',
        'تجنب تناول أي أدوية تخصصية بدون إشراف طبي مباشر.',
        'مراجعة الطبيب المعالج عند استمرار الأعراض لأكثر من 48 ساعة.',
      ],
      'footer': 'تنبيه: هذه القراءة التحليلية مخصصة للتثقيف الصحي المبدئي ولا تغني عن الفحص السريري.',
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
          title: 'MEDIQ AI PRO',
          debugShowCheckedModeBanner: false,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF2F6FC),
            primaryColor: const Color(0xFF0066CC),
            cardColor: Colors.white,
            colorScheme: const ColorScheme.light(primary: Color(0xFF0066CC), secondary: Color(0xFF00B4D8), surface: Colors.white),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF060F1E),
            primaryColor: const Color(0xFF00B4D8),
            cardColor: const Color(0xFF0E1E32),
            colorScheme: const ColorScheme.dark(primary: Color(0xFF00B4D8), secondary: Color(0xFF00E5FF), surface: Color(0xFF0E1E32)),
          ),
          builder: (context, child) => Directionality(
            textDirection: TextDirection.rtl,
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(appController.fontScale)),
              child: child!,
            ),
          ),
          home: const SplashScreen(),
        );
      },
    );
  }
}

// ================= Logo & ECG =================
class MediqLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool forceDark;
  const MediqLogo({super.key, this.size = 42, this.showText = true, this.forceDark = false});

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
            gradient: const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF0077B6), Color(0xFF023E8A)]),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.favorite_rounded, color: Colors.white.withOpacity(0.18), size: size * 0.72),
              Container(
                width: size * 0.54,
                height: size * 0.54,
                decoration: BoxDecoration(color: const Color(0xFF061526).withOpacity(0.9), shape: BoxShape.circle),
                child: Icon(Icons.health_and_safety_rounded, color: const Color(0xFF00E5FF), size: size * 0.34),
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
                  style: TextStyle(fontSize: size * 0.42, fontWeight: FontWeight.w900, letterSpacing: 0.6),
                  children: [
                    TextSpan(text: 'MEDIQ ', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0A192F))),
                    const TextSpan(text: 'AI', style: TextStyle(color: Color(0xFF00B4D8))),
                  ],
                ),
              ),
              Text('المساعد الطبي الأكاديمي', style: TextStyle(fontSize: size * 0.22, color: isDark ? Colors.white70 : const Color(0xFF64748B), fontWeight: FontWeight.w600)),
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
  const AnimatedEcgWave({super.key, this.width = 220, this.height = 45, this.color = const Color(0xFF00E5FF)});

  @override
  State<AnimatedEcgWave> createState() => _AnimatedEcgWaveState();
}

class _AnimatedEcgWaveState extends State<AnimatedEcgWave> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat();
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(animation: _ctrl, builder: (_, __) => CustomPaint(painter: EcgPainter(progress: _ctrl.value, color: widget.color))),
    );
  }
}

class EcgPainter extends CustomPainter {
  final double progress;
  final Color color;
  EcgPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paintBase = Paint()..color = color.withOpacity(0.18)..strokeWidth = 2.0..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;
    final paintGlow = Paint()..color = color..strokeWidth = 2.8..strokeCap = StrokeCap.round..style = PaintingStyle.stroke;

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
    final extract = metric.extractPath(math.max(0, start), math.min(metric.length, start + len));
    canvas.drawPath(extract, paintGlow);
  }
  @override
  bool shouldRepaint(covariant EcgPainter old) => old.progress != progress;
}

// ================= SplashScreen =================
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
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainShell()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainShell())),
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [Color(0xFF040B16), Color(0xFF08203E), Color(0xFF040B16)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF00E5FF).withOpacity(0.06), border: Border.all(color: const Color(0xFF00E5FF).withOpacity(0.18))),
                  child: const MediqLogo(size: 115, showText: false),
                ),
                const SizedBox(height: 28),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 1.4),
                    children: [
                      TextSpan(text: 'MEDIQ ', style: TextStyle(color: Colors.white)),
                      TextSpan(text: 'AI PRO', style: TextStyle(color: Color(0xFF00E5FF))),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text('أداة الأطباء والطلاب والمريض الذكية', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 30),
                const AnimatedEcgWave(width: 240, height: 48),
                const Spacer(flex: 2),
                const SizedBox(width: 26, height: 26, child: CircularProgressIndicator(strokeWidth: 2.4, color: Color(0xFF00E5FF))),
                const SizedBox(height: 14),
                const Text('جاري تهيئة المنصة الطبية...', style: TextStyle(color: Colors.white60, fontSize: 13)),
                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ================= MainShell =================
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
      setState(() { _selectedChatId = chat['id']; _navIndex = 2; });
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(chatData: chat)));
    }
  }

  void _newChat([String? initialQuestion]) {
    final newChat = {'id': 'new', 'title': 'استشارة طبية جديدة', 'question': initialQuestion ?? '', 'answerIntro': '', 'bullets': <String>[], 'footer': ''};
    final isDesktop = MediaQuery.of(context).size.width >= 950;
    if (isDesktop) {
      setState(() { _selectedChatId = 'new'; _navIndex = 2; });
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(chatData: newChat)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 950;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pages = [
      HomeScreen(onOpenChat: _openChat, onNewChat: () => _newChat()),
      ExploreScreen(onAskQuestion: (q) => _newChat(q)),
      ChatScreen(chatData: appController.chats.isNotEmpty ? appController.chats.first : {'id': 'new', 'title': 'استشارة جديدة', 'question': '', 'answerIntro': '', 'bullets': <String>[], 'footer': ''}, embedded: true),
      const MedicalToolsScreen(embedded: true),
      const MedicalStudentHubScreen(embedded: true),
      const SettingsScreen(embedded: true),
    ];

    if (isDesktop) {
      final activeChat = appController.chats.firstWhere(
        (c) => c['id'] == (_selectedChatId ?? 'diabetes'),
        orElse: () => {'id': 'new', 'title': 'استشارة جديدة', 'question': '', 'answerIntro': '', 'bullets': <String>[], 'footer': ''},
      );
      return Scaffold(
        body: Row(
          children: [
            SizedBox(
              width: 275,
              child: SidebarDrawer(
                onNewChat: () => _newChat(),
                onSelectNav: (idx) => setState(() => _navIndex = idx),
              ),
            ),
            Expanded(
              flex: 3,
              child: _navIndex == 2
                  ? ChatScreen(chatData: activeChat, embedded: true, onOpenSettings: () => setState(() => _navIndex = 5))
                  : pages[_navIndex],
            ),
            Container(
              width: 300,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0A1626) : Colors.white,
                border: Border(right: BorderSide(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0))),
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
          onNewChat: () { Navigator.pop(context); _newChat(); },
          onSelectNav: (idx) { Navigator.pop(context); setState(() => _navIndex = idx); },
        ),
      ),
      body: IndexedStack(index: _navIndex, children: pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0A1626) : Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, -3))],
        ),
        child: NavigationBar(
          selectedIndex: _navIndex > 5 ? 0 : _navIndex,
          onDestinationSelected: (i) => setState(() => _navIndex = i),
          backgroundColor: Colors.transparent,
          elevation: 0,
          height: 68,
          indicatorColor: const Color(0xFF0077B6).withOpacity(isDark ? 0.30 : 0.14),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded, color: Color(0xFF0096C7)), label: 'الرئيسية'),
            NavigationDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore_rounded, color: Color(0xFF0096C7)), label: 'الموسوعة'),
            NavigationDestination(icon: Icon(Icons.chat_bubble_outline_rounded), selectedIcon: Icon(Icons.chat_bubble_rounded, color: Color(0xFF0096C7)), label: 'المحادثة'),
            NavigationDestination(icon: Icon(Icons.medical_services_outlined), selectedIcon: Icon(Icons.medical_services_rounded, color: Color(0xFF0096C7)), label: 'الحاسبات'),
            NavigationDestination(icon: Icon(Icons.school_outlined), selectedIcon: Icon(Icons.school_rounded, color: Color(0xFF0096C7)), label: 'الطلاب'),
            NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings_rounded, color: Color(0xFF0096C7)), label: 'الإعدادات'),
          ],
        ),
      ),
    );
  }
}

// ================= Sidebar Drawer (All Pages) =================
class SidebarDrawer extends StatelessWidget {
  final VoidCallback onNewChat;
  final Function(int) onSelectNav;
  const SidebarDrawer({super.key, required this.onNewChat, required this.onSelectNav});

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
              const MediqLogo(size: 38, forceDark: true),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    const CircleAvatar(radius: 18, backgroundColor: Color(0xFF0077B6), child: Icon(Icons.person_rounded, color: Colors.white, size: 20)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(appController.userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                          Text(appController.userHandle, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              InkWell(
                onTap: onNewChat,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF0096C7), Color(0xFF023E8A)]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.add_comment_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 10),
                      Expanded(child: Text('استشارة جديدة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5))),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView(
                  children: [
                    _item(Icons.home_rounded, 'الرئيسية', 0),
                    _item(Icons.explore_rounded, 'الموسوعة والاستكشاف', 1),
                    _item(Icons.chat_bubble_rounded, 'المساعد الذكي', 2),
                    _item(Icons.medical_services_rounded, 'الأدوات والحاسبات الطبية', 3),
                    _item(Icons.school_rounded, 'بوابة طالب الطب (OSCE & GCS)', 4),
                    _item(Icons.settings_rounded, 'الإعدادات والتخصيص', 5),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF0B1F36), borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: [
                    Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    const Text('المحرك المحلي متصل', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 11.5)),
                    const Spacer(),
                    const Icon(Icons.verified_rounded, color: Color(0xFF00E5FF), size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(IconData icon, String title, int index) {
    return ListTile(
      onTap: () => onSelectNav(index),
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: const Color(0xFF00B4D8), size: 20),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w500)),
    );
  }
}

// ================= HomeScreen =================
class HomeScreen extends StatelessWidget {
  final Function(Map<String, dynamic>) onOpenChat;
  final VoidCallback onNewChat;
  const HomeScreen({super.key, required this.onOpenChat, required this.onNewChat});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chats = appController.filteredChats;

    return SafeArea(
      child: Column(
        children: [
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
                      border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                    ),
                    child: Icon(Icons.menu_rounded, color: isDark ? Colors.white : const Color(0xFF0A192F), size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(child: MediqLogo(size: 38)),
                IconButton(
                  onPressed: appController.toggleTheme,
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: Icon(isDark ? Icons.wb_sunny_rounded : Icons.dark_mode_rounded, color: isDark ? const Color(0xFFFFB703) : const Color(0xFF023E8A), size: 20),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF03045E), Color(0xFF0077B6), Color(0xFF00B4D8)], begin: Alignment.topRight, end: Alignment.bottomLeft),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.black.withOpacity(0.25), borderRadius: BorderRadius.circular(20)),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bolt_rounded, color: Color(0xFF00E5FF), size: 14),
                                SizedBox(width: 4),
                                Text('أحدث إصدار أطباء وطلاب', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text('أهلاً بك، ${appController.userName} 🩺', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      const Text('منصة طبية شاملة: حاسبات سريرية، إِسعافات، تحليل مخبري، وبوابة طالب طب.', style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4)),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: onNewChat,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF023E8A),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          icon: const Icon(Icons.add_comment_rounded, size: 18),
                          label: const Text('بدء استشارة أو فحص جديد', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                  ),
                  child: TextField(
                    onChanged: appController.setSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'ابحث في الاستشارات والمواضيع الطبية...',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0077B6)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(width: 4, height: 18, decoration: BoxDecoration(color: const Color(0xFF0096C7), borderRadius: BorderRadius.circular(4))),
                        const SizedBox(width: 8),
                        Text(appController.showFavoritesOnly ? 'الاستشارات المفضلة ⭐' : 'سجل الاستشارات الطبية', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF0A192F))),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () => appController.setShowFavoritesOnly(!appController.showFavoritesOnly),
                      icon: Icon(appController.showFavoritesOnly ? Icons.view_list_rounded : Icons.star_rounded, size: 18),
                      label: Text(appController.showFavoritesOnly ? 'عرض الكل' : 'المفضلة فقط', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...chats.map((chat) {
                  final isFav = chat['isFavorite'] == true;
                  final accentColor = Color(chat['color'] as int? ?? 0xFF0077B6);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                    ),
                    child: InkWell(
                      onTap: () => onOpenChat(chat),
                      borderRadius: BorderRadius.circular(18),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Container(
                              width: 50, height: 50,
                              decoration: BoxDecoration(color: accentColor.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                              child: Icon(chat['icon'] as IconData, color: accentColor, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(chat['title'], style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: isDark ? Colors.white : const Color(0xFF0A192F))),
                                  const SizedBox(height: 4),
                                  Text(chat['subtitle'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => appController.toggleFavorite(chat['id']),
                              icon: Icon(isFav ? Icons.star_rounded : Icons.star_border_rounded, color: isFav ? const Color(0xFFFFB703) : const Color(0xFF94A3B8), size: 22),
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

// ================= ExploreScreen =================
class ExploreScreen extends StatelessWidget {
  final Function(String) onAskQuestion;
  const ExploreScreen({super.key, required this.onAskQuestion});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topics = [
      {'title': 'صحة القلب والشرايين', 'sub': 'ضغط الدم، ECG، والكوليسترول', 'icon': Icons.monitor_heart_rounded, 'color': 0xFFE11D48, 'q': 'ما هي أهم مؤشرات صحة القلب وكيف أقرأ تخطيط القلب ECG؟'},
      {'title': 'السكري والغدد', 'sub': 'مستوى السكر، HbA1c، والأنسولين', 'icon': Icons.water_drop_rounded, 'color': 0xFF0096C7, 'q': 'كيف أفسر نتيجة تحليل السكر التراكمي HbA1c بدقة؟'},
      {'title': 'المناعة والفيتامينات', 'sub': 'فيتامين D، الحديد، والمناعة', 'icon': Icons.shield_rounded, 'color': 0xFF10B981, 'q': 'ما هي أعراض نقص فيتامين D والحديد وكيف أعوضهما؟'},
      {'title': 'الجهاز الهضمي', 'sub': 'جرثومة المعدة والقولون', 'icon': Icons.restaurant_menu_rounded, 'color': 0xFFF59E0B, 'q': 'ما هي أعراض جرثومة المعدة وبروتوكول العلاج الشائع؟'},
      {'title': 'الأعصاب والصداع', 'sub': 'الشقيقة، التوتر، وجودة النوم', 'icon': Icons.psychology_rounded, 'color': 0xFF8B5CF6, 'q': 'ما هي أسباب الصداع النصفي الشديد وكيف أتغلب على الأرق؟'},
      {'title': 'الإسعافات الطارئة', 'sub': 'الإغماء، الحروق، النزيف', 'icon': Icons.medical_services_rounded, 'color': 0xFFEC4899, 'q': 'ما هي الإسعافات الأولية السريعة لحالات الإغماء وانخفاض السكر؟'},
    ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('الموسوعة والاستكشاف السريري', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF0A192F))),
          const SizedBox(height: 6),
          const Text('اختر أي تخصص أو موضوع طبي لبدء تحليل فوري:', style: TextStyle(fontSize: 13.5, color: Color(0xFF64748B))),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: topics.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.05),
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
                    border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: c.withOpacity(0.14), borderRadius: BorderRadius.circular(14)), child: Icon(t['icon'] as IconData, color: c, size: 24)),
                      const Spacer(),
                      Text(t['title'] as String, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF0A192F))),
                      const SizedBox(height: 4),
                      Text(t['sub'] as String, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
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

// ================= MedicalToolsScreen =================
class MedicalToolsScreen extends StatefulWidget {
  final bool embedded;
  const MedicalToolsScreen({super.key, this.embedded = false});

  @override
  State<MedicalToolsScreen> createState() => _MedicalToolsScreenState();
}

class _MedicalToolsScreenState extends State<MedicalToolsScreen> {
  int _selectedTab = 0;

  final TextEditingController _weightCtrl = TextEditingController(text: '70');
  final TextEditingController _heightCtrl = TextEditingController(text: '175');
  String _bmiResult = '';

  final TextEditingController _bpCtrl = TextEditingController(text: '120/80');

  String _labType = 'السكر التراكمي (HbA1c)';
  final TextEditingController _labValCtrl = TextEditingController(text: '6.2');
  String _labResult = '';

  int _waterCups = 4;

  void _calcBmi() {
    final w = double.tryParse(_weightCtrl.text) ?? 0;
    final h = double.tryParse(_heightCtrl.text) ?? 0;
    if (w <= 0 || h <= 0) return;
    final hm = h / 100;
    final bmi = w / (hm * hm);
    String status = '';
    if (bmi < 18.5) status = 'وزن منخفض (Underweight)';
    else if (bmi < 25) status = 'وزن مثالي وطبيعي (Normal) ✅';
    else if (bmi < 30) status = 'زيادة وزن (Overweight)';
    else status = 'سمنة (Obese) - يُنصح بالمتابعة الغذائية';

    setState(() {
      _bmiResult = 'مؤشر كتلة الجسم (BMI): ${bmi.toStringAsFixed(1)}\nالتصنيف: $status';
    });
  }

  void _interpretLab() {
    final v = double.tryParse(_labValCtrl.text) ?? 0;
    String res = '';
    if (_labType.contains('HbA1c')) {
      if (v < 5.7) res = 'طبيعي (سليم)';
      else if (v < 6.5) res = 'مرحلة ما قبل السكري (Prediabetes) - يُنصح بتعديل النمط الغذائي.';
      else res = 'مرتفع (مؤشر لمرض السكري) - يرجى مراجعة الطبيب.';
    } else if (_labType.contains('فيتامين D')) {
      if (v < 20) res = 'نقص حاد (Deficient) - يتطلب وصفة علاجية مكملة.';
      else if (v < 30) res = 'نقص (Insufficient).';
      else res = 'مستوى طبيعي ومطمئن (Sufficient) ✅';
    } else {
      res = 'القراءة المدخلة ($v) ضمن المعدلات العامة للاختبار. راجع التقرير المخبري المختوم.';
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
        automaticallyImplyLeading: !widget.embedded,
        title: Text('الأدوات والحاسبات الطبية المتقدمة', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: isDark ? Colors.white : const Color(0xFF0A192F))),
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
                _tabBtn('مفسر التحاليل', 2),
                _tabBtn('عدّاد الماء', 3),
                _tabBtn('التعارضات الدوائية', 4),
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
                if (_selectedTab == 3) _buildWaterCard(isDark),
                if (_selectedTab == 4) _buildInteractionsCard(isDark),
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
        labelStyle: TextStyle(color: active ? Colors.white : null, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBmiCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('حاسبة مؤشر كتلة الجسم والوزن المثالي (BMI)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          TextField(controller: _weightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الوزن بالكيلوجرام (kg)')),
          const SizedBox(height: 10),
          TextField(controller: _heightCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الطول بالسنتيمتر (cm)')),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _calcBmi, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0077B6), foregroundColor: Colors.white), child: const Text('احسب المؤشر الآن')),
          if (_bmiResult.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF0096C7).withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text(_bmiResult, style: const TextStyle(fontWeight: FontWeight.bold, height: 1.5))),
          ],
        ],
      ),
    );
  }

  Widget _buildVitalsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('تسجيل قراءة الضغط أو السكر', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          TextField(controller: _bpCtrl, decoration: const InputDecoration(labelText: 'القراءة (مثال: 130/85 أو 110 mg/dl)')),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () {
              appController.addVital('ضغط الدم / قياس', _bpCtrl.text, 'تم التسجيل');
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تمت إضافة القراءة إلى السجل بنجاح ✓')));
              setState(() {});
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('حفظ في السجل الحيوي'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
          ),
          const SizedBox(height: 18),
          const Text('السجل الحفظ السابق:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 8),
          ...appController.vitalsLog.map((v) => ListTile(
            dense: true,
            leading: const Icon(Icons.monitor_heart_rounded, color: Color(0xFF0077B6)),
            title: Text('${v['type']}: ${v['val']}'),
            subtitle: Text('الوقت: ${v['date']}'),
            trailing: Chip(label: Text(v['status'], style: const TextStyle(fontSize: 11)), backgroundColor: Colors.green.withOpacity(0.1)),
          )),
        ],
      ),
    );
  }

  Widget _buildLabCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('مفسر التحاليل المخبرية السريع', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _labType,
            items: const [
              DropdownMenuItem(value: 'السكر التراكمي (HbA1c)', child: Text('السكر التراكمي (HbA1c)')),
              DropdownMenuItem(value: 'فيتامين D (Vit D)', child: Text('فيتامين D (Vit D)')),
            ],
            onChanged: (val) => setState(() => _labType = val!),
            decoration: const InputDecoration(labelText: 'نوع التحليل'),
          ),
          const SizedBox(height: 10),
          TextField(controller: _labValCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'الرقم أو النتيجة الرقمية')),
          const SizedBox(height: 14),
          ElevatedButton(onPressed: _interpretLab, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0077B6), foregroundColor: Colors.white), child: const Text('تحليل النتيجة الطبية')),
          if (_labResult.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFF59E0B).withOpacity(0.12), borderRadius: BorderRadius.circular(12)), child: Text(_labResult, style: const TextStyle(fontWeight: FontWeight.bold, height: 1.5))),
          ],
        ],
      ),
    );
  }

  Widget _buildWaterCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0))),
      child: Column(
        children: [
          const Text('عدّاد أكواب الماء اليومي (Hydration Tracker)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(onPressed: () => setState(() => _waterCups = math.max(0, _waterCups - 1)), icon: const Icon(Icons.remove_circle, size: 32, color: Colors.red)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('$_waterCups / 8 أكواب', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0077B6))),
              ),
              IconButton(onPressed: () => setState(() => _waterCups += 1), icon: const Icon(Icons.add_circle, size: 32, color: Colors.green)),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(value: _waterCups / 8, minHeight: 10, borderRadius: BorderRadius.circular(10)),
          const SizedBox(height: 8),
          const Text('حافظ على شرب الماء بانتظام لصحة الكلى ونضارة البشرة.', style: TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildInteractionsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('كاشف التعارضات الدوائية والغذائية الهامة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 12),
          Text('• حبوب الحديد والكالسيوم: لا تتناولها مع الشاي أو القهوة لأنها تمنع الامتصاص.\n• المسكنات (NSAIDs): يفضل أخذها بعد الوجبة تماماً لحماية جدار المعدة.\n• المضادات الحيوية: تجنب منتجات الألبان مع بعض أنواعها كالـ Doxycycline.', style: TextStyle(height: 1.6, fontSize: 13.5)),
        ],
      ),
    );
  }
}

// ================= MedicalStudentHubScreen =================
class MedicalStudentHubScreen extends StatefulWidget {
  final bool embedded;
  const MedicalStudentHubScreen({super.key, this.embedded = false});

  @override
  State<MedicalStudentHubScreen> createState() => _MedicalStudentHubScreenState();
}

class _MedicalStudentHubScreenState extends State<MedicalStudentHubScreen> {
  int _tab = 0;

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
        automaticallyImplyLeading: !widget.embedded,
        title: Text('بوابة طالب الطب والتدريب السريري', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: isDark ? Colors.white : const Color(0xFF0A192F))),
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _tabBtn('مقياس GCS للوعي', 0),
                _tabBtn('اختصارات التذاكر الطبية', 1),
                _tabBtn('منهجية ECG وأشعة الصدر', 2),
                _tabBtn('بطاقات المراجعة (Flashcards)', 3),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_tab == 0) ...[
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('حاسبة غلاسكو للغيبوبة (GCS Score): $totalGcs / 15', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF0077B6))),
                        const SizedBox(height: 14),
                        _gcsDropdown('استجابة العين (Eye - E)', _gcsE, {4: 'عفوية (Spontaneous)', 3: 'للصوت (To Speech)', 2: 'للألم (To Pain)', 1: 'لا توجد (None)'}, (v) => setState(() => _gcsE = v)),
                        _gcsDropdown('الاستجابة اللفظية (Verbal - V)', _gcsV, {5: 'واعي ومنتظم (Oriented)', 4: 'مشتت (Confused)', 3: 'كلمات غير مرتبة (Inappropriate)', 2: 'أصوات غير مفهومة (Incomprehensible)', 1: 'لا توجد (None)'}, (v) => setState(() => _gcsV = v)),
                        _gcsDropdown('الاستجابة الحركية (Motor - M)', _gcsM, {6: 'ينفذ الأوامر (Obeys commands)', 5: 'يحدد مكان الألم (Localizes pain)', 4: 'سحب للألم (Withdrawal)', 3: 'ثني غير طبيعي (Decorticate)', 2: 'بسط غير طبيعي (Decerebrate)', 1: 'لا توجد (None)'}, (v) => setState(() => _gcsM = v)),
                      ],
                    ),
                  ),
                ],
                if (_tab == 1) ...[
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('قاموس الاختصارات الطبية (Medical Abbreviations)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 12),
                        Text('• BID: مرتان يومياً (Twice a day)\n• TID: ثلاث مرات يومياً (Three times a day)\n• QID: أربع مرات يومياً\n• PRN: عند الحاجة (As needed)\n• STAT: فوراً وبشكل عاجل (Immediately)\n• NPO: صائم لا شيء عن طريق الفم (Nothing by mouth)\n• IV / IM: حقن وريدي / حقن عضلي\n• SOB: ضيق التنفس (Shortness of breath)\n• CP: ألم الصدر (Chest pain)', style: TextStyle(height: 1.6, fontSize: 13.5)),
                      ],
                    ),
                  ),
                ],
                if (_tab == 2) ...[
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('منهجية قراءة تخطيط القلب (ECG Interpretation)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0077B6))),
                        SizedBox(height: 8),
                        Text('1. معدل النبض (Rate): احسب المربعات الكبيرة بين قمم R واقسم 300 عليها.\n2. النظم (Rhythm): هل المنتظم (Regular) أم لا؟\n3. موجة P ومحور القلب (Axis).\n4. مركب QRS وقطعة ST (بحثاً عن ارتفاع ST Elevation في جلطات STEMI).\n\nمنهجية أشعة الصدر (Chest X-Ray ABCDEF):\nA: Airways | B: Bones & Soft tissue | C: Cardiac shadow | D: Diaphragm | E: Effusions / Edema | F: Fields (lungs).', style: TextStyle(height: 1.5, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
                if (_tab == 3) ...[
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20), border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0))),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('بطاقات العلامات السريرية (Clinical Flashcards)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 12),
                        Text('• علامة ميرفي (Murphy\'s Sign): إيجابية في التهاب المرارة الحاد (Acute Cholecystitis).\n• علامة مكبرني (McBurney\'s Point): ألم في الربع السفلي الأيمن في التهاب الزائدة الدودية.\n• انعكاس بابينسكي (Babinski Reflex): طبيعي في الرضع، وغير طبيعي (Upgoing) في الآفات العصبية المركزية.', style: TextStyle(height: 1.6, fontSize: 13.5)),
                      ],
                    ),
                  ),
                ],
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
        labelStyle: TextStyle(color: active ? Colors.white : null, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _gcsDropdown(String title, int currentVal, Map<int, String> options, Function(int) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0096C7))),
          const SizedBox(height: 4),
          DropdownButtonFormField<int>(
            value: currentVal,
            items: options.entries.map((e) => DropdownMenuItem(value: e.key, child: Text('${e.key} - ${e.value}', style: const TextStyle(fontSize: 13)))).toList(),
            onChanged: (val) => onChanged(val!),
            decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
          ),
        ],
      ),
    );
  }
}

// ================= ChatScreen =================
class ChatScreen extends StatefulWidget {
  final Map<String, dynamic> chatData;
  final bool embedded;
  final VoidCallback? onOpenSettings;
  const ChatScreen({super.key, required this.chatData, this.embedded = false, this.onOpenSettings});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final List<Map<String, dynamic>> _exchanges = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final initialQ = widget.chatData['question']?.toString() ?? '';
    if (widget.chatData['id'] == 'new' && initialQ.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _send(initialQ));
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
    final hasInitialBuiltInAnswer = widget.chatData['id'] != 'new' && (widget.chatData['question'] as String).isNotEmpty;
    final isNew = !hasInitialBuiltInAnswer && _exchanges.isNotEmpty && !_loading;

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
                  Text(widget.chatData['title'] ?? 'استشارة طبية', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF0A192F))),
                  Row(
                    children: [
                      Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                      const SizedBox(width: 5),
                      Text('متصل • ${appController.selectedModel}', style: const TextStyle(fontSize: 11, color: Color(0xFF10B981), fontWeight: FontWeight.w600)),
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
                widget.chatData['isFavorite'] == true ? Icons.star_rounded : Icons.star_border_rounded,
                color: widget.chatData['isFavorite'] == true ? const Color(0xFFFFB703) : null,
              ),
            ),
          if (_exchanges.isNotEmpty)
            IconButton(
              tooltip: 'محادثة جديدة',
              onPressed: () => setState(() => _exchanges.clear()),
              icon: const Icon(Icons.refresh_rounded, size: 20),
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
                      ..._exchanges.map((ex) => Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Column(
                          children: [
                            _userBubble(ex['question']),
                            const SizedBox(height: 16),
                            _aiBubble(ex, isDark),
                          ],
                        ),
                      )),
                      if (_loading)
                        Padding(
                          padding: const EdgeInsets.all(18),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
                            child: const Row(
                              children: [
                                SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.2, color: Color(0xFF0096C7))),
                                SizedBox(width: 12),
                                Text('جاري تحليل الحالة الطبية...', style: TextStyle(color: Color(0xFF0096C7), fontSize: 13, fontWeight: FontWeight.w600)),
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
      {'t': 'ما هي أعراض ارتفاع ضغط الدم؟', 'sub': 'القلب', 'i': Icons.favorite_rounded, 'c': 0xFFE11D48},
      {'t': 'كيف أقوي الجهاز المناعي؟', 'sub': 'المناعة', 'i': Icons.shield_rounded, 'c': 0xFF10B981},
      {'t': 'ما فائدة فيتامين D؟', 'sub': 'الفيتامينات', 'i': Icons.wb_sunny_rounded, 'c': 0xFFF59E0B},
      {'t': 'ما أسباب الصداع المستمر؟', 'sub': 'الأعصاب', 'i': Icons.psychology_rounded, 'c': 0xFF0096C7},
    ];
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            const MediqLogo(size: 72, showText: false),
            const SizedBox(height: 16),
            Text('كيف يمكنني مساعدتك طبياً اليوم؟', textAlign: TextAlign.center, style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF0A192F))),
            const SizedBox(height: 6),
            const Text('اختر سؤالاً شائعاً أو اكتب استشارتك بالأسفل', style: TextStyle(fontSize: 13.5, color: Color(0xFF64748B))),
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
                      border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: c.withOpacity(0.14), borderRadius: BorderRadius.circular(10)), child: Icon(item['i'] as IconData, color: c, size: 20)),
                        const SizedBox(height: 10),
                        Text(item['sub'] as String, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: c)),
                        const SizedBox(height: 4),
                        Text(item['t'] as String, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, height: 1.35, color: isDark ? Colors.white : const Color(0xFF0A192F))),
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
          gradient: const LinearGradient(colors: [Color(0xFF0077B6), Color(0xFF023E8A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20), bottomLeft: Radius.circular(20), bottomRight: Radius.circular(4)),
        ),
        child: Text(txt, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14, height: 1.45)),
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
        border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const MediqLogo(size: 28, showText: false),
              const SizedBox(width: 8),
              Text('MEDIQ AI PRO', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13.5, color: isDark ? Colors.white : const Color(0xFF0A192F))),
            ],
          ),
          const Divider(height: 22),
          Text(data['answerIntro'], style: TextStyle(fontSize: 14, height: 1.6, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1E293B))),
          const SizedBox(height: 12),
          ...bullets.map((b) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.03) : const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF0096C7), size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text(b, style: TextStyle(fontSize: 13.5, height: 1.5, color: isDark ? Colors.white.withOpacity(0.88) : const Color(0xFF334155)))),
              ],
            ),
          )),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.30)),
            ),
            child: Text(data['footer'], style: TextStyle(fontSize: 12, height: 1.5, fontWeight: FontWeight.w600, color: isDark ? const Color(0xFFFDE68A) : const Color(0xFF92400E))),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _actionBtn(
                icon: Icons.copy_rounded,
                label: 'نسخ التقرير',
                onTap: () {
                  Clipboard.setData(ClipboardData(text: '${data['answerIntro']}\n${bullets.join("\n")}\n${data['footer']}'));
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ الإجابة الطبية ✓')));
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionBtn({required IconData icon, String label = '', bool active = false, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: active ? const Color(0xFF0077B6).withOpacity(0.15) : Colors.grey.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: active ? const Color(0xFF0077B6) : const Color(0xFF64748B)),
            if (label.isNotEmpty) ...[const SizedBox(width: 6), Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))],
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
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF060F1E) : const Color(0xFFF2F6FC),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFDCE4F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.medical_services_outlined, color: Color(0xFF0096C7), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        onSubmitted: (_) => _send(),
                        decoration: const InputDecoration(hintText: 'اكتب سؤالك أو الأعراض الطبية...', border: InputBorder.none),
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
                width: 48, height: 48,
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF00B4D8), Color(0xFF0077B6)]), shape: BoxShape.circle),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= SettingsScreen =================
class SettingsScreen extends StatelessWidget {
  final bool embedded;
  const SettingsScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: !embedded,
        title: Text('الإعدادات والخصوصية الطبية', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF0A192F), fontWeight: FontWeight.w900, fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                const CircleAvatar(radius: 26, backgroundColor: Color(0xFF0077B6), child: Icon(Icons.person_rounded, color: Colors.white, size: 28)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(appController.userName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                      Text(appController.userHandle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _switchTile(context, icon: isDark ? Icons.dark_mode_rounded : Icons.wb_sunny_rounded, title: 'الوضع الداكن المريح', value: isDark, onChanged: (_) => appController.toggleTheme()),
          _tile(context, Icons.text_fields_rounded, 'حجم الخط', appController.fontSizeLabel, appController.cycleFontSize),
          _tile(context, Icons.memory_rounded, 'النموذج الطبي النشط', appController.selectedModel, appController.cycleModel),
          _tile(context, Icons.dns_rounded, 'حالة الخادم المحلي', appController.isLocalServerConnected ? 'متصل ●' : 'متوقف ○', appController.toggleServerStatus),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SplashScreen())),
              leading: const Icon(Icons.restart_alt_rounded, color: Color(0xFFE11D48)),
              title: const Text('إعادة تشغيل النظام', style: TextStyle(color: Color(0xFFE11D48), fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _switchTile(BuildContext context, {required IconData icon, required String title, required bool value, required ValueChanged<bool> onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
      child: SwitchListTile.adaptive(value: value, onChanged: onChanged, activeColor: const Color(0xFF0096C7), secondary: Icon(icon, color: const Color(0xFF0077B6)), title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, String trailing, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: const Color(0xFF0077B6), size: 22),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        trailing: Text(trailing, style: const TextStyle(fontSize: 12.5, color: Color(0xFF0077B6), fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// ================= InfoPanel =================
class InfoPanel extends StatelessWidget {
  const InfoPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: isDark ? [const Color(0xFF102A45), const Color(0xFF0B1C30)] : [const Color(0xFFE0F2FE), const Color(0xFFF0F9FF)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: const [
              Icon(Icons.monitor_heart_rounded, color: Color(0xFF0096C7), size: 44),
              SizedBox(height: 10),
              Text('MEDIQ AI PRO', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
              SizedBox(height: 4),
              Text('منصة الأطباء والطلاب والمريض', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _feat(Icons.medical_services_rounded, 'الحاسبات السريرية', 'GCS, BMI, الجرعات', isDark),
        _feat(Icons.school_rounded, 'بوابة طلاب الطب', 'التخطيط والبطاقات السريرية', isDark),
        _feat(Icons.wifi_off_rounded, 'يعمل بدون إنترنت', 'خصوصية ومعالجة تامة', isDark),
        const SizedBox(height: 20),
        const Center(child: AnimatedEcgWave(width: 170, height: 32, color: Color(0xFF0096C7))),
      ],
    );
  }

  Widget _feat(IconData icon, String title, String sub, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF0096C7).withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: const Color(0xFF0096C7), size: 18)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: isDark ? Colors.white : const Color(0xFF0A192F))),
            Text(sub, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          ])),
        ],
      ),
    );
  }
}

