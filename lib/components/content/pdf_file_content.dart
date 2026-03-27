import 'package:amphi/models/app_localizations.dart';
import 'package:cloud/models/file_model.dart';
import 'package:cloud/utils/screen_size.dart';
import 'package:cloud/views/desktop_text_file_view.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../../channels/app_web_channel.dart';

class PdfFileContent extends StatelessWidget {

  final FileModel fileModel;
  const PdfFileContent({super.key, required this.fileModel});

  @override
  Widget build(BuildContext context) {
    if(fileModel.size > 10 * 1024 * 1024) {
      return Text(AppLocalizations.of(context).get("message_file_too_large"));
    }
    else {
      final result = SfPdfViewer.network(
        "${appWebChannel.serverAddress}/cloud/files/${fileModel.id}/download",
        headers: {
          "Authorization": appWebChannel.token
        },
      );

      if(isDesktop()) {
        return DesktopTextFileView(child: result);
      }
      return result;
    }
  }
}
