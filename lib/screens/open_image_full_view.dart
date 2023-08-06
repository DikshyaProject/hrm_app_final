import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/colors.dart';

class open_image_full_view extends StatefulWidget {
  String imageUrl;
  open_image_full_view({Key? key, required this.imageUrl}) : super(key: key);

  @override
  State<open_image_full_view> createState() => _open_image_full_viewState();
}

class _open_image_full_viewState extends State<open_image_full_view> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CachedNetworkImage(
            placeholder: (context, url) => Center(
              child: CupertinoActivityIndicator(
                radius: 12,
                color: MyColors.blackColor,
              ),
            ),
            imageUrl: widget.imageUrl,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.contain,
          ),
          Positioned(
            top: 40,
            right: 10,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                height: 30,
                width: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(color: MyColors.blackColor)),
                child: Icon(
                  CupertinoIcons.multiply,
                  color: MyColors.blackColor,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
