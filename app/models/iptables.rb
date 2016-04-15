class Iptables
  EXPIRATION = 120

  include Redis::Objects

  sorted_set :pool, global: true

  class << self
    def reject(ip, expiration = 1.hour)
      pool[ip] = Time.now.since(expiration).to_i
    end

    def delete(ip)
      pool.delete(ip)
    end

    def match?(ip)
      pool.score(ip).to_i >= Time.now.to_i
    end

    def clear_all
      pool.clear
    end

    def list
      pool.members
    end

    def mark(ip)
      Redis::Counter.new("iptables::mark:#{ip}", expiration: EXPIRATION).incr
    end

    def marked
      redis.keys 'iptables::mark:*'
    end

    def count_mark(ip)
      Redis.current.get("iptables::mark:#{ip}").to_i
    end

    protected

    def redis
      @redis ||= Redis.current
    end
  end
end
