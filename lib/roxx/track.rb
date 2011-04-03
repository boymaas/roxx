module Roxx
  # Empty module to add custom DSL statements
  module TrackExtentions
  end

  class Track
    include TrackExtentions
    include Shell
    include Presets
    include EcasoundRenderable
    include Effect

    attr_accessor :file, :sounds
    attr_reader :ecasound_channel_ref
    attr_writer :duration

    def initialize(script)
      @script = script
      @sounds = []
      @effects = []
      @volume = 1
      @focus = false
      @duration = nil
    end

    def dependencies
      @sounds.map(&:path)
    end

    def to_hash
      hexdigest(@sounds, @effects)
    end

    def is_focused?
      @focus
    end

    def duration
      @duration || @sounds.map(&:stop_at).max
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
      when Pathname
        path = params.shift.to_s
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

    # Will concatenate sounds
    # creates new instances as to be sure
    # not to displace previously used sounds
    def concat_sounds sounds, opts = {}
      opts.reverse_merge! :start_at => 0, :interval => 5

      max_duration = opts.delete(:max_duration)

      p = opts[:start_at]
      sounds.map do |s|
        ns = sound s, :start_at => p

        p += ns.duration + opts[:interval]

        unless max_duration.nil?
          # cut off duration
          ns.duration = max_duration if ns.duration > max_duration
          max_duration -= ns.duration
          break if max_duration <= 0 # will endup at 0, but < to be safe
        end
        ns
      end
    end

    def effect name = nil, *params
      @effects << Effect.build(self, name, *params)
    end

    def preset name
      self.instance_eval &Presets::Library[name]
    end

    # Sox interaction
    def to_sox_param
      "-v #{@volume} #{@file.path}"
    end

    # eacsound
    def to_ecasound_param
      @ecasound_channel_ref, @ecasound_params = 
        build_ecasound_params @sounds, @volume, @effects

      @ecasound_params
    end

  end
end
