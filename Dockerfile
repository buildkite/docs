ARG BASE_IMAGE=public.ecr.aws/docker/library/ruby:3.2.2-slim-bookworm@sha256:17de1131ceb018ab30cbb76505559baa49a4c1b125e03c90dd10220bf863783c

FROM $BASE_IMAGE AS builder

WORKDIR /app

RUN echo "--- :package: Installing system deps" \
    # Cache apt
    rm -f /etc/apt/apt.conf.d/docker-clean \
    && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache \
    # Install a few pre-reqs
    && apt-get update \
    && apt-get install -y curl gnupg \
    # Setup apt for GH cli
    && curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    # Setup apt for node
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    # Install all the things
    && apt-get update \
    && apt-get install -y nodejs gh jq build-essential \
    ## Pull down security updates
    && apt-get upgrade -y \
    # Upgrade rubygems and bundler
    && gem update --system \
    && gem install bundler \
    # clean up
    && rm -rf /tmp/*

# Install tool for generating static site
RUN curl -sf https://gobinaries.com/tj/staticgen/cmd/staticgen | sh

# Install yarn as recommended by https://yarnpkg.com/getting-started/install
RUN corepack enable && corepack prepare yarn@stable --activate

# ------------------------------------------------------------------

FROM builder AS bundle

COPY Gemfile Gemfile.lock .ruby-version ./

ARG RAILS_ENV

RUN echo "--- :bundler: Installing ruby gems" \
    && bundle config set --local without "$([ "$RAILS_ENV" = "production" ] && echo 'development test')" \
    && bundle config set force_ruby_platform true \
    && bundle install --jobs $(nproc) --retry 3

# ------------------------------------------------------------------

FROM builder as yarn

COPY package.json yarn.lock ./
RUN echo "--- :yarn: Installing node packages" && yarn

# ------------------------------------------------------------------

FROM builder as assets

COPY . /app/
COPY --from=yarn /app/node_modules /app/node_modules
COPY --from=yarn /app/.yarn /app/.yarn
COPY --from=bundle /usr/local/bundle/ /usr/local/bundle/

ARG RAILS_ENV

RUN if [ "$RAILS_ENV" = "production" ]; then \
    echo "--- Precompiling assets" \
    && RAILS_ENV=production RAILS_GROUPS=assets SECRET_KEY_BASE=xxx bundle exec rake assets:precompile \
    && cp -r /app/public/docs/assets /app/public/assets; \
    fi

# ------------------------------------------------------------------

FROM $BASE_IMAGE AS runtime

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
COPY --from=bundle /usr/local/bundle/ /usr/local/bundle/
COPY --from=assets /app/public/ /app/public/

RUN bundle exec rake sitemap:create

EXPOSE 3000
CMD ["bundle", "exec", "puma", "-C", "./config/puma.rb"]
