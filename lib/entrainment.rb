module Entrainment
  extend self

  def binaural duration, base, freq
    file = WavTempfile.new('binaural') 
    run "sox -n -c 2 -r 44100 #{file.path} synth #{duration} sine #{base} sine #{base + freq}"
    file
  end

  def pinknoise_tremolo duration, freq, depth = 60
    file = WavTempfile.new('tremolo') 
    `sox -n -c 2 -r 44100 #{file.path} synth #{duration} pinknoise tremolo #{freq} #{depth}`
    file
  end
end

module TrackExtentions
  #generate_binaural [0,20,400,1], [10,5,200,1]

  def generate_binaural *points
    points.zip(points.tail).body.each do |a,b|
      a_start, a_freq, a_base, a_volume = a.map &:to_f
      b_start, b_freq, b_base, b_volume = b.map &:to_f

      duration = b_start - a_start
      delta_freq = ( b_freq - a_freq ) / duration
      delta_base = ( b_base - a_base ) / duration
      delta_volume = ( b_volume - a_volume ) / duration

      step_duration = 2
      # one delta per second
      (0 .. duration.to_i).each do |s|
        sound Entrainment::binaural( step_duration + 1, a_base + (s*delta_base), a_freq + (s*delta_freq) ), 
          :start_at => a_start + s - 0.5, :duration => step_duration do
            effect :fade, :fade_in_length => 0.5, :fade_out_length => 0.5
          end
      end
    end
  end

end
