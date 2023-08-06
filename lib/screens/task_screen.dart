import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hrm_app/constants/colors.dart';
import 'package:hrm_app/constants/images_url.dart';
import 'package:hrm_app/constants/toast.dart';
import 'package:hrm_app/functions/navigation_functions.dart';
import 'package:hrm_app/screens/task_details.dart';
import 'package:hrm_app/services/api_urls.dart';
import 'package:hrm_app/services/webservices.dart';
import 'package:hrm_app/widgets/appbar.dart';
import 'package:hrm_app/widgets/custom_dropdown.dart';
import 'package:hrm_app/widgets/custom_text_field.dart';
import 'package:hrm_app/widgets/dropdown.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:searchfield/searchfield.dart';
import '../constants/global_data.dart';
import '../constants/sized_box.dart';
import '../widgets/CustomTexts.dart';
import '../widgets/round_edged_button.dart';

class task_screen extends StatefulWidget {
  task_screen({
    Key? key,
  }) : super(key: key);

  @override
  State<task_screen> createState() => _task_screenState();
}

class _task_screenState extends State<task_screen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  late PageController _pageController;
  TextEditingController search = TextEditingController();
  TextEditingController taskName = TextEditingController();
  TextEditingController date = TextEditingController();
  TextEditingController time = TextEditingController();
  TextEditingController desc = TextEditingController();
  String? selectedVal;
  String? selectedValPriority;
  bool loading = false;
  bool addTaskLoading = false;
  List all_task_data = [];
  List completed_task_data = [];
  Map? selectedEmp;
  Map? selectedCC;
  List empList = [];
  DateTime selectedDate1 = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String formattedTime = '';
  List<File> selectedFiles = [];
  int selectedAssineeId = 0;
  int selectedCcId = 0;
  List<dynamic> filteredTask = [];
  List<dynamic> completedFilteredTask = [];

  void filterTask() {
    filteredTask = [];
    completedFilteredTask = [];

    setState(() {
      for (int index = 0; index < all_task_data.length; index++) {
        if (all_task_data[index]['title']
                .toString()
                .toLowerCase()
                .contains(search.text.toLowerCase()) ||
            all_task_data[index]['description']
                .toString()
                .toLowerCase()
                .contains(search.text.toLowerCase())) {
          filteredTask.add(all_task_data[index]);
        }
      }

      for (int index = 0; index < completed_task_data.length; index++) {
        for (int i = 0;
            i < completed_task_data[index]['task_data'].length;
            i++) {
          if (completed_task_data[index]['task_data'][i]['title']
                  .toString()
                  .toLowerCase()
                  .contains(search.text.toLowerCase()) ||
              completed_task_data[index]['task_data'][i]['description']
                  .toString()
                  .toLowerCase()
                  .contains(search.text.toLowerCase()) ||
              completed_task_data[index]['task_data'][i]['task_status']
                      ['task_start']
                  .toString()
                  .toLowerCase()
                  .contains(search.text.toLowerCase()) ||
              completed_task_data[index]['task_data'][i]['task_status']
                      ['task_end']
                  .toString()
                  .toLowerCase()
                  .contains(search.text.toLowerCase())) {
            completedFilteredTask
                .add(completed_task_data[index]['task_data'][i]);
          }
        }
      }
    });
  }

  ///multiple image upload code
  Future pickMultipleFile() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: true);

    if (result != null) {
      selectedFiles = result.paths.map((path) => File(path!)).toList();
      print('selectedfiles===$selectedFiles');
    } else {
      print("No file selected");
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
      allTaskListApi();

      if (all_task_data[i]['task_status'] == null) {
        toast('Task has been started successfully');
      } else if (all_task_data[i]['task_status'] != null &&
          all_task_data[i]['task_status']['status'].toString() != '1') {
        toast('Task has been completed successfully');
      }
    }
  }

  allTaskListApi() async {
    setState(() {
      loading = true;
    });

    Map<String, dynamic> request = {
      'company_id': userData.company_id.toString(),
      'employee_id': userData.id.toString(),
    };

    final response = await Webservices.postData(
        apiUrl: ApiUrls.get_my_task, request: request, isGetMethod: true);

    setState(() {
      loading = false;
    });

    if (response['status'].toString() == '1') {
      all_task_data = response['data'];
      filteredTask = all_task_data;
      print("all_task_data $all_task_data");

      setState(() {});
    }
    getEmployeeListApi("");
  }

  completedTaskListApi() async {
    setState(() {
      loading = true;
    });

    Map<String, dynamic> request = {
      'company_id': userData.company_id.toString(),
      'employee_id': userData.id.toString(),
    };

    final response = await Webservices.postData(
        apiUrl: ApiUrls.get_completed_task,
        request: request,
        isGetMethod: true);

    setState(() {
      loading = false;
    });

    if (response['status'].toString() == '1') {
      completed_task_data = response['data'];

      for (int index = 0; index < completed_task_data.length; index++)
        completedFilteredTask = completed_task_data[index]['task_data'];
      // completed_copy_data = response['data'];
      print("completed_task_data $completed_task_data");

      setState(() {});
    }
  }

  getEmployeeListApi(name) async {
    Map<String, dynamic> request = {
      'company_id': userData.company_id.toString(),
      'employee_id': userData.id.toString(),
      'name': name,
    };

    final response = await Webservices.postData(
        apiUrl: ApiUrls.get_employee_list, request: request, isGetMethod: true);

    if (response['status'].toString() == '1') {
      empList = response['data'];
      log("empList${empList}");
    }
  }

  addTaskApi() async {
    Map<String, dynamic> request = {
      'title': taskName.text,
      'start_date': DateFormat('yyyy-MM-dd').format(selectedDate1).toString(),
      'start_time': formattedTime,
      'employee_ids': selectedAssineeId.toString(),
      'description': desc.text,
      'priority': selectedValPriority ?? "",
      'company_id': userData.company_id.toString(),
      'employee_id': userData.id.toString(),
      'cc_to': selectedCcId.toString(),
    };

    Map<String, dynamic> imageFile = {};

    if (selectedFiles.length != 0) {
      for (int i = 0; i < selectedFiles.length; i++)
        imageFile['files[$i]'] = selectedFiles[i];
    }

    print('add task request==> $request');
    print('add task file==> $imageFile');

    final response = await Webservices.postDataWithImageFunction(
        body: request,
        files: imageFile,
        apiUrl: ApiUrls.add_new_task,
        errorAlert: false);

    print("add task response$response");

    if (response['status'].toString() == '1') {
      Navigator.pop(context);
      allTaskListApi();
      toast(response['message']);
    } else {
      Navigator.pop(context);
      if (taskName.text == '' ||
          desc.text == '' ||
          selectedValPriority == '' ||
          selectedCcId.toString() == '0') {
        toast('You have not filled complete form');
      } else {
        toast('Something went wrong');
      }
    }
    setState(() {
      addTaskLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    _pageController = PageController(initialPage: tabController.index);
    tabController.addListener(() {
      _pageController.animateToPage(
        tabController.index,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
    allTaskListApi();
  }

  void _handleTabChange(index) {
    switch (index) {
      case 0:
        allTaskListApi();
        break;
      case 1:
        completedTaskListApi();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          backgroundColor: MyColors.backgroundColor,
          appBar: appBar(
            context: context,
            title: 'Task',
            implyLeading: false,
            bottom: TabBar(
              controller: tabController,
              labelColor: MyColors.primaryColor,
              unselectedLabelColor: MyColors.hintColor,
              indicator: ShapeDecoration(
                shape: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: MyColors.primaryColor,
                        width: 2,
                        style: BorderStyle.solid)),
              ),
              tabs: <Widget>[
                ParagraphText(
                  'All Task',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                ParagraphText(
                  'Completed Task',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ],
              onTap: (index) {
                _handleTabChange(index);
                tabController.index = index;
                setState(() {});
              },
            ),
          ),
          body: Column(
            children: [
              ///search bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: MyColors.whiteColor,
                    boxShadow: [
                      BoxShadow(
                        color:
                            MyColors.grey1.withOpacity(0.8), //color of shadow
                        spreadRadius: 0.2,
                        blurRadius: 3,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  child: CustomTextField(
                    controller: search,
                    hintText: 'Search Task',
                    hintcolor: MyColors.blackColor,
                    borderColor: MyColors.whiteColor,
                    fontsize: 12,
                    borderRadius: 20,
                    preffix: Icon(
                      CupertinoIcons.search,
                      color: MyColors.blackColor,
                      size: 25,
                    ),
                    suffix2: Container(
                      alignment: Alignment.center,
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: MyColors.primaryColor.withOpacity(0.1),
                      ),
                      child: Icon(
                        CupertinoIcons.chevron_forward,
                        color: MyColors.primaryColor,
                        size: 20,
                      ),
                    ),
                    onChanged: (val) {
                      filterTask();
                      setState(() {});
                    },
                  ),
                ),
              ),

              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    print("about to page change");
                    _handleTabChange(index);
                    tabController.index = index;
                    search.clear();
                    setState(() {});
                    print("after page change ${tabController.index}");
                  },
                  children: <Widget>[
                    loading == true
                        ? Center(
                            child: CupertinoActivityIndicator(
                            radius: 12,
                            color: MyColors.blackColor,
                          ))
                        : all_task_data.length == 0
                            ? Center(
                                child: ParagraphText(
                                'No Task Present',
                                fontSize: 12,
                                color: MyColors.grey1,
                                fontWeight: FontWeight.w700,
                              ))
                            : filteredTask.isEmpty
                                ? Container(
                                    height: 500,
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'No Task Present :(',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: MyColors.grey1,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          // Image.asset(MyImages.sad_emoji, height: 50,)
                                        ],
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: ListView.builder(
                                        itemCount: filteredTask.length,
                                        itemBuilder: (context, index) {
                                          return Padding(
                                            padding: EdgeInsets.only(
                                                bottom: index ==
                                                        all_task_data.length - 1
                                                    ? 60
                                                    : 0),
                                            child: GestureDetector(
                                              onTap: () async {
                                                await push(
                                                    context: context,
                                                    screen: task_details(
                                                      task_id:
                                                          filteredTask[index]
                                                                  ['id']
                                                              .toString(),
                                                    ));
                                                allTaskListApi();
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: MyColors
                                                          .boxBorderColor,
                                                      width: 1),
                                                  color: MyColors
                                                      .boxBackgroundColor,
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 20,
                                                      vertical: 10),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      ParagraphText(
                                                        '${filteredTask[index]['title']}',
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                      vSizedBox05,
                                                      ParagraphText(
                                                        '${filteredTask[index]['description']}',
                                                        fontSize: 9,
                                                        maxline: 2,
                                                        color: MyColors
                                                            .body_font_color,
                                                      ),
                                                      vSizedBox10,
                                                      if (filteredTask[index][
                                                                  'task_status'] !=
                                                              null &&
                                                          filteredTask[index][
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
                                                              'Start Time: ${filteredTask[index]['task_status']['task_start'].toString().substring(11, 16)}',
                                                              fontSize: 9,
                                                              color: MyColors
                                                                  .green4,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                            ParagraphText(
                                                              'Completed on: ${filteredTask[index]['task_status']['task_end'].toString().substring(11, 16)}',
                                                              fontSize: 9,
                                                              color: MyColors
                                                                  .green4,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                          ],
                                                        ),
                                                      if (filteredTask[index][
                                                                  'task_status'] ==
                                                              null ||
                                                          filteredTask[index][
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
                                                                if (filteredTask[
                                                                            index]
                                                                        [
                                                                        'task_status'] !=
                                                                    null)
                                                                  ParagraphText(
                                                                    filteredTask[index]['task_status']['status'].toString() ==
                                                                            '0'
                                                                        ? 'Status: Running'
                                                                        : filteredTask[index]['task_status']['status'].toString() ==
                                                                                '1'
                                                                            ? 'Status: Completed'
                                                                            : '',
                                                                    fontSize: 9,
                                                                    color: filteredTask[index]['task_status']['status']
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
                                                                if (filteredTask[
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
                                                                  'Priority: ${filteredTask[index]['priority']}',
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
                                                                          color:
                                                                              MyColors.blackColor,
                                                                        ),
                                                                        ParagraphText(
                                                                          '${filteredTask[index]['attachment'].length}',
                                                                          fontSize:
                                                                              9,
                                                                          color:
                                                                              MyColors.blackColor,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    vSizedBox05,
                                                                    ParagraphText(
                                                                      '${filteredTask[index]['start_date']}',
                                                                      fontSize:
                                                                          9,
                                                                      color: MyColors
                                                                          .blackColor,
                                                                    ),
                                                                  ],
                                                                ),
                                                                RoundEdgedButton(
                                                                  text: filteredTask[index]
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
                                                                  border_color:
                                                                      Colors
                                                                          .transparent,
                                                                  color: filteredTask[index]
                                                                              [
                                                                              'startTaskLoading'] ==
                                                                          true
                                                                      ? MyColors
                                                                          .grey1
                                                                      : filteredTask[index]['task_status'] ==
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
                                              ),
                                            ),
                                          );
                                        }),
                                  ),

                    ///completed
                    loading == true
                        ? Center(
                            child: CupertinoActivityIndicator(
                            radius: 12,
                            color: MyColors.blackColor,
                          ))
                        : completed_task_data.length == 0
                            ? Center(
                                child: ParagraphText(
                                'No Completed Task Present',
                                fontSize: 12,
                                color: MyColors.grey1,
                                fontWeight: FontWeight.w700,
                              ))
                            : completedFilteredTask.isEmpty
                                ? Container(
                                    height: 500,
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'No Completed Task :(',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: MyColors.grey1,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          // Image.asset(MyImages.sad_emoji, height: 50,)
                                        ],
                                      ),
                                    ),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10),
                                    child: ListView.builder(
                                        itemCount: completedFilteredTask.length,
                                        itemBuilder: (context, index) {
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20),
                                                child: ParagraphText(
                                                  '${completed_task_data[index]['task_start']}',
                                                  fontSize: 12,
                                                ),
                                              ),
                                              vSizedBox10,
                                              for (int i = 0;
                                                  i <
                                                      completedFilteredTask
                                                          .length;
                                                  i++)
                                                GestureDetector(
                                                  onTap: () {
                                                    push(
                                                        context: context,
                                                        screen: task_details(
                                                          task_id:
                                                              completedFilteredTask[
                                                                      i]['id']
                                                                  .toString(),
                                                        ));
                                                  },
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: index ==
                                                                completed_task_data
                                                                    .length
                                                            ? 80
                                                            : 0),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color: MyColors
                                                                .boxBorderColor,
                                                            width: 1),
                                                        color: MyColors
                                                            .boxBackgroundColor,
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 20,
                                                                vertical: 15),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            ParagraphText(
                                                              '${completedFilteredTask[i]['title']}',
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                            vSizedBox05,
                                                            ParagraphText(
                                                              '${completedFilteredTask[i]['description']}',
                                                              fontSize: 9,
                                                              maxline: 2,
                                                              color: MyColors
                                                                  .body_font_color,
                                                            ),
                                                            vSizedBox10,
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                ParagraphText(
                                                                  'Start Time: ${completedFilteredTask[i]['task_status']['task_start'].toString().substring(11, 16)}',
                                                                  fontSize: 9,
                                                                  color: MyColors
                                                                      .green4,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                                ParagraphText(
                                                                  'Completed on: ${completedFilteredTask[i]['task_status']['task_end'].toString().substring(11, 16)}',
                                                                  fontSize: 9,
                                                                  color: MyColors
                                                                      .green4,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              vSizedBox10,
                                            ],
                                          );
                                        }),
                                  ),
                  ],
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            backgroundColor: MyColors.primaryColor,
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return StatefulBuilder(builder: (context, dialogSetState) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: AlertDialog(
                        scrollable: true,
                        backgroundColor: MyColors.whiteColor,
                        insetPadding: EdgeInsets.zero,
                        contentPadding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        content: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: MyColors.whiteColor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ParagraphText(
                                  'Add Task',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                                vSizedBox20,
                                ParagraphText(
                                  'Task Name',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                                vSizedBox05,
                                Container(
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
                                  child: CustomTextField(
                                    controller: taskName,
                                    hintText: 'Task Name',
                                    borderColor: Colors.transparent,
                                  ),
                                ),
                                vSizedBox20,
                                ParagraphText(
                                  'Date',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                                vSizedBox05,
                                Container(
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
                                  child: CustomTextField(
                                    controller: date,
                                    hintText: 'Date',
                                    borderColor: Colors.transparent,
                                    enabled: false,
                                    onTap: () {
                                      showDatePicker(
                                          context: context,
                                          initialDate: selectedDate1,
                                          firstDate: DateTime.now(),
                                          lastDate: DateTime.now()
                                              .add(Duration(days: 100000)),
                                          builder: (context, child) {
                                            return Theme(
                                              data: Theme.of(context).copyWith(
                                                colorScheme:
                                                    const ColorScheme.light(
                                                  primary:
                                                      MyColors.primaryColor,
                                                  onPrimary: Color(0xffE2E2E2),
                                                  onSurface: Color(0xff1C1F24),
                                                ),
                                              ),
                                              child: child!,
                                            );
                                          }).then((value) {
                                        DateTime newDate = DateTime(
                                            value != null
                                                ? value.year
                                                : selectedDate1.year,
                                            value != null
                                                ? value.month
                                                : selectedDate1.month,
                                            value != null
                                                ? value.day
                                                : selectedDate1.day,
                                            selectedDate1.hour,
                                            selectedDate1.minute);
                                        setState(() {
                                          selectedDate1 = newDate;
                                          print(
                                              "selectedDate1${DateFormat("yyyy-MM-dd").format(selectedDate1)}");
                                          date.text = DateFormat("dd-MM-yyyy")
                                              .format(selectedDate1);
                                        });
                                      });
                                    },
                                  ),
                                ),
                                vSizedBox20,
                                ParagraphText(
                                  'Start Time',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                                vSizedBox05,
                                Container(
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
                                  child: CustomTextField(
                                      controller: time,
                                      hintText: 'Select Time',
                                      borderColor: Colors.transparent,
                                      enabled: false,
                                      onTap: () async {
                                        final TimeOfDay? newTime =
                                            await showTimePicker(
                                                context: context,
                                                initialTime: selectedTime,
                                                builder: (context, child) {
                                                  return Theme(
                                                    data: Theme.of(context)
                                                        .copyWith(
                                                      colorScheme:
                                                          const ColorScheme
                                                              .light(
                                                        primary: MyColors
                                                            .primaryColor,
                                                        onPrimary:
                                                            Color(0xffE2E2E2),
                                                        onSurface:
                                                            Color(0xff1C1F24),
                                                      ),
                                                    ),
                                                    child: child!,
                                                  );
                                                });
                                        if (newTime != null) {
                                          setState(() {
                                            selectedTime = newTime;
                                            print(
                                                "_time  ${selectedTime.hour}:${selectedTime.minute}");
                                            formattedTime =
                                                "${selectedTime.hour}:${selectedTime.minute}";
                                            print(
                                                "formattedTime== $formattedTime");
                                            time.text =
                                                selectedTime.format(context);
                                          });
                                        }
                                      }),
                                ),
                                vSizedBox20,
                                ParagraphText(
                                  'Assinee',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                                vSizedBox05,
                                Container(
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
                                  child: SearchField(
                                    searchInputDecoration: InputDecoration(
                                        border: InputBorder.none),
                                    suggestions: empList
                                        .map(
                                          (e) => SearchFieldListItem(
                                            e['name'],
                                            item: e,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(e['name']),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    suggestionsDecoration: SuggestionDecoration(
                                      borderRadius: BorderRadius.circular(10),
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
                                    onSuggestionTap: (x) {
                                      selectedAssineeId = (x.item as Map)['id'];
                                      print("selctAssinee===>${x.item}");
                                      print(
                                          "selctAssineeId===>${selectedAssineeId}");
                                    },
                                  ),
                                ),
                                vSizedBox20,
                                ParagraphText(
                                  'CC',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                                vSizedBox05,
                                Container(
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
                                  child: SearchField(
                                    searchInputDecoration: InputDecoration(
                                        border: InputBorder.none),
                                    suggestions: empList
                                        .map(
                                          (e) => SearchFieldListItem(
                                            e['name'],
                                            item: e,
                                            child: Padding(
                                              padding: EdgeInsets.all(8.0),
                                              child: Text(e['name']),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    suggestionsDecoration: SuggestionDecoration(
                                      borderRadius: BorderRadius.circular(10),
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
                                    onSuggestionTap: (x) {
                                      selectedCcId = (x.item as Map)['id'];
                                      print("selectedCcId===>${x.item}");
                                      print("selectedCcId===>${selectedCcId}");
                                    },
                                  ),
                                ),
                                vSizedBox20,
                                ParagraphText(
                                  'Description',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                                vSizedBox05,
                                Container(
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
                                  child: CustomTextField(
                                    controller: desc,
                                    hintText: 'Add description',
                                    borderColor: Colors.transparent,
                                  ),
                                ),
                                vSizedBox20,
                                ParagraphText(
                                  'Priority',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                                vSizedBox05,
                                Container(
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
                                  child: DropDown(
                                    items: ['High', 'Medium', 'Low'],
                                    label: 'Priority',
                                    selectedValue: selectedValPriority,
                                    height: 50,
                                    borderRadius: 10,
                                    width: MediaQuery.of(context).size.width,
                                    borderColor:
                                        MyColors.grey1.withOpacity(0.5),
                                    dropdownwidth:
                                        MediaQuery.of(context).size.width /
                                            1.09,
                                    onChange: (val) {
                                      dialogSetState(() {
                                        selectedValPriority = val;
                                        print(
                                            "selectedValPriority$selectedValPriority");
                                      });
                                    },
                                  ),
                                ),
                                vSizedBox20,
                                ParagraphText(
                                  'Add Document',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                                vSizedBox05,
                                Row(
                                  children: [
                                    RoundEdgedButton(
                                      text: 'ATTACH FILE',
                                      textColor: MyColors.hintColor,
                                      width: 180,
                                      fontSize: 13,
                                      height: 45,
                                      borderRadius: 30,
                                      border_color:
                                          MyColors.grey1.withOpacity(0.5),
                                      color: MyColors.whiteColor,
                                      icon: MyImages.attach_tilt,
                                      iconSize: 25,
                                      leftTextPadding: 10,
                                      rightTextPadding: 10,
                                      onTap: () async {
                                        await pickMultipleFile();
                                        dialogSetState(() {});
                                      },
                                    ),
                                    if (selectedFiles.length != 0)
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0),
                                            child: Icon(
                                              Icons.check_circle,
                                              color: MyColors.primaryColor,
                                            ),
                                          ),
                                          hSizedBox10,
                                          ParagraphText(
                                            '${selectedFiles.length} doc selected',
                                            fontSize: 10,
                                            color: MyColors.blackColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ],
                                      )
                                  ],
                                ),
                                vSizedBox20,
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    RoundEdgedButton(
                                      text: "Add",
                                      width:
                                          MediaQuery.of(context).size.width / 3,
                                      color: addTaskLoading == true
                                          ? MyColors.primaryColor
                                              .withOpacity(0.4)
                                          : MyColors.primaryColor,
                                      onTap: () async {
                                        addTaskLoading = true;
                                        tabController.index = 0;
                                        setState(() {});
                                        dialogSetState(() {});
                                        await addTaskApi();
                                        selectedFiles.clear();
                                        taskName.clear();
                                        date.clear();
                                        desc.clear();
                                        dialogSetState(() {});
                                      },
                                    ),
                                    RoundEdgedButton(
                                      text: "Cancel",
                                      width:
                                          MediaQuery.of(context).size.width / 3,
                                      color: MyColors.grey11,
                                      onTap: () {
                                        selectedFiles.clear();
                                        taskName.clear();
                                        date.clear();
                                        desc.clear();
                                        setState(() {});
                                        Navigator.pop(context);
                                      },
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  });
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
