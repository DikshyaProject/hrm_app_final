import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hrm_app/constants/colors.dart';
import 'package:hrm_app/constants/global_data.dart';
import 'package:hrm_app/constants/toast.dart';
import 'package:hrm_app/functions/navigation_functions.dart';
import 'package:hrm_app/screens/announcement_details.dart';
import 'package:hrm_app/screens/leave_request.dart';
import 'package:hrm_app/screens/sub_project.dart';
import 'package:hrm_app/screens/task_details.dart';
import 'package:hrm_app/services/api_urls.dart';
import 'package:hrm_app/services/webservices.dart';
import 'package:intl/intl.dart';
import '../constants/sized_box.dart';
import '../widgets/CustomTexts.dart';
import '../widgets/appbar.dart';

class announcement extends StatefulWidget {
  const announcement({Key? key}) : super(key: key);

  @override
  State<announcement> createState() => _announcementState();
}

class _announcementState extends State<announcement> {
  bool loading = false;
  List notification_list = [];

  getNotificationApi() async {
    setState(() {
      loading = true;
    });

    Map<String, dynamic> request = {
      'company_id': userData.company_id.toString(),
      'employee_id': userData.id.toString(),
    };

    final response = await Webservices.postData(
        apiUrl: ApiUrls.get_notification, request: request, isGetMethod: true);

    setState(() {
      loading = false;
    });

    if (response['status'].toString() == '1') {
      notification_list = response['data'];
      print("notification_list$notification_list");
    } else {
      toast(response['message']);
    }
  }

  @override
  void initState() {
    getNotificationApi();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: appBar(
        context: context,
        title: 'Announcement ',
      ),
      body: loading == true
          ? Center(
              child: CupertinoActivityIndicator(
              radius: 12,
              color: MyColors.blackColor,
            ))
          : notification_list.length == 0
              ? Center(
                  child: Container(
                      height: 150,
                      alignment: Alignment.bottomCenter,
                      child: ParagraphText(
                        'No announcements yet',
                        fontSize: 12,
                        color: MyColors.grey1,
                        fontWeight: FontWeight.w700,
                      )))
              : ListView.builder(
                  itemCount: notification_list.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        if (notification_list[index]['other']['leave_id']
                                    .toString() !=
                                null &&
                            notification_list[index]['other']['screen'].toString() ==
                                'leave_action') {
                          push(
                              context: context,
                              screen: leave_requset(
                                leave_id: notification_list[index]['other']
                                        ['leave_id']
                                    .toString(),
                              ));
                        } else if (notification_list[index]['other']['task_id']
                                    .toString() !=
                                null &&
                            notification_list[index]['other']['screen'].toString() ==
                                'employee_task') {
                          push(
                              context: context,
                              screen: task_details(
                                task_id: notification_list[index]['other']
                                        ['task_id']
                                    .toString(),
                              ));
                        } else if (notification_list[index]['other']
                                        ['announcement_id']
                                    .toString() !=
                                null &&
                            notification_list[index]['other']['screen'].toString() ==
                                'add_announcement') {
                          push(
                              context: context,
                              screen: announcement_details(
                                announce_id: notification_list[index]['other']
                                        ['announcement_id']
                                    .toString(),
                              ));
                        } else if (notification_list[index]['other']['project_id']
                                    .toString() !=
                                null &&
                            notification_list[index]['other']['screen'].toString() ==
                                'add_project') {
                          push(
                              context: context,
                              screen: sub_projects(
                                project_id: notification_list[index]['other']
                                        ['project_id']
                                    .toString(),
                              ));
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 5),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: MyColors.whiteColor,
                            boxShadow: [
                              BoxShadow(
                                color: MyColors.grey1
                                    .withOpacity(0.8), //color of shadow
                                spreadRadius: 0.2,
                                blurRadius: 3,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 15),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    ParagraphText(
                                      DateFormat("dd-MM-yyyy").format(
                                          DateTime.parse(
                                              notification_list[index]
                                                      ['created_at']
                                                  .toString())),
                                      fontSize: 10,
                                      color: MyColors.primaryColor,
                                    ),
                                    hSizedBox05,
                                    ParagraphText(
                                      '${notification_list[index]['message']}',
                                      fontSize: 10,
                                    ),
                                  ],
                                ),
                                vSizedBox05,
                                ParagraphText(
                                  '${notification_list[index]['time_ago']}',
                                  fontSize: 10,
                                  color: MyColors.grey9,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
    );
  }
}
