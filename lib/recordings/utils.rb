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

    def clear; system('clear') ; end

    def getc
      system("stty raw -echo")
      c = STDIN.getc
    ensure
      system("stty -raw echo")
      raise Interrupt if c == 3
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
  puts "#{Tty.red}Alert#{Tty.reset}: #{warning}"
end

def onoe error
  lines = error.to_s.split'\n'
  puts "#{Tty.red}Error#{Tty.reset}: #{lines.shift}"
  puts lines unless lines.empty?
end

