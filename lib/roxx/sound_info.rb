module Roxx
  module SoundInfo

    @sound_info = nil

    def determine_sound_info pathname
      sound_info ||= {}
      sound_info[:length_seconds] = `ecalength -s #{pathname} 2>/dev/null`.chomp.strip.to_f
      sound_info
    end

    def sound_info path
      @sound_info ||= determine_sound_info(path)
    end
  end
end
