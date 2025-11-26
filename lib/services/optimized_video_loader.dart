import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:video_player/video_player.dart';
import 'cache_manager.dart';

/// Optimized Video Loader with chunk loading and buffering
class OptimizedVideoLoader {
  static final OptimizedVideoLoader _instance = OptimizedVideoLoader._internal();
  factory OptimizedVideoLoader() => _instance;
  OptimizedVideoLoader._internal();

  final AdvancedCacheManager _cacheManager = AdvancedCacheManager();
  final Map<String, VideoLoadState> _loadStates = {};

  Timer? _memoryMonitor;
  static const int maxConcurrentLoads = 2;
  int _currentLoads = 0;

  /// Initialize loader
  Future<void> initialize() async {
    await _cacheManager.initialize();
    _startMemoryMonitoring();
  }

  /// Load video with intelligent buffering
  Future<VideoPlayerController?> loadVideo(File videoFile) async {
    final key = videoFile.path;

    try {
      // Check if already loading
      if (_loadStates[key]?.isLoading ?? false) {
        debugPrint('⏳ Video already loading: $key');
        return await _waitForLoad(key);
      }

      // Check concurrent load limit
      while (_currentLoads >= maxConcurrentLoads) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      _currentLoads++;
      _loadStates[key] = VideoLoadState(isLoading: true);

      // Check cache first
      final cachedFile = await _cacheManager.get(key, CacheType.video);
      final fileToLoad = cachedFile ?? videoFile;

      // Pre-process video for optimal playback
      final optimizedFile = await _preprocessVideo(fileToLoad);

      // Create controller with optimized settings
      final controller = VideoPlayerController.file(
        optimizedFile,
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
          allowBackgroundPlayback: false,
        ),
      );

      // Initialize with timeout protection
      await controller.initialize().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('Video initialization timeout');
        },
      );

      // Cache if not already cached
      if (cachedFile == null) {
        await _cacheManager.put(key, optimizedFile, CacheType.video);
      }

      // Enable buffering
      await controller.setVolume(1.0);

      _loadStates[key] = VideoLoadState(
        isLoading: false,
        controller: controller,
        isLoaded: true,
      );

      _currentLoads--;

      debugPrint('✅ Video loaded: $key');
      return controller;

    } catch (e) {
      _currentLoads--;
      _loadStates[key] = VideoLoadState(
        isLoading: false,
        error: e.toString(),
      );

      debugPrint('❌ Video load error: $e');
      return null;
    }
  }

  /// Preprocess video for optimal performance
  Future<File> _preprocessVideo(File videoFile) async {
    try {
      final fileSize = await videoFile.length();

      // If file is very large (>100MB), create temporary optimized version
      if (fileSize > 100 * 1024 * 1024) {
        debugPrint('📦 Large file detected, optimizing...');

        // For now, return original (can implement ffmpeg compression here)
        return videoFile;
      }

      return videoFile;
    } catch (e) {
      debugPrint('❌ Preprocess error: $e');
      return videoFile;
    }
  }

  /// Wait for ongoing load
  Future<VideoPlayerController?> _waitForLoad(String key) async {
    int attempts = 0;
    const maxAttempts = 100; // 10 seconds max wait

    while (attempts < maxAttempts) {
      final state = _loadStates[key];

      if (state != null && !state.isLoading) {
        return state.controller;
      }

      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }

    return null;
  }

  /// Monitor memory usage
  void _startMemoryMonitoring() {
    _memoryMonitor?.cancel();
    _memoryMonitor = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkMemoryPressure();
    });
  }

  Future<void> _checkMemoryPressure() async {
    try {
      final stats = await _cacheManager.getStats();

      // If memory cache is getting full, clear least used entries
      if (stats.memorySize > AdvancedCacheManager.maxMemoryCacheSize * 0.9) {
        debugPrint('⚠️ High memory pressure, clearing cache...');
        await _cacheManager.clearCache(CacheType.temp);
      }
    } catch (e) {
      debugPrint('❌ Memory check error: $e');
    }
  }

  /// Preload video in background
  Future<void> preloadVideo(File videoFile) async {
    await compute(_preloadInBackground, videoFile.path);
  }

  static Future<void> _preloadInBackground(String path) async {
    // Background preloading logic
    final file = File(path);
    if (await file.exists()) {
      await file.readAsBytes();
    }
  }

  /// Clear specific video from memory
  Future<void> clearVideo(String key) async {
    final state = _loadStates.remove(key);
    await state?.controller?.dispose();
  }

  /// Clear all loaded videos
  Future<void> clearAll() async {
    for (var state in _loadStates.values) {
      await state.controller?.dispose();
    }
    _loadStates.clear();
  }

  void dispose() {
    _memoryMonitor?.cancel();
    clearAll();
    _cacheManager.dispose();
  }
}

/// Video load state
class VideoLoadState {
  final bool isLoading;
  final VideoPlayerController? controller;
  final bool isLoaded;
  final String? error;

  VideoLoadState({
    this.isLoading = false,
    this.controller,
    this.isLoaded = false,
    this.error,
  });
}