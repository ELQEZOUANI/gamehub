// lib/common_widgets/glassmorphic_container.dart

import 'dart:ui';
import 'package:flutter/material.dart';

class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final double borderRadius;
  final double blur;
  final Color color;
  final double borderStrength;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    required this.width,
    required this.height,
    this.borderRadius = 20,
    this.blur = 10,
    this.color = Colors.white,
    this.borderStrength = 0.2,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            // Hada howa l'effet dyal l'blur
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
              child: Container(), // Container khawi ghir bach i'activer l'blur
            ),

            // Hada howa loun l'jaj w l'border dyalo
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(color: color.withValues(alpha: borderStrength)),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: 0.25),
                    color.withValues(alpha: 0.1),
                  ],
                ),
              ),
            ),

            // Hada howa l'content li ghadi ikoun west l'jaj
            Center(child: child),
          ],
        ),
      ),
    );
  }
}