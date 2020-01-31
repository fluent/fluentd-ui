FROM ruby:2.7.0-slim

LABEL maintainer="Fluentd developers <fluentd@googlegroups.com>"
LABEL description="fluentd-ui docker image"
LABEL Vendor="Fluent Organization"

RUN apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    libxml2-dev \
    libxslt1-dev \
    ruby-dev \
 && rm -rf /var/lib/apt/lists/*

RUN gem install fluentd-ui

EXPOSE 9292

ENTRYPOINT [ "fluentd-ui", "start" ]
