import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TabletMainPage extends ConsumerStatefulWidget {
  const TabletMainPage({super.key});

  @override
  ConsumerState createState() => _DesktopMainPageState();
}

class _DesktopMainPageState extends ConsumerState<TabletMainPage> {
  @override
  Widget build(BuildContext context) {
    //TODO: implement dedicated layout for tablet
    return Container();
  }
}
