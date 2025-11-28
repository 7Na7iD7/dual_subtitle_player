import 'package:flutter/material.dart';
import '../../providers/video_provider.dart';
import 'menu_tabs_manager.dart';

class PlaybackTab {
  static List<Widget> getItems({
    required VideoProvider videoProvider,
    required VoidCallback onClose,
    required BuildContext context,
  }) {
    return [
      MenuWidgets.buildDropdownItem(
        icon: videoProvider.isPlaying ? Icons.pause : Icons.play_arrow,
        title: videoProvider.isPlaying ? 'Pause' : 'Play',
        subtitle: 'Space',
        onTap: () {
          videoProvider.togglePlayPause();
          onClose();
        },
      ),
      MenuWidgets.buildDropdownItem(
        icon: Icons.stop,
        title: 'Stop',
        subtitle: 'S',
        onTap: () {
          videoProvider.pause();
          videoProvider.seekTo(Duration.zero);
          onClose();
        },
      ),
      MenuWidgets.buildDivider(),
      MenuWidgets.buildDropdownItem(
        icon: Icons.skip_previous,
        title: 'Previous Frame',
        subtitle: 'Left',
        onTap: () {
          _seekFrames(videoProvider, -1);
          onClose();
        },
      ),
      MenuWidgets.buildDropdownItem(
        icon: Icons.skip_next,
        title: 'Next Frame',
        subtitle: 'Right',
        onTap: () {
          _seekFrames(videoProvider, 1);
          onClose();
        },
      ),
      MenuWidgets.buildDivider(),
      MenuWidgets.buildDropdownItem(
        icon: Icons.replay_5,
        title: 'Jump Backward 5s',
        subtitle: 'Ctrl+Left',
        onTap: () {
          _jumpBackward(videoProvider, 5);
          onClose();
        },
      ),
      MenuWidgets.buildDropdownItem(
        icon: Icons.forward_5,
        title: 'Jump Forward 5s',
        subtitle: 'Ctrl+Right',
        onTap: () {
          _jumpForward(videoProvider, 5);
          onClose();
        },
      ),
      MenuWidgets.buildDropdownItem(
        icon: Icons.replay_10,
        title: 'Jump Backward 10s',
        subtitle: 'Shift+Left',
        onTap: () {
          _jumpBackward(videoProvider, 10);
          onClose();
        },
      ),
      MenuWidgets.buildDropdownItem(
        icon: Icons.forward_10,
        title: 'Jump Forward 10s',
        subtitle: 'Shift+Right',
        onTap: () {
          _jumpForward(videoProvider, 10);
          onClose();
        },
      ),
      MenuWidgets.buildDivider(),
      MenuWidgets.buildSectionHeader('Playback Speed'),
      ...[0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0].map(
            (speed) => MenuWidgets.buildSpeedOption(
          speed: speed,
          currentSpeed: videoProvider.playbackSpeed,
          onTap: () {
            videoProvider.setPlaybackSpeed(speed);
            onClose();
          },
        ),
      ),
      MenuWidgets.buildDivider(),
      MenuWidgets.buildDropdownItem(
        icon: Icons.loop,
        title: 'Loop',
        subtitle: 'L',
        isChecked: videoProvider.isLooping,
        onTap: () {
          videoProvider.toggleLoop();
          onClose();
        },
      ),
      MenuWidgets.buildDropdownItem(
        icon: Icons.shuffle,
        title: 'Shuffle',
        onTap: onClose,
      ),
      MenuWidgets.buildDivider(),
      MenuWidgets.buildDropdownItem(
        icon: Icons.bookmark_add,
        title: 'Add Bookmark',
        subtitle: 'Ctrl+B',
        onTap: () {
          _addBookmark(context, videoProvider);
          onClose();
        },
      ),
      MenuWidgets.buildDropdownItem(
        icon: Icons.bookmarks,
        title: 'Show Bookmarks',
        subtitle: 'Ctrl+Shift+B',
        onTap: () {
          _showBookmarks(context, videoProvider);
          onClose();
        },
      ),
    ];
  }

  static void _seekFrames(VideoProvider provider, int frames) {
    if (!provider.isInitialized) return;

    final fps = 30; // Default FPS
    final frameDuration = Duration(milliseconds: (1000 / fps).round());
    final newPosition = provider.position + (frameDuration * frames);

    if (newPosition >= Duration.zero && newPosition <= provider.duration) {
      provider.seekTo(newPosition);
    }
  }

  static void _jumpBackward(VideoProvider provider, int seconds) {
    if (!provider.isInitialized) return;

    final newPosition = provider.position - Duration(seconds: seconds);
    provider.seekTo(
      newPosition < Duration.zero ? Duration.zero : newPosition,
    );
  }

  static void _jumpForward(VideoProvider provider, int seconds) {
    if (!provider.isInitialized) return;

    final newPosition = provider.position + Duration(seconds: seconds);
    provider.seekTo(
      newPosition > provider.duration ? provider.duration : newPosition,
    );
  }

  static void _addBookmark(BuildContext context, VideoProvider provider) {
    if (!provider.isInitialized) return;

    final controller = TextEditingController();
    final currentTime = provider.position;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.red.withOpacity(0.3), width: 2),
        ),
        title: const Row(
          children: [
            Icon(Icons.bookmark_add, color: Colors.red),
            SizedBox(width: 12),
            Text('Add Bookmark', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Time: ${_formatDuration(currentTime)}',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Bookmark name...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.white.withOpacity(0.6))),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Save bookmark
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  static void _showBookmarks(BuildContext context, VideoProvider provider) {
    final bookmarks = [
      {'name': 'Opening scene', 'time': const Duration(minutes: 0, seconds: 30)},
      {'name': 'Important moment', 'time': const Duration(minutes: 5, seconds: 15)},
      {'name': 'Plot twist', 'time': const Duration(minutes: 12, seconds: 45)},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a1a),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.red.withOpacity(0.3), width: 2),
        ),
        title: const Row(
          children: [
            Icon(Icons.bookmarks, color: Colors.red),
            SizedBox(width: 12),
            Text('Bookmarks', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final bookmark = bookmarks[index];
              return ListTile(
                leading: const Icon(Icons.bookmark, color: Colors.red),
                title: Text(
                  bookmark['name'] as String,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  _formatDuration(bookmark['time'] as Duration),
                  style: TextStyle(color: Colors.white.withOpacity(0.6)),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.play_arrow, color: Colors.red),
                  onPressed: () {
                    provider.seekTo(bookmark['time'] as Duration);
                    Navigator.pop(context);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  static String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }
}