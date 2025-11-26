import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class VideoProvider extends ChangeNotifier {
  late final Player _player;
  late final VideoController _controller;

  File? _videoFile;
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _error;

  // Getters
  Player get player => _player;
  VideoController get controller => _controller;
  File? get videoFile => _videoFile;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Duration get currentPosition => _player.state.position;
  Duration get totalDuration => _player.state.duration;
  bool get isPlaying => _player.state.playing;
  bool get isBuffering => _player.state.buffering;

  // استریم موقعیت برای استفاده در StreamBuilder (تغییر جدید)
  Stream<Duration> get positionStream => _player.stream.position;

  double get buffered {
    final duration = _player.state.duration.inMilliseconds;
    final buffer = _player.state.buffer.inMilliseconds;
    if (duration == 0) return 0.0;
    return (buffer / duration).clamp(0.0, 1.0);
  }

  VideoProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _player = Player();
    _controller = VideoController(_player);

    // Listen to position changes
    // اصلاح: حذف notifyListeners برای پوزیشن برای جلوگیری از بیلد شدن‌های اضافی
    // چون حالا از StreamBuilder استفاده می‌کنیم، نیازی نیست اینجا UI رو خبر کنیم.
    /* _player.stream.position.listen((duration) {
      notifyListeners();
    });
    */

    // Listen to playing state
    _player.stream.playing.listen((playing) {
      notifyListeners();
    });

    // Listen to buffering state
    _player.stream.buffering.listen((buffering) {
      notifyListeners();
    });

    // Listen to completion
    _player.stream.completed.listen((completed) {
      if (completed) {
        _player.seek(Duration.zero);
        _player.pause();
      }
    });

    // Listen to errors
    _player.stream.error.listen((error) {
      _error = 'MediaKit Error: $error';
      notifyListeners();
    });
  }

  Future<void> pickVideo() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final filePath = result.files.single.path!;
      _videoFile = File(filePath);

      await _player.open(Media(filePath));

      _isInitialized = true;
      _error = null;

    } catch (e) {
      _error = 'Error loading video: $e';
      _isInitialized = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void play() {
    _player.play();
  }

  void pause() {
    _player.pause();
  }

  void togglePlayPause() {
    _player.playOrPause();
  }

  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  void setVolume(double volume) {
    _player.setVolume(volume * 100);
  }

  void setPlaybackSpeed(double speed) {
    _player.setRate(speed);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}