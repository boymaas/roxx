module Roxx
  module CacheInfo
    def hexdigest *params
      MD5.hexdigest( params.flatten.map {|e| e.respond_to?(:to_hash) ? e.to_hash : e } * ':' )
    end

    def cache_data prefix, cache_params
      _cache_path = cache_pathname(prefix, cache_params, :yml)
      if _cache_path.exist?
        return YAML.load_file(_cache_path)
      end

      data = yield

      File.open(_cache_path, 'w+') {|f| f.write(YAML.dump(data)) }

      data

    end

    def disable_cache_file
      @cache_info_disable_cache_file = true
    end

    # either cache using file or execute block
    #
    # cache_file [:this, :are, :cache, :params]
    def cache_file prefix, cache_params, opts = {}
      if @cache_info_disable_cache_file
        return yield
      end

      # when MD5 hexdigit of cache_params matches
      # read file from cache
      _cache_path = cache_pathname(prefix, cache_params, opts.fetch(:ext, IntermediateFileFormat))

      if _cache_path.exist?
        return File.open(_cache_path)
      end

      file = yield

      begin
        file.flush if file.writable?
      rescue
      end

      unless file.nil?
        FileUtils.cp file.path, _cache_path
      end

      file
    end

    private

    def cache_genid params
      MD5.hexdigest params * ' '
    end

    def cache_filename prefix, params, ext
      "cache/#{prefix}_#{cache_genid(params)}.#{ext}"
    end

    def cache_pathname prefix, params, ext
      Pathname.new(cache_filename(prefix,params,ext))
    end

  end
end
