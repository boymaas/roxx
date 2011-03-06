require 'rubygems'
require 'tempfile'
require 'pathname'
require 'facets'
require 'fileutils'
require 'lib/roxx/shell'
require 'open3'
require 'ruby-debug'

require 'lib/recordings/utils'

class ScriptRecording

  attr_reader :paragraphs

  # String -> String -> String -> ScriptRecording
  def initialize(type, name, script)
    @type, @name, @original_text = type, name, script
    @paragraphs = split_into_paragraphs(script).
      map_with_index {|p,i| ParagraphRecording.new(self,i,p)}
  end

  #  -> Pathname
  def target_dir
    # determine dirname based on type and name
    @target_dir ||= Pathname.new "recordings/#{@type}/#{@name}/"
  end

  def ensure_target_dir_exists
    unless File.directory?( target_dir )
      FileUtils.mkdir_p(target_dir)
    end
  end

  # String -> [ParagraphRecording]
  def split_into_paragraphs(text)
    text.split(%r{\n{2,}}).map &:strip
  end

  # [ParagraphRecording]
  def record
    # check if directory already exists
    # raise when exists .. make sure we don't overwrite
    if target_dir.exist?
      raise "Target directory exists .. please move out of the way ..."
    end
    ensure_target_dir_exists

    # forall paragraphs call record
    begin
      @paragraphs.each do |paragraph|
        while !paragraph.record; end
      end

      # render recording in recording dir
    rescue Interrupt
      opoo "Control-C caught .. exiting the recording process .."
    end
  end

  # Pathname -> Boolean
  def render
    # remove silences at beginning and end
    # call sox to concatenate recordings
    # save into target sctip
  end

  def script_target_path
    # determine script target path based on type and name
  end
end

class ParagraphRecording

  # String -> ParagraphRecording
  def initialize script_recording, count, paragraph
    @script_recording = script_recording
    @count = count
    @paragraph = paragraph
    @path = file_path
    @text_path = text_path
  end

  # -> Boolean
  #
  # returns true when recording was defined a success
  #
  def record
    @script_recording.ensure_target_dir_exists
    # when file is defined, this is a second
    # recording, unlink previous one and create
    # new target
    if file_path.exist?
      remove_files
    end

    # display paragraph
    print ""
    ohai "Preparing to record paragraph #{@count}", "", @paragraph, ""

    # [Enter to start recording]
    ohai "Press enter to start recording, hit Enter again to stop recording"
    Tty.getc



    recorder_stdin = nil
    begin
      # NOTICE: we can connectio with the interactive interface .. but if this works it's ok for me ...
      recorder_stdin, = Open3.popen3(record_cmd(file_path))
      recorder_stdin.puts("start")

      ( 1..3 ).each do |n|
        puts "Coundown #{3-n} .."
        sleep 1
      end
      opoo "Recording has been started ..."
      Tty.getc

    ensure
      # Stop the recorder
      opoo "Recording will stop in 2 seconds ..."
      sleep 2
      recorder_stdin.puts("quit")
      opoo "Recording is stopped ..."
    end

    # ask if this recording is ok while playing back
    begin
      player_stdin, = Open3.popen3("ecasound -i #{file_path} -o jack,system -c")
      player_stdin.puts("start")

      # emit cmdline question:
      # [Enter for next paragraph, Space to do again]
      # 13 = Enter
      # 32 = Space
      recording_ok = ohai_question "Is this recording approved? (Enter = yes, Space = No)",
        13 => :yes, 32 => :no
    ensure
      player_stdin.puts("quit")
    end

    case recording_ok
    when :yes
      spit_text
      ohai "Recording saved under #{file_path}, paragraph saved next to it ..."
      return true
    when :no
      remove_files
      onoe "Recoding incorrect ... removed files .. restarting this paragraph ..."
      return false
    end
  end

  protected

  # Pathname
  def file_path
    @script_recording.target_dir + ( "paragraph-%02d.wav" % @count )
  end

  # Pathname
  def text_path
    Pathname.new(file_path.to_s + '.txt')
  end

  def remove_files
    [file_path, text_path].each do |f|
      FileUtils.rm f if f.exist?
    end
  end

  def spit_text
    File.open(text_path, 'w+').write(@paragraph)
  end

  # String -> String
  def record_cmd target
    "ecasound -q -f:f32,2,44100 -i jack,system -f:s16,2 -o #{target} -c 2>&1" 
  end

end
