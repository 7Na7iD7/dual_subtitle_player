import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subtitle_provider.dart';

class SubtitlesTab extends StatelessWidget {
  const SubtitlesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SubtitleProvider>(
      builder: (context, provider, child) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Subtitle Management',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),

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
              ),

              const SizedBox(height: 24),

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
              ),

              const SizedBox(height: 32),

              Card(
                color: Colors.grey[850],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Subtitle Gap',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: provider.subtitleGap,
                              min: 0,
                              max: 50,
                              divisions: 50,
                              label: provider.subtitleGap.toStringAsFixed(0),
                              onChanged: (value) => provider.setSubtitleGap(value),
                            ),
                          ),
                          Text(
                            '${provider.subtitleGap.toStringAsFixed(0)} px',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
      }) {
    return Card(
      color: Colors.grey[850],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
                IconButton(
                  icon: Icon(
                    isVisible ? Icons.visibility : Icons.visibility_off,
                    color: isVisible ? Colors.blue : Colors.grey,
                  ),
                  onPressed: onToggleVisibility,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onUpload,
                    icon: const Icon(Icons.upload_file),
                    label: Text(isSelected ? 'Change' : 'Upload'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: onClear,
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[700],
                    ),
                  ),
                ],
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Size:', style: TextStyle(fontSize: 14)),
                  Expanded(
                    child: Slider(
                      value: size,
                      min: 12,
                      max: 32,
                      divisions: 20,
                      label: size.toStringAsFixed(0),
                      onChanged: onSizeChange,
                    ),
                  ),
                  Text('${size.toStringAsFixed(0)}'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Color:', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 16),
                  ...[Colors.white, Colors.yellow, Colors.cyan, Colors.green]
                      .map(
                        (c) => Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: GestureDetector(
                        onTap: () => onColorChange(c),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: c,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: color == c ? Colors.blue : Colors.grey,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                      .toList(),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}