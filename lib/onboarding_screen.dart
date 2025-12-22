import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';

class OnboardingData {
  final String title;
  final String highlightedTitle;
  final String subtitle;
  final String imageUrl;

  OnboardingData({
    required this.title,
    required this.highlightedTitle,
    required this.subtitle,
    required this.imageUrl,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF13EC5B);
    const backgroundDark = Color(0xFF102216);
    const backgroundLight = Color(0xFFF6F8F6);

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? backgroundDark : backgroundLight;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDarkMode
        ? const Color(0xFF94A3B8)
        : const Color(0xFF475569);

    final List<OnboardingData> pages = [
      OnboardingData(
        title: 'Your Mood, ',
        highlightedTitle: 'Decoded.',
        subtitle:
            'Simply write about your day. Our AI understands your sentiment and adapts the app to match your vibe.',
        imageUrl:
            'https://lh3.googleusercontent.com/aida-public/AB6AXuDin_drABYUdmXjz_7vYCl-a9BSDlH21ssJ2U_u0BJjE8UfhbvVnNyi78G6vv5tWG5wVlWgxRtDDOTxQxvVFfBx4JZzS-20PDroror6AkCSFyRoWTxtKdP7gO4GAPwfT994DNSUHwIk5_1nV8qj6SY2dF92kPEj8XQUP-huoycGI_REn2NACAtcqmFR6w5iJJ26wXkRRle3s93t9JPuyxDsz8OtUAN0i9yPkY6VHVcXDuQqPhMHmuST3DndbNd0Uy83SNx4siMsylg',
      ),
      OnboardingData(
        title: 'Visualize Your ',
        highlightedTitle: 'Journey.',
        subtitle:
            'See your emotional patterns over time with intuitive charts. Understand what triggers your mood and find your balance.',
        imageUrl: 'https://i.imgur.com/5eBZa1j.png',
      ),
      OnboardingData(
        title: 'Your Privacy, ',
        highlightedTitle: 'Our Priority.',
        subtitle:
            'Your thoughts are safe with biometric locking. Get personalized insights to improve your mental well-being every single day.',
        imageUrl:
            'https://images.unsplash.com/photo-1563986768609-322da13575f3?auto=format&fit=crop&q=80&w=1000',
      ),
    ];

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 48),
                  Text(
                    'AI Smart Journal',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  _currentPage < pages.length - 1
                      ? GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                              pages.length - 1,
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.fastOutSlowIn,
                            );
                          },
                          child: SizedBox(
                            width: 48,
                            child: Text(
                              'Skip',
                              textAlign: TextAlign.end,
                              style: GoogleFonts.manrope(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: secondaryTextColor,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          // Hero Illustration
                          AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.15),
                                    blurRadius: 40,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.network(
                                    page.imageUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              color: primaryColor.withOpacity(
                                                0.1,
                                              ),
                                              child: const Icon(
                                                Icons.image,
                                                size: 64,
                                                color: primaryColor,
                                              ),
                                            ),
                                  ),
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          backgroundColor.withOpacity(0.8),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          // Headline
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: page.title,
                                  style: GoogleFonts.manrope(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: textColor,
                                  ),
                                ),
                                TextSpan(
                                  text: page.highlightedTitle,
                                  style: GoogleFonts.manrope(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Body Text
                          Text(
                            page.subtitle,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.manrope(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: secondaryTextColor,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            // Bottom Action Section
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Dots Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(pages.length, (index) {
                      double delta = (index - _currentPage).abs();
                      double width = 8.0;
                      if (delta < 1.0) {
                        width = 8.0 + (32.0 - 8.0) * (1.0 - delta);
                      }
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: width,
                        decoration: BoxDecoration(
                          color: delta < 0.5
                              ? primaryColor
                              : (isDarkMode
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.grey.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: delta < 0.5
                              ? [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.5),
                                    blurRadius: 10,
                                  ),
                                ]
                              : [],
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),
                  // CTA Button
                  InkWell(
                    onTap: () {
                      if (_currentPage < pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      height: 56,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage >= pages.length - 1.5
                                ? 'Start Journaling'
                                : 'Next',
                            style: GoogleFonts.manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: backgroundDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            _currentPage >= pages.length - 1.5
                                ? Icons.check
                                : Icons.arrow_forward,
                            size: 20,
                            color: backgroundDark,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
