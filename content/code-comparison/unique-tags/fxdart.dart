import 'package:fxdart/fxdart.dart';

class Post {
  final String title;
  final List<String> tags;
  const Post(this.title, this.tags);
}

const posts = [
  Post('Lazy pipelines', ['dart', 'fp', 'iterables']),
  Post('Stream vs pull', ['dart', 'async', 'streams']),
  Post('Recipe: chunking', ['iterables', 'recipes']),
  Post('Concurrency limits', ['async', 'concurrency', 'fp']),
  Post('Zip and friends', ['iterables', 'fp']),
];

void main() {
  final tags = fx(posts)
      .flatMap((p) => p.tags)
      .uniq()
      .sort((a, b) => a.compareTo(b))
      .toList();
  print(tags.join(', '));
}
