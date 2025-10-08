import 'dart:io';

import 'package:amphi/models/app_localizations.dart';
import 'package:cloud/channels/app_method_channel.dart';
import 'package:cloud/components/server_setting_component.dart';
import 'package:flutter/material.dart';

import '../models/app_settings.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Visibility(
            visible: Platform.isAndroid &&
                appMethodChannel.systemVersion >= 29,
            child: TitledCheckBox(
                title: AppLocalizations.of(context).get("@transparent_navigation_bar"),
                value: appSettings.transparentNavigationBar,
                onChanged: (value) {
                  setState(() {
                    appSettings.transparentNavigationBar = value!;
                  });
                })),
        ServerSettingComponent()
      ],
    );
  }
}

class TitledCheckBox extends StatelessWidget {
  final String title;
  final bool value;
  final Function onChanged;
  const TitledCheckBox({super.key, required this.title, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(left: 10, top: 5),
            child: Text(
              title,
              textAlign: TextAlign.left,
            ),
          ),
        ),
        Checkbox(
            value: value, onChanged: (value) {
          onChanged(value);
        }),
      ],
    );
  }
}