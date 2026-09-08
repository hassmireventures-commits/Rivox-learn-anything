import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Which vertical edge-docked position the chat entry FAB was last dragged
/// to (Samsung-Edge-panel-handle style — a docked handle, not a freely
/// floating bubble). [verticalFraction] is 0 (top of the safe/allowed drag
/// range) to 1 (bottom).
class ChatFabPosition {
  ChatFabPosition({this.edge = 'right', this.verticalFraction = 1.0});

  /// 'left' | 'right'
  String edge;
  double verticalFraction;

  Map<String, dynamic> toJson() => {
        'edge': edge,
        'verticalFraction': verticalFraction,
      };

  factory ChatFabPosition.fromJson(Map<String, dynamic> json) {
    return ChatFabPosition(
      edge: json['edge'] as String? ?? 'right',
      verticalFraction: (json['verticalFraction'] as num?)?.toDouble().clamp(0.0, 1.0) ?? 1.0,
    );
  }
}

class ChatFabPositionStore {
  ChatFabPositionStore._();
  static final instance = ChatFabPositionStore._();

  ChatFabPosition _cached = ChatFabPosition();

  ChatFabPosition get current => _cached;

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/chat_fab_position.json');
  }

  Future<ChatFabPosition> load() async {
    try {
      final file = await _file();
      if (!file.existsSync()) return _cached;
      final json = jsonDecode(await file.readAsString());
      if (json is Map<String, dynamic>) {
        _cached = ChatFabPosition.fromJson(json);
      }
    } catch (_) {}
    return _cached;
  }

  Future<void> save(ChatFabPosition position) async {
    _cached = position;
    final file = await _file();
    await file.writeAsString(jsonEncode(position.toJson()));
  }
}
