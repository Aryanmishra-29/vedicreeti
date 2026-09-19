import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/wishlist_screen.dart';
import 'screens/karma_quests_screen.dart';
import 'widgets/luxury_page_route.dart';
import 'widgets/spiritual_profile_sheet.dart';
import 'widgets/address_skeleton_card.dart';
import 'auth_bottom_sheet.dart';
import 'splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'utils/localization_helper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}
class _ProfileScreenState extends State<ProfileScreen> {
  final bool _notificationsEnabled = true;
  StreamSubscription<AuthState>? _authSubscription;
  @override
  void initState() {
    super.initState();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      if (mounted) setState(() {});
    });
  }
  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
  void _navigateToDetail(BuildContext context, String title) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      LuxuryPageRoute(page: ProfileDetailScreen(title: title)),
    );
  }
  void _showLogoutDialog(BuildContext context) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFC9922A).withOpacity(0.3),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.logout_rounded,
                      color: Color(0xFFC9922A),
                      size: 48,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Logout',
                      style: TextStyle(
                        color: Color(0xFFC9922A),
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Serif',
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Are you sure you want to log out of VedicReeti?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 15,
                        fontWeight: FontWeight.w300,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white.withOpacity(0.6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(fontSize: 14, letterSpacing: 1.0),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFE8520A).withOpacity(0.2),
                                blurRadius: 15,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                HapticFeedback.lightImpact();
                                Navigator.of(context).pop();
                                await Supabase.instance.client.auth.signOut();
                                if (mounted) setState(() {});
                              },
                              splashColor: const Color(
                                0xFFE8520A,
                              ).withOpacity(0.15),
                              highlightColor: const Color(
                                0xFFC9922A,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(30),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFE8520A,
                                  ).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(30),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFE8520A,
                                    ).withOpacity(0.5),
                                    width: 0.5,
                                  ),
                                ),
                                child: const Text(
                                  'Yes, Logout',
                                  style: TextStyle(
                                    color: Color(0xFFE8520A),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  void _showDeleteAccountDialog(BuildContext context) {
    HapticFeedback.heavyImpact();
    final passwordController = TextEditingController();
    bool isDeleting = false;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            title: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Warning: This action is permanent. Your data will be erased, and you will have to sign up again from scratch to access the platform if you proceed.',
                  style: TextStyle(color: Colors.redAccent),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter your password to confirm',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                    filled: true,
                    fillColor: Colors.black,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel', style: TextStyle(color: Colors.white)),
              ),
              if (isDeleting)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.redAccent, strokeWidth: 2),
                  ),
                )
              else
                TextButton(
                  onPressed: () async {
                    if (passwordController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Incorrect password. Account deletion aborted.'), backgroundColor: Colors.redAccent),
                      );
                      return;
                    }
                    setState(() => isDeleting = true);
                    try {
                      final user = Supabase.instance.client.auth.currentUser;
                      if (user?.email == null) throw Exception("User email not found");
                      try {
                        await Supabase.instance.client.auth.signInWithPassword(
                          email: user!.email!,
                          password: passwordController.text.trim(),
                        );
                      } on AuthException catch (e) {
                        if (e.message.contains('Invalid login credentials')) {
                          if (context.mounted) {
                            setState(() => isDeleting = false);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Incorrect password. Account deletion aborted.'), backgroundColor: Colors.redAccent),
                            );
                          }
                          return;
                        }
                      }
                      try {
                        await Supabase.instance.client.rpc('delete_user');
                      } catch (rpcError) {
                        debugPrint('Supabase RPC delete_user failed: $rpcError');
                      }
                      await Supabase.instance.client.auth.signOut(scope: SignOutScope.global);
                      try {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear();
                      } catch (e) {
                        debugPrint('Error clearing SharedPreferences: $e');
                      }
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (_) => const SplashScreen()),
                          (route) => false,
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        setState(() => isDeleting = false);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Account deletion aborted: ${e.toString()}'), backgroundColor: Colors.redAccent),
                        );
                      }
                    }
                  },
                  child: const Text('Delete', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                ),
            ],
          );
        });
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final isLoggedIn = user != null;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'profile.title'.tr(),
          style: const TextStyle(
            color: Color(0xFF2A241D),
            fontFamily: 'Serif',
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF2A241D)),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: isLoggedIn
            ? _buildAuthenticatedView(user)
            : _buildUnauthenticatedView(),
      ),
    );
  }
  Widget _buildUnauthenticatedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock_person_rounded,
              color: Color(0xFFD4AF37),
              size: 64,
            ),
            const SizedBox(height: 24),
            Text(
              'profile.login_prompt'.tr(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF6B6258),
                fontSize: 16,
                fontWeight: FontWeight.w500,
                height: 1.6,
                fontFamily: 'Serif',
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                AuthBottomSheet.show(context);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFD4AF37).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  'profile.login_btn'.tr(),
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildAuthenticatedView(User user) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      children: [
        _buildSpiritualIdentityHeader(user),
        const SizedBox(height: 32),
        _buildVipTierCard(user),
        const SizedBox(height: 48),
        Text(
          'ui.the_sacred_hub'.tr(),
          style: const TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.5,
          ),
        ),
        const SizedBox(height: 16),
        _buildSacredHubList(),
        const SizedBox(height: 48),
        _buildFooter(),
        const SizedBox(height: 24),
      ],
    );
  }
  Widget _buildSpiritualIdentityHeader(User user) {
    final metadata = user.userMetadata ?? {};
    final name = metadata['full_name'] ?? metadata['name'] ?? metadata['user_name'];
    final displayName = (name != null && name.toString().trim().isNotEmpty) ? name.toString().trim() : 'Devotee';
    final email = user.email ?? '';
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final String? gotra = metadata['gotra']?.toString().trim();
    final String? rashi = metadata['rashi']?.toString().trim();
    final bool hasSpiritualProfile = gotra != null && gotra.isNotEmpty && rashi != null && rashi.isNotEmpty;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5), width: 1.0),
          ),
          child: const CircleAvatar(
            radius: 40,
            backgroundColor: Color(0xFF1A1A1A),
            child: Icon(Icons.person, color: Color(0xFFD4AF37), size: 40),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          displayName,
          style: TextStyle(
            color: isDarkMode ? const Color(0xFFFDFBF7) : const Color(0xFF1A1A1A),
            fontSize: 26,
            fontWeight: FontWeight.w600,
            fontFamily: 'Playfair Display',
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: TextStyle(
            color: isDarkMode ? Colors.white54 : Colors.black54,
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () => _showLogoutDialog(context),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(60, 32),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                side: BorderSide(color: isDarkMode ? Colors.white24 : Colors.black26, width: 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Logout', style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87, fontSize: 12, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () => _showDeleteAccountDialog(context),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(60, 32),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                side: BorderSide(color: const Color(0xFFE57373).withOpacity(0.5), width: 1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Delete', style: TextStyle(color: Color(0xFFE57373), fontSize: 12, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (hasSpiritualProfile)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12.0,
            runSpacing: 12.0,
            children: [
              _buildSpiritualTag(Icons.history_edu_rounded, 'Gotra: $gotra', isDarkMode),
              _buildSpiritualTag(Icons.nightlight_round, 'Rashi: $rashi', isDarkMode),
            ],
          )
        else
          _buildCompleteProfileButton(isDarkMode),
      ],
    );
  }
  Widget _buildCompleteProfileButton(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            SpiritualProfileSheet.show(context, () async {
              await Supabase.instance.client.auth.refreshSession();
              if (mounted) setState(() {});
            });
          },
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  isDarkMode ? Colors.white.withOpacity(0.1) : const Color(0xFFD4AF37).withOpacity(0.1),
                  isDarkMode ? Colors.white.withOpacity(0.05) : const Color(0xFFD4AF37).withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.6), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, color: Color(0xFFD4AF37), size: 16),
                const SizedBox(width: 8),
                Text(
                  'Complete Spiritual Profile (+50 Karma)',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildSpiritualTag(IconData icon, String text, bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.white.withOpacity(0.05) : const Color(0xFFD4AF37).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFD4AF37)),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildVipTierCard(User user) {
    final metadata = user.userMetadata ?? {};
    final int karma = (metadata['karma_points'] as num?)?.toInt() ?? 0;
    String tierName = 'ui.silver_devotee'.tr();
    String nextTierText = '';
    double progress = 0.0;
    if (karma < 500) {
      tierName = 'ui.silver_devotee'.tr();
      nextTierText = '${500 - karma} ${'ui.points_to_gold_tier'.tr()}';
      progress = karma / 500.0;
    } else if (karma < 1500) {
      tierName = 'Gold Seeker';
      nextTierText = '${1500 - karma} points to Platinum Tier';
      progress = (karma - 500) / 1000.0;
    } else if (karma < 4000) {
      tierName = 'Platinum Disciple';
      nextTierText = '${4000 - karma} points to Diamond Tier';
      progress = (karma - 1500) / 2500.0;
    } else {
      tierName = 'Diamond Guru';
      nextTierText = 'Highest tier achieved!';
      progress = 1.0;
    }
    if (progress < 0.01) progress = 0.01; // Minimum visibility
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.push(
                  context,
                  LuxuryPageRoute(page: KarmaQuestsScreen(currentKarma: karma)),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.white.withOpacity(0.03) : const Color(0xFFD4AF37).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.5), width: 1),
                ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('ui.loyalty_tier'.tr(),
                            style: TextStyle(
                              color: Color(0xFFD4AF37),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tierName,
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black87,
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Playfair Display',
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF9E79F), Color(0xFFD4AF37), Color(0xFFAA7C11)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD4AF37).withOpacity(0.4),
                              blurRadius: 15,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.workspace_premium, color: Colors.white, size: 28),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ui.karma_points'.tr(),
                        style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54, fontSize: 13),
                      ),
                      Text(
                        '',
                        style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 6,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.white12 : Colors.black12,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF9E79F), Color(0xFFD4AF37), Color(0xFFAA7C11)],
                          ),
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFD4AF37).withOpacity(0.6),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        nextTierText,
                        style: TextStyle(color: isDarkMode ? Colors.white38 : Colors.black38, fontSize: 11),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'ui.view_tasks_rewards'.tr(),
                            style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 12, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_ios, color: Color(0xFFD4AF37), size: 10),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
  Widget _buildSacredHubList() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        _buildLuxuryListTile(
          icon: Icons.shopping_bag_outlined,
          title: 'ui.sacred_acquisitions'.tr(),
          subtitle: 'ui.my_orders_bookings'.tr(),
          isDarkMode: isDarkMode,
          onTap: () {
            HapticFeedback.lightImpact();
            _navigateToDetail(context, 'My Puja Bookings');
          },
        ),
        const SizedBox(height: 12),
        _buildLuxuryListTile(
          icon: Icons.favorite_border_rounded,
          title: 'ui.divine_wishlist'.tr(),
          subtitle: 'ui.saved_products_pujas'.tr(),
          isDarkMode: isDarkMode,
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const WishlistScreen()),
            );
          },
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFFD4AF37), Color(0xFFFFF2CD), Color(0xFFD4AF37)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.1),
                blurRadius: 8,
              ),
            ],
          ),
          padding: const EdgeInsets.all(1.0),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  leading: const Icon(Icons.support_agent_rounded, color: Color(0xFFD4AF37), size: 28),
                  title: Text(
                    'ui.vedic_concierge'.tr(),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  subtitle: Text(
                    'ui.premium_support_chat'.tr(),
                    style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 12),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFFD4AF37), size: 16),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _navigateToDetail(context, 'Contact Support');
                  },
                ),
              ),
        ),
        const SizedBox(height: 12),
        _buildLuxuryListTile(
          icon: Icons.tune_rounded,
          title: 'settings.app_preferences'.tr(),
          subtitle: 'ui.theme_notifications'.tr(),
          isDarkMode: isDarkMode,
          onTap: () {
            HapticFeedback.lightImpact();
            _navigateToDetail(context, 'App Preferences');
          },
        ),
      ],
    );
  }
  Widget _buildLuxuryListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDarkMode ? Colors.white12 : Colors.black12,
            width: 1,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Icon(icon, color: isDarkMode ? Colors.white70 : Colors.black87, size: 24),
          title: Text(
            title,
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black87,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black54, fontSize: 12),
          ),
          trailing: Icon(Icons.arrow_forward_ios_rounded, color: isDarkMode ? Colors.white38 : Colors.black38, size: 14),
        ),
      ),
    );
  }
  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 50,
            height: 1,
            color: const Color(0xFFC9922A).withOpacity(0.2),
          ),
          const SizedBox(height: 16),
          Text(
            'ui.app_developed_by'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xFFC9922A).withOpacity(0.4),
              fontSize: 11,
              fontWeight: FontWeight.w300,
              fontStyle: FontStyle.italic,
              letterSpacing: 1.0,
              fontFamily: 'Serif',
            ),
          ),
        ],
      ),
    );
  }
}
class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;
  final Widget? trailingOverride;
  _MenuItem({
    required this.icon,
    required this.title,
    this.onTap,
    this.trailingOverride,
  });
}
class ProfileDetailScreen extends StatefulWidget {
  final String title;
  const ProfileDetailScreen({super.key, required this.title});
  @override
  State<ProfileDetailScreen> createState() => _ProfileDetailScreenState();
}
class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  final String _selectedLanguage = 'English (US)';
  final TextEditingController _addressController = TextEditingController();
  String? newlySelectedLang;
  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: bgColor, // Sleek mix
        elevation: 0,
        title: Text(
          widget.title == 'App Preferences' ? 'settings.app_preferences'.tr() : widget.title,
          style: const TextStyle(
            color: Color(0xFFD4AF37), // Champagne Gold
            fontFamily: 'Serif',
            fontWeight: FontWeight.w500,
            letterSpacing: 1.0,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFFD4AF37)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFFD4AF37).withOpacity(0.2),
            height: 0.3, // Ultra-thin hairline divider
          ),
        ),
      ),
      body: Container(
        color: bgColor,
        child: _buildBody(context),
      ),
      bottomNavigationBar: (newlySelectedLang != null && newlySelectedLang != context.locale.languageCode)
        ? Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: () async {
                final String targetLangCode = newlySelectedLang ?? 'en';
                final newLocale = Locale(targetLangCode);
                await context.setLocale(newLocale);
                if (!context.mounted) return;
                setState(() { newlySelectedLang = null; });
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Save & Apply', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          )
        : const SizedBox.shrink(),
    );
  }
  Widget _buildBody(BuildContext context) {
    switch (widget.title) {
      case 'My Puja Bookings':
        return _buildPujaBookings();
      case 'Wallet & Payments':
        return _buildWalletPayments();
      case 'Saved Addresses':
        return _buildSavedAddresses();
      case 'App Preferences':
        return _buildAppPreferences();
      case 'Contact Support':
        return _buildContactSupport();
      case 'Terms & Privacy':
        return _buildTermsPrivacy();
      default:
        return _buildGeneric();
    }
  }
  Widget _buildPujaBookings() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return const SizedBox.shrink();
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Supabase.instance.client
          .from('bookings')
          .stream(primaryKey: ['id'])
          .eq('user_id', user.id)
          .order('created_at', ascending: false),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
          );
        }
        final bookings = snapshot.data ?? [];
        if (bookings.isEmpty) {
          return Center(
            child: Text(
              'No bookings found.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54), fontSize: 16),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: bookings.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final b = bookings[index];
            final date = DateTime.parse(
              b['date_time'].toString(),
            ).toLocal().toString().split(' ')[0];
            return _buildBookingTicket(
              getLocalizedText(b['service_name'] ?? b['title'] ?? 'Unknown', context.locale.languageCode),
              date,
              b['pandit_name'] ?? 'Assigned',
              b['status'] ?? 'Confirmed',
            );
          },
        );
      },
    );
  }
  Widget _buildBookingTicket(
    String title,
    String date,
    String pandit,
    String status,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.3),
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD4AF37).withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Serif',
                  letterSpacing: 1.0,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withOpacity(0.5),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.24), height: 1, thickness: 0.3),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.calendar_month_rounded,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Date: $date',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person_rounded, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54), size: 16),
              const SizedBox(width: 8),
              Text(
                'Pandit Ji: $pandit',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7), fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildWalletPayments() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return const SizedBox.shrink();
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: Supabase.instance.client
          .from('user_wallets')
          .stream(primaryKey: ['user_id'])
          .eq('user_id', user.id),
      builder: (context, walletSnapshot) {
        final walletData = walletSnapshot.data?.firstOrNull;
        final balance = walletData?['balance'] ?? 0.0;
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: Supabase.instance.client
              .from('wallet_transactions')
              .stream(primaryKey: ['id'])
              .eq('user_id', user.id)
              .order('created_at', ascending: false),
          builder: (context, txSnapshot) {
            if (txSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37)));
            }
            if (txSnapshot.hasError) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Failed to load transaction history.', style: TextStyle(color: Colors.redAccent)),
                ),
              );
            }
            final transactions = txSnapshot.data ?? [];
            return ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: const RadialGradient(
                      colors: [Color(0xFFD4AF37), Colors.transparent],
                      radius: 2.0,
                    ),
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withOpacity(0.4),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'profile.wallet.balance'.tr(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${balance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Serif',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'profile.wallet.saved_methods'.tr(),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 16),
                StreamBuilder<List<Map<String, dynamic>>>(
                  stream: Supabase.instance.client
                      .from('user_payment_methods')
                      .stream(primaryKey: ['id'])
                      .eq('user_id', user.id),
                  builder: (context, methodsSnapshot) {
                    if (methodsSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFD4AF37),
                        ),
                      );
                    }
                    if (methodsSnapshot.hasError) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text('Failed to load payment methods.', style: TextStyle(color: Colors.redAccent)),
                        ),
                      );
                    }
                    final methods = methodsSnapshot.data ?? [];
                    if (methods.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          'No saved payment methods linked yet.',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 14,
                            fontFamily: 'Serif',
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: methods.map((m) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: _buildListTile(
                            m['type'] == 'UPI'
                                ? Icons.account_balance_rounded
                                : Icons.credit_card_rounded,
                            m['title'] ?? 'Unknown Method',
                            m['subtitle'] ?? '',
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                const SizedBox(height: 40),
                Text(
                  'profile.wallet.transactions'.tr(),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 16),
                if (transactions.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No transactions yet.',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  ),
                ...transactions.map((tx) {
                  final isDebit = tx['is_debit'] == true;
                  final sign = isDebit ? '-' : '+';
                  return Column(
                    children: [
                      _buildTransaction(
                        tx['title'] ?? 'Transaction',
                        '$sign ₹${tx['amount']}',
                        tx['created_at'].toString().split(' ')[0],
                        isDebit,
                      ),
                      const Divider(
                        color: Colors.white24,
                        height: 24,
                        thickness: 0.3,
                      ),
                    ],
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }
  Widget _buildListTile(IconData icon, String title, String subtitle) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFFD4AF37), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white54, fontSize: 13),
      ),
    );
  }
  Widget _buildTransaction(
    String title,
    String amount,
    String date,
    bool isDebit,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              date,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        Text(
          amount,
          style: TextStyle(
            color: isDebit ? Colors.white : const Color(0xFFD4AF37),
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  Widget _buildSavedAddresses() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return const SizedBox.shrink();
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: Supabase.instance.client
          .from('user_addresses')
          .select()
          .eq('user_id', user.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Address functionality coming soon...'))
                    );
                  },
                  icon: const Icon(Icons.add_location_alt_rounded, color: Color(0xFFD4AF37)),
                  label: const Text('+ Add New Address', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: 2,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) => const AddressSkeletonCard(),
                ),
              ),
            ],
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Failed to load saved addresses. Please try again.', style: TextStyle(color: Colors.redAccent.withOpacity(0.8))),
            ),
          );
        }
        final addresses = snapshot.data ?? [];
        if (addresses.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.location_off_rounded,
                  color: Color(0xFFD4AF37),
                  size: 48,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No saved addresses found.',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 16,
                    fontFamily: 'Serif',
                  ),
                ),
                const SizedBox(height: 32),
                OutlinedButton.icon(
                  onPressed: _showAddAddressBottomSheet,
                  icon: const Icon(
                    Icons.add_location_alt_rounded,
                    color: Color(0xFFD4AF37),
                  ),
                  label: const Text(
                    '+ Add New Address',
                    style: TextStyle(
                      color: Color(0xFFD4AF37),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: const Color(0xFFD4AF37).withOpacity(0.5),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: OutlinedButton.icon(
                onPressed: _showAddAddressBottomSheet,
                icon: const Icon(Icons.add_location_alt_rounded, color: Color(0xFFD4AF37)),
                label: const Text('+ Add New Address', style: TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                itemCount: addresses.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final a = addresses[index];
                  return _buildAddressCard(
                    a['id']?.toString() ?? '',
                    a['tag'] ?? 'Address',
                    a['full_address'] ?? '',
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
  void _showAddAddressBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add New Address',
                style: TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Serif',
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _addressController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter your full address...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFD4AF37)),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    final user = Supabase.instance.client.auth.currentUser;
                    if (user == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('कृपया पहले लॉग इन करें!', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          backgroundColor: Color(0xFFD4AF37),
                        ),
                      );
                      return;
                    }
                    final addressText = _addressController.text.trim();
                    if (addressText.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('कृपया अपना पता दर्ज करें', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          backgroundColor: Color(0xFFD4AF37),
                        ),
                      );
                      return;
                    }
                    try {
                      await Supabase.instance.client.from('user_addresses').upsert({
                        'user_id': user.id,
                        'user_email': user.email,
                        'full_address': addressText,
                        'tag': 'Home',
                        'updated_at': DateTime.now().toIso8601String(),
                      });
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('पता सफलतापूर्वक सहेज लिया गया है!', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                            backgroundColor: Color(0xFFD4AF37),
                          ),
                        );
                        _addressController.clear();
                        Navigator.pop(context);
                        setState(() {});
                      }
                    } catch (error) {
                      debugPrint('Error saving address: $error');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $error', style: const TextStyle(color: Colors.white)),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  child: const Text(
                    'Save Address',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
  Widget _buildAddressCard(String addressId, String tag, String address) {
    IconData getIconForTag(String t) {
      final lower = t.toLowerCase();
      if (lower.contains('home')) return Icons.home_rounded;
      if (lower.contains('work') || lower.contains('office')) return Icons.work_rounded;
      return Icons.location_on_rounded;
    }
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24), // Charcoal background
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4AF37).withOpacity(0.3), width: 1), // Subtle gold border
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            getIconForTag(tag),
            color: const Color(0xFFD4AF37),
            size: 28,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tag.isNotEmpty ? tag : 'Address',
                  style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    fontFamily: 'Serif',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  address,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Colors.redAccent,
              size: 20,
            ),
            onPressed: () async {
              if (addressId.isEmpty) return;
              try {
                await Supabase.instance.client
                    .from('user_addresses')
                    .delete()
                    .eq('id', addressId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('पता सफलतापूर्वक हटा दिया गया है!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  setState(() {});
                }
              } catch (error) {
                debugPrint('Error deleting address: $error');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $error', style: const TextStyle(color: Colors.white)),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
  Widget _buildAppPreferences() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          'settings.app_language'.tr(),
          style: const TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 16),
        _buildLanguageOption('English (US)', 'en', 'A'),
        const SizedBox(height: 12),
        _buildLanguageOption('हिन्दी (Hindi)', 'hi', 'अ'),
        const SizedBox(height: 12),
        _buildLanguageOption('मराठी (Marathi)', 'mr', 'म'),
        const SizedBox(height: 12),
        _buildLanguageOption('ગુજરાતી (Gujarati)', 'gu', 'ગુ'),
        const SizedBox(height: 12),
        _buildLanguageOption('বাংলা (Bengali)', 'bn', 'অ'),
        const SizedBox(height: 12),
        _buildLanguageOption('தமிழ் (Tamil)', 'ta', 'த'),
        const SizedBox(height: 12),
        _buildLanguageOption('తెలుగు (Telugu)', 'te', 'తె'),
        const SizedBox(height: 12),
        _buildLanguageOption('ಕನ್ನಡ (Kannada)', 'kn', 'ಕ'),
        const SizedBox(height: 12),
        _buildLanguageOption('മലയാളം (Malayalam)', 'ml', 'മ'),
        const SizedBox(height: 12),
        _buildLanguageOption('ਪੰਜਾਬੀ (Punjabi)', 'pa', 'ਪ'),
        const SizedBox(height: 48),
        Text(
          'settings.alarm_settings'.tr(),
          style: const TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 16),
        _buildCustomRingtoneTile(),
      ],
    );
  }
  Widget _buildCustomRingtoneTile() {
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final prefs = snapshot.data!;
        final customPath = prefs.getString('custom_alarm_path');
        final hasCustomPath = customPath != null && customPath.isNotEmpty;
        final fileName = hasCustomPath ? customPath.split('/').last : 'settings.default_flute'.tr();
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.03),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.24),
              width: 0.3,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: const Icon(Icons.music_note_rounded, color: Color(0xFFD4AF37)),
            title: Text(
              'settings.custom_reminder_sound'.tr(),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              fileName,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6), fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: hasCustomPath
                ? IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () async {
                      await prefs.remove('custom_alarm_path');
                      if (mounted) setState(() {});
                    },
                  )
                : const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFFD4AF37)),
            onTap: () async {
              try {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.audio,
                  allowMultiple: false,
                );
                if (result != null && result.files.single.path != null) {
                  await prefs.setString('custom_alarm_path', result.files.single.path!);
                  if (mounted) setState(() {});
                }
              } catch (e) {
                debugPrint('File picker error: $e');
              }
            },
          ),
        );
      },
    );
  }
  Widget _buildLanguageOption(String lang, String code, String iconChar) {
    bool isSelected = newlySelectedLang == code || (newlySelectedLang == null && context.locale.languageCode == code);
    return GestureDetector(
      onTap: () {
        setState(() {
          newlySelectedLang = code;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFD4AF37).withOpacity(0.05)
              : Theme.of(context).colorScheme.onSurface.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFD4AF37) : Theme.of(context).colorScheme.onSurface.withOpacity(0.24),
            width: isSelected ? 0.8 : 0.3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFD4AF37).withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFFD4AF37).withOpacity(0.2),
              radius: 20,
              child: Text(
                iconChar,
                style: const TextStyle(
                  color: Color(0xFFD4AF37),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                lang,
                style: TextStyle(
                  color: isSelected ? const Color(0xFFD4AF37) : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFFD4AF37),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
  Widget _buildContactSupport() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  final Uri url = Uri.parse('https://wa.me/918080909201');
                  try {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Could not launch WhatsApp')),
                      );
                    }
                  }
                },
                child: _buildSupportCard(
                  Icons.chat_bubble_outline_rounded,
                  'Instant Chat Support',
                  'WhatsApp Concierge',
                  true,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  final Uri url = Uri.parse('tel:+918080909201');
                  try {
                    await launchUrl(url);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Calling not supported on this device.')),
                      );
                    }
                  }
                },
                child: _buildSupportCard(
                  Icons.phone_in_talk_outlined,
                  'Call Support',
                  '24/7 Helpline',
                  false,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () async {
            HapticFeedback.lightImpact();
            final Uri emailLaunchUri = Uri(
              scheme: 'mailto',
              path: 'vedicreeti@gmail.com',
              queryParameters: {
                'subject': 'Support Token - VedicReeti',
              },
            );
            try {
              await launchUrl(emailLaunchUri);
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No email client found on this device.')),
                );
              }
            }
          },
          child: _buildSupportCard(
            Icons.email_outlined,
            'Raise a Token',
            'Email Request',
            false,
          ),
        ),
        const SizedBox(height: 48),
        Text(
          'FREQUENTLY ASKED QUESTIONS',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
            fontSize: 12,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 16),
        _buildFaqItem(
          'How do I cancel a booking?',
          'Bookings can be cancelled up to 24 hours prior to the scheduled muhurat without any penalty.',
        ),
        Divider(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.24), height: 1, thickness: 0.3),
        _buildFaqItem(
          'Are the Pandits verified?',
          'Yes, all our Acharyas undergo a rigorous 4-step Vedic background verification process.',
        ),
      ],
    );
  }
  Widget _buildSupportCard(
    IconData icon,
    String title,
    String subtitle,
    bool isChat,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD4AF37).withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: isChat ? Colors.greenAccent : const Color(0xFFD4AF37),
            size: 28,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54), fontSize: 11),
          ),
        ],
      ),
    );
  }
  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      iconColor: const Color(0xFFD4AF37),
      collapsedIconColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
      title: Text(
        question,
        style: TextStyle(color: Theme.of(context).colorScheme.onSurface, fontSize: 14),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Text(
            answer,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.54),
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildTermsPrivacy() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Terms of Service & Privacy Policy',
          style: TextStyle(
            color: Color(0xFFD4AF37),
            fontSize: 20,
            fontFamily: 'Serif',
          ),
        ),
        const SizedBox(height: 24),
        _buildTermsSection(
          '1. Information Collection',
          'We collect necessary information such as your name, contact details, and spiritual preferences to curate a personalized divine experience. Your data is strictly secured and never shared with third-party marketers.',
        ),
        const SizedBox(height: 24),
        _buildTermsSection(
          '2. Divine Service Guidelines',
          'Our Acharyas operate on strict adherence to the Vedic muhurats. Clients are expected to be prepared at the given location at least 15 minutes prior to the commencement of the sankalpa.',
        ),
        const SizedBox(height: 24),
        _buildTermsSection(
          '3. Payment & Refunds',
          'Payments are securely processed through our encrypted gateway. Refunds for cancellations are granted automatically if the cancellation occurs before the 24-hour window of the scheduled puja.',
        ),
      ],
    );
  }
  Widget _buildTermsSection(String header, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          header,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ],
    );
  }
  Widget _buildGeneric() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.construction_rounded,
            color: Color(0xFFD4AF37),
            size: 40,
          ),
          const SizedBox(height: 24),
          Text(
            'Content for\n${widget.title}\nwill appear here',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 16,
              fontWeight: FontWeight.w300,
              height: 1.6,
              fontFamily: 'Serif',
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}
