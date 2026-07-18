
1. Go to https://app.codecov.io and sign in with GitHub (Codecov reads your repo list from your GitHub identity).
2. If this is your first time, Codecov will ask to install its GitHub App. Grant it access to at least BansookNam/FxDart. You can pick "Only select repositories" — it does not need org-wide access.
3. In the Codecov dashboard, find FxDart in the repo list and click it. If it isn't listed, hit the re-sync/refresh button on the repo list page — Codecov caches your repo list and a brand-new repo often needs one sync.
4. The repo's setup page shows a section like "Step 1: add repository token" with a value labeled CODECOV_TOKEN. Copy that UUID-looking string.

Step 2 — Store the token as a GitHub Actions secret

Either through the web UI:

1. https://github.com/BansookNam/FxDart/settings/secrets/actions
2. New repository secret
3. Name: CODECOV_TOKEN (exact — the workflow references it by that name)
4. Secret: paste the token → Add secret

Or, since you're already authenticated with gh, I can run this for you — you'd paste the token and I'd pipe it in:

gh secret set CODECOV_TOKEN --repo BansookNam/FxDart


Say the word and I'll run it (it prompts for the value, so the token never lands in your shell history or in this transcript as a command argument).

Step 3 — Commit and push

The four changed files are still uncommitted in your working tree:

.github/workflows/coverage.yml   (new)
pubspec.yaml                     (coverage dev_dependency)
.gitignore                       (coverage/)
README.md                        (badge + testing note)

Push to main, or open a PR — the workflow triggers on both. I can commit and push these for you if you want; just tell me which (direct to main or a branch + PR).

Step 4 — Watch the first run

gh run watch --repo BansookNam/FxDart

Or the Actions tab. The run should take ~1–2 min. What to expect:

- The Upload coverage to Codecov step prints the report URL on success.
- If the token is missing or wrong, that step logs a rate-limit or auth warning but the job still passes green — I set fail_ci_if_error: false, matching nav. So a green check does not by itself prove the upload worked; read the step's log the first time.

Step 5 — Confirm the badge renders

The badge image is served by Codecov and only turns from grey unknown to a percentage after the first successful upload is processed. Give it a minute after the run, then hard-refresh https://github.com/BansookNam/FxDart. Expect it to read roughly 92%, matching the local run.

One judgement call worth flagging

nav's README claims 100% line coverage and embeds a sunburst graph. FxDart is at 92.3%, so I deliberately did not copy that framing — I wrote a neutral "coverage is measured on every push" line instead. If you'd rather match nav's style, I can add the sunburst image once the first upload lands (the graph URL 404s until Codecov has data). And if you want to actually chase 100%, the 96 uncovered lines are identifiable from coverage/lcov.info — I can break down where they are.
