import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hrm_app/constants/toast.dart';
import 'package:hrm_app/functions/navigation_functions.dart';
import 'package:hrm_app/screens/holiday_list.dart';
import 'package:hrm_app/services/webservices.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../constants/colors.dart';
import '../constants/global_data.dart';
import '../constants/images_url.dart';
import '../constants/sized_box.dart';
import '../services/api_urls.dart';
import '../widgets/CustomTexts.dart';
import '../widgets/appbar.dart';
import '../widgets/round_edged_button.dart';
import 'expense_screen.dart';
import 'leave_request.dart';


class attendance_screen extends StatefulWidget {
  const attendance_screen({Key? key}) : super(key: key);

  @override
  State<attendance_screen> createState() => _attendance_screenState();
}

class _attendance_screenState extends State<attendance_screen> with SingleTickerProviderStateMixin{
  late TabController tabController;
  bool isPunchInLoading = false;
  List punch_in_data=[];
  var punchInStatus;
  Position? _currentPosition;
  String? _currentAddress;
  String? fullAddress;
  var formattedDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final List<DateTime> toHighlight = [];
  bool loading =false;
  bool countLoading =false;
  List all_leave_data=[];
  List holiday_list_data=[];
  List attendance_list_data=[];
  Map? leave_count_data;
  String isMonth = "1";

  chekingPunchInEligibleApi() async{

    Map<String,dynamic> request={
      'company_id': userData.company_id.toString(),
      'employee_id': userData.id.toString(),
    };

    final response = await Webservices.postData(apiUrl: ApiUrls.get_punchin_out_eligible, request: request, isGetMethod: true,showErrorMessage: false);

    setState(() {countLoading =false;});
    setState(() {isPunchInLoading = false;});


    if(response['status'].toString() != '0'){
      punch_in_data = response['data'];
      punchInStatus = response['status'].toString();
      print("punch_in_data $punch_in_data");
      print("punchInStatus $punchInStatus");

      setState(() {});
    }
  }

  getAttendanceListApi(selectedDate) async{
    // setState(() {loading =true;});
    selectedDate = DateFormat('yyyy-MM-dd').format(selectedDay);

    Map<String,dynamic> login_request={
      'company_id': userData.company_id.toString(),
      'employee_id': userData.id.toString(),
      'date': selectedDate,
      'is_month' : isMonth
    };

    final response = await Webservices.postData(apiUrl: ApiUrls.get_my_attendance, request: login_request, isGetMethod: true);

    setState(() {loading =false;});

    attendance_list_data.clear();
    setState(() {});

    if(response['status'].toString() == '1'){
      attendance_list_data = response['data'];
      print("attendance_list_data $attendance_list_data");

    }else{
      toast(response['message']);
    }

  }

  punchInOutApi() async{
    setState(() {isPunchInLoading = true;});

    Map<String,dynamic> request={
      'company_id': userData.company_id.toString(),
      'employee_id': userData.id.toString(),
      'lat' : _currentPosition?.latitude.toString(),
      'lng' : _currentPosition?.longitude.toString(),
      'address' : fullAddress,
    };

    final res= await Webservices.postData(apiUrl: ApiUrls.punch, request: request,);

    if(res['status'].toString() == "1"){
      chekingPunchInEligibleApi();
    }
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      _getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });
    print('LAT: ${_currentPosition?.latitude ?? ""}');
    print('LNG: ${_currentPosition?.longitude ?? ""}');
    print('myADDRESS: ${_currentAddress ?? ""}');
  }
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }
  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
        _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
        '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
      });
      fullAddress = '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
      print("fullAddress $fullAddress");

    }).catchError((e) {
      debugPrint(e);
    });
  }

  getLeaveListApi() async{
    setState(() {loading =true;});

    Map<String,dynamic> request={
      'company_id': userData.company_id.toString(),
      'employee_id': userData.id.toString(),
      'date' : formattedDate
    };

    final response = await Webservices.postData(apiUrl: ApiUrls.get_all_my_leaves, request: request, isGetMethod: true);

    setState(() {loading =false;});

    if(response['status'].toString() == '1'){
      all_leave_data = response['data'];
      print("all_leave_data $all_leave_data");

      setState(() {});
    }
  }

  getHolidayListApi() async{
    setState(() {loading =true;});

    Map<String,dynamic> login_request={
      'company_id': userData.company_id.toString(),
      'date': formattedDate,
    };

    final response = await Webservices.postData(apiUrl: ApiUrls.get_holidays_list, request: login_request, isGetMethod: true);

    setState(() {loading =false;});

    if(response['status'].toString() == '1'){
      holiday_list_data = response['data'];
      print("holiday_list_data $holiday_list_data");

      toHighlight.clear();

      for (int i = 0; i < holiday_list_data.length; i++)
        toHighlight.add(DateTime.parse((holiday_list_data[i]['holiday_date'])));

      print("events_date $toHighlight");

      setState(() {});
    }else{
      toast(response['message']);
    }
  }

  getLeaveCountApi() async{
    setState(() {countLoading =true;});

    Map<String,dynamic> login_request={
      'company_id': userData.company_id.toString(),
      'employee_id': userData.id.toString(),
      'date' : formattedDate
    };

    final response = await Webservices.postData(apiUrl: ApiUrls.get_leaves_count, request: login_request, isGetMethod: true);

    setState(() {countLoading =false;});

    if(response['status'].toString() == '1'){
      leave_count_data = response['data'];
      print("leave_count_data $leave_count_data");

    }else{
      toast(response['message']);
    }
    getAttendanceListApi(DateFormat('yyyy-MM-dd').format(selectedDay));

  }

  callFunction() async{
    setState(() {
      loading =true;
    });
    await _getCurrentPosition();

    chekingPunchInEligibleApi();
    getLeaveCountApi();
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 3, vsync: this, );
    tabController.addListener(_handleTabChange);

    callFunction();
  }

  void _handleTabChange() {
    if (tabController.indexIsChanging) {
      switch (tabController.index) {
        case 0:
          getAttendanceListApi(DateFormat('yyyy-MM-dd').format(selectedDay));
          break;
        case 1:
          getHolidayListApi();
          break;
        case 2:
          getLeaveListApi();
          break;
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        return false;
      },
      child: Scaffold(
        backgroundColor: MyColors.backgroundColor,
        appBar: appBar(context: context, title: 'Attendance', implyLeading: false, actions: [
              InkWell(
                onTap: (){
                  push(context: context, screen: expense_screen());
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, right: 10, bottom: 12),
                  child: ParagraphText('Expense', fontSize: 13, color: MyColors.primaryColor, underlined: true,)
                ),
              )
            ]),

          body: SingleChildScrollView(
            child: Column(
              children: [
                countLoading ==true ? Container(height: 20, alignment: Alignment.topCenter, child: CupertinoActivityIndicator(radius: 10, color: MyColors.blackColor,),):
                Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: MyColors.boxBorderColor, width: 1),
                      color: MyColors.boxBackgroundColor,
                    ),
                    child: Column(
                      children: [

                        vSizedBox10,
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [

                              ParagraphText('Today Attendance', fontSize: 14, fontWeight: FontWeight.w600,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.calendar_month_outlined, size: 17,),
                                  hSizedBox05,
                                  ParagraphText('18-05-2023, Thursday', fontSize: 11, color: MyColors.blackColor,),
                                ],
                              ),

                            ],
                          ),
                        ),
                        Divider(),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [

                            Center(
                              child: RoundEdgedButton(
                                text: punchInStatus == "1" ? 'Punch Out time' : 'Punch in time',
                                fontSize: 12,
                                width: MediaQuery.of(context).size.width/3, height: 40,
                                border_color: Colors.transparent,
                                color: isPunchInLoading == true ? MyColors.primaryColor.withOpacity(0.4) : MyColors.primaryColor,
                                onTap: (){
                                  punchInOutApi();
                                },
                              ),
                            ),

                            for(int i=0; i<punch_in_data.length; i++)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 25),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  if(punch_in_data[i]['human_in'] != null)
                                  ParagraphText('Punch in ${punch_in_data[i]['human_in']}', fontSize: 14, fontWeight: FontWeight.w600,),
                                  if(punch_in_data[i]['human_out'] != null)
                                    ParagraphText('Punch out ${punch_in_data[i]['human_out']}', fontSize: 14, fontWeight: FontWeight.w600,)
                                ],
                              ),
                            ),
                          ],
                        ),
                        vSizedBox10,
                      ],
                    )
                ),


                Container(
                  height: MediaQuery.of(context).size.height,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      vSizedBox10,

                      ///------------------Table calendar---------------------------
                      TableCalendar(
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        firstDay: DateTime.utc(2010, 10, 20),
                        lastDay: DateTime.utc(2040, 10, 20),
                        focusedDay: focusedDay,
                        rowHeight: 40,
                        onPageChanged: (val){
                          isMonth = "1";
                          setState(() {});
                          focusedDay = val;
                          selectedDay = val;

                          formattedDate = DateFormat("yyyy-MM-dd").format(val);
                          if(tabController.index == 1)
                          getHolidayListApi();

                          getLeaveCountApi();

                          if(tabController.index == 2)
                            getLeaveListApi();

                          if(isMonth == "1" && tabController.index == 0)
                          getAttendanceListApi(val);
                          print('selected date is $formattedDate');
                        } ,
                        selectedDayPredicate: (DateTime date) {
                          return isSameDay(selectedDay, date);
                        },
                        headerStyle: const HeaderStyle(
                          leftChevronIcon: Icon(CupertinoIcons.back,
                              color: MyColors.blackColor, size: 20),
                          rightChevronIcon: Icon(CupertinoIcons.forward,
                              color: MyColors.blackColor, size: 20),
                          formatButtonVisible: false,
                          titleCentered: true,

                          titleTextStyle: TextStyle(
                              fontSize: 15.0,
                              letterSpacing: 1.0,
                              color: MyColors.blackColor,
                              fontFamily: "poppins",
                              fontWeight: FontWeight.bold),
                        ),

                        daysOfWeekHeight: 40,

                        daysOfWeekStyle: const DaysOfWeekStyle(
                          weekdayStyle: TextStyle(
                            height: 1.3333333333333333,
                            fontSize: 15,
                            color: MyColors.blackColor,
                            fontWeight: FontWeight.w500,
                          ),
                          weekendStyle: TextStyle(
                            height: 1.3333333333333333,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: MyColors.blackColor,
                          ),
                        ),

                        calendarStyle: const CalendarStyle(
                          selectedTextStyle: TextStyle(
                              fontSize: 12,
                              fontFamily: "poppins",
                              color: MyColors.whiteColor,
                              fontWeight: FontWeight.w600),
                          selectedDecoration: BoxDecoration(
                            color: MyColors.orange1,
                            shape: BoxShape.circle,
                          ),
                          todayTextStyle: TextStyle(
                              fontSize: 12,
                              fontFamily: "poppins",
                              color: MyColors.whiteColor,
                              fontWeight: FontWeight.w600),
                          todayDecoration: BoxDecoration(
                            color: MyColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          defaultTextStyle: TextStyle(
                              fontSize: 15,
                              fontFamily: "poppins",
                              fontWeight: FontWeight.w600),
                          weekendTextStyle: TextStyle(
                              fontSize: 12,
                              fontFamily: "poppins",
                              color: MyColors.whiteColor,
                              fontWeight: FontWeight.w600),
                          weekendDecoration: BoxDecoration(
                            color: MyColors.grey10,
                            shape: BoxShape.circle,
                          ),

                        ),

                        calendarFormat: _calendarFormat,
                        onFormatChanged: (CalendarFormat format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        },
                        onDaySelected: (DateTime selectDay, DateTime focusDay) {
                          setState(() {
                            isMonth = "0";
                            setState(() {});
                            selectedDay = selectDay;
                            focusedDay = focusDay;
                            String dateclick = focusedDay.toString().substring(0, 10);

                            log('date selected$focusedDay');
                            log('date selected here$selectedDay');
                            log('date ===> $dateclick');
                            log('isMonth ===> $isMonth');
                            if(isMonth != "1")
                            getAttendanceListApi(selectedDay);
                          });
                        },

                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, day, focusedDay) {
                            for (DateTime d in toHighlight) {
                              if (day.day == d.day &&
                                  day.month == d.month &&
                                  day.year == d.year) {
                                return Container(
                                  decoration: const BoxDecoration(
                                    color: MyColors.green4,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${day.day}',
                                      style: const TextStyle(
                                          color: MyColors.whiteColor,
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'poppins'),
                                    ),
                                  ),
                                );
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                      ///------------------


                      vSizedBox20,

                      countLoading ==true ? Container(height: 20, alignment: Alignment.topCenter, child: CupertinoActivityIndicator(radius: 10, color: MyColors.blackColor,),):
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: MyColors.whiteColor,
                              boxShadow:[
                                BoxShadow(
                                  color: MyColors.grey1.withOpacity(0.8), //color of shadow
                                  spreadRadius: 0.2,
                                  blurRadius: 3,
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),

                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 10),
                              child: Column(
                                children: [
                                  ParagraphText('Present', fontSize: 12, fontWeight: FontWeight.w600, color: MyColors.darkred,),
                                  ParagraphText('${leave_count_data?['present']}', fontSize: 16, fontWeight: FontWeight.w600, color: MyColors.darkred,),

                                ],
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: MyColors.whiteColor,
                              boxShadow:[
                                BoxShadow(
                                  color: MyColors.grey1.withOpacity(0.8), //color of shadow
                                  spreadRadius: 0.2,
                                  blurRadius: 3,
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),

                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                              child: Column(
                                children: [
                                  ParagraphText('Absent', fontSize: 12, fontWeight: FontWeight.w600, color: MyColors.red3,),
                                  ParagraphText('${leave_count_data?['absent']}', fontSize: 16, fontWeight: FontWeight.w600, color: MyColors.red3,),

                                ],
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: MyColors.whiteColor,
                              boxShadow:[
                                BoxShadow(
                                  color: MyColors.grey1.withOpacity(0.8), //color of shadow
                                  spreadRadius: 0.2,
                                  blurRadius: 3,
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                              child: Column(
                                children: [
                                  ParagraphText('Half Day', fontSize: 12, fontWeight: FontWeight.w600, color: MyColors.orange1,),
                                  ParagraphText('${leave_count_data?['half_days']}', fontSize: 16, fontWeight: FontWeight.w600, color: MyColors.orange1,),

                                ],
                              ),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: MyColors.whiteColor,
                              boxShadow:[
                                BoxShadow(
                                  color: MyColors.grey1.withOpacity(0.8), //color of shadow
                                  spreadRadius: 0.2,
                                  blurRadius: 3,
                                  offset: Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                              child: Column(
                                children: [
                                  ParagraphText('Paid Leave', fontSize: 12, fontWeight: FontWeight.w600, color: MyColors.blue2,),
                                  ParagraphText('${leave_count_data?['paid_days']}', fontSize: 16, fontWeight: FontWeight.w600, color: MyColors.blue2,),

                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      vSizedBox20,
                      TabBar(
                        controller: tabController,
                        labelColor: MyColors.primaryColor,
                        unselectedLabelColor: MyColors.hintColor,
                        indicator: ShapeDecoration(
                          shape: UnderlineInputBorder(
                              borderSide: BorderSide(color: MyColors.primaryColor, width: 2, style: BorderStyle.solid)),
                        ),
                        tabs: <Widget>[
                          ParagraphText('Attendance', fontSize: 15, fontWeight: FontWeight.w600,),
                          ParagraphText('Holiday', fontSize: 15, fontWeight: FontWeight.w600,),
                          ParagraphText('Leaves', fontSize: 15, fontWeight: FontWeight.w600,),
                        ],
                      ),
                      vSizedBox20,

                      Expanded(
                        child: TabBarView(
                          controller: tabController,
                            children: [
                              ///Attendance
                              loading ==true ? Container(height: 20, alignment: Alignment.topCenter, child: CupertinoActivityIndicator(radius: 12, color: MyColors.blackColor,),):
                              attendance_list_data.length == 0 ?  Container(alignment: Alignment.topCenter, child: ParagraphText('No Attendance List Available', fontSize: 12, color: MyColors.grey1, fontWeight: FontWeight.w700,)):
                              ListView.builder(
                                  itemCount: attendance_list_data.length,
                                  itemBuilder: (context, index){
                                return Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      color: MyColors.whiteColor,
                                      boxShadow:[
                                        BoxShadow(
                                          color: MyColors.grey1.withOpacity(0.8), //color of shadow
                                          spreadRadius: 0.2,
                                          blurRadius: 3,
                                          offset: Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              ParagraphText('${attendance_list_data[index]['in_time']}', fontSize: 13, fontWeight: FontWeight.w600,),
                                              ParagraphText('Total working hour: ${attendance_list_data[index]['total_work_hour']}', fontSize: 9,fontWeight: FontWeight.w600, color: MyColors.green, ),
                                            ],
                                          ),

                                          vSizedBox05,
                                          for(int i = 0 ; i<attendance_list_data[index]['attendance_data'].length; i++)
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              ParagraphText('Punch in: ${attendance_list_data[index]['attendance_data'][i]['in_time']}', fontSize: 9, fontWeight: FontWeight.w600,color: MyColors.green,),
                                              ParagraphText('${attendance_list_data[index]['attendance_data'][i]['work_hour']['hour_min']}', fontSize: 10, fontWeight: FontWeight.w700, color: MyColors.primaryColor,),
                                              ParagraphText('Punch out: ${attendance_list_data[index]['attendance_data'][i]['out_time']}', fontSize: 9,fontWeight: FontWeight.w600, color: MyColors.red3, ),
                                            ],
                                          ),



                                          vSizedBox05,
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: RichText(
                                              text: TextSpan(children: [
                                                TextSpan(text: 'Salary will be: ', style: TextStyle(fontSize: 10, fontFamily: 'poppins',color: MyColors.blackColor)),
                                                // TextSpan(text: '80.6x8.35 ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, fontFamily: 'poppins',color: MyColors.blackColor )),
                                                TextSpan(text: '${attendance_list_data[index]['salary']}', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, fontFamily: 'poppins', color: MyColors.green)),
                                              ]),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),

                              ///Holiday
                              loading ==true ? Container(height: 20, alignment: Alignment.topCenter, child: CupertinoActivityIndicator(radius: 12, color: MyColors.blackColor,),):
                              holiday_list_data.length == 0 ?  Container(alignment: Alignment.topCenter, child: ParagraphText('No Holidays for this month', fontSize: 12, color: MyColors.grey1, fontWeight: FontWeight.w700,)):
                              ListView.builder(
                                  itemCount: holiday_list_data.length,
                                  itemBuilder: (context, index){
                                return Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: MyColors.whiteColor,
                                      boxShadow:[
                                        BoxShadow(
                                          color: MyColors.grey1.withOpacity(0.8), //color of shadow
                                          spreadRadius: 0.2,
                                          blurRadius: 3,
                                          offset: Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(child: ParagraphText('${DateFormat("dd-MMM-yyyy").format(DateTime.parse(holiday_list_data[index]['holiday_date'].toString()))}', fontSize: 13, fontWeight: FontWeight.w600,)),
                                          Expanded(child: ParagraphText(holiday_list_data[index]['day'], fontSize: 10,fontWeight: FontWeight.w600, color: MyColors.orange1, )),
                                          Expanded(child: ParagraphText(holiday_list_data[index]['title'], fontSize: 11,fontWeight: FontWeight.w600, color: MyColors.green3, )),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),

                              ///Leaves
                              loading ==true ? Container(height: 20, alignment: Alignment.topCenter, child: CupertinoActivityIndicator(radius: 12, color: MyColors.blackColor,),):
                              all_leave_data.length == 0 ?  Container(alignment: Alignment.topCenter, child: ParagraphText('No Leaves for this month', fontSize: 12, color: MyColors.grey1, fontWeight: FontWeight.w700,)):
                              ListView.builder(
                                  itemCount: all_leave_data.length,
                                  itemBuilder: (context, index){
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 15, left: 2, right: 2, top: 2),
                                      child:  Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: MyColors.whiteColor,
                                          boxShadow:[
                                            BoxShadow(
                                              color: MyColors.grey1.withOpacity(0.8), //color of shadow
                                              spreadRadius: 0.2,
                                              blurRadius: 3,
                                              offset: Offset(0, 0),
                                            ),
                                          ],
                                        ),

                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 20, top: 10, right: 20),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Container(
                                                      decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(100),
                                                          border: Border.all(color: MyColors.primaryColor, width: 2)
                                                      ),
                                                      child: ClipRRect(
                                                          borderRadius: BorderRadius.circular(100),
                                                          child: CachedNetworkImage(imageUrl:userData!.image! , height: 60, width: 60, fit: BoxFit.cover,))),
                                                  hSizedBox10,

                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      ParagraphText(userData.Name.toString(), fontSize: 14, fontWeight: FontWeight.w600,),
                                                      ParagraphText(DateFormat("dd-MM-yyyy").format(DateTime.parse(all_leave_data[index]['created_at'].toString())), fontSize: 12, color: MyColors.grey6, ),
                                                    ],
                                                  ),

                                                  Spacer(),

                                                  Row(
                                                    children: [
                                                      Container(
                                                        height: 25,
                                                        alignment: Alignment.center,
                                                        decoration: BoxDecoration(
                                                          color:
                                                          all_leave_data[index]['is_approved'].toString() == '1' && all_leave_data[index]['is_full_day'].toString() == '1' ? MyColors.green :
                                                          all_leave_data[index]['is_approved'].toString() == '2'  ? MyColors.redColor : MyColors.orange1,
                                                          borderRadius: BorderRadius.circular(30),
                                                        ),
                                                        child: Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 10),
                                                          child: ParagraphText(

                                                            all_leave_data[index]['is_approved'].toString() == '1' && all_leave_data[index]['is_full_day'].toString() == '1' ? 'Approved' :
                                                            all_leave_data[index]['is_approved'].toString() == '1' && all_leave_data[index]['is_full_day'].toString() == '0'  ? 'Approved Half day' :
                                                            all_leave_data[index]['is_approved'].toString() == '0'  ? 'Pending' :
                                                            all_leave_data[index]['is_approved'].toString() == '2'  ? 'Unapproved' : '',

                                                            fontSize: 10, fontWeight: FontWeight.w600,
                                                            color: MyColors.whiteColor,
                                                          ),
                                                        ),
                                                      ),

                                                        hSizedBox20,
                                                    ],
                                                  )
                                                ],
                                              ),

                                              vSizedBox10,


                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      ParagraphText(DateFormat("dd-MM-yyyy").format(DateTime.parse(all_leave_data[index]['from_date'])), fontSize: 13, fontWeight: FontWeight.w600,),
                                                      ParagraphText('Start Date ', fontSize: 12, color: MyColors.grey6, ),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      ParagraphText(DateFormat("dd-MM-yyyy").format(DateTime.parse(all_leave_data[index]['to_date'])), fontSize: 13, fontWeight: FontWeight.w600,),
                                                      ParagraphText('End Date ', fontSize: 12, color: MyColors.grey6, ),
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(right: 20),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        ParagraphText(
                                                          all_leave_data[index]['is_full_day'].toString() == '0' && all_leave_data[index]['total_days'].toString() == '0' ? "1/2 Day" :
                                                          '${all_leave_data[index]['total_days'].toString()} Day', fontSize: 13, fontWeight: FontWeight.w600,),
                                                        ParagraphText('Leave Days', fontSize: 12, color: MyColors.grey6, ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),

                                              vSizedBox10,

                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  ParagraphText('Description', fontSize: 11,color: MyColors.grey7, fontWeight: FontWeight.w600, ),
                                                  ParagraphText(all_leave_data[index]['reason'],
                                                    fontSize: 11,color: MyColors.grey7, ),
                                                ],
                                              ),
                                              vSizedBox10,

                                              RichText(text: TextSpan(
                                                  children: [
                                                    TextSpan(text: 'REPLY:  ', style: TextStyle(fontSize: 11,color: MyColors.grey7, fontWeight: FontWeight.w600,)),
                                                    TextSpan(text: all_leave_data[index]['remark'],
                                                        style: TextStyle(fontSize: 11,color: MyColors.grey7,)),
                                                  ]
                                              )),


                                              vSizedBox20,
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),

                            ]),
                      ),

                      vSizedBox20,
                    ],
                  ),
                ),
              ],
            ),
          ),

        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: MyColors.primaryColor,
          onPressed: () {
            push(context: context, screen: leave_requset(leave_id: "",));
          },
        ),
      ),
    );
  }
}
