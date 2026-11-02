import 'package:biggie/app/views/main_view.dart';
import 'package:biggie/app/views/status_bar.dart';
import 'package:biggie/app/views/top_tabs.dart';
import 'package:biggie/app/views/top_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      body: Column(
        children: [
          TopTabs(),
          TopView(),
          Expanded(child: MainView()),
          Divider(height: 1),
          StatusBar(),
        ],
      ),
    );
  }
}
