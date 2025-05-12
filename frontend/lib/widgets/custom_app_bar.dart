// Flutter imports:
import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final String? leftIconPath;
  final bool centerTitle;
  final bool showBackButton; // 추가

  const CustomAppBar({
    Key? key,
    this.title,
    this.leftIconPath,
    this.centerTitle = true,
    this.showBackButton = true, // 기본값 true
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: centerTitle,
      leading: showBackButton
          ? IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
        onPressed: () => Navigator.pop(context),
      )
          : null, // showBackButton이 false면 leading 자체를 없앰
      title: title != null
          ? Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leftIconPath != null) ...[
            Image.asset(
              leftIconPath!,
              width: 30,
              height: 30,
            ),
            const SizedBox(width: 6),
          ],
          Text(
            title!,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 22,
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
