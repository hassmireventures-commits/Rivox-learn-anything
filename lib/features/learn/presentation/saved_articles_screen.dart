import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/locale/app_localizations_ext.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/bottom_native_ad_slot.dart';
import 'resource_webview_args.dart';

/// Saved articles from daily packs, paths, and the in-app reader.
class SavedArticlesScreen extends ConsumerWidget {
  const SavedArticlesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final store = ref.watch(articleBookmarkStoreProvider);
    final items = store.items;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.savedArticlesTitle)),
      body: CustomScrollView(
        slivers: [
          if (items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_border_rounded,
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.savedArticlesEmpty,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(AppTheme.pageHorizontal),
              sliver: SliverList.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppTheme.cardGap),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return AppCard(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        item.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      subtitle: item.topic.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(item.topic),
                            )
                          : null,
                      trailing: IconButton(
                        tooltip: l10n.articleBookmarkRemove,
                        icon: const Icon(Icons.bookmark_rounded),
                        onPressed: () => store.remove(item.url),
                      ),
                      onTap: () => openResourceInApp(
                        context,
                        url: item.url,
                        title: item.title,
                        topic: item.topic,
                      ),
                    ),
                  );
                },
              ),
            ),
          const SliverToBoxAdapter(
            child: ScrollableNativeAdSlot(slotId: 'saved_articles'),
          ),
        ],
      ),
    );
  }
}
