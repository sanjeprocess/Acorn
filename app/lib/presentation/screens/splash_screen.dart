import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../core/theme.dart';
import '../../routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _floatingController;
  late AnimationController _shineController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotateAnimation;
  late Animation<double> _fadeInAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _shineAnimation;

  // Particles for background animation
  final List<Map<String, dynamic>> _particles = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    // Generate particles for background
    for (int i = 0; i < 20; i++) {
      _particles.add({
        'position': Offset(
          _random.nextDouble() * 400,
          _random.nextDouble() * 800,
        ),
        'size': _random.nextDouble() * 8 + 2,
        'speed': _random.nextDouble() * 2 + 1,
      });
    }

    // Main animation controller
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    // Floating animation controller
    _floatingController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    // Shine animation controller
    _shineController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat();

    // Logo scaling animation
    _logoScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    // Logo rotation animation
    _logoRotateAnimation = Tween<double>(begin: -0.5, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOutBack),
      ),
    );

    // Text fade in animation
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.6, 0.9, curve: Curves.easeIn),
      ),
    );

    // Text slide animation
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.6, 0.9, curve: Curves.easeOut),
      ),
    );

    // Floating animation
    _floatAnimation = Tween<double>(begin: -5, end: 5).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );

    // Shine animation
    _shineAnimation = Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(parent: _shineController, curve: Curves.linear));

    // Start animations
    _mainController.forward();

    // Navigate after delay
    Timer(const Duration(milliseconds: 4500), () {
      AppRoutes.navigateAndReplace(context, AppRoutes.login);
    });

    // Update particles periodically
    Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (mounted) {
        setState(() {
          for (var particle in _particles) {
            particle['position'] = Offset(
              particle['position'].dx,
              particle['position'].dy - particle['speed'],
            );

            if (particle['position'].dy < 0) {
              particle['position'] = Offset(particle['position'].dx, 800);
            }
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _floatingController.dispose();
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Luxury background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppTheme.gradient1, AppTheme.gradient2],
              ),
            ),
          ),

          // Animated particles
          CustomPaint(
            size: Size(screenSize.width, screenSize.height),
            painter: ParticlesPainter(_particles),
          ),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated logo with floating effect
                AnimatedBuilder(
                  animation: Listenable.merge([
                    _mainController,
                    _floatingController,
                  ]),
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatAnimation.value),
                      child: Transform.scale(
                        scale: _logoScaleAnimation.value,
                        child: Transform.rotate(
                          angle: _logoRotateAnimation.value,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Shine effect
                              AnimatedBuilder(
                                animation: _shineController,
                                builder: (context, child) {
                                  return Transform.rotate(
                                    angle: _shineAnimation.value * math.pi,
                                    child: Container(
                                      width: screenSize.width * 0.45,
                                      height: screenSize.width * 0.45,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.white.withOpacity(0),
                                            Colors.white.withOpacity(0.2),
                                            Colors.white.withOpacity(0),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              // Logo container
                              Container(
                                width: screenSize.width * 0.4,
                                height: screenSize.width * 0.4,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                    BoxShadow(
                                      color: AppTheme.primaryColor.withOpacity(
                                        0.3,
                                      ),
                                      blurRadius: 30,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(20),
                                child: Image.asset(
                                  'assets/images/acorn_logo.jpg',
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),

                // Animated text
                AnimatedBuilder(
                  animation: _mainController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeInAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          children: [
                            // Text(
                            //   'LUXURY TRAVELS',
                            //   style: TextStyle(
                            //     color: Colors.white,
                            //     fontSize: 32,
                            //     fontWeight: FontWeight.bold,
                            //     letterSpacing: 3.0,
                            //     fontFamily: 'Roboto',
                            //     shadows: [
                            //       Shadow(
                            //         color: Colors.black.withOpacity(0.3),
                            //         offset: const Offset(0, 2),
                            //         blurRadius: 4,
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            // const SizedBox(height: 15),
                            // Text(
                            //   'Experience the extraordinary',
                            //   style: TextStyle(
                            //     color: Colors.white.withOpacity(0.9),
                            //     fontSize: 18,
                            //     fontWeight: FontWeight.w400,
                            //     fontFamily: 'Roboto',
                            //     letterSpacing: 1.2,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 60),

                // Loading indicator
                AnimatedBuilder(
                  animation: _mainController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeInAnimation.value,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.all(5),
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 3,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for particle animation
class ParticlesPainter extends CustomPainter {
  final List<Map<String, dynamic>> particles;

  ParticlesPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..style = PaintingStyle.fill;

    for (var particle in particles) {
      canvas.drawCircle(particle['position'], particle['size'], paint);
    }
  }

  @override
  bool shouldRepaint(ParticlesPainter oldDelegate) => true;
}
