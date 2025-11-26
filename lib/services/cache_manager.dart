import 'dart:io';
import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Advanced Multi-Layer Cache Manager
/// Implements LRU + LFU hybrid algorithm with memory and disk caching

class AdvancedCacheManager {
  static final AdvancedCacheManager _instance = AdvancedCacheManager._internal();
  factory AdvancedCacheManager() => _instance;
  AdvancedCacheManager._internal();

  // Memory Cache (Level 1 - Fastest)
  final LinkedHashMap<String, CacheEntry> _memoryCache = LinkedHashMap();

  // Disk Cache directories
  Directory? _videoCacheDir;
  Directory? _subtitleCacheDir;
  Directory? _thumbnailCacheDir;
  Directory? _tempCacheDir;

  // Cache configuration
  static const int maxMemoryCacheSize = 50 * 1024 * 1024; // 50 MB
  static const int maxDiskCacheSize = 500 * 1024 * 1024; // 500 MB
  static const int maxMemoryEntries = 20;
  static const Duration cacheExpiration = Duration(days: 7);

  // Cache statistics
  int _memoryHits = 0;
  int _diskHits = 0;
  int _misses = 0;
  int _currentMemorySize = 0;

  final StreamController<CacheStats> _statsController = StreamController.broadcast();
  Stream<CacheStats> get statsStream => _statsController.stream;

  bool _isInitialized = false;

  /// Initialize cache system
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

      // Clean expired cache on startup
      _cleanExpiredCache();

      debugPrint('✅ Advanced Cache Manager initialized');
    } catch (e) {
      debugPrint('❌ Cache initialization error: $e');
    }
  }

  /// Get from cache with automatic fallback
  Future<File?> get(String key, CacheType type) async {
    if (!_isInitialized) await initialize();

    // Level 1: Memory Cache
    final memEntry = _memoryCache[key];
    if (memEntry != null && !memEntry.isExpired) {
      _memoryHits++;
      memEntry.incrementAccess();
      _updateStats();
      return memEntry.file;
    }

    // Level 2: Disk Cache
    final diskFile = await _getFromDisk(key, type);
    if (diskFile != null && await diskFile.exists()) {
      _diskHits++;
      _updateStats();

      // Promote to memory cache
      _putInMemoryCache(key, diskFile);

      return diskFile;
    }

    _misses++;
    _updateStats();
    return null;
  }

  /// Put file in cache with intelligent storage
  Future<void> put(String key, File file, CacheType type) async {
    if (!_isInitialized) await initialize();

    try {
      // Put in disk cache
      final cachedFile = await _putInDiskCache(key, file, type);

      // Put in memory cache
      _putInMemoryCache(key, cachedFile);

      debugPrint('✅ Cached: $key (${await file.length()} bytes)');
    } catch (e) {
      debugPrint('❌ Cache put error: $e');
    }
  }

  /// Memory cache with LRU + LFU hybrid
  void _putInMemoryCache(String key, File file) {
    try {
      final fileSize = file.lengthSync();

      // Check if we need to evict
      while (_memoryCache.length >= maxMemoryEntries ||
          _currentMemorySize + fileSize > maxMemoryCacheSize) {
        _evictLeastValuable();
      }

      final entry = CacheEntry(
        file: file,
        size: fileSize,
        timestamp: DateTime.now(),
      );

      _memoryCache[key] = entry;
      _currentMemorySize += fileSize;
    } catch (e) {
      debugPrint('❌ Memory cache error: $e');
    }
  }

  /// LRU + LFU hybrid eviction
  void _evictLeastValuable() {
    if (_memoryCache.isEmpty) return;

    String? keyToEvict;
    double lowestScore = double.infinity;

    for (var entry in _memoryCache.entries) {
      final score = entry.value.calculateScore();
      if (score < lowestScore) {
        lowestScore = score;
        keyToEvict = entry.key;
      }
    }

    if (keyToEvict != null) {
      final removed = _memoryCache.remove(keyToEvict);
      if (removed != null) {
        _currentMemorySize -= removed.size;
      }
    }
  }

  /// Disk cache operations
  Future<File> _putInDiskCache(String key, File file, CacheType type) async {
    final dir = _getCacheDirectory(type);
    final cachedFile = File(path.join(dir.path, _sanitizeKey(key)));

    await file.copy(cachedFile.path);
    return cachedFile;
  }

  Future<File?> _getFromDisk(String key, CacheType type) async {
    final dir = _getCacheDirectory(type);
    final file = File(path.join(dir.path, _sanitizeKey(key)));

    if (await file.exists()) {
      // Check expiration
      final stats = await file.stat();
      if (DateTime.now().difference(stats.modified) < cacheExpiration) {
        return file;
      } else {
        await file.delete();
      }
    }

    return null;
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

  /// Clear specific cache type
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

      // Clear from memory cache
      _memoryCache.removeWhere((key, value) =>
          value.file.path.contains(dir.path));

      _recalculateMemorySize();

      debugPrint('✅ Cleared ${type.name} cache');
    } catch (e) {
      debugPrint('❌ Clear cache error: $e');
    }
  }

  /// Clear all caches
  Future<void> clearAllCaches() async {
    _memoryCache.clear();
    _currentMemorySize = 0;

    for (var type in CacheType.values) {
      await clearCache(type);
    }

    _updateStats();
  }

  /// Clean expired cache entries
  Future<void> _cleanExpiredCache() async {
    for (var type in CacheType.values) {
      try {
        final dir = _getCacheDirectory(type);

        await for (var entity in dir.list()) {
          if (entity is File) {
            final stats = await entity.stat();
            if (DateTime.now().difference(stats.modified) > cacheExpiration) {
              await entity.delete();
            }
          }
        }
      } catch (e) {
        debugPrint('❌ Clean expired error: $e');
      }
    }
  }

  /// Get cache statistics
  Future<CacheStats> getStats() async {
    if (!_isInitialized) await initialize();

    int totalDiskSize = 0;
    int videoCount = 0;
    int subtitleCount = 0;
    int thumbnailCount = 0;

    try {
      totalDiskSize += await _getDirectorySize(_videoCacheDir!);
      totalDiskSize += await _getDirectorySize(_subtitleCacheDir!);
      totalDiskSize += await _getDirectorySize(_thumbnailCacheDir!);
      totalDiskSize += await _getDirectorySize(_tempCacheDir!);

      videoCount = await _countFiles(_videoCacheDir!);
      subtitleCount = await _countFiles(_subtitleCacheDir!);
      thumbnailCount = await _countFiles(_thumbnailCacheDir!);
    } catch (e) {
      debugPrint('❌ Stats error: $e');
    }

    return CacheStats(
      memorySize: _currentMemorySize,
      diskSize: totalDiskSize,
      memoryEntries: _memoryCache.length,
      videoCount: videoCount,
      subtitleCount: subtitleCount,
      thumbnailCount: thumbnailCount,
      memoryHits: _memoryHits,
      diskHits: _diskHits,
      misses: _misses,
    );
  }

  Future<int> _getDirectorySize(Directory dir) async {
    int size = 0;
    try {
      await for (var entity in dir.list(recursive: true)) {
        if (entity is File) {
          size += await entity.length();
        }
      }
    } catch (e) {
      debugPrint('❌ Directory size error: $e');
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
      debugPrint('❌ Count files error: $e');
    }
    return count;
  }

  void _recalculateMemorySize() {
    _currentMemorySize = 0;
    for (var entry in _memoryCache.values) {
      _currentMemorySize += entry.size;
    }
  }

  void _updateStats() {
    if (!_statsController.isClosed) {
      getStats().then((stats) => _statsController.add(stats));
    }
  }

  String _sanitizeKey(String key) {
    return key.replaceAll(RegExp(r'[^\w\s-]'), '_');
  }

  void dispose() {
    _statsController.close();
  }
}

/// Cache entry with access tracking
class CacheEntry {
  final File file;
  final int size;
  final DateTime timestamp;
  int accessCount = 0;
  DateTime lastAccessed;

  CacheEntry({
    required this.file,
    required this.size,
    required this.timestamp,
  }) : lastAccessed = DateTime.now();

  void incrementAccess() {
    accessCount++;
    lastAccessed = DateTime.now();
  }

  bool get isExpired {
    return DateTime.now().difference(timestamp) >
        AdvancedCacheManager.cacheExpiration;
  }

  /// LRU + LFU hybrid score
  double calculateScore() {
    final recency = DateTime.now().difference(lastAccessed).inSeconds;
    final frequency = accessCount;

    // Lower score = higher priority for eviction
    return (frequency + 1) / (recency + 1);
  }
}

/// Cache types
enum CacheType {
  video,
  subtitle,
  thumbnail,
  temp,
}

/// Cache statistics
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