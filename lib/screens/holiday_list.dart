import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neat_and_clean_calendar/flutter_neat_and_clean_calendar.dart';
import 'package:hrm_app/constants/global_data.dart';
import 'package:hrm_app/constants/sized_box.dart';
import 'package:hrm_app/widgets/appbar.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../constants/colors.dart';
import '../constants/toast.dart';
import '../services/api_urls.dart';
import '../services/webservices.dart';
import '../widgets/CustomTexts.dart';

class holiday_list extends StatefulWidget {
  const holiday_list({Key? key}) : super(key: key);

  @override
  State<holiday_list> createState() => _holiday_listState();
}

class _holiday_listState extends State<holiday_list> {

  var formattedDate = DateFormat("yyyy-MM-dd").format(DateTime.now());
  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  final List<DateTime> toHighlight = [];

  bool loading =false;
  List holiday_list_data=[];


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

  @override
  void initState() {
    super.initState();
    getHolidayListApi();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: appBar(context: context, title: 'Holiday'),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            ///------------------Table calendar---------------------------
            Container(
                  decoration: BoxDecoration(
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
              child: TableCalendar(
                startingDayOfWeek: StartingDayOfWeek.monday,
                firstDay: DateTime.utc(2010, 10, 20),
                lastDay: DateTime.utc(2040, 10, 20),
                focusedDay: focusedDay,
                rowHeight: 40,
                onPageChanged: (val){
                 focusedDay = val;
                  formattedDate = DateFormat("yyyy-MM-dd").format(val);
                  getHolidayListApi();
                  print('selected date is $formattedDate');
                } ,
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
                    selectedDay = selectDay;
                    focusedDay = focusDay;
                    String dateclick = focusedDay.toString().substring(0, 10);

                    log('date selected$focusedDay');
                    log('date selected here$selectedDay');
                    log('date ===> $dateclick');
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
                            color: MyColors.green2,
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
            ),
            ///------------------

            vSizedBox20,

            Row(
              children: [
                hSizedBox20,
                Container(
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(
                    color: MyColors.grey10,
                    borderRadius: BorderRadius.circular(5)
                  ),
                ),
                hSizedBox10,
                ParagraphText('Weekoff', fontSize: 14, fontWeight: FontWeight.w600, ),

                hSizedBox60,
                Container(
                  height: 25,
                  width: 1.5,
                  decoration: BoxDecoration(
                      color: MyColors.grey2,
                      borderRadius: BorderRadius.circular(5)
                  ),
                ),
                hSizedBox40,


                Container(
                  height: 25,
                  width: 25,
                  decoration: BoxDecoration(
                      color: MyColors.green2,
                      borderRadius: BorderRadius.circular(5)
                  ),
                ),
                hSizedBox10,
                ParagraphText('Public Holiday', fontSize: 14, fontWeight: FontWeight.w600, ),
              ],
            ),

            vSizedBox20,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ParagraphText('Holidays', fontSize: 16, fontWeight: FontWeight.w600, ),

                  vSizedBox20,


                  loading ==true ? Center(child: Container(height: 300, child: CupertinoActivityIndicator(radius: 12, color: MyColors.blackColor,),)):
                  holiday_list_data.length == 0 ?  Center(child: Container(height: 150, alignment: Alignment.bottomCenter, child: ParagraphText('No Holidays for this month', fontSize: 12, color: MyColors.grey1, fontWeight: FontWeight.w700,))):
                  ListView.builder(
                      itemCount: holiday_list_data.length,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index){
                        return
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              vSizedBox05,
                              ParagraphText('${DateFormat("dd-MM-yyyy").format(DateTime.parse(holiday_list_data[index]['holiday_date'].toString()))}, ${holiday_list_data[index]['day']}', fontWeight: FontWeight.w600, fontSize: 13, ),
                              vSizedBox05,
                              ParagraphText('${holiday_list_data[index]['title']}', fontSize: 14,  ),
                              vSizedBox05,
                              Divider()

                            ],
                          );
                      }),
                ],
              ),
            ),


          ],
        ),
      ),
    );
  }
}
