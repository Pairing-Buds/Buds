import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? leftIconPath;
  final bool centerTitle;

  const CustomAppBar({
    Key? key,
    this.title,
    this.leftIconPath,
    this.centerTitle = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: centerTitle,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: title != null
          ? Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leftIconPath != null) ...[
            Image.asset(
              leftIconPath!,
              width: 24,
              height: 24,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            title!,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      )
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
