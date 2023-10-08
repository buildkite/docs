FROM public.ecr.aws/docker/library/ruby:3.1.4-bookworm@sha256:ce07ca486ea1589cdbc3df60a554c595b10a792e9a61a0363977d42e9de20726

ARG RAILS_ENV
ARG DD_RUM_VERSION="unknown"
ARG DD_RUM_ENV="unknown"

ENV DD_RUM_ENV=${DD_RUM_ENV}
ENV DD_RUM_VERSION=${DD_RUM_VERSION}
ENV DD_RUM_ENABLED=true
ENV RAILS_ENV=${RAILS_ENV:-production}
ENV SECRET_KEY_BASE=xxx

RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add -
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -

RUN echo "--- :package: Installing system deps" \
    # Cache apt
    rm -f /etc/apt/apt.conf.d/docker-clean \
    && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache \
    # Install all the things
    && apt-get update \
    && apt-get install -y nodejs gh jq \
    # Upgrade rubygems and bundler
    && gem update --system \
    && gem install bundler \
    # clean up
    && rm -rf /tmp/*

# Install yarn as recommended by https://yarnpkg.com/getting-started/install
RUN corepack enable && corepack prepare yarn@stable --activate

WORKDIR /app

# Install deps
COPY Gemfile Gemfile.lock .ruby-version ./
RUN echo "--- :bundler: Installing ruby gems" \
    && bundle config set --local without "$([ "$RAILS_ENV" = "production" ] && echo 'development test')" \
    && bundle config set force_ruby_platform true \
    && bundle install --jobs $(nproc) --retry 3

# Install tool for generating static site
RUN curl -sf https://gobinaries.com/tj/staticgen/cmd/staticgen | sh

# Add the app
COPY . /app

RUN echo "--- :npm: Installing node dependencies"
RUN yarn

# Compile assets
RUN if [ "$RAILS_ENV" = "production" ]; then \
    echo "--- Precompiling assets" \
    && RAILS_ENV=production RAILS_GROUPS=assets SECRET_KEY_BASE=xxx bundle exec rake assets:precompile \
    && cp -r /app/public/docs/assets /app/public/assets; \
    fi

# Generate sitemap
RUN bundle exec rake sitemap:create

EXPOSE 3000

# Let puma serve the static files
ENV RAILS_SERVE_STATIC_FILES=true

ENV SEGMENT_TRACKING_ID=q0LtPl49tgnyHHY8PGBsPsshHk9AVNKm

CMD ["bundle", "exec", "puma", "-C", "./config/puma.rb"]
