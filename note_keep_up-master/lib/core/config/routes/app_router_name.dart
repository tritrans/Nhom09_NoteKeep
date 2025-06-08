enum AppRouterName {
  home('/'),
  note('note'),
  setting('setting'),
  trash('trash'),
  archive('archive'),
  statistics('statistics');

  final String path;
  const AppRouterName(this.path);
}
