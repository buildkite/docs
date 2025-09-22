#!/usr/bin/env sh

set -e

apk add jq

touch annotation.md

# We need to wait until rails has started before running muffet as otherwise it will error out
# and the test will appear to have failed without having run. The time to wait is hard to
# predict, and furthermore, some paths take longer to be be ready than others. The path in this
# loop was chosen after some non-systematic observations. So it does not guarantee that the
# server will be ready. But it seems to work well in practice.
#
while ! wget --spider -S http://app:3000/docs/agent/v3/hooks;
  do echo 💎🛤️🦥 Rails is still starting;
  sleep 0.5;
done
echo 💎🛤️🚆 Rails has started running

# If muffet fails, we want to process the results instead of quitting immediately.
set +e

# Exclude links that show up as failures but definitely work
# Accept 403's access denied status codes, as these are mostly sites blocking muffet
# Ignore fragments (e.g. markdown heading links) because GitHub doesn't tag headings properly
# Add a user agent so less sites respond with 403 or 429 statuses

/muffet http://app:3000/docs \
  --exclude="https://buildkite.com/docs" \
  --exclude="https://api.buildkite.com/" \
  --exclude="https://buildkite.com/%7E/bazel-monorepo-example" \
  --exclude="https://buildkite.com/my-organization/" \
  --exclude="https://buildkite.com/organizations" \
  --exclude="https://buildkite.com/user" \
  --exclude="https://cd.apps.argoproj.io/swagger-ui" \
  --exclude="https://console.aws.amazon.com/cloudformation/home" \
  --exclude="https://console.aws.amazon.com/ec2/v2/home" \
  --exclude="https://console.cloud.google.com/compute/instancesAdd#preconfigured-image-ubuntu-1604-xenial-v20170202" \
  --exclude="https://docs.cursor.com/en/context/mcp#using-mcp-json" \
  --exclude="https://github.com/buildkite/agent" \
  --exclude="https://github.com/buildkite/backstage-plugin" \
  --exclude="https://github.com/buildkite/buildkite-logs" \
  --exclude="https://github.com/buildkite/buildkite-mcp-server" \
  --exclude="https://github.com/buildkite/buildkite-sdk" \
  --exclude="https://github.com/buildkite/docs/" \
  --exclude="https://github.com/buildkite/elastic-ci-stack-for-aws" \
  --exclude="https://github.com/buildkite/emojis" \
  --exclude="https://github.com/buildkite/test-collector-ruby/blob/d9fe11341e4aa470e766febee38124b644572360/lib/buildkite/test_collector.rb#L" \
  --exclude="https://github.com/cybeats/sbomgen" \
  --exclude="https://github.com/floraison/fugit" \
  --exclude="https://github.com/hashicorp/hcl" \
  --exclude="https://github.com/honeycombio/buildevents" \
  --exclude="https://github.com/joscha/ShardyMcShardFace" \
  --exclude="https://github.com/KnapsackPro/knapsack_pro-ruby" \
  --exclude="https://github.com/marketplace" \
  --exclude="https://github.com/my-org/" \
  --exclude="https://github.com/rspec/rspec-core" \
  --exclude="https://schemas.xmlsoap.org/ws/2005/05/identity/claims/name" \
  --exclude="https://webtask.io/" \
  --exclude="/sample.svg" \
  --header="User-Agent: Muffet/$(/muffet --version)" \
  --max-connections=10 \
  --timeout=15 \
  --buffer-size=8192 \
  --format=json \
  > muffet-results.json

muffet_exit_code=$?
set -e

# We want to see muffet's output in its natural habitat (the build log) in case
# something goes wrong, e.g. the output is not valid JSON for some reason, or we
# hit a bug in the annotation-making code below.
#
cat muffet-results.json

if [ "0" = "$muffet_exit_code" ]; then
    echo "Muffet found no problems :sunglasses:"
else
    # Use jq to transform JSON output from muffet into a Markdown table.
    #
    # This place is not a place of honor. No highly esteemed deed is
    # commemorated here. Nothing valued is here.
    #
    # This is some of the worst and most advanced jq I have ever written.
    #
    # DuckDB would do this job far more easily, but it's not available in the
    # Alpine container image where this script gets executed during CI, and I'm
    # already awash with yak hair. If you find yourself able to swap this out
    # for DuckDB (or any other tool that would do the job more elegantly), I
    # encourage you to do so.
    #
    # -- @lucaswilric, July 2025
    #
    #shellcheck disable=SC2016
    jq_query='. |
    map(.page = (.url | sub("https?:\/\/[^\/]+"; ""))) |
    map(.links_str = (.links | map("| "+.url+" | "+.error+" |") | join("\n"))) |
    map("In `"+.page+"`:\n\n| Link | Status |\n|--|--|\n"+.links_str) | .[]'

    {
        echo "## Muffet found the following link issues"
        echo
        echo "Before looking at the list of links below to work out what's going on, ignore links with **429**, **403** or **timeout** statuses first. Links returning these statuses will likely work (or in the case of **timeout**s, eventually work) when selected by a human."
        echo
        echo "Instead, identify genuine link issues, such as those with a **404** status (not found) or ones returning an **id #fragment-part-of-url not found** issue, and resolve them. For **id #fragment-part-of-url not found** issues, fix the link and its fragment first (since the target content may have moved, or the link and its fragment might just happen to be wrong). However, if the revised/fixed link (which you manually tested yourself) is implemented and this job still fails, you'll likely need to add this revised link's full URL (excluding any query parameters from <code>?</code> onwards, but retaining its fragment) as a new <code>--exclude</code> option to the list of existing ones in the <code>muffet.sh</code> script."
        echo
        echo "If you've added an <code>--exclude</code> entry for a link that generates an **id #fragment-part-of-url not found** error, but it still appears in the following list (that is, the link and its fragment actually works but muffet still reports it as erroneous), then remove the fragment part of the URL from its <code>--exclude</code> entry."
        echo
    } >> annotation.md

    < muffet-results.json jq -r "$jq_query" >> annotation.md

    if [ -n "$(which buildkite-agent)" ]; then
        buildkite-agent annotate --style=error --context=muffet <annotation.md
    else
        cat annotation.md
    fi

    # The logic in this script is currently quite flaky, and hence, the implementation of a 'soft fail' in this pipeline's step to allow the builds pass.

    exit $muffet_exit_code
fi
