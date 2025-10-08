import 'package:amphi/models/app_localizations.dart';
import 'package:cloud/models/app_settings.dart';
import 'package:cloud/views/settings_view.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        appSettings.save();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: Builder(builder: (context) {
            return IconButton(onPressed: () {
              Navigator.pop(context);
            }, icon: Icon(Icons.arrow_back_ios));
          }),
          title: Text(AppLocalizations.of(context).get("@settings")),
          centerTitle: true,
        ),
        body: SettingsView(),
      ),
    );
  }
}