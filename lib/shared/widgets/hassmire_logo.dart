import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.height = 72,
    this.width,
    this.fit = BoxFit.contain,
  });

  final double height;
  final double? width;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppConstants.brandingLogoAsset,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (_, _, _) => Icon(
        Icons.auto_awesome_rounded,
        size: height * 0.75,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

/// Hassmire Ventures logo for About/Settings only.
class HassmireLogo extends StatelessWidget {
  const HassmireLogo({
    super.key,
    this.height = 48,
    this.width,
    this.fit = BoxFit.contain,
  });

  final double height;
  final double? width;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppConstants.organizationLogoAsset,
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (_, _, _) => const SizedBox.shrink(),
    );
  }
}
