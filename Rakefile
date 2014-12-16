require "bundler/gem_tasks"
require "rake/testtask"

task :default => [ :test ]

task :tasks do
  puts "Tasks:"
  puts "test : Run unit tests"
end

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList[ 'test/test_*.rb' ]
  t.verbose = true
end
