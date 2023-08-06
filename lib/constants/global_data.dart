import 'package:shared_preferences/shared_preferences.dart';
import '../model/user_model.dart';

enum Options { Edit, Delete }

user_model userData = {} as user_model;

 late  SharedPreferences prefs ;

final One_Signal_appid = "a826922a-b548-4bbc-b27b-882ebf8918c6";
