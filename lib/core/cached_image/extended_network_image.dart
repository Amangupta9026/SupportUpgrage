import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class CacheImage extends StatefulWidget {
  final String imageUrl;
  final double? height;
  final double? width;
  final Color? color;
  final BlendMode? colorBlendMode;
  final BoxFit? fit;
  final String? semantic;
  const CacheImage(
      {required this.imageUrl,
      this.height,
      this.width,
      this.color,
      this.colorBlendMode,
      this.fit,
      this.semantic,
      Key? key})
      : super(key: key);

  @override
  PrefetchImageState createState() => PrefetchImageState();
}

class PrefetchImageState extends State<CacheImage> {
  @override
  Widget build(BuildContext context) {
    return ExtendedImage.network(
      widget.imageUrl,
      width: widget.width,
      height: widget.height,
      color: widget.color,
      filterQuality: FilterQuality.high,
      cache: true,
      enableLoadState: false,
      colorBlendMode: widget.colorBlendMode,
      fit: widget.fit,
      semanticLabel: widget.semantic,
    );
  }
}
