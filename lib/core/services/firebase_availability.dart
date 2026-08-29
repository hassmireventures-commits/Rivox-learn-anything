import '../../firebase_options.dart';

/// Whether Firebase is configured with real credentials (not placeholders).
bool get isFirebaseConfigured => DefaultFirebaseOptions.isConfigured;
