module SoundInfo
  include CacheInfo

  @sound_info = nil

  def determine_sound_info pathname
    cache_data :sound_info, [pathname, pathname.mtime] do

      sox_info_output = `sox #{pathname} -n stat 2>&1`
      puts "Sox error on '#{path}': #{ sox_info_output }" if sox_info_output.lines.first =~ /FAIL/ 
      sox_info_output.split("\n\n")[0].lines.map(&:chomp).map do |line|
        k,v = line.split(':').map &:strip
        [ k.downcase.gsub(/[^\w]+/, '_').chomp('_').to_sym, v.to_f ]
      end.to_h

    end
  end

  def sound_info path
    @sound_info ||= determine_sound_info(path)
  end
end
