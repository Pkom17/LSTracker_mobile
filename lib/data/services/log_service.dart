import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Niveau de log.
enum LogLevel { debug, info, warn, error }

/// Une entrée du journal en mémoire.
class LogEntry {
  final DateTime timestamp;
  final LogLevel level;
  final String tag;
  final String message;
  final Object? error;
  final StackTrace? stackTrace;

  LogEntry({
    required this.timestamp,
    required this.level,
    required this.tag,
    required this.message,
    this.error,
    this.stackTrace,
  });

  /// Représentation texte d'une ligne (utilisée à la fois pour l'écran et
  /// l'export fichier).
  String format() {
    final buf = StringBuffer();
    buf.write(timestamp.toIso8601String());
    buf.write(' [');
    buf.write(level.name.toUpperCase().padRight(5));
    buf.write('] [');
    buf.write(tag);
    buf.write('] ');
    buf.write(message);
    if (error != null) {
      buf.write(' | error=$error');
    }
    if (stackTrace != null) {
      buf.write('\n');
      buf.write(stackTrace.toString());
    }
    return buf.toString();
  }
}

/// Service de journalisation centralisé pour l'app.
///
/// - Anneau circulaire en mémoire ([_buffer]) limité à [maxEntries]
/// - Notifie l'UI via [stream] pour rafraîchissement temps réel
/// - Sortie console via [debugPrint] (niveau >= info en release)
/// - Export texte via [exportToFile] (utilisable pour partage / debug)
///
/// Aucune information sensible (mot de passe, token) ne doit être passée
/// au logger. La règle est documentée mais non enforced.
class LogService {
  static final LogService instance = LogService._internal();
  LogService._internal();

  static const int maxEntries = 1000;

  final Queue<LogEntry> _buffer = Queue<LogEntry>();
  final StreamController<LogEntry> _controller =
      StreamController<LogEntry>.broadcast();

  /// Flux d'événements pour rafraîchir le journal à l'écran.
  Stream<LogEntry> get stream => _controller.stream;

  /// Snapshot ordonné chronologiquement (plus récent en dernier).
  List<LogEntry> snapshot() => List.unmodifiable(_buffer);

  void debug(String tag, String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.debug, tag, message, error: error, stackTrace: stackTrace);
  }

  void info(String tag, String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.info, tag, message, error: error, stackTrace: stackTrace);
  }

  void warn(String tag, String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.warn, tag, message, error: error, stackTrace: stackTrace);
  }

  void error(String tag, String message, {Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, tag, message, error: error, stackTrace: stackTrace);
  }

  void _log(
    LogLevel level,
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      level: level,
      tag: tag,
      message: message,
      error: error,
      stackTrace: stackTrace,
    );
    _buffer.addLast(entry);
    while (_buffer.length > maxEntries) {
      _buffer.removeFirst();
    }
    if (!_controller.isClosed) {
      _controller.add(entry);
    }
    // En debug : tout va à la console. En release : seulement info+ (debug est skip).
    if (kDebugMode || level != LogLevel.debug) {
      debugPrint(entry.format());
    }
  }

  /// Efface le buffer mémoire (l'écran journal sera vidé via stream).
  void clear() {
    _buffer.clear();
  }

  /// Exporte le buffer dans un fichier texte sous le dossier documents.
  /// Retourne le chemin du fichier créé. Pour partage : passer ce chemin
  /// à `share_plus`.
  Future<String> exportToFile() async {
    final dir = await getApplicationDocumentsDirectory();
    final ts = DateTime.now().toIso8601String().replaceAll(':', '-');
    final filePath = '${dir.path}${Platform.pathSeparator}transportdno-logs-$ts.txt';
    final file = File(filePath);
    final sink = file.openWrite();
    try {
      sink.writeln('TransportDNO log export');
      sink.writeln('Generated: ${DateTime.now().toIso8601String()}');
      sink.writeln('Entries: ${_buffer.length}');
      sink.writeln('--------------------------------------------------');
      for (final entry in _buffer) {
        sink.writeln(entry.format());
      }
    } finally {
      await sink.flush();
      await sink.close();
    }
    return filePath;
  }
}
