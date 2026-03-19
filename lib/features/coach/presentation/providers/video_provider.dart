import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

final videoControllerProvider = StateNotifierProvider.family<
    VideoControllerNotifier, VideoPlayerController?, String?>(
  (ref, videoUrl) => VideoControllerNotifier(videoUrl),
);

class VideoControllerNotifier
    extends StateNotifier<VideoPlayerController?> {
  VideoControllerNotifier(String? videoUrl) : super(null) {
    if (videoUrl != null && videoUrl.isNotEmpty) {
      _init(videoUrl);
    }
  }

  Future<void> _init(String videoUrl) async {
    try {
      final controller =
          VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await controller.initialize();
      controller.setLooping(true);
      controller.play();
      state = controller;
    } catch (e) {
      debugPrint('ERREUR init vidéo : $e');
      state = null;
    }
  }

  @override
  void dispose() {
    state?.dispose();
    super.dispose();
  }
}
