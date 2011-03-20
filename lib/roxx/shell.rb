def sox original, *params
  options = params.last.is_a?(Hash) ? params.pop : {}

  target = options.delete(:target)
  target ||= WavTempfile.new('sox_target')

  sox_options = options.delete(:sox_options)

  original = case original
             when Array
               original * ' '
             else
               original
             end
  effects = if !options.blank?
              options.map {|k,v| "#{k} #{v * ' '}"}
            else
              params * ' '
            end

  run "sox --multi-threaded --buffer 131072 #{sox_options} #{original} -c 2 -r 44100 #{target.path} #{effects}"
  target
end

class SoxException < Exception ; end

def run cmd
  puts cmd
  r = `#{cmd}`
  raise SoxException.new(r) unless $?.success?
end
