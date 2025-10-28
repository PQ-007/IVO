// Auth Gate will handle the authentication state of the user
import 'package:flutter/material.dart';
import 'package:ivo/view/pages/auth-page/login_page.dart';
import 'package:ivo/view/widget_tree.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      // Listen to authentication state changes
      stream: Supabase.instance.client.auth.onAuthStateChange,

      builder: (context, snapshot) {
        // loading state
        if ((snapshot.connectionState == ConnectionState.waiting)) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Check if there is a current user session
        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null) {
          // User is signed in
          return WidgetTree();
        } else {
          // User is not signed in
          return LoginPage();
        }
      },
    );
  }
}
