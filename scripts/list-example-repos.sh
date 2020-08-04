#!/usr/bin/bash

echo -e "# Example Pipelines\n" > ../pages/pipelines/example_pipelines.md.erb

wget -qO- https://raw.githubusercontent.com/buildkite/example-pipelines/master/README.md | md-extract "Lang*" | sed 's/^\*\s\[\([a-zA-Z \.\s\\//-]*\)](https:\/\/\([a-z\.\/-]*\)) - \([a-zA-Z, \/\.&]*\)/<a class="Docs__example-repo" href="https:\/\/\2">\n <span class="icon">:sparkles:<\/span>\n  <span class="detail">\n    <strong>\1<\/strong>\n     <span class="description">\3<\/span>\n    <span class="repo">\2<\/span>\n  <\/span>\n<\/a>\n/' >> ../pages/pipelines/example_pipelines.md.erb
