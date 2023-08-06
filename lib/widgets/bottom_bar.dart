import 'package:flutter/material.dart';
import 'package:hrm_app/screens/attendance_screen.dart';
import 'package:hrm_app/screens/chat_list.dart';
import 'package:hrm_app/screens/project_screen.dart';
import 'package:hrm_app/screens/task_screen.dart';
import '../constants/colors.dart';
import '../constants/images_url.dart';
import '../screens/home_screen.dart';



class bottom_bar extends StatefulWidget {

  bottom_bar({required Key key}) : super(key: key);

  @override
  State<bottom_bar> createState() => bottom_barState();
}

class bottom_barState extends State<bottom_bar> {
  int _selectedIndex = 0;


  void onItemTapped(int index) {
    setState(() {
      print('pressed $_selectedIndex index');
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: [
            home_screen(),
            task_screen(),
            chat_list(),
            project_screen(),
            attendance_screen(),
          ].elementAt(_selectedIndex),
        ),

        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 15.0, // soften the shadow
                spreadRadius: 5.0, //extend the shadow
                offset: Offset(
                  5.0, // Move to right 5  horizontally
                  5.0, // Move to bottom 5 Vertically
                ),
              )
            ]
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.white,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            selectedFontSize: 10,
            elevation: 0,
            unselectedFontSize: 10,
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                label: 'Dashboard',
                icon: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ImageIcon(
                    AssetImage(MyImages.home),
                    size: 25,
                  ),
                ),
                activeIcon: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ImageIcon(
                    AssetImage(MyImages.home_fill),
                    size: 25,
                  ),
                ),
                backgroundColor:MyColors.whiteColor,
              ),
              BottomNavigationBarItem(
                label: 'Tasks',
                icon: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ImageIcon(
                    AssetImage(MyImages.task),
                    size: 25,
                  ),
                ),
                activeIcon: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ImageIcon(
                    AssetImage(MyImages.task_fill),
                    size: 25,
                  ),
                ),
                backgroundColor:MyColors.whiteColor,
              ),


              BottomNavigationBarItem(
                label: 'Chats',
                icon: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ImageIcon(
                    AssetImage(MyImages.chat),
                    size: 25,
                  ),
                ),
                activeIcon: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: ImageIcon(
                    AssetImage(MyImages.chat_fill),
                    size: 25,
                  ),
                ),
                backgroundColor:MyColors.whiteColor,
              ),

              BottomNavigationBarItem(
                label: 'Projects',
                icon: Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: ImageIcon(
                    AssetImage(MyImages.project),
                    size: 28,
                  ),
                ),
                activeIcon: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: ImageIcon(
                    AssetImage(MyImages.project_fill),
                    size: 28,
                  ),
                ),
                backgroundColor:MyColors.whiteColor,
              ),
              BottomNavigationBarItem(
                label: 'HR',
                icon: Padding(
                  padding: const EdgeInsets.fromLTRB(7,3,0,3),
                  child: ImageIcon(
                    AssetImage(MyImages.user),
                    size: 25,
                  ),
                ),
                activeIcon: Padding(
                  padding: const EdgeInsets.fromLTRB(7,3,0,3),
                  child: ImageIcon(
                    AssetImage(MyImages.user_fill),
                    size: 25,
                  ),
                ),
                backgroundColor:MyColors.whiteColor,
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor:  MyColors.primaryColor,
            onTap: onItemTapped,
          ),
        ),
      );

  }
}