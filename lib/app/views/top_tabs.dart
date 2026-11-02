import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:biggie/app/services/app_provider.dart';

class TopTabs extends ConsumerWidget {
  const TopTabs({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final appNotifier = ref.watch(appProvider.notifier);
    final fileService = ref.watch(fileServiceProvider);

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          MenuAnchor(
            builder: (context, controller, child) {
              return HoverButton(
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                child: const Text('File'),
              );
            },
            menuChildren: [
              MenuItemButton(
                style: MenuItemButton.styleFrom(
                  minimumSize: Size(20, 25),
                  shape: RoundedRectangleBorder(),
                ),
                onPressed: () async {
                  final res = await fileService.getDirPath();
                  if (res != null && res.isNotEmpty) {
                    appNotifier.changeTarget(res);
                  }
                },
                child: const Text('Open Directory...'),
              ),
            ],
          ),

          const SizedBox(width: 2),

          MenuAnchor(
            builder: (context, controller, child) {
              return HoverButton(
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                child: const Text('Options'),
              );
            },
            menuChildren: [
              MenuItemButton(
                style: MenuItemButton.styleFrom(
                  minimumSize: Size(20, 25),
                  shape: RoundedRectangleBorder(),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => const SettingsDialog(),
                  );
                },
                child: const Text('Settings...'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HoverButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const HoverButton({super.key, required this.onPressed, required this.child});

  @override
  State<HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<HoverButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _isHovered
                ? theme.colorScheme.actionButtonHover()
                : Colors.transparent,
            borderRadius: BorderRadius.circular(3),
          ),
          child: DefaultTextStyle(
            style: theme.textTheme.bodySmall!.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

extension on ColorScheme {
  Color actionButtonHover() => surfaceContainerHighest.withValues(alpha: 0.6);
}

class SettingsDialog extends ConsumerStatefulWidget {
  const SettingsDialog({super.key});

  @override
  ConsumerState<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends ConsumerState<SettingsDialog> {
  AppState get app => ref.watch(appProvider);
  int _scanLimit = 1000;
  bool _isDarkMode = false;
  bool _skipHiddenFiles = true;

  @override
  void initState() {
    super.initState();
    _scanLimit = app.limits;
    _isDarkMode = app.themeMode.isDark;
    _skipHiddenFiles = app.skipHiddenFiles;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          4,
        ), // Native sharp-ish desktop corners
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
          width: 1,
        ),
      ),
      backgroundColor: theme.colorScheme.surface,
      elevation: 8,
      titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      title: Text(
        'Settings',
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Native Option Row: Dark Theme
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Dark Theme', style: theme.textTheme.bodySmall),
                Switch(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: _isDarkMode,
                  onChanged: (val) {
                    setState(() {
                      _isDarkMode = val;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Native Option Row: Skip Hidden Files
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Skip Hidden Files', style: theme.textTheme.bodySmall),
                Switch(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  value: _skipHiddenFiles,
                  onChanged: (val) {
                    setState(() {
                      _skipHiddenFiles = val;
                    });
                  },
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Scan Limit Items', style: theme.textTheme.bodySmall),
                Text(
                  _scanLimit == 0 ? 'Unlimited' : '$_scanLimit',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
              ),
              child: Slider(
                value: _scanLimit.toDouble(),
                min: 100,
                max: 10000,
                divisions: 99,
                onChanged: (val) {
                  setState(() {
                    _scanLimit = val.round();
                  });
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        SizedBox(
          height: 28,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel', style: TextStyle(fontSize: 12)),
          ),
        ),
        SizedBox(
          height: 28,
          child: FilledButton(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            onPressed: () {
              final app = ref.watch(appProvider.notifier);
              app.changeLimit(_scanLimit);
              app.changeTheme(_isDarkMode ? ThemeMode.dark : ThemeMode.light);
              app.skipHidden(_skipHiddenFiles);
              Navigator.of(context).pop();
            },
            child: const Text('Save', style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }
}
