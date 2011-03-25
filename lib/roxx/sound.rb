module Roxx
  class Sound
    include SoxRenderable
    include SoundInfo
    include CacheInfo
    include Shell

    attr_accessor :start_at, :volume, :file, :offset, :track, :duration
    def initialize(track, options = {})
      @track = track
      @start_at = options.delete(:start_at) || 0
      @duration = options.delete(:duration) 
      @offset = options.delete(:offset) || 0 
      @path = options.delete(:path)
      @path = Pathname.new(@path) if @path
      @file = options.delete(:file) || nil

      @volume = options.delete(:volume) || 1

      @sounds = options.delete(:sounds) || []
      @effects = []
    end

    def to_hash
      hexdigest(path, path ? path.mtime : 0, @offset, @duration, @start_at, @volume, @sounds, @effects)
    end

    # duration is baed on ether a fixed
    # duration or on the file length
    def duration
      @duration ||= sound_info[:length_seconds] - offset
    end

    def sound_info
      super(path)
    end

    def length_in_seconds
      sound_info[:length_seconds]
    end

    # path is defined by either
    # a rendered file or by it initialized value
    def path
      @file && !@file.path.nil? ? Pathname.new(@file.path) : @path
    end

    # calculate stop at
    # based on duation which is file length
    # or on
    def stop_at
      @start_at + duration
    end

    # prepare the file
    def prepare
      # if we match the complete file .. we don't need
      # to trim it ...
      if @offset == 0 && duration == sound_info[:length_seconds]
        @file ||= File.open(path)
      else
        @file = sox path, :trim, @offset, @duration
      end
    end

    def render
      #  @file = cache_file :sound_file, [self.to_hash] do
      prepare
      # calls SoxRenderable
      super(@file, @sounds, @effects)
      #  end
    end

    def render_in_thread
      Thread.new do
        render
      end
    end

    # DSL
    def effect name = nil, *params
      @effects << Effect.build(self, name, *params)
    end
  end

  class RenderedSound < Sound
    def render
      @file
    end
  end
end
