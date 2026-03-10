import 'package:arcon_travel_app/core/constant.dart';
import 'package:arcon_travel_app/core/theme.dart';
import 'package:flutter/material.dart';

class GradientScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final IconData backgroundIcon;
  final Color backgroundIconColor;
  final double backgroundIconSize;
  final double backgroundIconOpacity;
  final Alignment backgroundIconAlignment;

  // Gradient properties
  final Gradient? gradient;
  final List<Color>? gradientColors;
  final AlignmentGeometry gradientBegin;
  final AlignmentGeometry gradientEnd;
  final List<double>? gradientStops;

  const GradientScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.backgroundIcon = Icons.arrow_circle_down,
    this.backgroundIconColor = Colors.white,
    this.backgroundIconSize = 400,
    this.backgroundIconOpacity = 0.05,
    this.backgroundIconAlignment = Alignment.center,
    this.gradient,
    this.gradientColors,
    this.gradientBegin = Alignment.topLeft,
    this.gradientEnd = Alignment.bottomRight,
    this.gradientStops,
  });

  @override
  Widget build(BuildContext context) {
    // Determine the gradient to use

    Gradient? finalGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppTheme.primaryColor,
        AppTheme.gradient2,
        const Color.fromARGB(255, 5, 17, 36),
      ],
    );
    if (finalGradient == null && gradientColors != null) {
      finalGradient = LinearGradient(
        begin: gradientBegin,
        end: gradientEnd,
        colors: gradientColors!,
        stops: gradientStops,
      );
    }

    return Scaffold(
      appBar: appBar,
      backgroundColor:
          finalGradient != null ? Colors.transparent : backgroundColor,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration:
            finalGradient != null
                ? BoxDecoration(gradient: finalGradient)
                : null,
        child: Stack(
          children: [
            // Main content - takes full available space
            Positioned.fill(child: body),
            // Background icon - always positioned at bottom right
            Positioned(
              bottom: -270,
              right: 100,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.00,
                  child: Image.asset(
                    AppConstants.compassImageUrl,
                    color: AppTheme.whiteColor,
                    fit: BoxFit.contain,
                    width: 600,
                    height: 600,
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
