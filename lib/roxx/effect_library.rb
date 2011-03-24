EffectLibrary = {}

class CustomEffect
  attr_accessor :param_order
  attr_reader :param_filter, :param_defaults

  def initialize(name)
    @name = name
    @param_order = []
    @param_defaults = {}
    @param_filter = nil
  end

  def def_param_filter &block
    @param_filter = block
  end

  def def_param_defaults opts = {}
    @param_defaults = opts
  end

  def to_sox_param options
    @param_order.map {|k| options[k] || @param_defaults[k] }
  end
end

def def_effect name, param_order, &block
  # set class instance variables
  custom_effect = CustomEffect.new(name)
  custom_effect.instance_eval &block
  custom_effect.param_order = param_order

  EffectLibrary[name] = custom_effect
end

def_effect :fade, [:type, :fade_in_length, :stop_time, :fade_out_length] do
  def_param_defaults :type => :q, :fade_in_length => 8, :stop_time => nil, :fade_out_length => 8
  def_param_filter do |file,params|
    params[2] ||= file.info[:length_seconds]
    params
  end
end

