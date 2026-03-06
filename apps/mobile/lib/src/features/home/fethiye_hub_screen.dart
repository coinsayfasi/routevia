import 'package:flutter/material.dart';

import 'local_hub_screen.dart';

class FethiyeHubScreen extends StatelessWidget {
  const FethiyeHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LocalHubScreen(initialProvinceSlug: 'mugla');
  }
}
