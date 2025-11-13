import 'package:flutter/material.dart';
import 'package:foods_recipe/components/navbar.dart';
import 'package:foods_recipe/Screens/dashboard_screen.dart';
import 'package:foods_recipe/Screens/bookmarks_screen.dart';
import 'package:foods_recipe/Screens/search_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foods_recipe/Screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 4; // profile tab

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('No user signed in')),
      );
    }

    final Stream<DocumentSnapshot<Map<String, dynamic>>> userStream =
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: userStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final doc = snapshot.data;
            if (doc == null || !doc.exists) {
              return const Center(child: Text('User data not found'));
            }

            final data = doc.data() ?? <String, dynamic>{};
            final name = data['name'] ?? user.displayName ?? 'No name';
            final email = data['email'] ?? user.email ?? 'No email';
            final photoUrl = data['photoUrl'] ?? user.photoURL;
            final otherEntries = Map.of(data);
            otherEntries.remove('name');
            otherEntries.remove('email');
            otherEntries.remove('photoUrl');
            otherEntries.remove('uid');
            otherEntries.remove('lastSeen');
            final arrayEntries = otherEntries.entries
                .where((e) => e.value is List)
                .toList();
            final displayArrayEntries = arrayEntries.take(2).toList();
            for (final e in displayArrayEntries) {
              otherEntries.remove(e.key);
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Top header removed per request. Keep small spacing before profile info.
                  const SizedBox(height: 12),

                  // Name and email (no header)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: Colors.grey.shade800,
                          backgroundImage:
                              (photoUrl != null &&
                                  photoUrl.toString().isNotEmpty)
                              ? NetworkImage(photoUrl.toString())
                              : null,
                          child:
                              (photoUrl == null || photoUrl.toString().isEmpty)
                              ? Text(
                                  (name.isNotEmpty
                                      ? name[0].toUpperCase()
                                      : '?'),
                                  style: const TextStyle(
                                    fontSize: 28,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.grey.shade400,
                              width: 1.25,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.email_outlined,
                                size: 16,
                                color: Color(0xFFFF6B6B),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                email,
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 0),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 236, 223, 223),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFFF6B6B),
                                              Color(0xFFFFA726),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.person_outline,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text(
                                        'Profile Information',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  if (displayArrayEntries.isNotEmpty) ...[
                                    ...displayArrayEntries.map((arrEntry) {
                                      final colorSchemes = {
                                        0: [
                                          const Color(0xFFFF6B6B),
                                          const Color(0xFFFFE5E5),
                                        ],
                                        1: [
                                          const Color(0xFF4ECDC4),
                                          const Color(0xFFE0F7F6),
                                        ],
                                      };
                                      final schemeIndex = displayArrayEntries
                                          .indexOf(arrEntry);
                                      final colors =
                                          colorSchemes[schemeIndex] ??
                                          colorSchemes[0]!;

                                      return Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 20,
                                        ),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: colors[0].withOpacity(0.75),
                                            width: 2.0,
                                          ),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                    6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: colors[0],
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    arrEntry.key
                                                            .toLowerCase()
                                                            .contains('food')
                                                        ? Icons.restaurant_menu
                                                        : Icons
                                                              .category_outlined,
                                                    size: 16,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  arrEntry.key
                                                          .toString()
                                                          .isNotEmpty
                                                      ? '${arrEntry.key[0].toUpperCase()}${arrEntry.key.substring(1)}'
                                                      : arrEntry.key,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color:
                                                        (arrEntry.key
                                                                    .toString()
                                                                    .toLowerCase() ==
                                                                'foods' ||
                                                            arrEntry.key
                                                                .toString()
                                                                .toLowerCase()
                                                                .contains(
                                                                  'cuisine',
                                                                ))
                                                        ? Colors.black87
                                                        : colors[0],
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children: (arrEntry.value as List)
                                                  .map<Widget>((item) {
                                                    final tagColors = [
                                                      [
                                                        const Color(0xFFFF6B6B),
                                                        const Color(0xFFFFE5E5),
                                                      ],
                                                      [
                                                        const Color(0xFF4ECDC4),
                                                        const Color(0xFFE0F7F6),
                                                      ],
                                                      [
                                                        const Color(0xFFFFA726),
                                                        const Color(0xFFFFEDD5),
                                                      ],
                                                      [
                                                        const Color(0xFF9B59B6),
                                                        const Color(0xFFF3E5F5),
                                                      ],
                                                      [
                                                        const Color(0xFF3498DB),
                                                        const Color(0xFFE3F2FD),
                                                      ],
                                                      [
                                                        const Color(0xFF2ECC71),
                                                        const Color(0xFFE8F8F5),
                                                      ],
                                                    ];
                                                    final tagColorPair =
                                                        tagColors[item
                                                                .toString()
                                                                .hashCode %
                                                            tagColors.length];
                                                    final base =
                                                        tagColorPair[0];

                                                    // derive a darker background from the base color
                                                    final hslBase =
                                                        HSLColor.fromColor(
                                                          base,
                                                        );
                                                    final darkBg = hslBase
                                                        .withLightness(
                                                          (hslBase.lightness *
                                                                  0.36)
                                                              .clamp(0.0, 1.0),
                                                        )
                                                        .toColor();

                                                    return Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 14,
                                                            vertical: 10,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: darkBg,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                        border: Border.all(
                                                          color: base
                                                              .withOpacity(
                                                                0.22,
                                                              ),
                                                          width: 1.0,
                                                        ),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                  0.06,
                                                                ),
                                                            blurRadius: 4,
                                                            offset:
                                                                const Offset(
                                                                  0,
                                                                  2,
                                                                ),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Text(
                                                        item?.toString() ?? '',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    );
                                                  })
                                                  .toList(),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],

                                  if (otherEntries.isNotEmpty)
                                    ...otherEntries.entries.map((e) {
                                      // Icon mapping for different field types
                                      IconData getIcon(String key) {
                                        if (key.toLowerCase().contains(
                                          'verified',
                                        ))
                                          return Icons.verified_user;
                                        if (key.toLowerCase().contains('phone'))
                                          return Icons.phone;
                                        if (key.toLowerCase().contains(
                                          'address',
                                        ))
                                          return Icons.location_on;
                                        if (key.toLowerCase().contains('date'))
                                          return Icons.calendar_today;
                                        return Icons.info_outline;
                                      }

                                      final isVerified =
                                          e.key
                                              .toString()
                                              .toLowerCase()
                                              .contains('verified') &&
                                          (e.value == true ||
                                              (e.value != null &&
                                                  e.value
                                                          .toString()
                                                          .toLowerCase() ==
                                                      'true'));

                                      if (isVerified) {
                                        return Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 16,
                                          ),
                                          padding: const EdgeInsets.all(14),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: Colors.green.withOpacity(
                                                0.68,
                                              ),
                                              width: 2.0,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.03,
                                                ),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(
                                                  8,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.green
                                                      .withOpacity(0.12),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: const Icon(
                                                  Icons.verified,
                                                  size: 18,
                                                  color: Colors.green,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: const [
                                                    Text(
                                                      'Verified',
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: Colors.black87,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      'This account is verified',
                                                      style: TextStyle(
                                                        color: Colors.black54,
                                                        fontSize: 13,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }

                                      return Container(
                                        margin: const EdgeInsets.only(
                                          bottom: 16,
                                        ),
                                        padding: const EdgeInsets.all(14),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                            width: 1.25,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.03,
                                              ),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFFFF6B6B,
                                                ).withOpacity(0.08),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              child: Icon(
                                                getIcon(e.key),
                                                size: 18,
                                                color: const Color(0xFFFF6B6B),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    e.key,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.black87,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    e.value?.toString() ?? '',
                                                    style: const TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    })
                                  else if (displayArrayEntries.isEmpty)
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 20,
                                        ),
                                        child: Column(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(20),
                                              decoration: BoxDecoration(
                                                color: Colors.grey.shade100,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.info_outline_rounded,
                                                size: 48,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              'No additional information',
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),

                                  const SizedBox(height: 20),

                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        // confirm logout
                                        final doLogout = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Log out'),
                                            content: const Text(
                                              'Are you sure you want to log out?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(
                                                  ctx,
                                                ).pop(false),
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.of(ctx).pop(true),
                                                child: const Text('Log out'),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (doLogout == true) {
                                          await FirebaseAuth.instance.signOut();
                                          Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const LoginScreen(),
                                            ),
                                          );
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.logout,
                                        color: Colors.white,
                                      ),
                                      label: const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 14.0,
                                        ),
                                        child: Text(
                                          'Log out',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.redAccent,
                                        elevation: 4,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) async {
          setState(() => _currentIndex = index);

          if (index == 2) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Camera tapped')));
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

          if (index == 3) {
            await Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const BookmarksScreen()));
            return;
          }
        },
      ),
    );
  }
}
