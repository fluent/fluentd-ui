# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fluentd-ui/version'

Gem::Specification.new do |spec|
  spec.name          = "fluentd-ui"
  spec.version       = FluentdUI::VERSION
  spec.authors       = ["Masahiro Nakagawa", "uu59"]
  spec.email         = ["repeatedly@gmail.com", "k@uu59.org"]
  spec.summary       = %q{Web UI for Fluentd}
  spec.description   = %q{Web UI for Fluentd}
  spec.homepage      = "https://github.com/fluent/fluentd-ui"
  spec.license       = "MIT"

  unless (ARGV & %w(rake build)).length.zero?
    # NOTE: `fluentd-ui start` will run `bundle exec ...`. so this gemspec file evaluated by bundler then exec `git ls-files`
    #       but `git ls-files` would be warn if $PWD is not git dir, and unnecessary this step for to do it.
    #       And spec.files required for building a .gem only.
    #       Thus git ls-files only invoked with `rake build` command
    spec.files         = `git ls-files`.split($/)
  end
  spec.executables   = ["fluentd-ui"]
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "fluentd", "~> 0.10.51"
  spec.add_dependency 'rails', '4.1.4'
  spec.add_dependency 'sucker_punch', "~> 1.0.5"
  spec.add_dependency 'i18n_generators', '1.2.1'
  spec.add_dependency 'bcrypt', '~> 3.1.5'
  spec.add_dependency 'addressable'
  spec.add_dependency "font-awesome-rails"
  spec.add_dependency 'sass-rails', '~> 4.0.3'
  spec.add_dependency "haml-rails", "~> 0.5.3"
  spec.add_dependency 'jquery-rails', "~> 3.1.0"
  spec.add_dependency 'jbuilder', '~> 2.0'
  spec.add_dependency "bundler"
  spec.add_dependency "httpclient"
  spec.add_dependency "settingslogic"
  spec.add_dependency "puma"
  spec.add_dependency "thor"
  spec.add_dependency "kramdown", "> 1.0.0"
  spec.add_dependency "kramdown-haml"
  spec.add_dependency "rubyzip", "~> 1.1" # API changed as Zip::ZipFile -> Zip::File since v1.0.0
end
