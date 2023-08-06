import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hrm_app/constants/sized_box.dart';
import 'package:hrm_app/functions/navigation_functions.dart';
import 'package:hrm_app/screens/profile_screen.dart';
import 'package:hrm_app/widgets/custom_text_field.dart';
import '../constants/colors.dart';
import '../constants/images_url.dart';
import '../widgets/CustomTexts.dart';

class user_chat_screen extends StatefulWidget {
  const user_chat_screen({Key? key}) : super(key: key);

  @override
  State<user_chat_screen> createState() => _user_chat_screenState();
}

class _user_chat_screenState extends State<user_chat_screen> {
  TextEditingController messageController = TextEditingController();
  TextEditingController search = TextEditingController();
  bool isSearch=true;
  List chats=[];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar:
      isSearch == true?
      AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: InkWell(
          onTap: (){
            push(context: context, screen: profile_screen());
          },
          child: Row(
            children: [
          Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.asset(MyImages.boy1, height: 45, width: 45, fit: BoxFit.cover,),),
              ),

              hSizedBox10,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ParagraphText('John Smith', fontSize: 13, fontWeight: FontWeight.w600, color: MyColors.blackColor,),
                  ParagraphText('Employee ID', fontSize: 10,  color: MyColors.blackColor,),
                ],
              ),
            ],
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(top: 12, left: 12),
          child: Container(
            alignment: Alignment.center,
            height: 25, width: 25,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1000),
                color: MyColors.green4
            ),
            child: IconButton(
              icon:  Icon(
                CupertinoIcons.chevron_back,
                color: MyColors.whiteColor,
                size: 25,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
            actions: [
              InkWell(
                onTap: (){
                  isSearch=false;
                  setState(() {});
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 5 , right: 15),
                  child: Icon(CupertinoIcons.search, color: MyColors.blackColor,),
                ),
              )
            ]
      ):
      AppBar(
        centerTitle: true,
        backgroundColor: MyColors.whiteColor,
        elevation: 0.0,
        leading:Padding(
          padding: const EdgeInsets.only(top: 12, left: 12),
          child: Container(
            alignment: Alignment.center,
            height: 25, width: 25,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1000),
                color: MyColors.primaryColor
            ),
            child: IconButton(
              icon:  Icon(
                CupertinoIcons.chevron_back,
                color: MyColors.whiteColor,
                size: 25,
              ),
              onPressed: () {
                isSearch = true;
                setState(() {});
              },
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(65),
          child:
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CustomTextField(
                controller: search,
                hintText: 'Search here...',
                onChanged: (val){
                  setState(() {});
                },
              ),
            )
        ),

      ),

      body: Container(
        height: MediaQuery.of(context).size.height - 50,
        child: Stack(
          children: [

            if (chats.length == 0)
              Center(
                child: ParagraphText(
                  'Type a message to start conversation....',
                ),
              ),


            ListView.builder(
              itemCount: chats.length,
              reverse: true,
              padding: EdgeInsets.only(bottom: 66),
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Stack(
                        children: [
                          Container(
                            padding: EdgeInsets.only(
                                top: 16, left: 16, bottom: 16, right: 60),
                            decoration: BoxDecoration(
                                color: MyColors.grey3,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(15),
                                  topLeft: Radius.circular(15),
                                  bottomLeft: Radius.circular(15),
                                )),
                            child: ParagraphText(chats[index], color: MyColors.grey5),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: ParagraphText('12:34 pm', fontSize: 10, color: Colors.black.withOpacity(0.5)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );

              },
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: MyColors.grey4),
                child: TextField(
                  clipBehavior: Clip.none,
                  style: TextStyle(color: MyColors.blackColor),
                  controller: messageController,
                  decoration: InputDecoration(
                    suffixIcon: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, // added line
                      mainAxisSize: MainAxisSize.min, // added line
                      children: [

                        IconButton(
                            onPressed: () async {
                              chats.add(messageController.text);
                              messageController.text = "";
                              setState(() {});
                            },
                            icon: Image.asset(MyImages.send, height: 25, color: MyColors.receivedChatColor,)),
                      ],
                    ),
                    prefixIcon:  Row(
                      mainAxisSize: MainAxisSize.min, // added line
                      children: [
                        hSizedBox05,
                        InkWell(
                            onTap: () async {

                            },
                            child: Image.asset(MyImages.attach, height: 25, color: MyColors.receivedChatColor,)),
                        hSizedBox05,
                        InkWell(
                            onTap: () async {

                            },
                            child: Image.asset(MyImages.emoji, height: 25, color: MyColors.receivedChatColor,)),
                        hSizedBox05,
                        InkWell(
                            onTap: () async {

                            },
                            child: Image.asset(MyImages.link, height: 25, color: MyColors.receivedChatColor,)),
                        hSizedBox10,
                      ],
                    ),
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 20, horizontal: 16),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.transparent, width: 1),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.transparent, width: 1),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    hintText: 'Type a message here...',
                    hintStyle: TextStyle(
                        fontSize: 12, color: MyColors.grey5),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
