part of 'theme_cubit.dart';

sealed class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object> get props => [];
}

final class ThemeInitial extends ThemeState {}

class LoadedTheme extends ThemeState {
  // final ThemeData themeData;

  final ThemeMode themeMode;
  final String fontFamily;

  const LoadedTheme(
    // this.themeData,
    this.themeMode,
    this.fontFamily,
  );

  @override
  List<Object> get props => [themeMode, fontFamily];
}
