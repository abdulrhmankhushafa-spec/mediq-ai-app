import 'package:flutter/material.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0284C7)),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Map<String, String>> _medicalChats = [
    {
      'title': 'أعراض مرض السكري',
      'subtitle': 'العطش الشديد، التبوّل المتكرر، والإرهاق.',
      'time': '09:24 م',
    },
    {
      'title': 'أسباب التهاب المعدة',
      'subtitle': 'العدوى البكتيرية والمسكنات والأطعمة الحارة.',
      'time': 'أمس',
    },
    {
      'title': 'أعراض فقر الدم (الأنيميا)',
      'subtitle': 'شحوب الجلد، التعب المستمر، والدوخة.',
      'time': 'أمس',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF0284C7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            const Text(
              'MEDIQ AI',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('النموذج المحلي متصل بنجاح (Llama 3.1) ✓')),
              );
            },
            icon: const Icon(Icons.dns_rounded, color: Color(0xFF0284C7)),
          ),
        ],
      ),
      body: _currentIndex == 0 ? _buildHomeBody() : _buildSettingsBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: const Color(0xFF0284C7),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_rounded),
            label: 'المحادثات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_rounded),
            label: 'الإعدادات',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeBody() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'مساعدك الطبي الذكي محلياً',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6),
              Text(
                'احصل على إجابات طبية دقيقة وموثوقة بدون إنترنت وبسرعة فائقة.',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'المحادثات الأخيرة',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 10),
        ..._medicalChats.map((chat) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2)),
            ],
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.medical_services_rounded, color: Color(0xFF0284C7)),
            ),
            title: Text(chat['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text(chat['subtitle']!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            trailing: Text(chat['time']!, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('فتح محادثة: ${chat['title']}')),
              );
            },
          ),
        )),
      ],
    );
  }

  Widget _buildSettingsBody() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'إعدادات التطبيق',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              const ListTile(
                leading: Icon(Icons.memory_rounded, color: Color(0xFF0284C7)),
                title: Text('النموذج النشط'),
                trailing: Text('Llama 3.1 (8B)', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0284C7))),
              ),
              const Divider(height: 1),
              const ListTile(
                leading: Icon(Icons.dns_rounded, color: Color(0xFF0284C7)),
                title: Text('حالة الخادم المحلي'),
                trailing: Text('متصل ●', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

