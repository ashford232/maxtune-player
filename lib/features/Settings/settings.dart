import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:hugeicons_pro/hugeicons.dart';

import 'package:maxtune_player/core/db/app_database.dart';
import 'package:maxtune_player/core/db/operations/settings_operation.dart';
import 'package:maxtune_player/core/db/services/database_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Settings extends ConsumerStatefulWidget {
  const Settings({super.key});

  @override
  ConsumerState<Settings> createState() => _SettingsState();
}

class _SettingsState extends ConsumerState<Settings> {
  SettingsOperation get settingOperation => ref.read(settingsOperationProvider);

  bool _loading = true;

  double _speed = 1;
  double _pitch = 1;

  String _theme = 'system';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // LOAD SETTINGS

  Future<void> _loadSettings() async {
    try {
      final settings = await settingOperation.getSettings();

      if (!mounted) return;

      setState(() {
        _speed = settings.playbackSpeed;
        _pitch = settings.pitch;

        _theme = settings.theme;

        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() => _loading = false);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load settings: $e')));
    }
  }

  Future<void> _save(SettingsTableCompanion companion) async {
    try {
      await settingOperation.updateSettingsPartial(companion);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save settings: $e')));
    }
  }

  void _resetEffect(String name) {
    switch (name) {
      case 'Speed':
        setState(() => _speed = 1);
        _save(const SettingsTableCompanion(playbackSpeed: Value(1)));

      case 'Pitch':
        setState(() => _pitch = 1);
        _save(const SettingsTableCompanion(pitch: Value(1)));
    }
  }

  Future<void> _resetAll() async {
    setState(() {
      _speed = 1;
      _pitch = 1;

      _theme = 'system';
    });

    await settingOperation.resetSettings();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('SOUND EFFECTS'),

            const SizedBox(height: 16),

            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 850
                    ? 3
                    : constraints.maxWidth >= 520
                    ? 2
                    : 1;

                const spacing = 24.0;

                final width =
                    (constraints.maxWidth - spacing * (columns - 1)) / columns;

                final groups = [
                  Column(
                    children: [
                      _simpleSlider('Speed', _speed, 0.5, 2),
                      _simpleSlider('Pitch', _pitch, 0.5, 1.5),
                    ],
                  ),
                ];

                return Wrap(
                  spacing: spacing,
                  runSpacing: 20,
                  children: [
                    for (final group in groups)
                      SizedBox(width: width, child: group),
                  ],
                );
              },
            ),

            const SizedBox(height: 22),

            const Divider(height: 1),

            const SizedBox(height: 14),

            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Right-click a control to reset its value.',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
                TextButton(
                  onPressed: _resetAll,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text(
                    'Reset all',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _footerButton(HugeIconsStroke.github, 'GitHub', () {
                  _launchURL('https://github.com/ashford232');
                }),
                const SizedBox(width: 12),
                _footerButton(HugeIconsStroke.whatsapp, 'WhatsApp', () {
                  _launchURL('https://wa.me/+231880421012');
                }),
              ],
            ),

            const SizedBox(height: 18),

            const Divider(height: 1),

            const SizedBox(height: 12),

            Row(
              children: [
                const Text('Theme', style: TextStyle(fontSize: 11)),
                const SizedBox(width: 12),

                DropdownButton<String>(
                  value: _theme,
                  underline: const SizedBox(),
                  style: TextStyle(fontSize: 11, color: colors.onSurface),
                  items: const [
                    DropdownMenuItem(value: 'system', child: Text('System')),
                    DropdownMenuItem(value: 'dark', child: Text('Dark Mode')),
                    DropdownMenuItem(value: 'light', child: Text('Light Mode')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;

                    setState(() => _theme = value);

                    _save(SettingsTableCompanion(theme: Value(value)));
                  },
                ),

                const Spacer(),
              ],
            ),
            Column(
              crossAxisAlignment: .start,
              children: [Text('Version'), Text('v0.1.0')],
            ),
          ],
        ),
      ),
    );
  }

  // EFFECT CONTROL

  // SPEED AND PITCH

  Widget _simpleSlider(String label, double value, double min, double max) {
    return GestureDetector(
      onSecondaryTap: () => _resetEffect(label),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(label, style: const TextStyle(fontSize: 12)),
                ),
                Text(
                  '${value.toStringAsFixed(2)}x',
                  style: const TextStyle(fontSize: 10),
                ),
              ],
            ),

            const SizedBox(height: 2),

            _slider(
              value: value,
              min: min,
              max: max,
              onChanged: (v) {
                setState(() {
                  if (label == 'Speed') {
                    _speed = v;
                  } else {
                    _pitch = v;
                  }
                });

                if (label == 'Speed') {
                  _save(SettingsTableCompanion(playbackSpeed: Value(v)));
                } else {
                  _save(SettingsTableCompanion(pitch: Value(v)));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // SLIDER

  Widget _slider({
    required double value,
    double min = 0,
    double max = 1,
    required ValueChanged<double>? onChanged,
  }) {
    final colors = Theme.of(context).colorScheme;

    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 3,
        activeTrackColor: colors.primary,
        inactiveTrackColor: colors.surfaceContainerHighest,
        disabledActiveTrackColor: colors.onSurface.withValues(alpha: 0.2),
        disabledInactiveTrackColor: colors.surfaceContainerHighest,
        thumbColor: colors.primary,
        disabledThumbColor: colors.onSurface.withValues(alpha: 0.3),
        thumbShape: const _RectangularThumbShape(width: 8, height: 14),
        overlayShape: SliderComponentShape.noOverlay,
        trackShape: const RoundedRectSliderTrackShape(),
        showValueIndicator: ShowValueIndicator.never,
      ),
      child: SizedBox(
        height: 25,
        child: Slider(
          value: value.clamp(min, max),
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ),
    );
  }

  // FOOTER BUTTON

  Widget _footerButton(IconData icon, String label, VoidCallback onPressed) {
    return OutlinedButton.icon(
      icon: Icon(icon),
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      ),
      label: Text(label, style: const TextStyle(fontSize: 11)),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.1,
      ),
    );
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $urlString');
    }
  }
}

class _RectangularThumbShape extends SliderComponentShape {
  final double width;
  final double height;

  const _RectangularThumbShape({this.width = 8, this.height = 14});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size(width, height);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required Size sizeWithOverflow,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double textScaleFactor,
    required double value,
  }) {
    final paint = Paint()
      ..color =
          sliderTheme.thumbColor ??
          sliderTheme.activeTrackColor ??
          Colors.transparent
      ..style = PaintingStyle.fill;

    final rect = Rect.fromCenter(center: center, width: width, height: height);

    context.canvas.drawRect(rect, paint);
  }
}
