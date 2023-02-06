#!/bin/bash
scripts_dir="$(dirname "${BASH_SOURCE[0]}")"

echo "Removing existing GraphQL docs..."
rm -rf ${scripts_dir}/../pages/apis/graphql/schemas/*

echo "Generating GraphQL docs..."
ruby "${scripts_dir}/generate_graphql_api_content.rb"
