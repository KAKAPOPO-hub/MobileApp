import 'package:flutter/material.dart';

import '../services/auth_session.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final username = AuthSession.username ?? 'Guest User';
    final userId = AuthSession.userId ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF20202D)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF20202D),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F3FF),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE7E4FA)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFF6557E8),
                    child: Icon(Icons.person_rounded, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF20202D),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'User ID: $userId',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Color(0xFF77768A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _GroupCard(
              children: [
                _SettingsTile(icon: Icons.person_outline_rounded, label: 'Account', onTap: () {}),
                _SettingsTile(icon: Icons.article_outlined, label: 'My Posts', onTap: () {}),
                _SettingsTile(icon: Icons.bookmark_border_rounded, label: 'Saved Posts', onTap: () {}),
              ],
            ),
            const SizedBox(height: 14),
            _GroupCard(
              children: [
                _SettingsTile(icon: Icons.notifications_none_rounded, label: 'Notifications', onTap: () {}),
                _SettingsTile(icon: Icons.privacy_tip_outlined, label: 'Privacy & Safety', onTap: () {}),
                _SettingsTile(icon: Icons.help_outline_rounded, label: 'Help Center', onTap: () {}, isLast: true),
              ],
            ),
            const SizedBox(height: 14),
            _GroupCard(
              children: [
                _SettingsTile(
                  icon: Icons.logout_rounded,
                  label: 'Log out',
                  onTap: () {
                    AuthSession.token = null;
                    AuthSession.userId = null;
                    AuthSession.username = null;
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  },
                  isLast: true,
                  labelColor: Colors.redAccent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5FB),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEAE8F2)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isLast = false,
    this.labelColor = const Color(0xFF20202D),
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isLast;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(bottom: BorderSide(color: Color(0xFFEAE8F2))),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFFECE7FF),
              child: Icon(icon, color: const Color(0xFF6557E8), size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: labelColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF77768A)),
          ],
        ),
      ),
    );
  }
}