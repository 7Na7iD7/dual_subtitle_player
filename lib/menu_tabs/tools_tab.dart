import 'package:flutter/material.dart';
import 'menu_tabs_manager.dart';

class ToolsTab {
  static List<Widget> getItems({
    required VoidCallback onClose,
    required BuildContext context,
  }) {
    return [
      MenuWidgets.buildDropdownItem(
        icon: Icons.camera_alt,
        title: 'Take Screenshot',
        subtitle: 'Ctrl+S',
        onTap: onClose,
      ),
      MenuWidgets.buildDropdownItem(
        icon: Icons.photo_library,
        title: 'Screenshot Series',
        onTap: onClose,
      ),
      MenuWidgets.buildDivider(),
      MenuWidgets.buildDropdownItem(
        icon: Icons.fiber_manual_record,
        title: 'Record Screen',
        subtitle: 'Ctrl+R',
        onTap: onClose,
      ),
      MenuWidgets.buildDropdownItem(
        icon: Icons.stop_circle,
        title: 'Stop Recording',
        onTap: onClose,
      ),
      MenuWidgets.buildDivider(),
      MenuWidgets.buildDropdownItem(
        icon: Icons.note_add,
        title: 'Notes',
        subtitle: 'Ctrl+N',
        onTap: onClose,
      ),
      MenuWidgets.buildDropdownItem(
        icon: Icons.bookmark_add,
        title: 'Bookmarks',
        subtitle: 'Ctrl+B',
        onTap: onClose,
      ),
      MenuWidgets.buildDivider(),
      MenuWidgets.buildDropdownItem(
        icon: Icons.equalizer,
        title: 'Audio Equalizer',
        subtitle: 'Ctrl+E',
        onTap: onClose,
      ),
      MenuWidgets.buildDropdownItem(
        icon: Icons.color_lens,
        title: 'Video Effects',
        onTap: onClose,
      ),
      MenuWidgets.buildDivider(),
      MenuWidgets.buildDropdownItem(
        icon: Icons.content_cut,
        title: 'Video Trimmer',
        onTap: onClose,
      ),
      MenuWidgets.buildDropdownItem(
        icon: Icons.merge_type,
        title: 'Video Merger',
        onTap: onClose,
      ),
      MenuWidgets.buildDivider(),
      MenuWidgets.buildDropdownItem(
        icon: Icons.subtitles,
        title: 'Subtitle Editor',
        onTap: onClose,
      ),
      MenuWidgets.buildDropdownItem(
        icon: Icons.text_format,
        title: 'Add Watermark',
        onTap: onClose,
      ),
    ];
  }
}
