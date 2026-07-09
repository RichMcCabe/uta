import 'package:flutter/material.dart';

import '../models/driving_style.dart';
import '../models/trip.dart';
import '../services/driver_eligibility_service.dart';
import '../theme/uta_theme.dart';
import '../widgets/section_header.dart';
import '../widgets/uta_card.dart';
import '../widgets/warning_banner.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final eligibility = const DriverEligibilityService();

    return Scaffold(
      appBar: AppBar(title: const Text('Profiles')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader('Traveler profiles', subtitle: 'Profiles are broader than driving. Driving is one optional capability.'),
          for (final profile in trip.profiles)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: UtaCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(profile.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 4),
                  Text(profile.role, style: const TextStyle(color: UtaColors.muted)),
                  const SizedBox(height: 12),
                  Text('Driving style: ${profile.drivingStyle.label}'),
                  const SizedBox(height: 6),
                  Text('Restrictions: ${eligibility.eligibilitySummary(profile, trip.sunriseLabel, trip.sunsetLabel)}'),
                  if (profile.drivingStyle.isAboveLimit) ...[
                    const SizedBox(height: 12),
                    const WarningBanner(
                      title: 'Speed warning',
                      message: 'Driving above the posted speed limit is illegal. UTA does not recommend or encourage speeding. This is a planning assumption only.',
                      isSevere: true,
                    ),
                  ],
                ]),
              ),
            ),
        ],
      ),
    );
  }
}
