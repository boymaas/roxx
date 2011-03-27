module Roxx
  module Presets
    Library = {}

    def self.def_preset name, &block
      Library[name] = block
    end

    def_preset :hypnotic_voice do |params|
      effect_echo
      effect_reverb1
    end
  end
end
