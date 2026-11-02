import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class FileService {
  Future<String?> getDirPath() async {
    return await getDirectoryPath();
  }

  Future<bool> pathExist(String path) async {
    return await Directory(path).exists();
  }

  Future<void> openLocalFolder(String absolutePath) async {
    final fileSystemEntity = FileSystemEntity.typeSync(absolutePath);

    // If the path doesn't exist at all, exit early to prevent crashes
    if (fileSystemEntity == FileSystemEntityType.notFound) {
      debugPrint("Path does not exist: $absolutePath");
      return;
    }

    // Check if it's a file or a directory
    final bool isFile = fileSystemEntity == FileSystemEntityType.file;

    if (Platform.isWindows) {
      try {
        if (isFile) {
          // Windows specific: /select instructs explorer to highlight the file inside its directory
          await Process.run('explorer.exe', ['/select,', absolutePath]);
        } else {
          await Process.run('explorer.exe', [absolutePath]);
        }
        return; // Handled successfully via native processes
      } catch (e) {
        debugPrint("Windows Process fallback failed: $e");
      }
    }

    if (Platform.isMacOS) {
      try {
        if (isFile) {
          // macOS specific: -R (reveal) opens Finder and selects the target file
          await Process.run('open', ['-R', absolutePath]);
        } else {
          await Process.run('open', [absolutePath]);
        }
        return;
      } catch (e) {
        debugPrint("macOS Process fallback failed: $e");
      }
    }

    // Cross-platform Fallback (Linux/Mobile): Extract the parent directory path if it's a file
    String targetFolder = absolutePath;
    if (isFile) {
      targetFolder = File(absolutePath).parent.path;
    }

    final Uri folderUri = Uri.directory(targetFolder);
    if (await canLaunchUrl(folderUri)) {
      await launchUrl(folderUri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("Could not open folder location for: $absolutePath");
    }
  }
}
