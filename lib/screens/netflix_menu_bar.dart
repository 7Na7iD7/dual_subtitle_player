import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/video_provider.dart';
import '../providers/subtitle_provider.dart';
import 'dart:math' as math;
import 'dart:ui';

class NetflixMenuBar extends StatefulWidget {
  final VoidCallback? onFullscreenToggle;
  
  const NetflixMenuBar({
    super.key,
    this.onFullscreenToggle,
  });

  @override
  State<NetflixMenuBar> createState() => _NetflixMenuBarState();
}

class _NetflixMenuBarState extends State<NetflixMenuBar> 
    with TickerProviderStateMixin {
  String? _hoveredMenu;
  String? _activeMenu;
  late AnimationController _menuController;
  late AnimationController _glowController;
  late AnimationController _particleController;
  late Animation<double> _menuAnimation;
  
  bool _showMiniPlayer = false;
  bool _showVideoInfo = false;
  bool _showEqualizer = false;
  bool _showNotes = false;

  @override
  void initState() {
    super.initState();
    _menuController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _menuAnimation = CurvedAnimation(
      parent: _menuController,
      curve: Curves.easeOutCubic,
    );
    
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _menuController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _toggleMenu(String menu) {
    setState(() {
      if (_activeMenu == menu) {
        _activeMenu = null;
        _menuController.reverse();
      } else {
        _activeMenu = menu;
        _menuController.forward();
      }
    });
  }

  void _closeMenu() {
    setState(() {
      _activeMenu = null;
      _menuController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<VideoProvider, SubtitleProvider>(
      builder: (context, videoProvider, subtitleProvider, child) {
        return Stack(
          children: [
            // Main Menu Bar
            Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.95),
                    Colors.black.withOpacity(0.85),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Animated Particles Background
                  AnimatedBuilder(
                    animation: _particleController,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: ParticlePainter(_particleController.value),
                        size: Size.infinite,
                      );
                    },
                  ),
                  
                  // Menu Items
                  Row(
                    children: [
                      const SizedBox(width: 20),
                      
                      // Logo with Glow Effect
                      AnimatedBuilder(
                        animation: _glowController,
                        builder: (context, child) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12, 
                              vertical: 6
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.red[700]!,
                                  Colors.red[900]!
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(
                                    0.5 + (_glowController.value * 0.5)
                                  ),
                                  blurRadius: 20 + (_glowController.value * 10),
                                  spreadRadius: 2 + (_glowController.value * 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.play_circle_filled,
                              color: Colors.white,
                              size: 24,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 32),
                      
                      _buildMenuItem('File', 'file'),
                      _buildMenuItem('Playback', 'playback'),
                      _buildMenuItem('Audio', 'audio'),
                      _buildMenuItem('Subtitles', 'subtitles'),
                      _buildMenuItem('View', 'view'),
                      _buildMenuItem('Tools', 'tools'),
                      
                      const Spacer(),
                      
                      // Quick Actions
                      _buildQuickAction(
                        icon: Icons.folder_open,
                        tooltip: 'Open Video',
                        onTap: () => videoProvider.pickVideo(),
                      ),
                      
                      _buildQuickAction(
                        icon: videoProvider.isPlaying 
                            ? Icons.pause 
                            : Icons.play_arrow,
                        tooltip: videoProvider.isPlaying ? 'Pause' : 'Play',
                        onTap: () => videoProvider.togglePlayPause(),
                        isHighlighted: videoProvider.isInitialized,
                      ),
                      
                      _buildQuickAction(
                        icon: Icons.picture_in_picture_alt,
                        tooltip: 'Mini Player',
                        onTap: () => setState(() => _showMiniPlayer = !_showMiniPlayer),
                        isHighlighted: _showMiniPlayer,
                      ),
                      
                      _buildQuickAction(
                        icon: Icons.info_outline,
                        tooltip: 'Video Info',
                        onTap: () => setState(() => _showVideoInfo = true),
                      ),
                      
                      _buildQuickAction(
                        icon: Icons.fullscreen,
                        tooltip: 'Fullscreen',
                        onTap: widget.onFullscreenToggle,
                      ),
                      
                      const SizedBox(width: 20),
                    ],
                  ),
                  
                  // Dropdown Menu
                  if (_activeMenu != null)
                    Positioned(
                      top: 56,
                      left: _getMenuPosition(_activeMenu!),
                      child: FadeTransition(
                        opacity: _menuAnimation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, -0.1),
                            end: Offset.zero,
                          ).animate(_menuAnimation),
                          child: _buildDropdownMenu(
                            _activeMenu!,
                            videoProvider,
                            subtitleProvider,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Mini Player
            if (_showMiniPlayer)
              Positioned(
                right: 20,
                bottom: 20,
                child: _buildMiniPlayer(videoProvider),
              ),
            
            // Video Info Dialog
            if (_showVideoInfo)
              _buildVideoInfoDialog(videoProvider),
            
            // Equalizer Dialog
            if (_showEqualizer)
              _buildEqualizerDialog(videoProvider),
            
            // Notes Panel
            if (_showNotes)
              _buildNotesPanel(videoProvider),
          ],
        );
      },
    );
  }

  Widget _buildMenuItem(String title, String key) {
    final isActive = _activeMenu == key;
    final isHovered = _hoveredMenu == key;
    
    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredMenu = key),
      onExit: (_) => setState(() => _hoveredMenu = null),
      child: GestureDetector(
        onTap: () => _toggleMenu(key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(
                    colors: [
                      Colors.red.withOpacity(0.3),
                      Colors.red.withOpacity(0.1),
                    ],
                  )
                : isHovered
                    ? LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.15),
                          Colors.white.withOpacity(0.05),
                        ],
                      )
                    : null,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(8)
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isActive ? Colors.red[300] : Colors.white,
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 4),
              AnimatedRotation(
                turns: isActive ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.arrow_drop_down,
                  color: isActive 
                      ? Colors.red[300] 
                      : Colors.white.withOpacity(0.7),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String tooltip,
    VoidCallback? onTap,
    bool isHighlighted = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            gradient: isHighlighted
                ? LinearGradient(
                    colors: [
                      Colors.red.withOpacity(0.3),
                      Colors.red.withOpacity(0.1),
                    ],
                  )
                : LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.08),
                      Colors.white.withOpacity(0.03),
                    ],
                  ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: isHighlighted
                ? [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: IconButton(
            icon: Icon(icon),
            color: isHighlighted ? Colors.red[300] : Colors.white,
            iconSize: 22,
            onPressed: onTap,
          ),
        ),
      ),
    );
  }

  double _getMenuPosition(String menu) {
    switch (menu) {
      case 'file': return 120;
      case 'playback': return 200;
      case 'audio': return 310;
      case 'subtitles': return 390;
      case 'view': return 500;
      case 'tools': return 580;
      default: return 0;
    }
  }

  Widget _buildDropdownMenu(
    String menu,
    VideoProvider videoProvider,
    SubtitleProvider subtitleProvider,
  ) {
    return GestureDetector(
      onTap: () {},
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 280,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1a1a1a).withOpacity(0.95),
                  const Color(0xFF0d0d0d).withOpacity(0.95),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.6),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: Colors.red.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _getMenuItems(menu, videoProvider, subtitleProvider),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _getMenuItems(
    String menu,
    VideoProvider videoProvider,
    SubtitleProvider subtitleProvider,
  ) {
    switch (menu) {
      case 'file':
        return [
          _buildDropdownItem(
            icon: Icons.folder_open,
            title: 'Open Video',
            subtitle: 'Ctrl+O',
            onTap: () {
              videoProvider.pickVideo();
              _closeMenu();
            },
          ),
          _buildDivider(),
          _buildDropdownItem(
            icon: Icons.history,
            title: 'Recent Files',
            onTap: _closeMenu,
          ),
          _buildDropdownItem(
            icon: Icons.close,
            title: 'Close Video',
            subtitle: 'Ctrl+W',
            isDestructive: true,
            onTap: _closeMenu,
          ),
        ];

      case 'playback':
        return [
          _buildDropdownItem(
            icon: videoProvider.isPlaying ? Icons.pause : Icons.play_arrow,
            title: videoProvider.isPlaying ? 'Pause' : 'Play',
            subtitle: 'Space',
            onTap: () {
              videoProvider.togglePlayPause();
              _closeMenu();
            },
          ),
          _buildDropdownItem(
            icon: Icons.stop,
            title: 'Stop',
            onTap: () {
              videoProvider.pause();
              videoProvider.seekTo(Duration.zero);
              _closeMenu();
            },
          ),
          _buildDivider(),
          _buildSectionHeader('Playback Speed'),
          ...[ 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0].map(
            (speed) => _buildSpeedOption(speed, videoProvider),
          ),
        ];

      case 'audio':
        return [
          _buildSectionHeader('Volume'),
          _buildVolumeSlider(videoProvider),
          _buildDivider(),
          _buildDropdownItem(
            icon: Icons.equalizer,
            title: 'Equalizer',
            subtitle: 'Ctrl+E',
            onTap: () {
              setState(() => _showEqualizer = true);
              _closeMenu();
            },
          ),
          _buildDropdownItem(
            icon: Icons.volume_off,
            title: 'Mute',
            subtitle: 'M',
            onTap: () {
              videoProvider.setVolume(0);
              _closeMenu();
            },
          ),
        ];

      case 'subtitles':
        return [
          _buildDropdownItem(
            icon: Icons.subtitles,
            title: 'Load Subtitles',
            onTap: () {
              subtitleProvider.pickSubtitles();
              _closeMenu();
            },
          ),
          _buildDivider(),
          _buildDropdownItem(
            icon: subtitleProvider.isSubtitlesEnabled
                ? Icons.check_box
                : Icons.check_box_outline_blank,
            title: 'Enable Subtitles',
            onTap: () {
              subtitleProvider.toggleSubtitles();
              _closeMenu();
            },
          ),
          if (subtitleProvider.hasSubtitles) ...[
            _buildDivider(),
            _buildSectionHeader('Subtitle Settings'),
            _buildDropdownItem(
              icon: Icons.format_size,
              title: 'Font Size',
              onTap: _closeMenu,
            ),
            _buildDropdownItem(
              icon: Icons.palette,
              title: 'Subtitle Color',
              onTap: _closeMenu,
            ),
          ],
        ];

      case 'view':
        return [
          _buildDropdownItem(
            icon: Icons.fullscreen,
            title: 'Fullscreen',
            subtitle: 'F',
            onTap: () {
              widget.onFullscreenToggle?.call();
              _closeMenu();
            },
          ),
          _buildDivider(),
          _buildDropdownItem(
            icon: Icons.picture_in_picture_alt,
            title: 'Mini Player',
            subtitle: 'Ctrl+M',
            onTap: () {
              setState(() => _showMiniPlayer = !_showMiniPlayer);
              _closeMenu();
            },
          ),
          _buildDropdownItem(
            icon: Icons.aspect_ratio,
            title: 'Aspect Ratio',
            onTap: _closeMenu,
          ),
          _buildDivider(),
          _buildDropdownItem(
            icon: Icons.info_outline,
            title: 'Video Info',
            subtitle: 'Ctrl+I',
            onTap: () {
              setState(() => _showVideoInfo = true);
              _closeMenu();
            },
          ),
        ];

      case 'tools':
        return [
          _buildDropdownItem(
            icon: Icons.camera_alt,
            title: 'Take Screenshot',
            subtitle: 'Ctrl+S',
            onTap: _closeMenu,
          ),
          _buildDropdownItem(
            icon: Icons.fiber_manual_record,
            title: 'Record Screen',
            subtitle: 'Ctrl+R',
            onTap: _closeMenu,
          ),
          _buildDivider(),
          _buildDropdownItem(
            icon: Icons.note_add,
            title: 'Notes',
            subtitle: 'Ctrl+N',
            onTap: () {
              setState(() => _showNotes = !_showNotes);
              _closeMenu();
            },
          ),
          _buildDropdownItem(
            icon: Icons.equalizer,
            title: 'Audio Equalizer',
            onTap: () {
              setState(() => _showEqualizer = true);
              _closeMenu();
            },
          ),
        ];

      default:
        return [];
    }
  }

  Widget _buildDropdownItem({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    bool isDestructive = false,
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

  Widget _buildSpeedOption(double speed, VideoProvider videoProvider) {
    final isActive = false; // TODO: Get from provider
    
    return InkWell(
      onTap: () {
        videoProvider.setPlaybackSpeed(speed);
        _closeMenu();
      },
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

  Widget _buildVolumeSlider(VideoProvider videoProvider) {
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
                value: 0.7,
                onChanged: (value) => videoProvider.setVolume(value),
              ),
            ),
          ),
          Icon(Icons.volume_up, color: Colors.white.withOpacity(0.7), size: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
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

  Widget _buildDivider() {
    return Divider(
      color: Colors.white.withOpacity(0.1),
      height: 1,
      thickness: 1,
    );
  }

  // Mini Player Widget
  Widget _buildMiniPlayer(VideoProvider videoProvider) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 300,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Video Preview
              Center(
                child: Icon(
                  Icons.play_circle_outline,
                  size: 60,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              
              // Close Button
              Positioned(
                top: 8,
                right: 8,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => setState(() => _showMiniPlayer = false),
                ),
              ),
              
              // Controls
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          videoProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                        ),
                        onPressed: () => videoProvider.togglePlayPause(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Video Info Dialog
  Widget _buildVideoInfoDialog(VideoProvider videoProvider) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _showVideoInfo = false),
        child: Container(
          color: Colors.black.withOpacity(0.7),
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 400,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1a1a1a).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.info, color: Colors.red, size: 28),
                            const SizedBox(width: 12),
                            const Text(
                              'Video Information',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () => setState(() => _showVideoInfo = false),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildInfoRow('Duration', '02:15:30'),
                        _buildInfoRow('Format', 'MP4'),
                        _buildInfoRow('Resolution', '1920x1080'),
                        _buildInfoRow('FPS', '60'),
                        _buildInfoRow('Bitrate', '5.2 Mbps'),
                        _buildInfoRow('Codec', 'H.264'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$label:',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Equalizer Dialog
  Widget _buildEqualizerDialog(VideoProvider videoProvider) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => setState(() => _showEqualizer = false),
        child: Container(
          color: Colors.black.withOpacity(0.7),
          child: Center(
            child: GestureDetector(
              onTap: () {},
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 500,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1a1a1a).withOpacity(0.95),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withOpacity(0.3),
                          blurRadius: 30,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.equalizer, color: Colors.red, size: 28),
                            const SizedBox(width: 12),
                            const Text(
                              'Audio Equalizer',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.white),
                              onPressed: () => setState(() => _showEqualizer = false),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildEQBand('60Hz', 0.5),
                            _buildEQBand('170Hz', 0.3),
                            _buildEQBand('310Hz', 0.7),
                            _buildEQBand('600Hz', 0.4),
                            _buildEQBand('1kHz', 0.6),
                            _buildEQBand('3kHz', 0.5),
                            _buildEQBand('6kHz', 0.8),
                            _buildEQBand('12kHz', 0.6),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Preset Buttons
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _buildPresetButton('Flat'),
                            _buildPresetButton('Pop'),
                            _buildPresetButton('Rock'),
                            _buildPresetButton('Jazz'),
                            _buildPresetButton('Classical'),
                            _buildPresetButton('Bass Boost'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEQBand(String label, double value) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: RotatedBox(
            quarterTurns: 3,
            child: SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                activeTrackColor: Colors.red,
                inactiveTrackColor: Colors.white.withOpacity(0.2),
                thumbColor: Colors.red,
                overlayColor: Colors.red.withOpacity(0.3),
              ),
              child: Slider(
                value: value,
                onChanged: (val) {},
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPresetButton(String label) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Notes Panel
  Widget _buildNotesPanel(VideoProvider videoProvider) {
    return Positioned(
      right: 20,
      top: 80,
      bottom: 20,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 320,
            decoration: BoxDecoration(
              color: const Color(0xFF1a1a1a).withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.red.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.2),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red.withOpacity(0.3),
                        Colors.red.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.note_add, color: Colors.red, size: 24),
                      const SizedBox(width: 12),
                      const Text(
                        'Notes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => setState(() => _showNotes = false),
                      ),
                    ],
                  ),
                ),
                
                // Current Time Display
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.white.withOpacity(0.05),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Current: 00:15:30',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Notes List
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildNoteItem('00:15:30', 'Important scene to remember'),
                      _buildNoteItem('00:45:20', 'Character development moment'),
                      _buildNoteItem('01:12:45', 'Major plot twist here'),
                      _buildNoteItem('01:45:10', 'Beautiful cinematography'),
                    ],
                  ),
                ),
                
                // Add Note Input
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Write a note...',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add),
                        label: const Text('Add Note at Current Time'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoteItem(String timestamp, String note) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  timestamp,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  Icons.play_circle_outline,
                  color: Colors.white.withOpacity(0.6),
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.red.withOpacity(0.6),
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            note,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// Particle Painter for Background Animation
class ParticlePainter extends CustomPainter {
  final double animation;
  
  ParticlePainter(this.animation);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;
    
    // Create multiple particles with different properties
    for (int i = 0; i < 30; i++) {
      final progress = (animation + (i / 30)) % 1.0;
      final x = (size.width / 30) * i + (progress * 100);
      final y = math.sin((progress * 2 * math.pi) + (i * 0.3)) * 15 + 28;
      final opacity = (math.sin(progress * math.pi) * 0.3).clamp(0.0, 1.0);
      
      // Draw particle with glow effect
      paint.color = Colors.red.withOpacity(opacity);
      canvas.drawCircle(
        Offset(x % size.width, y),
        2 + (math.sin(progress * math.pi) * 1),
        paint,
      );
      
      // Add subtle glow
      paint.color = Colors.red.withOpacity(opacity * 0.3);
      canvas.drawCircle(
        Offset(x % size.width, y),
        4 + (math.sin(progress * math.pi) * 2),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}