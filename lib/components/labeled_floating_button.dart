import 'package:cloud/components/floating_button.dart';
import 'package:flutter/material.dart';

class LabeledFloatingButton extends StatelessWidget {

  final String label;
  final IconData icon;
  final void Function() onPressed;
  const LabeledFloatingButton({super.key, required this.label, required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 10),
          child: Text(
              label, style: TextStyle(
            fontWeight: FontWeight.bold
          )),
        ),
        FloatingButton(
          icon: icon,
          onPressed: onPressed,
        )
      ],
    );
  }
}
