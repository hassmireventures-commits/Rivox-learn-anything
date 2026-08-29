import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/firebase_availability.dart';

final firebaseConfiguredProvider = Provider<bool>((ref) => isFirebaseConfigured);
