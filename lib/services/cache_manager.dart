import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class AdvancedCacheManager {
  static final AdvancedCacheManager _instance = AdvancedCacheManager._internal();
  factory AdvancedCacheManager() => _instance;
  AdvancedCacheManager._internal();

  Directory? _videoCacheDir;
  Directory? _subtitleCacheDir;
  Directory? _thumbnailCacheDir;
  Directory? _tempCacheDir;

  final StreamController<CacheStats> _statsController = StreamController.broadcast();
  Stream<CacheStats> get statsStream => _statsController.stream;

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final tempDir = await getTemporaryDirectory();
      final cacheDir = await getApplicationCacheDirectory();

      _videoCacheDir = Directory(path.join(cacheDir.path, 'videos'));
      _subtitleCacheDir = Directory(path.join(cacheDir.path, 'subtitles'));
      _thumbnailCacheDir = Directory(path.join(cacheDir.path, 'thumbnails'));
      _tempCacheDir = Directory(path.join(tempDir.path, 'temp_cache'));

      await _videoCacheDir!.create(recursive: true);
      await _subtitleCacheDir!.create(recursive: true);
      await _thumbnailCacheDir!.create(recursive: true);
      await _tempCacheDir!.create(recursive: true);

      _isInitialized = true;
      debugPrint('Cache Manager initialized');
    } catch (e) {
      debugPrint('Cache init error: $e');
      _isInitialized = true;
    }
  }

  Future<File?> get(String key, CacheType type) async {
    if (!_isInitialized) await initialize();

    try {
      final dir = _getCacheDirectory(type);
      final file = File(path.join(dir.path, _sanitize(key)));

      if (await file.exists()) {
        return file;
      }
    } catch (e) {
      debugPrint('Cache get error: $e');
    }

    return null;
  }

  Future<void> put(String key, File file, CacheType type) async {
    if (!_isInitialized) await initialize();

    try {
      final dir = _getCacheDirectory(type);
      final cached = File(path.join(dir.path, _sanitize(key)));
      await file.copy(cached.path);
      debugPrint('Cached: $key');
    } catch (e) {
      debugPrint('Cache put error: $e');
    }
  }

  Future<void> clearCache(CacheType type) async {
    if (!_isInitialized) await initialize();

    try {
      final dir = _getCacheDirectory(type);

      if (await dir.exists()) {
        await for (var entity in dir.list()) {
          if (entity is File) {
            await entity.delete();
          }
        }
      }

      debugPrint('Cleared ${type.name} cache');
    } catch (e) {
      debugPrint('Clear cache error: $e');
    }
  }

  Future<void> clearAllCaches() async {
    for (var type in CacheType.values) {
      await clearCache(type);
    }
  }

  Future<CacheStats> getStats() async {
    if (!_isInitialized) await initialize();

    int totalSize = 0;
    int videoCount = 0;
    int subtitleCount = 0;

    try {
      totalSize += await _getDirSize(_videoCacheDir!);
      totalSize += await _getDirSize(_subtitleCacheDir!);
      totalSize += await _getDirSize(_thumbnailCacheDir!);
      totalSize += await _getDirSize(_tempCacheDir!);

      videoCount = await _countFiles(_videoCacheDir!);
      subtitleCount = await _countFiles(_subtitleCacheDir!);
    } catch (e) {
      debugPrint('Stats error: $e');
    }

    return CacheStats(
      memorySize: 0,
      diskSize: totalSize,
      memoryEntries: 0,
      videoCount: videoCount,
      subtitleCount: subtitleCount,
      thumbnailCount: 0,
      memoryHits: 0,
      diskHits: 0,
      misses: 0,
    );
  }

  Future<int> _getDirSize(Directory dir) async {
    int size = 0;
    try {
      await for (var entity in dir.list(recursive: true)) {
        if (entity is File) {
          size += await entity.length();
        }
      }
    } catch (e) {
      debugPrint('Dir size error: $e');
    }
    return size;
  }

  Future<int> _countFiles(Directory dir) async {
    int count = 0;
    try {
      await for (var entity in dir.list()) {
        if (entity is File) count++;
      }
    } catch (e) {
      debugPrint('Count error: $e');
    }
    return count;
  }

  Directory _getCacheDirectory(CacheType type) {
    switch (type) {
      case CacheType.video:
        return _videoCacheDir!;
      case CacheType.subtitle:
        return _subtitleCacheDir!;
      case CacheType.thumbnail:
        return _thumbnailCacheDir!;
      case CacheType.temp:
        return _tempCacheDir!;
    }
  }

  String _sanitize(String key) {
    return key.replaceAll(RegExp(r'[^\w\s-]'), '_');
  }

  void dispose() {
    _statsController.close();
  }
}

enum CacheType {
  video,
  subtitle,
  thumbnail,
  temp,
}

class CacheStats {
  final int memorySize;
  final int diskSize;
  final int memoryEntries;
  final int videoCount;
  final int subtitleCount;
  final int thumbnailCount;
  final int memoryHits;
  final int diskHits;
  final int misses;

  CacheStats({
    required this.memorySize,
    required this.diskSize,
    required this.memoryEntries,
    required this.videoCount,
    required this.subtitleCount,
    required this.thumbnailCount,
    required this.memoryHits,
    required this.diskHits,
    required this.misses,
  });

  double get hitRate {
    final total = memoryHits + diskHits + misses;
    return total > 0 ? (memoryHits + diskHits) / total : 0;
  }

  int get totalSize => memorySize + diskSize;
}