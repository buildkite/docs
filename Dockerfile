ARG BASE_IMAGE=public.ecr.aws/docker/library/ruby:3.4.2-slim-bookworm@sha256:2864c6bfcf8fec6aecbdbf5bd7adcb8abe9342e28441a77704428decf59930fd
ARG NODE_IMAGE=public.ecr.aws/docker/library/node:18-bookworm-slim@sha256:d2d8a6420c9fc6b7b403732d3a3c5395d016ebc4996f057aad1aded74202a476

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
    && apt-get install -y gh jq build-essential \
    ## Pull down security updates
    && apt-get upgrade -y \
    # Upgrade rubygems and bundler
    && gem update --system \
    && gem install bundler \
    # clean up
    && rm -rf /tmp/*

# ------------------------------------------------------------------

FROM builder AS bundle

COPY Gemfile Gemfile.lock .ruby-version ./

ARG RAILS_ENV

RUN echo "--- :bundler: Installing ruby gems" \
    && bundle config set --local without "$([ "$RAILS_ENV" = "production" ] && echo 'development test')" \
    && bundle config set force_ruby_platform true \
    && bundle install --jobs $(nproc) --retry 3

# ------------------------------------------------------------------

FROM $NODE_IMAGE as node-deps

COPY package.json yarn.lock ./
RUN echo "--- :yarn: Installing node packages" && yarn

# ------------------------------------------------------------------

FROM public.ecr.aws/docker/library/golang:1.24-bookworm as gobuild

# This was previously installed from gobinaries.com within
# the deploy-preview step, but gobinaries.com keeps being unavailable :(
RUN go install github.com/tj/staticgen/cmd/staticgen@v1.1.0

# ------------------------------------------------------------------

FROM builder as assets

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

# Install a few misc. deps for CI
RUN apt-get update && apt-get install -y curl jq
RUN apt purge --assume-yes linux-libc-dev

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
ENV SEGMENT_TRACKING_ID=q0LtPl49tgnyHHY8PGBsPsshHk9AVNKm
ENV SECRET_KEY_BASE=xxx

COPY . /app
COPY --from=node-deps /usr/local/bin /usr/local/bin
COPY --from=node-deps /node_modules /app/node_modules
COPY --from=bundle /usr/local/bundle/ /usr/local/bundle/
COPY --from=assets /app/public/ /app/public/
COPY --from=gobuild /go/bin/staticgen /usr/local/bin/staticgen

RUN bundle exec rake sitemap:create

EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "./config/puma.rb"]
