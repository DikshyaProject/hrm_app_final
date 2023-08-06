import 'package:flutter/material.dart';


//
// class MainHeadingText extends StatelessWidget {
//   final String text;
//   final Color? color;
//   final double? fontSize;
//   final FontWeight? fontWeight;
//   final String? fontFamily;
//   final TextAlign? textAlign;
//   final double? height;
//
//   const MainHeadingText(this.text,{
//     Key? key,
//     this.color,
//     this.fontSize,
//     this.fontWeight,
//     this.fontFamily = 'poppins',
//     this.textAlign,
//     this.height
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       text,
//       textAlign: textAlign,
//       style: TextStyle(
//         color: color,
//         fontWeight:fontWeight??FontWeight.w600,
//         fontSize: fontSize??28,
//         fontFamily: fontFamily,
//         height: height
//       ),
//     );
//   }
// }
//
// class AppBarHeadingText extends StatelessWidget {
//   final String text;
//   final Color? color;
//   final double? fontSize;
//   final FontWeight? fontWeight;
//   final String? fontFamily;
//   final TextAlign? textAlign;
//   const AppBarHeadingText({
//     Key? key,
//     required this.text,
//     this.color,
//     this.fontSize,
//     this.fontWeight,
//     this.fontFamily,
//     this.textAlign,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<MyColors> (builder: (context, colorProvider, child) {
//       return Text(
//         text,
//         textAlign: textAlign,
//         style: TextStyle(
//             overflow: TextOverflow.ellipsis,
//             color: color ?? colorProvider.whiteColor,
//             fontWeight: fontWeight ?? FontWeight.w400,
//             fontSize: fontSize ?? 22,
//             fontFamily: fontFamily
//         ),
//       );
//     });
//   }
// }
//
// class SubHeadingText extends StatelessWidget {
//   final String text;
//   final Color? color;
//   final double? fontSize;
//   final FontWeight? fontWeight;
//   final String fontFamily;
//   final TextAlign textAlign;
//   final bool underlined;
//   const SubHeadingText(this.text,{
//     Key? key,
//     this.color,
//     this.fontSize,
//     this.fontWeight,
//     this.fontFamily ='fontFamily',
//     this.textAlign=TextAlign.start,
//     this.underlined = false,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       text,
//       textAlign: textAlign,
//       style: TextStyle(
//           color: color,
//           fontWeight:fontWeight??FontWeight.w500,
//           fontSize: fontSize??18,
//           fontFamily: fontFamily,
//         decoration:underlined? TextDecoration.underline:null,
//       ),
//     );
//   }
// }

class ParagraphText extends StatelessWidget {
  final  TextOverflow? overflow;
  final String text;
  final Color? color;
  final double? fontSize;
  final int? maxline;
  final FontWeight? fontWeight;
  final String? fontFamily;
  final TextAlign? textAlign;
  final bool underlined;
  final double? lineHeight;
  final FontStyle? fontStyle;
  const ParagraphText(this.text,{
    Key? key,

    this.color,
    this.fontSize,
    this.maxline,
    this.fontWeight,
    this.fontFamily='poppins',
    this.textAlign,
    this.underlined = false,
    this.lineHeight,
    this.fontStyle,
    this.overflow
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
      return Text(
        overflow: overflow,
        text,
        textAlign: textAlign ?? TextAlign.start,
        maxLines: maxline,
        style: TextStyle(
          color: color,
          fontWeight: fontWeight ?? FontWeight.w400,
          fontSize: fontSize ?? 16,
          height: lineHeight,
          fontFamily: fontFamily,
          fontStyle: fontStyle,
          decoration: underlined ? TextDecoration.underline : null,
        ),
      );
  }
}


