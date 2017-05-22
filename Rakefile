#!/usr/bin/env rake
begin
  require "bundler/setup"
rescue LoadError
  puts "You must `gem install bundler` and `bundle install` to run rake tasks"
end

APP_RAKEFILE = File.expand_path("../test/dummy/Rakefile", __FILE__)
load "rails/tasks/engine.rake"
load "rails/tasks/statistics.rake"
require "rake/testtask"

require "rake/testtask"
Rake::TestTask.new(:test) do |t|
  t.libs << "lib"
  t.libs << "test"
  t.pattern = "test/**/*_test.rb"
  t.verbose = false
end
task default: :test

$LOAD_PATH.unshift File.expand_path("../lib", __FILE__)
require "workarea/avatax/version"

desc "Release version #{Workarea::Avatax::VERSION} of the gem"
task :release do
  host = "https://#{ENV['BUNDLE_GEMS__WEBLINC__COM']}@gems.weblinc.com"

  system "git tag -a v#{Workarea::Avatax::VERSION} -m 'Tagging #{Workarea::Avatax::VERSION}'"
  system "git push --tags"

  system "gem build workarea-avatax.gemspec"
  system "gem push workarea-avatax-#{Workarea::Avatax::VERSION}.gem --host #{host}"
  system "rm workarea-avatax-#{Workarea::Avatax::VERSION}.gem"
end
