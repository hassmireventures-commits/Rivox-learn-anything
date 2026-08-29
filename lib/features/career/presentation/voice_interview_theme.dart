import 'package:flutter/material.dart';

/// Dark, high-contrast styling for the voice interview flow.
abstract final class VoiceInterviewTheme {
  static const background = Color(0xFF070B14);
  static const surface = Color(0xFF111827);
  static const surfaceElevated = Color(0xFF1A2332);
  static const hrAccent = Color(0xFF7C4DFF);
  static const techAccent = Color(0xFF00E5FF);
  static const glowHr = Color(0xFFB388FF);
  static const glowTech = Color(0xFF18FFFF);
  static const captionBg = Color(0xFF0D1524);
  static const questionText = Color(0xFFF5F7FA);
  static const questionSubtext = Color(0xFFB8C4D4);

  static LinearGradient backgroundGradient({InterviewAccent accent = InterviewAccent.tech}) {
    final c = accent == InterviewAccent.hr ? hrAccent : techAccent;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        background,
        Color.lerp(background, c, 0.12)!,
        background,
      ],
    );
  }

  static BoxDecoration personaCard({
    required bool selected,
    required InterviewAccent accent,
  }) {
    final color = accent == InterviewAccent.hr ? hrAccent : techAccent;
    return BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          surfaceElevated,
          Color.lerp(surfaceElevated, color, selected ? 0.35 : 0.08)!,
        ],
      ),
      border: Border.all(
        color: selected ? color : Colors.white12,
        width: selected ? 2 : 1,
      ),
      boxShadow: selected
          ? [
              BoxShadow(
                color: color.withValues(alpha: 0.35),
                blurRadius: 24,
                spreadRadius: -4,
              ),
            ]
          : null,
    );
  }
}

enum InterviewAccent { hr, tech }
