import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class ProfileNavButton extends StatelessWidget {
  const ProfileNavButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FAvatar(
      image: const NetworkImage(
        'https://raw.githubusercontent.com/forus-labs/forui/main/samples/assets/avatar.png',
      ),
      fallback: const Text('MN'),
    );
  }
}
