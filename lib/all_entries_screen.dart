import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'journal_service.dart';
import 'theme_service.dart';
import 'dart:ui';
import 'package:intl/intl.dart';

class AllEntriesScreen extends StatelessWidget {
  const AllEntriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService();
    final primaryColor = themeService.primaryColor;
    final backgroundColor = themeService.backgroundColor;
    final surfaceColor = themeService.surfaceColor;
    final textColor = themeService.textColor;
    final textColorSecondary = themeService.textColorSecondary;

    final entries = JournalService().entries;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withOpacity(0.05),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
                child: Container(),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: textColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'All Journal Entries',
                        style: GoogleFonts.manrope(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Entries List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    physics: const BouncingScrollPhysics(),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildEntryItem(
                          entry.mood,
                          entry.content,
                          DateFormat('MMM').format(entry.timestamp),
                          DateFormat('dd').format(entry.timestamp),
                          Icons.auto_awesome,
                          primaryColor,
                          surfaceColor,
                          textColor,
                          textColorSecondary,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryItem(
    String title,
    String subtitle,
    String month,
    String day,
    IconData moodIcon,
    Color moodColor,
    Color surfaceColor,
    Color textColor,
    Color textColorSecondary,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: textColor.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                month.toUpperCase(),
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: textColorSecondary,
                ),
              ),
              Text(
                day,
                style: GoogleFonts.manrope(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Container(width: 1, height: 40, color: textColor.withOpacity(0.1)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Icon(moodIcon, size: 18, color: moodColor),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    color: textColorSecondary,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
