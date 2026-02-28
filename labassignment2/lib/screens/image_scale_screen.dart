import 'package:flutter/material.dart';

class ImageScaleScreen extends StatefulWidget {
  const ImageScaleScreen({super.key});

  @override
  State<ImageScaleScreen> createState() => _ImageScaleScreenState();
}

class _ImageScaleScreenState extends State<ImageScaleScreen> {
  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _offset = Offset.zero;

  void _handleDoubleTap() {
    setState(() {
      if (_scale > 1.0) {
        _scale = 1.0;
        _offset = Offset.zero; // Reset position when zooming out
      } else {
        _scale = 3.0; // Zoom in
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Scale')),
      body: ClipRect(
        child: GestureDetector(
          onDoubleTap: _handleDoubleTap,
          onScaleStart: (ScaleStartDetails details) {
            _previousScale = _scale;
          },
          onScaleUpdate: (ScaleUpdateDetails details) {
            setState(() {
              _scale = (_previousScale * details.scale).clamp(1.0, 5.0);
              
              // Only allow panning/dragging if zoomed in
              if (_scale > 1.0) {
                _offset += details.focalPointDelta;
              } else {
                _offset = Offset.zero;
              }
            });
          },
          child: Container(
            color: Colors.transparent, // Capture gestures on the whole screen area
            width: double.infinity,
            height: double.infinity,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..translate(_offset.dx, _offset.dy)
                ..scale(_scale),
              child: Center(
                child: Image.network(
                  'https://picsum.photos/400',
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const CircularProgressIndicator();
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.broken_image, size: 100);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
