class Script
  include CacheInfo

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

  def render
    # filter out non-focused tracks
    # and set volume to 1
    if @tracks.any?(&:is_focused?)
      @tracks.reject! {|t| !t.is_focused?}
      @tracks.each { |t| t.volume 1 }
    end

    @file = cache_file :script_file, [self.to_hash] do
      # multithreaded rendering
      render_threads = 
        @tracks.map(&:render_in_thread)
      render_threads.map(&:join)

      if @tracks.count == 1
        if @tracks[0].volume == 1
          @file = @tracks[0].file
        else
          @file = sox @tracks[0].to_sox_param
        end
      else
        @file = sox @tracks.map(&:to_sox_param), :sox_options => '-m'
      end
      @file
    end
  end

  # DSL
  def track name = nil, &block
    ( @tracks << Track.new(self) ).last.instance_eval( &block )
  end

  # Saving
  def save path
    render
    case path
    when /\.mp3$/
      if IntermediateFileFormat == :mp3
        unless @file.path.to_s == path.to_s
          FileUtils.cp @file.path, path
        end
      elsif IntermediateFileFormat == :au
        sox @file.path, :target => OpenStruct.new(:path => path)
      else
        mp3_file = cache_file :mp3_file, [self.to_hash,:lame_encoding] do
          `lame --preset standard #{@file.path} #{path} `
          File.open(path)
        end
        # if first cache hit, no need to copy it over
        unless mp3_file.path.to_s == path
          FileUtils.cp mp3_file.path, path 
        end
      end
    else
      sox @file.path, :target => OpenStruct.new(:path => path)
    end
    cleanup
  end

  def cleanup
    RegisteredTempfile.unlink_registery
  end

end
