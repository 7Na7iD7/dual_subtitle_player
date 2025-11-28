import 'package:flutter/material.dart';
import '../providers/video_provider.dart';
import '../providers/subtitle_provider.dart';
import 'file_tab.dart';
import 'playback_tab.dart';
import 'audio_tab.dart';
import 'subtitles_tab_menu.dart';
import 'view_tab.dart';
import 'tools_tab.dart';

class MenuTabsManager {
  static List<Widget> getTabContent({
    required String tabName,
    required VideoProvider videoProvider,
    required SubtitleProvider subtitleProvider,
    required VoidCallback onClose,
    required BuildContext context,
  }) {
    switch (tabName) {
      case 'file':
        return FileTab.getItems(
          videoProvider: videoProvider,
          onClose: onClose,
          context: context,
        );

      case 'playback':
        return PlaybackTab.getItems(
          videoProvider: videoProvider,
          onClose: onClose,
          context: context,
        );

      case 'audio':
        return AudioTab.getItems(
          videoProvider: videoProvider,
          onClose: onClose,
          context: context,
        );

      case 'subtitles':
        return SubtitlesTab.getItems(
          subtitleProvider: subtitleProvider,
          onClose: onClose,
          context: context,
        );

      case 'view':
        return ViewTab.getItems(
          onClose: onClose,
          context: context,
        );

      case 'tools':
        return ToolsTab.getItems(
          onClose: onClose,
          context: context,
        );

      default:
        return [];
    }
  }

  /// دریافت موقعیت افقی تب
  static double getTabPosition(String tabName) {
    switch (tabName) {
      case 'file':
        return 120;
      case 'playback':
        return 200;
      case 'audio':
        return 310;
      case 'subtitles':
        return 390;
      case 'view':
        return 500;
      case 'tools':
        return 580;
      default:
        return 0;
    }
  }
}

class MenuWidgets {
  static Widget buildDropdownItem({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    bool isDestructive = false,
    bool isChecked = false,
  }) {
    return InkWell(
      onTap: onTap,
      hoverColor: isDestructive
          ? Colors.red.withOpacity(0.1)
          : Colors.white.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            if (isChecked)
              const Icon(
                Icons.check,
                color: Colors.red,
                size: 20,
              )
            else
              Icon(
                icon,
                color: isDestructive
                    ? Colors.red[400]
                    : Colors.white.withOpacity(0.9),
                size: 20,
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isDestructive ? Colors.red[400] : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  static Widget buildDivider() {
    return Divider(
      color: Colors.white.withOpacity(0.1),
      height: 1,
      thickness: 1,
    );
  }

  static Widget buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  static Widget buildVolumeSlider({
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(Icons.volume_down, color: Colors.white.withOpacity(0.7), size: 20),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                activeTrackColor: Colors.red,
                inactiveTrackColor: Colors.white.withOpacity(0.2),
                thumbColor: Colors.red,
                overlayColor: Colors.red.withOpacity(0.2),
              ),
              child: Slider(
                value: value,
                onChanged: onChanged,
              ),
            ),
          ),
          Icon(Icons.volume_up, color: Colors.white.withOpacity(0.7), size: 20),
        ],
      ),
    );
  }

  static Widget buildSpeedOption({
    required double speed,
    required double currentSpeed,
    required VoidCallback onTap,
  }) {
    final isActive = (speed - currentSpeed).abs() < 0.01;

    return InkWell(
      onTap: onTap,
      hoverColor: Colors.white.withOpacity(0.05),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              child: isActive
                  ? const Icon(Icons.check, color: Colors.red, size: 18)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              '${speed}x',
              style: TextStyle(
                color: isActive ? Colors.red : Colors.white,
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
