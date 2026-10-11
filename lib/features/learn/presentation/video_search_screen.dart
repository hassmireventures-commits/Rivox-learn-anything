import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/youtube_reject_store.dart';
import '../../../core/services/youtube_search_service.dart';
import '../../../shared/widgets/in_app_youtube_player.dart';

/// In-app video for a topic: finds embeddable, on-topic YouTube videos and
/// plays them inside Rivox. Opened from chat's video suggestion and from any
/// module/daily video slot that has no usable video id. YouTube itself is
/// only a last resort when nothing playable is found.
class VideoSearchScreen extends StatefulWidget {
  const VideoSearchScreen({super.key, required this.topic, this.searchService});

  final String topic;
  final YoutubeSearchService? searchService;

  @override
  State<VideoSearchScreen> createState() => _VideoSearchScreenState();
}

class _VideoSearchScreenState extends State<VideoSearchScreen> {
  late final YoutubeSearchService _service = widget.searchService ?? YoutubeSearchService();
  List<YoutubeVideoHit> _hits = const [];
  int _selected = 0;
  bool _loading = true;
  bool _playing = false;
  final Set<String> _failed = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final hits = await _service.search(widget.topic);
    if (!mounted) return;
    setState(() {
      _hits = hits;
      _loading = false;
    });
  }

  Future<void> _openYouTube() async {
    final q = Uri.encodeQueryComponent('${widget.topic} tutorial');
    await launchUrl(
      Uri.parse('https://www.youtube.com/results?search_query=$q'),
      mode: LaunchMode.externalApplication,
    );
  }

  Future<void> _notRelevant(YoutubeVideoHit hit) async {
    await YoutubeRejectStore.reject(hit.videoId, reason: 'learner_flagged');
    if (!mounted) return;
    setState(() {
      _hits = _hits.where((h) => h.videoId != hit.videoId).toList();
      _selected = 0;
      _playing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(widget.topic, maxLines: 1, overflow: TextOverflow.ellipsis)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _hits.isEmpty
              ? _EmptyResult(topic: widget.topic, onOpenYouTube: _openYouTube)
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    InAppYoutubePlayer(
                      key: ValueKey(_hits[_selected].videoId),
                      videoId: _hits[_selected].videoId,
                      title: _hits[_selected].title,
                      failed: _failed.contains(_hits[_selected].videoId),
                      isActive: _playing,
                      onActivate: () => _playing = true,
                      onDeactivate: () => _playing = false,
                      onError: () => setState(() => _failed.add(_hits[_selected].videoId)),
                    ),
                    const SizedBox(height: 12),
                    Text(_hits[_selected].title, style: theme.textTheme.titleMedium),
                    if (_hits[_selected].channel.isNotEmpty)
                      Text(
                        _hits[_selected].channel,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: () => _notRelevant(_hits[_selected]),
                        icon: const Icon(Icons.thumb_down_alt_outlined, size: 16),
                        label: const Text('Not relevant, show another'),
                      ),
                    ),
                    if (_hits.length > 1) ...[
                      const SizedBox(height: 8),
                      Text('More videos', style: theme.textTheme.titleSmall),
                      const SizedBox(height: 4),
                      for (var i = 0; i < _hits.length; i++)
                        if (i != _selected)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                'https://img.youtube.com/vi/${_hits[i].videoId}/mqdefault.jpg',
                                width: 96,
                                height: 54,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    const SizedBox(width: 96, height: 54, child: Icon(Icons.smart_display)),
                              ),
                            ),
                            title: Text(_hits[i].title, maxLines: 2, overflow: TextOverflow.ellipsis),
                            onTap: () => setState(() {
                              _selected = i;
                              _playing = false;
                            }),
                          ),
                    ],
                  ],
                ),
    );
  }
}

class _EmptyResult extends StatelessWidget {
  const _EmptyResult({required this.topic, required this.onOpenYouTube});

  final String topic;
  final VoidCallback onOpenYouTube;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.smart_display_outlined, size: 48, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              'No playable video found for "$topic" right now.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onOpenYouTube,
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Search on YouTube'),
            ),
          ],
        ),
      ),
    );
  }
}
