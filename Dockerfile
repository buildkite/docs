FROM public.ecr.aws/docker/library/ruby:2.7.5-buster@sha256:d76f1c822df854ecc6a983c63be3bd2e5854a6b47a3cdd140664953877d91651

ARG RAILS_ENV
ENV RAILS_ENV=${RAILS_ENV:-production}

ADD https://deb.nodesource.com/gpgkey/nodesource.gpg.key /etc/apt/trusted.gpg.d/nodesource.asc
ADD https://dl.yarnpkg.com/debian/pubkey.gpg /etc/apt/trusted.gpg.d/yarn.asc
RUN echo "--- :package: Installing system deps" \
    # Make sure apt can see trusted keys downloaded above (simpler than apt-key)
    && chmod +r /etc/apt/trusted.gpg.d/*.asc \
    # Yarn's key has carriage returns which confuses debian, so remove them
    && sed -i 's/\r//' /etc/apt/trusted.gpg.d/*.asc \
    # Cache apt
    && rm -f /etc/apt/apt.conf.d/docker-clean \
    && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache \
    # Node apt sources
    && echo "deb http://deb.nodesource.com/node_10.x stretch main" > /etc/apt/sources.list.d/nodesource.list \
    # Yarn apt sources
    && echo "deb http://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list \
    # Install all the things
    && apt-get update \
    && apt-get install -y nodejs yarn \
    # Upgrade rubygems and bundler
    && gem update --system \
    && gem install bundler \
    # clean up
    && rm -rf /tmp/*

WORKDIR /app

# Install deps
COPY Gemfile Gemfile.lock .ruby-version ./
RUN echo "--- :bundler: Installing ruby gems" \
    && bundle config set --local without "$([ "$RAILS_ENV" = "production" ] && echo 'development test')" \
    && bundle install --jobs $(($(nproc) * 4)) --retry 3

COPY package.json package-lock.json ./
RUN echo "--- :npm: Installing npm deps" \
    && npm ci

# Add the app
COPY . /app

# Compile sprockets
RUN if [ "$RAILS_ENV" = "production" ]; then \
      echo "--- :sprockets: Precompiling assets" \
      && RAILS_ENV=production RAILS_GROUPS=assets bundle exec rake assets:precompile \
      && cp -r /app/public/docs/assets /app/public/assets; \
    fi

EXPOSE 3000

# Let puma serve the static files
ENV RAILS_SERVE_STATIC_FILES=true

CMD ["bundle", "exec", "puma", "-C", "./config/puma.rb"]
