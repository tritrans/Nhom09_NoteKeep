export './sections.dart';
export './tiles_section.dart';
export './item_theme.dart';
export './themes_item_tile.dart';
export './them_muc_moi_switch_tile.dart';
export './chuyen_muc_da_chon_switch_tile.dart';
export './auth_switch_tile.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceSwitchTile extends StatefulWidget {
  const AttendanceSwitchTile({super.key});

  @override
  State<AttendanceSwitchTile> createState() => _AttendanceSwitchTileState();
}

class _AttendanceSwitchTileState extends State<AttendanceSwitchTile> {
  bool _enabled = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _enabled = prefs.getBool('attendance_enabled') ?? true;
    });
  }

  Future<void> _save(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('attendance_enabled', value);
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('Bật/tắt điểm danh tự động'),
      value: _enabled,
      onChanged: (value) {
        setState(() {
          _enabled = value;
        });
        _save(value);
      },
    );
  }
}
