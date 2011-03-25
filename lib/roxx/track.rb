module Roxx
  # Empty module to add custom DSL statements
  module TrackExtentions
  end

  class Track
    include TrackExtentions
    include SoxRenderable
    include CacheInfo
    include Shell

    attr_accessor :file

    def initialize(script)
      @script = script
      @sounds = []
      @effects = []
      @volume = 1
      @focus = false

      disable_cache_file
    end

    def dependencies
      @sounds.map(&:path)
    end

    def to_hash
      hexdigest(@sounds, @effects)
    end

    def render
      # calls SoxRenderable
      @file = cache_file :track_file, [self.to_hash] do
        super(nil, @sounds, @effects)
      end
    end

    def render_in_thread
      Thread.new do
        render
      end
    end

    def is_focused?
      @focus
    end

    # DSL
    def focus
      @focus = true
    end

    def volume v = nil
      v.nil? ? @volume : @volume = v
    end

    def sound *params, &block
      options = params.last.is_a?(Hash) ? params.pop : {}

      name,path,sound = nil,nil,nil
      case params.first
      when Symbol
        name = params.shift
      when String
        path = params.shift
      when Sound
        # notice: create new instance of sound here
        # otherwise when adding same Sound.new object changes
        # to one will happen on every reference. This may cause
        # strange effects ...
        sound = params.shift.dup
        sound.track = self
        options.each {|k,v| sound.send("#{k}=",v)}
      else
        if [File, Tempfile].any? {|t| params.first.is_a?( t ) }
          file = params.first
          sound = RenderedSound.new(self, options.merge(:file => file, :path => file.path))
        end
      end

      @sounds << ( sound || Sound.new(self, options.merge(:path => path, :name => name)) )
      if block_given?
        @sounds.last.instance_eval( &block )
      end
      @sounds.last
    end

    def concat_sounds sounds, opts = {}
      opts.reverse_merge! :start_at => 0, :interval => 5

      max_duration = opts.delete(:max_duration)

      p = opts[:start_at]
      for s in sounds
        ns = sound s, :start_at => p

        p += ns.duration + opts[:interval]

        unless max_duration.nil?
          # cut off duration
          ns.duration = max_duration if ns.duration > max_duration
          max_duration -= ns.duration
          break if max_duration <= 0 # will endup at 0, but < to be safe
        end
      end

    end

    def effect name = nil, *params
      @effects << Effect.build(self, name, *params)
    end

    def preset name
      self.instance_eval &::PreSets[name]
    end

    # Sox interaction
    def to_sox_param
      "-v #{@volume} #{@file.path}"
    end

  end
end
