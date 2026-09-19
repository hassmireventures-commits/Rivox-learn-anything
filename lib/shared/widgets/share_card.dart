import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';

/// A fixed-size, brand-styled card meant to be rendered off-screen and
/// captured as a PNG for sharing (results, learning-path progress, etc).
/// Kept generic (eyebrow/title/big stat/meta) so both call sites reuse the
/// same widget instead of near-duplicate layouts.
class ShareCard extends StatelessWidget {
  const ShareCard({
    super.key,
    required this.eyebrow,
    required this.title,
    required this.statValue,
    required this.statLabel,
    required this.metaLine,
    this.icon = Icons.auto_awesome_rounded,
  });

  final String eyebrow;
  final String title;
  final String statValue;
  final String statLabel;
  final String metaLine;
  final IconData icon;

  static const double width = 360;
  static const double height = 450;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.purpleStart, AppTheme.purpleEnd],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text(
                eyebrow,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          const Spacer(),
          Text(
            statValue,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 64,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            statLabel,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            metaLine,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  'assets/branding/rivox_logo.png',
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                AppConstants.appName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Captures [card] off-screen as a PNG and opens the platform share sheet.
/// Shared by results and learning-path screens so the capture/temp-file/share
/// plumbing exists in exactly one place.
Future<void> shareCardAsImage(ShareCard card, {String fileNamePrefix = 'rivox_share'}) async {
  final controller = ScreenshotController();
  final bytes = await controller.captureFromWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Material(color: Colors.transparent, child: card),
    ),
    pixelRatio: 3,
  );
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/${fileNamePrefix}_${DateTime.now().millisecondsSinceEpoch}.png');
  await file.writeAsBytes(bytes);
  await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
}
