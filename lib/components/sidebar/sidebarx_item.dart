import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';

class SidebarXSubItem {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  SidebarXSubItem({
    required this.icon,
    required this.label,
    this.onTap,
  });
}

class CustomSidebarXItem extends SidebarXItem {
  final List<SidebarXSubItem>? subItems;

  CustomSidebarXItem({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    this.subItems,
  }) : super(icon: icon, label: label, onTap: onTap);
}
