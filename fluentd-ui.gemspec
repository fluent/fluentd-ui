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
  spec.license       = "Apache-2.0"

  unless (ARGV & %w(rake build)).length.zero?
    # NOTE: `fluentd-ui start` will run `bundle exec ...`. so this gemspec file evaluated by bundler then exec `git ls-files`
    #       but `git ls-files` would be warn if $PWD is not git dir, and unnecessary this step for to do it.
    #       And spec.files required for building a .gem only.
    #       Thus git ls-files only invoked with `rake build` command
    spec.files         = `git ls-files`.split($/)
    # Add pre-compiled assets
    Dir.chdir(__dir__) do
      Dir.glob("public/assets/.sprockets-manifest-*.json") do |file|
        spec.files << file
      end
      Dir.glob("public/{assets,packs}/*") do |file|
        spec.files << file
      end
    end
  end
  spec.executables   = ["fluentd-ui"]
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "fluentd", [">= 1.0.0", "< 2"]
  spec.add_dependency 'rails', '~> 5.2.0'
  spec.add_dependency "dig_rb", "~> 1.0.0"
  spec.add_dependency "bootsnap", ">= 1.1.0"
  spec.add_dependency 'sucker_punch', "~> 2.0.4"
  spec.add_dependency 'addressable'
  spec.add_dependency "font-awesome-rails"
  spec.add_dependency 'sass-rails', '~> 5.0.7'
  spec.add_dependency "haml-rails", "~> 2.0"
  spec.add_dependency 'jbuilder', '~> 2.0'
  spec.add_dependency "draper", '~> 3.0'
  spec.add_dependency "bundler"
  spec.add_dependency "httpclient", "~> 2.5" # same as td-agent
  spec.add_dependency "settingslogic"
  spec.add_dependency "puma"
  spec.add_dependency "thor"
  spec.add_dependency "kramdown", "> 1.0.0"
  spec.add_dependency "kramdown-haml"
  spec.add_dependency "rubyzip", "~> 1.1" # API changed as Zip::ZipFile -> Zip::File since v1.0.0
  spec.add_dependency "diff-lcs"
  spec.add_dependency "webpacker"

  spec.add_dependency "fluent-plugin-td", "~> 1.0"
  spec.add_dependency "fluent-plugin-mongo", "~> 1.1"
  spec.add_dependency "fluent-plugin-elasticsearch", "~> 2.10"
  spec.add_dependency "fluent-plugin-s3", "~> 1.1"
end
