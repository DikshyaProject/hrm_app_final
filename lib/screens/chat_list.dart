import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hrm_app/constants/sized_box.dart';
import 'package:hrm_app/functions/navigation_functions.dart';
import 'package:hrm_app/screens/user_chat_screen.dart';
import 'package:hrm_app/widgets/round_edged_button.dart';
import '../constants/colors.dart';
import '../constants/images_url.dart';
import '../widgets/CustomTexts.dart';
import '../widgets/appbar.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/new_chat_dialog.dart';
import 'announcement.dart';


class chat_list extends StatefulWidget {
  const chat_list({Key? key}) : super(key: key);

  @override
  State<chat_list> createState() => _chat_listState();
}

class _chat_listState extends State<chat_list> {
  List chatList = [
    { 'image' : MyImages.boy1, 'name' : 'John Smith', 'msg' : 'Sure, what time are you free this monday?', 'time':'12:34 pm' , },
    { 'image' : MyImages.boy2, 'name' : 'Nigel Smith', 'msg' : 'Sure, what time are you free this monday?', 'time':'12:34 pm' , },
    {'image' : MyImages.boy3, 'name' : 'Smith', 'msg' : 'Sure, what time are you free this monday?', 'time':'12:34 pm' , },
    {'image' : MyImages.boy4, 'name' : 'Rocky', 'msg' : 'Sure, what time are you free this monday?', 'time':'12:34 pm' , },
    {'image' : MyImages.girl1, 'name' : 'Sonia', 'msg' : 'Sure, what time are you free this monday?', 'time':'12:34 pm' , },
    {'image' : MyImages.girl2, 'name' : 'Mona', 'msg' : 'Sure, what time are you free this monday?', 'time':'12:34 pm' , },
    {'image' : MyImages.girl3, 'name' : 'Liza', 'msg' : 'Sure, what time are you free this monday?', 'time':'12:34 pm' , },
    {'image' : MyImages.girl4, 'name' : 'Liza', 'msg' : 'Sure, what time are you free this monday?', 'time':'12:34 pm' , },
    {'image' : MyImages.boy1, 'name' : 'John Smith', 'msg' : 'Sure, what time are you free this monday?', 'time':'12:34 pm' , },
    {'image' : MyImages.boy2, 'name' : 'Nigel Smith', 'msg' : 'Sure, what time are you free this monday?', 'time':'12:34 pm' , },
    {'image' : MyImages.boy3, 'name' : 'Smith', 'msg' : 'Sure, what time are you free this monday?', 'time':'12:34 pm' , },
    {'image' : MyImages.boy4, 'name' : 'Rocky', 'msg' : 'Sure, what time are you free this monday?', 'time':'12:34 pm' , },
    ];
  TextEditingController  search = TextEditingController();



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        return false;
      },
      child: Scaffold(
        backgroundColor: MyColors.backgroundColor,
        appBar: appBar(context: context, implyLeading: false, title: 'Messages', ),

        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
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

                child: CustomTextField(
                  controller: search,
                  hintText: 'Search Task',
                  hintcolor: MyColors.blackColor,
                  borderColor: MyColors.whiteColor,
                  fontsize: 12,
                  height: 55,
                  preffix: Icon(CupertinoIcons.search, color: MyColors.blackColor, size: 25,),
                  suffix2: Container(
                    alignment: Alignment.center,
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: MyColors.primaryColor.withOpacity(0.1),
                    ),
                    child: Icon(CupertinoIcons.chevron_forward, color: MyColors.primaryColor, size: 20,),
                  ),
                  onChanged: (val){
                    setState(() {});
                  },
                ),
              ),
            ),

            Expanded(
              child: ListView.builder(
                  itemCount: chatList.length,
                  itemBuilder: (context, index){
                return  GestureDetector(
                  onTap: (){
                    push(context: context, screen: user_chat_screen());
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                    child: Row(

                      children: [
                        hSizedBox20,
                        ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Image.asset(chatList[index]['image'], height: 50, width: 50, fit: BoxFit.cover,)),

                        hSizedBox10,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            ParagraphText(chatList[index]['name'], color: MyColors.blackColor, fontSize: 13, fontWeight: FontWeight.w700, ),
                            ParagraphText(chatList[index]['msg'], color: MyColors.body_font_color, fontSize: 9,),


                          ],
                        ),

                        Spacer(),
                        ParagraphText(chatList[index]['time'], color: MyColors.grey2, fontSize: 10, fontWeight: FontWeight.w600, ),
                        hSizedBox05,
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          backgroundColor: MyColors.primaryColor,
          onPressed: () {
            new_chat_dialog(context);
          },
        ),
      ),
    );
  }
}
