#!/bin/bash

set -e

echo "--- :docker: Building docker image"

TAG="${BUILDKITE_BUILD_NUMBER}"

docker build -t "$REPOSITORY:$TAG" .

echo "--- :docker: Pushing docker image"

docker push "$REPOSITORY:$TAG"
