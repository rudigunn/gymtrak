import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gymtrak/pages/bloodwork.dart';
import 'package:gymtrak/pages/calendar.dart';
import 'package:gymtrak/pages/dashboard.dart';
import 'package:gymtrak/pages/medication.dart';
import 'package:gymtrak/pages/metrics.dart';
import 'package:gymtrak/pages/settings.dart';
import 'package:material_symbols_icons/symbols.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  int _lastSelectedIndex = 0;
  bool _showAddOverlay = false;
  bool _isMedicationPageOpen = false;
  bool _isBloodWorkPageOpen = false;

  final List<Widget> _pages = [
    const UserDashboardPage(),
    const UserMetricsPage(),
    const Center(child: Text('Add pressed', style: TextStyle(fontSize: 50))),
    const UserCalendarPage(),
    const UserSettingsPage(),
  ];

  final Widget _bloodWorkPage = const UserBloodWorkPage();
  final Widget _medicationPage = const UserMedicationPage();

  Widget get _overlayContent => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _createOverlayButton(
              const Icon(
                Symbols.health_metrics,
                color: Colors.white,
              ),
              'Blood Work', () {
            _switchPage(true, false);
          }),
          const SizedBox(height: 10),
          _createOverlayButton(
              const Icon(
                Symbols.syringe,
                color: Colors.white,
              ),
              'Medication', () {
            _switchPage(false, true);
          }),
          const SizedBox(height: 15),
        ],
      );

  ElevatedButton _createOverlayButton(Icon icon, String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
          textStyle: const TextStyle(fontSize: 15, color: Colors.white),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          minimumSize: const Size(75, 45),
          splashFactory: NoSplash.splashFactory),
      onPressed: onPressed,
      icon: icon,
      label: Text(label),
    );
  }

  void _switchPage(bool bloodWork, bool medication) {
    setState(() {
      _showAddOverlay = false;
      _isBloodWorkPageOpen = bloodWork;
      _isMedicationPageOpen = medication;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget displayBody = _showAddOverlay
        ? Stack(
            children: [
              _isBloodWorkPageOpen || _isMedicationPageOpen
                  ? (_isMedicationPageOpen ? _medicationPage : _bloodWorkPage)
                  : _pages[_lastSelectedIndex],
              GestureDetector(
                onTap: () => setState(() {
                  _showAddOverlay = false;
                  _selectedIndex = _lastSelectedIndex;
                }),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                  child: Container(
                    color: Colors.white.withOpacity(0.1),
                    alignment: Alignment.bottomCenter,
                    child: _overlayContent,
                  ),
                ),
              )
            ],
          )
        : (_isBloodWorkPageOpen || _isMedicationPageOpen
            ? (_isMedicationPageOpen ? _medicationPage : _bloodWorkPage)
            : _pages[_selectedIndex]);

    return Scaffold(
      body: displayBody,
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return SafeArea(
      child: SizedBox(
        height: 60,
        child: Theme(
            data: ThemeData(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
            ),
            child: Container(
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  blurRadius: 0.1,
                  offset: const Offset(0.0, -0.5),
                ),
              ]),
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _navigateBottomBar,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                selectedLabelStyle: const TextStyle(fontSize: 14, color: Colors.black, fontWeight: FontWeight.normal),
                unselectedLabelStyle: const TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.normal),
                showSelectedLabels: true,
                selectedItemColor: Colors.black,
                unselectedItemColor: Colors.black54,
                showUnselectedLabels: true,
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(
                        Symbols.dashboard,
                        color: Colors.black,
                      ),
                      activeIcon: Icon(
                        Symbols.dashboard,
                        fill: 1,
                        color: Colors.black,
                      ),
                      label: 'Charts'),
                  BottomNavigationBarItem(
                      icon: Icon(Symbols.straighten, color: Colors.black),
                      activeIcon: Icon(Symbols.straighten, fill: 1, color: Colors.black),
                      label: 'Metrics'),
                  BottomNavigationBarItem(
                      icon: Icon(
                        Symbols.add,
                        color: Colors.black,
                      ),
                      label: "Add"),
                  BottomNavigationBarItem(
                      icon: Icon(Symbols.calendar_today, color: Colors.black),
                      activeIcon: Icon(
                        Symbols.calendar_today,
                        fill: 1,
                        color: Colors.black,
                      ),
                      label: 'Calendar'),
                  BottomNavigationBarItem(
                      icon: Icon(
                        Symbols.settings,
                        color: Colors.black,
                      ),
                      activeIcon: Icon(
                        Symbols.settings,
                        fill: 1,
                        color: Colors.black,
                      ),
                      label: 'Settings')
                ],
              ),
            )),
      ),
    );
  }

  void _navigateBottomBar(int index) {
    setState(() {
      if (index == 2) {
        if (_showAddOverlay) {
          // Keep the overlay, do not change the selected index
          return;
        }
        _showAddOverlay = true;
        _lastSelectedIndex = _selectedIndex;
      } else {
        _showAddOverlay = false;
        _isMedicationPageOpen = false;
        _isBloodWorkPageOpen = false;
      }
      _selectedIndex = index;
    });
  }
}
