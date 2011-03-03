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
  gem.summary = %Q{TODO: one-line summary of your gem}
  gem.description = %Q{TODO: longer description of your gem}
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

task :default do
  puts "Welcome to Roxx, run rake -T to see what can be done ..."
end

namespace :roxx do
  def normalize_deps 
    # restoring sources from mp3 backup
    FileList['source-mp3/**/*.mp3'].map do |sf|
      target = Pathname.new(sf.gsub(%r{source-mp3/(.*).mp3}, 'source/\1.mp3'))
      source = Pathname.new(sf)
      file target => source do
        # create directory
        FileUtils.mkdir_p target.dirname
        sh "sox #{source} #{target} norm"
      end
      target
    end
  end

  desc "Restores mp3 sources to sources/ dir as wave files"
  task :normalize => normalize_deps
end
