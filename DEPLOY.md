# Deploying the FxDart site

The site lives in `docs/` and is served by GitHub Pages straight off the
default branch — there is no build artifact branch. Deploying is just
building the playground bundle and pushing `docs/`.

## One command

```bash
./deploy.sh
```

| Command | What it does |
| --- | --- |
| `./deploy.sh` | Build, commit as `docs: update GitHub Pages site`, push |
| `./deploy.sh "tweak 101 intro"` | Same, with your commit message |
| `./deploy.sh -n` | Dry run — build and print the diffstat, no commit |
| `./deploy.sh -s "msg"` | Skip the build; just commit and push |

Pages takes roughly a minute to rebuild after the push:
<https://bansooknam.github.io/FxDart/>

## What the script does

1. Runs `tools/build_single_file.sh`, which regenerates
   `docs/assets/fxdart_single.dart` — a single-file concatenation of `lib/src/`
   that the browser playground prepends to user code before sending it to the
   DartPad compile service — and analyzes it.
2. Runs `dart analyze lib`.
3. Checks that the required page resources exist (`docs/index.html`,
   `docs/101/index.html`, `docs/css/site.css`, `docs/js/playground.js`,
   `docs/assets/fxdart_single.dart`).
4. Stages `docs/`, `tools/`, `deploy.sh`, and `DEPLOY.md` — and nothing else —
   then commits and pushes to `origin/<current branch>`.

Staging is by path on purpose: a docs deploy will **not** pick up in-progress
changes in `lib/` or `test/`. If a library change belongs in the same push,
commit it yourself first, then run `./deploy.sh`.

If the build produces no changes, the script stops with
`nothing to deploy` and exits 0.

## Notes

- **Never hand-edit `docs/assets/fxdart_single.dart`.** It is generated;
  change `lib/src/` and rerun the deploy.
- The untracked `example/_snip_*.dart` files are scratch snippets from writing
  the tutorials. The script stages by path rather than using `git add -A`, so
  they are deliberately left out of deploy commits.
- Pages must be configured to serve `/docs` from the default branch
  (Settings → Pages → Source: *Deploy from a branch*, `main` + `/docs`).

## Adding a tutorial page

1. Write `docs/tutorials/<name>.html` — copy an existing page for the header,
   breadcrumb, and `.playground` structure.
2. Link it from `docs/101/index.html`.
3. Run `./deploy.sh -n` to confirm the new file is picked up, then
   `./deploy.sh "docs: add <name> tutorial"`.
