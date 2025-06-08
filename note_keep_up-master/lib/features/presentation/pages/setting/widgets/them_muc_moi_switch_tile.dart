import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemMucMoiSwitchTile extends StatefulWidget {
  const ThemMucMoiSwitchTile({super.key});

  @override
  State<ThemMucMoiSwitchTile> createState() => _ThemMucMoiSwitchTileState();
}

class _ThemMucMoiSwitchTileState extends State<ThemMucMoiSwitchTile> {
  bool _value = false;

  @override
  void initState() {
    super.initState();
    _loadValue();
  }

  Future<void> _loadValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _value = prefs.getBool('them_muc_moi') ?? false;
    });
  }

  Future<void> _onChanged(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('them_muc_moi', val);
    setState(() {
      _value = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Thêm các mục mới vào cuối'),
      trailing: Switch(
        value: _value,
        onChanged: _onChanged,
      ),
    );
  }
} 