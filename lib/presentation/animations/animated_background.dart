import 'package:flutter/material.dart';
import 'dart:math';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({Key? key}) : super(key: key);

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  const Color(0xFF1e1b4b),
                  const Color(0xFF581c87),
                  _controller.value,
                )!,
                const Color(0xFF7c2d8e),
                Color.lerp(
                  const Color(0xFF9d174d),
                  const Color(0xFF581c87),
                  _controller.value,
                )!,
              ],
            ),
          ),
          child: Stack(
            children: List.generate(15, (index) {
              return Positioned(
                left: (index * 100.0 + _controller.value * 50) %
                    MediaQuery.of(context).size.width,
                top: (index * 60.0) % MediaQuery.of(context).size.height,
                child: Opacity(
                  opacity: 0.1,
                  child: Container(
                    width: 100 + (index % 5) * 20.0,
                    height: 100 + (index % 5) * 20.0,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }
}
