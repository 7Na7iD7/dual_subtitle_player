import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subtitle_provider.dart';

class SubtitlesTab extends StatelessWidget {
  const SubtitlesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SubtitleProvider>(
      builder: (context, provider, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.grey[900]!,
                Colors.black,
              ],
            ),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  _buildHeader(),
                  const SizedBox(height: 32),

                  // Subtitle 1 Card
                  _buildSubtitleCard(
                    context,
                    title: 'Subtitle 1 (Primary)',
                    subtitle: provider.subtitle1File?.path.split('/').last ?? 'No file selected',
                    isSelected: provider.subtitle1File != null,
                    onUpload: () => provider.pickSubtitle1(),
                    onClear: provider.subtitle1File != null ? () => provider.clearSubtitle1() : null,
                    isVisible: provider.showSubtitle1,
                    onToggleVisibility: () => provider.toggleSubtitle1(),
                    color: provider.subtitle1Color,
                    size: provider.subtitle1Size,
                    onColorChange: (color) => provider.setSubtitle1Color(color),
                    onSizeChange: (size) => provider.setSubtitle1Size(size),
                    isPrimary: true,
                  ),

                  const SizedBox(height: 24),

                  // Subtitle 2 Card
                  _buildSubtitleCard(
                    context,
                    title: 'Subtitle 2 (Secondary)',
                    subtitle: provider.subtitle2File?.path.split('/').last ?? 'No file selected',
                    isSelected: provider.subtitle2File != null,
                    onUpload: () => provider.pickSubtitle2(),
                    onClear: provider.subtitle2File != null ? () => provider.clearSubtitle2() : null,
                    isVisible: provider.showSubtitle2,
                    onToggleVisibility: () => provider.toggleSubtitle2(),
                    color: provider.subtitle2Color,
                    size: provider.subtitle2Size,
                    onColorChange: (color) => provider.setSubtitle2Color(color),
                    onSizeChange: (size) => provider.setSubtitle2Size(size),
                    isPrimary: false,
                  ),

                  const SizedBox(height: 32),

                  // Subtitle Gap Card
                  _buildSubtitleGapCard(provider),

                  const SizedBox(height: 32),

                  // Info Card
                  _buildInfoCard(),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.withOpacity(0.2), Colors.red.withOpacity(0.1)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.subtitles,
              color: Colors.red,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subtitle Management',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Customize your subtitle appearance',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitleCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required bool isSelected,
        required VoidCallback onUpload,
        required VoidCallback? onClear,
        required bool isVisible,
        required VoidCallback onToggleVisibility,
        required Color color,
        required double size,
        required Function(Color) onColorChange,
        required Function(double) onSizeChange,
        required bool isPrimary,
      }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[850]!,
            Colors.grey[900]!,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? (isPrimary ? Colors.blue : Colors.purple).withOpacity(0.5)
              : Colors.white.withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? (isPrimary ? Colors.blue : Colors.purple).withOpacity(0.2)
                : Colors.black.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (isPrimary ? Colors.blue : Colors.purple).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.closed_caption,
                    color: isPrimary ? Colors.blue : Colors.purple,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: isVisible
                        ? (isPrimary ? Colors.blue : Colors.purple).withOpacity(0.2)
                        : Colors.grey.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(
                      isVisible ? Icons.visibility : Icons.visibility_off,
                      color: isVisible
                          ? (isPrimary ? Colors.blue : Colors.purple)
                          : Colors.grey,
                    ),
                    onPressed: onToggleVisibility,
                    tooltip: isVisible ? 'Hide subtitle' : 'Show subtitle',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: onUpload,
                    icon: Icon(isSelected ? Icons.swap_horiz : Icons.upload_file),
                    label: Text(
                      isSelected ? 'Change File' : 'Upload Subtitle',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPrimary ? Colors.blue : Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton.icon(
                      onPressed: onClear,
                      icon: const Icon(Icons.delete_outline, size: 20),
                      label: const Text(
                        'Clear',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                    ),
                  ),
                ],
              ],
            ),

            // Customization Options
            if (isSelected) ...[
              const SizedBox(height: 24),
              Divider(color: Colors.white.withOpacity(0.1)),
              const SizedBox(height: 20),

              // Size Slider
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Font Size',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: (isPrimary ? Colors.blue : Colors.purple)
                              .withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${size.toStringAsFixed(0)} px',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isPrimary ? Colors.blue : Colors.purple,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: isPrimary ? Colors.blue : Colors.purple,
                      inactiveTrackColor: Colors.grey[700],
                      thumbColor: isPrimary ? Colors.blue : Colors.purple,
                      overlayColor: (isPrimary ? Colors.blue : Colors.purple)
                          .withOpacity(0.2),
                      trackHeight: 4,
                    ),
                    child: Slider(
                      value: size,
                      min: 12,
                      max: 32,
                      divisions: 20,
                      label: size.toStringAsFixed(0),
                      onChanged: onSizeChange,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Color Picker
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Subtitle Color',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      Colors.white,
                      Colors.yellow,
                      Colors.cyan,
                      Colors.green,
                      Colors.orange,
                      Colors.pink,
                    ].map((c) {
                      final isSelected = color == c;
                      return GestureDetector(
                        onTap: () => onColorChange(c),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: isSelected ? 48 : 44,
                          height: isSelected ? 48 : 44,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? (isPrimary ? Colors.blue : Colors.purple)
                                  : Colors.grey,
                              width: isSelected ? 3 : 2,
                            ),
                            boxShadow: isSelected
                                ? [
                              BoxShadow(
                                color: c.withOpacity(0.5),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ]
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(
                            Icons.check,
                            color: Colors.black,
                            size: 24,
                          )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Preview
              _buildPreview(
                text: isPrimary ? 'Primary Subtitle' : 'Secondary Subtitle',
                color: color,
                size: size,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPreview({
    required String text,
    required Color color,
    required double size,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: size,
                  color: color,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black,
                      blurRadius: 2,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitleGapCard(SubtitleProvider provider) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[850]!,
            Colors.grey[900]!,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.height,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Subtitle Gap',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Space between two subtitles',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${provider.subtitleGap.toStringAsFixed(0)} px',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: Colors.orange,
                inactiveTrackColor: Colors.grey[700],
                thumbColor: Colors.orange,
                overlayColor: Colors.orange.withOpacity(0.2),
                trackHeight: 4,
              ),
              child: Slider(
                value: provider.subtitleGap,
                min: 0,
                max: 50,
                divisions: 50,
                label: provider.subtitleGap.toStringAsFixed(0),
                onChanged: (value) => provider.setSubtitleGap(value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.1),
            Colors.purple.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Supported Formats',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['SRT', 'VTT', 'ASS', 'SSA'].map((format) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  format,
                  style: const TextStyle(
                    color: Colors.blue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}