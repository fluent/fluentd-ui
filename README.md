# fluentd-ui

[![Build Status](https://travis-ci.org/fluent/fluentd-ui.svg?branch=master)](https://travis-ci.org/fluent/fluentd-ui)
[![Gem Version](https://badge.fury.io/rb/fluentd-ui.svg)](http://badge.fury.io/rb/fluentd-ui)
[![Code Climate](https://codeclimate.com/github/fluent/fluentd-ui/badges/gpa.svg)](https://codeclimate.com/github/fluent/fluentd-ui)

fluentd-ui is a browser-based [fluentd](http://www.fluentd.org) and [td-agent](https://docs.treasuredata.com/articles/td-agent) manager that supports following operations.

* Install, uninstall, and upgrade Fluentd plugins
* start/stop/restart fluentd process
* Configure Fluentd settings such as config file content, pid file path, etc
* View Fluentd log with simple error viewer

[Official documentation](https://docs.fluentd.org/deployment/fluentd-ui) \| [Changelog](./ChangeLog.md)


## Requirements

- ruby 2.2.2 or later (since v1.0.0)
- fluentd v1.0.0 or later (also supports td-agent 3)
  - Currently, fluentd v1 and td-agent 3 support is in alpha state

And some additional packages (Debian / Ubuntu)

- build-essential
- libssl-dev
- libxml2-dev
- libxslt1-dev
- ruby-dev

## How to install and run

    $ gem install fluentd-ui
    $ fluentd-ui setup
    $ fluentd-ui start --daemonize

Access http://localhost:9292 by web browser.
The default account is username="admin" and password="changeme".

### Run under sub path

Use `RAILS_RELATIVE_URL_ROOT` environment variable.

   $ RAILS_RELATIVE_URL_ROOT=/prefix fluentd-ui start --daemonize

Access http://localhost:9292/prefix by web browser.

## Development

### Get the source

    $ git clone https://github.com/fluent/fluentd-ui
    $ cd fluentd-ui

### Install dependent gems

Use bundler:

    $ gem install bundler
    $ bundle install --path vendor/bundle

### Install dependent JavaScript packages

Use [yarn](https://yarnpkg.com/).
See https://yarnpkg.com/en/docs/install to install it to your environment.
After install it, run following command:

    $ ./bin/yarn install

### Run fluentd-ui

    $ bin/rails server

Access http://localhost:3000 by web browser.

#### Run with Docker

    $ docker build -t fluent/fluentd-ui:1.0.0 .
    $ docker run --net=host fluent/fluentd-ui:1.0.0


### Run tests

You need [chromedriver](https://sites.google.com/a/chromium.org/chromedriver/downloads) or chromiumdriver to run tests.

    $ npm install -g chromedriver
    Or,
    $ brew install chromedriver
    Or,
    $ sudo apt install chromium-driver

NOTE: `chromedriver` executable binary should be located under your `$PATH`.

After that you can run tests by following command:

    $ bundle exec rake test

### Building fluentd-ui.gem

    # Generate ChangeLog.md and increment version
    $ bin/rails release:prepare

    # Clear tmp/, public/assets and public/packs
    $ bin/rails tmp:clear assets:clobber && touch tmp/.gitkeep

    # Generate pre-compiled assets
    $ RAILS_ENV=production bin/rails assets:precompile

    # fluentd-ui X.X.X built to pkg/fluentd-ui-X.X.X.gem.
    $ RAILS_ENV=production bin/rails build

    # Push to rubygems.org
    $ bin/rails release
