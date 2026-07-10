import 'ad_diagnostics_logger_base.dart';
import 'ad_diagnostics_logger_stub.dart'
    if (dart.library.io) 'ad_diagnostics_logger_io.dart'
    as impl;

export 'ad_diagnostics_logger_base.dart';

AdDiagnosticsLogger createAdDiagnosticsLogger() =>
    impl.createAdDiagnosticsLogger();
