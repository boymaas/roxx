require 'rubygems'
require 'bundler'
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
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "roxx"
  gem.homepage = "http://github.com/boymaas/roxx"
  gem.license = "MIT"
  gem.summary = %Q{Wrapper around Sox}
  gem.description = %Q{Wrapper around Sox to generate multitrack files}
  gem.email = "boy.maas@gmail.com"
  gem.authors = ["Boy Maas"]
  # Include your dependencies below. Runtime dependencies are required when using your gem,
  # and development dependencies are only needed for development (ie running rake tasks, tests, etc)
  #  gem.add_runtime_dependency 'jabber4r', '> 0.1'
  #  gem.add_development_dependency 'rspec', '> 1.2.3'
end
Jeweler::RubygemsDotOrgTasks.new


require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "roxx #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

# Versioning and releasing on github
namespace :release do
  #desc "create a new version, create tag and push to github"
  task :github_and_tag do
    #Rake::Task['github:release'].invoke
    Rake::Task['git:release'].invoke
  end

  [:patch, :minor, :major].each do |type|
    desc "Release new #{type} version on github" 
    task type do
      Rake::Task["version:bump:#{type}"].invoke
      Rake::Task['release:github_and_tag'].invoke
    end
  end

end

task :default do
  puts "Welcome to Roxx, run rake -T to see what can be done ..."
end

