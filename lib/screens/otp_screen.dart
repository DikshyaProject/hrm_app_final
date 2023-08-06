import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hrm_app/constants/images_url.dart';
import 'package:hrm_app/services/api_urls.dart';
import 'package:hrm_app/services/webservices.dart';
import 'package:hrm_app/widgets/bottom_bar.dart';
import '../constants/colors.dart';
import '../constants/global_data.dart';
import '../constants/global_keys.dart';
import '../constants/sized_box.dart';
import '../constants/toast.dart';
import '../functions/navigation_functions.dart';
import '../services/auth.dart';
import '../widgets/CustomTexts.dart';
import '../widgets/appbar.dart';
import '../widgets/otp_widget.dart';
import '../widgets/round_edged_button.dart';
import 'package:hrm_app/model/user_model.dart';


class otp_screen extends StatefulWidget {
  String userId;
  String countryCode;
  String phoneNumber;

   otp_screen({Key? key, required this.userId, required this.countryCode, required this.phoneNumber, }) : super(key: key);

  @override
  State<otp_screen> createState() => _otp_screenState();
}

class _otp_screenState extends State<otp_screen> {
  String correctOtp = "1234";
  bool loading = false;
  TextEditingController otpController = TextEditingController();


  showLoading() async{
    // toast('Otp matched');
  }

  ///validation and api Integration
  verifyOtpApi() async{
    if(otpController.text == '' || otpController.text == null){
      toast('Please enter otp');
    }else{
      setState(() {loading =true;});

      Map<String,dynamic> verify_otp_request={
        'user_id': widget.userId,
        'otp': otpController.text,
      };

      final response = await Webservices.postData(apiUrl: ApiUrls.verify_otp, request: verify_otp_request);

      setState(() {loading =false;});

      if(response['status'].toString() == '1'){
        updateUserDetails(response['data']);
        userData = user_model.fromJson(response['data']);

        toast('Otp verified');
        push(context: context, screen: bottom_bar(key: MyGlobalKeys.bottomTabKey));
      }else{
        toast(response['message']);
      }
    }
  }

  resendOtpApi() async{
    Map<String,dynamic> get_otp_request={
      'country_code': widget.countryCode,
      'phone': widget.phoneNumber,
    };

    final response = await Webservices.postData(apiUrl: ApiUrls.login_with_phone, request: get_otp_request);

    if(response['status'].toString() == '1'){
      toast('Otp sent successfully');
    }else{
      toast(response['message']);
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

              ParagraphText('Enter OTP', fontSize: 20, fontWeight: FontWeight.w600, color: MyColors.blackColor,),
              vSizedBox05,
              ParagraphText('We sent OTP on +1 xxx xxx x144',  fontSize: 15, color: MyColors.grey2,),

              vSizedBox20,

              ///otp field
              OtpVerification(
                  bgColor: MyColors.whiteColor,
                  borderColor: Colors.transparent,
                  textColor: MyColors.blackColor,
                  correctOtp: correctOtp,
                  textEditingController: otpController,
                  load: showLoading,
                  wrongOtp: (){
                    otpController.text = '';
                    setState(() {});
                  },
                  navigationFrom: 'otp_screen',
                  ),

              InkWell(
                onTap: (){
                  ///calling api
                  resendOtpApi();
                },
                child: Align(
                    alignment: Alignment.centerRight,
                    child: ParagraphText('Resend OTP?',  color: MyColors.blue,)),
              ),

              vSizedBox05,

              RoundEdgedButton(
                text: 'Submit',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                isLoad: loading,
                onTap: (){
                  ///calling api
                  verifyOtpApi();
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
