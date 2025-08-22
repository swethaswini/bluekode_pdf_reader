import 'package:flutter/material.dart';
import '../presentation/library_screen/library_screen.dart';
import '../presentation/ask_screen/ask_screen.dart';
import '../presentation/insights_screen/insights_screen.dart';
import '../presentation/authentication_screen/authentication_screen.dart';
import '../presentation/document_viewer_screen/document_viewer_screen.dart';
import '../presentation/import_scan_screen/import_scan_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String library = '/library-screen';
  static const String ask = '/ask-screen';
  static const String insights = '/insights-screen';
  static const String authentication = '/authentication-screen';
  static const String documentViewer = '/document-viewer-screen';
  static const String importScan = '/import-scan-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const LibraryScreen(),
    library: (context) => const LibraryScreen(),
    ask: (context) => const AskScreen(),
    insights: (context) => const InsightsScreen(),
    authentication: (context) => const AuthenticationScreen(),
    documentViewer: (context) => const DocumentViewerScreen(),
    importScan: (context) => const ImportScanScreen(),
    // TODO: Add your other routes here
  };
}
