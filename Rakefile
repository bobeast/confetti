require 'bundler'
Bundler::GemHelper.install_tasks

desc "run all specs (is the default)"
task :spec do
 system "bundle exec rspec spec"
end

namespace :spec do
  # more spec running tasks here
  # whenever
end

task :default => :spec
