import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subtitle_provider.dart';
import '../providers/video_provider.dart';

class SubtitleDisplay extends StatelessWidget {
  const SubtitleDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SubtitleProvider, VideoProvider>(
      builder: (context, subtitleProvider, videoProvider, child) {
        if (!videoProvider.isInitialized) {
          return const SizedBox.shrink();
        }

        return StreamBuilder<Duration>(
          stream: videoProvider.positionStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final position = snapshot.data!;
               subtitleProvider.updateSubtitles(position);
            }

            final hasSub1 = subtitleProvider.showSubtitle1 &&
                subtitleProvider.currentSubtitle1.isNotEmpty;
            final hasSub2 = subtitleProvider.showSubtitle2 &&
                subtitleProvider.currentSubtitle2.isNotEmpty;

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
                      subtitleProvider.currentSubtitle2,
                      subtitleProvider.subtitle2Size,
                      subtitleProvider.subtitle2Color,
                    ),
                  if (hasSub1 && hasSub2)
                    SizedBox(height: subtitleProvider.subtitleGap),
                  if (hasSub1)
                    _buildSubtitleText(
                      subtitleProvider.currentSubtitle1,
                      subtitleProvider.subtitle1Size,
                      subtitleProvider.subtitle1Color,
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSubtitleText(String text, double size, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: size,
          color: color,
          fontWeight: FontWeight.bold,
          height: 1.4,
          shadows: [
            Shadow(
              offset: const Offset(2, 2),
              blurRadius: 4,
              color: Colors.black,
            ),
            Shadow(
              offset: const Offset(-1, -1),
              blurRadius: 4,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}