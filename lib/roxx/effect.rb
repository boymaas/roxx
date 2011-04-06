# can be included into class
# adds specific effects to effect array
#
# all effects are wrapped into a proc for delayed evaluation
# on rendering. Since settings of object may change or order can be different
#   volume 1
#   effect_fade 20
#   volume 0.8
#
# would otherwise render the volume incorrectly
#
# Effect chains: chains are executed after one another
# the reverb effect makes the sound a little softer, this is why
# we -ea = effect amplify it with 160% if therse is a linear envelope earlier
# in the chain the amplification is added to that value. Nice since we can compensate now.
module Roxx
  module Effect

    # baded on klg .. linear transformations of volume
    def effect_fade length # in seconds
      @effects << lambda {"-ea 0 -klg:1,0,#{volume*100},4,0,0,#{length},1,#{duration - length},1,#{duration},0"}
    end

    # sweeps the pan using a sinoid form right to left and back again
    # hrtz times a second
    def effect_sweeping_pan hrtz, i_phase = 5
      @effects << lambda {"-epp:0 -kos:1,0,100,#{hrtz},#{i_phase}"}
    end

    def effect_reverb1
      @effects << lambda {"-ete:500,100,40 -ea 160"}
    end
    def effect_echo
      @effects << lambda {"-etd:50,1,1,30"}
    end
    def effect_bassbooster
      @effects << lambda {"-efb:460,320 -ea:200 "}
    end
  end
end
