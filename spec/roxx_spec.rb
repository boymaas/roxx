require 'spec/helpers'
require 'lib/roxx'


#describe "defining a script with one sound" do
#  before do
#    clear_cache
#    @script = script do
#      track do
#        sound 'spec/data/intro.wav'
#      end
#    end
#  end

#  it "should render" do
#    @script.render
#    1.should == 1
#  end

#  it "should save" do
#    @script.save('spec/tmp/intro.mp3')
#    1.should == 1
#  end
#end
describe "defining a script with two sounds" do
  before do
    clear_cache
    @script = Roxx::script do
      track do
      (0..20).each do |os|
        sound 'spec/data/intro.wav', :start_at => os*0.2, :offset => 2
      end
      volume 0.1
      end
      track do
        sound 'spec/data/intro.wav', :start_at => 0
        volume 0.8
      end
      track do
       sound 'spec/data/intro.wav'
       sound 'spec/data/intro.wav', :start_at => 21
       sound 'spec/data/intro.wav', :start_at => 40
       effect_sweeping_pan 0.05
       effect_echo
       effect_bassbooster
       effect_reverb1
       preset :hypnotic_voice
       effect_fade 8
       volume 1
      end
      track do
       sound 'spec/data/preperation.mp3'
       preset :hypnotic_voice
       effect_sweeping_pan 0.05, 45
       volume 1
      end
      
      track do
       concat_sounds [ 'spec/data/intro.wav' ] * 2, :max_duration => 10
       concat_sounds [ 'spec/data/intro.wav' ] * 2, :max_duration => 5
       concat_sounds [ 'spec/data/intro.wav' ] * 2, :max_duration => 100
       concat_sounds [ 'spec/data/intro.wav' ] * 2
      end
      track do
        concat_sounds [ 'spec/data/intro.wav' ] * 2
      end
    end
  end

  #it "should render" do
  #  @script.render
  #  1.should == 1
  #end

  it "should save" do
   @script.save('spec/tmp/intro-spec-2.mp3')
   #@script.save('jack,system')
   #TempfileRegistery.size.should == 0
   1.should == 1
  end
end
