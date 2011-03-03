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

def normalize_deps 
  # restoring sources from mp3 backup
  #
  # How do we normalize?
  # How do we track if files are normalzed before?
  FileList['source/**/*.mp3'].map do |sf|
    target = Pathname.new(sf.gsub(%r{source/(.*).mp3}, 'source/_normalized_tracking/\1.is.normalized'))
    source = Pathname.new(sf)
    target_mp3 = target.to_s.chomp('.is.normalized') + '.mp3'
    file target => source do
      # create directory
      FileUtils.mkdir_p target.dirname
      sh "sox #{source} #{target_mp3} norm"
      if $?.success?
        FileUtils.mv target_mp3, source
      end
      # register target .. so as not to run this file again untill it's normalized again
      FileUtils.touch target
    end
    target
  end
end

namespace :roxx do

  desc "takes all the steps necessary to have a consistent roxx:environment"
  task :default => [:normalize, :gen_suggestion_tracks]

  desc "Restores mp3 sources to sources/ dir as wave files"
  task :normalize => normalize_deps

  require 'lib/roxx'
  require 'lib/hypnotic_script'

  suggestion_track_targets = FileList['source/suggestions/*'].select {|f| File.directory?( f ) }.map do |suggestion_dir|

    # determin dirname
    suggestion_dirname = suggestion_dir.match(%r{suggestions/([\w-]+)/?})[1].to_sym
    mp3_target_part_path = "source/suggestions/#{suggestion_dirname}-part.mp3"
    mp3_target_path = "source/suggestions/#{suggestion_dirname}.mp3"

    # suggestion tracks are based upon their dependencies .. that 
    # is all mp3 stored in the suggestion dir
    file mp3_target_path => [mp3_target_part_path, *FileList["#{ suggestion_dir }/*.mp3"]] do

      # render and save track
      script do
        track :suggestions do
          generate_suggestions suggestion_dirname, :duration => 5 * 60, :interval => 2
          preset :hypnotic_voice
        end
      end.save(mp3_target_part_path)

      # now concatenate parts till 60 minute track
      script do
        track :suggestions do
          concat_sounds [mp3_target_part_path] * 12, :interval => 2
        end
      end.save(mp3_target_path)

      mp3_target_path # return from the map 
    end

  end

  desc "Render suggestion tracks for faster usage"
  task :gen_suggestion_tracks => suggestion_track_targets


end
