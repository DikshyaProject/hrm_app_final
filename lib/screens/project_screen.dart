import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hrm_app/constants/toast.dart';
import 'package:hrm_app/screens/sub_project.dart';
import 'package:hrm_app/services/api_urls.dart';

import '../constants/colors.dart';
import '../constants/global_data.dart';
import '../constants/images_url.dart';
import '../constants/sized_box.dart';
import '../functions/navigation_functions.dart';
import '../services/webservices.dart';
import '../widgets/CustomTexts.dart';
import '../widgets/appbar.dart';
import '../widgets/custom_text_field.dart';

class project_screen extends StatefulWidget {
  const project_screen({Key? key}) : super(key: key);

  @override
  State<project_screen> createState() => _project_screenState();
}

class _project_screenState extends State<project_screen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  late PageController _pageController;
  TextEditingController search = TextEditingController();
  bool loading = false;
  bool isData = false;
  List pending_project_list = [];
  List completed_project_list = [];
  List<dynamic> filteredProjects = [];
  List<dynamic> completedFilteredProjects = [];

  getProjectsApi() async {
    setState(() {
      loading = true;
    });

    Map<String, dynamic> request = {
      'company_id': userData.company_id.toString(),
      'employee_id': userData.id.toString(),
    };

    final response = await Webservices.postData(
        apiUrl: ApiUrls.get_all_projects, request: request, isGetMethod: true);

    setState(() {
      loading = false;
    });

    if (response['status'].toString() == '1') {
      for (int i = 0; i < response['data'].length; i++) {
        if (response['data'][i]['status'].toString() == '0') {
          pending_project_list.add(response['data'][i]);
          filteredProjects = pending_project_list;
        } else {
          completed_project_list.add(response['data'][i]);
          completedFilteredProjects = completed_project_list;
        }
      }

      print("pending_project_list $pending_project_list");
      print("completed_project_list $completed_project_list");
    } else {
      toast(response['message']);
    }
  }

  void filterProjects() {
    filteredProjects = [];
    completedFilteredProjects = [];

    setState(() {
      for (int index = 0; index < pending_project_list.length; index++) {
        if (pending_project_list[index]['title']
                .toString()
                .toLowerCase()
                .contains(search.text.toLowerCase()) ||
            pending_project_list[index]['description']
                .toString()
                .toLowerCase()
                .contains(search.text.toLowerCase())) {
          filteredProjects.add(pending_project_list[index]);
        }
      }

      for (int index = 0; index < completed_project_list.length; index++) {
        if (completed_project_list[index]['title']
                .toString()
                .toLowerCase()
                .contains(search.text.toLowerCase()) ||
            completed_project_list[index]['description']
                .toString()
                .toLowerCase()
                .contains(search.text.toLowerCase())) {
          completedFilteredProjects.add(completed_project_list[index]);
        }
      }
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
    getProjectsApi();
  }

  void _handleTabChange(index) {
    // if (tabController.indexIsChanging) {
    switch (index) {
      case 0:
        {
          print('First tab tapped');
        }
        break;
      case 1:
        {
          print('Second tab tapped');
        }
        break;
    }

    // }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: MyColors.backgroundColor,
        appBar: appBar(
          context: context,
          implyLeading: false,
          title: 'Projects',
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
                'Pending Projects',
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              ParagraphText(
                'Completed Projects',
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
        body: loading == true
            ? Center(
                child: CupertinoActivityIndicator(
                radius: 12,
                color: MyColors.blackColor,
              ))
            : Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                child: Column(
                  children: [
                    ///search bar
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
                        controller: search,
                        hintText: 'Search Project',
                        hintcolor: MyColors.blackColor,
                        borderColor: MyColors.whiteColor,
                        fontsize: 12,
                        height: 55,
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
                          filterProjects();
                          setState(() {});
                          print(
                              "cccccccccccccccccc${filteredProjects.isEmpty}");
                        },
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
                        children: [
                          ///pending projects
                          pending_project_list.length == 0
                              ? Center(
                                  child: Container(
                                      height: 150,
                                      alignment: Alignment.bottomCenter,
                                      child: ParagraphText(
                                        'No projects available',
                                        fontSize: 12,
                                        color: MyColors.grey1,
                                        fontWeight: FontWeight.w700,
                                      )))
                              : filteredProjects.isEmpty
                                  ? Container(
                                      height: 500,
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'No Pending Projects :(',
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
                                  : ListView.builder(
                                      itemCount: filteredProjects.length,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () {
                                            push(
                                                context: context,
                                                screen: sub_projects(
                                                  project_id:
                                                      filteredProjects[index]
                                                              ['id']
                                                          .toString(),
                                                ));
                                          },
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 20),
                                            child: Row(
                                              children: [
                                                Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(100),
                                                        color: MyColors.blue3),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      child: Image.asset(
                                                        MyImages.project_fill,
                                                        height: 25,
                                                        width: 25,
                                                        fit: BoxFit.cover,
                                                        color: MyColors
                                                            .primaryColor,
                                                      ),
                                                    )),
                                                hSizedBox10,
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    ParagraphText(
                                                      filteredProjects[index]
                                                              ['title']
                                                          .toString(),
                                                      color:
                                                          MyColors.blackColor,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    vSizedBox05,
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              1.5,
                                                      child: Wrap(
                                                        children: [
                                                          ParagraphText(
                                                            filteredProjects[
                                                                        index][
                                                                    'description']
                                                                .toString(),
                                                            color: MyColors
                                                                .blackColor,
                                                            fontSize: 9,
                                                            maxline: 2,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Spacer(),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Image.asset(
                                                      MyImages.person,
                                                      height: 15,
                                                      color:
                                                          MyColors.primaryColor,
                                                    ),
                                                    hSizedBox05,
                                                    ParagraphText(
                                                      filteredProjects[index]
                                                              ['members']
                                                          .length
                                                          .toString(),
                                                      color:
                                                          MyColors.primaryColor,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    hSizedBox05,
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );

                                        // return Container();
                                      }),

                          ///completed projects
                          completed_project_list.length == 0
                              ? Center(
                                  child: Container(
                                      height: 150,
                                      alignment: Alignment.bottomCenter,
                                      child: ParagraphText(
                                        'No projects available',
                                        fontSize: 12,
                                        color: MyColors.grey1,
                                        fontWeight: FontWeight.w700,
                                      )))
                              : completedFilteredProjects.isEmpty
                                  ? Container(
                                      height: 500,
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              'No Completed Projects :(',
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
                                  : ListView.builder(
                                      itemCount:
                                          completedFilteredProjects.length,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          behavior: HitTestBehavior.opaque,
                                          onTap: () {
                                            push(
                                                context: context,
                                                screen: sub_projects(
                                                  project_id:
                                                      completedFilteredProjects[
                                                              index]['id']
                                                          .toString(),
                                                ));
                                          },
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 20),
                                            child: Row(
                                              children: [
                                                Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(100),
                                                        color: MyColors.blue3),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      child: Image.asset(
                                                        MyImages.project_fill,
                                                        height: 25,
                                                        width: 25,
                                                        fit: BoxFit.cover,
                                                        color: MyColors
                                                            .primaryColor,
                                                      ),
                                                    )),
                                                hSizedBox10,
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    ParagraphText(
                                                      completedFilteredProjects[
                                                              index]['title']
                                                          .toString(),
                                                      color:
                                                          MyColors.blackColor,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    vSizedBox05,
                                                    SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              1.5,
                                                      child: Wrap(
                                                        children: [
                                                          ParagraphText(
                                                            completedFilteredProjects[
                                                                        index][
                                                                    'description']
                                                                .toString(),
                                                            color: MyColors
                                                                .blackColor,
                                                            fontSize: 9,
                                                            maxline: 2,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Spacer(),
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Image.asset(
                                                      MyImages.person,
                                                      height: 15,
                                                      color:
                                                          MyColors.primaryColor,
                                                    ),
                                                    hSizedBox05,
                                                    ParagraphText(
                                                      completedFilteredProjects[
                                                              index]['members']
                                                          .length
                                                          .toString(),
                                                      color:
                                                          MyColors.primaryColor,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                    hSizedBox05,
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
