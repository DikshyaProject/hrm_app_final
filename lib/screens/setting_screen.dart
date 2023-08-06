import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hrm_app/constants/colors.dart';
import 'package:hrm_app/constants/toast.dart';
import 'package:hrm_app/functions/navigation_functions.dart';
import 'package:hrm_app/screens/login_via_phone.dart';
import 'package:hrm_app/screens/privacy_policy.dart';
import 'package:hrm_app/screens/profile_screen.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/global_data.dart';
import '../constants/images_url.dart';
import '../constants/sized_box.dart';
import '../services/api_urls.dart';
import '../services/auth.dart';
import '../services/webservices.dart';
import '../widgets/CustomTexts.dart';
import '../widgets/appbar.dart';
import '../widgets/round_edged_button.dart';
import 'expense_screen.dart';
import 'holiday_list.dart';
import 'leave_request.dart';
import 'package:hrm_app/model/user_model.dart';


class setting_screen extends StatefulWidget {
  const setting_screen({Key? key}) : super(key: key);

  @override
  State<setting_screen> createState() => _setting_screenState();
}

class _setting_screenState extends State<setting_screen> {
  File? imgFile;
  final imgPicker = ImagePicker();
  bool load= false;
  bool loading= false;
  List settingList =[
    {'image': MyImages.person, 'title' : 'Edit Profile'},
    {'image': MyImages.holiday, 'title' : 'Holiday List'},
    {'image': MyImages.leaves, 'title' : 'Leaves'},
    {'image': MyImages.wallet, 'title' : 'Expenses'},
    {'image': MyImages.privacy, 'title' : 'Privacy Policy'},
    {'image': MyImages.logout, 'title' : 'Logout'},
  ];
  String stored_image_path = userData.image.toString();

  ///image upload code
  Future<void> _image_camera_dialog(BuildContext context) async{
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Center(child: ParagraphText('Select an Image',)),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () async{
              var imgGallery = await imgPicker.pickImage(source: ImageSource.gallery);
              setState(() {
                imgFile = File(imgGallery!.path);
              });
              editProfileApi();
              Navigator.pop(context);
            },
            child: ParagraphText('Select a photo from Gallery',),),
          CupertinoActionSheetAction(
            onPressed: () async{
              var imgCamera = await imgPicker.pickImage(source: ImageSource.camera);
              setState(() {
                imgFile = File(imgCamera!.path);
              });
              editProfileApi();
              Navigator.pop(context);
            },
            child: ParagraphText('Take a photo with the camera',),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: ParagraphText('Cancel',),
        ),
      ),
    );
  }


  editProfileApi() async{
    if (imgFile == null){
      toast('Please select an image');
    } else{
      setState(() {loading =true;});

      Map<String,dynamic> request={
        'user_id': userData.id.toString(),
      };
      Map<String, dynamic> image = {
        'image': imgFile,
      };

      final response = await Webservices.postDataWithImageFunction(body: request, files: image, apiUrl: ApiUrls.edit_profile);

      setState(() {loading =false;});

      if(response['status'].toString() == '1'){
        stored_image_path = response['data']['image'];
        updateUserDetails(response['data']);

        setState(() {});
        toast('Image uploaded successfully');
      }else{
        toast(response['message']);
      }
    }
  }

  @override
  void initState() {
   print('stored_image_path$stored_image_path');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: appBar(context: context, title: 'Setting'),
      body:

      SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            vSizedBox10,

            ///image & name
            Center(
                child: Column(
                  children: [
                    loading == true ? Container(
                        height: 150, width: 150,
                        child: Center(child:  CupertinoActivityIndicator(radius: 15, color: MyColors.grey11,),)): Stack(
                      children: [
                        imgFile == null && stored_image_path == null ?
                        Container(
                            height: 150, width: 150,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(color: MyColors.purple, width: 1)
                            ),
                            child: Icon(Icons.camera_alt, color: MyColors.purple, size: 35,)):

                        imgFile != null || stored_image_path == null || stored_image_path == ''?
                        Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(color: MyColors.purple, width: 1)
                            ),
                            child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Image.file(imgFile!, height: 150, width: 150, fit: BoxFit.cover,))):

                            Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(color: MyColors.purple, width: 1)
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: CachedNetworkImage( imageUrl:stored_image_path , height: 150, width: 150, fit: BoxFit.cover,)
                              ),
                            ),

                        Positioned(
                            right: 0,
                            bottom: 0,
                            child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: ()  {
                                  _image_camera_dialog(context);

                                },
                                child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      color: MyColors.purple,
                                      border: Border.all(color: MyColors.whiteColor, width: 2)
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Icon(Icons.edit, color: MyColors.whiteColor, size: 25,),
                                    )))),
                      ],
                    ),
                    vSizedBox10,
                    ParagraphText(userData.Name!, fontSize: 18, fontWeight: FontWeight.w600,)
                  ],
                )),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ParagraphText('My Salary', fontSize: 18, fontWeight: FontWeight.w600,),
                ),

                vSizedBox10,

                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: MyColors.boxBorderColor, width: 1),
                    color: MyColors.boxBackgroundColor,
                  ),

                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RichText(text: TextSpan(
                                children: [
                                  TextSpan(text: 'CTC: ', style: TextStyle(fontSize: 15,  color: MyColors.blackColor)),
                                  TextSpan(text: '\$${userData.ctc}', style: TextStyle(fontSize: 14,  color: MyColors.blackColor, fontWeight: FontWeight.w600,)),
                                ]
                            )),

                            RichText(text: TextSpan(
                                children: [
                                  TextSpan(text: 'Salary: ', style: TextStyle(fontSize: 15,  color: MyColors.blackColor)),
                                  TextSpan(text: '\$${userData.salary}', style: TextStyle(fontSize: 14,  color: MyColors.blackColor, fontWeight: FontWeight.w600,)),
                                ]
                            )),
                          ],
                        ),
                        vSizedBox05,
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ParagraphText('${userData.salary_per_day}/day', fontSize: 8, ),
                            ParagraphText('For ${userData.present_days} days', fontSize: 8, ),
                          ],
                        ),
                        vSizedBox10,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RichText(text: TextSpan(
                                children: [
                                  TextSpan(text: 'Number of working day: ', style: TextStyle(fontSize: 10,  color: MyColors.blackColor)),
                                  TextSpan(text: '${userData.working_days}', style: TextStyle(fontSize: 10,  color: MyColors.blackColor, fontWeight: FontWeight.w600,)),
                                ]
                            )),

                            RichText(text: TextSpan(
                                children: [
                                  TextSpan(text: 'Present day: ', style: TextStyle(fontSize: 10,  color: MyColors.blackColor)),
                                  TextSpan(text: '${userData.present_days}', style: TextStyle(fontSize: 10,  color: MyColors.blackColor, fontWeight: FontWeight.w600,)),
                                ]
                            )),
                          ],
                        ),


                      ],
                    ),
                  ),
                ),
                vSizedBox20,


                for(int i=0; i<settingList.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: (){
                          if(i==0){
                            ///edit profile
                            push(context: context, screen: profile_screen());
                          } else if(i==1){
                            ///holiday
                            push(context: context, screen: holiday_list());
                          } else if(i==2){
                            ///leaves
                            push(context: context, screen: leave_requset(leave_id: ""));
                          }else if(i==3){
                            ///expense
                            push(context: context, screen: expense_screen());
                          }else if(i==4){
                            ///privacy
                            push(context: context, screen: privacy_policy());
                          }else if(i==5){
                            ///logout
                            showDialog<String>(
                              context: context,
                              builder: (BuildContext context) => BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: 1,
                                  sigmaY: 1,
                                ),
                                child: StatefulBuilder(
                                  builder: (context, setState) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                      ),
                                      child: AlertDialog(
                                        alignment: Alignment.center,
                                        actionsAlignment: MainAxisAlignment.center,
                                        insetPadding: EdgeInsets.zero,
                                        elevation: 0.0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(26)),
                                        content: SizedBox(
                                          width: double.maxFinite,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [

                                             vSizedBox20,
                                              Text(
                                                'Are you Sure!',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontFamily: "Regular",
                                                  color: MyColors.grey11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              vSizedBox40,
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  RoundEdgedButton(
                                                    text: "Logout",
                                                    width: MediaQuery.of(context).size.width/3,
                                                    color: MyColors.primaryColor,
                                                    isLoad: load,
                                                    onTap: () async{
                                                      setState(() {load=true;});
                                                      prefs.clear();
                                                      pushAndRemoveUntil(context: context, screen: login_via_phone());
                                                    },),
                                                  RoundEdgedButton(
                                                    text: "Cancel",
                                                    width: MediaQuery.of(context).size.width/3,
                                                    color: MyColors.grey11,
                                                    onTap: (){Navigator.pop(context);},)
                                                ],
                                              )
                                            ],
                                          ),
                                        ),

                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          }
                        },
                        child: Row(
                          children: [
                            Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(100),
                                    color: MyColors.primaryColor.withOpacity(0.1)
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Image.asset(settingList[i]['image'], color: MyColors.primaryColor, height: 15,  fit: BoxFit.cover,),
                                )),

                            hSizedBox10,
                            ParagraphText(settingList[i]['title'], fontSize: 14, ),

                            Spacer(),

                            Icon(CupertinoIcons.chevron_right, color: MyColors.hintColor,)
                          ],
                        ),
                      ),
                      Divider()
                    ],
                  ),
                )

              ],
            ),
          ],
        ),
      ),
    );
  }
}
