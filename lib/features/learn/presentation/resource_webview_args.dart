import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Arguments for [ResourceWebViewScreen]. Prefer [openResourceInApp] over raw
/// query strings so article URLs are not truncated or double-decoded.
class ResourceWebViewArgs {
  const ResourceWebViewArgs({
    required this.url,
    required this.title,
    this.topic = '',
  });

  final String url;
  final String title;
  final String topic;
}

void openResourceInApp(
  BuildContext context, {
  required String url,
  required String title,
  String topic = '',
}) {
  context.push(
    '/resource',
    extra: ResourceWebViewArgs(url: url.trim(), title: title.trim(), topic: topic.trim()),
  );
}
