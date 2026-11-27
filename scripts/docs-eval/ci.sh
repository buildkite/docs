#!/usr/bin/env bash
set -euo pipefail

image="docs-eval:${BUILDKITE_JOB_ID}"
docker buildx build --load --target runtime --build-arg RAILS_ENV=production --tag "$image" .
container=$(docker run --detach --publish 127.0.0.1::3000 "$image")
trap 'docker rm --force "$container" >/dev/null; docker image rm "$image" >/dev/null' EXIT

base_url="http://$(docker port "$container" 3000/tcp)"
if ! curl --fail --silent --retry 10 --retry-connrefused --retry-delay 2 "$base_url/docs" -o /dev/null; then
    docker logs "$container"
    exit 1
fi

python3 scripts/docs-eval/run.py docs --base-url "$base_url" --source "${BUILDKITE_COMMIT}" \
    --baseline scripts/docs-eval/baseline.json --out docs-eval-results/docs
buildkite-agent annotate --context docs-quality --style info < docs-eval-results/docs/summary.md
