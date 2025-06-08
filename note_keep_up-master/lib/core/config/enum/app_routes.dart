/// Represents the app routes and their paths.
enum AppRouterName {
  // routs Views
  //routs(name: 'routs', path: '/'),

  home(name: 'home', path: '/'),
  //=> Note Views
  //Note Add
  add(name: 'note', path: 'note/new'),
  //Note Detail
  note(name: 'note', path: 'note/:id'),
  //=>
  archive(name: 'archive', path: '/archive'),
  trash(name: 'trash', path: '/trash'),
  statistics(name: 'statistics', path: '/statistics'),
  setting(name: 'setting', path: '/setting');

  const AppRouterName({required this.name, required this.path});

  final String name;
  final String path;
}
