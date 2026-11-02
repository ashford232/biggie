import 'package:biggie/app/services/app_provider.dart';
import 'package:biggie/app/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatusBar extends ConsumerStatefulWidget {
  const StatusBar({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StatusBarState();
}

class _StatusBarState extends ConsumerState<StatusBar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = ref.watch(appProvider);
    final storageService = ref.read(storageServiceProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: .end,
        crossAxisAlignment: .end,
        children: [
          Expanded(child: _buildItemsRow(context, storageService, app)),
        ],
      ),
    );
  }

  Widget _buildItemsRow(
    BuildContext context,
    StorageService storageService,
    AppState app,
  ) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: .end,
      children: [
        Text(
          'Info:',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 10),
        app.initialized
            ? Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Text(
                  app.scanning ? "Scanning..." : "Ready",
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
              )
            : Text("-", style: theme.textTheme.bodySmall),
      ],
    );
  }
}
