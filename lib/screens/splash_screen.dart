import 'package:flutter/material.dart';
import 'package:hrm_app/constants/global_keys.dart';
import 'package:hrm_app/model/user_model.dart';
import 'package:hrm_app/screens/login_via_phone.dart';
import 'package:hrm_app/services/api_urls.dart';
import 'package:hrm_app/services/onesignal.dart';
import 'package:hrm_app/services/webservices.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';
import '../constants/global_data.dart';
import '../constants/images_url.dart';
import '../functions/navigation_functions.dart';
import '../services/auth.dart';
import '../widgets/CustomTexts.dart';
import '../widgets/bottom_bar.dart';
import 'dart:convert' as convert;
class splash_screen extends StatefulWidget {
  const splash_screen({Key? key}) : super(key: key);

  @override
  State<splash_screen> createState() => _splash_screenState();
}

class _splash_screenState extends State<splash_screen> {
  var user_id;


  go_to_sign_in_page() async{
    initOneSignal(One_Signal_appid);

    Future.delayed(Duration(seconds: 1),(){
      CheckSession();
      updateDeviceId();
    });
  }

  CheckSession() async {
    prefs = await SharedPreferences.getInstance();
    user_id = prefs.getString('user_id');

    if (await isUserLoggedIn() && user_id != null) {
      var res = await Webservices.getMap(ApiUrls.get_user_data + "?user_id=${user_id}");
      print('splash session data $res');

      if (res != null) {
        updateUserDetails(res);
        pushAndRemoveUntil(context: context, screen: bottom_bar(key: MyGlobalKeys.bottomTabKey));
      }
    } else {
      pushAndRemoveUntil(context: context, screen: login_via_phone());
    }
  }

  updateDeviceId() async{
    print("theCodeIsRunning$user_id");
    if(await isUserLoggedIn() && user_id != null) {
      /// update device id
      String? device_id = await get_device_id();
      print("Device_id_is======$device_id");

      ///device id
      Map<String, dynamic> request = {
        'user_id': user_id,
        'device_id': device_id,
      };

      final deviceId_response = await Webservices.postData(apiUrl: ApiUrls.edit_profile, request: request, showSuccessMessage: false,);

      print("deviceId_response=======================$deviceId_response");
      CheckSession();

    }else{
      CheckSession();
    }
  }

  @override
  void initState() {
    go_to_sign_in_page();


    super.initState();
  }


  @override
  Widget build(BuildContext context) {

      return Scaffold(
        backgroundColor: MyColors.backgroundColor,
        body:Center(
              child: Image.asset(MyImages.splash_logo, width: 220,)
          ),

      );
  }

}
