import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subtitle_provider.dart';

class SubtitleDisplay extends StatelessWidget {
  const SubtitleDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SubtitleProvider>(
      builder: (context, provider, child) {
        final hasSub1 = provider.showSubtitle1 && provider.currentSubtitle1.isNotEmpty;
        final hasSub2 = provider.showSubtitle2 && provider.currentSubtitle2.isNotEmpty;

        if (!hasSub1 && !hasSub2) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (hasSub2)
                _buildSubtitleText(
                  provider.currentSubtitle2,
                  provider.subtitle2Size,
                  provider.subtitle2Color,
                ),
              if (hasSub1 && hasSub2)
                SizedBox(height: provider.subtitleGap),
              if (hasSub1)
                _buildSubtitleText(
                  provider.currentSubtitle1,
                  provider.subtitle1Size,
                  provider.subtitle1Color,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubtitleText(String text, double size, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: size,
          color: color,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              offset: const Offset(1, 1),
              blurRadius: 3,
              color: Colors.black.withOpacity(0.8),
            ),
          ],
        ),
      ),
    );
  }
}