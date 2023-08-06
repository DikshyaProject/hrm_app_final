import 'package:flutter/material.dart';
import 'package:hrm_app/constants/toast.dart';
import 'package:hrm_app/screens/login_via_phone.dart';
import 'package:hrm_app/services/api_urls.dart';
import 'package:hrm_app/services/auth.dart';
import 'package:hrm_app/services/webservices.dart';

import '../constants/colors.dart';
import '../constants/global_data.dart';
import '../constants/images_url.dart';
import '../constants/sized_box.dart';
import '../functions/navigation_functions.dart';
import '../widgets/CustomTexts.dart';
import '../widgets/appbar.dart';
import '../widgets/bottom_bar.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/round_edged_button.dart';
import 'package:hrm_app/model/user_model.dart';


class forget_password extends StatefulWidget {
  const forget_password({Key? key}) : super(key: key);

  @override
  State<forget_password> createState() => _forget_passwordState();
}

class _forget_passwordState extends State<forget_password> {
  TextEditingController email = TextEditingController();
  bool loading =false;

  ///validation and api Integration
  forgetPasswordApi() async{
    if (email.text.length == 0){
      toast('Please enter email');
    } else  if(email.text.length > 0 && !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(email.text)){
      toast('Please enter valid email');
    } else{
      setState(() {loading =true;});

      Map<String,dynamic> request={
        'email': email.text,
      };

      final response = await Webservices.postData(apiUrl: ApiUrls.forget_password, request: request, isGetMethod: true);

      setState(() {loading =false;});

      if(response['status'].toString() == '1'){
        // toast(response['message']);
        push(context: context, screen: login_via_phone());
      }else{
        // toast(response['message']);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: appBar(context: context),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Center(child: Image.asset(MyImages.splash_logo, height: 200,)),

              ParagraphText('Forgot Password', fontSize: 20, fontWeight: FontWeight.w600, color: MyColors.blackColor,),
              vSizedBox05,
              ParagraphText('Please enter your registered email address', fontSize: 15, color: MyColors.grey2,),
              vSizedBox20,

              CustomTextField(
                  controller: email,
                  keyboardType: TextInputType.emailAddress,
                  hintText: 'Email ID'),



              vSizedBox10,

              RoundEdgedButton(
                text: 'Submit',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                isLoad: loading,
                onTap: (){
                  forgetPasswordApi();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
