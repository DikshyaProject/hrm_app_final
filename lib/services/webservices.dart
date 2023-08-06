import 'dart:convert' as convert;
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:hrm_app/constants/toast.dart';
import 'package:http/http.dart' as http;
import 'api_urls.dart';
late BuildContext dialogContext;


class Webservices {


  static Future<http.Response> getData(String url,{bool showConsole = true}) async {
    http.Response response =
    http.Response('{"message":"failure","status":0}', 404);
    if(showConsole)
      log('the api url is $url');
    try {
      response = await http.get(
        Uri.parse(url),
      );
      if(response.statusCode!=200){
        if(showConsole)
          print('The response status for url $url is ${response.statusCode}');
      }
      log(response.body);
    } catch (e) {
      // showSnackbar(context, text)
      if(showConsole)
        log('Error in $url : ------ $e');
    }
    return response;
  }

  static Future<http.Response> Get_latlng_by_placeId(String placeid) async {
    String url = 'https://maps.googleapis.com/maps/api/place/details/json?placeid=${placeid}&key=AIzaSyABk-0Al27H9Ap_Rtti2t0ePxOLvl5QFzk';
    http.Response response =
    http.Response('{"message":"failure","status":0}', 404);
      log('the api url is $url');
    try {
      response = await http.get(
        Uri.parse(url),
      );
      if(response.statusCode==200){
          print('The response status for url $url is ${response.statusCode}');
      }
      log(response.body);
    } catch (e) {
      // showSnackbar(context, text)
        log('Error in $url : ------ $e');
    }
    // var jsonResponse = jsonDecode(response.body);
    return response;
  }


  static Future<http.Response> Get_addressby_latlng(String latlng) async {
    String url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latlng}&key=AIzaSyABk-0Al27H9Ap_Rtti2t0ePxOLvl5QFzk';
    http.Response response =
    http.Response('{"message":"failure","status":0}', 404);
    log('the api url is $url');
    try {
      response = await http.get(
        Uri.parse(url),
      );
      if(response.statusCode==200){
        print('The response status for url $url is ${response.statusCode}');
      }
      log(response.body);
    } catch (e) {
      // showSnackbar(context, text)
      log('Error in $url : ------ $e');
    }
    // var jsonResponse = jsonDecode(response.body);
    return response;
  }

  static Future<Map<String, dynamic>> postData(
      {required String apiUrl,
        required Map<String, dynamic> request,
        bool showSuccessMessage  = false, bool isGetMethod = false, bool showErrorMessage = true}) async {
    http.Response response =
    http.Response('{"message":"failure","status":0}', 404);
    try {
      log('the requesst for $apiUrl is $request');
      String tempGetRequest = '?';
      request.forEach((key, value) {
        tempGetRequest +=key+'=' + value + '&';

      });
      tempGetRequest = tempGetRequest.substring(0,tempGetRequest.length-1);
      print('the url issss $apiUrl$tempGetRequest');
      late http.Response response;
      if(isGetMethod){
        response = await http.get(Uri.parse(apiUrl + tempGetRequest));
      }else{
        response = await http.post(Uri.parse(apiUrl), body: request);
      }
      if (response.statusCode == 200) {
        print('i am here');
        var jsonResponse = convert.jsonDecode(response.body);
        log('the response for $apiUrl is $jsonResponse');
        if (jsonResponse['status'] == 1) {
          if(showSuccessMessage){
            toast(jsonResponse['message']);
          }
          return jsonResponse;
        } else {
          if(showErrorMessage){
            toast( jsonResponse['message']);
          }
        }
        return jsonResponse;
      }
      else{
        print('the response is ${response.statusCode} : ${response.body}');
        try{
          if(showErrorMessage){
            var jsonResponse = convert.jsonDecode(response.body);
            toast(jsonResponse['message'] );
          }
        }catch(e){
          print('Error in  catch block 39 $e');
        }
      }
    } catch (e) {
      log('Error in $apiUrl : ------ $e');
    }
    return {"status": 0, "message": "api failed"};
  }

  // static Future<http.Response> postMultipartData({required String url, required Map<String, dynamic> request})async{
  //   http.Response response = http.Response('{"message":"failure","status":0}', 404);
  //   try{
  //     log('the request for $url is $request');
  //     response = await http.post(
  //         Uri.parse(url),
  //         body: request
  //     );
  //   }
  //   catch(e){
  //     log('Error in $url : ------ $e');
  //   }
  //   return response;
  // }


  static Future<Map<String, dynamic>>   getMap(String url, {Map<String, dynamic>? request, bool showSuccessMessage = false}) async {

    Map<String, dynamic> tempRequest = {};
    if(request!=null){
      request.forEach((key, value) {
        if(value!=null){
          tempRequest['$key'] = value;
        }
      });
    }
    try{
      log('the request for url $url is $tempRequest');
      late http.Response response;
      if(request==null){
        response = await http.get(Uri.parse(url));
      }else{
        response = await http.post(Uri.parse(url), body: tempRequest);
      }
      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body);
        if (jsonResponse['status'].toString() == '1') {
          log('the respognse for url: $url is ${jsonResponse}');
          if(showSuccessMessage){
            toast(jsonResponse['message']);
          }
          return jsonResponse['data'] ?? jsonResponse['content']??jsonResponse;
        } else {
          return jsonResponse['data'] ?? jsonResponse['content']??jsonResponse;
          log('Error in response for url $url -----${response.body}');
        }
      }else{
        print('error in status code ${response.statusCode}');
        log(response.body);
      }
    }catch(e){
      print('inside catch block 546745 $e');
    }

    return {};
  }

  static Future<List> getList(String url, {bool showConsole = true}) async {
    var response = await getData(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      if (jsonResponse['status'] == 1) {
        if(showConsole)
          log('the response for url: $url is ${jsonResponse}');
        return jsonResponse['data']??[];
      } else {
        if(showConsole)
          log('Error in response for url $url -----${response.body}');
      }
    }
    return [];
  }
  static Future<List> getListFromRequestParameters(String url, Map<String, dynamic> request,{ bool isGetMethod = true} ) async {

    Map<String, dynamic> tempRequest = {};
    request.forEach((key, value) {
      if(value!=null){
        tempRequest['$key'] = value;
      }
    });
    try{
      log('the request for url $url is $tempRequest');
      String tempGetRequest = '?';
      tempRequest.forEach((key, value) {
        tempGetRequest +=key+'=' + value + '&';

      });
      tempGetRequest = tempGetRequest.substring(0,tempGetRequest.length-1);
      print('the url issss $url$tempGetRequest');
      late http.Response response;
      if(isGetMethod){
        response = await http.get(Uri.parse(url + tempGetRequest));
      }else{
        response = await http.post(Uri.parse(url), body: tempRequest);
      }
      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body);
        if (jsonResponse['status'] == 1) {
          log('the respognse for url: $url is ${jsonResponse}');
          return jsonResponse['data'] ?? [];
        } else {
          log('Error in response for url $url -----${response.body}');
        }
      }else{
        print('error in status code ${response.statusCode}');
        log('The response for url ${url} with status code ${response.statusCode} is ${response.body}');
      }
    }catch(e){
      print('inside catch block. Error in getting response for search doctors $e');
    }

    return [];
  }


  static Future<Map<String, dynamic>> postDataWithImageFunction({
    required Map<String, dynamic> body,
    required Map<String, dynamic> files,
    // required BuildContext context,

    /// endpoint of the api
    required String apiUrl,
    bool successAlert = false,
    bool errorAlert = true,
  }) async {
    print('the request is $body');
    var url = Uri.parse(apiUrl);
    //
    log(apiUrl);
    try {
      var request = new http.MultipartRequest("POST", url);
      body.forEach((key, value) {
        request.fields[key] = value;
        // log(value2);
      });

      if (files != null) {
        (files as Map<dynamic, dynamic>).forEach((key, value) async {
          request.files.add(await http.MultipartFile.fromPath(key, value.path));
        });
      }


      log(request.fields.toString());
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      log(response.body);
      var jsonResponse = convert.jsonDecode(response.body);

      if (jsonResponse['status'].toString() == '1') {
        if (successAlert) {
          toast(jsonResponse['message']);
        }
      } else {
        if (errorAlert) {
          toast(jsonResponse['message']);
        }
      }
      return jsonResponse;
      // return response;
    } catch (e) {
      print(e);
      try{
        var response = await http.post(
            url,
            body: body
        );
        if(response.statusCode==200){
          var jsonResponse = convert.jsonDecode(response.body);
          return jsonResponse;
        }
      }catch(error){
        print('inside double catch block $error');
      }
      return {'status': 0, 'message': "fail"};
      // return null;
    }
  }



  // static Future<void> updateDeviceToken({
  //   required String userId,
  //   required String token,
  // }) async {
  //   var request = {
  //     "user_id": userId,
  //     "device_id": token,
  //   };
  //   print('the device token request for url ${ApiUrls.updateDeviceToken} is $request');
  //   try {
  //     var response = await http.post(
  //       Uri.parse(ApiUrls.updateDeviceToken),
  //       body: request,
  //     );
  //     if (response.statusCode == 200) {
  //       print('the device token is updated');
  //     } else {
  //
  //       print('error in device token with status code ${response.statusCode}');
  //       log(response.body);
  //     }
  //   } catch (e) {
  //     print('error in device token:  $e');
  //   }
  // }
  static Future<String> getStringData(String url, {Map<String, dynamic>? request}) async {

    Map<String, dynamic> tempRequest = {};
    if(request!=null){
      request.forEach((key, value) {
        if(value!=null){
          tempRequest['$key'] = value;
        }
      });
    }
    try{
      log('the request for url $url is $tempRequest');
      late http.Response response;
      if(request==null){
        response = await http.get(Uri.parse(url));
      }else{
        response = await http.post(Uri.parse(url), body: tempRequest);
      }
      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body);
        if (jsonResponse['status'].toString() == '1') {
          log('the respognse for url: $url is ${jsonResponse}');
          return jsonResponse['data'] ?? jsonResponse['content']??'NA';
        } else {
          log('Error in response for url $url -----${response.body}');
        }
      }else{
        print('error in status code ${response.statusCode}');
        log(response.body);
      }
    }catch(e){
      print('inside catch block 546745 $e');
    }

    return 'NA';
  }

  // static Future<void> updateDeviceToken({
  //   required String userId,
  //   required String token,
  // }) async {
  //   var request = {
  //     "user_id": userId,
  //     "id": userId,
  //     "device_id": token,
  //   };
  //   print('the device token request for url ${ApiUrls.updateDeviceToken} is $request');
  //   try {
  //     var response = await http.post(
  //       Uri.parse(ApiUrls.updateDeviceToken),
  //       body: request,
  //     );
  //     if (response.statusCode == 200) {
  //       print('the device token is updated');
  //       print(response.body);
  //     } else {
  //
  //       print('error in device token with status code ${response.statusCode}');
  //       log(response.body);
  //     }
  //   } catch (e) {
  //     print('error in device token:  $e');
  //   }
  // }

}

void loadingHide(context){
  Navigator.pop(dialogContext,true);
}

Future<dynamic> loadingShow(context){
  return  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      dialogContext = context;
      double h = MediaQuery.of(context).size.height;
      double w = MediaQuery.of(context).size.width;
      return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: EdgeInsets.all(10),

          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Stack(
              clipBehavior: Clip.none,
              children:[
                Container(
                    width: double.infinity,
                    // height: 200,
                    child:
                    Padding(
                      padding:EdgeInsets.all(16),
                      child: ListView(
                        shrinkWrap: true,
                        children: <Widget>[
                          Row(
                            children: [
                              Container(
                                clipBehavior: Clip.none,



                                width:(MediaQuery.of(context).size.width - 70),
                                // padding:EdgeInsets.fromLTRB(0, 0, 20, 0),
                                child:SpinKitRing(
                                  color: Colors.lightBlueAccent,
                                  size: 50.0,
                                )

                                ,
                              )
                            ],
                          ),
                        ],
                      ),
                    )
                ),
              ]
          )

      );
    },
  ).then((exit) {
    if (exit == null) return;

  });


}