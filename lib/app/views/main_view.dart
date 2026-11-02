import 'dart:io';

import 'package:biggie/app/services/app_provider.dart';
import 'package:biggie/shared/models/result.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';

class MainView extends ConsumerStatefulWidget {
  const MainView({super.key});

  @override
  ConsumerState<MainView> createState() => _MainViewState();
}

class _MainViewState extends ConsumerState<MainView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = ref.watch(appProvider);
    final appNotifier = ref.watch(appProvider.notifier);
    final storageService = ref.read(storageServiceProvider);
    final fileService = ref.read(fileServiceProvider);

    final sortedFilesResults = List<Result>.from(app.fileResults)
      ..sort((a, b) => b.size.compareTo(a.size));

    return Column(
      children: [
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLowest,
            border: Border(
              bottom: BorderSide(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelStyle: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: theme.textTheme.bodySmall,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            indicatorSize: TabBarIndicatorSize.label,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                width: 2,
                color: theme.colorScheme.primary,
              ),
            ),
            tabs: [
              Tab(text: 'Files (${app.fileResults.length})'),
              const Tab(text: 'Logs'),
            ],
          ),
        ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Files View
              _buildFilesView(
                context: context,
                results: sortedFilesResults,
                isEmpty: app.fileResults.isEmpty,
                isScanning: app.scanning,
                isInitialized: app.initialized,
                storageService: storageService,
                fileService: fileService,
              ),

              // Tab 2: Logs View
              _buildLogsView(
                context: context,
                app: app,
                appNotifier: appNotifier,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilesView({
    required BuildContext context,
    required List<Result> results,
    required bool isEmpty,
    required bool isScanning,
    required bool isInitialized,
    required dynamic storageService,
    required dynamic fileService,
  }) {
    final theme = Theme.of(context);

    if (isEmpty || isScanning) {
      return Container(
        color: theme.colorScheme.surface,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isScanning
                      ? HugeIconsStroke.loading01
                      : !isInitialized
                      ? HugeIconsStroke.folder01
                      : HugeIconsStroke.fileEmpty02,
                  size: 64,
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  isScanning
                      ? 'Scanning files...'
                      : isInitialized
                      ? ''
                      : 'Select a directory and scan to view files',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: DataTable2(
          columnSpacing: 16,
          horizontalMargin: 12,
          minWidth: 700,
          headingRowColor: WidgetStateProperty.all(
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          ),
          columns: [
            DataColumn2(
              label: Text(
                'File Name',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              size: ColumnSize.L,
            ),
            DataColumn(
              label: Text(
                'Path',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            DataColumn(
              label: Text(
                '% Usage',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              numeric: true,
            ),
            DataColumn(
              label: Text(
                'Size',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              numeric: true,
            ),
          ],
          rows: results.map((result) {
            final path = result.path;
            final name = result.path.split(Platform.pathSeparator).last;

            return DataRow(
              cells: [
                DataCell(
                  Row(
                    children: [
                      Icon(
                        HugeIconsStroke.file01,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                DataCell(
                  InkWell(
                    onTap: () async {
                      await fileService.openLocalFolder(path);
                    },
                    child: Text(
                      path,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    "${result.percentage.toStringAsFixed(2)}%",
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                DataCell(
                  Text(
                    storageService.formatBytes(result.size, 2),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLogsView({
    required BuildContext context,
    required AppState app,
    required AppProvider appNotifier,
  }) {
    final theme = Theme.of(context);
    final logs = app.logs;

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onPressed: () {
                  appNotifier.clearLogs();
                },
                icon: const Icon(Icons.clear_all, size: 14),
                label: const Text('Clear', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.4,
                  ),
                ),
              ),
              child: ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[index];
                  // if (log.okay) {
                  //   return SizedBox();
                  // }
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '[${log.createdAt.toLocal().toString().split('.').first}] ${log.log}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: !log.okay
                            ? theme.colorScheme.error
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
