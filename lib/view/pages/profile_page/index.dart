import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  // Changed to StatefulWidget
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoggingOut = false; // Add a state variable

  @override
  Widget build(BuildContext context) {
    return Stack(
      // Use Stack to overlay loading indicator
      children: [
        StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasData && snapshot.data != null) {
              return Scaffold(
                appBar: AppBar(title: const Text('Profile'), centerTitle: true),
                body: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.account_circle, size: 40),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        snapshot.data?.displayName ??
                                            'Username',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        snapshot.data?.email ??
                                            'user@email.com',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const SettingItem(title: "Update username"),
                      const SettingItem(title: "Change password"),
                      const SettingItem(title: "Delete my account"),
                      const SettingItem(
                        title: "About this app",
                        showArrow: false,
                      ),
                      ListTile(
                        title: const Text(
                          "Logout",
                          style: TextStyle(color: Colors.red, fontSize: 16),
                        ),
                        trailing: const Icon(Icons.logout, color: Colors.red),
                        onTap: () async {
                          setState(() {
                            _isLoggingOut = true; // Set loading state
                          });
                          await FirebaseAuth.instance.signOut();
                          // No need to pop here, the StreamBuilder will handle the navigation
                          setState(() {
                            _isLoggingOut = false; // Reset loading state
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            } else {
              return const LoginPage();
            }
          },
        ),
        if (_isLoggingOut) // Show loading indicator when _isLoggingOut is true
          const ModalBarrier(dismissible: false, color: Colors.black12),
        if (_isLoggingOut) const Center(child: CircularProgressIndicator()),
      ],
    );
  }
}

class SettingItem extends StatelessWidget {
  final String title;
  final bool showArrow;

  const SettingItem({super.key, required this.title, this.showArrow = true});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
      trailing:
          showArrow
              ? const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 16,
              )
              : null,
      onTap: () {},
    );
  }
}
