require 'lib/recordings'
require 'rr'

describe ParagraphRecording do
  extend RR::Adapters::RRMethods
  before do
    @paragraph = File.open('spec/data/recordings-paragraph.txt').read
    @script_recording = ScriptRecording.new( :deepener, :time_capsule, @paragraph )
    @paragraph_recording = ParagraphRecording.new(@script_recording, 0, @paragraph )
  end
  after do
    RR.verify
  end

  it "successfull recording of a paragraph" do
    getc_return_values = [13,13,13].reverse
    mock(Tty).getc.times(3) { getc_return_values.pop }
    stub(IO).popen { stub!.pid {-1} }
    mock(Process).kill("TERM", -1).once {true}

    @paragraph_recording.record
    1.should == 1
  end
  it "unsucessfull recording of a paragraph" do
    getc_return_values = [13,13,32].reverse
    mock(Tty).getc.times(3) { getc_return_values.pop }
    stub(IO).popen { stub!.pid {-1} }
    mock(Process).kill("TERM", -1).once {true}

    @paragraph_recording.record
    1.should == 1
  end
end

describe ScriptRecording do
  extend RR::Adapters::RRMethods
  before do
    @script = File.open('spec/data/script.txt').read
    @script_recording = ScriptRecording.new( :deepener, :time_capsule, @script )
  end
  after do
    RR.verify
  end

  it "should render correct target path" do
    @script_recording.target_dir.to_s.should == "recordings/deepener/time_capsule/"
  end

  it "should split in the correct paragraphs" do
    @script_recording.paragraphs.size.should == 17
  end

  it "should call render the appropiate times" do
    any_instance_of( ParagraphRecording ) do |pr| 
     mock(pr).record.times(17) {true}
    end
    mock( @script_recording.target_dir ).exist? {false}
    @script_recording.record
    1.should == 1
  end
end
