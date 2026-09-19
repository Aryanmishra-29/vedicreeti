import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/devotional_audio_player_screen.dart';
class AartiScreen extends StatefulWidget {
  final String type;
  final String deity;
  const AartiScreen({
    super.key,
    this.type = 'aarti',
    this.deity = 'Ganesh',
  });
  @override
  State<AartiScreen> createState() => _AartiScreenState();
}
class _AartiScreenState extends State<AartiScreen> {
  final bool _isPlaying = false;
  double _currentProgress = 0.3; // 30% placeholder
  bool _isLoading = true;
  String _lyrics = '';
  String _title = '';
  Map<String, dynamic>? _contentItem;
  final supabase = Supabase.instance.client;
  @override
  void initState() {
    super.initState();
    _loadContent();
  }
  Future<void> _loadContent() async {
    try {
      final data = await fetchContent(widget.type, widget.deity);
      if (mounted) {
        setState(() {
          if (data.isNotEmpty) {
            _contentItem = data.first;
            _lyrics = data.first['content']?.toString() ?? 'Content not available.';
            _title = data.first['title']?.toString() ?? 'श्री गणेश आरती';
          } else {
            _lyrics = 'No content found for ${widget.deity} ${widget.type}.';
            _title = 'Not Found';
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _lyrics = 'Error loading content: $e';
          _isLoading = false;
        });
      }
    }
  }
  Future<List<Map<String, dynamic>>> fetchContent(String type, String deity) async {
    try {
      final typeQuery = type.toLowerCase();
      final deityQuery = deity;
      debugPrint('Fetching devotional_content for type: $typeQuery, deity: $deityQuery');
      final response = await supabase
          .from('devotional_content')
          .select('*')
          .eq('type', typeQuery)
          .eq('deity', deityQuery);
      debugPrint('Supabase result: $response');
      return (response as List).whereType<Map<String, dynamic>>().toList();
    } catch (e) {
      debugPrint('Error fetching devotional_content: $e');
      rethrow;
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _isLoading ? 'Loading...' : _title,
          style: const TextStyle(
            color: Color(0xFF2A241D),
            fontSize: 24,
            fontWeight: FontWeight.bold,
            fontFamily: 'Serif',
            letterSpacing: 1.2,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2A241D)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFC9922A)))
          : Column(
              children: [
                const SizedBox(height: 16),
                _buildAudioPlayerCard(),
                const SizedBox(height: 24),
                _buildLyricsArea(),
              ],
            ),
    );
  }
  Widget _buildAudioPlayerCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFFFF),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFE7D8B1),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '01:12',
                      style: TextStyle(
                        color: Color(0xFF6B6258),
                        fontSize: 14,
                        fontFamily: 'Serif',
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        if (_contentItem != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DevotionalAudioPlayerScreen(item: _contentItem!),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Audio data not available.')),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFE8520A).withOpacity(0.15),
                          border: Border.all(
                            color: const Color(0xFFE8520A), // Saffron border
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE8520A).withOpacity(0.4), // Saffron glow
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                    const Text(
                      '04:30',
                      style: TextStyle(
                        color: Color(0xFF6B6258),
                        fontSize: 14,
                        fontFamily: 'Serif',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SliderTheme(
                  data: SliderThemeData(
                    trackHeight: 4,
                    activeTrackColor: const Color(0xFFE8520A), // Saffron track
                    inactiveTrackColor: const Color(0xFFE7D8B1),
                    thumbColor: const Color(0xFFC9922A), // Gold thumb
                    overlayColor: const Color(0xFFE8520A).withOpacity(0.2),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                  ),
                  child: Slider(
                    value: _currentProgress,
                    onChanged: (value) {
                      setState(() {
                        _currentProgress = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildLyricsArea() {
    return Expanded(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Center(
          child: Text(
            _lyrics,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF2A241D),
              fontSize: 22,
              height: 2.0, // High line-height for readability
              fontWeight: FontWeight.w600,
              fontFamily: 'Noto Sans Devanagari', // Fits the theme
            ),
          ),
        ),
      ),
    );
  }
}
