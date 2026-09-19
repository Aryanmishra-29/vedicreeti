import 'package:flutter/material.dart';
import 'product_detail_screen.dart';
import '../home_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:ui';
import 'dart:math' as math;
class KarmaQuestsScreen extends StatefulWidget {
  final int currentKarma;
  const KarmaQuestsScreen({super.key, required this.currentKarma});
  @override
  State<KarmaQuestsScreen> createState() => _KarmaQuestsScreenState();
}
class _KarmaQuestsScreenState extends State<KarmaQuestsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;
  final Set<String> _completedTaskIds = {};
  final Set<String> _processingTasks = {};
  bool _isLoadingTasks = true;
  final List<Map<String, dynamic>> _mockTasks = [
    {
      'id': 'task_profile',
      'title': 'Complete Spiritual Profile',
      'description': 'Add your Gotra and Rashi to receive personalized recommendations.',
      'karma': 50,
      'icon': Icons.person_add_alt_1_rounded,
      'actionType': 'navigate_profile',
    },
    {
      'id': 'task_wishlist',
      'title': 'Add an item to Divine Wishlist',
      'description': 'Heart your first sacred item.',
      'karma': 20,
      'icon': Icons.favorite_border_rounded,
      'actionType': 'navigate_shop',
    },
    {
      'id': 'task_panchang',
      'title': 'Read Daily Panchang',
      'description': 'Check today\'s auspicious timings.',
      'karma': 10,
      'icon': Icons.calendar_month_rounded,
      'actionType': 'navigate_home',
    },
    {
      'id': 'task_rudraksha',
      'title': 'Purchase First Rudraksha',
      'description': 'Begin your spiritual journey with an authentic Rudraksha.',
      'karma': 200,
      'icon': Icons.shopping_bag_outlined,
      'actionType': 'navigate_product',
    },
    {
      'id': 'task_puja',
      'title': 'Book a Virtual Puja',
      'description': 'Perform a puja remotely with our Vedic Pandits.',
      'karma': 500,
      'icon': Icons.video_call_rounded,
      'actionType': 'navigate_services',
    },
  ];
  @override
  void initState() {
    super.initState();
    _fetchCompletedTasks();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    double targetProgress = 0.0;
    if (widget.currentKarma < 500) {
      targetProgress = widget.currentKarma / 500;
    } else if (widget.currentKarma < 1500) {
      targetProgress = (widget.currentKarma - 500) / 1000;
    } else if (widget.currentKarma < 4000) {
      targetProgress = (widget.currentKarma - 1500) / 2500;
    } else {
      targetProgress = 1.0;
    }
    _progressAnimation = Tween<double>(begin: 0, end: targetProgress).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );
    _progressController.forward();
  }
  Future<void> _fetchCompletedTasks() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        if (mounted) setState(() => _isLoadingTasks = false);
        return;
      }
      final response = await Supabase.instance.client
          .from('user_completed_tasks')
          .select('task_id')
          .eq('user_id', user.id);
      if (mounted) {
        setState(() {
          _completedTaskIds.clear();
          for (var row in response) {
            _completedTaskIds.add(row['task_id'] as String);
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching completed tasks: $e');
    } finally {
      if (mounted) setState(() => _isLoadingTasks = false);
    }
  }
  Future<void> _completeKarmaTask(String taskId, int points) async {
    if (_completedTaskIds.contains(taskId)) return;
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      await Supabase.instance.client.from('user_completed_tasks').insert({
        'user_id': user.id,
        'task_id': taskId,
      });
      final currentMeta = Map<String, dynamic>.from(user.userMetadata ?? {});
      final currentKarma = (currentMeta['karma_points'] as num?)?.toInt() ?? 0;
      final newKarma = currentKarma + points;
      currentMeta['karma_points'] = newKarma;
      await Supabase.instance.client.auth.updateUser(UserAttributes(data: currentMeta));
      if (mounted) {
        setState(() {
          _completedTaskIds.add(taskId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task completed! + Karma', style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.green.shade700,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error completing task: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Network error. Failed to complete task.', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }
  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }
  String _getTierName() {
    if (widget.currentKarma < 500) return 'Silver Devotee';
    if (widget.currentKarma < 1500) return 'Gold Seeker';
    if (widget.currentKarma < 4000) return 'Platinum Disciple';
    return 'Diamond Guru';
  }
  String _getNextTierInfo() {
    if (widget.currentKarma < 500) return '${500 - widget.currentKarma} points to Gold Tier';
    if (widget.currentKarma < 1500) return '${1500 - widget.currentKarma} points to Platinum Tier';
    if (widget.currentKarma < 4000) return '${4000 - widget.currentKarma} points to Diamond Tier';
    return 'Highest tier achieved!';
  }
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Karma Quests',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDarkMode ? const Color(0xFFFDFBF7) : const Color(0xFF2A241D),
            fontFamily: 'Serif',
          ),
        ),
        backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFFFFFFF),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: isDarkMode ? const Color(0xFFFDFBF7) : const Color(0xFF2A241D),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressCard(isDarkMode),
              const SizedBox(height: 32),
              Text(
                'Divine Tasks',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Playfair Display',
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              if (_isLoadingTasks)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
                  ),
                )
              else
                ..._mockTasks.map((task) => _buildQuestTile(task, isDarkMode)),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildProgressCard(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.white.withOpacity(0.03) : const Color(0xFFD4AF37).withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5), width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.stars_rounded, color: Color(0xFFD4AF37), size: 56),
                const SizedBox(height: 16),
                Text(
                  '${widget.currentKarma} Karma Points',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Playfair Display',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getTierName().toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 32),
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.white12 : Colors.black12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: math.max(0.01, _progressAnimation.value),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF9E79F), Color(0xFFD4AF37), Color(0xFFAA7C11)],
                            ),
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD4AF37).withOpacity(0.6),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                ),
                const SizedBox(height: 16),
                Text(
                  _getNextTierInfo(),
                  style: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildQuestTile(Map<String, dynamic> task, bool isDarkMode) {
    final String taskId = task['id'] as String;
    final int points = task['karma'] as int;
    final bool isCompleted = _completedTaskIds.contains(taskId);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.01),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted
              ? const Color(0xFFD4AF37).withOpacity(0.5)
              : (isDarkMode ? Colors.white12 : Colors.black12),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        onLongPress: () async {
          if (!isCompleted && !_processingTasks.contains(taskId)) {
            setState(() => _processingTasks.add(taskId));
            await _completeKarmaTask(taskId, points);
            if (mounted) setState(() => _processingTasks.remove(taskId));
          }
        },
        onTap: () async {
          if (isCompleted || _processingTasks.contains(taskId)) return;
          final actionType = task['actionType'] as String?;
          if (actionType == 'navigate_product') {
            try {
              final product = await Supabase.instance.client
                  .from('products')
                  .select('id')
                  .ilike('name', '%1%mukhi%')
                  .limit(1)
                  .maybeSingle();
              if (mounted) {
                if (product != null && product['id'] != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(productId: product['id'] as String),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Product not found in database.', style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.red.shade700,
                    ),
                  );
                }
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Connection error. Please try again.', style: TextStyle(color: Colors.white)),
                    backgroundColor: Colors.red.shade700,
                  ),
                );
              }
            }
          } else if (actionType == 'navigate_profile') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen(initialIndex: 3)),
              (route) => false,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please complete your profile details here to earn Karma.', style: TextStyle(color: Colors.white)),
                backgroundColor: Color(0xFFD4AF37),
              ),
            );
          } else if (actionType == 'navigate_home') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen(initialIndex: 1)),
              (route) => false,
            );
          } else if (actionType == 'navigate_shop') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const HomeScreen(initialIndex: 2)),
              (route) => false,
            );
          } else if (actionType == 'navigate_services') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Virtual Puja bookings opening soon!', style: TextStyle(color: Colors.white)),
                backgroundColor: Color(0xFFD4AF37),
              ),
            );
          }
        },
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isCompleted
                ? const Color(0xFFD4AF37).withOpacity(0.15)
                : (isDarkMode ? Colors.white12 : Colors.black12),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isCompleted ? Icons.check_circle_rounded : task['icon'] as IconData,
            color: isCompleted ? const Color(0xFFD4AF37) : (isDarkMode ? Colors.white54 : Colors.black54),
          ),
        ),
        title: Text(
          task['title'] as String,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black87,
            decoration: isCompleted ? TextDecoration.lineThrough : null,
            decorationColor: isDarkMode ? Colors.white54 : Colors.black54,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            task['description'] as String,
            style: TextStyle(
              fontSize: 13,
              color: isDarkMode ? Colors.white54 : Colors.black54,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isCompleted
                    ? Colors.transparent
                    : const Color(0xFFD4AF37).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '+${task['karma']}',
                style: TextStyle(
                  color: isCompleted
                      ? (isDarkMode ? Colors.white38 : Colors.black38)
                      : const Color(0xFFD4AF37),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            if (!isCompleted) ...[
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, color: Color(0xFFD4AF37), size: 14),
            ],
          ],
        ),
      ),
    );
  }
}
