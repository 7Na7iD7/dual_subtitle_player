import 'package:flutter/material.dart';
import '../../providers/video_provider.dart';
import 'menu_tabs_manager.dart';

class AudioTab {
  static List<Widget> getItems({
    required VideoProvider videoProvider,
    required VoidCallback onClose,
    required BuildContext context,
  }) {
    return [
      MenuWidgets.buildSectionHeader('Volume'),
      MenuWidgets.buildVolumeSlider(
        value: videoProvider.volume,
        onChanged: (value) => videoProvider.setVolume(value),
      ),
      MenuWidgets.buildDivider(),
      MenuWidgets.buildDropdownItem(
        icon: videoProvider.volume == 0 ? Icons.volume_off : Icons.volume_up,
        title: videoProvider.volume == 0 ? 'Unmute' : 'Mute',
        subtitle: 'M',
        onTap: () {
          if (videoProvider.volume == 0) {
            videoProvider.setVolume(0.7);
          } else {
            videoProvider.setVolume(0);
          }
          onClose();
        },
      ),
      MenuWidgets.buildDropdownItem(
        icon: Icons.volume_up,
        title: 'Increase Volume',
        subtitle: 'Up',
        onTap: () {
          final newVolume = (videoProvider.volume + 0.1).clamp(0.0, 1.0);
          videoProvider.setVolume(newVolume);
          onClose();
        },
      ),
      MenuWidgets.buildDropdownItem(
        icon: Icons.volume_down,
        title: 'Decrease Volume',
        subtitle: 'Down',
        onTap: () {
          final newVolume = (videoProvider.volume - 0.1).clamp(0.0, 1.0);
          videoProvider.setVolume(newVolume);
          onClose();
        },
      ),
      MenuWidgets.buildDivider(),
      MenuWidgets.buildDropdownItem(
        icon: Icons.equalizer,
        title: 'Audio Equalizer',
        subtitle: 'Ctrl+E',
        onTap: onClose,
      ),
      MenuWidgets.buildDropdownItem(
        icon: Icons.tune,
        title: 'Audio Filters',
        onTap: onClose,
      ),
      MenuWidgets.buildDivider(),
      MenuWidgets.buildSectionHeader('Audio Track'),
      MenuWidgets.buildDropdownItem(
        icon: Icons.audiotrack,
        title: 'Track 1 (Default)',
        isChecked: true,
        onTap: onClose,
      ),
      MenuWidgets.buildDropdownItem(
        icon: Icons.audiotrack,
        title: 'Track 2',
        onTap: onClose,
      ),
      MenuWidgets.buildDivider(),
      MenuWidgets.buildDropdownItem(
        icon: Icons.headset,
        title: 'Audio Device',
        onTap: onClose,
      ),
      MenuWidgets.buildDropdownItem(
        icon: Icons.sync,
        title: 'Audio Sync',
        onTap: onClose,
      ),
    ];
  }
}