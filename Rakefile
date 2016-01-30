require 'rake'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = Dir.glob('spec/**/*_spec.rb')
end

RuboCop::RakeTask.new(:rubocop) do |task|
  task.formatters = ['progress']
  task.fail_on_error = false
end

task default: [:spec, :rubocop]

task :start do
  exec 'ruby -Ilib ./bin/cows_bulls_arena'
end

task :install do
  Dir.chdir('./lib/cows_bulls_arena/node') do
    exec 'npm install'
  end
end