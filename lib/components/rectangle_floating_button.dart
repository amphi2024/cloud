import 'package:flutter/material.dart';

class RectangleFloatingButton extends StatelessWidget {
  final IconData icon;
  final void Function() onPressed;
  const RectangleFloatingButton({super.key, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor,
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: IconButton(
            style: IconButton.styleFrom(
                backgroundColor: Theme.of(context).floatingActionButtonTheme.backgroundColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            onPressed: onPressed,
            icon: Icon(
              color: Theme.of(context).floatingActionButtonTheme.focusColor,
              icon,
              size: Theme.of(context).floatingActionButtonTheme.iconSize,
            )));
  }
}
