import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'food-type-selection.dart';
import 'login_screen.dart';

class FoodSelectionScreen extends StatefulWidget {
  final List<String> selectedCuisines;
  const FoodSelectionScreen({Key? key, this.selectedCuisines = const []}) : super(key: key);

  @override
  State<FoodSelectionScreen> createState() => _FoodSelectionScreenState();
}

class _FoodSelectionScreenState extends State<FoodSelectionScreen> {
  final List<String> _foods = [
    'Seafood',
    'Fried Rice',
    'Curry',
    'Biryani',
    'Roast Beef',
    'Lasagna',
    'Risotto',
    'Casserole',
    'Beef Stew',
    'Chicken Soup',
    'BBQ Ribs',
    'Kebab',
    'Paella',
    'Stew',
    'Fried Noodles',
    'Burger',
    'Pizza',
    'Sushi',
    'Seafood',
    'Taco',
    'Pasta',
    'Salad',
    'Sandwich',
    'Fries',
    'Ice Cream',
    'Donut',
    'Bread',
    'Cake',
    'Yoghurt',
    'Milkshake',
    'Milk'
  ];

  final Set<int> _selected = {};
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.selectedCuisines.isNotEmpty) {
      for (var name in widget.selectedCuisines) {
        final idx = _foods.indexOf(name);
        if (idx != -1) _selected.add(idx);
      }
    }
  }

  void _toggle(int i) {
    setState(() {
      if (_selected.contains(i)) _selected.remove(i);
      else _selected.add(i);
    });
  }

  Future<void> _saveSelectedAndNavigate(BuildContext context, List<String> selectedNames) async {
    setState(() {
      _isSaving = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Not signed in. Preferences will not be saved.')));
      } else {
        final users = FirebaseFirestore.instance.collection('users');
        await users.doc(user.uid).set({
          'uid': user.uid,
          'foods': selectedNames,
          'lastSeen': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Food preferences saved')));
      }

      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed saving preferences: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const FoodTypeSelectionScreen()));
          },
        ),
        title: const Text(
          'Choose your foods',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.black87),
        ),
        centerTitle: true,
        leadingWidth: 72,
        toolbarHeight: 88,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              if (_selected.isNotEmpty) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selected.map((i) => Chip(
                        label: Text(_foods[i]),
                        backgroundColor: Colors.black87,
                        labelStyle: const TextStyle(color: Colors.white),
                      )).toList(),
                ),
                const SizedBox(height: 12),
              ],

              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.zero,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 3.0,
                  ),
                  itemCount: _foods.length,
                  itemBuilder: (context, i) {
                    final selected = _selected.contains(i);
                    return GestureDetector(
                      onTap: () => _toggle(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        decoration: BoxDecoration(
                          color: selected ? const Color(0xFFEBD9B5) : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: selected ? Colors.black12 : Colors.transparent),
                          boxShadow: selected
                              ? [BoxShadow(color: Colors.black12, blurRadius: 8, offset: const Offset(0, 4))]
                              : [BoxShadow(color: Colors.black12.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2))],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _foods[i],
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: selected ? Colors.black87 : Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.black12),
                              ),
                              child: selected ? const Icon(Icons.check, size: 18, color: Colors.white) : const SizedBox.shrink(),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving
                          ? null
                          : () async {
                              await _saveSelectedAndNavigate(context, []);
                            },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        side: const BorderSide(color: Colors.black12),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                      ),
                      child: const Text('Skip', style: TextStyle(color: Colors.black87)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: !_isSaving && _selected.isNotEmpty
                          ? () async {
                              final selectedNames = _selected.map((i) => _foods[i]).toList();
                              await _saveSelectedAndNavigate(context, selectedNames);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEBD9B5),
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                      ),
                      child: const Text('Continue'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

