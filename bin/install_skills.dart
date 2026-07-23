/// Installs the AI agent skills bundled with fxdart (the `skills/` directory
/// of this package) into the skill directories of coding agents.
///
/// From a project that depends on fxdart:
///
/// ```sh
/// dart run fxdart:install_skills            # auto-detect agents in project
/// dart run fxdart:install_skills claude codex --global
/// ```
///
/// Or globally:
///
/// ```sh
/// dart pub global activate fxdart
/// fxdart_skills --global claude
/// ```
///
/// Zero dependencies — dart:io and dart:isolate only.
library;

import 'dart:io';
import 'dart:isolate';

/// A coding agent that consumes Agent Skills (https://agentskills.io).
class AgentTarget {
  const AgentTarget(this.name, this.projectDir, this.globalDir,
      {this.detectMarkers = const []});

  final String name;

  /// Skill directory relative to the project root.
  final String projectDir;

  /// Skill directory relative to the user's home directory.
  final String globalDir;

  /// Directories whose presence auto-selects this agent (project-relative
  /// for project installs, home-relative for global installs).
  final List<String> detectMarkers;
}

const targets = <AgentTarget>[
  AgentTarget('claude', '.claude/skills', '.claude/skills',
      detectMarkers: ['.claude']),
  AgentTarget('codex', '.agents/skills', '.agents/skills',
      detectMarkers: ['.codex']),
  AgentTarget('devin', '.devin/skills', '.config/devin/skills',
      detectMarkers: ['.devin']),
  AgentTarget('antigravity', '.agents/skills', '.agents/skills'),
  AgentTarget('opencode', '.opencode/skills', '.config/opencode/skills',
      detectMarkers: ['.opencode']),
  AgentTarget('pi', '.pi/skills', '.pi/agent/skills',
      detectMarkers: ['.pi']),
  AgentTarget('generic', '.agents/skills', '.agents/skills',
      detectMarkers: ['.agents']),
];

Never _fail(String message) {
  stderr.writeln('error: $message');
  exit(1);
}

void _usage() {
  final names = targets.map((t) => t.name).join(', ');
  stdout.writeln('''
Install fxdart's AI agent skills into coding-agent skill directories.

Usage: dart run fxdart:install_skills [agents...] [options]

Agents: $names, all
  (no agents given: auto-detect from existing agent directories)

Options:
  -g, --global          install into per-user directories (e.g. ~/.claude/skills)
      --project-root DIR  project root for project installs (default: current dir)
      --home DIR        override the home directory (for testing)
      --list            show install locations and status, change nothing
      --remove          remove fxdart skills from the selected targets
  -h, --help            show this help

Directory map (project | global under \$HOME):
${targets.map((t) => '  ${t.name.padRight(12)} ${t.projectDir.padRight(18)} | ~/${t.globalDir}').join('\n')}

Alternatively, the serverpod `skills` CLI installs these too:
  dart pub global activate skills && skills get fxdart
''');
}

/// Locates this package's `skills/` directory via package resolution, so it
/// works from a dependent project, from `dart pub global activate fxdart`,
/// and from the fxdart repo itself.
Future<Directory> _skillsSource() async {
  final libUri =
      await Isolate.resolvePackageUri(Uri.parse('package:fxdart/fxdart.dart'));
  if (libUri == null) {
    _fail('cannot resolve package:fxdart — run from a project that '
        'depends on fxdart (after `dart pub get`).');
  }
  final packageRoot = File.fromUri(libUri).parent.parent;
  final skills = Directory('${packageRoot.path}/skills');
  if (!skills.existsSync()) {
    _fail('no skills/ directory found in the fxdart package '
        'at ${packageRoot.path}');
  }
  return skills;
}

/// Skill directories shipped by the package: `skills/fxdart-*/SKILL.md`.
List<Directory> _skillDirs(Directory source) => source
    .listSync()
    .whereType<Directory>()
    .where((d) {
      final name = d.uri.pathSegments.lastWhere((s) => s.isNotEmpty);
      return name.startsWith('fxdart-') &&
          File('${d.path}/SKILL.md').existsSync();
    })
    .toList()
  ..sort((a, b) => a.path.compareTo(b.path));

void _copyTree(Directory from, Directory to) {
  to.createSync(recursive: true);
  for (final entity in from.listSync(recursive: true)) {
    final relative = entity.path.substring(from.path.length + 1);
    if (entity is Directory) {
      Directory('${to.path}/$relative').createSync(recursive: true);
    } else if (entity is File) {
      File('${to.path}/$relative')
        ..parent.createSync(recursive: true)
        ..writeAsBytesSync(entity.readAsBytesSync());
    }
  }
}

Future<void> main(List<String> args) async {
  var global = false;
  var list = false;
  var remove = false;
  String? projectRoot;
  String? homeOverride;
  final requested = <String>[];

  for (var i = 0; i < args.length; i++) {
    final arg = args[i];
    switch (arg) {
      case '-h' || '--help':
        _usage();
        return;
      case '-g' || '--global':
        global = true;
      case '--list':
        list = true;
      case '--remove':
        remove = true;
      case '--project-root':
        if (++i >= args.length) _fail('--project-root needs a value');
        projectRoot = args[i];
      case '--home':
        if (++i >= args.length) _fail('--home needs a value');
        homeOverride = args[i];
      default:
        if (arg.startsWith('-')) _fail('unknown option $arg (see --help)');
        requested.add(arg.toLowerCase());
    }
  }

  final home = homeOverride ??
      Platform.environment['HOME'] ??
      Platform.environment['USERPROFILE'];
  if (global && home == null) _fail('cannot determine home directory');
  final root = Directory(projectRoot ?? Directory.current.path);
  if (!root.existsSync()) _fail('project root ${root.path} does not exist');

  // Resolve agent names → targets.
  final known = {for (final t in targets) t.name: t};
  List<AgentTarget> selected;
  if (requested.contains('all')) {
    selected = targets.toList();
  } else if (requested.isNotEmpty) {
    selected = requested.map((name) {
      final t = known[name];
      if (t == null) {
        _fail('unknown agent "$name" — expected one of: '
            '${known.keys.join(', ')}, all');
      }
      return t;
    }).toList();
  } else {
    final base = global ? home! : root.path;
    selected = targets
        .where((t) => t.detectMarkers
            .any((m) => Directory('$base/$m').existsSync()))
        .toList();
    if (selected.isEmpty && !list) {
      stdout.writeln('No agent directories detected in '
          '${global ? '~ ($base)' : base}.');
      stdout.writeln(
          'Name agents explicitly, e.g.: dart run fxdart:install_skills '
          'claude codex');
      _usage();
      exit(1);
    }
    if (list && selected.isEmpty) selected = targets.toList();
  }

  // Several agents share .agents/skills — deduplicate by destination.
  final byDest = <String, List<String>>{};
  for (final t in selected) {
    final dest =
        global ? '$home/${t.globalDir}' : '${root.path}/${t.projectDir}';
    byDest.putIfAbsent(dest, () => []).add(t.name);
  }

  final source = await _skillsSource();
  final skills = _skillDirs(source);
  if (skills.isEmpty) _fail('no fxdart-* skills found in ${source.path}');
  final skillNames = [
    for (final d in skills) d.uri.pathSegments.lastWhere((s) => s.isNotEmpty)
  ];

  for (final MapEntry(key: dest, value: agents) in byDest.entries) {
    final label = agents.join(', ');
    if (list) {
      final installed = skillNames
          .where((n) => File('$dest/$n/SKILL.md').existsSync())
          .toList();
      final status = installed.isEmpty
          ? 'not installed'
          : 'installed: ${installed.join(', ')}';
      stdout.writeln('$label → $dest ($status)');
      continue;
    }
    if (remove) {
      var removed = 0;
      for (final name in skillNames) {
        final dir = Directory('$dest/$name');
        if (dir.existsSync()) {
          dir.deleteSync(recursive: true);
          removed++;
        }
      }
      stdout.writeln('$label → removed $removed skill(s) from $dest');
      continue;
    }
    for (final skill in skills) {
      final name = skill.uri.pathSegments.lastWhere((s) => s.isNotEmpty);
      final target = Directory('$dest/$name');
      if (target.existsSync()) target.deleteSync(recursive: true);
      _copyTree(skill, target);
    }
    stdout.writeln('$label → installed ${skillNames.join(', ')} into $dest');
  }
}
