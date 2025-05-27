import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/constant.dart';
import '../../common/widgets.dart';
import '../../controllers/localization_controller.dart';
import '../../controllers/appLoad_controller.dart';
import '../web/web_home.dart';

class DashboardDrawer extends StatelessWidget {
  final Function(int) onItemTap;
  final int selectedIndex;
  final bool isLoggedIn;
  final BuildContext context;

  final Constants constant = Constants();

  DashboardDrawer({
    super.key,
    required this.onItemTap,
    required this.selectedIndex,
    required this.context,
    this.isLoggedIn = true
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          children: [
            // Header with blur effect
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: Image.asset(
                      'assets/images/headletters.png',
                      height: 260,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.grey.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            // Menu Items
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Column(
                  children: [
                    _createDrawerItem(
                      icon: Icons.dashboard_outlined,
                      text: isLoggedIn ? 'Dashboard' : 'Home',
                      onTap: () => onItemTap(0),
                      isSelected: selectedIndex == 0,
                    ),
                    _createDrawerItem(
                      svgIcon: 'assets/svg/article.svg',
                      text: 'Articles',
                      onTap: () => onItemTap(1),
                      isSelected: selectedIndex == 1,
                    ),
                    _createDrawerItem(
                      svgIcon: 'assets/svg/about1.svg',
                      text: 'About us',
                      onTap: () => onItemTap(2),
                      isSelected: selectedIndex == 2,
                    ),
                    _createDrawerItem(
                      svgIcon: 'assets/svg/contact1.svg',
                      text: 'Contact',
                      onTap: () => onItemTap(3),
                      isSelected: selectedIndex == 3,
                    ),

                    const Spacer(),

                    // Logout section with divider
                    if (isLoggedIn) ...[
                      Container(
                        height: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        color: Colors.grey.withOpacity(0.2),
                      ),
                      _createDrawerItem(
                        icon: Icons.logout_outlined,
                        text: 'Logout',
                        onTap: () => showLogoutDialog(),
                        isSelected: false,
                        isLogout: true,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Footer with divider
            Column(
              children: [
                Container(
                  height: 1,
                  color: Colors.grey.withOpacity(0.1),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Text(
                    '© 2024 Planet Combo - All Rights Reserved.',
                    style: GoogleFonts.lexend(
                      fontSize: 11,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
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
    bool isLogout = false,
  }) {
    final Color itemColor = isLogout
        ? Colors.red[600]!
        : isSelected
        ? constant.appPrimaryColor
        : Colors.grey[700]!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected ? constant.appPrimaryColor.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: constant.appPrimaryColor.withOpacity(0.2), width: 1)
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        leading: svgIcon == null
            ? Icon(
          icon,
          size: 22,
          color: itemColor,
        )
            : SvgPicture.asset(
          svgIcon,
          colorFilter: ColorFilter.mode(
            itemColor,
            BlendMode.srcIn,
          ),
          width: 22,
          height: 22,
        ),
        title: Text(
          text,
          style: GoogleFonts.lexend(
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: itemColor,
            letterSpacing: 0.2,
          ),
        ),
        trailing: isSelected
            ? Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: constant.appPrimaryColor,
            shape: BoxShape.circle,
          ),
        )
            : null,
        onTap: onTap,
      ),
    );
  }

  Future<void> showLogoutDialog() async {
    return yesOrNoDialog(
      context: context,
      dialogMessage: LocalizationController.getInstance().getTranslatedValue('Are you sure you want to logout?'),
      cancelText: LocalizationController.getInstance().getTranslatedValue('No'),
      okText: LocalizationController.getInstance().getTranslatedValue('Yes'),
      cancelAction: () => Navigator.pop(context),
      okAction: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        // appLoadController.userValue.value = false; // Uncomment if needed
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => WebHomePage()),
              (route) => false,
        );
      },
    );
  }
}