import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_palette.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_photo.dart';
import 'package:dashboard/features/chat/fluttersocial_demo/fluttersocial_user.dart';
import 'package:flutter/material.dart';

/// Port of the source profile tab (source `lib/views/tabs/profile.dart`).
///
/// Every row here is inert in the source (no `onTap`), so the port keeps the
/// list tiles display-only rather than pretending they lead somewhere.
class FlutterSocialProfilePage extends StatelessWidget {
  const FlutterSocialProfilePage({super.key});

  FlutterSocialUser get user => flutterSocialUsers[0];

  @override
  Widget build(BuildContext context) {
    final hr = const Divider();

    final userStats = Positioned(
      bottom: 10.0,
      left: 40.0,
      right: 40.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildUserStats('VISITORS', '2305'),
          _buildUserStats('LIKED', '276'),
          _buildUserStats('MATCHED', '51'),
        ],
      ),
    );

    final userImage = FlutterSocialPhoto(
      source: user.photo,
      width: 100.0,
      height: 100.0,
      circle: true,
    );

    final userNameLocation = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          user.name,
          style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.w900),
        ),
        Text(
          user.location,
          style: TextStyle(
            color: Colors.grey.withValues(alpha: 0.6),
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    final userInfo = Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20.0),
          child: Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(8.0),
            shadowColor: Colors.white,
            child: Container(
              height: 220.0,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0, bottom: 20.0),
                child: Row(
                  children: <Widget>[
                    userImage,
                    const SizedBox(width: 10.0),
                    userNameLocation,
                  ],
                ),
              ),
            ),
          ),
        ),
        userStats,
      ],
    );

    final secondCard = Padding(
      padding: const EdgeInsets.only(right: 20.0, left: 20.0, bottom: 30.0),
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(8.0),
        shadowColor: Colors.white,
        child: Container(
          height: 200.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            children: <Widget>[
              _buildIconTile(Icons.favorite, Colors.red, 'Likes'),
              hr,
              _buildIconTile(
                Icons.visibility_outlined,
                Colors.green,
                'Visitors',
              ),
              hr,
              _buildIconTile(
                Icons.group_outlined,
                Colors.purpleAccent,
                'Groups',
              ),
            ],
          ),
        ),
      ),
    );

    final thirdCard = Padding(
      padding: const EdgeInsets.only(right: 20.0, left: 20.0, bottom: 30.0),
      child: Material(
        elevation: 5.0,
        borderRadius: BorderRadius.circular(8.0),
        shadowColor: Colors.white,
        child: Container(
          height: 350.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Column(
            children: <Widget>[
              _buildIconTile(
                Icons.account_balance_wallet_outlined,
                Colors.red,
                'My Wallet',
              ),
              hr,
              _buildIconTile(Icons.diamond_outlined, Colors.blue, 'VIP Center'),
              hr,
              _buildIconTile(
                Icons.person_add_alt,
                Colors.orangeAccent,
                'Find Friends',
              ),
              hr,
              _buildIconTile(
                Icons.person_off_outlined,
                Colors.black,
                'Blacklist',
              ),
              hr,
              _buildIconTile(
                Icons.settings_outlined,
                Colors.grey.withValues(alpha: 0.6),
                'Settings',
              ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Column(
                children: <Widget>[
                  Stack(
                    children: <Widget>[
                      const SizedBox(height: 350.0),
                      Container(
                        height: 250.0,
                        decoration: const BoxDecoration(
                          gradient: FlutterSocialPalette.primaryGradient,
                        ),
                      ),
                      Positioned(top: 100, right: 0, left: 0, child: userInfo),
                    ],
                  ),
                  secondCard,
                  thirdCard,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserStats(String name, String value) {
    return Column(
      children: <Widget>[
        Text(
          name,
          style: TextStyle(
            color: Colors.grey.withValues(alpha: 0.6),
            fontWeight: FontWeight.w600,
            fontSize: 16.0,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w900,
            fontSize: 20.0,
          ),
        ),
      ],
    );
  }

  Widget _buildIconTile(IconData icon, Color color, String title) {
    return ListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      leading: Container(
        height: 30.0,
        width: 30.0,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Center(child: Icon(icon, color: Colors.white)),
      ),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
