import 'package:flutter/material.dart';
import '../../providers/video_provider.dart';
import 'menu_tabs_manager.dart';

class FileTab {
  static List<Widget> getItems({
    required VideoProvider videoProvider,
    required VoidCallback onClose,
    required BuildContext context,
  }) {
    return [
      MenuWidgets.buildDropdownItem(
        icon: Icons.folder_open,
        title: 'Open Video',
        subtitle: 'Ctrl+O',
        onTap: () {
          videoProvider.pickVideo();
          onClose();
        },
      ),
      MenuWidgets.buildDropdownItem(
        icon: Icons.drive_folder_upload,
        title: 'Open URL',
        subtitle: 'Ctrl+U',
        onTap: () {
          _showOpenUrlDialog(context, videoProvider, onClose);
        },
      ),
      MenuWidgets.buildDivider(),
      MenuWidgets.buildDropdownItem(
        icon: Icons.history,
        title: 'Recent Files',
        subtitle: 'Ctrl+R',
        onTap: () {
          _showRecentFiles(context, videoProvider, onClose);
        },
      ),
      MenuWidgets.buildDropdownItem(
        icon: Icons.playlist_play,
        title: 'Open Playlist',
        onTap: onClose,
      ),
      MenuWidgets.buildDivider(),
      MenuWidgets.buildDropdownItem(
        icon: Icons.save_alt,
        title: 'Save Snapshot',
        subtitle: 'Ctrl+S',
        onTap: onClose,
      ),
      MenuWidgets.buildDropdownItem(
        icon: Icons.folder,
        title: 'Save Playlist',
        onTap: onClose,
      ),
      MenuWidgets.buildDivider(),
      MenuWidgets.buildDropdownItem(
        icon: Icons.settings,
        title: 'Preferences',
        subtitle: 'Ctrl+P',
        onTap: () {
          _showPreferences(context, onClose);
        },
      ),
      MenuWidgets.buildDivider(),
      MenuWidgets.buildDropdownItem(
        icon: Icons.close,
        title: 'Close Video',
        subtitle: 'Ctrl+W',
        isDestructive: true,
        onTap: () {
          videoProvider.dispose();
          onClose();
        },
      ),
      MenuWidgets.buildDropdownItem(
        icon: Icons.exit_to_app,
        title: 'Exit',
        subtitle: 'Alt+F4',
        isDestructive: true,
        onTap: onClose,
      ),
    ];
  }

  static void _showOpenUrlDialog(
    BuildContext context,
    VideoProvider videoProvider,
    VoidCallback onClose,
  ) {
    final controller = TextEditingController();
    
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
            Icon(Icons.link, color: Colors.red),
            SizedBox(width: 12),
            Text('Open URL', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter video URL...',
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
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.white.withOpacity(0.6))),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                // TODO: videoProvider.loadFromUrl(controller.text);
                Navigator.pop(context);
                onClose();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }

  static void _showRecentFiles(
    BuildContext context,
    VideoProvider videoProvider,
    VoidCallback onClose,
  ) {
    final recentFiles = [
      'movie_2024.mp4',
      'documentary.mkv',
      'series_s01e01.avi',
      'tutorial.mp4',
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
            Icon(Icons.history, color: Colors.red),
            SizedBox(width: 12),
            Text('Recent Files', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: SizedBox(
          width: 400,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: recentFiles.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.movie, color: Colors.red),
                title: Text(
                  recentFiles[index],
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  // TODO: videoProvider.loadRecentFile(recentFiles[index]);
                  Navigator.pop(context);
                  onClose();
                },
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

  static void _showPreferences(BuildContext context, VoidCallback onClose) {
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
            Icon(Icons.settings, color: Colors.red),
            SizedBox(width: 12),
            Text('Preferences', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Settings will be available in the next version',
                style: TextStyle(color: Colors.white),
              ),
            ],
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
}
