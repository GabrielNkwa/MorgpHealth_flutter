import 'package:flutter/material.dart';
import 'package:kivicare_flutter/utils/extensions/string_extensions.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/report_model.dart';
import 'package:kivicare_flutter/utils/common.dart';

class ReportComponent extends StatelessWidget {
  final ReportData reportData;
  final VoidCallback? deleteReportData;
  final bool isForMyReportScreen;
  final bool isDeleteOn;

  ReportComponent({required this.reportData, this.deleteReportData, this.isForMyReportScreen = false, this.isDeleteOn = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecorationDefault(color: isForMyReportScreen ? context.cardColor : context.scaffoldBackgroundColor),
      margin: EdgeInsets.only(top: 8, bottom: 8),
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          if (reportData.uploadReport != null && reportData.uploadReport.validate().isNotEmpty)
            Image(
              height: 40,
              width: 40,
              image: AssetImage(reportData.uploadReport!.fileFormatImage()),
            )
          else
            Image(image: AssetImage(ic_invalidURL), color: grey.withOpacity(0.2), height: 30, width: 30),
          16.width,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("${reportData.name.validate()}", style: boldTextStyle(), maxLines: 2, overflow: TextOverflow.ellipsis),
              4.height,
              Text(reportData.date.validate(), style: secondaryTextStyle(size: 10)),
            ],
          ).expand(),
          8.width,
          Row(
            children: [
              if (reportData.uploadReport.validateURL())
                TextButton(
                  onPressed: () {
                    commonLaunchUrl(reportData.uploadReport.validate(), launchMode: LaunchMode.externalApplication).catchError((e) {
                      throw e;
                    });
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: radius(), side: BorderSide(color: context.scaffoldBackgroundColor))),
                    padding: MaterialStateProperty.all(
                      EdgeInsets.only(top: 0, right: 8, left: 8, bottom: 0),
                    ),
                  ),
                  child: Text('${locale.lblViewFile}', style: primaryTextStyle(size: 12)),
                ),
              if (deleteReportData != null && !isPatient())
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.delete, size: 20, color: Colors.red),
                  onPressed: deleteReportData,
                ).visible(isDeleteOn),
            ],
          ),
          8.height,
        ],
      ),
    );
  }
}
