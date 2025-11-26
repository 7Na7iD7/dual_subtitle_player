import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/video_provider.dart';
import '../providers/subtitle_provider.dart';

class VideoControls extends StatefulWidget {
  const VideoControls({super.key});

  @override
  State<VideoControls> createState() => _VideoControlsState();
}

class _VideoControlsState extends State<VideoControls> {
  bool _showControls = true;

  @override
  Widget build(BuildContext context) {
    return Consumer2<VideoProvider, SubtitleProvider>(
      builder: (context, videoProvider, subtitleProvider, child) {
        if (!videoProvider.isInitialized) {
          return const SizedBox.shrink();
        }

        final duration = videoProvider.totalDuration;

        return AnimatedOpacity(
          opacity: _showControls ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
            child: StreamBuilder<Duration>(
              stream: videoProvider.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;

                if (snapshot.hasData) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    subtitleProvider.updateSubtitles(position);
                  });
                }

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Text(
                            _formatDuration(position),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          Expanded(
                            child: Slider(
                              value: position.inMilliseconds.toDouble().clamp(
                                0.0,
                                duration.inMilliseconds.toDouble(),
                              ),
                              max: duration.inMilliseconds.toDouble(),
                              onChanged: (value) {
                                videoProvider.seekTo(
                                  Duration(milliseconds: value.toInt()),
                                );
                              },
                              activeColor: Colors.blue,
                              inactiveColor: Colors.grey[700],
                            ),
                          ),
                          Text(
                            _formatDuration(duration),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.replay_10),
                            color: Colors.white,
                            iconSize: 28,
                            onPressed: () {
                              final newPosition = position - const Duration(seconds: 10);
                              videoProvider.seekTo(
                                newPosition < Duration.zero ? Duration.zero : newPosition,
                              );
                            },
                          ),
                          const SizedBox(width: 20),
                          IconButton(
                            icon: Icon(
                              videoProvider.isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_filled,
                            ),
                            color: Colors.white,
                            iconSize: 56,
                            onPressed: () => videoProvider.togglePlayPause(),
                          ),
                          const SizedBox(width: 20),
                          IconButton(
                            icon: const Icon(Icons.forward_10),
                            color: Colors.white,
                            iconSize: 28,
                            onPressed: () {
                              final newPosition = position + const Duration(seconds: 10);
                              videoProvider.seekTo(
                                newPosition > duration ? duration : newPosition,
                              );
                            },
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.upload_file),
                            color: Colors.white,
                            iconSize: 28,
                            onPressed: () => videoProvider.pickVideo(),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
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