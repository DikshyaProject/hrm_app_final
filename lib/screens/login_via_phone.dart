import 'package:country_list_pick/country_list_pick.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hrm_app/constants/images_url.dart';
import 'package:hrm_app/constants/toast.dart';
import 'package:hrm_app/screens/otp_screen.dart';
import 'package:hrm_app/services/onesignal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/colors.dart';
import '../constants/global_data.dart';
import '../constants/sized_box.dart';
import '../functions/navigation_functions.dart';
import '../services/api_urls.dart';
import '../services/auth.dart';
import '../services/webservices.dart';
import '../widgets/CustomTexts.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/round_edged_button.dart';
import 'login_via_email.dart';

class login_via_phone extends StatefulWidget {
  const login_via_phone({Key? key}) : super(key: key);

  @override
  State<login_via_phone> createState() => _login_via_phoneState();
}

class _login_via_phoneState extends State<login_via_phone> {
TextEditingController phoneNumber = TextEditingController();
String? countryCode;
String? initial;
bool loading = false;
String? userId;
var user_id;

///validation and api Integration
 getOtpApi() async{
   SharedPreferences prefs = await SharedPreferences.getInstance();

   if(countryCode == '' || countryCode == null ){
     toast('Please select country code');
   }else if(phoneNumber.text == '' || phoneNumber.text == null){
     toast('Please enter phone number');
   }else{
     setState(() {loading =true;});

     Map<String,dynamic> get_otp_request={
       'country_code': countryCode,
       'phone': phoneNumber.text,
     };

     final response = await Webservices.postData(apiUrl: ApiUrls.login_with_phone, request: get_otp_request);

     setState(() {loading =false;});

     if(response['status'].toString() == '1'){
       prefs.setString('user_id', response['user_id'].toString());
       userId = prefs.getString('user_id');
       await updateDeviceId();

       push(context: context, screen: otp_screen(userId: userId!, countryCode: countryCode!, phoneNumber: phoneNumber.text,));
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
      'user_id': user_id,
      'device_id': device_id,
    };

    final deviceId_response = await Webservices.postData(apiUrl: ApiUrls.edit_profile, request: request, showSuccessMessage: false,);

    print("deviceId_response=======================$deviceId_response");

  }
}


 @override
  void initState() {
    // TODO: implement initState
   final List<Locale> systemLocales = WidgetsBinding.instance.window.locales;
   initial = systemLocales!.first!.countryCode!;
   countryCode = '93';
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              vSizedBox80,
              vSizedBox20,
              Center(child: Image.asset(MyImages.splash_logo, height: 200,)),

              ParagraphText('Login/Signup via Phone Number', fontSize: 20, fontWeight: FontWeight.w600, color: MyColors.blackColor,),
              vSizedBox05,
              ParagraphText('Please enter your phone number', fontSize: 15, color: MyColors.grey2,),
              vSizedBox20,

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: MyColors.grey1.withOpacity(0.5))
                    ),
                    child: CountryListPick(
                        theme: CountryTheme(
                          isShowFlag: true,
                          isShowTitle: false,
                          isShowCode: true,
                          // initialSelection: "IN",
                          isDownIcon: true,
                          showEnglishName: true,
                        ),
                        onChanged: (CountryCode){
                          print(CountryCode?.name);
                          print(CountryCode?.code);
                          print(CountryCode?.dialCode);
                          print(CountryCode?.flagUri);

                          countryCode = CountryCode?.dialCode;
                          setState(() {});
                          print('selected countryCode is $countryCode ');

                        },
                        initialSelection: '',
                        useUiOverlay: true,
                        useSafeArea: false
                    ),
                  ),

                  CustomTextField(
                    width: MediaQuery.of(context).size.width/1.8,
                      controller: phoneNumber,
                      keyboardType: TextInputType.number,
                      // borderColor: Colors.transparent,
                      hintText: 'Phone number')
                ],
              ),

              vSizedBox10,

              RoundEdgedButton(
                  text: 'Submit',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                  isLoad: loading,
                  onTap: (){
                    ///calling api
                    getOtpApi();
                },
              )
            ],
          ),
        ),
      ),

      bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height*0.25,
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
                text: 'LOGIN IN VIA EMAIL',
                fontSize: 16,
                icon: MyImages.email,
                fontWeight: FontWeight.w600,
                iconSize: 25,
                color: MyColors.grey11,
                leftTextPadding: 60,
                rightTextPadding: 60,
                border_color: MyColors.grey12,
                onTap: (){
                  push(context: context, screen: login_via_email());
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
