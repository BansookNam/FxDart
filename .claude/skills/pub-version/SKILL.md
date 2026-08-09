---
name: pub-version
description: Check what version of a Dart package is actually published on pub.dev and compare it to the local pubspec. Use before writing or restructuring a CHANGELOG section, before bumping a version, when deciding whether the top CHANGELOG section is released or in-progress, or any time you are about to assume a version shipped. pub.dev is the source of truth — never infer it from git tags, git log, or the CHANGELOG.
---

# Checking the published version on pub.dev

`https://pub.dev/packages/<name>` is the source of truth for what shipped.
**Never infer release state from git tags, `git log`, or the CHANGELOG** — in
this repo tags stop at `v0.2.0` while 22 versions are on pub.dev, the pubspec
is bumped when work *lands* rather than when it publishes, and some CHANGELOG
sections were never published under their own version number.

## Check it

The JSON API needs no auth and no browser:

```bash
curl -s -H "Accept: application/vnd.pub.v2+json" \
  https://pub.dev/api/packages/fxdart |
  python3 -c "
import sys,json
d=json.load(sys.stdin)
print('latest published:', d['latest']['version'], d['latest']['published'][:10])
print('all versions   :', ', '.join(v['version'] for v in d['versions']))
"
```

Useful fields: `latest.version`, `latest.published`, `latest.pubspec` (the
full published pubspec), and `versions[]` in publication order.

A 404 means the package name has never been published at all — that is a
valid answer, not an error to work around.

## Compare against local

```bash
# local version
grep '^version:' pubspec.yaml
# published version
curl -s -H "Accept: application/vnd.pub.v2+json" \
  https://pub.dev/api/packages/fxdart | python3 -c "import sys,json;print(json.load(sys.stdin)['latest']['version'])"
```

Three outcomes, and what each means for the CHANGELOG:

| local vs published | meaning | CHANGELOG |
|---|---|---|
| local **>** published | in-progress release, not yet shipped | the top section is the unreleased one — add to it |
| local **==** published | the tree matches what shipped | new work needs a **new** section above it, and a version bump |
| local **<** published | the checkout is behind | stop and ask; do not write release notes |

## Gaps in the version list are normal

Only published versions appear. A version that was bumped in the pubspec but
never published simply is not there — its work shipped inside whatever version
came next. `0.7.7` and `0.7.8` have CHANGELOG sections in this repo but never
reached pub.dev; both shipped as part of `0.7.9`.

So a CHANGELOG section is **not** evidence a version was released. If you are
about to say "X shipped" or split a section on that basis, check first.

## When this matters

- Writing or restructuring a CHANGELOG section (is the top one released?)
- Deciding whether to bump `pubspec.yaml`
- Answering "what's the current version" — quote pub.dev, not the pubspec
- Before telling the user a version is or isn't out

If the network is unavailable, say so and state the assumption you are
proceeding under, rather than silently falling back to the CHANGELOG.
