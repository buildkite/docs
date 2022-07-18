#!/bin/bash
scripts_dir="$(dirname "${BASH_SOURCE[0]}")"

rm -rf ${scripts_dir}/../pages/apis/graphql/schemas/*
ruby "${scripts_dir}/generate_graphql_api_content.rb"
