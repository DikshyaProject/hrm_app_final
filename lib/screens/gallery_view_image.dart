import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hrm_app/constants/sized_box.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../constants/colors.dart';

class gallery_view_image extends StatefulWidget {
  final List? images;
  final int imgImdex;
  bool? fromMembers;

  gallery_view_image(
      {Key? key,
      required this.images,
      required this.imgImdex,
      this.fromMembers})
      : super(key: key);

  @override
  State<gallery_view_image> createState() => _GalleryImagesState();
}

class _GalleryImagesState extends State<gallery_view_image> {
  PageController controller = PageController();

  @override
  void initState() {
    openPicture();
    super.initState();
  }

  openPicture() {
    Future.delayed(Duration(microseconds: 500), () {
      controller.jumpToPage(widget.imgImdex);
    });
  }

  next() {
    controller.nextPage(
        duration: Duration(microseconds: 200), curve: Curves.easeIn);
  }

  previous() {
    controller.previousPage(
        duration: Duration(microseconds: 200), curve: Curves.easeIn);
  }

  var inventoryImage;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PhotoViewGallery.builder(
            itemCount: widget.images?.length,
            pageController: controller,
            builder: (context, index) {
              if (widget.fromMembers == true) {
                inventoryImage = widget.images?[index]['media'];
              } else {
                inventoryImage = widget.images?[index]['file'];
              }

              return PhotoViewGalleryPageOptions(
                imageProvider: CachedNetworkImageProvider(inventoryImage),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.contained * 4,
              );
            },
          ),
          Positioned(
            bottom: 20,
            left: 70,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    previous();
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100)),
                    child: Icon(
                      CupertinoIcons.chevron_back,
                      color: MyColors.blackColor,
                      size: 30,
                    ),
                  ),
                ),
                hSizedBox80,
                hSizedBox80,
                GestureDetector(
                  onTap: () {
                    next();
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(100)),
                    child: Icon(
                      CupertinoIcons.chevron_right,
                      color: MyColors.blackColor,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
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
                    borderRadius: BorderRadius.circular(100)),
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
