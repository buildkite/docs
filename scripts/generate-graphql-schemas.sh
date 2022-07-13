#!/bin/bash
scripts_dir="$(dirname "${BASH_SOURCE[0]}")"

mkdir ${scripts_dir}/../pages/apis/graphql/schemas
rm -rf ${scripts_dir}/../pages/apis/graphql/schemas/*

ruby "${scripts_dir}/generate-graphql-schema-pages.rb"
