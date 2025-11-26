import 'package:flutter/material.dart';
import '../services/cache_manager.dart';

class CacheProvider extends ChangeNotifier {
  final AdvancedCacheManager _cacheManager = AdvancedCacheManager();

  CacheStats? _currentStats;
  bool _isCalculating = false;
  String? _error;
  List<String> _cacheLogs = [];

  CacheStats? get currentStats => _currentStats;
  bool get isCalculating => _isCalculating;
  String? get error => _error;
  List<String> get cacheLogs => _cacheLogs;

  // Convenience getters
  double get cacheSize => (_currentStats?.totalSize ?? 0) / (1024 * 1024);
  double get hitRate => _currentStats?.hitRate ?? 0;

  CacheProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _cacheManager.initialize();

    // Listen to stats stream
    _cacheManager.statsStream.listen((stats) {
      _currentStats = stats;
      notifyListeners();
    });

    calculateCacheSize();
  }

  Future<void> calculateCacheSize() async {
    _isCalculating = true;
    _error = null;
    notifyListeners();

    try {
      _currentStats = await _cacheManager.getStats();
      _addLog('Cache calculated: ${cacheSize.toStringAsFixed(2)} MB');
      _addLog('Hit rate: ${(hitRate * 100).toStringAsFixed(1)}%');
      _addLog('Memory: ${_currentStats!.memoryEntries} entries');
      _addLog('Videos: ${_currentStats!.videoCount}');
      _addLog('Subtitles: ${_currentStats!.subtitleCount}');
    } catch (e) {
      _error = 'Error calculating cache: $e';
      _addLog('Error: $e');
    } finally {
      _isCalculating = false;
      notifyListeners();
    }
  }

  Future<void> clearCache() async {
    _isCalculating = true;
    _error = null;
    notifyListeners();

    try {
      await _cacheManager.clearAllCaches();
      await calculateCacheSize();
      _addLog('✅ All caches cleared successfully');
    } catch (e) {
      _error = 'Error clearing cache: $e';
      _addLog('❌ Clear error: $e');
    } finally {
      _isCalculating = false;
      notifyListeners();
    }
  }

  Future<void> clearCacheByType(CacheType type) async {
    _isCalculating = true;
    notifyListeners();

    try {
      await _cacheManager.clearCache(type);
      await calculateCacheSize();
      _addLog('✅ ${type.name} cache cleared');
    } catch (e) {
      _error = 'Error clearing ${type.name} cache: $e';
      _addLog('❌ Error: $e');
    } finally {
      _isCalculating = false;
      notifyListeners();
    }
  }

  void _addLog(String log) {
    final timestamp = DateTime.now();
    final formatted = '${timestamp.hour}:${timestamp.minute}:${timestamp.second}';
    _cacheLogs.insert(0, '[$formatted] $log');

    if (_cacheLogs.length > 100) {
      _cacheLogs.removeLast();
    }
    notifyListeners();
  }

  void clearLogs() {
    _cacheLogs.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _cacheManager.dispose();
    super.dispose();
  }
}