import 'package:flutter/material.dart';

import '../models/trip.dart';
import '../theme/uta_theme.dart';
import '../widgets/section_header.dart';
import '../widgets/uta_card.dart';

class DocumentsScreen extends StatelessWidget {
  const DocumentsScreen({super.key, required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Travel Vault')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader('Documents', subtitle: 'Safe trip storage. Uploads come later; categories are ready now.'),
          for (final category in trip.documentCategories)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: UtaCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(category.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final type in category.types)
                        Chip(
                          label: Text(type),
                          backgroundColor: type == 'Other' ? UtaColors.amber.withValues(alpha: 0.18) : UtaColors.cardSoft,
                        ),
                    ],
                  ),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}
