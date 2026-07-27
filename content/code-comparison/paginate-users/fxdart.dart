import 'package:fxdart/fxdart.dart';

const users = [
  'Ava', 'Ben', 'Cara', 'Dan', 'Elle', 'Finn', //
  'Gus', 'Hana', 'Ivan', 'June', 'Kai', 'Lena',
];

void main() {
  final pages = fx(users)
      .chunk(10)
      .map((page) => '${page.length} users: ${page.join(', ')}')
      .toList();
  for (var i = 0; i < pages.length; i++) {
    print('Page ${i + 1}, ${pages[i]}');
  }
}
