import 'package:flutter/material.dart';
import 'package:foods_recipe/components/navbar.dart';
import 'package:foods_recipe/Screens/profile_screen.dart';
import 'package:foods_recipe/Screens/search_screen.dart';
import 'package:foods_recipe/Screens/bookmarks_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF1A2A66);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: primary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildBodyForIndex(context, primary),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          setState(() {
            _currentIndex = index;
          });

          if (index == 2) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Camera tapped')));
            return;
          }

          if (index == 1) {
            await Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const SearchScreen()));
            return;
          }

          if (index == 3) {
            await Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const BookmarksScreen()));
            return;
          }

          if (index == 4) {
            await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
            return;
          }
        },
      ),
    );
  }

  Widget _buildBodyForIndex(BuildContext context, Color primary) {
    if (_currentIndex == 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text('Welcome!', style: TextStyle(color: primary, fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('This is your dashboard. From here you can access the app features.'),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildCard(context, Icons.fastfood, 'Food Types'),
                _buildCard(context, Icons.list_alt, 'My Recipes'),
                _buildCard(context, Icons.favorite, 'Favorites'),
                _buildCard(context, Icons.settings, 'Settings'),
              ],
            ),
          ),
        ],
      );
    }

    // Simple placeholders for other tabs. Replace with real pages if available.
    final labels = ['Explore', 'Camera', 'Bookmarks', 'Profile'];
    final label = ( _currentIndex - 1 >= 0 && _currentIndex - 1 < labels.length)
        ? labels[_currentIndex - 1]
        : 'Page';

    return Center(
      child: Text('$label', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildCard(BuildContext context, IconData icon, String title) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Open $title')));
        },
        borderRadius: BorderRadius.circular(12),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: const Color(0xFF1A2A66)),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
