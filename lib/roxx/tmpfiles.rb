class WavTempfile < Tempfile
  include SoundInfo

  def make_tmpname(basename, n)
    sprintf('%s%d.%d.mp3', basename, $$, n)
  end

end

class DatTempfile < Tempfile
  def make_tmpname(basename, n)
    sprintf('%s%d.%d.dat', basename, $$, n)
  end
end

class File
  include SoundInfo

  def info
    sound_info(Pathname.new(path))
  end
end
