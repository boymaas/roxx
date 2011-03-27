require 'rubygems'
require 'facets'
require 'yaml'
require 'pathname'
require 'md5'
require 'fileutils'
require 'tempfile'
require 'active_support/core_ext' # extract options etc

require 'ruby-debug'

# Intermedia file format
# speed is a tradeoff with size
#
# rendering a 3 track file
#
# when we use an IntermediateFileFormat of :mp3 we
# use a time equal to:
#  real	3m9.979s
#  user	3m5.497s
#  sys	0m1.296s
# 
# vs a IntermediateFileFormat of :wav which uses:
#  real	0m50.699s
#  user	0m29.710s
#  sys	0m4.755s
#   
# this means wav is more than 3x faster.
#
# wav vs flac: 2x faster
# This is logical since especially the encoding of mp3 is heavy on time.
#
# CONCLUSION: aiff, wav, au 
#
# .au cannot be used in conjunction with lame .. but it' the fastest of the bunch
#


module Roxx
  IntermediateFileFormat = :wav
end

# add current-dir to load-path
$:.unshift(File.expand_path(File.dirname(__FILE__))) unless
$:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'roxx/cache_info'
require 'roxx/sound_info'

require 'roxx/shell'
require 'roxx/tmpfiles'

#require 'roxx/sox_renderable'
require 'roxx/ecasound_renderable'

require 'roxx/preset'
require 'roxx/script'
require 'roxx/track'
require 'roxx/sound'
require 'roxx/silence'
require 'roxx/effect'


module Roxx
  # DSL
  #
  def self.script &block
    ( script = Script.new ).instance_eval &block
    script
  end
end
