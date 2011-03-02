module CacheInfo
  def cache_data prefix, cache_params
    _cache_path = cache_pathname(prefix, cache_params)
    if _cache_path.exist?
      return YAML.load_file(_cache_path)
    end

    data = yield

    File.open(_cache_path, 'w+') {|f| f.write(YAML.dump(data)) }

    data

  end

  # either cache using file or execute block
  #
  # cache_file [:this, :are, :cache, :params]
  def cache_file prefix, cache_params
    # when MD5 hexdigit of cache_params matches
    # read file from cache
    _cache_path = cache_pathname(prefix, cache_params)

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

  def cache_filename prefix, params
    "cache/#{prefix}_#{cache_genid(params)}"
  end

  def cache_pathname prefix, params
    Pathname.new(cache_filename(prefix,params))
  end

end
