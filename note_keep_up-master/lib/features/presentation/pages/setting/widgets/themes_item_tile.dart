import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_app/features/presentation/blocs/blocs.dart';

import '../../../../../core/core.dart';
import 'widgets.dart';

class ThemesItemTile extends StatelessWidget {
  const ThemesItemTile({super.key});

  static const List<String> supportedFonts = [
    'Roboto',
    'GoogleSans',
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final loadedTheme = state as LoadedTheme;
        final currentTheme = loadedTheme.themeMode;
        final selectedTheme = AppThemes.values.firstWhere(
          (appTheme) => appTheme.mode == currentTheme,
        );
        final currentFont = loadedTheme.fontFamily;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
          title: const Text('Themes'),
          trailing: Text(
            selectedTheme.title,
            style: context.textTheme.bodyLarge,
          ),
          leading: AppIcons.themes,
          onTap: () => _showThemesDialog(context),
            ),
            ListTile(
              title: const Text('Font chữ'),
              trailing: Text(
                currentFont,
                style: context.textTheme.bodyLarge,
              ),
              leading: const Icon(Icons.font_download),
              onTap: () => _showFontsDialog(context, currentFont),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showThemesDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
          title: const Text('Choose Theme'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              AppThemes.values.length,
              (itemThemeIndex) => ItemTheme(indexTheme: itemThemeIndex),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showFontsDialog(BuildContext context, String currentFont) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
          title: const Text('Chọn font chữ'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: supportedFonts.map((font) {
              return RadioListTile<String>(
                value: font,
                groupValue: currentFont,
                title: Text(font),
                onChanged: (value) {
                  if (value != null) {
                    Navigator.of(context).pop();
                    context.read<ThemeCubit>().fontChanged(value);
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
