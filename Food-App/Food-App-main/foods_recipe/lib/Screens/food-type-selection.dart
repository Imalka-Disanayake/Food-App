import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'food-selection.dart';

class FoodTypeSelectionScreen extends StatefulWidget {
  const FoodTypeSelectionScreen({Key? key}) : super(key: key);

  @override
  State<FoodTypeSelectionScreen> createState() => _FoodTypeSelectionScreenState();
}

class _FoodTypeSelectionScreenState extends State<FoodTypeSelectionScreen> {
  final List<String> _cuisines = [
    'Spanish',
    'Thai',
    'Mexican',
    'Turkish',
    'Italian',
    'Greek',
    'Indian',
    'Sri Lankan',
    'Japanese',
    'German',
    'Chinese',
    'French',
    'American',
    'Korean',
    'Vietnamese',
    'Moroccan',
    'Lebanese',
    'Mediterranean',
    'Caribbean',
  ];

  final Set<int> _selected = {};
  bool _isSaving = false;

  void _toggle(int index) {
    setState(() {
      if (_selected.contains(index)) _selected.remove(index);
      else _selected.add(index);
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
          'cuisines': selectedNames,
          'lastSeen': DateTime.now().toIso8601String(),
        }, SetOptions(merge: true));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Preferences saved')));
      }

      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => FoodSelectionScreen(selectedCuisines: selectedNames)));
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

        title: const Text(
          'Choose your favorite\ncuisines',
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
      backgroundColor: Colors.white,
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
                  children: _selected
                      .map((i) => Chip(
                            label: Text(_cuisines[i]),
                            backgroundColor: Colors.black87,
                            labelStyle: const TextStyle(color: Colors.white),
                          ))
                      .toList(),
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
                  itemCount: _cuisines.length,
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
                                _cuisines[i],
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
                              // Save an empty selection (user skipped) and navigate
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
                              final selectedNames = _selected.map((i) => _cuisines[i]).toList();
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
