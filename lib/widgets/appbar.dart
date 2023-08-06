import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/sized_box.dart';
import 'CustomTexts.dart';


AppBar appBar(
    {String? title,
    bool showLogoutButton = false,
    bool implyLeading = true,
      Widget? preTitle,
    Function()? onBackButtonTap,
      PreferredSizeWidget? bottom,
      Color? iconColor,
    required BuildContext context,
    List<Widget>? actions}) {
  return AppBar(
    toolbarHeight: 70,
    automaticallyImplyLeading: false,
    titleSpacing: implyLeading ? 10 : 16,
    backgroundColor: Colors.transparent,
    centerTitle: false,
    elevation: 0,
    bottom: bottom,
    title: title == null
        ? null
        : preTitle != null ? Row(
          children: [
            preTitle ,
            hSizedBox10,
            ParagraphText(title,
                fontSize:15,
                fontFamily: 'poppins',
      fontWeight: FontWeight.w600,
      color:  MyColors.blackColor,
              ),
          ],
        )
        :   Padding(
          padding: const EdgeInsets.only(top: 10),
          child: ParagraphText(title,
      fontSize:15,
      fontFamily: 'poppins',
      fontWeight: FontWeight.w700,
      color: MyColors.blackColor,
    ),
        ),
    leading: implyLeading
        ? Padding(
          padding: const EdgeInsets.only(top: 20, left: 17, bottom: 10),
          child: Container(
            alignment: Alignment.center,
            height: 25, width: 25,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(1000),
          color:iconColor ?? MyColors.primaryColor
      ),
            child: IconButton(
                icon: const Icon(
                  CupertinoIcons.chevron_back,
                  color: MyColors.whiteColor,
                  size: 25,
                ),
                onPressed: onBackButtonTap != null
                    ? onBackButtonTap
                    : () {
                        Navigator.pop(context);
                      },
              ),
          ),
        )
        : null,
    actions: showLogoutButton
        ? [
            hSizedBox05,
            Center(
              child: GestureDetector(
                onTap: ()async{

                },
                child: Text(
                  'logout',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            hSizedBox05,
          ]
        : actions,
  );
}

