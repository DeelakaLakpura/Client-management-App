import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);  // Looping

    // Fade-in animation
    _fadeAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Scale animation
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0F1C),
      body: Stack(
        children: [
          // Layered gradient background for depth
          _buildGradientBackground(),

          // Rotating shapes in the background for visual interest
          Positioned(
            top: -50,
            left: -50,
            child: _buildRotatingShape(const Color(0xFF14CE52).withOpacity(0.4)),
          ),
          Positioned(
            bottom: -50,
            right: -50,
            child: _buildRotatingShape(const Color(0xFFFFD700).withOpacity(0.4)),
          ),

          // Centered loading components
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildGlowingCard(), // Glowing card behind Lottie animation

                // Animated Lottie animation
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Lottie.network(
                    'https://lottie.host/18ed0a4a-c1b2-4d1e-bf90-7a7b35f6e35f/70SaWdHNIi.json',
                    width: 200,
                    height: 200,
                  ),
                ),

                const SizedBox(height: 20),

                // Status card without loading text
                _buildStatusCard(),
              ],
            ),
          ),

          // Bottom centered loading text with advanced styles
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Text(
                'Initializing...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Nunito',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Gradient background for more depth
  Widget _buildGradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0.7, -0.6),
          radius: 1.0,
          colors: [Color(0xFF1A237E), Color(0xFF0D47A1), Color(0xFF000000)],
          stops: [0.1, 0.3, 1.0],
        ),
      ),
    );
  }

  // Rotating background shape
  Widget _buildRotatingShape(Color color) {
    return RotationTransition(
      turns: _controller,
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }

  // Glowing card effect for advanced look
  Widget _buildGlowingCard() {
    return Container(
      width: 230,
      height: 230,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Colors.cyanAccent, Colors.transparent],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withOpacity(0.4),
            blurRadius: 40,
            spreadRadius: 15,
          ),
        ],
      ),
    );
  }

  // Status card without loading text
  Widget _buildStatusCard() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        margin: const EdgeInsets.symmetric(horizontal: 30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFF121212).withOpacity(0.9),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.update,
              color: Colors.white70,
              size: 30,
            ),
            const SizedBox(width: 10),
            Text(
              '', // Empty text since we removed the loading resources part
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontFamily: 'Nunito',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
