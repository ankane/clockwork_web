# dependencies
require "clockwork"
require "safely/core"

# modules
require_relative "clockwork_web/engine" if defined?(Rails)
require_relative "clockwork_web/version"

module ClockworkWeb
  LAST_RUNS_KEY = "clockwork:last_runs"
  DISABLED_KEY = "clockwork:disabled"
  HEARTBEAT_KEY = "clockwork:heartbeat"
  STATUS_KEY = "clockwork:status"

  class << self
    attr_accessor :clock_path
    attr_accessor :redis
    attr_accessor :monitor
    attr_accessor :running_threshold
    attr_accessor :on_job_update
    attr_accessor :user_method
  end
  self.monitor = true
  self.running_threshold = 60 # seconds
  self.user_method = :current_user

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
      Hash[redis.hgetall(LAST_RUNS_KEY).map { |job, timestamp| [job, Time.at(timestamp.to_i)] }.sort_by { |job, time| [time, job] }]
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
        if prev_heartbeat >= heartbeat
          redis.setex(STATUS_KEY, 60, "multiple")
        end
      end
    end
  end

  def self.running?
    last_heartbeat && last_heartbeat > Time.now - running_threshold
  end

  def self.multiple?
    redis && redis.get(STATUS_KEY) == "multiple"
  end
end

module Clockwork
  on(:before_tick) do
    ClockworkWeb.heartbeat if ClockworkWeb.monitor
    true
  end

  on(:before_run) do |event, t|
    run = true
    Safely.safely do
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
