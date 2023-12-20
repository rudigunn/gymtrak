import 'package:flutter/material.dart';
import 'package:gymtrak/pages/calendar.dart';
import 'package:gymtrak/pages/dashboard.dart';
import 'package:gymtrak/pages/metrics.dart';
import 'package:gymtrak/pages/settings.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const UserDashboardPage(),
    const UserMetricsPage(),
    const Center(
      child: Text(
        'Add pressed',
        style: TextStyle(fontSize: 50),
      ),
    ),
    const UserCalendarPage(),
    const UserSettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: SafeArea(
          child: SizedBox(
              height: 80,
              child: Theme(
                data: ThemeData(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: BottomNavigationBar(
                  currentIndex: _selectedIndex,
                  onTap: _navigateBottomBar,
                  type: BottomNavigationBarType.fixed,
                  selectedLabelStyle: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.normal),
                  unselectedLabelStyle:
                      const TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.normal),
                  showSelectedLabels: true,
                  selectedItemColor: Colors.black,
                  unselectedItemColor: Colors.black54,
                  showUnselectedLabels: true,
                  items: [
                    BottomNavigationBarItem(
                        icon: Image.asset('assets/icons/grid_view.png'),
                        activeIcon: Image.asset('assets/icons/grid_view-active.png'),
                        label: 'Dashboard'),
                    BottomNavigationBarItem(
                        icon: Image.asset('assets/icons/straighten.png'),
                        activeIcon: Image.asset('assets/icons/straighten-active.png'),
                        label: 'Metrics'),
                    BottomNavigationBarItem(icon: Image.asset('assets/icons/add.png'), label: "Add"),
                    BottomNavigationBarItem(
                        icon: Image.asset('assets/icons/calendar_today.png'),
                        activeIcon: Image.asset('assets/icons/calendar_today-active.png'),
                        label: 'Calendar'),
                    BottomNavigationBarItem(
                        icon: Image.asset('assets/icons/settings.png'),
                        activeIcon: Image.asset('assets/icons/settings-active.png'),
                        label: 'Settings')
                  ],
                ),
              )),
        ));
  }

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
