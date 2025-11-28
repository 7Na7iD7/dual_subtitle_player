import 'package:flutter/material.dart';
import 'menu_tabs_manager.dart';

class ViewTab {
  static List<Widget> getItems({
    required VoidCallback onClose,
    required BuildContext context,
  }) {
    return [
      MenuWidgets.buildDropdownItem(
        icon: Icons.fullscreen,
        title: 'Fullscreen',
        subtitle: 'F',
        onTap: onClose,
      ),
      MenuWidgets.buildDropdownItem(
        icon: Icons.fullscreen_exit,
        title: 'Exit Fullscreen',
        subtitle: 'Esc',
        onTap: onClose,
      ),
      MenuWidgets.buildDivider(),
      MenuWidgets.buildDropdownItem(
        icon: Icons.picture_in_picture_alt,
        title: 'Mini Player',
        subtitle: 'Ctrl+M',
        onTap: onClose,
      ),
      MenuWidgets.buildDropdownItem(
        icon: Icons.aspect_ratio,
        title: 'Aspect Ratio',
        onTap: onClose,
      ),
      MenuWidgets.buildDropdownItem(
        icon: Icons.crop,
        title: 'Crop',
        onTap: onClose,
      ),
      MenuWidgets.buildDivider(),
      MenuWidgets.buildSectionHeader('Zoom'),
      MenuWidgets.buildDropdownItem(
        icon: Icons.zoom_in,
        title: 'Zoom In',
        subtitle: '+',
        onTap: onClose,
      ),
      MenuWidgets.buildDropdownItem(
        icon: Icons.zoom_out,
        title: 'Zoom Out',
        subtitle: '-',
        onTap: onClose,
      ),
      MenuWidgets.buildDropdownItem(
        icon: Icons.fit_screen,
        title: 'Reset Zoom',
        subtitle: '0',
        onTap: onClose,
      ),
      MenuWidgets.buildDivider(),
      MenuWidgets.buildDropdownItem(
        icon: Icons.info_outline,
        title: 'Video Info',
        subtitle: 'Ctrl+I',
        onTap: onClose,
      ),
      MenuWidgets.buildDropdownItem(
        icon: Icons.analytics,
        title: 'Statistics',
        subtitle: 'Ctrl+J',
        onTap: onClose,
      ),
      MenuWidgets.buildDivider(),
      MenuWidgets.buildSectionHeader('Interface'),
      MenuWidgets.buildDropdownItem(
        icon: Icons.tune,
        title: 'Show Controls',
        isChecked: true,
        onTap: onClose,
      ),
      MenuWidgets.buildDropdownItem(
        icon: Icons.timeline,
        title: 'Show Timeline',
        isChecked: true,
        onTap: onClose,
      ),
      MenuWidgets.buildDropdownItem(
        icon: Icons.menu,
        title: 'Show Menu Bar',
        isChecked: true,
        onTap: onClose,
      ),
    ];
  }
}
