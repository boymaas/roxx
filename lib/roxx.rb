require 'facets'
require 'yaml'
require 'pathname'
require 'md5'
require 'fileutils'
require 'tempfile'
require 'active_support/core_ext' # extract options etc

require 'ruby-debug'

# add current-dir to load-path
$:.unshift(File.expand_path(File.dirname(__FILE__))) unless
    $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'roxx/cache_info'
require 'roxx/sound_info'
require 'roxx/hexdigest'

require 'roxx/shell'
require 'roxx/tmpfiles'

require 'roxx/sox_renderable'

require 'roxx/script'
require 'roxx/track'
require 'roxx/sound'
require 'roxx/silence'
require 'roxx/effect'

# DSL
#
def script &block
  ( script = Script.new ).instance_eval &block
  script
end
