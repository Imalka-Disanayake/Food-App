import 'package:flutter/material.dart';
import 'package:foods_recipe/components/navbar.dart';
import 'package:foods_recipe/Screens/dashboard_screen.dart';
import 'package:foods_recipe/Screens/search_screen.dart';
import 'package:foods_recipe/Screens/profile_screen.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        backgroundColor: const Color(0xFF1A2A66),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.bookmark, size: 64, color: Color(0xFF1A2A66)),
              SizedBox(height: 16),
              Text('Your bookmarks will appear here', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3,
        onTap: (index) async {
          if (index == 2) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Camera tapped')));
            return;
          }

          if (index == 0) {
            await Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const DashboardScreen()));
            return;
          }

          if (index == 1) {
            await Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const SearchScreen()));
            return;
          }

          if (index == 4) {
            await Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const ProfileScreen()));
            return;
          }
        },
      ),
    );
  }
}
