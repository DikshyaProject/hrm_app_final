// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:flutter/material.dart';
// import '../constants/colors.dart';
//
// class CustomDropdownButton<T> extends StatelessWidget {
//   final String text;
//   final bool isLabel;
//   final Color labelColor;
//   final List<T> items;
//   final T? selectedItem;
//   final String hint;
//   final BoxBorder? border;
//   final void Function(T? value)? onChanged;
//   final double margin;
//   final double? height;
//   final double labelFontSize;
//   final String itemMapKey;
//   final Color fieldColor;
//   final CrossAxisAlignment crossAxisAlignment;
//   const CustomDropdownButton({Key? key,
//     this.margin = 16,
//     this.labelFontSize = 15,
//     required this.text,
//     this.selectedItem,
//     this.labelColor =Colors.black,
//     required this.items,
//     required this.hint,
//     this.onChanged,
//     this.height,
//     this.border,
//     this.isLabel = true,
//     this.itemMapKey = 'name',
//     this.fieldColor=Colors.transparent,
//     this.crossAxisAlignment = CrossAxisAlignment.start
//
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: crossAxisAlignment,
//       children: [
//
//
//         Text(text, style: TextStyle(fontSize: labelFontSize, color: labelColor, fontFamily: 'poppins', fontWeight: FontWeight.w600),),
//         Container(
//           height: height?? MediaQuery.of(context).size.height*0.06,
//           margin: EdgeInsets.symmetric(vertical: margin),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(10),
//             color: MyColors.whiteColor,
//             boxShadow:[
//               BoxShadow(
//                 color: MyColors.grey1.withOpacity(0.8), //color of shadow
//                 spreadRadius: 0.2,
//                 blurRadius: 3,
//                 offset: Offset(0, 0),
//               ),
//             ],
//           ),
//           padding: EdgeInsets.only(left: 0, top: 0),
//           child:  DropdownSearch<T>(
//             popupBackgroundColor: Colors.transparent,
//             popupElevation: 0,
//             // dro
//             dropdownSearchDecoration: InputDecoration.collapsed(
//
//                 hintText: '  $hint',
//                 hintStyle: TextStyle(color: Color(0xFF999999), fontFamily: 'light')
//             ),
//             mode: Mode.MENU,
//             items: items,
//
//             popupItemBuilder: (context,value,a){
//               print('the value is ${value.toString()}');
//               try{
//                 return Container(
//                   height: height?? MediaQuery.of(context).size.height*0.06,
//
//                   decoration: BoxDecoration(
//                       color:Colors.white,
//                       border: Border(bottom: BorderSide(color: Colors.black12))
//                   ),
//                   padding: const EdgeInsets.all(8.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text((value as Map)['${itemMapKey}']),
//                       // Divider(),
//                     ],
//                   ),
//                 );
//
//               }catch(e){
//                 print('Error in catch block  5d55 $e');
//               }
//               return Container(
//                 height: height?? MediaQuery.of(context).size.height*0.06,
//                 decoration: BoxDecoration(
//                     color:Colors.white,
//                     border: Border(bottom: BorderSide(color: Colors.black12))
//                 ),
//                 padding: const EdgeInsets.all(8.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Text(value.toString()),
//                     // Divider(),
//                   ],
//                 ),
//               );
//
//
//             },
//             itemAsString: (T? value){
//               print('this is called');
//               try{
//                 return ' ${(value as Map)['${itemMapKey}']}';
//               }catch(e){
//                 print('Error in catch block  555 $e');
//               }
//               return '  ${value.toString()}';
//             },
//             selectedItem: selectedItem,
//
//             onChanged: onChanged,
//           ),
//         ),
//       ],
//     );
//   }
// }
//
//
// // import 'package:dropdown_search/dropdown_search.dart';
// // import 'package:flutter/material.dart';
// // import '../constants/colors.dart';
// //
//
// // class CustomDropdownButton extends StatelessWidget {
// //   final String text;
// //   final Color labelColor;
// //   final List items;
// //   final String hint;
// //   final BoxBorder? border;
// //   final Function(dynamic value)? onChanged;
// //   final double margin;
// //   final double labelFontSize;
// //   final dynamic selectedItem;
// //
// //   const CustomDropdownButton({Key? key,
// //     this.margin = 16,
// //     this.labelFontSize = 18,
// //     required this.text,
// //     this.labelColor = MyColors.secondaryColor,
// //     required this.items,
// //     required this.hint,
// //     this.onChanged,
// //     this.border,
// //     this.selectedItem,
// //   }) : super(key: key);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(text, style: TextStyle(fontSize: labelFontSize, color: labelColor, fontFamily: 'bold'),),
// //         Container(
// //           height: 60,
// //           margin: EdgeInsets.symmetric(vertical: margin),
// //           decoration: BoxDecoration(
// //               color: Color(0xFEF0F0F0),
// //               border: Border.all(color: Color(0xFEF0F0F0)),
// //               borderRadius: BorderRadius.circular(8)),
// //           padding: EdgeInsets.only(left: 10, top: 5),
// //           child: DropdownSearch(
// //             selectedItem: selectedItem,
// //             dropdownSearchDecoration: InputDecoration.collapsed(
// //                 hintText: hint,
// //                 hintStyle: TextStyle(color: Color(0xFEA1A1A1), fontFamily: 'light')
// //             ),
// //             mode: Mode.MENU,
// //             items: items,
// //             onChanged: onChanged,
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }
