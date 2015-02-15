require "clockwork_web/version"

# dependencies
require "clockwork"
require "robustly"

# engine
require "clockwork_web/engine"

module ClockworkWeb
  LAST_RUNS_KEY = "clockwork:last_runs"
  DISABLED_KEY = "clockwork:disabled"
  HEARTBEAT_KEY = "clockwork:heartbeat"

  class << self
    attr_accessor :clock_path
    attr_accessor :redis
    attr_accessor :monitor
  end
  self.monitor = true

  def self.enable(job)
    if redis
      redis.srem(DISABLED_KEY, job)
      true
    else
      false
    end
  end

  def self.disable(job)
    if redis
      redis.sadd(DISABLED_KEY, job)
      true
    else
      false
    end
  end

  def self.enabled?(job)
    if redis
      !redis.sismember(DISABLED_KEY, job)
    else
      true
    end
  end

  def self.disabled_jobs
    if redis
      Set.new(redis.smembers(DISABLED_KEY))
    else
      Set.new
    end
  end

  def self.last_runs
    if redis
      Hash[ redis.hgetall(LAST_RUNS_KEY).map{|job, timestamp| [job, Time.at(timestamp.to_i)] }.sort_by{|job, time| [time, job] } ]
    else
      {}
    end
  end

  def self.set_last_run(job)
    if redis
      redis.hset(LAST_RUNS_KEY, job, Time.now.to_i)
    end
  end

  def self.last_heartbeat
    if redis
      timestamp = redis.get(HEARTBEAT_KEY)
      if timestamp
        Time.at(timestamp.to_i)
      end
    end
  end

  def self.heartbeat
    if redis
      heartbeat = Time.now.to_i
      if heartbeat % 10 == 0
        prev_heartbeat = redis.getset(HEARTBEAT_KEY, heartbeat).to_i
        if heartbeat == prev_heartbeat
          # TODO debounce
          # TODO try to surface hostnames when this condition is detected
          # TODO hook to take action
          redis.setex("clockwork:status", 20, "multiple")
        end
      end
    end
  end

  def self.running?
    last_heartbeat && last_heartbeat > 60.seconds.ago
  end

  def self.multiple?
    redis && redis.get("clockwork:status") == "multiple"
  end
end

module Clockwork
  on(:before_tick) do
    ClockworkWeb.heartbeat if ClockworkWeb.monitor
    true
  end

  on(:before_run) do |event, t|
    run = true
    safely do
      run = ClockworkWeb.enabled?(event.job)
      if run
        ClockworkWeb.set_last_run(event.job)
      else
        manager.log "Skipping '#{event}'"
        event.last = event.convert_timezone(t)
      end
    end
    run
  end
end
