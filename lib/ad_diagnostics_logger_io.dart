import 'dart:io';

import 'ad_diagnostics_logger_base.dart';

AdDiagnosticsLogger createAdDiagnosticsLogger() => IoAdDiagnosticsLogger();

class IoAdDiagnosticsLogger implements AdDiagnosticsLogger {
  File get _file {
    final home = Platform.environment['HOME'];
    final directory = home == null || home.isEmpty
        ? Directory.systemTemp
        : Directory('$home/Documents');
    return File('${directory.path}/animal_kings_admob_diagnostics.log');
  }

  @override
  Future<void> writeLines(List<String> lines) async {
    final timestamp = DateTime.now().toIso8601String();
    final buffer = StringBuffer();
    for (final line in lines) {
      buffer.writeln('$timestamp [AdMob] $line');
    }

    try {
      final file = _file;
      await file.parent.create(recursive: true);
      await file.writeAsString(
        buffer.toString(),
        mode: FileMode.append,
        flush: true,
      );
    } catch (error) {
      stderr.writeln('[AdMob] File logging failed: $error');
    }
  }
}
