import 'package:flutter/material.dart';
import '../../providers/subtitle_provider.dart';
import 'menu_tabs_manager.dart';

class SubtitlesTab {
  static List<Widget> getItems({
    required SubtitleProvider subtitleProvider,
    required VoidCallback onClose,
    required BuildContext context,
  }) {
    return [
      MenuWidgets.buildDropdownItem(
        icon: Icons.subtitles,
        title: 'Load Subtitles',
        subtitle: 'Ctrl+L',
        onTap: () {
          subtitleProvider.pickSubtitles();
          onClose();
        },
      ),
      MenuWidgets.buildDropdownItem(
        icon: Icons.search,
        title: 'Search Subtitles Online',
        onTap: onClose,
      ),
      MenuWidgets.buildDivider(),
      MenuWidgets.buildDropdownItem(
        icon: subtitleProvider.isSubtitlesEnabled
            ? Icons.check_box
            : Icons.check_box_outline_blank,
        title: 'Enable Subtitles',
        subtitle: 'V',
        isChecked: subtitleProvider.isSubtitlesEnabled,
        onTap: () {
          subtitleProvider.toggleSubtitles();
          onClose();
        },
      ),
      if (subtitleProvider.hasSubtitles) ...[
        MenuWidgets.buildDivider(),
        MenuWidgets.buildSectionHeader('Subtitle Tracks'),
        MenuWidgets.buildDropdownItem(
          icon: Icons.language,
          title: 'English',
          isChecked: true,
          onTap: onClose,
        ),
        MenuWidgets.buildDropdownItem(
          icon: Icons.language,
          title: 'Spanish',
          onTap: onClose,
        ),
        MenuWidgets.buildDropdownItem(
          icon: Icons.language,
          title: 'French',
          onTap: onClose,
        ),
        MenuWidgets.buildDivider(),
        MenuWidgets.buildSectionHeader('Appearance'),
        MenuWidgets.buildDropdownItem(
          icon: Icons.format_size,
          title: 'Font Size',
          onTap: onClose,
        ),
        MenuWidgets.buildDropdownItem(
          icon: Icons.palette,
          title: 'Subtitle Color',
          onTap: onClose,
        ),
        MenuWidgets.buildDropdownItem(
          icon: Icons.text_fields,
          title: 'Font Style',
          onTap: onClose,
        ),
        MenuWidgets.buildDropdownItem(
          icon: Icons.format_align_center,
          title: 'Position',
          onTap: onClose,
        ),
        MenuWidgets.buildDivider(),
        MenuWidgets.buildDropdownItem(
          icon: Icons.sync,
          title: 'Subtitle Sync',
          onTap: onClose,
        ),
        MenuWidgets.buildDropdownItem(
          icon: Icons.speed,
          title: 'Subtitle Delay',
          onTap: onClose,
        ),
      ],
    ];
  }
}
