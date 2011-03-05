#!/usr/bin/env ruby

# splits at every 5 seconds
# and removes silence from beginning to end

require 'lib/sox'

filename = ARGV[0]

sound = Sound.new(filename)

position = 0
count = 0
while position < sound.length_in_seconds
  puts "Creating part #{count}"
  `sox #{filename} #{filename.chomp('.wav')}-#{count}.wav trim #{position} 5 silence -l 1 5 0.1 2 5 0.02`
  #`sox #{filename} #{filename.chomp('.wav')}-#{count}-o.wav trim #{position} 5`
  count += 1
  position += 5
end
