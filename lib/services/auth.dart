import 'dart:convert';
import 'dart:developer';
import 'dart:async';
import 'package:hrm_app/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/global_data.dart';



void updateUserDetails(details) async{
  userData = user_model.fromJson(details);
  SharedPreferences shared_User = await SharedPreferences.getInstance();
  String user = jsonEncode(details);

  shared_User.setString('user_details', user);
}


Future isUserLoggedIn() async{
  final  sharedUser = await SharedPreferences.getInstance();

  String? user = await sharedUser.getString('user_details');
  log(user.toString());

  if(user==null){
    print('user not logged in');
    return false;
  }
  else{
    print('user logged in');
    return true;
  }

}

//
// Future logout(bool is_timer,{isDevice=true}) async{
//   print("logout()");
//   if(isDevice){
//     Map<String, dynamic> request = {
//       'user_id': await getCurrentUserId(),
//       'device_id': ''
//     };
//     await Webservices.postData(apiUrl: ApiUrls.device_id,request:request);
//   }
//   SharedPreferences shared_User = await SharedPreferences.getInstance();
//   SharedPreferences cart = await SharedPreferences.getInstance();
//   await cart.clear();
//   await shared_User.clear();
//
//   if(is_timer && globel_timer!=null){
//     globel_timer!.cancel();
//   }
//   return true;
// }


// Future getCurrentUserId() async{
//   SharedPreferences shared_User = await SharedPreferences.getInstance();
//   String? userMap = await shared_User.getString('user_details');
//   String userS = (userMap==null)?'':userMap;
//   Map<String , dynamic> user = jsonDecode(userS) as  Map<String, dynamic>;
//   return user['id'].toString();
// }



