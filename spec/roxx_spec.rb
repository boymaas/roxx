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
    @script = script do
      #track do
      #  (0..20).each do |os|
      #    sound 'spec/data/intro.wav', :start_at => os*0.2, :offset => 2
      #  end
      #  volume 0.6
      #end
      track do
        sound 'spec/data/intro.wav', :start_at => 0
        volume 0.8
        effect :echos, [0.8, 0.7, 700, 0.25, 700, 0.4]
        effect :earwax
        effect :bass, 20
      end
      track do
        sound 'spec/data/intro.wav', :start_at => 21
        sound 'spec/data/intro.wav', :start_at => 40
        volume 0.8
      end
    end
  end

  #it "should render" do
  #  @script.render
  #  1.should == 1
  #end

  it "should save" do
   @script.save('spec/tmp/intro-spec-2.mp3')
   1.should == 1
  end
end
