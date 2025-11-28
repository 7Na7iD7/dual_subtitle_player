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
  double _volume = 0.7;
  double _playbackSpeed = 1.0;
  bool _isLooping = false;

  // Getters
  Player get player => _player;
  VideoController get controller => _controller;
  File? get videoFile => _videoFile;
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Getters
  double get volume => _volume;
  double get playbackSpeed => _playbackSpeed;
  bool get isLooping => _isLooping;

  Duration get currentPosition => _player.state.position;
  Duration get totalDuration => _player.state.duration;
  Duration get position => _player.state.position;
  Duration get duration => _player.state.duration;
  bool get isPlaying => _player.state.playing;
  bool get isBuffering => _player.state.buffering;

  //StreamBuilder
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
        if (_isLooping) {
          _player.seek(Duration.zero);
          _player.play();
        } else {
          _player.seek(Duration.zero);
          _player.pause();
        }
      }
    });

    // Listen to errors
    _player.stream.error.listen((error) {
      _error = 'MediaKit Error: $error';
      notifyListeners();
    });

    _player.setVolume(_volume * 100);
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
    _volume = volume.clamp(0.0, 1.0);
    _player.setVolume(_volume * 100);
    notifyListeners();
  }

  void setPlaybackSpeed(double speed) {
    _playbackSpeed = speed;
    _player.setRate(speed);
    notifyListeners();
  }

  void toggleLoop() {
    _isLooping = !_isLooping;
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}