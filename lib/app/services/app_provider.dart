// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import 'package:biggie/app/services/file_service.dart';
import 'package:biggie/app/services/storage_service.dart';
import 'package:biggie/shared/models/result.dart';

final appProvider = NotifierProvider(() => AppProvider());
final fileServiceProvider = Provider((ref) => FileService());
final storageServiceProvider = Provider((ref) => StorageService());
final totalSizeProvider = FutureProvider.family<int, String>(
  (ref, path) => ref.watch(storageServiceProvider).getFolderSize(path),
);

class AppProvider extends Notifier<AppState> {
  @override
  AppState build() {
    return AppState();
  }

  void changeTarget(String target) {
    state = state.copyWith(target: target);
  }

  void scan(bool val) {
    state = state.copyWith(scanning: val);
  }

  void fileInputValue(List<Result> results) {
    state = state.copyWith(fileResults: results);
  }

  void folderInputValue(List<Result> results) {
    state = state.copyWith(folderResults: results);
  }

  void changeLimit(int limit) {
    state = state.copyWith(limits: limit);
  }

  void changeTheme(ThemeMode theme) {
    state = state.copyWith(themeMode: theme);
  }

  void skipHidden(bool val) {
    state = state.copyWith(skipHiddenFiles: val);
  }

  void addLog(Log log) {
    state = state.copyWith(logs: [...state.logs, log]);
  }

  void clearLogs() {
    state = state.copyWith(logs: []);
  }
}

class AppState {
  final String target;
  final bool scanning;

  final List<Result> fileResults;
  final List<Result> folderResults;

  final ThemeMode themeMode;
  final bool skipHiddenFiles;
  final int limits;
  final List<Log> logs;

  AppState({
    this.target = "",
    this.scanning = false,
    this.fileResults = const [],
    this.folderResults = const [],
    this.themeMode = .light,
    this.skipHiddenFiles = true,
    this.limits = 10000,
    this.logs = const [],
  });
  bool get initialized => target.trim() != '';
  String? get dirName => p.basename(target);
  String? get prefixPath => p.rootPrefix(target);

  AppState copyWith({
    String? target,
    bool? scanning,
    List<Result>? fileResults,
    List<Result>? folderResults,
    List<Log>? logs,
    ThemeMode? themeMode,
    bool? skipHiddenFiles,
    int? limits,
  }) {
    return AppState(
      target: target ?? this.target,
      scanning: scanning ?? this.scanning,
      fileResults: fileResults ?? this.fileResults,
      folderResults: folderResults ?? this.folderResults,
      themeMode: themeMode ?? this.themeMode,
      skipHiddenFiles: skipHiddenFiles ?? this.skipHiddenFiles,
      limits: limits ?? this.limits,
      logs: logs ?? this.logs,
    );
  }
}
