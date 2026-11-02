import 'dart:io';

import 'package:flutter/material.dart';

class StorageService {
  Future<int> getFileSize(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  Future<int> getFolderSize(String folderPath) async {
    final directory = Directory(folderPath);
    int totalSize = 0;

    if (await directory.exists()) {
      try {
        await for (final entity in directory.list(
          recursive: true,
          followLinks: false,
        )) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      } catch (e) {
        debugPrint("Error reading directory: $e");
      }
    }
    return totalSize;
  }

  Future<List<FileSystemEntity>> getEntities(
    String folderPath, {
    int? limit = 1000,
    bool skipHidden = true,
  }) async {
    final directory = Directory(folderPath);
    final List<FileSystemEntity> items = [];

    if (!await directory.exists()) {
      return [];
    }

    try {
      await _collectEntitiesRecursive(directory, items, limit, skipHidden);
    } catch (e) {
      debugPrint("Error reading directory: $e");
    }

    return items;
  }

  Future<void> _collectEntitiesRecursive(
    Directory dir,
    List<FileSystemEntity> items,
    int? limit,
    bool skipHidden,
  ) async {
    if (limit != null && items.length >= limit) return;

    try {
      await for (final entity in dir.list(followLinks: false)) {
        if (limit != null && items.length >= limit) break;

        final name = entity.uri.pathSegments.where((s) => s.isNotEmpty).last;

        if (skipHidden && name.startsWith('.')) {
          continue;
        }

        if (entity is Directory) {
          if (name == 'build' ||
              name == '.dart_tool' ||
              name == '.git' ||
              name == 'node_modules') {
            continue; // Skip scanning inside these folders
          }
        }

        items.add(entity);

        if (entity is Directory) {
          await _collectEntitiesRecursive(entity, items, limit, skipHidden);
        }
      }
    } catch (e) {
      debugPrint("Skipping restricted or broken path: $e");
    }
  }

  String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (bytes / 1024).floor() == 0 ? 0 : (bytes).toString().length ~/ 3.1;
    if (i >= suffixes.length) i = suffixes.length - 1;

    double size = bytes / (1 << (10 * i));
    return "${size.toStringAsFixed(decimals)} ${suffixes[i]}";
  }
}
