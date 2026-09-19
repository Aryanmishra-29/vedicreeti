import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import '../global_audio_service.dart';
class DevotionalAudioPlayerScreen extends StatefulWidget {
  final Map<String, dynamic> audioItem;
  const DevotionalAudioPlayerScreen({super.key, required this.audioItem});
  @override
  State<DevotionalAudioPlayerScreen> createState() => _DevotionalAudioPlayerScreenState();
}
class _DevotionalAudioPlayerScreenState extends State<DevotionalAudioPlayerScreen> with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  bool _isFavorite = false;
  bool _isShuffle = false;
  bool _isRepeat = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  late AnimationController _ambientController;
  late Animation<double> _ambientAnimation;
  void _onIsPlayingChanged() {
    if (mounted) {
      setState(() {
        _isPlaying = GlobalAudioService().isPlayingNotifier.value;
      });
    }
  }
  void _onPositionChanged() {
    if (mounted) {
      setState(() {
        _currentPosition = GlobalAudioService().positionNotifier.value;
      });
    }
  }
  void _onDurationChanged() {
    if (mounted) {
      setState(() {
        _totalDuration = GlobalAudioService().durationNotifier.value;
      });
    }
  }
  @override
  void initState() {
    super.initState();
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _ambientAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _ambientController, curve: Curves.easeInOutSine),
    );
    GlobalAudioService().isPlayingNotifier.addListener(_onIsPlayingChanged);
    GlobalAudioService().positionNotifier.addListener(_onPositionChanged);
    GlobalAudioService().durationNotifier.addListener(_onDurationChanged);
    _isPlaying = GlobalAudioService().isPlayingNotifier.value;
    _currentPosition = GlobalAudioService().positionNotifier.value;
    _totalDuration = GlobalAudioService().durationNotifier.value;
    _isRepeat = GlobalAudioService().player.loopMode == LoopMode.one;
  }
  @override
  void dispose() {
    GlobalAudioService().isPlayingNotifier.removeListener(_onIsPlayingChanged);
    GlobalAudioService().positionNotifier.removeListener(_onPositionChanged);
    GlobalAudioService().durationNotifier.removeListener(_onDurationChanged);
    _ambientController.dispose();
    super.dispose();
  }
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
  void _seek(double value) {
    final position = Duration(seconds: value.toInt());
    GlobalAudioService().player.seek(position);
  }
  void _togglePlayPause() {
    HapticFeedback.lightImpact();
    GlobalAudioService().togglePlayPause();
  }
  @override
  Widget build(BuildContext context) {
    final title = widget.audioItem['title']?.toString() ?? 'Unknown Title';
    final subtitle = widget.audioItem['subtitle']?.toString() ?? 'Traditional';
    final imageUrl = widget.audioItem['image_url']?.toString() ?? 'assets/images/god_ganesh.jpg';
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D), // Premium Dark Divinity
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFFFFD700), size: 32),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Color(0xFFFFD700)),
            onPressed: () {
              HapticFeedback.lightImpact();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _ambientAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _ambientAnimation.value,
                                  child: Container(
                                    width: 280,
                                    height: 280,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          Colors.amber.withOpacity(0.15),
                                          Colors.transparent,
                                        ],
                                        stops: const [0.4, 1.0],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                            Container(
                              width: 320,
                              height: 320,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.amber.withOpacity(0.15),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: imageUrl.startsWith('http')
                                    ? Image.network(imageUrl, fit: BoxFit.cover)
                                    : Image.asset(imageUrl, fit: BoxFit.cover),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: const TextStyle(
                                    color: Color(0xFFFFD700),
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Noto Sans Devanagari',
                                    letterSpacing: 0.5,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  subtitle,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(50),
                              onTap: () {
                                HapticFeedback.selectionClick();
                                setState(() {
                                  _isFavorite = !_isFavorite;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Icon(
                                  _isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                                  color: const Color(0xFFFFD700),
                                  size: 32,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Column(
                        children: [
                          SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 4,
                              activeTrackColor: Colors.transparent, // Handled by container
                              inactiveTrackColor: Colors.white12,
                              thumbColor: const Color(0xFFFFD700),
                              overlayColor: const Color(0xFFFFD700).withOpacity(0.2),
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                            ),
                            child: Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final progress = _totalDuration.inSeconds == 0
                                      ? 0.0
                                      : _currentPosition.inSeconds / _totalDuration.inSeconds;
                                    return Container(
                                      width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                                      height: 4,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(2),
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFFC9922A), Color(0xFFFFD700)],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                Slider(
                                  value: _currentPosition.inSeconds.toDouble().clamp(0.0, _totalDuration.inSeconds.toDouble()),
                                  min: 0.0,
                                  max: _totalDuration.inSeconds.toDouble() > 0 ? _totalDuration.inSeconds.toDouble() : 1.0,
                                  activeColor: Colors.transparent, // Override to show the gradient underneath
                                  onChanged: _seek,
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatDuration(_currentPosition),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 12,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  _formatDuration(_totalDuration),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 12,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(50),
                              onTap: () {
                                HapticFeedback.lightImpact();
                                setState(() => _isShuffle = !_isShuffle);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Icon(
                                  Icons.shuffle_rounded,
                                  color: _isShuffle ? const Color(0xFFFFD700) : Colors.white.withOpacity(0.5),
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(50),
                              onTap: () {
                                HapticFeedback.lightImpact();
                                GlobalAudioService().player.seekToPrevious();
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Icon(
                                  Icons.skip_previous_rounded,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: _togglePlayPause,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFFFD700),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFFD700).withOpacity(0.4),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  color: const Color(0xFF0D0D0D),
                                  size: 42,
                                ),
                              ),
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(50),
                              onTap: () {
                                HapticFeedback.lightImpact();
                                GlobalAudioService().player.seekToNext();
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: Icon(
                                  Icons.skip_next_rounded,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(50),
                              onTap: () {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  _isRepeat = !_isRepeat;
                                  GlobalAudioService().player.setLoopMode(_isRepeat ? LoopMode.one : LoopMode.off);
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Icon(
                                  Icons.repeat_rounded,
                                  color: _isRepeat ? const Color(0xFFFFD700) : Colors.white.withOpacity(0.5),
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
