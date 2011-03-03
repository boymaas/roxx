class Script
  include CacheInfo

  def initialize
    @tracks = []
    @file = nil
  end

  def to_hash
    hexdigest(@tracks, [@tracks.map(&:volume)])
  end

  def render
    # filter out non-focused tracks
    # and set volume to 1
    if @tracks.any?(&:is_focused?)
      @tracks.reject! {|t| !t.is_focused?}
      @tracks.each { |t| t.volume 1 }
    end

    @file = cache_file :script_file, [self.to_hash] do
      @tracks.map(&:render)
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
      FileUtils.cp @file.path, path
    when /\.lame\.mp3$/
     mp3_file = cache_file :mp3_file, [self.to_hash,:mp3] do
       `lame #{@file.path} #{path} `
       File.open(path)
     end
     # if first cache hit, no need to copy it over
     unless mp3_file.path == path
       FileUtils.cp mp3_file.path, path 
     end
    else
      sox @file.path, :target => OpenStruct.new(:path => path)
    end
  end
  
end
