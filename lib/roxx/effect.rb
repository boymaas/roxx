module Roxx
  class Effect

    attr_reader :start_at, :duration
    attr_accessor :custom_effect

    def initialize(sound_or_track, name=nil, *params)
      opts = params.extract_options!

      @sound_or_track = sound_or_track

      @start_at = opts.delete(:start_at) || 0
      @duration = opts.delete(:duration) || nil # when duration is nil .. till end of file

      @name = name
      @params = params
    end

    def to_hash
      hexdigest(@name, @params)
    end

    def stop_at
      return nil unless duration
      start_at + duration
    end

    def to_sox_param file
      effect_params = @params

      if @custom_effect && @custom_effect.param_filter
        effect_params = @custom_effect.param_filter.call(file, @params.dup) 
      end

      "#{@name} #{effect_params.flatten * ' '}"
    end

    class << self
      #
      # Effect builder out of def_effect configuration. Essentially congfigures an Effect::Base
      def build sound, name, *params
        # when not defined in a special way ..
        unless EffectLibrary.has_key?(name)
          return Effect.new(sound, name, *params)
        end

        # we have the effect in our library
        # build params

        options = params.extract_options!
        custom_effect = EffectLibrary[name]

        effect = Effect.new(sound, name, *custom_effect.to_sox_param(options))
        effect.custom_effect = custom_effect
        effect
      end

    end
  end
end 
