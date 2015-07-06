require 'rake'
require 'rake/testtask'
require 'bundler/gem_tasks'
 
Rake::TestTask.new do |t|
  t.test_files = Dir.glob('spec/**/*_spec.rb')
  t.libs.push 'spec'
end

desc "Automated setup of development environment"
task :setup do
  system('bundle install')
end
 
desc "Start an IRB console with the ledger environment already setup"
task :console do
  require 'irb'
  require File.expand_path('../lib/ledger', __FILE__)
  include Ledger

  ARGV.clear
  IRB.start
end

