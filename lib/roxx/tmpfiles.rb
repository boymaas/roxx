TempfileRegistery = []

class RegisteredTempfile < Tempfile
  def initialize *params
    super(*params)
    TempfileRegistery << self
  end

  def self.unlink_registery
    TempfileRegistery.each do |tmpf|
      tmpf.close unless tmpf.closed?
      tmpf.unlink if tmpf.path
    end
    TempfileRegistery.clear
  end
end

class WavTempfile < RegisteredTempfile
  include SoundInfo

  def make_tmpname(basename, n)
    sprintf("%s%d.%d.#{IntermediateFileFormat}", basename, $$, n)
  end

end

class DatTempfile < RegisteredTempfile
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
