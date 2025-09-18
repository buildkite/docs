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
# Ignore framents (e.g. markdown heading links) because GitHub doesn't tag headings properly
# Add a user agent so less sites respond with 403 or 429 statuses

/muffet http://app:3000/docs \
  --exclude="https://github.com/buildkite/docs/" \
  --exclude="https://buildkite.com/user" \
  --exclude="https://buildkite.com/organizations" \
  --exclude="https://api.buildkite.com/" \
  --exclude="https://buildkite.com/my-organization/" \
  --exclude="https://github.com/my-org/" \
  --exclude="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name" \
  --exclude="https://github.com/marketplace" \
  --exclude="http://www.shellcheck.net" \
  --exclude="https://webtask.io/" \
  --exclude="/sample.svg" \
  --ignore-fragments \
  --header="User-Agent: Muffet/$(muffet --version)" \
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
        echo "## Muffet found broken links"
        echo
    } >> annotation.md

    < muffet-results.json jq -r "$jq_query" >> annotation.md

    # Select all responses where the error code is not 429. If this list is empty, 
    # then every error is a 429 and we can pass the build.
    # Note that the entire list is empty when there are no errors at all.
    if [[ $(jq -r 'map(select( (.links[].error != "429") and ( .links[].error != "403" ))) | length == 0' muffet-results.json) == true ]]; then
        echo >> annotation.md
        echo >> annotation.md
        echo "All remaining errors detected by muffet (above) are either 'Too Many Requests' (429) or 'Forbidden' (403) pages that should actually be accessible when selected by a human." >> annotation.md
        echo "These errors usually occur when the target site/page either blocks muffet's link check because muffet uses a bot account to do this, and/or the site/page has authentication implemented." >> annotation.md
        echo "Confirm the links manually (especially 403s for pages that indicate 'Forbidden') as this build will pass and ignore these failures." >> annotation.md
        muffet_exit_code=0
    fi


    if [ -n "$(which buildkite-agent)" ]; then
        buildkite-agent annotate --style=error --context=muffet <annotation.md
    else
        cat annotation.md
    fi

    exit $muffet_exit_code
fi
