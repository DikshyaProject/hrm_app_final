import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hrm_app/widgets/round_edged_button.dart';
import '../constants/colors.dart';
import '../constants/images_url.dart';
import '../constants/sized_box.dart';
import 'CustomTexts.dart';
import 'custom_text_field.dart';

TextEditingController name = TextEditingController();
TextEditingController message = TextEditingController();


Future new_chat_dialog (BuildContext context){
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: AlertDialog(
                scrollable: true,
                backgroundColor:   MyColors.whiteColor,
                insetPadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                content: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: MyColors.whiteColor,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        vSizedBox10,
                        ParagraphText('Name', fontSize: 15,),
                        CustomTextField(
                          controller: name,
                          hintText: 'Name',
                          borderColor: MyColors.grey1.withOpacity(0.5),
                        ),


                        vSizedBox10,


                        ParagraphText('Message', fontSize: 15,),
                        CustomTextField(
                          controller: message,
                          hintText: 'Message',
                          borderColor: MyColors.grey1.withOpacity(0.5),
                        ),

                        RoundEdgedButton(text: 'Send', onTap: (){
                          Navigator.pop(context);
                        },)

                      ],
                    ),
                  ),
                ),
              ),
            );
          }
      );
    },
  );
}

