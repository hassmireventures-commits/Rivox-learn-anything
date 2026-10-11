import '../../../data/local/repositories/learner_repository.dart';

/// One change the chat agent wants to make to the learner's active path.
class PathEditOp {
  const PathEditOp._(this.kind, {this.index, this.title, this.summary, this.toIndex});

  const PathEditOp.add({required String title, String summary = '', int? index})
      : this._('add', title: title, summary: summary, index: index);
  const PathEditOp.remove({required int index}) : this._('remove', index: index);
  const PathEditOp.rename({required int index, required String title})
      : this._('rename', index: index, title: title);
  const PathEditOp.move({required int index, required int toIndex})
      : this._('move', index: index, toIndex: toIndex);

  /// 'add' | 'remove' | 'rename' | 'move'
  final String kind;

  /// 0-based module index the op targets. For 'add', the position the new
  /// module is inserted at (null = append).
  final int? index;
  final String? title;
  final String? summary;
  final int? toIndex;

  static const int maxTitleLength = 80;

  Map<String, dynamic> toJson() => {
        'op': kind,
        'index': ?index,
        'title': ?title,
        if (summary != null && summary!.isNotEmpty) 'summary': summary,
        'toIndex': ?toIndex,
      };

  /// Model output uses 1-based "module" numbers (how learners count); the
  /// persisted form uses 0-based "index". Accepts either. Null on anything
  /// it cannot apply safely.
  static PathEditOp? fromJson(Map<String, dynamic> json) {
    int? idx(String zeroKey, String oneKey) {
      final zero = json[zeroKey];
      if (zero is num) return zero.toInt();
      final one = json[oneKey];
      if (one is num) return one.toInt() - 1;
      return null;
    }

    String? clean(Object? raw) {
      final t = raw?.toString().trim() ?? '';
      if (t.isEmpty) return null;
      return t.length > maxTitleLength ? t.substring(0, maxTitleLength).trim() : t;
    }

    switch (json['op']?.toString()) {
      case 'add':
        final title = clean(json['title']);
        if (title == null) return null;
        return PathEditOp.add(
          title: title,
          summary: json['summary']?.toString().trim() ?? '',
          index: idx('index', 'module'),
        );
      case 'remove':
        final i = idx('index', 'module');
        return i == null ? null : PathEditOp.remove(index: i);
      case 'rename':
        final i = idx('index', 'module');
        final title = clean(json['title']);
        return i == null || title == null ? null : PathEditOp.rename(index: i, title: title);
      case 'move':
        final i = idx('index', 'module');
        final to = idx('toIndex', 'toModule');
        return i == null || to == null ? null : PathEditOp.move(index: i, toIndex: to);
      default:
        return null;
    }
  }
}

/// A batch of [PathEditOp]s with the agent's one-line reason.
class PathEditPlan {
  const PathEditPlan({required this.ops, this.reason = ''});

  static const int maxOps = 6;

  final List<PathEditOp> ops;
  final String reason;

  Map<String, dynamic> toJson() => {
        'ops': ops.map((o) => o.toJson()).toList(),
        if (reason.isNotEmpty) 'reason': reason,
      };

  static PathEditPlan? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final rawOps = raw['ops'];
    if (rawOps is! List) return null;
    final ops = rawOps
        .whereType<Map>()
        .map((m) => PathEditOp.fromJson(Map<String, dynamic>.from(m)))
        .whereType<PathEditOp>()
        .take(maxOps)
        .toList();
    if (ops.isEmpty) return null;
    return PathEditPlan(ops: ops, reason: raw['reason']?.toString().trim() ?? '');
  }

  /// Short human summary for the chat card and snackbar.
  String describe() {
    final parts = <String>[];
    for (final op in ops) {
      final n = (op.index ?? 0) + 1;
      parts.add(switch (op.kind) {
        'add' => 'added "${op.title}"',
        'remove' => 'removed module $n',
        'rename' => 'renamed module $n to "${op.title}"',
        'move' => 'moved module $n to position ${(op.toIndex ?? 0) + 1}',
        _ => op.kind,
      });
    }
    return parts.join(', ');
  }
}

/// Result of applying a plan purely in memory.
class PathEditResult {
  const PathEditResult({required this.steps, required this.currentIndex, required this.applied});

  final List<Map<String, dynamic>> steps;
  final int currentIndex;

  /// How many ops actually changed something (invalid ones are skipped).
  final int applied;
}

/// Everything needed to put a path back exactly as it was.
class PathSnapshot {
  const PathSnapshot({
    required this.pathUuid,
    required this.steps,
    required this.currentIndex,
    required this.status,
  });

  final String pathUuid;
  final List<Map<String, dynamic>> steps;
  final int currentIndex;
  final String status;
}

/// Applies chat-agent edits to the learner's active learning path, with an
/// exact snapshot for Undo. This is the "self-healing" half of the chat
/// agent: when the learner reports an irrelevant or wrong module, the agent
/// fixes the plan itself instead of telling them where to go.
///
/// Guard rails (enforced here, not trusted to the model): at least
/// [minModules] and at most [maxModules] modules remain; out-of-range ops are
/// skipped; completed modules keep counting as completed (the progress
/// pointer follows the module the learner is on).
class LearningPlanEditor {
  LearningPlanEditor(this._repo);

  static const int minModules = 1;
  static const int maxModules = 15;

  final LearnerRepository _repo;

  /// Pure: applies [ops] to [steps]. Never throws.
  static PathEditResult applyOps(
    List<Map<String, dynamic>> steps,
    List<PathEditOp> ops, {
    required int currentIndex,
  }) {
    final out = steps.map((s) => Map<String, dynamic>.from(s)).toList();
    var current = currentIndex.clamp(0, out.length);
    var applied = 0;
    for (final op in ops) {
      switch (op.kind) {
        case 'add':
          if (out.length >= maxModules) continue;
          final at = (op.index ?? out.length).clamp(0, out.length);
          out.insert(at, {
            'title': op.title,
            'summary': op.summary ?? '',
            'difficulty': 'medium',
            'estimatedMinutes': 15,
            'resources': <Map<String, dynamic>>[],
          });
          if (at < current) current++;
          applied++;
        case 'remove':
          final i = op.index ?? -1;
          if (i < 0 || i >= out.length || out.length <= minModules) continue;
          out.removeAt(i);
          if (i < current) current--;
          applied++;
        case 'rename':
          final i = op.index ?? -1;
          if (i < 0 || i >= out.length || op.title == null) continue;
          out[i]['title'] = op.title;
          // Old summary/resources described the old title; drop them so the
          // module regenerates its notes on next open instead of lying.
          out[i]['summary'] = '';
          out[i]['resources'] = <Map<String, dynamic>>[];
          out[i].remove('youtubeVideoId');
          applied++;
        case 'move':
          final from = op.index ?? -1;
          final to = op.toIndex ?? -1;
          if (from < 0 || from >= out.length || to < 0 || to >= out.length || from == to) continue;
          final step = out.removeAt(from);
          out.insert(to, step);
          applied++;
      }
    }
    return PathEditResult(
      steps: out,
      currentIndex: current.clamp(0, out.length),
      applied: applied,
    );
  }

  /// Applies [plan] to the active path (or [pathUuid]). Returns the snapshot
  /// to undo with, or null when there is no path or nothing valid to apply.
  Future<PathSnapshot?> apply(PathEditPlan plan, {String? pathUuid}) async {
    final path = pathUuid != null ? await _repo.getPath(pathUuid) : await _repo.primaryActivePath();
    if (path == null) return null;
    final before = await _repo.rawPathSteps(path);
    final result = applyOps(before, plan.ops, currentIndex: path.currentIndex);
    if (result.applied == 0) return null;
    final snapshot = PathSnapshot(
      pathUuid: path.uuid,
      steps: before,
      currentIndex: path.currentIndex,
      status: path.status,
    );
    // A path that was "completed" but just gained an unfinished module is
    // active again.
    final status = path.status == 'completed' && result.currentIndex < result.steps.length
        ? 'active'
        : null;
    await _repo.replacePathStructure(
      path.uuid,
      steps: result.steps,
      currentIndex: result.currentIndex,
      status: status,
    );
    return snapshot;
  }

  Future<void> restore(PathSnapshot snapshot) => _repo.replacePathStructure(
        snapshot.pathUuid,
        steps: snapshot.steps,
        currentIndex: snapshot.currentIndex,
        status: snapshot.status,
      );
}
