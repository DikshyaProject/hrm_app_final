import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:hrm_app/constants/images_url.dart';
import 'package:hrm_app/constants/toast.dart';
import 'package:hrm_app/functions/navigation_functions.dart';
import 'package:hrm_app/screens/open_image_full_view.dart';
import 'package:hrm_app/widgets/appbar.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/colors.dart';
import '../constants/global_data.dart';
import '../constants/sized_box.dart';
import '../services/api_urls.dart';
import '../services/webservices.dart';
import '../widgets/CustomTexts.dart';
import '../widgets/round_edged_button.dart';
import 'gallery_view_image.dart';

class task_details extends StatefulWidget {
  String? task_id;
  task_details({Key? key, required this.task_id}) : super(key: key);

  @override
  State<task_details> createState() => _task_detailsState();
}

class _task_detailsState extends State<task_details> {
  bool loading = false;
  bool isShowImage = false;
  Map detail_list = {};
  double percentage = 0.0;
  List imageList = [];
  List pdfList = [];

  assigningMediaInList() {
    for (int index = 0; index < detail_list['attachment'].length; index++) {
      if (detail_list['attachment'][index]['file_type'].toString() == 'image') {
        imageList.add(detail_list['attachment'][index]);
      } else {
        pdfList.add(detail_list['attachment'][index]);
      }
      setState(() {});
    }
  }

  taskDetailApi() async {
    checkPermission();

    setState(() {
      loading = true;
    });

    Map<String, dynamic> request = {
      'company_id': userData.company_id.toString(),
      'employee_id': userData.id.toString(),
      'task_id': widget.task_id,
    };

    final response = await Webservices.postData(
        apiUrl: ApiUrls.get_task_detail, request: request, isGetMethod: true);

    setState(() {
      loading = false;
    });

    if (response['status'].toString() == '1') {
      detail_list = response['data'];
      assigningMediaInList();

      for (int i = 0; i < detail_list['attachment'].length; i++)
        detail_list['attachment'][i]['downloading'] = false;

      print("detail_list$detail_list");
    } else {
      toast(response['message']);
    }
  }

  startEndTaskApi() async {
    setState(() {
      detail_list['startTaskLoading'] = true;
    });

    Map<String, dynamic> request = {
      'company_id': userData.company_id.toString(),
      'employee_id': userData.id.toString(),
      'task_id': widget.task_id
    };

    final response = await Webservices.postData(
      apiUrl: ApiUrls.start_end_task,
      request: request,
    );

    setState(() {
      detail_list['startTaskLoading'] = false;
    });

    if (response['status'].toString() == '1') {
      taskDetailApi();

      if (detail_list['task_status'] == null) {
        toast('Task has been started successfully');
      } else if (detail_list['task_status'] != null &&
          detail_list['task_status']['status'].toString() != '1') {
        toast('Task has been completed successfully');
      }
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
    taskDetailApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: appBar(context: context, title: 'Task Detail'),
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ParagraphText(
                                '${detail_list['title']}',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              if (detail_list['task_status'] == null ||
                                  detail_list['task_status']['status']
                                          .toString() !=
                                      '1')
                                RoundEdgedButton(
                                  text: detail_list['task_status'] == null
                                      ? 'START'
                                      : 'END',
                                  width: 55,
                                  height: 20,
                                  borderRadius: 30,
                                  fontSize: 10,
                                  border_color: Colors.transparent,
                                  color: detail_list['startTaskLoading'] == true
                                      ? MyColors.grey1
                                      : detail_list['task_status'] == null
                                          ? MyColors.start_task
                                          : MyColors.end_task,
                                  verticalMargin: 0,
                                  onTap: () {
                                    startEndTaskApi();
                                  },
                                ),
                            ],
                          ),
                          vSizedBox05,
                          ParagraphText(
                            '${detail_list['description']}',
                            fontSize: 12,
                            color: MyColors.hintColor,
                            maxline: 2,
                          ),
                          vSizedBox10,
                          if (detail_list['task_status'] != null &&
                              detail_list['task_status']['status'].toString() ==
                                  '1')
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ParagraphText(
                                  'Start Time: ${detail_list['task_status']['task_start'].toString().substring(11, 16)}',
                                  fontSize: 12,
                                  color: MyColors.green4,
                                  fontWeight: FontWeight.w600,
                                ),
                                ParagraphText(
                                  'Completed on: ${detail_list['task_status']['task_end'].toString().substring(11, 16)}',
                                  fontSize: 12,
                                  color: MyColors.green4,
                                  fontWeight: FontWeight.w600,
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
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (detail_list['task_status'] == null ||
                                  detail_list['task_status']['status']
                                          .toString() !=
                                      '1')
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (detail_list['task_status'] != null)
                                      ParagraphText(
                                        detail_list['task_status']['status']
                                                    .toString() ==
                                                '0'
                                            ? 'Status: Running'
                                            : detail_list['task_status']
                                                            ['status']
                                                        .toString() ==
                                                    '1'
                                                ? 'Status: Completed'
                                                : '',
                                        fontSize: 12,
                                        color: detail_list['task_status']
                                                        ['status']
                                                    .toString() ==
                                                '0'
                                            ? MyColors.progress_task
                                            : MyColors.green4,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    if (detail_list['task_status'] == null)
                                      ParagraphText(
                                        'Status: Pending',
                                        fontSize: 12,
                                        color: MyColors.lightOrange,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ParagraphText(
                                      'Priority: ${detail_list['priority']}',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: MyColors.redColor,
                                    ),
                                  ],
                                ),
                              vSizedBox10,
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      ParagraphText(
                                        'Assign By: ',
                                        fontSize: 12,
                                        color: MyColors.blackColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      ParagraphText(
                                        '${detail_list['created_by']['name']}',
                                        fontSize: 12,
                                        color: MyColors.blackColor,
                                      ),
                                    ],
                                  ),
                                  if (detail_list['cc_data'] != null)
                                    Row(
                                      children: [
                                        ParagraphText(
                                          'Cc: ',
                                          fontSize: 12,
                                          color: MyColors.blackColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        ParagraphText(
                                          '${detail_list['cc_data']['name']}',
                                          fontSize: 12,
                                          color: MyColors.blackColor,
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              vSizedBox10,
                              Row(
                                children: [
                                  ParagraphText(
                                    'Created at: ',
                                    fontSize: 12,
                                    color: MyColors.blackColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  ParagraphText(
                                    '${detail_list['start_date']}',
                                    fontSize: 12,
                                    color: MyColors.blackColor,
                                  ),
                                ],
                              ),
                              vSizedBox10,
                              if (detail_list['task_status'] != null &&
                                  detail_list['task_status']['task_end'] !=
                                      null)
                                Row(
                                  children: [
                                    ParagraphText(
                                      'Finished at: ',
                                      fontSize: 12,
                                      color: MyColors.blackColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    ParagraphText(
                                      '${DateFormat('dd-MM-yyyy HH:mm a').format(DateTime.parse(detail_list['task_status']['task_end']))}',
                                      fontSize: 12,
                                      color: MyColors.blackColor,
                                    ),
                                  ],
                                ),
                              vSizedBox10,
                            ],
                          ),
                        ),
                        if (detail_list['attachment'].length != 0)
                          for (int i = 0;
                              i < detail_list['attachment'].length;
                              i++)
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: MyColors.green4.withOpacity(0.2),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 5, 20, 5),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          ParagraphText(
                                            'Attachment ${i + 1} :',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          detail_list['attachment'][i]
                                                      ['file_type'] ==
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
                                                  color: detail_list['attachment']
                                                                  [i]
                                                              ['downloading'] ==
                                                          true
                                                      ? MyColors.grey1
                                                      : MyColors.green4,
                                                  leftTextPadding: 10,
                                                  rightTextPadding: 10,
                                                  iconSize: 20,
                                                  icon: detail_list[
                                                                  'attachment'][
                                                              i]['file_type'] ==
                                                          'application'
                                                      ? MyImages.pdf
                                                      : MyImages.doc_symbol,
                                                  onTap: () {
                                                    if (detail_list[
                                                                'attachment'][i]
                                                            ['downloading'] ==
                                                        false)
                                                      FileDownloader
                                                          .downloadFile(
                                                        url:
                                                            "${detail_list['attachment'][i]['file']}",
                                                        onDownloadCompleted:
                                                            (path) async {
                                                          final File file =
                                                              File(path);
                                                          toast(
                                                              "File has been downloaded successfully");

                                                          ///open downloaded file
                                                          await OpenFile.open(
                                                              path);
                                                        },
                                                        onProgress: (String?
                                                                fileName,
                                                            double progress) {
                                                          print(
                                                              'FILE fileName HAS PROGRESS $progress');
                                                          percentage = progress;
                                                          setState(() {});
                                                          if (progress == 0.0) {
                                                            setState(() {
                                                              detail_list['attachment']
                                                                          [i][
                                                                      'downloading'] =
                                                                  true;
                                                              toast(
                                                                  "Downloading starts");
                                                            });
                                                          } else if (progress ==
                                                              100.0) {
                                                            setState(() {
                                                              detail_list['attachment']
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
