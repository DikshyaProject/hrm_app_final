import 'package:country_list_pick/country_list_pick.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hrm_app/constants/global_keys.dart';
import 'package:hrm_app/constants/images_url.dart';
import 'package:hrm_app/screens/login_via_phone.dart';
import 'package:hrm_app/screens/otp_screen.dart';
import 'package:hrm_app/services/onesignal.dart';
import '../constants/colors.dart';
import '../constants/global_data.dart';
import '../constants/sized_box.dart';
import '../constants/toast.dart';
import '../functions/navigation_functions.dart';
import '../services/api_urls.dart';
import '../services/auth.dart';
import '../services/webservices.dart';
import '../widgets/CustomTexts.dart';
import '../widgets/bottom_bar.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/round_edged_button.dart';
import 'forget_password.dart';
import 'package:hrm_app/model/user_model.dart';


class login_via_email extends StatefulWidget {
  const login_via_email({Key? key}) : super(key: key);

  @override
  State<login_via_email> createState() => _login_via_emailState();
}

class _login_via_emailState extends State<login_via_email> {
  TextEditingController email = TextEditingController();
  TextEditingController pass = TextEditingController();
  bool loading =false;
  String? userId;


  ///validation and api Integration
  loginWithEmail() async{
    if (email.text.length == 0){
      toast('Please enter email');
    } else  if(email.text.length > 0 && !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email.text)){
      toast('Please enter valid email');
    }else if (pass.text.length == 0){
      toast('Please enter password');
    } else{
      setState(() {loading =true;});

      Map<String,dynamic> login_request={
        'email': email.text,
        'password': pass.text,
      };

      final response = await Webservices.postData(apiUrl: ApiUrls.login_with_email, request: login_request);

      setState(() {loading =false;});

      if(response['status'].toString() == '1'){
        updateUserDetails(response['data']);
        // userData = user_model.fromJson(response['data']);

        prefs.setString('user_id', response['data']['id'].toString());
        userId = prefs.getString('user_id');
        await updateDeviceId();
        push(context: context, screen: bottom_bar(key: MyGlobalKeys.bottomTabKey,));
      }
    }
  }
  updateDeviceId() async{
    if(await isUserLoggedIn()) {
      /// update device id
      String? device_id = await get_device_id();
      print("Device_id_is======$device_id");

      ///device id
      Map<String, dynamic> request = {
        'user_id': userId,
        'device_id': device_id,
      };

      final deviceId_response = await Webservices.postData(apiUrl: ApiUrls.edit_profile, request: request, showSuccessMessage: false,);

      print("deviceId_response=======================$deviceId_response");

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              vSizedBox80,
              vSizedBox20,
              Center(child: Image.asset(MyImages.splash_logo, height: 200,)),

              ParagraphText('Login', fontSize: 20, fontWeight: FontWeight.w600, color: MyColors.blackColor,),
              vSizedBox05,
              ParagraphText('Please sign-in to continue.', fontSize: 15, color: MyColors.grey2,),
              vSizedBox20,

              CustomTextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  hintText: 'Email ID'),
              vSizedBox10,
              CustomTextField(
                  controller: pass,
                  hintText: 'Password'),

              vSizedBox10,
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                  onTap: (){
                    push(context: context, screen: forget_password());
                  },
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: ParagraphText('Forgot Password?', fontSize: 15, fontWeight: FontWeight.w600, color: MyColors.blue,))),

              RoundEdgedButton(
                text: 'Login',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                isLoad: loading,
                onTap: (){
                  loginWithEmail();
                },
              )
            ],
          ),
        ),
      ),

      bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height*0.23,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(height: 1, width: 130, color: MyColors.grey1,),
                  ParagraphText('Or', fontWeight: FontWeight.w600,),
                  Container(height: 1, width: 130, color: MyColors.grey1,),
                ],),

              RoundEdgedButton(
                text: 'LOGIN IN VIA PHONE',
                fontSize: 16,
                icon: MyImages.phone,
                fontWeight: FontWeight.w600,
                iconSize: 27,
                color: MyColors.grey11,
                leftTextPadding: 60,
                rightTextPadding: 60,
                border_color: MyColors.grey12,
                onTap: (){
                  push(context: context, screen: login_via_phone());
                },
              ),
              RoundEdgedButton(
                text: 'LOGIN IN WITH GOOGLE',
                fontSize: 16,
                icon: MyImages.google,
                fontWeight: FontWeight.w600,
                iconSize: 20,
                color: MyColors.red1,
                leftTextPadding: 45,
                rightTextPadding: 45,
                border_color: MyColors.red2,
                onTap: (){
                  // push(context: context, screen: bottom_bar());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
