import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../API/realtime_crud.dart';
import '../Controllers/app_controller.dart';
import '../Controllers/internet.dart';
import '../Controllers/theme_controller.dart';
import '../side_bar/sidebar_menu.dart';
import '../utils.dart';
import 'client/all_client.dart';
import 'employee/employee_details/employee_home.dart';
import 'stocks/stocks.dart';

class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final drawerController = AdvancedDrawerController();
  late int _selectedIndex = 0;
  final AppController appController = Get.find();
  List<Map<String, dynamic>> companyDetails = [];
  final ThemeController theme = Get.find();
  final InternetController internet = Get.find();

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    fetchCompanyDetails();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: theme.appbarBottomNav.value,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  Future<void> fetchCompanyDetails() async {
    bool hasInternet = await internet.checkInternet();
    if (!hasInternet) {
      Utils.showSnackBar('Error', 'Not Internet Connection');
      return;
    }
    companyDetails = await Api.getCompanyDetails();
    setState(() {});
  }

  void openDrawer() {
    drawerController.showDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => AdvancedDrawer(
        openRatio: 0.7,
        openScale: 0.8,
        rtlOpening: false,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 500),
        controller: drawerController,
        backdropColor: theme.cardBtn.value,
        drawer: SidebarMenu(
          companyDetails: companyDetails,
        ),
        child: Scaffold(
          backgroundColor: theme.scaffoldBg.value,
          appBar: AppBar(
            backgroundColor: theme.appbarBottomNav.value,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                IconButton(
                  onPressed: openDrawer,
                  icon: Icon(FontAwesomeIcons.barsStaggered,
                      color: theme.textLight.value),
                ),
                _selectedIndex == 0
                    ? Text(
                        'Employee',
                        style: TextStyle(
                            color: theme.textLight.value, fontSize: 16),
                      )
                    : _selectedIndex == 1
                        ? Text('Bills',
                            style: TextStyle(
                                color: theme.textLight.value, fontSize: 16))
                        : Text('Stocks',
                            style: TextStyle(
                                color: theme.textLight.value, fontSize: 16))
              ],
            ),
          ),
          body: _buildBody(),
          bottomNavigationBar: SafeArea(
            child: Container(
              margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewPadding.bottom > 0
                    ? 0
                    : MediaQuery.of(context).padding.bottom,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: theme.appbarBottomNav.value,
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: GNav(
                  color: theme.textLight.value,
                  activeColor: theme.textDark.value,
                  tabBackgroundColor: theme.cardBtn.value,
                  padding: const EdgeInsets.all(12),
                  gap: 8,
                  selectedIndex: _selectedIndex,
                  onTabChange: (index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  tabs: const [
                    GButton(
                        icon: FontAwesomeIcons.userGroup, text: 'Employees'),
                    GButton(icon: FontAwesomeIcons.receipt, text: 'Bills'),
                    GButton(icon: FontAwesomeIcons.industry, text: 'Stock'),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const EmployeeHome();
      case 1:
        return const AllClients();
      case 2:
        return const Stocks();
      default:
        return Container();
    }
  }
}
