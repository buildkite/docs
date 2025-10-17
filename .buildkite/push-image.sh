#!/bin/bash

set -eu

echo "--- :docker: Building docker image"

TAG="${BUILDKITE_BUILD_NUMBER}"

docker build -t "$ECR_REPO:$TAG" \
  --target="runtime" \
  --build-arg="RAILS_ENV=production" \
  --build-arg="DD_RUM_VERSION=$BUILDKITE_BUILD_NUMBER" \
  --build-arg="DD_RUM_ENV=production" \
  --push \
  --provenance=false \
  .
