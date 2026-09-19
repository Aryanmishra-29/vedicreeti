import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'devotional_audio_player_screen.dart';
import '../global_audio_service.dart';
class DevotionalCategoryScreen extends StatefulWidget {
  final String categoryType;
  const DevotionalCategoryScreen({super.key, required this.categoryType});
  @override
  State<DevotionalCategoryScreen> createState() => _DevotionalCategoryScreenState();
}
class _DevotionalCategoryScreenState extends State<DevotionalCategoryScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _devotionals = [];
  @override
  void initState() {
    super.initState();
    _fetchDevotionals();
  }
  Future<void> _fetchDevotionals() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final typeQuery = widget.categoryType.toLowerCase();
      debugPrint('Fetching devotional_content for type: $typeQuery');
      final data = await Supabase.instance.client
          .from('devotional_content')
          .select()
          .eq('type', typeQuery);
      debugPrint('Supabase result for $typeQuery: $data');
      if (mounted) {
        setState(() {
          _devotionals = data.whereType<Map<String, dynamic>>().toList();
                  _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching devotional_content: $e');
      if (mounted) {
        setState(() {
          _devotionals = [];
          _isLoading = false;
        });
      }
    }
  }
  @override
  void dispose() {
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F0F13) : const Color(0xFFFDFBF7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFD4AF37)),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderInfo(context),
              const SizedBox(height: 32),
              Expanded(
                child: _buildDynamicListView(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildHeaderInfo(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.categoryType,
          style: TextStyle(
            color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
            fontSize: 28,
            fontWeight: FontWeight.bold,
            fontFamily: 'Montserrat',
            letterSpacing: 1.0,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.5),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${widget.categoryType.toUpperCase()} LIST',
              style: TextStyle(
                color: const Color(0xFFD4AF37).withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'Montserrat',
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
  Widget _buildDynamicListView(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
    }
    if (_devotionals.isEmpty) {
      return Center(
        child: Text(
          "No ${widget.categoryType} found in database.",
          style: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black54, fontFamily: 'Montserrat'),
        ),
      );
    }
    final placeholderImage = 'assets/images/god_ganesh.jpg';
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: _devotionals.length,
      itemBuilder: (context, index) {
        final item = _devotionals[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E1E24) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDarkMode ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
            boxShadow: [
              BoxShadow(
                color: isDarkMode ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: item['image_url'] != null && item['image_url'].toString().startsWith('http')
                    ? Image.network(
                        item['image_url'].toString(),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        item['image_url']?.toString() ?? placeholderImage,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['title']?.toString() ?? 'Unknown Title',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Montserrat',
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['subtitle']?.toString() ?? '',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white.withOpacity(0.5) : Colors.black54,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      _showLyricsBottomSheet(context, item);
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E), // Dark background matching bottom sheet
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.amber.withOpacity(0.4),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: Colors.amber,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ValueListenableBuilder<Map<String, dynamic>?>(
                    valueListenable: GlobalAudioService().currentItemNotifier,
                    builder: (context, currentItem, _) {
                      return ValueListenableBuilder<bool>(
                        valueListenable: GlobalAudioService().isPlayingNotifier,
                        builder: (context, globalIsPlaying, _) {
                          final isPlaying = currentItem?['audio_url'] == item['audio_url'] && globalIsPlaying;
                          return GestureDetector(
                            onTap: () {
                              GlobalAudioService().playItem(item);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DevotionalAudioPlayerScreen(audioItem: item),
                                ),
                              );
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (item['audio_url'] == null || item['audio_url'].toString().isEmpty)
                                    ? Colors.grey[800]
                                    : const Color(0xFFD4AF37),
                                boxShadow: [
                                  if (!(item['audio_url'] == null || item['audio_url'].toString().isEmpty))
                                    BoxShadow(
                                      color: const Color(0xFFD4AF37).withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                ],
                              ),
                              child: Icon(
                                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
  void _showLyricsBottomSheet(BuildContext context, Map<String, dynamic> item) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Color(0xFFD4AF37),
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(Icons.close_rounded, color: Color(0xFFD4AF37)),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      Center(
                        child: Text(
                          item['title']?.toString() ?? 'Lyrics',
                          style: const TextStyle(
                            color: Color(0xFFD4AF37),
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Noto Sans Devanagari',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Text(
                      item['content']?.toString() ?? item['lyrics']?.toString() ?? 'Lyrics not available.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : const Color(0xFF1A1A1A),
                        fontSize: 18,
                        height: 2.0,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Noto Sans Devanagari',
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
