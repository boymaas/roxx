require 'lib/recordings'

describe ParagraphRecording do
  before do
    @paragraph = File.open('spec/data/recordings-paragraph.txt').read
    @script_recording = ScriptRecording.new( :deepener, :time_capsule, @paragraph )
    @paragraph_recording = ParagraphRecording.new(@script_recording, 0, @paragraph )
  end

  it "should record" do
    @paragraph_recording.record
    1.should == 1
  end
end
