import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hrm_app/constants/toast.dart';
import 'package:hrm_app/functions/navigation_functions.dart';
import 'package:hrm_app/screens/task_details.dart';
import 'package:hrm_app/services/webservices.dart';
import 'package:hrm_app/widgets/appbar.dart';
import '../constants/colors.dart';
import '../constants/global_data.dart';
import '../constants/images_url.dart';
import '../constants/sized_box.dart';
import '../services/api_urls.dart';
import '../widgets/CustomTexts.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/round_edged_button.dart';
import 'gallery_view_image.dart';

class members_profile_screen extends StatefulWidget {
  String memberId;
  members_profile_screen({Key? key, required this.memberId}) : super(key: key);

  @override
  State<members_profile_screen> createState() => _members_profile_screenState();
}

class _members_profile_screenState extends State<members_profile_screen> {
  bool loading = false;
  TextEditingController search = TextEditingController();
  Map members_detail = {};
  List all_task_data = [];

  membersDetailApi() async {
    setState(() {
      loading = true;
    });

    Map<String, dynamic> request = {
      'user_id': widget.memberId.toString(),
    };
    print('membersDetailRequest $request');

    final response = await Webservices.postData(
        apiUrl: ApiUrls.get_user_data, request: request, isGetMethod: true);

    if (response['status'].toString() == '1') {
      members_detail = response['data'];

      print("members_detail $members_detail");
    } else {
      toast(response['message']);
    }
    allTaskListApi();
  }

  allTaskListApi() async {
    Map<String, dynamic> request = {
      'company_id': userData.company_id.toString(),
      'employee_id': widget.memberId.toString(),
    };

    final response = await Webservices.postData(
        apiUrl: ApiUrls.get_my_task, request: request, isGetMethod: true);

    setState(() {
      loading = false;
    });

    if (response['status'].toString() == '1') {
      all_task_data = response['data'];
      print("all_task_data $all_task_data");

      setState(() {});
    }
  }

  @override
  void initState() {
    membersDetailApi();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MyColors.backgroundColor,
        appBar: appBar(
          context: context,
          // title: loading == true ? '' : '${members_detail['name']}',
          title: "Member's Profile",
        ),
        body: loading == true
            ? Center(
                child: CupertinoActivityIndicator(
                radius: 12,
                color: MyColors.blackColor,
              ))
            : SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: MyColors.purple, width: 2)),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: CachedNetworkImage(
                            imageUrl: members_detail['image'].toString(),
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          )),
                    ),
                    vSizedBox10,
                    Container(
                      color: MyColors.grey1.withOpacity(0.4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                ParagraphText(
                                  'Name: ',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                ParagraphText(
                                  members_detail['name'].toString(),
                                  fontSize: 13,
                                ),
                              ],
                            ),
                            vSizedBox05,
                            Row(
                              children: [
                                ParagraphText(
                                  'Employee Id: ',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                ParagraphText(
                                  members_detail['employee_id'].toString(),
                                  fontSize: 13,
                                ),
                              ],
                            ),
                            vSizedBox05,
                            Row(
                              children: [
                                ParagraphText(
                                  'Email: ',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                ParagraphText(
                                  members_detail['email'].toString(),
                                  fontSize: 13,
                                ),
                              ],
                            ),
                            vSizedBox05,
                            Row(
                              children: [
                                ParagraphText(
                                  'Contact Number: ',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                ParagraphText(
                                  members_detail['phone_with_code'].toString(),
                                  fontSize: 13,
                                ),
                              ],
                            ),
                            vSizedBox05,
                            Row(
                              children: [
                                ParagraphText(
                                  'Address: ',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                ParagraphText(
                                  members_detail['city'].toString(),
                                  fontSize: 13,
                                ),
                              ],
                            ),
                            vSizedBox05,
                            Row(
                              children: [
                                ParagraphText(
                                  'Present Days: ',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                ParagraphText(
                                  members_detail['present_days'].toString(),
                                  fontSize: 13,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    vSizedBox10,

                    ///media

                    Container(
                      color: MyColors.green4.withOpacity(0.2),
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: ParagraphText(
                          'Media',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: MyColors.green4,
                        ),
                      ),
                    ),
                    vSizedBox10,
                    members_detail['media_files'].length == 0
                        ? Center(
                            child: ParagraphText(
                            'No Media Present',
                            fontSize: 12,
                            color: MyColors.grey1,
                            fontWeight: FontWeight.w700,
                          ))
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Wrap(
                                direction: Axis.horizontal,
                                runSpacing: 10,
                                spacing: 5,
                                children: [
                                  for (int index = 0;
                                      index <
                                          members_detail['media_files'].length;
                                      index++)
                                    GestureDetector(
                                      onTap: () {
                                        push(
                                            context: context,
                                            screen: gallery_view_image(
                                              images:
                                                  members_detail['media_files'],
                                              imgImdex: index,
                                              fromMembers: true,
                                            ));
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: MyColors.whiteColor,
                                          boxShadow: [
                                            BoxShadow(
                                              color: MyColors.grey1.withOpacity(
                                                  0.8), //color of shadow
                                              spreadRadius: 0.2,
                                              blurRadius: 3,
                                              offset: Offset(0, 0),
                                            ),
                                          ],
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: CachedNetworkImage(
                                            imageUrl:
                                                '${members_detail['media_files'][index]['media']}',
                                            height: 90,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                3.2,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                    vSizedBox10,

                    ///task
                    Container(
                      color: MyColors.green4.withOpacity(0.2),
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 10),
                        child: ParagraphText(
                          'Task',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: MyColors.green4,
                        ),
                      ),
                    ),
                    vSizedBox10,
                    all_task_data.length == 0
                        ? Center(
                            child: ParagraphText(
                            'No Task Present',
                            fontSize: 12,
                            color: MyColors.grey1,
                            fontWeight: FontWeight.w700,
                          ))
                        : ListView.builder(
                            physics: NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: all_task_data.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.only(
                                    bottom: index == all_task_data.length - 1
                                        ? 60
                                        : 0),
                                child: GestureDetector(
                                  onTap: () async {
                                    await push(
                                        context: context,
                                        screen: task_details(
                                          task_id: all_task_data[index]['id']
                                              .toString(),
                                        ));
                                    allTaskListApi();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: MyColors.boxBorderColor,
                                          width: 1),
                                      color: MyColors.boxBackgroundColor,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ParagraphText(
                                            '${all_task_data[index]['title']}',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          vSizedBox05,
                                          ParagraphText(
                                            '${all_task_data[index]['description']}',
                                            fontSize: 9,
                                            maxline: 2,
                                            color: MyColors.body_font_color,
                                          ),
                                          vSizedBox10,
                                          if (all_task_data[index]
                                                      ['task_status'] !=
                                                  null &&
                                              all_task_data[index]
                                                              ['task_status']
                                                          ['status']
                                                      .toString() ==
                                                  '1')
                                            Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                ParagraphText(
                                                  'Start Time: ${all_task_data[index]['task_status']['task_start'].toString().substring(11, 16)}',
                                                  fontSize: 9,
                                                  color: MyColors.green4,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                ParagraphText(
                                                  'Completed on: ${all_task_data[index]['task_status']['task_end'].toString().substring(11, 16)}',
                                                  fontSize: 9,
                                                  color: MyColors.green4,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ],
                                            ),
                                          if (all_task_data[index]
                                                      ['task_status'] ==
                                                  null ||
                                              all_task_data[index]
                                                              ['task_status']
                                                          ['status']
                                                      .toString() !=
                                                  '1')
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    if (all_task_data[index]
                                                            ['task_status'] !=
                                                        null)
                                                      ParagraphText(
                                                        all_task_data[index][
                                                                            'task_status']
                                                                        [
                                                                        'status']
                                                                    .toString() ==
                                                                '0'
                                                            ? 'Status: Running'
                                                            : all_task_data[index]['task_status']
                                                                            [
                                                                            'status']
                                                                        .toString() ==
                                                                    '1'
                                                                ? 'Status: Completed'
                                                                : '',
                                                        fontSize: 9,
                                                        color: all_task_data[index]
                                                                            [
                                                                            'task_status']
                                                                        [
                                                                        'status']
                                                                    .toString() ==
                                                                '0'
                                                            ? MyColors
                                                                .progress_task
                                                            : MyColors.green4,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    if (all_task_data[index]
                                                            ['task_status'] ==
                                                        null)
                                                      ParagraphText(
                                                        'Status: Pending',
                                                        fontSize: 9,
                                                        color: MyColors
                                                            .lightOrange,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ParagraphText(
                                                      'Priority: ${all_task_data[index]['priority']}',
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: MyColors.redColor,
                                                    ),
                                                  ],
                                                ),
                                                vSizedBox10,
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        ParagraphText(
                                                          'Total attachments: ',
                                                          fontSize: 9,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: MyColors
                                                              .blackColor,
                                                        ),
                                                        ParagraphText(
                                                          '${all_task_data[index]['attachment'].length}',
                                                          fontSize: 9,
                                                          color: MyColors
                                                              .blackColor,
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        ParagraphText(
                                                          'Start Date: ',
                                                          fontSize: 9,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: MyColors
                                                              .blackColor,
                                                        ),
                                                        ParagraphText(
                                                          '${all_task_data[index]['start_date']}',
                                                          fontSize: 9,
                                                          color: MyColors
                                                              .blackColor,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                  ],
                ),
              ));
  }
}
