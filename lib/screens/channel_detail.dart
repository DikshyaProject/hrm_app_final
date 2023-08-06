import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/images_url.dart';
import '../constants/sized_box.dart';
import '../widgets/CustomTexts.dart';
import '../widgets/appbar.dart';
import '../widgets/round_edged_button.dart';


class channel_detail extends StatefulWidget {
  String title;
  channel_detail({Key? key, required this.title, }) : super(key: key);

  @override
  State<channel_detail> createState() => _channel_detailState();
}

class _channel_detailState extends State<channel_detail> {
  List mediaList =[
    MyImages.media1,
    MyImages.media2,
    MyImages.media3,
    MyImages.media4,
    MyImages.media5,
    MyImages.media6,
    MyImages.media7,
    MyImages.media8,
    MyImages.media9,
  ];
  bool isComplete = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: MyColors.backgroundColor,
        appBar: appBar(context: context, title: widget.title,  ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: MyColors.box1,
                width: MediaQuery.of(context).size.width,
                child:  Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: ParagraphText('About Us', fontSize: 15, fontWeight: FontWeight.w600, color: MyColors.primaryColor,),
                ),
              ),
              vSizedBox10,

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: ParagraphText("Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.",
                fontSize: 11, color: MyColors.hintColor,
                ),
              )  ,

              vSizedBox20,

              Container(
                color: MyColors.box1,
                width: MediaQuery.of(context).size.width,
                child:  Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: ParagraphText('Media', fontSize: 15, fontWeight: FontWeight.w600, color: MyColors.primaryColor,),
                ),
              ),

              vSizedBox10,


              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: GridView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: mediaList.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:  3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 5,
                    childAspectRatio: MediaQuery.of(context).size.height/MediaQuery.of(context).size.width*0.8,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    return  ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(mediaList[index], fit: BoxFit.cover,),
                    );
                  },
                ),
              ),

              vSizedBox10,

              Container(
                color: MyColors.box1,
                width: MediaQuery.of(context).size.width,
                child:  Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: ParagraphText('Doc', fontSize: 15, fontWeight: FontWeight.w600, color: MyColors.primaryColor,),
                ),
              ),
              vSizedBox10,


              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Image.asset(MyImages.doc, height: 50, )
                        ),
                      );
                    }),
              ),
            ],
          ),
        )
    );
  }
}
