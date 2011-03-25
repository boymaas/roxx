module Roxx
  PreSets = {}

  def self.def_preset name, &block
    PreSets[name] = block
  end

  def_preset :hypnotic_voice do |params|
    effect :echos, [ 0.8, 0.7, 120, 0.25, 70, 0.1 ]
    #effect :echos, 0.8, 0.7, 200, 0.25, 70, 0.1 # god like sound
    #effect :tempo, :factor => 0.8
    #effect :speed, :factor => 0.94
    effect :bass, 15
  end
end
