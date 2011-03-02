class Track
  include SoxRenderable
  include CacheInfo

  attr_accessor :file

  def initialize(script)
    @script = script
    @sounds = []
    @effects = []
    @volume = 1
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

  # DSL
  def volume v = nil
    v.nil? ? @volume : @volume = v
  end

  def sound *params
    options = params.last.is_a?(Hash) ? params.pop : {}
    name = params.first.is_a?(Symbol) ? params.shift : nil
    path = params.first.is_a?(String) ? params.shift : nil

    @sounds << Sound.new(self, options.merge(:path => path, :name => name))
    if block_given?
      @sounds.last.instance_eval(&block)
    end
  end

  def effect name = nil, *params
    @effects << Effect.new(self, name, *params)
  end

  def to_sox_param
    "-v #{@volume} #{@file.path}"
  end

end
