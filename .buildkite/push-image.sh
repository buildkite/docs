#!/bin/bash

set -eu

echo "--- :docker: Building docker image"

TAG="${BUILDKITE_BUILD_NUMBER}"

docker build -t "$ECR_REPO:$TAG" .

echo "--- :docker: Pushing docker image"

docker push "$ECR_REPO:$TAG"
