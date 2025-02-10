import 'package:flutter/material.dart';

class Feature {
  final String title;
  final String description;
  final IconData icon;
  final int requiredInvites;

  Feature({
    required this.title,
    required this.description,
    required this.icon,
    required this.requiredInvites,
  });
}

Map<String, Feature> limitedFeatures = {
  "function_0": Feature(
    title: '複数画像投稿',
    description: '1回の投稿で最大4枚まで',
    icon: Icons.image,
    requiredInvites: 1,
  ),
  "function_01": Feature(
    title: "グループチャット",
    description: "複数人でのチャットを作成",
    icon: Icons.group,
    requiredInvites: 3,
  ),
  "function_02": Feature(
    title: 'ビデオ通話',
    description: '友達とビデオ通話',
    icon: Icons.videocam,
    requiredInvites: 5,
  ),
};
