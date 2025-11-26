import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../providers/video_provider.dart';
import '../providers/subtitle_provider.dart';
import '../widgets/video_controls.dart';
import '../widgets/subtitle_display.dart';

class PlayerTab extends StatefulWidget {
  const PlayerTab({super.key});

  @override
  State<PlayerTab> createState() => _PlayerTabState();
}

class _PlayerTabState extends State<PlayerTab> {
  @override
  Widget build(BuildContext context) {
    return Consumer2<VideoProvider, SubtitleProvider>(
      builder: (context, videoProvider, subtitleProvider, child) {
        if (videoProvider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (videoProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  videoProvider.error!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => videoProvider.pickVideo(),
                  icon: const Icon(Icons.video_file),
                  label: const Text('Pick Another Video'),
                ),
              ],
            ),
          );
        }

        if (!videoProvider.isInitialized) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.video_library,
                  size: 100,
                  color: Colors.grey,
                ),
                const SizedBox(height: 24),
                const Text(
                  'No video selected',
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => videoProvider.pickVideo(),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload Video'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Stack(
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: videoProvider.controller!.value.aspectRatio,
                child: VideoPlayer(videoProvider.controller!),
              ),
            ),
            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: SubtitleDisplay(),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoControls(),
            ),
          ],
        );
      },
    );
  }
}