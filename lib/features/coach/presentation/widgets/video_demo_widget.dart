import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../providers/video_provider.dart';

class VideoDemoWidget extends ConsumerStatefulWidget {
  final String? videoUrl;

  const VideoDemoWidget({super.key, this.videoUrl});

  @override
  ConsumerState<VideoDemoWidget> createState() => _VideoDemoWidgetState();
}

class _VideoDemoWidgetState extends ConsumerState<VideoDemoWidget> {
  bool _muted = false;

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(videoControllerProvider(widget.videoUrl));

    if (controller == null || !controller.value.isInitialized) {
      return _Placeholder();
    }

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: controller.value.size.width,
              height: controller.value.size.height,
              child: VideoPlayer(controller),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.black54,
            ),
            icon: Icon(
              _muted ? Icons.volume_off : Icons.volume_up,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _muted = !_muted;
                controller.setVolume(_muted ? 0 : 1);
              });
            },
          ),
        ),
      ],
    );
  }
}

class _Placeholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.play_circle_outline, size: 64, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            'Démonstration non disponible',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
