import 'dart:io';

import 'package:biggie/app/services/app_provider.dart';
import 'package:biggie/shared/models/result.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons_pro/hugeicons.dart';
import 'package:path/path.dart' as p;

class TopView extends ConsumerStatefulWidget {
  const TopView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TopViewState();
}

class _TopViewState extends ConsumerState<TopView> {
  int total = 0;
  int done = 0;
  bool finished = false;
  Stopwatch? _scanStopwatch;

  String _getRemainingTimeText() {
    if (finished) return "Done";
    if (!ref.read(appProvider).scanning || total == 0 || done == 0) {
      return "";
    }

    if (_scanStopwatch == null || !_scanStopwatch!.isRunning) {
      return "Calculating remaining time...";
    }

    final elapsedSeconds = _scanStopwatch!.elapsedMilliseconds / 1000.0;
    if (elapsedSeconds < 1.0) return "Calculating remaining time...";

    final itemsPerSecond = done / elapsedSeconds;
    if (itemsPerSecond <= 0) return "Calculating remaining time...";

    final remainingItems = total - done;
    final remainingSeconds = remainingItems / itemsPerSecond;

    if (remainingSeconds < 60) {
      return "approx ${remainingSeconds.ceil()} seconds remaining";
    } else if (remainingSeconds < 3600) {
      final minutes = (remainingSeconds / 60).ceil();
      return "approx $minutes ${minutes == 1 ? 'minute' : 'minutes'} remaining";
    } else {
      final hours = (remainingSeconds / 3600).toStringAsFixed(1);
      return "approx $hours hours remaining";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final app = ref.watch(appProvider);
    final appNotifier = ref.read(appProvider.notifier);
    final fileService = ref.watch(fileServiceProvider);
    final storageService = ref.read(storageServiceProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 650),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: app.scanning
                                  ? null
                                  : () async {
                                      final res = await fileService
                                          .getDirPath();
                                      if (res != null && res.isNotEmpty) {
                                        appNotifier.changeTarget(res);
                                      }
                                    },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      theme.colorScheme.surfaceContainerLowest,
                                  border: Border.all(
                                    color: theme.colorScheme.outlineVariant,
                                    width: 0.5,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        !app.initialized
                                            ? "Select Directory"
                                            : (app.dirName ?? ""),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      HugeIconsStroke.arrowDown01,
                                      size: 18,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 32,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                backgroundColor:
                                    theme.colorScheme.surfaceContainerHighest,
                                foregroundColor: theme.colorScheme.onSurface,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              onPressed: app.scanning
                                  ? null
                                  : () async {
                                      if (!app.initialized) {
                                        final res = await fileService
                                            .getDirPath();
                                        if (res != null && res.isNotEmpty) {
                                          appNotifier.changeTarget(res);
                                        }
                                      } else {
                                        setState(() {
                                          finished = false;
                                          done = 0;
                                          total = 0;
                                          _scanStopwatch = Stopwatch()..start();
                                        });

                                        appNotifier.fileInputValue([]);
                                        appNotifier.folderInputValue([]);
                                        appNotifier.scan(true);
                                        appNotifier.clearLogs();

                                        final entities = await storageService
                                            .getEntities(
                                              app.target,
                                              limit: app.limits,
                                              skipHidden: app.skipHiddenFiles,
                                            );

                                        final rootSize = await storageService
                                            .getFolderSize(app.target);

                                        setState(() {
                                          total = entities.length;
                                        });

                                        List<Result> fileResults = [];
                                        List<Result> folderResults = [];

                                        for (final en in entities) {
                                          if (!ref.read(appProvider).scanning) {
                                            break;
                                          }

                                          try {
                                            final isFolder = en is Directory;
                                            final path = en.path;
                                            final name = p.basename(path);

                                            int? size = isFolder
                                                ? await storageService
                                                      .getFolderSize(path)
                                                : await storageService
                                                      .getFileSize(path);

                                            final double percentage =
                                                (rootSize > 0)
                                                ? (size * 100) / rootSize
                                                : 0.0;

                                            final resItem = Result(
                                              path: path,
                                              name: name,
                                              size: size,
                                              percentage: percentage,
                                            );

                                            if (isFolder) {
                                              folderResults.add(resItem);
                                            } else {
                                              fileResults.add(resItem);
                                            }
                                            final log = Log(
                                              log: "$name $path",
                                              okay: true,
                                              createdAt: DateTime.now(),
                                            );
                                            appNotifier.addLog(log);

                                            done++;

                                            if (done % 5 == 0 ||
                                                done == total) {
                                              appNotifier.fileInputValue(
                                                List.from(fileResults),
                                              );
                                              appNotifier.folderInputValue(
                                                List.from(folderResults),
                                              );

                                              if (mounted) {
                                                setState(() {});
                                              }
                                            }
                                          } on FileSystemException catch (err) {
                                            final isFolder = en is Directory;
                                            if (!isFolder) {
                                              final log = Log(
                                                log: "$err",
                                                okay: false,
                                                createdAt: DateTime.now(),
                                              );
                                              appNotifier.addLog(log);
                                            }
                                          } catch (err) {
                                            debugPrint(err.toString());
                                          }
                                        }

                                        // Final confirmation dispatch
                                        appNotifier.fileInputValue(
                                          List.from(fileResults),
                                        );
                                        appNotifier.folderInputValue(
                                          List.from(folderResults),
                                        );

                                        _scanStopwatch?.stop();
                                        if (mounted) {
                                          appNotifier.scan(false);
                                          setState(() {
                                            finished = true;
                                          });
                                        }
                                      }
                                    },
                              child: Text(!app.initialized ? "Select" : "Scan"),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),

                      Row(
                        children: [
                          if (app.scanning) ...[
                            const CupertinoActivityIndicator(radius: 6),
                            const SizedBox(width: 5),
                          ],
                          Text(
                            _getRemainingTimeText(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          minHeight: 6,
                          color: finished ? Colors.green : null,
                          value: app.initialized
                              ? app.scanning
                                    ? (total > 0 ? (done / total) : null)
                                    : finished
                                    ? 1.0
                                    : 0.0
                              : 0.0,
                          backgroundColor:
                              theme.colorScheme.surfaceContainerHighest,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: VerticalDivider(
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.6,
                    ),
                    thickness: 1,
                    width: 1,
                  ),
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildDetailRow(
                        context,
                        label: 'Selection:',
                        value: app.initialized ? (app.prefixPath ?? '') : '-',
                      ),
                      const SizedBox(height: 4),
                      _buildDetailRow(
                        context,
                        label: 'Path:',
                        value: app.initialized ? app.target : '-',
                      ),
                      const SizedBox(height: 4),
                      _buildStorageRow(context, storageService, app),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStorageRow(
    BuildContext context,
    dynamic storageService,
    dynamic app,
  ) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            'Total Space:',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: app.initialized
              ? ref
                    .watch(totalSizeProvider(app.target))
                    .when(
                      data: (size) {
                        return Text(
                          storageService.formatBytes(size, 2),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                      error: (err, st) => const Text('-'),
                      loading: () => const SizedBox(
                        height: 12,
                        width: 12,
                        child: CupertinoActivityIndicator(radius: 6),
                      ),
                    )
              : const Text('-'),
        ),
      ],
    );
  }
}
