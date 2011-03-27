module Roxx
  module EcasoundRenderable
    @@ecasound_uidx = 0
    @@ecasound_loop_uidx = 0
    def get_ecasound_uidx
      @@ecasound_uidx += 1
    end
    def get_ecasound_loop_uidx
      @@ecasound_loop_uidx += 1
      "loop,#{@@ecasound_loop_uidx}"
    end

    # ecasound
    # -> [ecasound params]
    def build_ecasound_params sounds, volume

      if sounds.empty?
        # nothing to do
        # just return
        return []
      elsif sounds.size == 1
        # no children just simply render sound at a certain position
        # and apply effects
        sound = sounds.first

        ecasound_channel_ref = get_ecasound_uidx
        ecasound_params = [ "-a:#{ecasound_channel_ref} -i playat,#{sound.start_at},select,#{sound.offset},#{sound.duration},#{sound.path} -ea #{volume * sound.volume * 100}" ] 

      else
        # if we have child sources render them indivudally
        # and merge their resulting channel_refs into a loopback
        # and apply sound effects on the loopback device
         ecasound_loopback = get_ecasound_loop_uidx

        ecasound_params = sounds.map {|s| s.to_ecasound_param}
        # and group them into it's own loop .. to be referenced by
        ecasound_params += 
          [ "-a:#{sounds.map(&:ecasound_channel_ref) * ','} -o #{ecasound_loopback} " ]

        # now apply effects of this sound, including
        # volume on the ref
        #
        # we get a new channel ref .. since loops are grouped
        ecasound_channel_ref = get_ecasound_uidx
        ecasound_params +=
          ["-a:#{ecasound_channel_ref} -i #{ecasound_loopback} -ea #{volume * 100}"]
      end

      # terurn params and resulting channel reference
      [ ecasound_channel_ref, ecasound_params.flatten ]
    end
  end
end
