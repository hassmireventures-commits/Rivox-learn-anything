import '../../../core/constants/official_learning_domains.dart';

class ResourceLink {
  const ResourceLink({
    required this.type,
    required this.title,
    required this.url,
    required this.domain,
  });

  final String type;
  final String title;
  final String url;
  final String domain;

  factory ResourceLink.fromJson(Map<String, dynamic> json) {
    return ResourceLink(
      type: json['type']?.toString() ?? 'doc',
      title: json['title']?.toString() ?? 'Resource',
      url: json['url']?.toString() ?? '',
      domain: json['domain']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'title': title,
        'url': url,
        'domain': domain,
      };
}

class PathStep {
  const PathStep({
    required this.title,
    required this.summary,
    required this.difficulty,
    required this.estimatedMinutes,
    required this.resources,
    this.youtubeVideoId,
  });

  final String title;
  final String summary;
  final String difficulty;
  final int estimatedMinutes;
  final List<ResourceLink> resources;
  final String? youtubeVideoId;

  factory PathStep.fromJson(Map<String, dynamic> json) {
    final resourcesRaw = json['resources'];
    final resources = <ResourceLink>[];
    if (resourcesRaw is List) {
      for (final item in resourcesRaw) {
        if (item is Map) {
          resources.add(ResourceLink.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return PathStep(
      title: json['title']?.toString() ?? 'Module',
      summary: json['summary']?.toString() ?? '',
      difficulty: json['difficulty']?.toString() ?? 'medium',
      estimatedMinutes: (json['estimatedMinutes'] as num?)?.toInt() ?? 15,
      resources: resources,
      youtubeVideoId: json['youtubeVideoId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'summary': summary,
        'difficulty': difficulty,
        'estimatedMinutes': estimatedMinutes,
        'resources': resources.map((e) => e.toJson()).toList(),
        'youtubeVideoId': youtubeVideoId,
      };
}

class GeneratedLearningPath {
  const GeneratedLearningPath({
    required this.title,
    required this.steps,
  });

  final String title;
  final List<PathStep> steps;
}

class ResourceLinkValidator {
  const ResourceLinkValidator._();

  static String? extractYouTubeId(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.host.contains('youtu.be')) {
      final id = uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
      return _isValidYouTubeId(id) ? id : null;
    }
    if (uri.host.contains('youtube.com') || uri.host.contains('youtube-nocookie.com')) {
      final id = uri.queryParameters['v'];
      return _isValidYouTubeId(id) ? id : null;
    }
    return null;
  }

  static bool _isValidYouTubeId(String? id) {
    if (id == null || id.length != 11) return false;
    return RegExp(r'^[A-Za-z0-9_-]{11}$').hasMatch(id);
  }

  static ResourceLink? sanitizeLink(Map<String, dynamic> raw) {
    final url = raw['url']?.toString().trim() ?? '';
    if (!url.startsWith('https://')) return null;
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) return null;

    final type = raw['type']?.toString() ?? 'doc';
      if (type == 'video') {
        if (!OfficialLearningDomains.isAllowedVideo(uri.host)) return null;
        final id = extractYouTubeId(url);
        if (id == null) return null;
    } else {
      if (!OfficialLearningDomains.isAllowedDoc(uri.host)) return null;
    }

    return ResourceLink(
      type: type,
      title: raw['title']?.toString() ?? uri.host,
      url: url,
      domain: uri.host,
    );
  }

  static GeneratedLearningPath validatePath(Map<String, dynamic> json) {
    final title = json['title']?.toString() ?? 'Learning path';
    final stepsRaw = json['steps'];
    if (stepsRaw is! List) {
      throw FormatException('Missing steps array');
    }

    final steps = <PathStep>[];
    for (final item in stepsRaw) {
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final resourcesRaw = map['resources'];
      final validatedResources = <ResourceLink>[];
      String? youtubeId = map['youtubeVideoId']?.toString();

      if (resourcesRaw is List) {
        for (final r in resourcesRaw) {
          if (r is! Map) continue;
          final link = sanitizeLink(Map<String, dynamic>.from(r));
          if (link != null) {
            validatedResources.add(link);
            if (link.type == 'video' && youtubeId == null) {
              youtubeId = extractYouTubeId(link.url);
            }
          }
        }
      }

      final youtubeUrl = map['youtubeUrl']?.toString();
      if (youtubeUrl != null && youtubeUrl.isNotEmpty) {
        final link = sanitizeLink({'type': 'video', 'title': 'Video', 'url': youtubeUrl});
        if (link != null) {
          validatedResources.add(link);
          youtubeId ??= extractYouTubeId(link.url);
        }
      }

      if (validatedResources.isEmpty && youtubeId == null) continue;

      steps.add(PathStep(
        title: map['title']?.toString() ?? 'Module ${steps.length + 1}',
        summary: map['summary']?.toString() ?? '',
        difficulty: map['difficulty']?.toString() ?? 'medium',
        estimatedMinutes: (map['estimatedMinutes'] as num?)?.toInt() ?? 15,
        resources: validatedResources,
        youtubeVideoId: youtubeId,
      ));
    }

    if (steps.isEmpty) {
      throw FormatException('No valid modules with official resources');
    }

    return GeneratedLearningPath(title: title, steps: steps.take(8).toList());
  }
}
