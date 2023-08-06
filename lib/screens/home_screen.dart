import 'dart:developer';
import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hrm_app/constants/colors.dart';
import 'package:hrm_app/constants/global_data.dart';
import 'package:hrm_app/constants/global_keys.dart';
import 'package:hrm_app/constants/images_url.dart';
import 'package:hrm_app/constants/sized_box.dart';
import 'package:hrm_app/constants/toast.dart';
import 'package:hrm_app/functions/navigation_functions.dart';
import 'package:hrm_app/screens/announcement_details.dart';
import 'package:hrm_app/screens/login_via_phone.dart';
import 'package:hrm_app/screens/setting_screen.dart';
import 'package:hrm_app/screens/task_screen.dart';
import 'package:hrm_app/services/api_urls.dart';
import 'package:hrm_app/services/onesignal.dart';
import 'package:hrm_app/services/webservices.dart';
import 'package:hrm_app/widgets/CustomTexts.dart';
import 'package:hrm_app/widgets/round_edged_button.dart';
import 'package:intl/intl.dart';
import '../widgets/appbar.dart';
import 'announcement.dart';

class home_screen extends StatefulWidget {
  const home_screen({Key? key}) : super(key: key);

  @override
  State<home_screen> createState() => _home_screenState();
}

class _home_screenState extends State<home_screen> {
  bool isPunchInLoading = false;
  List punch_in_data = [];
  var punchInStatus;
  Position? _currentPosition;
  String? _currentAddress;
  String? fullAddress;
  bool loading = false;
  DateTime todayDate = DateTime.now();
  var formattedDate = DateFormat("dd-MM-yyyy").format(DateTime.now());
  bool _showCartBadge = false;
  ValueNotifier<String?> badge_count = ValueNotifier('');
  List all_task_data = [];
  bool load2 = false;

  interval_api() async {
    Map<String, dynamic> request = {
      'employee_id': userData.id.toString(),
      'company_id': userData.company_id.toString(),
    };

    final res = await Webservices.postData(
        apiUrl: ApiUrls.interval,
        request: request,
        isGetMethod: true,
        showSuccessMessage: false);
    log("interval_api_response=============$res");
    badge_count.value = res['data']['unread_noti'].toString();
    _showCartBadge = badge_count.value.toString() != "";
    print("badge_count${badge_count.value}");

    if (res['data']['status'].toString() == "0") {
      isUserBlocked();
    }

    Future.delayed(Duration(seconds: 25), () {
      interval_api();
    });
  }

  isUserBlocked() {
    prefs.clear();
    pushAndRemoveUntil(context: context, screen: login_via_phone());
    toast(
        'Sorry, temporary you are blocked by company, Contact your admin for login credentials');
  }

  getTaskListApi() async {
    Map<String, dynamic> request = {
      'company_id': userData.company_id.toString(),
      'employee_id': userData.id.toString(),
      'date': DateFormat("yyyy-MM-dd").format(DateTime.now()).toString()
    };

    final response = await Webservices.postData(
        apiUrl: ApiUrls.get_my_task, request: request, isGetMethod: true);

    setState(() {
      loading = false;
    });

    if (response['status'].toString() == '1') {
      all_task_data = response['data'];
      print("all_leave_data $all_task_data");

      setState(() {});
    }
    interval_api();
  }

  chekingPunchInEligibleApi() async {
    Map<String, dynamic> request = {
      'company_id': userData.company_id.toString(),
      'employee_id': userData.id.toString(),
    };

    final response = await Webservices.postData(
        apiUrl: ApiUrls.get_punchin_out_eligible,
        request: request,
        isGetMethod: true,
        showErrorMessage: false);

    setState(() {
      load2 = false;
    });
    setState(() {
      isPunchInLoading = false;
    });

    if (response['status'].toString() != '0') {
      punch_in_data = response['data'];
      punchInStatus = response['status'].toString();
      print("punch_in_data $punch_in_data");
      print("punchInStatus $punchInStatus");

      setState(() {});
    }
  }

  punchInOutApi() async {
    setState(() {
      isPunchInLoading = true;
    });

    Map<String, dynamic> request = {
      'company_id': userData.company_id.toString(),
      'employee_id': userData.id.toString(),
      'lat': _currentPosition?.latitude.toString(),
      'lng': _currentPosition?.longitude.toString(),
      'address': fullAddress,
    };

    final res = await Webservices.postData(
      apiUrl: ApiUrls.punch,
      request: request,
    );

    if (res['status'].toString() == "1") {
      chekingPunchInEligibleApi();
      print("punch in successful");
    }
  }

  startEndTaskApi(i) async {
    setState(() {
      all_task_data[i]['startTaskLoading'] = true;
    });

    Map<String, dynamic> request = {
      'company_id': userData.company_id.toString(),
      'employee_id': userData.id.toString(),
      'task_id': all_task_data[i]['id'].toString()
    };

    final response = await Webservices.postData(
      apiUrl: ApiUrls.start_end_task,
      request: request,
    );

    setState(() {
      all_task_data[i]['startTaskLoading'] = false;
    });

    if (response['status'].toString() == '1') {
      getTaskListApi();

      if (all_task_data[i]['task_status'] == null)
        toast('Task has been started successfully');
    }
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      _getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });
    print('LAT: ${_currentPosition?.latitude ?? ""}');
    print('LNG: ${_currentPosition?.longitude ?? ""}');
    print('myADDRESS: ${_currentAddress ?? ""}');
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
      });
      fullAddress =
          '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
      print("fullAddress $fullAddress");
    }).catchError((e) {
      debugPrint(e);
    });
  }

  callFunction() async {
    setState(() {
      load2 = true;
      loading = true;
    });

    await _getCurrentPosition();

    getTaskListApi();
    chekingPunchInEligibleApi();
  }

  @override
  void initState() {
    setNotificationHandler(context);
    callFunction();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
          // backgroundColor: MyColors.backgroundColor,
          appBar: appBar(
              context: context,
              implyLeading: false,
              title: 'Welcome to BeAmOrg',
              actions: [
                InkWell(
                  onTap: () async {
                    await push(context: context, screen: setting_screen());

                    print("checking by mizan");
                    setState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Image.asset(
                      MyImages.setting_fill,
                      color: MyColors.hintColor,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () async {
                    await push(context: context, screen: announcement());
                    interval_api();
                  },
                  child: ValueListenableBuilder(
                      valueListenable: badge_count,
                      builder: (context, notiCount, child) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              right: 15, top: 20, bottom: 20),
                          child: badges.Badge(
                            position: badges.BadgePosition.topEnd(
                              top: -12,
                            ),
                            badgeAnimation: badges.BadgeAnimation.scale(
                              animationDuration: Duration(seconds: 1),
                              colorChangeAnimationDuration:
                                  Duration(seconds: 1),
                              loopAnimation: false,
                              curve: Curves.fastOutSlowIn,
                              colorChangeAnimationCurve: Curves.easeInCubic,
                            ),
                            showBadge: _showCartBadge,
                            badgeStyle: badges.BadgeStyle(
                              badgeColor: Colors.red,
                            ),
                            badgeContent: Text(
                              badge_count.value.toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                            child: Image.asset(
                              MyImages.bell,
                            ),
                          ), //badge_count.value
                        );
                      }),
                ),
              ]),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    hSizedBox20,
                    Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border:
                                Border.all(color: MyColors.green4, width: 2.5)),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: CachedNetworkImage(
                              imageUrl: userData!.image!,
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                            ))),
                    hSizedBox10,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                            text: TextSpan(children: [
                          TextSpan(
                              text: 'Good Morning ',
                              style: TextStyle(
                                  fontSize: 14, color: MyColors.blackColor)),
                          TextSpan(
                              text: userData.Name.toString(),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: MyColors.primaryColor)),
                        ])),
                        ParagraphText(
                          'Welcome to BeAmOrg',
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ],
                    ),
                  ],
                ),
                vSizedBox20,
                load2 == true
                    ? Container()
                    : Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: MyColors.boxBorderColor, width: 1),
                          color: MyColors.boxBackgroundColor,
                        ),
                        child: Column(
                          children: [
                            vSizedBox10,
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  ParagraphText(
                                    'Today Attendance',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.calendar_month_outlined,
                                        size: 17,
                                      ),
                                      hSizedBox05,
                                      ParagraphText(
                                        '$formattedDate ${DateFormat.EEEE().format(todayDate)}',
                                        fontSize: 12,
                                        color: MyColors.blackColor,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Divider(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Center(
                                  child: RoundEdgedButton(
                                    text: punchInStatus == "1"
                                        ? 'Punch Out time'
                                        : 'Punch in time',
                                    fontSize: 12,
                                    width:
                                        MediaQuery.of(context).size.width / 3,
                                    height: 40,
                                    border_color: Colors.transparent,
                                    color: isPunchInLoading == true
                                        ? MyColors.primaryColor.withOpacity(0.4)
                                        : MyColors.primaryColor,
                                    onTap: () {
                                      punchInOutApi();
                                    },
                                  ),
                                ),
                                for (int i = 0; i < punch_in_data.length; i++)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 25, vertical: 3),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        if (punch_in_data[i]['human_in'] !=
                                            null)
                                          ParagraphText(
                                            'Punch in ${punch_in_data[i]['human_in']}',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        if (punch_in_data[i]['human_out'] !=
                                            null)
                                          ParagraphText(
                                            'Punch out ${punch_in_data[i]['human_out']}',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          )
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            vSizedBox10,
                          ],
                        )),
                vSizedBox20,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ParagraphText(
                            'Today Task',
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                          GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                MyGlobalKeys.bottomTabKey.currentState!
                                    .onItemTapped(1);
                              },
                              child: ParagraphText(
                                'See all task',
                                fontSize: 10,
                                color: MyColors.primaryColor,
                                underlined: true,
                              )),
                        ],
                      ),
                    ),
                    vSizedBox10,
                    loading == true
                        ? Center(
                            child: CupertinoActivityIndicator(
                              radius: 12,
                              color: MyColors.blackColor,
                            ),
                          )
                        : all_task_data.length == 0
                            ? Container(
                                height: 100,
                                alignment: Alignment.center,
                                child: ParagraphText(
                                  'No Task for today',
                                  fontSize: 12,
                                  color: MyColors.grey1,
                                  fontWeight: FontWeight.w700,
                                ))
                            : SizedBox(
                                height: all_task_data.length == 1
                                    ? MediaQuery.of(context).size.height / 7.5
                                    : MediaQuery.of(context).size.height / 3.8,
                                child: loading == true
                                    ? Center(
                                        child: CupertinoActivityIndicator(
                                        radius: 12,
                                        color: MyColors.blackColor,
                                      ))
                                    : ListView.builder(
                                        itemCount: all_task_data.length,
                                        itemBuilder: (context, index) {
                                          if (index != 0 || index != 1) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color:
                                                        MyColors.boxBorderColor,
                                                    width: 1),
                                                color:
                                                    MyColors.boxBackgroundColor,
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 10),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    ParagraphText(
                                                      '${all_task_data[index]['title']}',
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    vSizedBox05,
                                                    ParagraphText(
                                                      '${all_task_data[index]['description']}',
                                                      fontSize: 9,
                                                      maxline: 2,
                                                      color: MyColors
                                                          .body_font_color,
                                                    ),
                                                    vSizedBox10,
                                                    if (all_task_data[index][
                                                                'task_status'] !=
                                                            null &&
                                                        all_task_data[index][
                                                                        'task_status']
                                                                    ['status']
                                                                .toString() ==
                                                            '1')
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          ParagraphText(
                                                            'Start Time: ${all_task_data[index]['task_status']['task_start'].toString().substring(11, 16)}',
                                                            fontSize: 9,
                                                            color:
                                                                MyColors.green4,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                          ParagraphText(
                                                            'Completed on: ${all_task_data[index]['task_status']['task_end'].toString().substring(11, 16)}',
                                                            fontSize: 9,
                                                            color:
                                                                MyColors.green4,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ],
                                                      ),
                                                    if (all_task_data[index][
                                                                'task_status'] ==
                                                            null ||
                                                        all_task_data[index][
                                                                        'task_status']
                                                                    ['status']
                                                                .toString() !=
                                                            '1')
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .end,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              if (all_task_data[
                                                                          index]
                                                                      [
                                                                      'task_status'] !=
                                                                  null)
                                                                ParagraphText(
                                                                  all_task_data[index]['task_status']['status']
                                                                              .toString() ==
                                                                          '0'
                                                                      ? 'Status: Running'
                                                                      : all_task_data[index]['task_status']['status'].toString() ==
                                                                              '1'
                                                                          ? 'Status: Completed'
                                                                          : '',
                                                                  fontSize: 9,
                                                                  color: all_task_data[index]['task_status']['status']
                                                                              .toString() ==
                                                                          '0'
                                                                      ? MyColors
                                                                          .progress_task
                                                                      : MyColors
                                                                          .green4,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              if (all_task_data[
                                                                          index]
                                                                      [
                                                                      'task_status'] ==
                                                                  null)
                                                                ParagraphText(
                                                                  'Status: Pending',
                                                                  fontSize: 9,
                                                                  color: MyColors
                                                                      .lightOrange,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ParagraphText(
                                                                'Priority: ${all_task_data[index]['priority']}',
                                                                fontSize: 9,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: MyColors
                                                                    .redColor,
                                                              ),
                                                            ],
                                                          ),
                                                          vSizedBox10,
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Column(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      ParagraphText(
                                                                        'Total attachments: ',
                                                                        fontSize:
                                                                            9,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        color: MyColors
                                                                            .blackColor,
                                                                      ),
                                                                      ParagraphText(
                                                                        '${all_task_data[index]['attachment'].length}',
                                                                        fontSize:
                                                                            9,
                                                                        color: MyColors
                                                                            .blackColor,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  vSizedBox05,
                                                                  ParagraphText(
                                                                    ' ${all_task_data[index]['start_date']}',
                                                                    fontSize: 9,
                                                                    color: MyColors
                                                                        .blackColor,
                                                                  ),
                                                                ],
                                                              ),
                                                              RoundEdgedButton(
                                                                text: all_task_data[index]
                                                                            [
                                                                            'task_status'] ==
                                                                        null
                                                                    ? 'START'
                                                                    : 'END',
                                                                width: 55,
                                                                height: 20,
                                                                borderRadius:
                                                                    30,
                                                                fontSize: 10,
                                                                border_color: Colors
                                                                    .transparent,
                                                                color: all_task_data[index]
                                                                            [
                                                                            'startTaskLoading'] ==
                                                                        true
                                                                    ? MyColors
                                                                        .grey1
                                                                    : all_task_data[index]['task_status'] ==
                                                                            null
                                                                        ? MyColors
                                                                            .start_task
                                                                        : MyColors
                                                                            .end_task,
                                                                verticalMargin:
                                                                    0,
                                                                onTap: () {
                                                                  startEndTaskApi(
                                                                      index);
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          } else {
                                            return Container(
                                              height: 0,
                                            );
                                          }
                                        }),
                              ),
                    vSizedBox10,
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ParagraphText(
                            'Upcoming Meetings',
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                          ParagraphText(
                            'See all meetings',
                            fontSize: 10,
                            color: MyColors.green4,
                            underlined: true,
                          ),
                        ],
                      ),
                    ),
                    vSizedBox10,
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: MyColors.boxBorderColor, width: 1),
                        color: MyColors.boxBackgroundColor,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ParagraphText(
                              'Project name',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            vSizedBox10,
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ParagraphText(
                                  'Meeting Link',
                                  fontSize: 10,
                                  color: MyColors.green3,
                                  fontWeight: FontWeight.w600,
                                  underlined: true,
                                ),
                                ParagraphText(
                                  'Meeting Created by: Admin',
                                  fontSize: 10,
                                  color: MyColors.blackColor,
                                ),
                              ],
                            ),
                            vSizedBox10,
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ParagraphText(
                                  '18-05-2023',
                                  fontSize: 10,
                                  color: MyColors.blackColor,
                                ),
                                ParagraphText(
                                  '02:00pm',
                                  fontSize: 10,
                                  color: MyColors.blackColor,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    vSizedBox10,
                    vSizedBox05,
                  ],
                ),
              ],
            ),
          )),
    );
  }
}
