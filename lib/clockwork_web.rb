require "clockwork_web/version"

# dependencies
require "clockwork"
require "robustly"

# engine
require "clockwork_web/engine"

module ClockworkWeb
  class << self
    attr_accessor :clock_path
    attr_accessor :redis
  end

  def self.enable(job)
    if redis
      redis.srem("clockwork:disabled", job)
      true
    else
      false
    end
  end

  def self.disable(job)
    if redis
      redis.sadd("clockwork:disabled", job)
      true
    else
      false
    end
  end

  def self.enabled?(job)
    if redis
      !redis.sismember("clockwork:disabled", job)
    else
      true
    end
  end

  def self.disabled_jobs
    if redis
      Set.new(redis.smembers("clockwork:disabled"))
    else
      Set.new
    end
  end
end

module Clockwork
  on(:before_run) do |event, t|
    run = true
    safely do
      run = ClockworkWeb.enabled?(event.job)
      if run
        if ClockworkWeb.redis
          ClockworkWeb.redis.set("clockwork:last_run:#{event.job}", Time.now.to_i)
        end
      else
        manager.log "Skipping '#{event}'"
        event.last = event.convert_timezone(t)
      end
    end
    run
  end
end
