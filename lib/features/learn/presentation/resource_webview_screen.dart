import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/constants/official_learning_domains.dart';
import '../../../core/locale/app_localizations_ext.dart';
import '../../../core/providers/ai_platform_providers.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/study_session_tracker.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/primary_button.dart';

/// Official docs open in a restricted WebView; user-added sites open externally
/// (no unrestricted JS in-app - ARB M6).
class ResourceWebViewScreen extends ConsumerStatefulWidget {
  const ResourceWebViewScreen({
    super.key,
    required this.url,
    required this.title,
    this.topic = '',
  });

  final String url;
  final String title;
  final String topic;

  @override
  ConsumerState<ResourceWebViewScreen> createState() => _ResourceWebViewScreenState();
}

class _ResourceWebViewScreenState extends ConsumerState<ResourceWebViewScreen> {
  WebViewController? _controller;
  bool _blocked = true;
  bool _userSiteExternal = false;
  bool _ready = false;
  bool _pageLoading = true;
  bool _loadFailed = false;

  static const _userAgent =
      'Mozilla/5.0 (Linux; Android 14) AppleWebKit/537.36 (KHTML, like Gecko) '
      'Chrome/120.0.0.0 Mobile Safari/537.36 Rivox/1.0';

  Future<bool> _isUserHost(String host) async {
    final repo = ref.read(knowledgeRepositoryProvider);
    return repo.isUserAllowedHost(host);
  }

  bool _allowsNavigation(String requestUrl) {
    final uri = Uri.tryParse(requestUrl);
    if (uri == null) return false;
    if (uri.scheme == 'about') return true;
    if (uri.scheme != 'https') return false;
    final host = uri.host;
    if (host.isEmpty) return false;
    return OfficialLearningDomains.isAllowedDoc(host);
  }

  @override
  void initState() {
    super.initState();
    StudySessionTracker.instance.beginStudy();
    _init();
  }

  Future<void> _init() async {
    try {
      final uri = Uri.tryParse(widget.url.trim());
      if (uri == null || uri.host.isEmpty) {
        if (mounted) {
          setState(() {
            _blocked = true;
            _ready = true;
            _pageLoading = false;
            _loadFailed = true;
          });
        }
        return;
      }
      final host = uri.host;
      final official = OfficialLearningDomains.isAllowedDoc(host);
      final user = await _isUserHost(host);

      // User library sites: external browser only (safer than unrestricted JS WebView).
      if (user && !official) {
        if (mounted) {
          setState(() {
            _userSiteExternal = true;
            _blocked = false;
            _ready = true;
            _pageLoading = false;
          });
        }
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }

      final allowed = official;
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setUserAgent(_userAgent)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (_) {
              if (!mounted) return;
              setState(() {
                _pageLoading = true;
                _loadFailed = false;
              });
            },
            onPageFinished: (_) {
              if (!mounted) return;
              setState(() => _pageLoading = false);
            },
            onWebResourceError: (_) {
              if (!mounted) return;
              setState(() {
                _pageLoading = false;
                _loadFailed = true;
              });
            },
            onNavigationRequest: (request) {
              return _allowsNavigation(request.url)
                  ? NavigationDecision.navigate
                  : NavigationDecision.prevent;
            },
          ),
        );

      if (allowed) {
        await controller.loadRequest(
          uri,
          headers: const {'Accept': 'text/html,application/xhtml+xml'},
        );
      }
      if (mounted) {
        setState(() {
          _controller = controller;
          _blocked = !allowed;
          _ready = true;
          _pageLoading = allowed;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _blocked = true;
          _ready = true;
          _pageLoading = false;
          _loadFailed = true;
        });
      }
    }
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.tryParse(widget.url.trim());
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  void dispose() {
    StudySessionTracker.instance.endStudy();
    final c = _controller;
    if (c != null && !_blocked && _ready && !_userSiteExternal) {
      c.loadRequest(Uri.parse('about:blank'));
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    if (!_ready) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_userSiteExternal) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        body: Padding(
          padding: const EdgeInsets.all(AppTheme.pageHorizontal),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              Icon(Icons.open_in_browser_rounded, size: 48, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                l10n.libraryUserSiteBadge,
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'For your safety, sites you add open in your device browser - not inside the app.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                label: l10n.resourceOpenInBrowser,
                icon: Icons.open_in_browser_rounded,
                onPressed: _openInBrowser,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final store = ref.watch(articleBookmarkStoreProvider);
              final saved = store.isBookmarked(widget.url);
              return IconButton(
                tooltip: saved ? l10n.articleBookmarkRemove : l10n.articleBookmarkSave,
                icon: Icon(saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded),
                onPressed: () async {
                  await store.toggle(
                    url: widget.url,
                    title: widget.title,
                    topic: widget.topic,
                  );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        saved ? l10n.articleBookmarkRemoved : l10n.articleBookmarkSaved,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          IconButton(
            tooltip: l10n.resourceOpenInBrowser,
            icon: const Icon(Icons.open_in_browser_rounded),
            onPressed: _openInBrowser,
          ),
        ],
      ),
      body: _blocked || _controller == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.pageHorizontal),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n.resourceBlocked, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: l10n.resourceOpenInBrowser,
                      icon: Icons.open_in_browser_rounded,
                      onPressed: _openInBrowser,
                    ),
                  ],
                ),
              ),
            )
          : Stack(
              children: [
                WebViewWidget(controller: _controller!),
                if (_pageLoading)
                  const Center(child: CircularProgressIndicator()),
                if (_loadFailed && !_pageLoading)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.pageHorizontal),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.wifi_off_rounded,
                            size: 40,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.resourceBlocked,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 16),
                          PrimaryButton(
                            label: l10n.resourceOpenInBrowser,
                            icon: Icons.open_in_browser_rounded,
                            onPressed: _openInBrowser,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
