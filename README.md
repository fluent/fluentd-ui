# fluentd-ui

[![build status](https://circleci.com/gh/fluent/fluentd-ui.png?style=shield&circle-token=a739a52ae9ae6774ab2192d4236a5f93ac29e11e)](https://circleci.com/gh/fluent/fluentd-ui)
[![Gem Version](https://badge.fury.io/rb/fluentd-ui.svg)](http://badge.fury.io/rb/fluentd-ui)
[![Code Climate](https://codeclimate.com/github/fluent/fluentd-ui/badges/gpa.svg)](https://codeclimate.com/github/fluent/fluentd-ui)

fluentd-ui is a browser-based [fluentd](http://fluentd.org/) and [td-agent](http://docs.treasuredata.com/articles/td-agent) manager that supports following operations.

* Install, uninstall, and upgrade Fluentd plugins
* start/stop/restart fluentd process
* Configure Fluentd settings such as config file content, pid file path, etc
* View Fluentd log with simple error viewer

[Official documentation](http://docs.fluentd.org/articles/fluentd-ui) \| [Changelog](./ChangeLog.md)


## Requirements

- ruby 2.1.3 or later (since v0.4.0)

And some additional packages (Debian / Ubuntu)

- build-essential
- libssl-dev
- libxml2-dev
- libxslt1-dev
- ruby-dev

## Development

    $ git clone https://github.com/treasure-data/fluentd-ui
    $ cd fluentd-ui
    $ bundle install
    $ bundle exec rails s

Also you need a phantomjs for test.

    $ npm install -g phantomjs
    Or,
    $ brew install phantomjs

NOTE: `phantomjs` executable binary should be located under your `$PATH`.

## Building fluentd-ui.gem

    $ bundle exec rake build
    fluentd-ui X.X.X built to pkg/fluentd-ui-X.X.X.gem.

    $ bundle exec rake release
    # Push to rubygems.org
