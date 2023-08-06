import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/radio/gf_radio.dart';
import 'package:getwidget/size/gf_size.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../constants/colors.dart';
import '../constants/global_data.dart';
import '../constants/images_url.dart';
import '../constants/sized_box.dart';
import '../constants/toast.dart';
import '../functions/navigation_functions.dart';
import '../services/api_urls.dart';
import '../services/webservices.dart';
import '../widgets/CustomTexts.dart';
import '../widgets/appbar.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/dropdown.dart';
import '../widgets/round_edged_button.dart';
import 'channel_chats.dart';


class leave_requset extends StatefulWidget {
  String leave_id;
   leave_requset({Key? key, required this.leave_id}) : super(key: key);

  @override
  State<leave_requset> createState() => _leave_requsetState(leave_id);
}

class _leave_requsetState extends State<leave_requset>  with SingleTickerProviderStateMixin{
  late TabController tabController;
  late PageController _pageController;
  _leave_requsetState(this.leave_id);

  PopupMenuItem _buildPopupMenuItem( String title, int position) {
    return PopupMenuItem(
      height: 0,
      value: position,
      child:  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          vSizedBox05,
          Text(title, style: TextStyle(color:  MyColors.whiteColor),),
          position == Options.Delete.index ? Container(height: 0,) :
          Divider(color:  MyColors.whiteColor)
        ],
      ),
    );
  }
  String? selectedVal;
  String? selectedHalf;
  int groupValue = 0;
  TextEditingController fromDate = TextEditingController();
  TextEditingController toDate = TextEditingController();
  TextEditingController selectHalfDate = TextEditingController();
  TextEditingController selectDay = TextEditingController();
  TextEditingController reason = TextEditingController();
  bool isEnable1=false;
  bool isEdit = false;
  var total_days;
  DateTime selectedDate1 = DateTime.now();
  DateTime selectedDate2 = DateTime.now();
  DateTime selectedDate3 = DateTime.now();
  bool loading =false;
  bool loading2 =false;
  List all_leave_data=[];
  File? imgFile;
  final imgPicker = ImagePicker();
  DateFormat outputFormat = DateFormat('yyyy-MM-dd');
  String leave_id;

  ///image upload code
  Future<void> _image_camera_dialog(BuildContext context) async{
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Center(child: ParagraphText('Select an Image',)),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            onPressed: () async{
              var imgGallery = await imgPicker.pickImage(source: ImageSource.gallery);
              setState(() {
                imgFile = File(imgGallery!.path);
              });
              Navigator.pop(context);
            },
            child: ParagraphText('Select a photo from Gallery',),),
          CupertinoActionSheetAction(
            onPressed: () async{
              var imgCamera = await imgPicker.pickImage(source: ImageSource.camera);
              setState(() {
                imgFile = File(imgCamera!.path);
              });
              Navigator.pop(context);
            },
            child: ParagraphText('Take a photo with the camera',),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: () {
            Navigator.pop(context);
          },
          child: ParagraphText('Cancel',),
        ),
      ),
    );
  }

  getAllLeaveApi() async{
    setState(() {loading =true;});

    Map<String,dynamic> request={
      'company_id': userData.company_id.toString(),
      'employee_id': userData.id.toString(),
    };

    final response = await Webservices.postData(apiUrl: ApiUrls.get_all_my_leaves, request: request, isGetMethod: true);

    setState(() {loading =false;});

    if(response['status'].toString() == '1'){
      all_leave_data = response['data'];
      print("all_leave_data $all_leave_data");

      setState(() {});
    }else{
      toast(response['message']);
    }
  }

  postLeaveRequestApi() async{

    if(selectedVal == '' || selectedVal == null){
      toast('Please select leave type');
    }else if(selectedDate1 == '' && groupValue == 0){
      toast('Please select from date');
    }else if(selectedDate2 == '' && groupValue == 0){
      toast('Please select to date');
    }else if(selectedDate3 == '' && groupValue == 1){
      toast('Please select date');
    }else if(reason.text == ''){
      toast('Please select reason');
    }else if((total_days == '' || total_days == null) && groupValue == 0){
      toast('Please select total days');
    }else if((selectedHalf == '' || selectedHalf == null) && groupValue == 1 ){
      toast('Please select half');
    }
    else{
      setState(() {loading2 =true;});

      Map<String,dynamic> request =
      groupValue == 1 ?
      {
        ///half day-----------
        if(isEdit == true)
          'leave_id' : leave_id,

        'employee_id': userData.id.toString(),
        'company_id': userData.company_id.toString(),
        'leave_type': selectedVal,
        'is_full_day': '0',
        'from_date': selectedDate3.toString(),
        'reason': reason.text,
        'day_type': selectedHalf,
      }:
      {
        ///full day-----------
        if(isEdit == true)
        'leave_id' : leave_id,

        'employee_id': userData.id.toString(),
        'company_id': userData.company_id.toString(),
        'leave_type': selectedVal,
        'is_full_day': '1',
        'from_date': selectedDate1.toString(),
        'to_date':selectedDate2.toString(),
        'total_days': selectDay.text,
        'reason': reason.text,
      };


      Map<String, dynamic> imageFile = {};

      if(imgFile!=null){
        imageFile['attachment'] =  imgFile;
      }


      final response = await Webservices.postDataWithImageFunction(body: request, files: imageFile, apiUrl: isEdit == true? ApiUrls.edit_leave_request : ApiUrls.add_leave_request);

      setState(() {loading2 =false;});

      if(response['status'].toString() == '1'){
        toast(response['message']);
        tabController.index = 0;
        setState(() {});
      }else{
        toast(response['message']);
      }
    }
  }

  deleteLeaveApi(i) async{
    setState(() {loading =true;});

    Map<String,dynamic> request={
      'company_id': userData.company_id.toString(),
      'employee_id': userData.id.toString(),
      'leave_id': all_leave_data[i]['id'].toString(),
    };

    final response = await Webservices.postData(apiUrl: ApiUrls.delete_my_leave, request: request, isGetMethod: true);

    setState(() {loading =false;});

    if(response['status'].toString() == '1'){
      toast(response['message']);
      tabController.index = 0;
      setState(() {});
    }else{
      toast(response['message']);
    }
  }

  autoFill(index){
    selectedVal = all_leave_data[index]['leave_type'];
    groupValue = all_leave_data[index]['is_full_day'].toString()  == "1" ? 0 : 1;
    fromDate.text = all_leave_data[index]['from_date'];
    toDate.text = all_leave_data[index]['to_date'];
    selectHalfDate.text = all_leave_data[index]['from_date'];
    selectDay.text = all_leave_data[index]['total_days'].toString();
    reason.text = all_leave_data[index]['reason'];
    selectedHalf = all_leave_data[index]['day_type'];

    setState(() {});
    print('auto_fill_done');
  }

  clearAllData(){
    selectedVal = '';
    groupValue = 0;
    fromDate.text = '';
    toDate.text = '';
    selectHalfDate.text = '';
    selectDay.text = '';
    reason.text = '';
    selectedHalf = '';
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    _pageController = PageController(initialPage: tabController.index);
    tabController.addListener(() {
      _pageController.animateToPage(
        tabController.index,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });

    getAllLeaveApi();
    print("leave_id===${widget.leave_id}");

  }

  void _handleTabChange(index) {
      switch (index) {
        case 0:
          getAllLeaveApi();
          break;
        case 1:

          break;
      }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: MyColors.backgroundColor,

        appBar: appBar(context: context, title: 'Leave Request',  bottom: TabBar(
            controller: tabController,
            labelColor: MyColors.primaryColor,
            unselectedLabelColor: MyColors.hintColor,
            indicator: ShapeDecoration(
              shape: UnderlineInputBorder(
                  borderSide: BorderSide(color: MyColors.primaryColor, width: 2, style: BorderStyle.solid)),
            ),
            tabs: <Widget>[
              ParagraphText('All Leave', fontSize: 15, fontWeight: FontWeight.w600,),
              ParagraphText('Request Leave', fontSize: 15, fontWeight: FontWeight.w600,),
            ],
          onTap: (index){
            _handleTabChange(index);
            tabController.index = index;
            setState(() {});
          },
          ),),

        body: Padding(
          padding: const EdgeInsets.symmetric( vertical: 10),
          child:  PageView(
            controller: _pageController,
            onPageChanged: (index) {
              print("about to page change");
              _handleTabChange(index);
              tabController.index = index;
              setState(() {});
              print("after page change ${tabController.index}");

            },
            children: <Widget>[

              loading ==true ? Center(child: CupertinoActivityIndicator(radius: 12, color: MyColors.blackColor,)):
              all_leave_data.length == 0 ?  Center(child: Container(child: ParagraphText('No Leave Records Yet', fontSize: 12, color: MyColors.grey1, fontWeight: FontWeight.w700,))):
              ListView.builder(
                  itemCount:  all_leave_data.length,
                  itemBuilder: (context, index){
                    if(widget.leave_id != "" && widget.leave_id != all_leave_data[index]['id'].toString()){
                      return Container();
                    }
                    return   Padding(
                      padding: const EdgeInsets.only(bottom: 10, left: 2, right: 2, top: 2),
                      child:  Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: MyColors.boxBorderColor, width: 1),
                          color: MyColors.boxBackgroundColor,
                        ),

                        child: Padding(
                          padding: const EdgeInsets.only(left: 20, top: 10),
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

                                      if(all_leave_data[index]['is_approved'].toString() == '0')
                                      PopupMenuButton(
                                        color: MyColors.grey6,
                                        iconSize: 25,
                                        position: PopupMenuPosition.under,
                                        padding: EdgeInsets.zero,
                                        constraints:  BoxConstraints.expand(width: 150, height: 85),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        onSelected: (value) async{
                                          ///Delete task
                                          if (value == Options.Delete.index){
                                            await deleteLeaveApi(index);
                                            getAllLeaveApi();
                                          }
                                          else if (value == Options.Edit.index){
                                            tabController.index = 1;
                                            isEdit = true;
                                            leave_id = all_leave_data[index]['id'].toString();
                                            setState(() {});

                                            await autoFill(index);
                                          }
                                          },
                                        itemBuilder: (BuildContext context) =>  [
                                          _buildPopupMenuItem('Edit', Options.Edit.index, ),
                                          _buildPopupMenuItem('Delete', Options.Delete.index, ),
                                        ],
                                      ),

                                      if(all_leave_data[index]['is_approved'].toString() != '0')
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

              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ParagraphText('Leave Type', fontSize: 15,),

                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: MyColors.grey1.withOpacity(0.5))
                        ),
                        child: DropDown(
                          items: ['Paid Leave', 'Sick Leave', 'Earned Leave' ],
                          label: '',
                          selectedValue: selectedVal,
                          height: 50,
                          borderRadius: 10,
                          width: MediaQuery.of(context).size.width,
                          dropdownwidth: MediaQuery.of(context).size.width/1.09,
                          borderColor: MyColors.grey1.withOpacity(0.5),
                          onChange: (val) {
                            setState(() {
                              selectedVal = val;
                              print("selected leave type=== $selectedVal");
                            });
                          },
                        ),
                      ),

                      vSizedBox20,

                      Row(
                        children: [
                          GFRadio(
                            size: GFSize.SMALL,
                            activeBorderColor: MyColors.primaryColor,
                            activeBgColor:MyColors.grey8,
                            inactiveBgColor: MyColors.grey8,
                            inactiveBorderColor: MyColors.primaryColor,
                            value: 0,
                            groupValue: groupValue,
                            onChanged: (val) {
                              setState(() {
                                groupValue = val;
                              });
                            },
                            inactiveIcon: null,
                            radioColor: MyColors.primaryColor,
                          ),
                          hSizedBox10,
                          ParagraphText('Full Day', fontSize: 18, fontWeight: FontWeight.w600, color: MyColors.blackColor,),

                          hSizedBox40,

                          GFRadio(
                            size: GFSize.SMALL,
                            activeBorderColor: MyColors.primaryColor,
                            activeBgColor:MyColors.grey8,
                            inactiveBgColor: MyColors.grey8,
                            inactiveBorderColor: MyColors.primaryColor,
                            value: 1,
                            groupValue: groupValue,
                            onChanged: (val) {
                              setState(() {
                                groupValue = val;
                              });
                            },
                            inactiveIcon: null,
                            radioColor: MyColors.primaryColor,
                          ),
                          hSizedBox10,
                          ParagraphText('Half Day', fontSize: 18, fontWeight: FontWeight.w600, color: MyColors.blackColor,),
                        ],
                      ),
                      vSizedBox20,

                      groupValue == 0?
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ParagraphText('From Date', fontSize: 15,),
                                  CustomTextField(
                                    controller: fromDate,
                                    hintText: 'Pick Date',
                                    enabled: isEnable1,
                                    width: MediaQuery.of(context).size.width/2.3,
                                    borderColor: MyColors.grey1.withOpacity(0.5),
                                    suffix2: GestureDetector(
                                        onTap: (){
                                          showDatePicker(
                                              context: context,
                                              initialDate: selectedDate1,
                                              firstDate: DateTime.now(),
                                              lastDate: DateTime.now().add(Duration(days: 100000)),
                                              builder: (context, child) {
                                                return Theme(
                                                  data: Theme.of(context).copyWith(
                                                    colorScheme: const ColorScheme.light(
                                                      primary: MyColors.primaryColor,
                                                      onPrimary: Color(0xffE2E2E2),
                                                      onSurface: Color(0xff1C1F24),
                                                    ),
                                                  ),
                                                  child: child!,
                                                );
                                              }).then((value) {
                                            DateTime newDate = DateTime(
                                                value != null ? value.year : selectedDate1.year,
                                                value != null ? value.month : selectedDate1.month,
                                                value != null ? value.day : selectedDate1.day,
                                                selectedDate1.hour,
                                                selectedDate1.minute);
                                            setState(() {
                                              selectedDate1 = newDate;
                                              print("selectedDate1${DateFormat("yyyy-MM-dd").format(selectedDate1)}");
                                              fromDate.text = DateFormat("dd-MMM-yyyy").format(selectedDate1);
                                            });

                                          });
                                        },
                                        child: Icon(Icons.calendar_month, color: MyColors.primaryColor,)),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ParagraphText('To Date', fontSize: 15,),
                                  CustomTextField(
                                    controller: toDate,
                                    hintText: 'Pick Date',
                                    enabled: isEnable1,
                                    width: MediaQuery.of(context).size.width/2.3,
                                    borderColor: MyColors.grey1.withOpacity(0.5),
                                    suffix2: GestureDetector(
                                        onTap: (){
                                          showDatePicker(
                                              context: context,
                                              initialDate: selectedDate2,
                                              firstDate: DateTime.now(),
                                              lastDate: DateTime.now().add(Duration(days: 100000)),
                                              builder: (context, child) {
                                                return Theme(
                                                  data: Theme.of(context).copyWith(
                                                    colorScheme: const ColorScheme.light(
                                                      primary: MyColors.primaryColor,
                                                      onPrimary: Color(0xffE2E2E2),
                                                      onSurface: Color(0xff1C1F24),
                                                    ),
                                                  ),
                                                  child: child!,
                                                );
                                              }).then((value) {
                                            DateTime newDate = DateTime(
                                                value != null ? value.year : selectedDate2.year,
                                                value != null ? value.month : selectedDate2.month,
                                                value != null ? value.day : selectedDate2.day,
                                                selectedDate2.hour,
                                                selectedDate2.minute);
                                            setState(() {
                                              selectedDate2 = newDate;

                                              total_days = selectedDate2.difference(selectedDate1).inDays;
                                              selectDay.text = (total_days + 1).toString();
                                              print("total_days ${total_days.runtimeType}");


                                              print("selectedDate1${DateFormat("yyyy-MM-dd").format(selectedDate2)}");
                                              toDate.text = DateFormat("dd-MMM-yyyy").format(selectedDate2);
                                            });
                                          });
                                        },
                                        child: Icon(Icons.calendar_month, color: MyColors.primaryColor,)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          vSizedBox20,

                          ParagraphText('Select Day (in numbers)', fontSize: 15,),
                          CustomTextField(
                            controller: selectDay,
                            hintText: '',
                            enabled: false,
                            keyboardType: TextInputType.number,
                            borderColor: MyColors.grey1.withOpacity(0.5),
                          ),
                        ],
                      ):
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ParagraphText('Select Date', fontSize: 15,),
                          CustomTextField(
                            controller: selectHalfDate,
                            hintText: 'Pick Date',
                            enabled: isEnable1,
                            borderColor: MyColors.grey1.withOpacity(0.5),
                            suffix2: GestureDetector(
                                onTap: (){
                                  showDatePicker(
                                      context: context,
                                      initialDate: selectedDate3,
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(Duration(days: 100000)),
                                      builder: (context, child) {
                                        return Theme(
                                          data: Theme.of(context).copyWith(
                                            colorScheme: const ColorScheme.light(
                                              primary: MyColors.primaryColor,
                                              onPrimary: Color(0xffE2E2E2),
                                              onSurface: Color(0xff1C1F24),
                                            ),
                                          ),
                                          child: child!,
                                        );
                                      }).then((value) {
                                    DateTime newDate = DateTime(
                                        value != null ? value.year : selectedDate3.year,
                                        value != null ? value.month : selectedDate3.month,
                                        value != null ? value.day : selectedDate3.day,
                                        selectedDate3.hour,
                                        selectedDate3.minute);
                                    setState(() {
                                      selectedDate3 = newDate;
                                      print("selectedDate1${DateFormat("yyyy-MM-dd").format(selectedDate3)}");
                                      selectHalfDate.text = DateFormat("dd-MMM-yyyy").format(selectedDate3);
                                    });

                                  });
                                },
                                child: Icon(Icons.calendar_month, color: MyColors.primaryColor,)),
                          ),
                          vSizedBox20,

                          ParagraphText('Select Half', fontSize: 15,),
                          Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: MyColors.grey1.withOpacity(0.5))
                            ),
                            child: DropDown(
                              items: ['First Half', 'Second Half',  ],
                              label: '',
                              selectedValue: selectedHalf,
                              height: 50,
                              borderRadius: 10,
                              width: MediaQuery.of(context).size.width,
                              dropdownwidth: MediaQuery.of(context).size.width/1.09,
                              borderColor: MyColors.grey1.withOpacity(0.5),
                              onChange: (val) {
                                setState(() {
                                  selectedHalf = val;
                                  print("selected day type=== $selectedHalf");
                                });
                              },
                            ),
                          ),
                        ],
                      ),

                      vSizedBox20,

                      ParagraphText('Reason', fontSize: 15,),
                      CustomTextField(
                        controller: reason,
                        hintText: '',
                        maxLines: 10,
                        height: 120,
                        borderColor: MyColors.grey1.withOpacity(0.5),
                      ),

                      vSizedBox20,
                      ParagraphText('Attachments', fontSize: 15,),
                      Row(
                        children: [
                          RoundEdgedButton(text: 'ATTACH FILE', textColor: MyColors.hintColor,  width: 180, fontSize: 13, height: 45, borderRadius: 30,
                            border_color: MyColors.grey1.withOpacity(0.5), color: MyColors.whiteColor,
                            icon: MyImages.attach_tilt,
                            iconSize: 25,
                            leftTextPadding: 10,
                            rightTextPadding: 10,
                            onTap: (){
                              _image_camera_dialog(context);
                            },
                          ),

                          if(imgFile != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Icon(Icons.check_circle, color: MyColors.primaryColor,),
                            )
                        ],
                      ),

                      RoundEdgedButton(text: 'Submit', isLoad: loading2, onTap: (){
                        postLeaveRequestApi();
                      },)
                    ],
                  ),
                ),
              )

            ],

          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }
}
