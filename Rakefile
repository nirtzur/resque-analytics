# encoding: utf-8

require 'rubygems'
require 'bundler'
require 'resque'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://guides.rubygems.org/specification-reference/ for more options
  gem.name = "resque-analytics"
  gem.homepage = "http://github.com/nirtzur/resque-analytics"
  gem.license = "MIT"
  gem.summary = %Q{Resque Job Analytics}
  gem.description = %Q{Shows Resque jobs key performance indciators over time}
  gem.email = "nir.tzur@samanage.com"
  gem.authors = ["Nir Tzur"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

desc "Code coverage detail"
task :simplecov do
  ENV['COVERAGE'] = "true"
  Rake::Task['test'].execute
end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "resque-analytics #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc "Convert multiple queues to a single summarized value"
task :multi_convert do
  require 'byebug'
  Resque.redis.keys("analytics:*").each do |key|
    _, kpi, job, date = key.split(":")
    if Resque.redis.type(key) == "string"
      Resque.redis.hincrby("resque-analytics:#{date}", "#{job}:#{kpi}", Resque.redis.get(key))
    else
      Resque.redis.hincrbyfloat("resque-analytics:#{date}", "#{job}:#{kpi}", Resque.redis.lrange(key, 0, -1).inject(0) {|sum,x| sum+x.to_f})
    end
    puts "handling #{key}\n"
  end
end