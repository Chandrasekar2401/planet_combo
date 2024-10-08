import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:planetcombo/common/constant.dart';
import 'package:planetcombo/common/widgets.dart';

class CustomDrawer extends StatelessWidget {
  final Function(int) onItemTap;
  final int selectedIndex;

  Constants constant = Constants();

  CustomDrawer({super.key, required this.onItemTap, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              height: 220,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.transparent),
                boxShadow: [],
              ),
              child: Image.asset('assets/images/headletters.png'),
            ),
            _createDrawerItem(
              icon: Icons.home_outlined,
              text: 'Home',
              onTap: () => onItemTap(0),
              isSelected: selectedIndex == 0,
            ),
            _createDrawerItem(
              svgIcon: 'assets/svg/planet.svg',
              text: 'Services',
              onTap: () => onItemTap(1),
              isSelected: selectedIndex == 1,
            ),
            _createDrawerItem(
              svgIcon: 'assets/svg/article.svg',
              text: 'Articles',
              onTap: () => onItemTap(2),
              isSelected: selectedIndex == 2,
            ),
            _createDrawerItem(
              svgIcon: 'assets/svg/about1.svg',
              text: 'About us',
              onTap: () => onItemTap(3),
              isSelected: selectedIndex == 3,
            ),
            _createDrawerItem(
              svgIcon: 'assets/svg/contact1.svg',
              text: 'Contact',
              onTap: () => onItemTap(4),
              isSelected: selectedIndex == 4,
            ),
            const SizedBox(height: 10),
            Padding(padding: EdgeInsets.all(12),
            child: commonBoldText(text: '© 2024 Planet Combo - All Rights Reserved.', fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _createDrawerItem({
    String? svgIcon,
    IconData? icon,
    required String text,
    required GestureTapCallback onTap,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 15),
      child: ListTile(
        leading: svgIcon == null ? Icon(
          icon,
          size: 21,
          color: isSelected ? constant.appPrimaryColor : Colors.black,
        ) :
        SvgPicture.asset(
          svgIcon,
          colorFilter: ColorFilter.mode(
            isSelected ? constant.appPrimaryColor : Colors.black,
            BlendMode.srcIn,
          ),
          width: 21,
          height: 21,
        ),
        title: Text(
          text,
          style: GoogleFonts.lexend(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isSelected ? constant.appPrimaryColor  : Colors.black,
          ),
        ),
        selected: isSelected,
        onTap: onTap,
      ),
    );
  }
}