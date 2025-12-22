import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _autoTheme = true;
  bool _sentimentAnalysis = true;
  double _fontSize = 16;
  bool _dailyReminder = false;

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF13EC5B);
    const backgroundDark = Color(0xFF102216);
    const surfaceDark = Color(0xFF1C2B21);
    const textColorSecondary = Color(0xFF94A3B8);

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode
        ? backgroundDark
        : const Color(0xFFF6F8F6);
    final cardColor = isDarkMode ? surfaceDark : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: backgroundColor.withOpacity(0.95),
                border: Border(
                  bottom: BorderSide(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.05)
                        : Colors.black.withOpacity(0.05),
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    color: textColor,
                    splashRadius: 24,
                  ),
                  Expanded(
                    child: Text(
                      'Settings',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Done',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isDarkMode
                            ? []
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: primaryColor, width: 2),
                              image: const DecorationImage(
                                image: NetworkImage(
                                  'https://lh3.googleusercontent.com/aida-public/AB6AXuAAI8Re_CwwCDJEGbBeDP-KUV0H7mVnGNWiflBoentt3u-h-599mwP37a5Hm_qxrybJuQ00FvoZkBl9s4k9MxdTtBJQO6DNEujnIbp60jBKbYZ9MLjg05bMP00MpnXpxHKWifSR8vk4B8dDgd3TcSRKSe-iJqOfw8pX03nYwdukxPyhF_VAc9L54zcVb58oBsn-iSHr_2qetsB2zajxRP-TQUA8Sgfmdi03zhNEruOdgu4QQyk7OE27GEJh4j6slcWXoj8gIAMlsAg',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Alex Doe',
                                      style: GoogleFonts.manrope(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                      ),
                                      child: Text(
                                        'PRO',
                                        style: GoogleFonts.manrope(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  'alex.doe@example.com',
                                  style: GoogleFonts.manrope(
                                    fontSize: 14,
                                    color: textColorSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.sentiment_satisfied,
                                    size: 16,
                                    color: primaryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Calm',
                                    style: GoogleFonts.manrope(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                'Avg. Mood',
                                style: GoogleFonts.manrope(
                                  fontSize: 10,
                                  color: textColorSecondary.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // AI & Personalization
                    _buildSectionHeader(
                      'AI & PERSONALIZATION',
                      textColorSecondary,
                    ),
                    _buildSettingsGroup([
                      _buildToggleItem(
                        'Auto-Theme by Mood',
                        'App colors change with your journal entries',
                        Icons.palette,
                        _autoTheme,
                        (val) => setState(() => _autoTheme = val),
                        primaryColor,
                        textColor,
                        textColorSecondary,
                      ),
                      _buildToggleItem(
                        'Sentiment Analysis',
                        'Enable AI to read entry tone',
                        Icons.psychology,
                        _sentimentAnalysis,
                        (val) => setState(() => _sentimentAnalysis = val),
                        primaryColor,
                        textColor,
                        textColorSecondary,
                      ),
                      _buildSliderItem(
                        'Font Size',
                        Icons.format_size,
                        _fontSize,
                        (val) => setState(() => _fontSize = val),
                        primaryColor,
                        textColor,
                        textColorSecondary,
                      ),
                    ], cardColor),
                    const SizedBox(height: 24),

                    // Privacy & Security
                    _buildSectionHeader(
                      'PRIVACY & SECURITY',
                      textColorSecondary,
                    ),
                    _buildSettingsGroup([
                      _buildNavigationItem(
                        'Biometric Lock',
                        Icons.face,
                        Colors.blue,
                        'FaceID',
                        textColor,
                        textColorSecondary,
                      ),
                      _buildNavigationItem(
                        'Data & Privacy Controls',
                        Icons.lock,
                        Colors.grey,
                        '',
                        textColor,
                        textColorSecondary,
                      ),
                    ], cardColor),
                    const SizedBox(height: 24),

                    // Notifications
                    _buildSectionHeader('NOTIFICATIONS', textColorSecondary),
                    _buildSettingsGroup([
                      _buildToggleItem(
                        'Daily Reminder',
                        '',
                        Icons.notifications,
                        _dailyReminder,
                        (val) => setState(() => _dailyReminder = val),
                        Colors.red,
                        textColor,
                        textColorSecondary,
                      ),
                      _buildNavigationItem(
                        'Reminder Time',
                        Icons.schedule,
                        Colors.indigo,
                        '8:00 PM',
                        textColor,
                        textColorSecondary,
                      ),
                    ], cardColor),
                    const SizedBox(height: 24),

                    // Data
                    _buildSectionHeader('DATA', textColorSecondary),
                    _buildSettingsGroup([
                      _buildNavigationItem(
                        'Backup to Cloud',
                        Icons.cloud_upload,
                        Colors.orange,
                        'Last backup: 2 days ago',
                        textColor,
                        textColorSecondary,
                      ),
                      _buildNavigationItem(
                        'Export Journal Entries',
                        Icons.ios_share,
                        const Color(0xFF059669), // Emerald 600
                        '',
                        textColor,
                        textColorSecondary,
                      ),
                    ], cardColor),
                    const SizedBox(height: 32),

                    // Footer
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        children: [
                          OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Colors.red,
                                width: 1,
                              ),
                              minimumSize: const Size(double.infinity, 52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Log Out',
                              style: GoogleFonts.manrope(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Smart Journal AI v2.4.1 (Build 890)',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              color: textColorSecondary.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children, Color bgColor) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: children.asMap().entries.map((entry) {
          int idx = entry.key;
          Widget child = entry.value;
          if (idx == children.length - 1) return child;
          return Column(
            children: [
              child,
              Divider(
                height: 1,
                indent: 56,
                color: Colors.grey.withOpacity(0.1),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildToggleItem(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
    Color iconColor,
    Color textColor,
    Color textColorSecondary,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: textColorSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF13EC5B),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderItem(
    String title,
    IconData icon,
    double value,
    Function(double) onChanged,
    Color iconColor,
    Color textColor,
    Color textColorSecondary,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, size: 20, color: iconColor),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              Text(
                '${value.toInt()}px',
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: textColorSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'A',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: textColorSecondary,
                ),
              ),
              Expanded(
                child: Slider(
                  value: value,
                  min: 12,
                  max: 24,
                  divisions: 12,
                  onChanged: onChanged,
                  activeColor: iconColor,
                ),
              ),
              Text(
                'A',
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColorSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItem(
    String title,
    IconData icon,
    Color iconColor,
    String trailingText,
    Color textColor,
    Color textColorSecondary,
  ) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            if (trailingText.isNotEmpty)
              Text(
                trailingText,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  color: textColorSecondary,
                ),
              ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              size: 20,
              color: textColorSecondary.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }
}
