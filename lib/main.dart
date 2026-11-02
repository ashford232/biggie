import 'package:biggie/app/app.dart';
import 'package:biggie/app/services/app_provider.dart';
import 'package:biggie/shared/themes/app_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lite_router/lite_router.dart';

void main() {
  runApp(const ProviderScope(child: Biggie()));
}

final router = LiteRouter();

class Biggie extends ConsumerWidget {
  const Biggie({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(appProvider).themeMode;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: router.navigatorKey,
      title: "Biggie",
      home: App(),
      themeMode: themeMode,
      theme: AppThemes.light,
      darkTheme: AppThemes.dark,
    );
  }
}
