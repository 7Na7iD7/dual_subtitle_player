import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/video_provider.dart';

class VideoControls extends StatefulWidget {
  const VideoControls({super.key});

  @override
  State<VideoControls> createState() => _VideoControlsState();
}

class _VideoControlsState extends State<VideoControls> {
  bool _isSeeking = false;
  double _seekPosition = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoProvider>(
      builder: (context, videoProvider, child) {
        if (!videoProvider.isInitialized) {
          return const SizedBox.shrink();
        }

        return StreamBuilder<Duration>(
          stream: videoProvider.positionStream,
          builder: (context, snapshot) {
            final position = snapshot.data ?? Duration.zero;
            final duration = videoProvider.totalDuration;

            if (!_isSeeking && snapshot.hasData) {
              _seekPosition = position.inMilliseconds.toDouble();
            }

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        _formatDuration(Duration(milliseconds: _seekPosition.toInt())),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 12,
                            ),
                            activeTrackColor: Colors.red,
                            inactiveTrackColor: Colors.white.withOpacity(0.3),
                            thumbColor: Colors.red,
                            overlayColor: Colors.red.withOpacity(0.2),
                          ),
                          child: Slider(
                            value: _seekPosition.clamp(
                              0.0,
                              duration.inMilliseconds.toDouble(),
                            ),
                            min: 0,
                            max: duration.inMilliseconds.toDouble().clamp(1.0, double.infinity),
                            onChangeStart: (value) {
                              setState(() {
                                _isSeeking = true;
                              });
                            },
                            onChanged: (value) {
                              setState(() {
                                _seekPosition = value;
                              });
                            },
                            onChangeEnd: (value) {
                              videoProvider.seekTo(
                                Duration(milliseconds: value.toInt()),
                              );
                              setState(() {
                                _isSeeking = false;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDuration(duration),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.replay_10),
                          color: Colors.white,
                          iconSize: 28,
                          onPressed: () {
                            final newPosition = position - const Duration(seconds: 10);
                            videoProvider.seekTo(
                              newPosition < Duration.zero ? Duration.zero : newPosition,
                            );
                          },
                          tooltip: 'Back 10 seconds',
                        ),
                      ),
                      const SizedBox(width: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            videoProvider.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                          color: Colors.white,
                          iconSize: 40,
                          onPressed: () => videoProvider.togglePlayPause(),
                          tooltip: videoProvider.isPlaying ? 'Pause' : 'Play',
                        ),
                      ),
                      const SizedBox(width: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.forward_10),
                          color: Colors.white,
                          iconSize: 28,
                          onPressed: () {
                            final newPosition = position + const Duration(seconds: 10);
                            videoProvider.seekTo(
                              newPosition > duration ? duration : newPosition,
                            );
                          },
                          tooltip: 'Forward 10 seconds',
                        ),
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.folder_open),
                          color: Colors.white,
                          iconSize: 28,
                          onPressed: () => videoProvider.pickVideo(),
                          tooltip: 'Change Video',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
}