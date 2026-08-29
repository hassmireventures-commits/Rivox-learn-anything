import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/locale/app_localizations_ext.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/bottom_native_ad_slot.dart';

class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adServiceProvider).loadInterstitial();
    });
  }

  Future<void> _sendEmail({required String subject, required String body}) async {
    String enc(String value) => Uri.encodeComponent(value).replaceAll('+', '%20');
    final uri = Uri.parse(
      'mailto:${AppConstants.supportEmail}?subject=${enc(subject)}&body=${enc(body)}',
    );
    await launchUrl(uri);
  }

  Future<void> _openPlayStore() async {
    final uri = Uri.parse(AppConstants.playStoreUrl);
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.supportPlayStoreUnavailable)),
      );
    }
  }

  Future<void> _shareApp() async {
    final l10n = context.l10n;
    await SharePlus.instance.share(
      ShareParams(
        text: '${l10n.supportShareText}\n${AppConstants.playStoreUrl}',
      ),
    );
  }

  Future<void> _showSupportAd() async {
    final l10n = context.l10n;
    final adService = ref.read(adServiceProvider);
    if (!adService.interstitialReady && !adService.loadingInterstitial) {
      adService.loadInterstitial();
    }
    final shown = await adService.showInterstitial();
    if (!mounted) return;
    if (shown) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.settingsThanksForSupport)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.supportAdNotReady)),
      );
      adService.loadInterstitial();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final adService = ref.watch(adServiceProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.supportTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            l10n.supportHeadline,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.supportSubheadline,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 20),
          _SupportTile(
            icon: Icons.ondemand_video_rounded,
            color: AppTheme.seedColor,
            title: l10n.supportWatchVideoTitle,
            subtitle: adService.loadingInterstitial
                ? l10n.supportLoadingAd
                : adService.interstitialReady
                    ? l10n.supportAdReady
                    : l10n.supportAdUnavailable,
            onTap: _showSupportAd,
          ),
          _SupportTile(
            icon: Icons.campaign_rounded,
            color: AppTheme.accentTeal,
            title: l10n.supportRequestSponsoredTitle,
            subtitle: l10n.supportRequestSponsoredSubtitle,
            onTap: () => _sendEmail(
              subject: l10n.supportRequestSponsoredEmailSubject,
              body: l10n.supportRequestSponsoredEmailBody,
            ),
          ),
          _SupportTile(
            icon: Icons.star_rate_rounded,
            color: AppTheme.accentOrange,
            title: l10n.supportRateTitle,
            subtitle: l10n.supportRateSubtitle,
            onTap: _openPlayStore,
          ),
          _SupportTile(
            icon: Icons.share_rounded,
            color: AppTheme.accentBlue,
            title: l10n.supportShareTitle,
            subtitle: l10n.supportShareSubtitle,
            onTap: _shareApp,
          ),
          _SupportTile(
            icon: Icons.bug_report_rounded,
            color: AppTheme.accentTeal,
            title: l10n.supportReportBugTitle,
            subtitle: l10n.supportReportBugSubtitle,
            onTap: () => _sendEmail(
              subject: l10n.supportBugEmailSubject,
              body: l10n.supportBugEmailBody,
            ),
          ),
          _SupportTile(
            icon: Icons.lightbulb_outline_rounded,
            color: AppTheme.accentOrange,
            title: l10n.supportFeatureRequestTitle,
            subtitle: l10n.supportFeatureRequestSubtitle,
            onTap: () => _sendEmail(
              subject: l10n.supportFeatureEmailSubject,
              body: l10n.supportFeatureEmailBody,
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.supportFaqTitle, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          _FaqTile(q: l10n.supportFaqApiKeyQuestion, a: l10n.supportFaqApiKeyAnswer),
          _FaqTile(q: l10n.supportFaqAccountQuestion, a: l10n.supportFaqAccountAnswer),
          _FaqTile(q: l10n.supportFaqAdsQuestion, a: l10n.supportFaqAdsAnswer),
          _FaqTile(q: l10n.supportFaqProvidersQuestion, a: l10n.supportFaqProvidersAnswer),
          const ScrollableNativeAdSlot(slotId: 'support'),
        ],
      ),
    );
  }
}

class _SupportTile extends StatelessWidget {
  const _SupportTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: onTap,
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(icon, color: color),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.q, required this.a});

  final String q;
  final String a;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(q, style: const TextStyle(fontWeight: FontWeight.w600)),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(a),
          ),
        ),
      ],
    );
  }
}
