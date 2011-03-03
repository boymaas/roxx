def hypnotic_script src_voices, options = {}, &block
  # get options
  src_backgrounds = options.delete(:src_backgrounds) || 
    ['source/background/delta_wave', 'source/background/thunderstorm-in-the-wilderness']
  src_suggestions = options.delete(:src_suggestions) || nil

  [src_backgrounds, src_voices].flatten.each do |src|
    raise "file referenced by #{src} -> #{src}.mp3 does not exists" unless File.exists? "#{src}.mp3"
  end

  # make sounds of our sources
  [src_backgrounds, src_voices].each do |sources|
    sources.map! {|src| Sound.new(nil, :path => "#{src}.mp3")}
  end

  background_track_length = src_backgrounds.map(&:length_in_seconds).min
  voice_track_length = src_voices.map(&:length_in_seconds).sum + ( ( src_voices.size - 1 ) * 10 + 60 ) # interval
  duration = options.delete(:duration) || voice_track_length + 20

  if voice_track_length > background_track_length
    raise "not enough background for this voice track background_length = #{background_track_length} vs calculated duration = #{duration}. #{duration - background_track_length} seconds overflow "
  end
  if duration > background_track_length
    raise "not enough background for this durations #{duration}"
  end

  script do
    if block_given?
      instance_eval(&block)
    end
    track :backgrounds do
      volume 0.05

      src_backgrounds.each {|bg|
        sound bg, :duration => duration
      }

      effect :fade, :fade_in_length => 20, :fade_out_length => 20
    end

    track :voice do
      volume 0.9

      concat_sounds src_voices, :interval => 10, :start_at => 30 

      effect :fade, :fade_in_length => 4, :fade_out_length => 4

      preset :hypnotic_voice
    end

    # when suggestions are available
    if src_suggestions
     # generate a track full of suggestinos
     track :suggestions do
       volume 0.05
       generate_suggestions( src_suggestions, :start_at => 0, :interval =>4, :duration => duration )

       effect :fade, :fade_in_length => 60, :fade_out_length => 60
       preset :hypnotic_voice
     end
    end
  end
end

module TrackExtentions
  # suggestions are little sentences ... never more than 5 seconds long ..
  # this method creates list of sounds inside a track over a period of duration stating at
  def generate_suggestions name, options = {}
    # sorted, otherwise caching will not function
    suggestions = Dir["source/suggestions/#{name}/*.mp3"].sort

    raise 'cannot find suggestions' if suggestions.blank?

    interval = options.delete(:interval) || 5
    duration = options.delete(:duration) || 60
    start_at = options.delete(:start_at) || 0
    variation = options.delete(:variation) || 0
    stop_at = start_at + duration

    placed_suggestions = []

    # seed otherwise caching will not function ;
    srand(0)
    position = start_at
    while position < stop_at
      sound suggestions.random_element, :start_at => position + rand(variation) do
        effect :pan, [-1,1,0.5,-0.5].random_element
      end
      position += interval
    end
  end
end
