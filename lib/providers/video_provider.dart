import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import '../services/optimized_video_loader.dart';

class VideoProvider extends ChangeNotifier {
  final OptimizedVideoLoader _videoLoader = OptimizedVideoLoader();

  VideoPlayerController? _controller;
  File? _videoFile;
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _error;
  String? _videoPath;

  VideoPlayerController? get controller => _controller;
  File? get videoFile => _videoFile;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get videoPath => _videoPath;

  Duration get currentPosition {
    if (_controller == null) return Duration.zero;
    return _controller!.value.position;
  }

  Duration get totalDuration {
    if (_controller == null) return Duration.zero;
    return _controller!.value.duration;
  }

  bool get isPlaying {
    if (_controller == null) return false;
    return _controller!.value.isPlaying;
  }

  double get buffered {
    if (_controller == null) return 0.0;
    if (_controller!.value.buffered.isEmpty) return 0.0;
    if (_controller!.value.duration.inMilliseconds == 0) return 0.0;

    return _controller!.value.buffered.last.end.inMilliseconds /
        _controller!.value.duration.inMilliseconds;
  }

  VideoProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _videoLoader.initialize();
  }

  Future<void> pickVideo() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowedExtensions: ['mp4', 'mkv', 'mov', 'avi', 'flv', 'wmv'],
      );

      if (result != null && result.files.single.path != null) {
        _videoFile = File(result.files.single.path!);
        _videoPath = result.files.single.path;

        // Validate file
        if (!await _videoFile!.exists()) {
          throw Exception('Video file not found');
        }

        final fileSize = await _videoFile!.length();
        if (fileSize == 0) {
          throw Exception('Video file is empty');
        }

        debugPrint('📹 Video selected: ${_videoFile!.path}');
        debugPrint('📦 Size: ${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB');

        await initializeVideo();
      }
    } catch (e) {
      _error = 'Error picking video: $e';
      debugPrint('❌ $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> initializeVideo() async {
    if (_videoFile == null) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Dispose previous controller
      await disposeController();

      // Load video with optimized loader
      _controller = await _videoLoader.loadVideo(_videoFile!);

      if (_controller == null) {
        throw Exception('Failed to initialize video controller');
      }

      // Add listener for updates
      _controller!.addListener(_videoListener);

      _isInitialized = true;
      _error = null;

      debugPrint('✅ Video initialized successfully');
      debugPrint('⏱️ Duration: ${_controller!.value.duration}');
      debugPrint('📐 Aspect Ratio: ${_controller!.value.aspectRatio}');

    } catch (e) {
      _error = 'Error initializing video: $e';
      _isInitialized = false;
      debugPrint('❌ $_error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _videoListener() {
    if (!_isInitialized) return;
    if (_controller == null) return;

    // Check for errors
    if (_controller!.value.hasError) {
      _error = _controller!.value.errorDescription;
      debugPrint('❌ Video error: $_error');
    }

    notifyListeners();
  }

  void play() {
    if (_controller == null || !_isInitialized) return;

    try {
      _controller!.play();
      notifyListeners();
    } catch (e) {
      _error = 'Error playing video: $e';
      notifyListeners();
    }
  }

  void pause() {
    if (_controller == null) return;

    try {
      _controller!.pause();
      notifyListeners();
    } catch (e) {
      _error = 'Error pausing video: $e';
      notifyListeners();
    }
  }

  void togglePlayPause() {
    if (_controller == null || !_isInitialized) return;

    if (_controller!.value.isPlaying) {
      pause();
    } else {
      play();
    }
  }

  Future<void> seekTo(Duration position) async {
    if (_controller == null || !_isInitialized) return;

    try {
      await _controller!.seekTo(position);
      notifyListeners();
    } catch (e) {
      _error = 'Error seeking: $e';
      notifyListeners();
    }
  }

  void setVolume(double volume) {
    if (_controller == null) return;

    try {
      _controller!.setVolume(volume.clamp(0.0, 1.0));
      notifyListeners();
    } catch (e) {
      _error = 'Error setting volume: $e';
      notifyListeners();
    }
  }

  void setPlaybackSpeed(double speed) {
    if (_controller == null || !_isInitialized) return;

    try {
      _controller!.setPlaybackSpeed(speed.clamp(0.25, 2.0));
      notifyListeners();
    } catch (e) {
      _error = 'Error setting speed: $e';
      notifyListeners();
    }
  }

  Future<void> disposeController() async {
    if (_controller != null) {
      _controller!.removeListener(_videoListener);

      try {
        await _controller!.pause();
        await _controller!.dispose();
      } catch (e) {
        debugPrint('❌ Error disposing controller: $e');
      }

      _controller = null;
      _isInitialized = false;
    }
  }

  @override
  void dispose() {
    disposeController();
    _videoLoader.dispose();
    super.dispose();
  }
}