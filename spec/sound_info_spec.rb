require 'spec/helpers'
require 'lib/roxx'

class WavTest
  include SoundInfo

  def initialize
    @path = Pathname.new( 'spec/data/intro.wav' )
  end

  def info
    sound_info(@path)
  end
end

describe "sound info" do
  before do
    clear_cache
    @wavtest = WavTest.new
  end
  it "should determine correct length" do
    @wavtest.info[:length_seconds].should == 16.402608
  end
end
