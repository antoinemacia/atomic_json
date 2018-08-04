require 'bundler/gem_tasks'
require 'rake/testtask'
require 'standalone_migrations'

StandaloneMigrations::Tasks.load_tasks
Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.libs << 'lib'
  t.test_files = FileList['test/**/*_test.rb']
end

Rake::TestTask.new(:benchmark) do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/*_benchmark.rb']
end

task default: :test
