import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ThemeService _themeService = ThemeService();
  bool _autoTheme = true;
  bool _sentimentAnalysis = true;
  double _fontSize = 16;
  bool _dailyReminder = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = _themeService.primaryColor;
    final backgroundColor = _themeService.backgroundColor;
    final cardColor = _themeService.surfaceColor;
    final textColor = _themeService.textColor;
    final textColorSecondary = _themeService.textColorSecondary;
    final isDarkMode = _themeService.isDark;

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
                                  'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=200&auto=format&fit=crop',
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
                                      'Ahmad',
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
                                  'ahmad@example.com',
                                  style: GoogleFonts.manrope(
                                    fontSize: 14,
                                    color: textColorSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Theme Section
                    _buildSectionHeader('VISUAL THEME', textColorSecondary),
                    _buildSettingsGroup([
                      _buildThemeSelector(cardColor, textColor, primaryColor),
                    ], cardColor),
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
                            'MindTrack AI v2.5.0',
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

  Widget _buildThemeSelector(
    Color cardColor,
    Color textColor,
    Color primaryColor,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.style, size: 20, color: primaryColor),
              const SizedBox(width: 12),
              Text(
                'Choose Theme',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 24) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _themeOption(
                    AppThemeMode.blueBlack,
                    'Blue - Dark',
                    const Color(0xFF3B82F6),
                    const Color(0xFF0F172A),
                    itemWidth,
                  ),
                  _themeOption(
                    AppThemeMode.greenBlack,
                    'Green - Dark',
                    const Color(0xFF13EC5B),
                    const Color(0xFF102216),
                    itemWidth,
                  ),
                  _themeOption(
                    AppThemeMode.blueWhite,
                    'Blue - Light',
                    const Color(0xFF3B82F6),
                    Colors.white,
                    itemWidth,
                  ),
                  _themeOption(
                    AppThemeMode.greenWhite,
                    'Green - Light',
                    const Color(0xFF13EC5B),
                    Colors.white,
                    itemWidth,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _themeOption(
    AppThemeMode mode,
    String label,
    Color primary,
    Color bg,
    double width,
  ) {
    final isSelected = _themeService.themeNotifier.value == mode;
    return GestureDetector(
      onTap: () {
        _themeService.setTheme(mode);
        setState(() {});
      },
      child: Container(
        width: width,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? primary.withOpacity(0.1) : bg.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primary : Colors.white.withOpacity(0.1),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: bg,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: _themeService.textColor,
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
            activeColor: _themeService.primaryColor,
          ),
        ],
      ),
    );
  }
}
