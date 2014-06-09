# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: resque-analytics 0.6.0 ruby lib

Gem::Specification.new do |s|
  s.name = "resque-analytics"
  s.version = "0.6.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nir Tzur"]
  s.date = "2014-06-09"
  s.description = "Shows Resque jobs key performance indciators over time"
  s.email = "nir.tzur@samanage.com"
  s.extra_rdoc_files = [
    "LICENSE",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    "Changelog",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "lib/resque-analytics.rb",
    "lib/resque-analytics/server.rb",
    "lib/resque-analytics/server/views/analytics.erb",
    "lib/resque/plugins/analytics.rb",
    "resque-analytics.gemspec"
  ]
  s.homepage = "http://github.com/nirtzur/resque-analytics"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "2.1.11"
  s.summary = "Resque Job Analytics"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<resque>, ["= 1.25.1"])
      s.add_runtime_dependency(%q<googlecharts>, ["= 1.6.8"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
      s.add_development_dependency(%q<byebug>, [">= 0"])
    else
      s.add_dependency(%q<resque>, ["= 1.25.1"])
      s.add_dependency(%q<googlecharts>, ["= 1.6.8"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<byebug>, [">= 0"])
    end
  else
    s.add_dependency(%q<resque>, ["= 1.25.1"])
    s.add_dependency(%q<googlecharts>, ["= 1.6.8"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<byebug>, [">= 0"])
  end
end

