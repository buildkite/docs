FROM node:6

ENV YARN_VERSION=0.16.0

# Base deps

RUN echo "--- :package: Installing system deps" \
    && npm install -g yarn@${YARN_VERSION}

WORKDIR /docs

ADD package.json yarn.lock /docs/
RUN echo "--- :yarn: Installing application deps" \
    && yarn

ADD . /docs/
