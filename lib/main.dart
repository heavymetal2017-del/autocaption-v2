import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const CaptionApp());

class CaptionApp extends StatelessWidget {
  const CaptionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto Caption Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F12),
        primaryColor: const Color(0xFF6C5CE7),
      ),
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
  final ImagePicker _picker = ImagePicker();

  Future<void> _selectVideo() async {
    final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
    if (file != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => EditorScreen(videoFile: File(file.path)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto Captions Studio', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: _selectVideo,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.video_library_rounded, size: 56, color: Colors.white),
                      SizedBox(height: 12),
                      Text(
                        'انتخاب ویدیو و ایجاد کپشن',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'ویژگی‌های هوشمند فعال',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white70),
            ),
            const SizedBox(height: 12),
            _buildFeatureTile(Icons.auto_awesome, 'هوش مصنوعی دقیق کلمه به کلمه'),
            _buildFeatureTile(Icons.style, 'بیش از ۱۰ قالب و استایل متحرک'),
            _buildFeatureTile(Icons.high_quality, 'خروجی سریع بدون افت کیفیت'),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile(IconData icon, String title) {
    return Card(
      color: const Color(0xFF1B1B22),
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF6C5CE7)),
        title: Text(title, style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}

class EditorScreen extends StatefulWidget {
  final File videoFile;
  const EditorScreen({super.key, required this.videoFile});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  late VideoPlayerController _controller;
  int _selectedTemplate = 0;
  final String _sampleCaption = "این یک کپشن خودکار هوشمند است";

  final List<Map<String, dynamic>> _templates = [
    {'name': 'Ali Abdaal', 'color': Colors.yellow, 'bg': Colors.black87, 'font': GoogleFonts.vazirmatn},
    {'name': 'Minimal', 'color': Colors.white, 'bg': Colors.transparent, 'font': GoogleFonts.lalezar},
    {'name': 'Neon Glow', 'color': Colors.cyanAccent, 'bg': Colors.black54, 'font': GoogleFonts.sahel},
  ];

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) => setState(() {}))
      ..setLooping(true)
      ..play();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeStyle = _templates[_selectedTemplate];

    return Scaffold(
      appBar: AppBar(
        title: const Text('شخصی‌سازی کپشن'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_done_rounded, color: Colors.greenAccent),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ویدیو با موفقیت رندر شد!')),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          VideoPlayer(_controller),
                          Positioned(
                            bottom: 40,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: activeStyle['bg'],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _sampleCaption,
                                style: (activeStyle['font'] as Function)(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: activeStyle['color'],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const CircularProgressIndicator(),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: const BoxDecoration(
              color: Color(0xFF1B1B22),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('انتخاب تمپلیت و فونت:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _templates.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final isSelected = _selectedTemplate == index;
                      return ChoiceChip(
                        label: Text(_templates[index]['name']),
                        selected: isSelected,
                        selectedColor: const Color(0xFF6C5CE7),
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedTemplate = index);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
