# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{roxx}
  s.version = "1.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Boy Maas"]
  s.date = %q{2011-03-28}
  s.description = %q{Wrapper around Sox to generate multitrack files}
  s.email = %q{boy.maas@gmail.com}
  s.executables = ["extract_audio_and_remove_silence.rb", "roxx"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".rvmrc",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "bin/extract_audio_and_remove_silence.rb",
    "bin/roxx",
    "docs/recording-tapes.mkd",
    "docs/spec.txt",
    "lib/roxx.rb",
    "lib/roxx/cache_info.rb",
    "lib/roxx/ecasound_renderable.rb",
    "lib/roxx/effect.rb",
    "lib/roxx/preset.rb",
    "lib/roxx/script.rb",
    "lib/roxx/shell.rb",
    "lib/roxx/silence.rb",
    "lib/roxx/sound.rb",
    "lib/roxx/sound_info.rb",
    "lib/roxx/sox_renderable.rb",
    "lib/roxx/tmpfiles.rb",
    "lib/roxx/track.rb",
    "roxx.gemspec",
    "spec/caching_spec.rb",
    "spec/data/intro.wav",
    "spec/data/recordings-paragraph.txt",
    "spec/data/script.txt",
    "spec/helpers.rb",
    "spec/roxx_spec.rb",
    "spec/sound_info_spec.rb",
    "spec/spec_helper.rb",
    "spec/tmp/README",
    "support/JackOSX.0.87_64-32bits.zip",
    "support/discord-3.2.1.tar.bz2",
    "support/ecasound-2.7.2.tar.gz"
  ]
  s.homepage = %q{http://github.com/boymaas/roxx}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.6.1}
  s.summary = %q{Wrapper around Sox}
  s.test_files = [
    "spec/caching_spec.rb",
    "spec/helpers.rb",
    "spec/roxx_spec.rb",
    "spec/sound_info_spec.rb",
    "spec/spec_helper.rb"
  ]

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<facets>, [">= 0"])
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
      s.add_runtime_dependency(%q<blankslate>, [">= 0"])
      s.add_runtime_dependency(%q<ruby-debug>, [">= 0"])
      s.add_development_dependency(%q<bacon>, [">= 0"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.5.2"])
    else
      s.add_dependency(%q<facets>, [">= 0"])
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<blankslate>, [">= 0"])
      s.add_dependency(%q<ruby-debug>, [">= 0"])
      s.add_dependency(%q<bacon>, [">= 0"])
      s.add_dependency(%q<bundler>, ["~> 1.0.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
    end
  else
    s.add_dependency(%q<facets>, [">= 0"])
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<blankslate>, [">= 0"])
    s.add_dependency(%q<ruby-debug>, [">= 0"])
    s.add_dependency(%q<bacon>, [">= 0"])
    s.add_dependency(%q<bundler>, ["~> 1.0.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.5.2"])
  end
end

