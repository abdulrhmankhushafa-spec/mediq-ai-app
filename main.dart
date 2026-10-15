import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
  String userName = 'مستخدم';
  String userHandle = 'mediq_user';
  String searchQuery = '';
  bool showFavoritesOnly = false;

  double get fontScale {
    switch (fontSizeLabel) {
      case 'صغير': return 0.88;
      case 'كبير': return 1.15;
      default: return 1.0;
    }
  }

  final List<Map<String, dynamic>> chats = [
    {
      'id': 'diabetes',
      'title': 'معلومات عن السكري',
      'subtitle': 'السكري هو اضطراب في استقلاب الجلوكوز...',
      'time': 'اليوم 09:24',
      'icon': Icons.water_drop_rounded,
      'isFavorite': true,
      'question': 'ما هي أعراض مرض السكري؟',
      'answerIntro': 'مرض السكري هو اضطراب في استقلاب الجلوكوز في الجسم، ويؤدي إلى ارتفاع مستوى السكر في الدم. من أبرز أعراضه:',
      'bullets': [
        'زيادة العطش وجفاف الفم المستمر.',
        'كثرة التبول خاصة خلال ساعات الليل.',
        'الجوع الشديد رغم تناول وجبات طعام كافية.',
        'فقدان الوزن غير المبرر وبدون حمية.',
        'الإرهاق العام وتشوش الرؤية المؤقت.',
      ],
      'footer': 'من المهم استشارة الطبيب وإجراء فحص السكر التراكمي (HbA1c) للتشخيص الدقيق.',
    },
    {
      'id': 'gastritis',
      'title': 'أعراض التهاب المعدة',
      'subtitle': 'التهاب المعدة يسبب ألماً في الجزء العلوي...',
      'time': 'أمس 16:45',
      'icon': Icons.medical_information_rounded,
      'isFavorite': false,
      'question': 'ما هي أسباب التهاب المعدة؟',
      'answerIntro': 'التهاب المعدة يمكن أن يحدث نتيجة عدة عوامل أساسية، منها:',
      'bullets': [
        '1. العدوى بجرثومة المعدة (هيليكوباكتر بيلوري).',
        '2. الإفراط في تناول المسكنات ومضادات الالتهاب.',
        '3. الضغط النفسي الشديد والتوتر العصبي.',
        '4. تناول الأطعمة الحارة أو الدهنية بكثرة.',
      ],
      'footer': 'للحصول على تشخيص دقيق ووصفة علاجية، يرجى مراجعة الطبيب المختص.',
    },
  ];

  List<Map<String, dynamic>> get filteredChats {
    return chats.where((chat) {
      final matchesSearch = searchQuery.isEmpty ||
          chat['title'].toString().contains(searchQuery) ||
          chat['subtitle'].toString().contains(searchQuery);
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
    selectedModel = selectedModel.contains('3.1') ? 'Meditron (7B)' : 'Llama 3.1 (8B)';
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
  void setSearchQuery(q) { searchQuery = q; notifyListeners(); }
  void setShowFavoritesOnly(v) { showFavoritesOnly = v; notifyListeners(); }
  void updateUserProfile(n, h) { if(n.isNotEmpty) userName=n; if(h.isNotEmpty) userHandle=h; notifyListeners(); }

  Map<String, dynamic> generateReply(String q) {
    return {
      'id': 'chat_${DateTime.now().millisecondsSinceEpoch}',
      'title': q.length > 25 ? '${q.substring(0, 25)}...' : q,
      'subtitle': 'إجابة تحليلية من المساعد الطبي المحلي...',
      'time': 'الآن',
      'icon': Icons.health_and_safety_rounded,
      'isFavorite': false,
      'question': q,
      'answerIntro': 'بناءً على المعطيات الطبية لنموذج ($selectedModel) حول "$q":',
      'bullets': [
        'مراقبة الأعراض والراحة التامة للجسد.',
        'الإكثار من السوائل والعصائر الطبيعية.',
        'استشارة الطبيب فوراً في حال استمرار الأعراض.',
      ],
      'footer': 'تنبيه: هذه المعلومات تثقيفية ولا تغني عن استشارة الطبيب.',
    };
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
            scaffoldBackgroundColor: const Color(0xFFF4F7FC),
            primaryColor: const Color(0xFF0066CC),
            cardColor: Colors.white,
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0066CC),
              secondary: Color(0xFF00C6FF),
              surface: Colors.white,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF040E18),
            primaryColor: const Color(0xFF00A8FF),
            cardColor: const Color(0xFF0B1D30),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00A8FF),
              secondary: Color(0xFF00E1FF),
              surface: Color(0xFF0B1D30),
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
            borderRadius: BorderRadius.circular(size * 0.28),
            gradient: const LinearGradient(
              colors: [Color(0xFF00E1FF), Color(0xFF0055CC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00C6FF).withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(Icons.psychology_alt_rounded, color: Colors.white.withOpacity(0.25), size: size * 0.75),
              Container(
                width: size * 0.52,
                height: size * 0.52,
                decoration: const BoxDecoration(
                  color: Color(0xFF061526),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.add_rounded, color: Colors.white, size: size * 0.35),
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
                  style: TextStyle(fontSize: size * 0.42, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  children: [
                    TextSpan(text: 'MEDIQ ', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF061526))),
                    const TextSpan(text: 'AI', style: TextStyle(color: Color(0xFF00C6FF))),
                  ],
                ),
              ),
              Text(
                'مساعدك الطبي الذكي',
                style: TextStyle(fontSize: size * 0.24, color: isDark ? Colors.white70 : const Color(0xFF5A7184), fontWeight: FontWeight.w600),
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
  const AnimatedEcgWave({super.key, this.width = 220, this.height = 45, this.color = const Color(0xFF00E1FF)});

  @override
  State<AnimatedEcgWave> createState() => _AnimatedEcgWaveState();
}

class _AnimatedEcgWaveState extends State<AnimatedEcgWave> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(painter: EcgPainter(progress: _ctrl.value, color: widget.color)),
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
    final paintBase = Paint()..color = color.withOpacity(0.2)..strokeWidth = 2..style = PaintingStyle.stroke;
    final paintGlow = Paint()..color = color..strokeWidth = 2.5..style = PaintingStyle.stroke;

    final path = Path();
    final mid = size.height / 2;
    path.moveTo(0, mid);
    path.lineTo(size.width * 0.3, mid);
    path.lineTo(size.width * 0.36, mid - 6);
    path.lineTo(size.width * 0.41, mid + 6);
    path.lineTo(size.width * 0.46, mid - 24);
    path.lineTo(size.width * 0.51, mid + 20);
    path.lineTo(size.width * 0.57, mid - 8);
    path.lineTo(size.width * 0.63, mid);
    path.lineTo(size.width, mid);

    canvas.drawPath(path, paintBase);
    final metric = path.computeMetrics().first;
    final len = metric.length * 0.35;
    final start = (metric.length * progress) - (len / 2);
    final extract = metric.extractPath(math.max(0, start), math.min(metric.length, start + len));
    canvas.drawPath(extract, paintGlow);
  }
  @override
  bool shouldRepaint(covariant EcgPainter old) => old.progress != progress;
}

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
            gradient: LinearGradient(
              colors: [Color(0xFF030D19), Color(0xFF09243E), Color(0xFF030D19)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                const MediqLogo(size: 130, showText: false),
                const SizedBox(height: 28),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 1.2),
                    children: [
                      TextSpan(text: 'MEDIQ ', style: TextStyle(color: Colors.white)),
                      TextSpan(text: 'AI', style: TextStyle(color: Color(0xFF00E1FF))),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Your Medical AI Assistant', style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 24),
                const Text('اسأل ... افهم ... تعلّم', style: TextStyle(color: Color(0xFF00E1FF), fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                const AnimatedEcgWave(width: 240, height: 45),
                const Spacer(flex: 2),
                const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF00E1FF))),
                const SizedBox(height: 16),
                const Text('جاري تهيئة المساعد الطبي الذكي...', style: TextStyle(color: Colors.white60, fontSize: 13)),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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

  void _newChat() {
    final newChat = {'id': 'new', 'title': 'محادثة جديدة', 'question': '', 'answerIntro': '', 'bullets': <String>[], 'footer': ''};
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

    if (isDesktop) {
      final activeChat = appController.chats.firstWhere(
        (c) => c['id'] == (_selectedChatId ?? 'anemia'),
        orElse: () => {'id': 'new', 'title': 'محادثة جديدة', 'question': '', 'answerIntro': '', 'bullets': <String>[], 'footer': ''},
      );
      return Scaffold(
        body: Row(
          children: [
            SizedBox(width: 280, child: SidebarDrawer(onNewChat: _newChat, onSelectSettings: () => setState(() => _navIndex = 3), onSelectHome: () => {appController.setShowFavoritesOnly(false), setState(() => _navIndex = 0)}, onSelectFav: () => {appController.setShowFavoritesOnly(true), setState(() => _navIndex = 0)})),
            Expanded(
              flex: 3,
              child: _navIndex == 3
                  ? const SettingsScreen(embedded: true)
                  : _navIndex == 0
                      ? HomeScreen(onOpenChat: _openChat, onNewChat: _newChat)
                      : ChatScreen(chatData: activeChat, embedded: true, onOpenSettings: () => setState(() => _navIndex = 3)),
            ),
            Container(
              width: 310,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF091828) : const Color(0xFFF8FAFC),
                border: Border(right: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200)),
              ),
              child: const InfoPanel(),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      drawer: Drawer(
        backgroundColor: const Color(0xFF051220),
        child: SidebarDrawer(
          onNewChat: () { Navigator.pop(context); _newChat(); },
          onSelectSettings: () { Navigator.pop(context); setState(() => _navIndex = 3); },
          onSelectHome: () { Navigator.pop(context); appController.setShowFavoritesOnly(false); setState(() => _navIndex = 0); },
          onSelectFav: () { Navigator.pop(context); appController.setShowFavoritesOnly(true); setState(() => _navIndex = 0); },
        ),
      ),
      body: IndexedStack(
        index: _navIndex,
        children: [
          HomeScreen(onOpenChat: _openChat, onNewChat: _newChat),
          ChatScreen(chatData: const {'id': 'new', 'title': 'استكشاف الأسئلة', 'question': '', 'answerIntro': '', 'bullets': <String>[], 'footer': ''}, embedded: true),
          ChatScreen(chatData: appController.chats.isNotEmpty ? appController.chats.first : {'id': 'new', 'title': 'محادثة جديدة', 'question': '', 'answerIntro': '', 'bullets': <String>[], 'footer': ''}, embedded: true),
          const SettingsScreen(embedded: true),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
        type: BottomNavigationBarType.fixed,
        backgroundColor: isDark ? const Color(0xFF081726) : Colors.white,
        selectedItemColor: const Color(0xFF0066CC),
        unselectedItemColor: const Color(0xFF7A8FA6),
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.lightbulb_outline_rounded), label: 'استكشاف'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_rounded), label: 'المحادثات'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'الإعدادات'),
        ],
      ),
    );
  }
}

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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Scaffold.maybeOf(context)?.openDrawer(),
                  child: const CircleAvatar(
                    radius: 19,
                    backgroundColor: Color(0xFF061626),
                    child: Icon(Icons.person_rounded, color: Color(0xFF00E1FF)),
                  ),
                ),
                const MediqLogo(size: 38),
                IconButton(
                  onPressed: () => Scaffold.maybeOf(context)?.openDrawer(),
                  icon: Icon(Icons.menu_open_rounded, color: isDark ? Colors.white : const Color(0xFF061626), size: 28),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                InkWell(
                  onTap: () => appController.toggleServerStatus(),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark ? [const Color(0xFF0C2540), const Color(0xFF061526)] : [const Color(0xFFE3F2FD), const Color(0xFFF4F9FD)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF0078D4).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 12, height: 12,
                          decoration: BoxDecoration(
                            color: appController.isLocalServerConnected ? const Color(0xFF10B981) : Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appController.isLocalServerConnected ? 'يعمل محلياً (${appController.selectedModel})' : 'الخادم المحلي متوقف',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : const Color(0xFF061626)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                appController.isLocalServerConnected ? 'المساعد الطبي متصل وجاهز للرد الفوري' : 'اضغط لإعادة الاتصال بالخادم',
                                style: TextStyle(fontSize: 11.5, color: isDark ? Colors.white70 : const Color(0xFF5A7184)),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.dns_rounded, color: Color(0xFF0078D4), size: 24),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3))],
                  ),
                  child: TextField(
                    onChanged: appController.setSearchQuery,
                    decoration: InputDecoration(
                      hintText: 'ابحث في المحادثات الطبية...',
                      hintStyle: const TextStyle(color: Color(0xFF9FB1C1), fontSize: 14),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0066CC)),
                      suffixIcon: appController.searchQuery.isNotEmpty
                          ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => appController.setSearchQuery(''))
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: onNewChat,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF0078D4), Color(0xFF004BA0)]),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: const Color(0xFF0078D4).withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 5))],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Icon(Icons.add_rounded, color: Colors.white, size: 24),
                        Text('محادثة طبية جديدة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(width: 24),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      appController.showFavoritesOnly ? 'المحادثات المفضلة ⭐' : 'المحادثات الأخيرة',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF061626)),
                    ),
                    TextButton.icon(
                      onPressed: () => appController.setShowFavoritesOnly(!appController.showFavoritesOnly),
                      icon: Icon(appController.showFavoritesOnly ? Icons.list_rounded : Icons.star_rounded, size: 18),
                      label: Text(appController.showFavoritesOnly ? 'عرض الكل' : 'المفضلة فقط', style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (chats.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(child: Text('لا توجد محادثات مطابقة', style: TextStyle(color: Colors.grey))),
                  ),
                ...chats.map((chat) {
                  final isFav = chat['isFavorite'] == true;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 3))],
                    ),
                    child: ListTile(
                      onTap: () => onOpenChat(chat),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF103154) : const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(chat['icon'] as IconData, color: const Color(0xFF0078D4), size: 26),
                      ),
                      title: Text(chat['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: isDark ? Colors.white : const Color(0xFF061626))),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(chat['subtitle'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Color(0xFF7A8FA6))),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(chat['time'], style: const TextStyle(fontSize: 10.5, color: Color(0xFF9FB1C1))),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () => appController.toggleFavorite(chat['id']),
                            child: Icon(isFav ? Icons.star_rounded : Icons.star_border_rounded, color: isFav ? Colors.amber : Colors.grey, size: 20),
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

class SidebarDrawer extends StatelessWidget {
  final VoidCallback onNewChat;
  final VoidCallback onSelectSettings;
  final VoidCallback onSelectHome;
  final VoidCallback onSelectFav;

  const SidebarDrawer({super.key, required this.onNewChat, required this.onSelectSettings, required this.onSelectHome, required this.onSelectFav});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF051220),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: MediqLogo(size: 40, forceDark: true),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(14),
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
                          Text(appController.userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(appController.userHandle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              InkWell(
                onTap: onNewChat,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF0078D4), Color(0xFF004BA0)]),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.chat_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 12),
                      Expanded(child: Text('محادثة جديدة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14))),
                      Icon(Icons.add_rounded, color: Colors.white, size: 22),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _item(Icons.history_rounded, 'المحادثات السابقة', onSelectHome),
              _item(Icons.search_rounded, 'البحث في المحادثات', onSelectHome),
              _item(Icons.star_border_rounded, 'المفضلة', onSelectFav),
              _item(Icons.menu_book_rounded, 'المعلومات الطبية', onSelectHome),
              _item(Icons.settings_outlined, 'الإعدادات', onSelectSettings),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B1E33),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF00C6FF).withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(width: 9, height: 9, decoration: BoxDecoration(color: appController.isLocalServerConnected ? const Color(0xFF10B981) : Colors.orange, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Text(appController.isLocalServerConnected ? 'يعمل محلياً' : 'غير متصل', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 13)),
                        const Spacer(),
                        const Icon(Icons.wifi_off_rounded, color: Colors.white54, size: 18),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text('النموذج متصل بالشبكة المحلية (بدون إنترنت)', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.memory_rounded, color: Color(0xFF00C6FF), size: 20),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('النموذج المستخدم', style: TextStyle(color: Colors.white70, fontSize: 10)),
                        Text(appController.selectedModel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('MEDIQ AI v1.0.0', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  Icon(Icons.verified_rounded, color: Colors.white38, size: 15),
                ],
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
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.white70, size: 21),
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14)),
    );
  }
}

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
  int _reaction = 0;

  void _send([String? preset]) async {
    final txt = preset ?? _ctrl.text.trim();
    if (txt.isEmpty || _loading) return;
    _ctrl.clear();
    setState(() => _loading = true);

    await Future.delayed(const Duration(milliseconds: 700));
    final reply = appController.generateReply(txt);
    if (mounted) setState(() { _loading = false; _exchanges.add(reply); });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isNew = widget.chatData['id'] == 'new' && _exchanges.isEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).cardColor,
        elevation: 0.5,
        automaticallyImplyLeading: !widget.embedded,
        title: Row(
          children: [
            const MediqLogo(size: 34, showText: false),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.chatData['title'] ?? 'محادثة طبية', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF061626))),
                  Row(
                    children: [
                      Container(width: 7, height: 7, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                      const SizedBox(width: 5),
                      Text('متصل محلياً • ${appController.selectedModel}', style: const TextStyle(fontSize: 11, color: Color(0xFF10B981))),
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
              onPressed: () => appController.toggleFavorite(widget.chatData['id']),
              icon: Icon(
                widget.chatData['isFavorite'] == true ? Icons.star_rounded : Icons.star_border_rounded,
                color: widget.chatData['isFavorite'] == true ? Colors.amber : null,
              ),
            ),
          if (widget.onOpenSettings != null)
            IconButton(onPressed: widget.onOpenSettings, icon: const Icon(Icons.settings_outlined)),
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
                      if ((widget.chatData['question'] as String).isNotEmpty) ...[
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
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Row(
                            children: [
                              SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                              SizedBox(width: 12),
                              Text('جاري تحليل السؤال الطبي...', style: TextStyle(color: Color(0xFF0078D4), fontSize: 13)),
                            ],
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
      {'t': 'ما هي أعراض\nارتفاع ضغط الدم؟', 'i': Icons.favorite_border_rounded},
      {'t': 'كيف يعمل\nالجهاز المناعي؟', 'i': Icons.shield_outlined},
      {'t': 'ما فائدة فيتامين\nD للجسم؟', 'i': Icons.wb_sunny_outlined},
      {'t': 'ما أسباب الصداع\nالمستمر؟', 'i': Icons.psychology_outlined},
    ];
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const MediqLogo(size: 70, showText: false),
            const SizedBox(height: 14),
            Text('MEDIQ AI', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: isDark ? Colors.white : const Color(0xFF061626))),
            const Text('مساعدك الطبي الذكي', style: TextStyle(fontSize: 14, color: Color(0xFF5A7184))),
            const SizedBox(height: 24),
            Text('كيف يمكنني مساعدتك اليوم؟', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF061626))),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: list.map((item) => InkWell(
                onTap: () => _send((item['t'] as String).replaceAll('\n', ' ')),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 160,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(item['i'] as IconData, color: const Color(0xFF0078D4), size: 24),
                      const SizedBox(height: 12),
                      Text(item['t'] as String, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF061626))),
                    ],
                  ),
                ),
              )).toList(),
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
        constraints: const BoxConstraints(maxWidth: 330),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          color: Color(0xFFD0EBFF),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(18),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(txt, style: const TextStyle(color: Color(0xFF061626), fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 4),
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.done_all_rounded, size: 14, color: Color(0xFF0078D4)),
                SizedBox(width: 4),
                Text('09:24 م', style: TextStyle(fontSize: 10, color: Color(0xFF5A7184))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _aiBubble(Map<String, dynamic> data, bool isDark) {
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
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('MEDIQ AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : const Color(0xFF061626))),
                    const SizedBox(width: 8),
                    const Text('10:25 م', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(data['answerIntro'], style: TextStyle(fontSize: 14, height: 1.6, color: isDark ? Colors.white : const Color(0xFF1E293B))),
                const SizedBox(height: 12),
                ...bullets.map((b) => Padding(
                  padding: const EdgeInsets.only(bottom: 8, right: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: Color(0xFF0078D4), fontWeight: FontWeight.bold, fontSize: 16)),
                      Expanded(child: Text(b, style: TextStyle(fontSize: 13.5, height: 1.5, color: isDark ? Colors.white70 : const Color(0xFF334155)))),
                    ],
                  ),
                )),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF102C48) : const Color(0xFFF0F7FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF0078D4).withOpacity(0.2)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_rounded, color: Color(0xFF0078D4), size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(data['footer'], style: TextStyle(fontSize: 12.5, height: 1.5, color: isDark ? Colors.white : const Color(0xFF061626)))),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _actionBtn(
                      icon: _reaction == 1 ? Icons.thumb_up_alt_rounded : Icons.thumb_up_alt_outlined,
                      active: _reaction == 1,
                      onTap: () => setState(() => _reaction = _reaction == 1 ? 0 : 1),
                    ),
                    _actionBtn(
                      icon: _reaction == -1 ? Icons.thumb_down_alt_rounded : Icons.thumb_down_alt_outlined,
                      active: _reaction == -1,
                      onTap: () => setState(() => _reaction = _reaction == -1 ? 0 : -1),
                    ),
                    _actionBtn(
                      icon: Icons.copy_rounded,
                      label: 'نسخ الإجابة',
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: '${data['answerIntro']}\n${bullets.join("\n")}'));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ الإجابة بنجاح ✓'), duration: Duration(seconds: 2)));
                      },
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

  Widget _actionBtn({required IconData icon, String label = '', bool active = false, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF0078D4).withOpacity(0.15) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? const Color(0xFF0078D4) : Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: active ? const Color(0xFF0078D4) : const Color(0xFF5A7184)),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _inputBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            InkWell(
              onTap: () => _send(),
              borderRadius: BorderRadius.circular(30),
              child: Container(
                width: 46, height: 46,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(colors: [Color(0xFF0088FF), Color(0xFF0055CC)]),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF040E18) : const Color(0xFFF4F7FC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        onSubmitted: (_) => _send(),
                        decoration: const InputDecoration(
                          hintText: 'اكتب سؤالك الطبي هنا...',
                          hintStyle: TextStyle(color: Color(0xFF9FB1C1), fontSize: 13.5),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.mic_none_rounded, color: Color(0xFF5A7184), size: 20)),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.image_outlined, color: Color(0xFF5A7184), size: 20)),
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
        title: Text('الإعدادات', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF061626), fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(radius: 24, backgroundColor: Color(0xFF0078D4), child: Icon(Icons.person, color: Colors.white, size: 28)),
              title: Text(appController.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(appController.userHandle, style: const TextStyle(color: Color(0xFF7A8FA6), fontSize: 13)),
              trailing: const Icon(Icons.edit_outlined, size: 18, color: Color(0xFF0078D4)),
            ),
          ),
          const SizedBox(height: 24),
          const Text('إعدادات التطبيق', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          _tile(context, isDark ? Icons.dark_mode_outlined : Icons.wb_sunny_outlined, 'المظهر', isDark ? 'الوضع الداكن' : 'الوضع الفاتح', appController.toggleTheme),
          _tile(context, Icons.language_rounded, 'اللغة', appController.language, () {}),
          _tile(context, Icons.text_fields_rounded, 'حجم الخط', appController.fontSizeLabel, appController.cycleFontSize),
          _tile(context, Icons.save_outlined, 'حفظ المحادثات', appController.saveChats ? 'تفعيل' : 'إيقاف', appController.toggleSaveChats),
          _tile(context, Icons.notifications_none_rounded, 'الإشعارات', appController.notificationsEnabled ? 'تفعيل' : 'إيقاف', appController.toggleNotifications),
          const SizedBox(height: 20),
          const Text('معلومات النموذج المحلي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          _tile(context, Icons.memory_rounded, 'اسم النموذج', appController.selectedModel, appController.cycleModel),
          _tile(context, Icons.dns_outlined, 'حالة الخادم', appController.isLocalServerConnected ? 'متصل ●' : 'غير متصل ○', appController.toggleServerStatus),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(14)),
            child: ListTile(
              onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SplashScreen())),
              leading: const Icon(Icons.logout_rounded, color: Color(0xFFE11D48)),
              title: const Text('إعادة التشغيل', style: TextStyle(color: Color(0xFFE11D48), fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String title, String trailing, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: const Color(0xFF0078D4), size: 22),
        title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(trailing, style: const TextStyle(fontSize: 13, color: Color(0xFF0078D4), fontWeight: FontWeight.bold)),
            const SizedBox(width: 6),
            const Icon(Icons.sync_alt_rounded, size: 15, color: Color(0xFF9FB1C1)),
          ],
        ),
      ),
    );
  }
}

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
            color: isDark ? const Color(0xFF102C48) : const Color(0xFFEBF5FF),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              const Icon(Icons.monitor_heart_rounded, color: Color(0xFF00B4DB), size: 48),
              const SizedBox(height: 12),
              Text('مساعدك الطبي الذكي', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF061626))),
              const SizedBox(height: 6),
              const Text('إجابات دقيقة وموثوقة لأسئلتك الطبية.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, color: Color(0xFF5A7184))),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _feat(Icons.verified_user_outlined, 'معلومات موثوقة', 'مبنية على مصادر طبية معتمدة', isDark),
        _feat(Icons.language_rounded, 'اللغة العربية', 'تواصل بسهولة بلغتك الأم', isDark),
        _feat(Icons.wifi_tethering_off_rounded, 'يعمل محلياً', 'بدون الحاجة للإنترنت', isDark),
        _feat(Icons.lock_outline_rounded, 'خصوصية تامة', 'لا يتم إرسال بياناتك لأي جهة', isDark),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF102C48) : const Color(0xFFE6F3FF),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF0078D4).withOpacity(0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.info_outline, color: Color(0xFF0078D4), size: 20),
                  SizedBox(width: 8),
                  Text('تنويه مهم', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0078D4), fontSize: 14)),
                ],
              ),
              const SizedBox(height: 10),
              Text('المعلومات المقدمة للتثقيف الطبي فقط، ولا تغني عن استشارة الطبيب المختص.', style: TextStyle(fontSize: 12, height: 1.6, color: isDark ? Colors.white70 : const Color(0xFF061626))),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Center(child: AnimatedEcgWave(width: 180, height: 32, color: Color(0xFF0078D4))),
        const SizedBox(height: 8),
        Center(child: Text('معاً نحو صحة أفضل', style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF061626), fontSize: 13))),
        const SizedBox(height: 12),
        const Center(child: MediqLogo(size: 36, showText: true)),
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
            decoration: BoxDecoration(color: isDark ? const Color(0xFF102C48) : const Color(0xFFE6F4FA), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: const Color(0xFF0078D4), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isDark ? Colors.white : const Color(0xFF061626))),
                Text(sub, style: const TextStyle(fontSize: 11.5, color: Color(0xFF7A8FA6))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
