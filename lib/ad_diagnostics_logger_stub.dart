import 'ad_diagnostics_logger_base.dart';

AdDiagnosticsLogger createAdDiagnosticsLogger() =>
    const NoopAdDiagnosticsLogger();

class NoopAdDiagnosticsLogger implements AdDiagnosticsLogger {
  const NoopAdDiagnosticsLogger();

  @override
  Future<void> writeLines(List<String> lines) async {}
}
