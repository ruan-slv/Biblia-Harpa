import 'dart:ui';

import 'package:flutter/material.dart';

class CarouselItemModel {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;

  CarouselItemModel(this.title, this.subtitle, this.icon, this.onTap);
}