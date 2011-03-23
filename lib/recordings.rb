require 'rubygems'
require 'tempfile'
require 'pathname'
require 'facets'
require 'fileutils'
require 'lib/roxx/shell'
require 'open3'
require 'ruby-debug'
require 'lib/ecasound'

require 'lib/recordings/utils'

class EcasoundError < RuntimeError; end
class EcasoundCommandError < EcasoundError
    attr_accessor :command, :error
    def initialize(command, error)
        @command = command
        @error = error
    end
end

class AudioPlayer < Ecasound::ControlInterface
  def initialize path
    super( "-i #{path} -o jack,system" )
  end
  def start
    command("start")
  end
  def rewind s
    command("rewind #{s}")
  end
  def forward s
    command("forward #{s}")
  end
  def stop
    command("stop")
  end
  def quit
    stop
    command("quit")
    cleanup
  end
  def get_length
    @length ||= command("get-length")
  end
  def get_position
    command("get-position")
  end

  def get_perc_position
    get_length == 0 ? 0 : ( 100 * get_position / get_length ) 
  end
end

class ScriptRecording

  attr_reader :paragraphs

  # String -> String -> String -> ScriptRecording
  def initialize(fpath, script)
    @fpath, @original_text = Pathname.new(fpath), script
    @paragraphs = split_into_paragraphs(script).
      map_with_index {|p,i| ParagraphRecording.new(self,i,p)}
  end

  #  -> Pathname
  def target_dir
    # determine dirname based on type and name
    target_dir_without_tstamp + "#{timestamp}/"
  end

  def target_dir_without_tstamp
    Pathname.new "recordings/#{@fpath.dirname}/#{ @fpath.basename.to_s.chomp('.txt') }/"
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
    if target_dir_without_tstamp.exist?
      timestamps = Dir["#{ target_dir_without_tstamp }/*"].map {|tsdir| tsdir.match(%r{/(\d+)/?})[1]}.sort
      if timestamps.size > 0
        timestamps.each_with_index do |ts,i|
          opoo "Recording #{i+1}: " + ts
        end
        continue_with = 
          ohai_question "Previous recordings exists .. want to overwrite one of them (n = create new one, digit = the timestamp you would like to use)?",
          ([ [ ?n,0 ] ] + (1..timestamps.size).map {|i| [ (i).to_s[0], i ] }).to_h         
        case continue_with
        when 0
        else
          @timestamp = timestamps[continue_with-1]
        end
      end
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

  # opens all paragraphs in audacity
  def open_paragraphs_in_audacity
    edit_paragraphs = ohai_question "Open paragraphs in audacity (Y/n)? ", 13 => :yes, ?y => :yes, ?n => :no, ?Y => :yes
    if edit_paragraphs == :yes
      @paragraphs.each do |paragraph|
        `open -a Audacity #{paragraph.file_path}`
      end
      opoo "Press Enter to continue rendering ..."
      Tty.getc
    end
  end

  # Pathname -> Boolean
  def render
    # remove silences at beginning and end
    # call sox to concatenate recordings
    # save into target sctip
    opoo "Rendering recording to ... #{script_target_path}"
    concatenated_file = sox @paragraphs.map(&:file_path)
    if File.exist? script_target_path
      case ohai_question "Target-file already exists #{script_target_path}. Backup ? (y/n)", ?y => :yes, ?n => :no
      when :yes
        FileUtils.mv script_target_path, script_target_path.chomp('.mp3')  + "-backup-#{timestamp_uncached}.mp3"
      when :no
      end
    end
    `lame --preset extreme #{concatenated_file.path} #{script_target_path}`
  end

  def timestamp
    @timestamp ||= timestamp_uncached
  end
  
  def timestamp_uncached
    Time.now.strftime('%Y%m%d%H%M')
  end

  def script_target_path
    # determine script target path based on type and name
    @fpath.to_s.chomp('.txt') + ".mp3"
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

  def display_banner
    # display paragraph
    Tty.clear
    ohai "Preparing to record paragraph #{@count + 1} of #{@script_recording.paragraphs.size}", "", @paragraph, ""
    ohai "into #{file_path}"
  end

  # -> Boolean
  #
  # returns true when recording was defined a success
  #
  def record
    display_banner

    @script_recording.ensure_target_dir_exists
    # when file is defined, this is a second
    # recording, unlink previous one and create
    # new target
    if file_path.exist?
      begin
        audio = AudioPlayer.new(file_path)
        audio.start

        while true
          searching_speed = 3
          old_paragraph_file_ok = ohai_question "Found an existing paragraph file (#{"%.2f" % audio.get_length} seconds), keep it? (Enter = yes, Space = No, (.) = forward #{searching_speed}s, (,) rewind #{searching_speed}s)", 13 => :yes, 32 => :no, 44 => :rewind, 46 => :forward

          display_banner
          case old_paragraph_file_ok
          when :yes
            return true
          when :no
            remove_files
            break
          when :rewind
            audio.rewind(searching_speed)
            ohai "rewinding #{searching_speed} seconds back to #{"%d" % audio.get_perc_position}%"
          when :forward
            audio.forward(searching_speed)
            ohai "forwarding #{searching_speed} seconds to #{"%d" % audio.get_perc_position}%"
          end
        end

      ensure
        audio.quit
      end
    end


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

  # Pathname
  def file_path
    @script_recording.target_dir + ( "paragraph-%02d.wav" % @count )
  end

  protected


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
