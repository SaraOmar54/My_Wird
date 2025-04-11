import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'package:logger/logger.dart';

final logger = Logger();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'الورد اليومي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Amiri',
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2E7D32),
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 30,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF388E3C),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 5, // إضافة ظل
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 24, fontFamily: 'Amiri', height: 2),
          displayLarge: TextStyle(fontSize: 36, fontFamily: 'Amiri', fontWeight: FontWeight.bold),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الورد اليومي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFF1F8E9)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Lottie.asset(
                  'assets/lottie/mamafatma.json',
                  height: 300,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DailyQuranPage(),
                    ),
                  );
                },
                child: const Text(
                  'قراءة الورد اليومي',
                  style: TextStyle(fontSize: 22, color: Colors.white),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'هدية من الحاجة فطيم الأمير',
                style: TextStyle(fontSize: 24, fontFamily: 'Amiri', color: Color.fromARGB(255, 0, 0, 0)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DailyQuranPage extends StatefulWidget {
  const DailyQuranPage({super.key});

  @override
  State<DailyQuranPage> createState() => _DailyQuranPageState();
}

class _DailyQuranPageState extends State<DailyQuranPage> {
  List<dynamic> allAyahs = [];
  int currentPage = 1;

  @override
  void initState() {
    super.initState();
    loadLastPage();
    fetchQuran();
  }

  Future<void> fetchQuran() async {
    try {
      final url = Uri.parse('https://api.alquran.cloud/v1/quran/quran-uthmani');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> ayahs = [];
        for (var surah in data['data']['surahs']) {
          for (var ayah in surah['ayahs']) {
            ayah['surahName'] = surah['englishName'];
            ayah['surahArabic'] = surah['name'];
            ayah['page'] = ayah['page'];
            ayahs.add(ayah);
          }
        }
        setState(() {
          allAyahs = ayahs;
        });
      } else {
        logger.e('Failed to load Quran data: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء تحميل البيانات')),
        );
      }
    } catch (e) {
      logger.e('Error fetching Quran data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تأكد من اتصالك بالإنترنت')),
      );
    }
  }

  Future<void> saveLastPage(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastPage', page);
  }

  Future<void> loadLastPage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentPage = prefs.getInt('lastPage') ?? 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dailyPages = List.generate(3, (index) => currentPage + index);
    final dailyAyahs = allAyahs
        .where((ayah) => dailyPages.contains(ayah['page']))
        .toList();
    final currentSurah =
        dailyAyahs.isNotEmpty ? dailyAyahs.first['surahArabic'] : '';

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(currentSurah),
        ),
        body: allAyahs.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: dailyAyahs.length,
                itemBuilder: (context, index) {
                  final ayah = dailyAyahs[index];
                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: [
                                    TextSpan(
                                      text: '${ayah['text']} ',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        height: 2,
                                        fontFamily: 'Amiri',
                                        color: Colors.black87,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '﴾${ayah['numberInSurah']}﴿',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Amiri',
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'الصفحة $currentPage',
                style: const TextStyle(fontSize: 18),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('السابق'),
                    onPressed: () {
                      if (currentPage > 1) {
                        setState(() {
                          currentPage = ((currentPage - 1 - 3) ~/ 3) * 3 + 1;
                          saveLastPage(currentPage);
                        });
                      }
                    },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.bookmark),
                    label: const Text('حفظ'),
                    onPressed: () {
                      saveLastPage(currentPage);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم الحفظ')),
                      );
                    },
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('التالي'),
                    onPressed: () {
                      setState(() {
                        currentPage = ((currentPage - 1) ~/ 3 + 1) * 3 + 1;
                        saveLastPage(currentPage);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('أحسنت! لقد انتهيت من قرأءة الوِرد اليومي'),
                          ),
                        );
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'الإعدادات قادمة قريباً...',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}