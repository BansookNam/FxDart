import 'dart:io';

import 'package:test/test.dart';

/// End-to-end tests for bin/install_skills.dart: runs the real executable
/// against temp directories and checks what lands on disk.
void main() {
  late Directory tmp;

  Future<ProcessResult> run(List<String> args) => Process.run(
      Platform.resolvedExecutable, ['run', 'bin/install_skills.dart', ...args]);

  setUp(() {
    tmp = Directory.systemTemp.createTempSync('fxdart_skills_test');
  });

  tearDown(() {
    if (tmp.existsSync()) tmp.deleteSync(recursive: true);
  });

  test('installs named agents into project directories, deduplicating shared '
      'destinations', () async {
    final result =
        await run(['--project-root', tmp.path, 'claude', 'codex', 'generic']);
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');

    expect(
        File('${tmp.path}/.claude/skills/fxdart-pipelines/SKILL.md')
            .existsSync(),
        isTrue);
    expect(
        File('${tmp.path}/.claude/skills/fxdart-pipelines/references/'
                'api-reference.md')
            .existsSync(),
        isTrue);
    // codex and generic share .agents/skills — installed once.
    expect(
        File('${tmp.path}/.agents/skills/fxdart-pipelines/SKILL.md')
            .existsSync(),
        isTrue);
    expect('codex, generic'.allMatches(result.stdout as String).length, 1);
  });

  test('auto-detects agents from marker directories', () async {
    Directory('${tmp.path}/.opencode').createSync(recursive: true);
    final result = await run(['--project-root', tmp.path]);
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
    expect(
        File('${tmp.path}/.opencode/skills/fxdart-pipelines/SKILL.md')
            .existsSync(),
        isTrue);
    // Undetected agents are untouched.
    expect(Directory('${tmp.path}/.claude').existsSync(), isFalse);
  });

  test('fails with guidance when nothing is detected and no agent is named',
      () async {
    final result = await run(['--project-root', tmp.path]);
    expect(result.exitCode, 1);
    expect(result.stdout, contains('No agent directories detected'));
  });

  test('--global installs under --home, including pi\'s '
      '~/.pi/agent/skills', () async {
    final result = await run(['--global', '--home', tmp.path, 'pi', 'devin']);
    expect(result.exitCode, 0, reason: '${result.stdout}\n${result.stderr}');
    expect(
        File('${tmp.path}/.pi/agent/skills/fxdart-pipelines/SKILL.md')
            .existsSync(),
        isTrue);
    expect(
        File('${tmp.path}/.config/devin/skills/fxdart-pipelines/SKILL.md')
            .existsSync(),
        isTrue);
  });

  test('--remove deletes only fxdart skills, --list reports status', () async {
    await run(['--project-root', tmp.path, 'claude']);
    // A foreign skill next to ours must survive --remove.
    File('${tmp.path}/.claude/skills/other-skill/SKILL.md')
      ..parent.createSync(recursive: true)
      ..writeAsStringSync('---\nname: other-skill\n---\n');

    final listed = await run(['--project-root', tmp.path, '--list', 'claude']);
    expect(listed.stdout, contains('installed: fxdart-pipelines'));

    final removed = await run(['--project-root', tmp.path, '--remove', 'claude']);
    expect(removed.exitCode, 0);
    expect(
        Directory('${tmp.path}/.claude/skills/fxdart-pipelines').existsSync(),
        isFalse);
    expect(File('${tmp.path}/.claude/skills/other-skill/SKILL.md').existsSync(),
        isTrue);
  });

  test('reinstall replaces stale files', () async {
    await run(['--project-root', tmp.path, 'claude']);
    final stale =
        File('${tmp.path}/.claude/skills/fxdart-pipelines/stale.txt')
          ..writeAsStringSync('old');
    await run(['--project-root', tmp.path, 'claude']);
    expect(stale.existsSync(), isFalse);
    expect(
        File('${tmp.path}/.claude/skills/fxdart-pipelines/SKILL.md')
            .existsSync(),
        isTrue);
  });
}
