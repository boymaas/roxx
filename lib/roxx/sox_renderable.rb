module SoxRenderable

  # Rendering a script, this contains generic rendering
  # functionality
  #
  # Phases of rendering
  #
  # track consists of sounds, and effects.
  #
  # A sound is a part or whole of an audiofile
  # A sound has a position. All sounds on a track are merged.
  #
  # A sound can have effects. Effects on a sound are applied to 
  # the whole part of the sound. If the effect does fall inside
  # the duration of the sound. The sound will have to split furhter
  # until a sound is matched with an effect.
  #
  # then the remaining sounds will be merged into a track by the following
  # algorithm:
  #
  # p. prepare all sounds. Preparation means trimming and applying effects on the sounds
  # a. find non-overlapping sounds
  #    render the non-overlapping sounds with the silence between them
  # b. merge this rendered sounds with the previous track if there are
  #    remaining sounds
  # c. when there are no remaining sounds, all sounds are rendered
  #    apply the effects of this track
  #
  # On the applyance of effects
  #
  # effects may only be applied to the whole sound-file, as such
  # we could optimize by doing the following.
  #
  # Effects will only be rendered inside a Sound when the effect
  # spans the whole Sound
  #

  # expand the track to a series of sounds
  # with effects on top of them
  def render file, sounds, effects
    file = render_sounds sounds, file unless sounds.blank?
    file = render_effects effects, file unless effects.blank?
    return file
  end


  def render_sounds sounds, file = nil
    sounds.sort! {|a,b| a.start_at <=> b.stop_at}

    # find all non overlapping sounds and concat them with silence between
    non_overlapping_sounds = sounds.size == 1 ? sounds : _find_non_overlapping( sounds )
    remaining_sounds = sounds - non_overlapping_sounds

    # render the sounds which will concatenated
    non_overlapping_sounds.map(&:render)

    # now fill gaps with silence
    #
    # notice: make sure silences is as big as @sounds otherwise we are missing
    # elements since we zip with silences first
    position = 0
    silences = Array.new(non_overlapping_sounds.size)
    non_overlapping_sounds.each_with_index do |snd,i|
      if position < snd.start_at
        silences[i] = Silence.new(:start_at => position, :duration => snd.start_at - position)
        silences[i].render
      end
      position = snd.start_at + snd.duration
    end
    # merge silences between sounds
    gapeless_sound_list = silences.zip(non_overlapping_sounds).flatten.reject &:nil?


    # now concatenate these sounds
    concatenated_sounds = 
      if gapeless_sound_list.size == 1 and gapeless_sound_list[0].volume == 1
        gapeless_sound_list[0].file
      else
        sox gapeless_sound_list.map(&:file).map(&:path)
      end

    # merge with original file if exist?
    if file
      merged_file = sox [file, concatenated_sounds].map(&:path), :sox_options => '-m'
    else
      merged_file = concatenated_sounds
    end
    #
    # this smells like recursive
    if remaining_sounds.blank?
      return merged_file
    end

    render_sounds(remaining_sounds, merged_file)
  end

  def render_effects effects, file
    # we split the file up into sounds wich have effects applied
    # to them and then render the track using render
    #
    # HOW DO WE RENDER!
    #
    # matching effects can be applied at once
    # overlapping effects need to be applied top down
    # non-overlapping effects can be split in individaul sounds
    #
    #
    # when only one effect, apply it and lets get it done
    overlapping_effects = effects.size == 1 ?  effects : _find_overlapping( effects )
    remaining_effects = effects - overlapping_effects

    # if effects span who file, we can render it safely
    # otherwise define a sound over this file to render these overlapping
    # on a part of this file inside a sound
    e0 = overlapping_effects[0]
    # notice: how i match on duration.nil? if no duration is specified .. til end of file ..
    #         which is same as complete file
    if e0.start_at == 0 && ( e0.duration.nil? || e0.duration == file.info[:length_seconds] )
      file = sox file.path, effects.map(&:to_sox_param) * ' '
    else
      sound = Sound.new(nil, :effects => effects, :start_at=>e0.start_at, :duration=>e0.duration, :file => file)
      file = render_sounds( [ sound ], file )
    end

    if remaining_effects.blank?
      return file
    end

    render_effects remaining_effects, file 
  end

  protected

  def _find_non_overlapping a
    #_partnerize(a).take_while {|k,l| l.nil? || k.stop_at <= l.start_at}.map &:first
    no = []
    a.each do |k|
      if no.blank? ; no << k ; next ; end

      if no.last.stop_at <= k.start_at 
        no << k
      end
    end
    no
  end

  def _find_overlapping a
    # matching since when a b match and b and c match a and c also match
    _partnerize(a).take_while {|a,b| b.nil? || a.start_at == b.start_at && a.stop_at == b.stop_at}.map &:first
  end

  def _partnerize a 
    return [] if a.blank?
    a.zip(a.tail)
  end

end
