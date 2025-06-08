import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChuyenMucDaChonSwitchTile extends StatefulWidget {
  const ChuyenMucDaChonSwitchTile({super.key});

  @override
  State<ChuyenMucDaChonSwitchTile> createState() => _ChuyenMucDaChonSwitchTileState();
}

class _ChuyenMucDaChonSwitchTileState extends State<ChuyenMucDaChonSwitchTile> {
  bool _value = false;

  @override
  void initState() {
    super.initState();
    _loadValue();
  }

  Future<void> _loadValue() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _value = prefs.getBool('chuyen_muc_da_chon') ?? false;
    });
  }

  Future<void> _onChanged(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('chuyen_muc_da_chon', val);
    setState(() {
      _value = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('Chuyển mục đã chọn xuống cuối danh sách'),
      trailing: Switch(
        value: _value,
        onChanged: _onChanged,
      ),
    );
  }
} 