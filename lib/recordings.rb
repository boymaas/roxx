require 'rubygems'
require 'tempfile'
require 'pathname'
require 'fileutils'
require 'lib/roxx/shell'
require 'ruby-debug'
#require 'open4'

class WavTempfile < Tempfile

  def make_tmpname(basename, n)
    sprintf("%s%d.%d.wav", basename, $$, n)
  end

end

class Tty
  class <<self
    def blue; bold 34; end
    def white; bold 39; end
    def red; underline 31; end
    def yellow; underline 33 ; end
    def reset; escape 0; end
    def em; underline 39; end

    def getc
      system("stty raw -echo")
      c = STDIN.getc
    ensure
      system("stty -raw echo")
      c
    end

    def ask_y_or_n 
      begin
        print ' (y or no) ? '
        answer = getc
        print "\r\n"
      end until(answer == ?y or answer == ?n or answer == 13)
      if block_given? and answer == ?y
        yield
      end
      return answer == ?y
    end

    def ask options = {}
      $stdout.flush
      while true
        answer = getc
        break if(options.keys.any? {|k| k ==  answer})
        print "\r\nNot a valid answer [#{answer}], try again .."
      end 

      print "\r\n"

      if block_given?
        yield(options[answer])
      else
        options[answer]
      end

    end

    private
    def color n
      escape "0;#{n}"
    end
    def bold n
      escape "1;#{n}"
    end
    def underline n
      escape "4;#{n}"
    end
    def escape n
      "\033[#{n}m" if $stdout.tty?
    end

    # read input directly

  end
end

# args are additional inputs to puts until a nil arg is encountered
def ohai title, *sput
  title = title.to_s[0, `/usr/bin/tput cols`.strip.to_i-4]
  puts "#{Tty.blue}==>#{Tty.white} #{title}#{Tty.reset}"
  puts sput unless sput.empty?
end
def ohai_question title, options, &block
  title = title.to_s[0, `/usr/bin/tput cols`.strip.to_i-4]
  print "#{Tty.blue}==>#{Tty.white} #{title}#{Tty.reset}"
  if block_given?
    Tty.ask options, &block
  else
    Tty.ask options
  end
end

def opoo warning
  puts "#{Tty.red}Warning#{Tty.reset}: #{warning}"
end

def onoe error
  lines = error.to_s.split'\n'
  puts "#{Tty.red}Error#{Tty.reset}: #{lines.shift}"
  puts lines unless lines.empty?
end


class ScriptRecording

  # String -> String -> String -> ScriptRecording
  def initialize(type, name, script)
    @type, @name, @original_text = type, name, script
    @paragraphs = split_into_paragraphs(script)
  end

  #  -> Pathname
  def directory_name
    # determine dirname based on type and name
    Pathname.new "recordings/#{@type}/#{@name}/"
  end

  def ensure_target_dir_exists
    unless File.directory?( directory_name )
      FileUtils.mkdir_p(directory_name)
    end
  end

  # String -> [ParagraphRecording]
  def split_into_paragraphs(text)
  end

  # [ParagraphRecording]
  def record
    # check if directory already exists
    ensure_target_dir_exists
    # raise when exists .. make sure we don't overwrite

    # forall paragraphs call record
    # render recoding in recoridng dir
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
    ohai "Preparing to record paragraph #{@count}", "", @paragraph, ""

    # [Enter to start recording]
    ohai "Press enter to start recording, hit ^C to stop recording"
    Tty.getc


    begin
      # NOTICE: we can connectio with the interactive interface .. but if this works it's ok for me ...
      recorder_stdin = IO.popen(record_cmd(file_path))

      # emit cmdline question:
      # [Enter for next paragraph, Space to do again]
      # 13 = Enter
      # 32 = Space
      recording_ok = ohai_question "Is this recording approved? (Enter = yes, Space = No)",
        13 => :yes, 32 => :no
    ensure
      # Stop the recorder
      Process.kill( 'TERM', recorder_stdin.pid )
    end

    case recording_ok
    when :yes
      spit_text
      return true
    when :no
      remove_files
      return false
    end
  end

  protected

  # Pathname
  def file_path
    @script_recording.directory_name + ( "paragraph-%02d.wav" % @count )
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
    "ecasound -q -f:f32,2,44100 -i jack,system -f:s16,2 -o #{target} 2>&1" 
  end

end
