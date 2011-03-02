class Effect
  
  attr_reader :start_at, :duration

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

  def to_sox_param
    "#{@name} #{@params.flatten * ' '}"
  end
end
