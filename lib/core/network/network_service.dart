import 'package:connectivity_plus/connectivity_plus.dart';

import '../error/app_exception.dart';

class NetworkService {
  NetworkService._();

  static final NetworkService instance = NetworkService._();
  final Connectivity _connectivity = Connectivity();

  Future<bool> hasConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.any((r) => r != ConnectivityResult.none);
    } catch (_) {
      // connectivity_plus can throw on some platforms (e.g. desktop) or when
      // network info is unavailable. Treat as connected so generation is not
      // silently blocked - the real HTTP call will surface a real error.
      return true;
    }
  }

  /// Checks connectivity and throws [NoInternetException] only when the
  /// device is definitively offline. False negatives from [connectivity_plus]
  /// (e.g. on Windows) are treated as connected.
  Future<void> ensureConnected() async {
    if (!await hasConnection()) {
      throw const NoInternetException();
    }
  }
}
