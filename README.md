# fluentd-ui

fluentd-ui is a browser-based [fluentd](http://fluentd.org/) and [td-agent](http://docs.treasuredata.com/articles/td-agent) manager than can following operations.

* Install, uninstall, and upgrade fluentd plugins
* start/stop/restart fluentd process
* Configure fluentd setting such as config file content, pidfile path, etc
* View fluentd log with simple error viewer

# Getting Started

    $ gem install fluentd-ui
    $ fluentd-ui
    # Open http://localhost:9292/ by your browser
    # default account is username="admin" and password="changeme"

Or, for developers.

    $ git clone https://github.com/treasure-data/fluentd-ui
    $ cd fluentd-ui
    $ bundle install
    $ bundle exec rails s

