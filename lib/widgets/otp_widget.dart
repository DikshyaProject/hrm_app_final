import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../constants/toast.dart';


class OtpVerification extends StatefulWidget {
  final Color textColor;
  final Color bgColor;
  final Color borderColor;
  final String navigationFrom;
  String correctOtp;
  Map<String, dynamic>? userDetails;
  final Function load;
  final Function() wrongOtp;
  TextEditingController textEditingController;

  OtpVerification({
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
    required this.navigationFrom,
    required this.correctOtp,
    required this.textEditingController,
    this.userDetails,
    required this.load,
    required this.wrongOtp,
  });

  @override
  _OtpVerificationState createState() => _OtpVerificationState();
}

class _OtpVerificationState extends State<OtpVerification> {
  // TextEditingController textEditingController = TextEditingController();
  StreamController<ErrorAnimationType>? errorController;

  bool hasError = false;
  String currentText = "";
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  @override
  void dispose() {
    errorController!.close();

    super.dispose();
  }

  // snackBar Widget
  snackBar(String? message) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message!),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Form(
          key: formKey,
          child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 0.0, horizontal: 0),
              child: PinCodeTextField(
                appContext: context,
                pastedTextStyle: TextStyle(
                  color: Colors.green,
                  backgroundColor: Colors.yellow,
                  fontWeight: FontWeight.bold,
                ),

                length: 4,

                animationType: AnimationType.fade,
                validator: (v) {
                  if (v!.length < 3) {
                    // return "I'm from validator";
                  } else {
                    return null;
                  }
                },
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(5),
                  fieldHeight: 55,
                  fieldWidth: 55,
                  activeFillColor: widget.bgColor,
                  selectedFillColor: widget.bgColor,
                  inactiveFillColor: widget.bgColor,
                  activeColor: widget.borderColor,
                  inactiveColor: widget.borderColor,
                  selectedColor: widget.borderColor,
                ),
                cursorColor: widget.textColor,
                animationDuration: Duration(milliseconds: 300),
                enableActiveFill: true,
                errorAnimationController: errorController,
                controller: widget.textEditingController,
                keyboardType: TextInputType.number,
                onCompleted: (v) {
                  print("Completed");
                },
                onChanged: (value) async {
                  print(value);
                  setState(() {
                    currentText = value;
                  });
                  if (currentText == widget.correctOtp) {
                    widget.load();

                  } else if (currentText.length == 4) {
                    currentText = '';
                    widget.textEditingController.clear();
                    widget.wrongOtp();
                    setState(() {});
                    toast('Wrong Otp entered');
                  }
                  setState(() {});
                },
                beforeTextPaste: (text) {
                  print("Allowing to paste $text");
                  //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                  //but you can show anything you want here, like your pop up saying wrong paste format or etc
                  return true;
                },
              )),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            hasError ? "*Please fill up all the cells properly" : "",
            style: TextStyle(
                color: Colors.red, fontSize: 12, fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }
}
