import 'package:flutter/material.dart';
import 'package:ofoqe_naween/components/sidebar/sidebarx_item.dart';
import 'package:sidebarx/sidebarx.dart';

class MySidebar extends StatefulWidget {
  @override
  _MySidebarState createState() => _MySidebarState();
}

class _MySidebarState extends State<MySidebar> {
  final SidebarXController controller = SidebarXController(selectedIndex: 0);
  int? expandedIndex;

  final List<CustomSidebarXItem> items = [
    CustomSidebarXItem(
      icon: Icons.home,
      label: 'Home',
      onTap: () {
        // Handle main item tap
      },
    ),
    CustomSidebarXItem(
      icon: Icons.settings,
      label: 'Settings',
      subItems: [
        SidebarXSubItem(
          icon: Icons.security,
          label: 'Security',
          onTap: () {
            // Handle sub-item tap
          },
        ),
        SidebarXSubItem(
          icon: Icons.account_circle,
          label: 'Account',
          onTap: () {
            // Handle sub-item tap
          },
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      child: ListView(
        children: [
          SidebarX(
            controller: controller,
            items: items.map((item) {
              return SidebarXItem(
                icon: item.icon,
                label: item.label,
                onTap: () {
                  if (item.subItems != null) {
                    setState(() {
                      expandedIndex = expandedIndex == items.indexOf(item) ? null : items.indexOf(item);
                    });
                  } else {
                    if (item.onTap != null) item.onTap!();
                  }
                },
              );
            }).toList(),
          ),
          if (expandedIndex != null && items[expandedIndex!].subItems != null)
            ...items[expandedIndex!].subItems!.map((subItem) {
              return ListTile(
                leading: Icon(subItem.icon),
                title: Text(subItem.label),
                onTap: subItem.onTap,
              );
            }).toList(),
        ],
      ),
    );
  }
}
