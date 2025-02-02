import 'package:flutter/material.dart';
import 'package:picnic_app/features/posts/domain/model/post_overlay_theme.dart';

class PostBarButtonParams {
  const PostBarButtonParams({
    required this.onTap,
    required this.overlayTheme,
    this.filledIcon,
    this.outlinedIcon,
    this.lightIconColor,
    this.text,
    this.selected = false,
    this.isVertical = true,
    this.width,
  });

  final String? filledIcon;
  final String? outlinedIcon;
  final Color? lightIconColor;
  final VoidCallback onTap;
  final String? text;
  final PostOverlayTheme overlayTheme;
  final bool selected;
  final bool isVertical;
  final double? width;
}
