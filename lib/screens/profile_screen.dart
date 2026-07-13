import 'package:flutter/material.dart';

import '../models/driver_restriction.dart';
import '../models/driving_session.dart';
import '../models/driving_style.dart';
import '../models/profile.dart';
import '../models/trip.dart';
import '../services/driver_eligibility_service.dart';
import '../theme/uta_theme.dart';
import '../widgets/uta_card.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.trip,
    required this.sessions,
    required this.activeDriverId,
    required this.onSaveProfiles,
    required this.onChangeDriver,
    required this.onAddManualSession,
    required this.onDeleteSession,
  });

  final Trip trip;
  final List<DrivingSession> sessions;
  final String? activeDriverId;
  final ValueChanged<List<Profile>> onSaveProfiles;
  final VoidCallback onChangeDriver;
  final Future<void> Function(DrivingSession session) onAddManualSession;
  final Future<void> Function(String id) onDeleteSession;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profiles & driving log'),
        actions: [
          IconButton.filled(
            tooltip: 'Add traveler',
            onPressed: () => _editProfile(context),
            icon: const Icon(Icons.person_add_alt_1_rounded),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
        children: [
          UtaCard(
            highlight: true,
            onTap: onChangeDriver,
            child: Row(
              children: [
                const Icon(Icons.swap_horiz_rounded, color: UtaColors.gold, size: 30),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('CURRENT DRIVER', style: UtaText.label),
                      const SizedBox(height: 4),
                      Text(
                        _activeDriverName,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const Expanded(child: Text('TRAVELERS', style: UtaText.label)),
              TextButton.icon(
                onPressed: () => _editProfile(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add'),
              ),
            ],
          ),
          if (trip.profiles.isEmpty)
            const UtaCard(
              child: Text(
                'No travelers yet. Add each traveler, then mark anyone who can drive.',
                style: TextStyle(color: UtaColors.muted, height: 1.4),
              ),
            ),
          for (final profile in trip.profiles) ...[
            _ProfileCard(
              profile: profile,
              sessions: sessions.where((item) => item.profileId == profile.id).toList(),
              isActive: profile.id == activeDriverId,
              onEdit: () => _editProfile(context, profile),
              onDelete: () => _deleteProfile(context, profile),
              onAddManual: () => _addManualSession(context, profile),
              onDeleteSession: onDeleteSession,
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }

  String get _activeDriverName {
    for (final profile in trip.profiles) {
      if (profile.id == activeDriverId) return profile.name;
    }
    return 'No driver selected — tap to choose';
  }

  Future<void> _deleteProfile(BuildContext context, Profile profile) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete traveler?'),
        content: Text('Delete ${profile.name}? Existing driving-log entries will remain.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      onSaveProfiles(trip.profiles.where((item) => item.id != profile.id).toList());
    }
  }

  Future<void> _editProfile(BuildContext context, [Profile? existing]) async {
    final result = await showModalBottomSheet<Profile>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ProfileEditor(profile: existing),
    );
    if (result == null) return;
    final profiles = [...trip.profiles];
    final index = profiles.indexWhere((item) => item.id == result.id);
    if (result.isPrimary) {
      for (var i = 0; i < profiles.length; i++) {
        profiles[i] = profiles[i].copyWith(isPrimary: false);
      }
    }
    if (index >= 0) {
      profiles[index] = result;
    } else {
      profiles.add(result);
    }
    onSaveProfiles(profiles);
  }

  Future<void> _addManualSession(BuildContext context, Profile profile) async {
    final now = DateTime.now();
    final start = now.subtract(const Duration(hours: 1));
    final result = await showDialog<DrivingSession>(
      context: context,
      builder: (dialogContext) => _ManualSessionDialog(profile: profile, initialStart: start, initialEnd: now),
    );
    if (result != null) await onAddManualSession(result);
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.profile,
    required this.sessions,
    required this.isActive,
    required this.onEdit,
    required this.onDelete,
    required this.onAddManual,
    required this.onDeleteSession,
  });

  final Profile profile;
  final List<DrivingSession> sessions;
  final bool isActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAddManual;
  final Future<void> Function(String id) onDeleteSession;

  @override
  Widget build(BuildContext context) {
    final total = sessions.fold<Duration>(Duration.zero, (sum, item) => sum + item.duration);
    final target = Duration(minutes: profile.drivingTargetMinutes);
    final progress = target.inMinutes <= 0
        ? 0.0
        : (total.inMinutes / target.inMinutes).clamp(0.0, 1.0).toDouble();
    final eligibility = const DriverEligibilityService().eligibilitySummary(profile);
    final recent = sessions.toList()..sort((a, b) => b.startedAt.compareTo(a.startedAt));

    return UtaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(child: Text(profile.name.isEmpty ? '?' : profile.name[0].toUpperCase())),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Flexible(child: Text(profile.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
                      if (isActive) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.circle, color: UtaColors.mint, size: 10),
                      ],
                    ]),
                    Text(profile.role, style: const TextStyle(color: UtaColors.muted)),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => value == 'edit' ? onEdit() : onDelete(),
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit traveler')),
                  PopupMenuItem(value: 'delete', child: Text('Delete traveler')),
                ],
              ),
            ],
          ),
          if (profile.canDrive) ...[
            const SizedBox(height: 14),
            Text(eligibility, style: TextStyle(color: const DriverEligibilityService().isEligible(profile) ? UtaColors.mint : UtaColors.sunset, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _LogMetric(label: 'LOGGED', value: _duration(total))),
                Expanded(child: _LogMetric(label: 'TARGET', value: target.inMinutes == 0 ? 'None' : _duration(target))),
                Expanded(child: _LogMetric(label: 'REMAINING', value: target.inMinutes == 0 ? '—' : _duration(target - total < Duration.zero ? Duration.zero : target - total))),
              ],
            ),
            if (target.inMinutes > 0) ...[
              const SizedBox(height: 12),
              LinearProgressIndicator(value: progress, minHeight: 8),
            ],
            const SizedBox(height: 12),
            OutlinedButton.icon(onPressed: onAddManual, icon: const Icon(Icons.add_alarm_rounded), label: const Text('Add manual drive')),
            if (recent.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('RECENT DRIVES', style: UtaText.label),
              for (final session in recent.take(5))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text('${_date(session.startedAt)} · ${_duration(session.duration)}'),
                  subtitle: Text('${session.tripName} · ${session.legName}${session.isManual ? ' · manual' : ''}'),
                  trailing: session.isActive
                      ? const Text('LIVE', style: TextStyle(color: UtaColors.mint, fontWeight: FontWeight.w900))
                      : IconButton(icon: const Icon(Icons.delete_outline_rounded), onPressed: () => onDeleteSession(session.id)),
                ),
            ],
          ],
        ],
      ),
    );
  }

  static String _duration(Duration value) {
    final minutes = value.inMinutes.abs();
    return '${minutes ~/ 60}h ${minutes % 60}m';
  }

  static String _date(DateTime value) => '${value.month}/${value.day}/${value.year}';
}

class _LogMetric extends StatelessWidget {
  const _LogMetric({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: UtaText.label), const SizedBox(height: 4), Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))]);
}

class _ProfileEditor extends StatefulWidget {
  const _ProfileEditor({this.profile});
  final Profile? profile;
  @override
  State<_ProfileEditor> createState() => _ProfileEditorState();
}

class _ProfileEditorState extends State<_ProfileEditor> {
  late final TextEditingController name = TextEditingController(text: widget.profile?.name ?? '');
  late final TextEditingController role = TextEditingController(text: widget.profile?.role ?? 'Traveler');
  late bool canDrive = widget.profile?.canDrive ?? false;
  late bool isPrimary = widget.profile?.isPrimary ?? false;
  late bool restricted = widget.profile?.restriction.hasRestrictions ?? false;
  late TimeOfDay start = _time(widget.profile?.restriction.allowedStartMinutes ?? 5 * 60);
  late TimeOfDay end = _time(widget.profile?.restriction.allowedEndMinutes ?? 21 * 60);
  late double targetHours = (widget.profile?.drivingTargetMinutes ?? 0) / 60.0;
  late DrivingStyle style = widget.profile?.drivingStyle ?? DrivingStyle.postedLimit;

  static TimeOfDay _time(int minutes) => TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 4, 18, MediaQuery.viewInsetsOf(context).bottom + 24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.profile == null ? 'Add traveler' : 'Edit traveler', style: UtaText.title),
            const SizedBox(height: 16),
            TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 12),
            TextField(controller: role, decoration: const InputDecoration(labelText: 'Role')),
            SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Primary traveler'), value: isPrimary, onChanged: (value) => setState(() => isPrimary = value)),
            SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Can drive'), value: canDrive, onChanged: (value) => setState(() => canDrive = value)),
            if (canDrive) ...[
              DropdownButtonFormField<DrivingStyle>(initialValue: style, decoration: const InputDecoration(labelText: 'Driving profile'), items: [for (final item in DrivingStyle.values) DropdownMenuItem(value: item, child: Text(item.label))], onChanged: (value) => setState(() => style = value ?? style)),
              SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Time-bound driving window'), value: restricted, onChanged: (value) => setState(() => restricted = value)),
              if (restricted)
                Row(children: [
                  Expanded(child: OutlinedButton(onPressed: () => _pick(true), child: Text('From ${start.format(context)}'))),
                  const SizedBox(width: 10),
                  Expanded(child: OutlinedButton(onPressed: () => _pick(false), child: Text('Until ${end.format(context)}'))),
                ]),
              const SizedBox(height: 12),
              Text('Driving-hours target: ${targetHours.round()} hours'),
              Slider(value: targetHours.clamp(0.0, 100.0).toDouble(), min: 0, max: 100, divisions: 100, label: '${targetHours.round()}h', onChanged: (value) => setState(() => targetHours = value)),
            ],
            const SizedBox(height: 18),
            SizedBox(width: double.infinity, child: FilledButton(onPressed: _save, child: const Text('Save traveler'))),
          ],
        ),
      ),
    );
  }

  Future<void> _pick(bool isStart) async {
    final selected = await showTimePicker(context: context, initialTime: isStart ? start : end);
    if (selected == null) return;
    setState(() => isStart ? start = selected : end = selected);
  }

  void _save() {
    if (name.text.trim().isEmpty) return;
    final id = widget.profile?.id ?? 'profile-${DateTime.now().microsecondsSinceEpoch}';
    Navigator.pop(context, Profile(
      id: id,
      name: name.text.trim(),
      role: role.text.trim().isEmpty ? 'Traveler' : role.text.trim(),
      canDrive: canDrive,
      drivingStyle: style,
      restriction: DriverRestriction(
        hasRestrictions: canDrive && restricted,
        allowedStartMinutes: restricted ? start.hour * 60 + start.minute : null,
        allowedEndMinutes: restricted ? end.hour * 60 + end.minute : null,
      ),
      isPrimary: isPrimary,
      drivingTargetMinutes: canDrive ? targetHours.round() * 60 : 0,
    ));
  }
}

class _ManualSessionDialog extends StatefulWidget {
  const _ManualSessionDialog({required this.profile, required this.initialStart, required this.initialEnd});
  final Profile profile;
  final DateTime initialStart;
  final DateTime initialEnd;
  @override
  State<_ManualSessionDialog> createState() => _ManualSessionDialogState();
}

class _ManualSessionDialogState extends State<_ManualSessionDialog> {
  late DateTime start = widget.initialStart;
  late DateTime end = widget.initialEnd;
  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text('Add drive for ${widget.profile.name}'),
    content: Column(mainAxisSize: MainAxisSize.min, children: [
      ListTile(title: const Text('Start'), subtitle: Text(start.toString().substring(0, 16)), onTap: () => _pick(true)),
      ListTile(title: const Text('End'), subtitle: Text(end.toString().substring(0, 16)), onTap: () => _pick(false)),
      Text('Duration: ${end.difference(start).inMinutes ~/ 60}h ${end.difference(start).inMinutes % 60}m'),
    ]),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      FilledButton(onPressed: end.isAfter(start) ? _save : null, child: const Text('Add')),
    ],
  );

  Future<void> _pick(bool isStart) async {
    final base = isStart ? start : end;
    final date = await showDatePicker(context: context, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 1)), initialDate: base);
    if (date == null || !mounted) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(base));
    if (time == null) return;
    final value = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() => isStart ? start = value : end = value);
  }

  void _save() => Navigator.pop(context, DrivingSession(
    id: 'manual-${DateTime.now().microsecondsSinceEpoch}',
    profileId: widget.profile.id,
    driverName: widget.profile.name,
    tripId: '',
    tripName: 'Manual entry',
    legId: '',
    legName: 'Driving log',
    startedAt: start,
    endedAt: end,
    isManual: true,
  ));
}
