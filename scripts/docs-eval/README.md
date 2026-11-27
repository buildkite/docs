# Docs revamp evals

The docs-quality checks and live-site answer engine optimization (AEO) runs measure different things. Compare each track only against the same track and settings.

## Check rendered docs

Start the docs app from the checkout you want to test using the [repository setup instructions](../../README.md#run-the-development-server). Run:

```bash
python3 scripts/docs-eval/run.py docs \
  --base-url http://localhost:3000 --source "$(git rev-parse HEAD)" \
  --baseline scripts/docs-eval/baseline-v2.json --out /tmp/docs-eval
```

For uncommitted page changes, give `--source` a label that distinguishes the draft from the commit. To test the published site instead, omit `--base-url` and only pass `--source` if you can verify the deployment. The published baseline came from [Docs (Private) build 20044](https://buildkite.com/buildkite/docs-private/builds/20044): the affected pages exposed its build number in their Datadog RUM version.

Each reader case in `cases.json` defines a question and two expected checks. A score of 2 means both checks found the expected evidence, 1 means only one did, and 0 means neither did. A missing page or HTML response to a Markdown request counts as missing evidence. Network and server errors leave the case unscored. The Markdown onboarding check appears under **Agent access** and does not count toward the reader total. `report.json` gives the result, page hash, and matched lines. The page files preserve the source behind each score.

The v2 baseline replays the saved Markdown from the original published revision. It expects a setup cue on docs home, a discovery path from GitHub setup to a first build, and an example of targeting a test job to the chosen queue from the Jenkins migration guide. Keep the original `baseline.json` for historical reference. Do not compare its total with v2.

The checks look at expected content and links in rendered Markdown. They do not model a reader looking for the right page, guarantee link navigation, or prove a snippet works. Recheck any unexpected result against the saved page. If a check needs changing after a rewrite, the runner omits the old score delta for that case. Use the `human_review` notes to test tasks that need a first-time reader or a real pipeline.

## Sample answers on the live web

Use an `ANTHROPIC_API_KEY` with public web search enabled. Do not pass docs URLs to the answering model. The runner makes three independent Claude Sonnet 4.6 requests per AEO prompt and makes a separate grading request for each completed answer.

```bash
python3 scripts/docs-eval/run.py aeo --out /tmp/live-aeo
```

The report keeps the full response and citations, accuracy scores, and official docs citations that supported a material claim based on the returned excerpts. A citation without enough excerpt evidence is not counted as supported; review its page when that distinction matters. Failed requests and ungraded answers are separate from incorrect answers. The Amp pilot is not a numerical baseline for the Claude API runner. Save the first fully graded Claude `report.json` as `scripts/docs-eval/aeo-baseline.json`. The runner automatically uses that file to compare accuracy and citation counts on fully graded cases with matching definitions and settings. Daily samples can vary without a docs change.

## Run daily in Buildkite

Use a dedicated private pipeline connected to this repository and a hosted queue with Docker and Python 3. Set its default branch to `main`, do not configure push or PR triggers, and use a bootstrap step that runs `buildkite-agent pipeline upload .buildkite/pipeline.docs-evals.yml`. Leave `DOCS_EVAL_AEO_ENABLED` unset until `DOCS_EVAL_ANTHROPIC_API_KEY` is available as a Buildkite secret restricted to this pipeline and trusted `main` builds. The step condition does not enforce secret access. Draft builds must not have access to the key.

1. Once the eval files are available on a remote branch, create a manual build targeting that branch and confirm its Docs quality annotation and saved pages. AEO runs only on `main`.
1. Once the files land on `main`, run a manual build of `main`. Verify the Docs quality annotation and downloads in `docs-eval-results/docs/`.
1. Create a schedule for `main`, commit `HEAD`, at `0 0 * * *` UTC (10:00 Brisbane), matching the daily docs GraphQL run. Keep scores informational.
1. When the secret is ready, set `DOCS_EVAL_AEO_ENABLED` to `true` in the pipeline configuration. Run a manual build of `main` and verify the Live-site AEO annotation and downloads in `docs-eval-results/aeo/`. Record the first fully graded live AEO run as the baseline for that track.

To test a future draft, use the local command or select its pushed branch and commit in a manual build. The docs-quality step builds that checkout, not the public site.
