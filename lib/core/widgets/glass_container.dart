// lib/core/widgets/glass_container.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../app/themes/colors.dart'; 

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double blur;
  final double opacity;
  final List<Color>? linearGradientColors;
  final BoxBorder? customBorder;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final AlignmentGeometry? gradientBegin;
  final AlignmentGeometry? gradientEnd;

  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.blur = 10,
    this.opacity = 0.2,
    this.linearGradientColors,
    this.customBorder,
    this.padding,
    this.width,
    this.height,
    this.gradientBegin,
    this.gradientEnd,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0), // Warna dasar transparan
            gradient: LinearGradient(
              colors: linearGradientColors ?? [
                AppColors.glassBackgroundStart.withOpacity(opacity),
                AppColors.glassBackgroundEnd.withOpacity(opacity),
              ],
              begin: gradientBegin ?? Alignment.topLeft,
              end: gradientEnd ?? Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            border: customBorder ?? Border.all(color: Colors.white.withOpacity(0.1), width: 1.0),
          ),
          child: child,
        ),
      ),
    );
  }
}