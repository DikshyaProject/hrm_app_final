import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/images_url.dart';
import '../constants/sized_box.dart';
import '../functions/navigation_functions.dart';
import '../widgets/CustomTexts.dart';
import '../widgets/custom_text_field.dart';
import 'channel_detail.dart';


class channel_chats extends StatefulWidget {
  String title;
  String members;
  channel_chats({Key? key, required this.title, required this.members}) : super(key: key);

  @override
  State<channel_chats> createState() => _channel_chatsState();
}

class _channel_chatsState extends State<channel_chats> {
  TextEditingController messageController = TextEditingController();
  List chats=[];
  TextEditingController search = TextEditingController();
  bool isSearch=true;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar:
      isSearch == true?
      AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: InkWell(
              onTap: (){
                push(context: context, screen: channel_detail(title: widget.title,));
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ParagraphText(widget.title, fontSize: 15, fontWeight: FontWeight.w600, color: MyColors.blackColor,),
                  ParagraphText('${widget.members } Member', fontSize: 12,  color: MyColors.hintColor,),
                ],
              ),
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
                padding: const EdgeInsets.only(top: 20 , right: 15),
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
