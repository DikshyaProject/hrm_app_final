import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../constants/colors.dart';

class DropDown extends StatefulWidget {
  final String label;
  final Color? labelcolor;
  final Color? borderColor;
  final double? fontsize;
  final double? borderRadius;
  final double? width;
  final double? height;
  final double? dropdownwidth;
  final List<String> items;
  final bool islabel;
  late final String? selectedValue;
  final Function(String?)? onChange;


   DropDown({
    Key? key,
    this.width=100,
    this.height=26,
    this.dropdownwidth=100,
    this.selectedValue,
    this.label = 'hii',
    this.labelcolor = MyColors.blackColor,
    this.borderColor = Colors.transparent,
    this.fontsize = 15,
    this.borderRadius ,
    this.items = const [
      'All',
      'Option 1',
      'Option 2',
      'Option 3',
      'Option 4',
    ],
    this.islabel = true,
    this.onChange,

  }) : super(key: key);

  @override
  State<DropDown> createState() => _DropDownState();
}

class _DropDownState extends State<DropDown> {
  // final List<String> items = [
  //   'All',
  //   'Option 1',
  //   'Option 2',
  //   'Option 3',
  //   'Option 4',
  // ];


  @override
  Widget build(BuildContext context) {

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonHideUnderline(
            child: DropdownButton2(
              isExpanded: true,
              hint: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 15,
                    color: MyColors.hintColor,
                    fontWeight: FontWeight.w400
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              items: widget.items
                  .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ))
                  .toList(),
              value: widget.selectedValue,
              onChanged:widget.onChange ??
                  (value) {
                setState(() {
                  widget.selectedValue = value as String?;
                });
              },
              icon: const Icon(
                Icons.expand_more_outlined,
              ),
              iconSize:14,
              iconEnabledColor: Colors.grey,
              iconDisabledColor: Colors.grey,
              buttonHeight:widget.height,
              buttonWidth: widget.width,
              // MediaQuery.of(context).size.width,
              buttonPadding: const EdgeInsets.only(left:10, right:10),
              buttonDecoration: BoxDecoration(
                // boxShadow: [shadow],
                borderRadius: BorderRadius.circular(widget.borderRadius ?? 5),
                // border: Border.all(
                //   color: MyColors.primaryColor,
                // ),
                // color: MyColors.primaryColor,
                color: MyColors.whiteColor,
              ),
              buttonElevation: 0,
              itemHeight: 30,
              itemPadding: const EdgeInsets.only(left: 14, right: 14),
              dropdownMaxHeight: 200,
              dropdownWidth:widget.dropdownwidth,
              // MediaQuery.of(context).size.width - 32,
              dropdownPadding: null,
              dropdownDecoration: BoxDecoration(
                // boxShadow: [shadow],
                borderRadius: BorderRadius.circular(widget.borderRadius ?? 5),
                color: MyColors.whiteColor,
                border: Border.all(
                  color: widget.borderColor?? MyColors.primaryColor,
                ),

              ),
              dropdownElevation: 0,
              scrollbarRadius: const Radius.circular(40),
              scrollbarThickness: 6,
              scrollbarAlwaysShow: true,
              offset: const Offset(0, 0),
            ),
          ),
        ],
      ),
    );
  }
}
