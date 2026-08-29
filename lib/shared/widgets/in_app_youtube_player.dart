import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../core/locale/app_localizations_ext.dart';
import '../../core/theme/app_theme.dart';

const double kInAppYoutubeAspectRatio = 16 / 9;

/// Tap-to-play YouTube embed used by learning paths and daily learning pack.
class InAppYoutubePlayer extends StatefulWidget {
  const InAppYoutubePlayer({
    super.key,
    required this.videoId,
    required this.title,
    required this.failed,
    required this.isActive,
    required this.onActivate,
    required this.onDeactivate,
    required this.onError,
  });

  /// May be null when validation stripped the id â€” shows search fallback.
  final String? videoId;
  final String title;
  final bool failed;
  final bool isActive;
  final VoidCallback onActivate;
  final VoidCallback onDeactivate;
  final VoidCallback onError;

  @override
  State<InAppYoutubePlayer> createState() => _InAppYoutubePlayerState();
}

class _InAppYoutubePlayerState extends State<InAppYoutubePlayer> {
  YoutubePlayerController? _controller;
  bool _started = false;
  StreamSubscription<YoutubePlayerValue>? _sub;

  @override
  void didUpdateWidget(covariant InAppYoutubePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isActive && _controller != null) {
      _disposeController();
    }
    if (widget.failed && _controller != null) {
      _disposeController();
      if (widget.isActive) {
        widget.onDeactivate();
      }
    }
  }

  void _disposeController() {
    unawaited(_sub?.cancel());
    _sub = null;
    _controller?.close();
    _controller = null;
    _started = false;
  }

  void _startPlayback() {
    final id = widget.videoId;
    if (_started || widget.failed || id == null || id.isEmpty) return;

    // showControls must be true on mobile â€” disabled controls historically
    // prevented the iframe player from loading on non-web platforms.
    _controller = YoutubePlayerController.fromVideoId(
      videoId: id,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        enableJavaScript: true,
        playsInline: true,
        strictRelatedVideos: true,
        origin: 'https://www.youtube.com',
        pointerEvents: PointerEvents.auto,
      ),
    );
    _sub = _controller!.listen((event) {
      if (!event.hasError) return;
      _disposeController();
      if (mounted) setState(() {});
      widget.onError();
    });
    _started = true;
    widget.onActivate();
    setState(() {});
  }

  @override
  void dispose() {
    widget.onDeactivate();
    _disposeController();
    super.dispose();
  }

  Future<void> _openYouTube() async {
    final id = widget.videoId;
    final uri = id != null
        ? Uri.parse('https://www.youtube.com/watch?v=$id')
        : Uri.parse(
            'https://www.youtube.com/results?search_query=${Uri.encodeComponent(widget.title)}');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _searchYouTube() async {
    final query = Uri.encodeComponent('${widget.title} tutorial');
    final uri = Uri.parse('https://www.youtube.com/results?search_query=$query');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (widget.failed || widget.videoId == null || widget.videoId!.isEmpty) {
      return _VideoSearchCard(
        title: widget.title,
        onSearch: _searchYouTube,
        l10n: l10n,
      );
    }

    if (!_started || _controller == null) {
      return InAppYoutubeFrame(
        child: GestureDetector(
          onTap: _startPlayback,
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              Image.network(
                'https://img.youtube.com/vi/${widget.videoId}/hqdefault.jpg',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: Colors.black87,
                  child: const Center(
                    child: Icon(
                      Icons.play_circle_fill_rounded,
                      color: Colors.white70,
                      size: 56,
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black45,
                  borderRadius: BorderRadius.circular(40),
                ),
                padding: const EdgeInsets.all(12),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
              ),
            ],
          ),
        ),
      );
    }

    return InAppYoutubeFrame(
      child: YoutubePlayer(
        controller: _controller!,
        aspectRatio: kInAppYoutubeAspectRatio,
        autoFullScreen: true,
        enableFullScreenOnVerticalDrag: true,
      ),
    );
  }
}

class InAppYoutubeFrame extends StatelessWidget {
  const InAppYoutubeFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: kInAppYoutubeAspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: child,
      ),
    );
  }
}

class _VideoSearchCard extends StatelessWidget {
  const _VideoSearchCard({
    required this.title,
    required this.onSearch,
    required this.l10n,
  });

  final String title;
  final VoidCallback onSearch;
  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    return InAppYoutubeFrame(
      child: Container(
        color: Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.smart_display_rounded, color: Colors.white70, size: 40),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.pathVideoSearchSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFFF0000)),
              onPressed: onSearch,
              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
              label: Text(l10n.pathVideoSearchButton, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

class _VideoUnavailableCard extends StatelessWidget {
  const _VideoUnavailableCard({required this.onWatch, this.l10n});

  final VoidCallback onWatch;
  final dynamic l10n;

  @override
  Widget build(BuildContext context) {
    final strings = l10n ?? context.l10n;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return InAppYoutubeFrame(
      child: ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.videocam_off_outlined, size: 40, color: muted),
            const SizedBox(height: 8),
            Text(
              strings.pathVideoUnavailable,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: muted),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onWatch,
              icon: const Icon(Icons.open_in_new_rounded),
              label: Text(strings.pathWatchOnYouTube),
            ),
          ],
        ),
      ),
    );
  }
}
