import 'package:flutter/material.dart';
import 'package:nidaa_v2/core/constant/app_color.dart';
import 'package:nidaa_v2/generated/l10n.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPageData(
      icon: Icons.mosque_outlined,
      title: 'onboardingWelcomeTitle',
      description: 'onboardingWelcomeDescription',
    ),
    _OnboardingPageData(
      icon: Icons.access_time,
      title: 'onboardingPrayerTitle',
      description: 'onboardingPrayerDescription',
    ),
    _OnboardingPageData(
      icon: Icons.explore,
      title: 'onboardingQiblaTitle',
      description: 'onboardingQiblaDescription',
    ),
    _OnboardingPageData(
      icon: Icons.menu_book_outlined,
      title: 'onboardingAzkarTitle',
      description: 'onboardingAzkarDescription',
    ),
    _OnboardingPageData(
      icon: Icons.check_circle_outline,
      title: 'onboardingReadyTitle',
      description: 'onboardingReadyDescription',
      isLast: true,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onComplete();
    }
  }

  void _onSkip() {
    widget.onComplete();
  }

  String _localized(String key) {
    switch (key) {
      case 'onboardingWelcomeTitle':
        return S.of(context).onboardingWelcomeTitle;
      case 'onboardingWelcomeDescription':
        return S.of(context).onboardingWelcomeDescription;
      case 'onboardingPrayerTitle':
        return S.of(context).onboardingPrayerTitle;
      case 'onboardingPrayerDescription':
        return S.of(context).onboardingPrayerDescription;
      case 'onboardingQiblaTitle':
        return S.of(context).onboardingQiblaTitle;
      case 'onboardingQiblaDescription':
        return S.of(context).onboardingQiblaDescription;
      case 'onboardingAzkarTitle':
        return S.of(context).onboardingAzkarTitle;
      case 'onboardingAzkarDescription':
        return S.of(context).onboardingAzkarDescription;
      case 'onboardingReadyTitle':
        return S.of(context).onboardingReadyTitle;
      case 'onboardingReadyDescription':
        return S.of(context).onboardingReadyDescription;
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
    final primaryText = isDark
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;
    final accentColor = isDark
        ? AppColors.darkAccentGold
        : AppColors.lightAccentBlue;
    final secondaryText = isDark
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _onSkip,
                child: Text(
                  s.onboardingSkip,
                  style: TextStyle(color: secondaryText),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(page.icon, size: 120, color: accentColor),
                        const SizedBox(height: 48),
                        Text(
                          _localized(page.title),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: primaryText,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _localized(page.description),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: secondaryText,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_pages.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? accentColor : secondaryText,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentPage == _pages.length - 1
                        ? s.onboardingGetStarted
                        : s.onboardingNext,
                    style: TextStyle(
                      fontSize: 18,
                      color: isDark ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final IconData icon;
  final String title;
  final String description;
  final bool isLast;

  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
    this.isLast = false,
  });
}
