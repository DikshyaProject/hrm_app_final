import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:hrm_app/constants/images_url.dart';
import 'package:hrm_app/constants/toast.dart';
import 'package:hrm_app/functions/navigation_functions.dart';
import 'package:hrm_app/screens/gallery_view_image.dart';
import 'package:hrm_app/screens/open_image_full_view.dart';
import 'package:hrm_app/widgets/appbar.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/colors.dart';
import '../constants/sized_box.dart';
import '../services/api_urls.dart';
import '../services/webservices.dart';
import '../widgets/CustomTexts.dart';
import '../widgets/round_edged_button.dart';

class announcement_details extends StatefulWidget {
  String? announce_id;
  announcement_details({Key? key, required this.announce_id}) : super(key: key);

  @override
  State<announcement_details> createState() => _announcement_detailsState();
}

class _announcement_detailsState extends State<announcement_details> {
  bool loading = false;
  bool isShowImage = false;
  Map detail_list = {};
  double percentage = 0.0;
  List imageList = [];
  List pdfList = [];

  assigningMediaInList() {
    for (int index = 0; index < detail_list['files'].length; index++) {
      if (detail_list['files'][index]['file_type'].toString() == 'image') {
        imageList.add(detail_list['files'][index]);
      } else {
        pdfList.add(detail_list['files'][index]);
      }
      setState(() {});
    }
  }

  announcementDetailApi() async {
    checkPermission();

    setState(() {
      loading = true;
    });

    Map<String, dynamic> request = {'announce_id': widget.announce_id};

    final response = await Webservices.postData(
        apiUrl: ApiUrls.get_announcement_detail,
        request: request,
        isGetMethod: true);

    setState(() {
      loading = false;
    });

    if (response['status'].toString() == '1') {
      detail_list = response['data'];

      assigningMediaInList();

      for (int i = 0; i < detail_list['files'].length; i++)
        detail_list['files'][i]['downloading'] = false;

      print("detail_list$detail_list");
    } else {
      toast(response['message']);
    }
  }

  static Future<void> checkPermission() async {
    if (!kIsWeb) {
      if (Platform.isAndroid || Platform.isIOS) {
        var permissionStatus = await Permission.storage.status;

        switch (permissionStatus) {
          case PermissionStatus.denied:
          case PermissionStatus.permanentlyDenied:
            await Permission.storage.request();
            break;
          default:
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    announcementDetailApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: appBar(context: context, title: 'Announcement Detail'),
      body: loading == true
          ? Center(
              child: CupertinoActivityIndicator(
              radius: 12,
              color: MyColors.blackColor,
            ))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  vSizedBox05,
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: MyColors.primaryColor.withOpacity(0.2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ParagraphText(
                            '${detail_list['title']}',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          vSizedBox05,
                          ParagraphText(
                            '${detail_list['description']}',
                            fontSize: 12,
                            color: MyColors.hintColor,
                            maxline: 2,
                          ),
                          vSizedBox10,
                          Row(
                            children: [
                              ParagraphText(
                                'Total attachments: ',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: MyColors.blackColor,
                              ),
                              ParagraphText(
                                '${detail_list['files'].length}',
                                fontSize: 12,
                                color: MyColors.blackColor,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  vSizedBox10,
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: MyColors.boxBorderColor, width: 1),
                      color: MyColors.boxBackgroundColor,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (detail_list['files'].length != 0)
                          for (int i = 0; i < detail_list['files'].length; i++)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  color: MyColors.green4.withOpacity(0.2),
                                ),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 5, 20, 5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ParagraphText(
                                        'Attachment ${i + 1} :',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      detail_list['files'][i]['file_type'] ==
                                              'image'
                                          ? RoundEdgedButton(
                                              text: 'View Image',
                                              width: 125,
                                              height: 30,
                                              borderRadius: 5,
                                              fontSize: 12,
                                              color: MyColors.green4,
                                              leftTextPadding: 10,
                                              rightTextPadding: 10,
                                              iconSize: 20,
                                              onTap: () {
                                                if (imageList.length != 0) {
                                                  push(
                                                      context: context,
                                                      screen:
                                                          gallery_view_image(
                                                        images: imageList,
                                                        imgImdex: i,
                                                      ));
                                                }
                                              },
                                            )
                                          : RoundEdgedButton(
                                              text: 'Download ',
                                              width: 125,
                                              height: 30,
                                              borderRadius: 5,
                                              fontSize: 12,
                                              color: detail_list['files'][i]
                                                          ['downloading'] ==
                                                      true
                                                  ? MyColors.grey1
                                                  : MyColors.green4,
                                              leftTextPadding: 10,
                                              rightTextPadding: 10,
                                              iconSize: 20,
                                              icon: detail_list['files'][i]
                                                          ['file_type'] ==
                                                      'application'
                                                  ? MyImages.pdf
                                                  : MyImages.doc_symbol,
                                              onTap: () {
                                                if (detail_list['files'][i]
                                                        ['downloading'] ==
                                                    false)
                                                  FileDownloader.downloadFile(
                                                    url:
                                                        "${detail_list['files'][i]['file']}",
                                                    onDownloadCompleted:
                                                        (path) async {
                                                      final File file =
                                                          File(path);
                                                      toast(
                                                          "File has been downloaded successfully");

                                                      ///open downloaded file
                                                      await OpenFile.open(path);
                                                    },
                                                    onProgress:
                                                        (String? fileName,
                                                            double progress) {
                                                      print(
                                                          'FILE fileName HAS PROGRESS $progress');
                                                      percentage = progress;
                                                      setState(() {});
                                                      if (progress == 0.0) {
                                                        setState(() {
                                                          detail_list['files']
                                                                      [i][
                                                                  'downloading'] =
                                                              true;
                                                          toast(
                                                              "Downloading starts");
                                                        });
                                                      } else if (progress ==
                                                          100.0) {
                                                        setState(() {
                                                          detail_list['files']
                                                                      [i][
                                                                  'downloading'] =
                                                              false;
                                                        });
                                                      }
                                                    },
                                                  );
                                              },
                                            ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                      ],
                    ),
                  ),
                  vSizedBox10,
                ],
              ),
            ),
    );
  }
}
