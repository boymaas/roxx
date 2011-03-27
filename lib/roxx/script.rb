module Roxx
  class Script
    include CacheInfo
    include Shell


    def initialize
      @tracks = []
      @file = nil

      # takes too much space on device
      disable_cache_file

      @dependencies
    end

    def to_hash
      hexdigest(@tracks, [@tracks.map(&:volume)])
    end

    # all source files used in this script
    def dependencies
      @tracks.map(&:dependencies).flatten.sort.uniq
    end

    def render target
      # build all tracks
      # run cmd
      ecasound_sources = @tracks.map {|t| t.to_ecasound_param }.flatten
      command = <<-cmd.gsub(/^\s+/,'')
        ecasound #{ecasound_sources * " "} -a:#{@tracks.map(&:ecasound_channel_ref) * ','} -o #{target}
      cmd

      $stderr.puts "\n"*2 + command.gsub(/-a:[\d,]+/, "\n    \\0") + "\n"*2
      run command

    end

    # DSL
    def track name = nil, &block
      ( @tracks << Track.new(self) ).last.instance_eval( &block )
    end

    # Saving
    def save path
      render path
    end

    def cleanup
      RegisteredTempfile.unlink_registery
    end

  end
end
