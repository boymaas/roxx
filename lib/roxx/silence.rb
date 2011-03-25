module Roxx
  class Silence < Sound
    def initialize(*params)
      super(nil,*params)
      @file = WavTempfile.new('silence') 
      @path = @file.path
    end
    def duration
      @duration
    end
    def render
      run "sox -n -r 44100 -c 2 #{@path} trim 0.0 #{duration}"
    end
  end
end
