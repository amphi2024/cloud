import 'package:amphi/models/app_localizations.dart';
import 'package:cloud/models/file_model.dart';
import 'package:flutter/material.dart';

import '../utils/bytes_utils.dart';

class FileDetailDialog extends StatelessWidget {

  final FileModel fileModel;
  const FileDetailDialog({super.key, required this.fileModel});

  @override
  Widget build(BuildContext context) {
    final fontSize = Theme.of(context).textTheme.bodyMedium!.fontSize! - 1;

    return Dialog(
      child: SizedBox(
        width: 275,
        height: 250,
        child: ListView(
          padding: EdgeInsets.all(8),
          children: [
            Text(fileModel.name, softWrap: true, maxLines: 3,
                textAlign: TextAlign.center,
                style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
            Text(AppLocalizations.of(context).get("created"), style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize)),
            Text(fileModel.created.toLocalizedString(context), softWrap: true, maxLines: 3,),
            Text(AppLocalizations.of(context).get("modified"), style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize)),
            Text(fileModel.created.toLocalizedString(context), softWrap: true, maxLines: 3,),
            Text(AppLocalizations.of(context).get("uploaded"), style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize)),
            Text(fileModel.created.toLocalizedString(context), softWrap: true, maxLines: 3,),
            if(!fileModel.isFolder) ...[
              Text(AppLocalizations.of(context).get("size"), style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize)),
              Text(formatBytes(fileModel.size), softWrap: true, maxLines: 3,),
            ]
          ],
        ),
      ),
    );
  }
}