import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/mergro_app.dart';

/// App entry point: wraps the app in a Riverpod [ProviderScope].
void main() {
  runApp(const ProviderScope(child: MergroApp()));
}
