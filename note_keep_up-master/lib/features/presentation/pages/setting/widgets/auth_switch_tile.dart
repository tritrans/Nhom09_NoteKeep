import 'package:flutter/material.dart';
import 'package:note_app/features/presentation/blocs/auth/auth_pref.dart';

class AuthSwitchTile extends StatefulWidget {
  const AuthSwitchTile({super.key});

  @override
  State<AuthSwitchTile> createState() => _AuthSwitchTileState();
}

class _AuthSwitchTileState extends State<AuthSwitchTile> {
  bool _authEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final enabled = await AuthPref.getAuthEnabled();
    setState(() {
      _authEnabled = enabled;
    });
  }

  Future<void> _saveAuthState(bool value) async {
    await AuthPref.setAuthEnabled(value);
  }

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: const Text('Bật/Tắt xác thực'),
      value: _authEnabled,
      onChanged: (value) {
        setState(() {
          _authEnabled = value;
        });
        _saveAuthState(value);
      },
    );
  }
}
