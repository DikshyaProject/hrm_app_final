import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:hrm_app/screens/gallery_view_image.dart';
import 'package:hrm_app/screens/open_image_full_view.dart';
import 'package:hrm_app/screens/user_chat_screen.dart';
import 'package:open_file/open_file.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/colors.dart';
import '../constants/images_url.dart';
import '../constants/sized_box.dart';
import '../constants/toast.dart';
import '../functions/navigation_functions.dart';
import '../services/api_urls.dart';
import '../services/webservices.dart';
import '../widgets/CustomTexts.dart';
import '../widgets/appbar.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/round_edged_button.dart';
import 'channel_chats.dart';
import 'members_profile_screen.dart';

class sub_projects extends StatefulWidget {
  final String project_id;
  sub_projects({Key? key, required this.project_id}) : super(key: key);

  @override
  State<sub_projects> createState() => _sub_projectsState();
}

class _sub_projectsState extends State<sub_projects>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  late PageController _pageController;
  double percentage = 0.0;

  TextEditingController search = TextEditingController();
  List projectList = [
    {
      'name': '#AppDevelopment',
      'msg': '@john Smith, @Nigel, @Jason, @bill',
    },
    {
      'name': '#Development',
      'msg': '@john Smith, @Nigel, @Jason, @bill',
    },
    {
      'name': '#UI&UX',
      'msg': '@john Smith, @Nigel, @Jason, @bill',
    },
  ];
  List imageList = [];
  List pdfList = [];
  Map project_detail = {};
  String searchHint = 'Search Member';
  bool isSearch = true;
  String result = '';
  bool loading = false;
  List<dynamic> filteredMembers = [];

  void filterProjects() {
    filteredMembers = [];

    setState(() {
      for (int index = 0; index < project_detail['members'].length; index++) {
        if (project_detail['members'][index]['name']
                .toString()
                .toLowerCase()
                .contains(search.text.toLowerCase()) ||
            project_detail['members'][index]['email']
                .toString()
                .toLowerCase()
                .contains(search.text.toLowerCase())) {
          filteredMembers.add(project_detail['members'][index]);
        }
      }
    });
  }

  projectDetailApi() async {
    setState(() {
      loading = true;
    });

    Map<String, dynamic> request = {
      'project_id': widget.project_id,
    };

    final response = await Webservices.postData(
        apiUrl: ApiUrls.get_project_by_id, request: request, isGetMethod: true);

    setState(() {
      loading = false;
    });

    if (response['status'].toString() == '1') {
      project_detail = response['data'];
      filteredMembers = project_detail['members'];

      for (int index = 0; index < project_detail['files'].length; index++) {
        if (project_detail['files'][index]['file_type'].toString() == 'image') {
          imageList.add(project_detail['files'][index]);
        } else {
          project_detail['files'][index]['downloading'] = false;
          pdfList.add(project_detail['files'][index]);
        }
        setState(() {});
      }

      for (int i = 0; i < pdfList.length; i++) {
        result = pdfList[i]['file'].split('/').last;
      }

      print("project_list $project_detail");
    } else {
      toast(response['message']);
    }
  }

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 3, vsync: this, initialIndex: 1);
    _pageController = PageController(initialPage: tabController.index);
    tabController.addListener(() {
      _pageController.animateToPage(
        tabController.index,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
    projectDetailApi();
  }

  void _handleTabChange(index) {
    // if (tabController.indexIsChanging) {
    switch (index) {
      case 0:
        {
          searchHint = 'Search Channel';
          isSearch = true;
          setState(() {});
          print('First tab tapped');
        }
        break;
      case 1:
        {
          searchHint = 'Search Member';
          isSearch = true;
          setState(() {});
          print('Second tab tapped');
        }
        break;
      case 2:
        {
          isSearch = false;
          setState(() {});
          print('Third tab tapped');
        }
        break;
    }

    // }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: MyColors.backgroundColor,
        appBar: appBar(
          context: context,
          title: loading == true ? "" : '${project_detail['title']}',
          actions: [
            // InkWell(
            //   onTap: (){
            //
            //   },
            //   child: Padding(
            //     padding: const EdgeInsets.only(top: 25, right: 15),
            //     child: ParagraphText('Create Task', fontSize: 13, underlined: true, color: MyColors.primaryColor,),
            //   ),
            // )
          ],
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
                'Channel',
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              ParagraphText(
                'Members',
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              ParagraphText(
                'Media',
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ],
            onTap: (index) {
              _handleTabChange(index);
              tabController.index = index;
              print('tab changed to $index');
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
            : Column(
                children: [
                  vSizedBox10,
                  if (isSearch == true)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
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
                        child: CustomTextField(
                          controller: search,
                          hintText: searchHint,
                          hintcolor: MyColors.blackColor,
                          borderColor: MyColors.whiteColor,
                          fontsize: 12,
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
                          },
                        ),
                      ),
                    ),
                  vSizedBox20,
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        print("about to page change");
                        _handleTabChange(index);
                        tabController.index = index;
                        setState(() {});
                        print("after page change ${tabController.index}");
                      },
                      children: <Widget>[
                        ///channel
                        ListView.builder(
                            itemCount: projectList.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                child: GestureDetector(
                                  onTap: () {
                                    push(
                                        context: context,
                                        screen: channel_chats(
                                          title: projectList[index]['name'],
                                          members: '25',
                                        ));
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              color: MyColors.blue3),
                                          child: Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Image.asset(
                                              MyImages.project_fill,
                                              height: 25,
                                              width: 25,
                                              fit: BoxFit.cover,
                                              color: MyColors.primaryColor,
                                            ),
                                          )),
                                      hSizedBox10,
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          ParagraphText(
                                            projectList[index]['name'],
                                            color: MyColors.blackColor,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          ParagraphText(
                                            projectList[index]['msg'],
                                            color: MyColors.blackColor,
                                            fontSize: 9,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),

                        ///members
                        filteredMembers.isEmpty ||
                                project_detail['members'].length == 0
                            ? Container(
                                height: 500,
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'No Members Present :(',
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
                                itemCount: filteredMembers.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 10),
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        push(
                                            context: context,
                                            screen: members_profile_screen(
                                              memberId: filteredMembers[index]
                                                      ['id']
                                                  .toString(),
                                            ));
                                      },
                                      child: Row(
                                        children: [
                                          hSizedBox20,
                                          ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              child: CachedNetworkImage(
                                                imageUrl: filteredMembers[index]
                                                        ['image']
                                                    .toString(),
                                                height: 50,
                                                width: 50,
                                                fit: BoxFit.cover,
                                              )),
                                          hSizedBox10,
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ParagraphText(
                                                filteredMembers[index]['name']
                                                    .toString(),
                                                color: MyColors.blackColor,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              ParagraphText(
                                                filteredMembers[index]['email']
                                                    .toString(),
                                                color: MyColors.blackColor,
                                                fontSize: 11,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),

                        ///media
                        project_detail['files'].length == 0
                            ? Center(
                                child: Container(
                                    height: 400,
                                    alignment: Alignment.bottomCenter,
                                    child: ParagraphText(
                                      'No Media available',
                                      fontSize: 12,
                                      color: MyColors.grey1,
                                      fontWeight: FontWeight.w700,
                                    )))
                            : SingleChildScrollView(
                                child: Column(
                                  children: [
                                    if (imageList.length != 0)
                                      Column(
                                        children: [
                                          Container(
                                            color: MyColors.green4
                                                .withOpacity(0.2),
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 25,
                                                      vertical: 10),
                                              child: ParagraphText(
                                                'Images',
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: MyColors.green4,
                                              ),
                                            ),
                                          ),
                                          vSizedBox10,
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Wrap(
                                                direction: Axis.horizontal,
                                                runSpacing: 10,
                                                spacing: 5,
                                                children: [
                                                  for (int index = 0;
                                                      index < imageList.length;
                                                      index++)
                                                    GestureDetector(
                                                      onTap: () {
                                                        push(
                                                            context: context,
                                                            screen:
                                                                gallery_view_image(
                                                              images: imageList,
                                                              imgImdex: index,
                                                            ));
                                                      },
                                                      child: Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          color: MyColors
                                                              .whiteColor,
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: MyColors
                                                                  .grey1
                                                                  .withOpacity(
                                                                      0.8), //color of shadow
                                                              spreadRadius: 0.2,
                                                              blurRadius: 3,
                                                              offset:
                                                                  Offset(0, 0),
                                                            ),
                                                          ],
                                                        ),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          child:
                                                              CachedNetworkImage(
                                                            imageUrl:
                                                                '${imageList[index]['file']}',
                                                            height: 90,
                                                            width: MediaQuery.of(
                                                                        context)
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
                                          )
                                        ],
                                      ),
                                    if (pdfList.length != 0)
                                      Column(
                                        children: [
                                          vSizedBox20,
                                          Container(
                                            color: MyColors.green4
                                                .withOpacity(0.2),
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 25,
                                                      vertical: 10),
                                              child: ParagraphText(
                                                'Pdf',
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                                color: MyColors.green4,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 300,
                                            child: ListView.builder(
                                                itemCount: pdfList.length,
                                                itemBuilder: (context, index) {
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 15,
                                                        vertical: 10),
                                                    child: GestureDetector(
                                                      onTap: () async {
                                                        ///using url launcher direct open in chrome
                                                        // if (await canLaunchUrl(
                                                        //     Uri.parse(pdfList[index]
                                                        //         ['file']))) {
                                                        //   await launch(
                                                        //       Uri.parse(pdfList[index]
                                                        //               ['file'])
                                                        //           .toString(),
                                                        //       forceWebView: false);
                                                        // }
                                                        ///download & open file
                                                        if (pdfList[index][
                                                                'downloading'] ==
                                                            false)
                                                          FileDownloader
                                                              .downloadFile(
                                                            url:
                                                                "${pdfList[index]['file']}",
                                                            onDownloadCompleted:
                                                                (path) async {
                                                              final File file =
                                                                  File(path);
                                                              toast(
                                                                  "File has been downloaded successfully");

                                                              ///open downloaded file
                                                              await OpenFile
                                                                  .open(path);
                                                            },
                                                            onProgress: (String?
                                                                    fileName,
                                                                double
                                                                    progress) {
                                                              print(
                                                                  'FILE fileName HAS PROGRESS $progress $index');
                                                              percentage =
                                                                  progress;
                                                              setState(() {});
                                                              if (progress ==
                                                                  0.0) {
                                                                setState(() {
                                                                  pdfList[index]
                                                                          [
                                                                          'downloading'] =
                                                                      true;
                                                                  toast(
                                                                      "Downloading starts");
                                                                });
                                                              } else if (progress ==
                                                                  100.0) {
                                                                setState(() {
                                                                  pdfList[index]
                                                                          [
                                                                          'downloading'] =
                                                                      false;
                                                                });
                                                              }
                                                            },
                                                          );
                                                      },
                                                      child: Container(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          color: pdfList[index][
                                                                      'downloading'] ==
                                                                  true
                                                              ? MyColors.grey1
                                                              : MyColors
                                                                  .whiteColor,
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: MyColors
                                                                  .grey1
                                                                  .withOpacity(
                                                                      0.8), //color of shadow
                                                              spreadRadius: 0.2,
                                                              blurRadius: 3,
                                                              offset:
                                                                  Offset(0, 0),
                                                            ),
                                                          ],
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .symmetric(
                                                                  vertical: 8,
                                                                  horizontal:
                                                                      15),
                                                          child: Row(
                                                            children: [
                                                              Image.asset(
                                                                MyImages.pdf,
                                                                height: 40,
                                                              ),
                                                              hSizedBox10,
                                                              ParagraphText(
                                                                '${result}',
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                color: MyColors
                                                                    .blackColor,
                                                              ),
                                                              hSizedBox10,
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                          )
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
