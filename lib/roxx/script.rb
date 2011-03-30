module Roxx
  class Script
    include CacheInfo
    include Shell
    include Effect
    include EcasoundRenderable

    attr_accessor :volume

    def initialize
      @tracks = []
      @file = nil
      @effects = []
      @volume = 1

      # takes too much space on device
      disable_cache_file

      @dependencies
    end

    def duration
      @tracks.map(&:duration).max
    end

    def to_hash
      hexdigest(@tracks, [@tracks.map(&:volume)])
    end

    # all source files used in this script
    def dependencies
      @tracks.map(&:dependencies).flatten.sort.uniq
    end

    def build_ecasound_cmd target
      # build all tracks
      # run cmd
      ecasound_sources = @tracks.map {|t| t.to_ecasound_param }.flatten
      script_loopback = get_ecasound_loop_uidx
      script_channel_ref = get_ecasound_uidx
      command = <<-cmd.gsub(/^\s+/,'').gsub("\n", ' ')
        ecasound #{ecasound_sources * " "} 
        -a:#{@tracks.map(&:ecasound_channel_ref) * ','} -o #{script_loopback} 
        -a:#{script_channel_ref} -i #{script_loopback} #{@effects.map(&:call) }
        -a:#{script_channel_ref} -o #{target}
      cmd

      $stderr.puts "\n"*2 + command.gsub(/-a:[\d,]+/, "\n    \\0") + "\n"*2
      
      command
    end

    def render target
      command = build_ecasound_cmd
      run command
    end

    # DSL
    def track name = nil, &block
      @tracks << ( new_track = Track.new(self) ) 
      if block.arity
        block.call(new_track)
      else
        new_track.instance_eval( &block )
      end
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
