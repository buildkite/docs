ARG BASE_IMAGE=public.ecr.aws/docker/library/ruby:4.0.2-slim-bookworm@sha256:ec909cc0a643fd2a6df9ebf4a1789594e389f029c148df477be646dcd06361c2
ARG NODE_IMAGE=public.ecr.aws/docker/library/node:24-bookworm-slim@sha256:879b21aec4a1ad820c27ccd565e7c7ed955f24b92e6694556154f251e4bdb240

FROM $BASE_IMAGE AS builder

WORKDIR /app

RUN echo "--- :package: Installing system deps" \
    # Cache apt
    rm -f /etc/apt/apt.conf.d/docker-clean \
    && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache \
    # Install a few pre-reqs
    && apt-get update \
    && apt-get install -y curl gnupg libyaml-dev \
    # Setup apt for GH cli
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    # Install all the things
    && apt-get update \
    && apt-get install -y gh jq build-essential python3 \
    ## Pull down security updates
    && apt-get upgrade -y \
    # Upgrade rubygems and bundler
    && gem update --system \
    && gem install bundler \
    # clean up
    && rm -rf /tmp/*

# ------------------------------------------------------------------

FROM builder AS bundle

COPY Gemfile Gemfile.lock ./

ARG RAILS_ENV

RUN echo "--- :bundler: Installing ruby gems" \
    && bundle config set --local without "$([ "$RAILS_ENV" = "production" ] && echo 'development test')" \
    && bundle config set force_ruby_platform false \
    && bundle install --jobs $(nproc) --retry 3

# ------------------------------------------------------------------

FROM $NODE_IMAGE AS node-deps

COPY package.json yarn.lock ./
RUN echo "--- :yarn: Installing node packages" && yarn

# ------------------------------------------------------------------

FROM public.ecr.aws/docker/library/golang:1.26-bookworm AS gobuild

# This was previously installed from gobinaries.com within
# the deploy-preview step, but gobinaries.com keeps being unavailable :(
RUN go install github.com/tj/staticgen/cmd/staticgen@v1.1.0

# ------------------------------------------------------------------

FROM builder AS assets

COPY . /app/
COPY --from=node-deps /usr/local/bin /usr/local/bin
COPY --from=node-deps /node_modules /app/node_modules
COPY --from=bundle /usr/local/bundle/ /usr/local/bundle/

ARG RAILS_ENV

RUN if [ "$RAILS_ENV" = "production" ]; then \
    echo "--- :vite: Compiling assets" \
    && RAILS_ENV=production RAILS_GROUPS=assets SECRET_KEY_BASE=xxx bundle exec rake assets:precompile \
    && cp -r /app/public/docs/assets /app/public/assets; \
    fi

# ------------------------------------------------------------------

FROM $BASE_IMAGE AS runtime

RUN apt-get update \
    && apt-get upgrade -y \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ARG RAILS_ENV
ARG DD_RUM_VERSION="unknown"
ARG DD_RUM_ENV="unknown"

# Config. Don't love this.
ENV RAILS_ENV=$RAILS_ENV
ENV DD_RUM_ENV=${DD_RUM_ENV}
ENV DD_RUM_VERSION=${DD_RUM_VERSION}
ENV DD_RUM_ENABLED=true
ENV RAILS_SERVE_STATIC_FILES=true
ENV SECRET_KEY_BASE=xxx

COPY . /app
COPY --from=node-deps /usr/local/bin /usr/local/bin
COPY --from=node-deps /node_modules /app/node_modules
COPY --from=bundle /usr/local/bundle/ /usr/local/bundle/
COPY --from=assets /app/public/ /app/public/

RUN bundle exec rake sitemap:create

EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "./config/puma.rb"]

# ------------------------------------------------------------------
#
# We use this image to deploy previews to Netlify.
#
# It needs npm packages installed by Yarn in node-deps, as well as jq, curl and
# staticgen for our orchestration machinery.
#

FROM runtime AS deploy-preview

# bin/deploy-preview has a couple of dependencies
RUN apt-get update && \
    apt-get install -y curl jq && \
    apt purge --assume-yes linux-libc-dev

COPY --from=gobuild /go/bin/staticgen /usr/local/bin/staticgen

# ------------------------------------------------------------------
#
# We use this image to run Muffet, a link checking tool.
#
# We use a Ruby wrapper script to process the results in ways that
# make sense to us.
#

FROM raviqqe/muffet:2.11.2 AS muffet-scratch
FROM ${BASE_IMAGE} AS muffet

RUN apt-get update && \
    apt-get install -y curl jq wget && \
    apt purge --assume-yes linux-libc-dev

COPY --from=muffet-scratch /muffet /muffet

# ------------------------------------------------------------------
#
# Here, we ensure that the `runtime` image is the final result if this
# Dockerfile is invoked without specifying a target.
#
FROM runtime
