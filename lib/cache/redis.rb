module Cache::Redis
  def after_fork
    redis_version = Gem::Version.new(Redis::VERSION)
    
    if redis_version >= Gem::Version.new("4")
      if @metal._client.respond_to?(:reconnect)
        @metal._client.reconnect
      else
        @metal._client.close
      end
    else
      @metal.client.reconnect
    end
  end
  
  def _get(k)
    if cached_v = @metal.get(k) and cached_v.is_a?(::String)
      ::Marshal.load cached_v
    end
  end

  def _get_multi(ks)
    ks.inject({}) do |memo, k|
      if v = _get(k)
        memo[k] = v
      end
      memo
    end
  end

  def _set(k, v, ttl)
    if ttl == 0
      @metal.set k, ::Marshal.dump(v)
    else
      @metal.setex k, ttl, ::Marshal.dump(v)
    end
  end

  def _delete(k)
    @metal.del k
  end

  def _flush
    @metal.flushdb
  end

  def _exist?(k)
    @metal.exists k
  end

  def _stats
    @metal.info
  end
end
