require 'fileutils'


def clear_cache
  FileUtils.rm Dir['cache/test_*']
end
