import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hrm_app/constants/colors.dart';
import 'package:hrm_app/constants/images_url.dart';
import 'package:hrm_app/constants/toast.dart';
import 'package:hrm_app/model/user_model.dart';
import 'package:hrm_app/widgets/appbar.dart';

import '../constants/global_data.dart';
import '../services/api_urls.dart';
import '../services/webservices.dart';
import '../widgets/CustomTexts.dart';


class privacy_policy extends StatefulWidget {
  const privacy_policy({Key? key}) : super(key: key);

  @override
  State<privacy_policy> createState() => _privacy_policyState();
}

class _privacy_policyState extends State<privacy_policy> {

  bool loading =false;
  String privacy_data = '';

  ///validation and api Integration
  getPrivacyPolicyApi() async{
    setState(() {loading =true;});

    Map<String,dynamic> request={
      'company_id': userData.company_id.toString()
    };

    final response = await Webservices.postData(apiUrl: ApiUrls.get_company_policy, request: request, isGetMethod: true);

    setState(() {loading =false;});

    if(response['status'].toString() == "1"){
      privacy_data = response['data']['description'];
      print(response['data']);
    }else{
      toast(response['message']);
    }
  }

  @override
  void initState() {
    super.initState();
    getPrivacyPolicyApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: appBar(context: context, title: 'Privacy Policy'),

      body:
      loading == true ? Center(child:  CupertinoActivityIndicator(radius: 15, color: MyColors.grey11,),):
      SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child:  Html(data: privacy_data,)
        ),
      ),
    );
  }
}
