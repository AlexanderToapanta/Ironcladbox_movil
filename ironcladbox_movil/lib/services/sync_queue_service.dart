import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PendingOperation {
  final String method;
  final String path;
  final Map<String, dynamic>? body;
  final int timestamp;

  PendingOperation({
    required this.method,
    required this.path,
    this.body,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'method': method,
        'path': path,
        'body': body,
        'timestamp': timestamp,
      };

  factory PendingOperation.fromJson(Map<String, dynamic> json) => PendingOperation(
        method: json['method'] as String,
        path: json['path'] as String,
        body: json['body'] as Map<String, dynamic>?,
        timestamp: json['timestamp'] as int,
      );
}

class SyncQueueService {
  static final SyncQueueService _instance = SyncQueueService._internal();
  SharedPreferences? _prefs;
  final List<PendingOperation> _queue = [];

  factory SyncQueueService() => _instance;
  SyncQueueService._internal();

  int get pendingCount => _queue.length;
  List<PendingOperation> get pendingOperations => List.unmodifiable(_queue);

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadFromDisk();
  }

  void enqueue(String method, String path, {Map<String, dynamic>? body}) {
    final op = PendingOperation(
      method: method,
      path: path,
      body: body,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    _queue.add(op);
    _saveToDisk();
  }

  Future<bool> processQueue(Future<dynamic> Function(String method, String path, Map<String, dynamic>? body) executor) async {
    if (_queue.isEmpty) return true;

    final List<PendingOperation> failed = [];
    for (final op in List.from(_queue)) {
      try {
        await executor(op.method, op.path, op.body);
      } catch (_) {
        failed.add(op);
      }
    }

    _queue.clear();
    if (failed.isNotEmpty) {
      _queue.addAll(failed);
      _saveToDisk();
      return false;
    }

    _saveToDisk();
    return true;
  }

  void clear() {
    _queue.clear();
    _saveToDisk();
  }

  void _saveToDisk() {
    if (_prefs == null) return;
    final jsonList = _queue.map((op) => jsonEncode(op.toJson())).toList();
    _prefs!.setStringList('sync_queue', jsonList);
  }

  void _loadFromDisk() {
    if (_prefs == null) return;
    final jsonList = _prefs!.getStringList('sync_queue') ?? [];
    _queue.clear();
    for (final jsonStr in jsonList) {
      try {
        final map = jsonDecode(jsonStr) as Map<String, dynamic>;
        _queue.add(PendingOperation.fromJson(map));
      } catch (_) {}
    }
  }
}
