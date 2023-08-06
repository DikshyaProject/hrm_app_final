import 'package:flutter/material.dart';
import 'package:hrm_app/constants/sized_box.dart';
import 'package:hrm_app/widgets/appbar.dart';

import '../constants/colors.dart';
import '../widgets/CustomTexts.dart';


class expense_screen extends StatefulWidget {
  const expense_screen({Key? key}) : super(key: key);

  @override
  State<expense_screen> createState() => _expense_screenState();
}

class _expense_screenState extends State<expense_screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.backgroundColor,
      appBar: appBar(context: context, title: 'Expense'),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          vSizedBox20,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ParagraphText('Transactions',  fontWeight: FontWeight.w600, ),
          ),

          Expanded(
            child: ListView.builder(
                itemCount: 15,
                itemBuilder: (context, index){
              return Padding(
                padding: const EdgeInsets.fromLTRB(20,5,20,12),
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
                  child:  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(child: ParagraphText('Monday', fontSize: 13, fontWeight: FontWeight.w600,)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ParagraphText('Tea & Beverages', fontSize: 11, fontWeight: FontWeight.w600, color: MyColors.orange1, ),
                                  ParagraphText('150 \$', fontSize: 11, fontWeight: FontWeight.w600, color: MyColors.green3, ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  ParagraphText('Snacks', fontSize: 11, fontWeight: FontWeight.w600, color: MyColors.orange1, ),
                                  ParagraphText('250 \$', fontSize: 11, fontWeight: FontWeight.w600, color: MyColors.green3, ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          )

        ],
      ),
    );
  }
}
