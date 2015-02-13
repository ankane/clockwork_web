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
      redis.del("clockwork:disabled:#{job}")
      true
    else
      false
    end
  end

  def self.disable(job)
    if redis
      redis.set("clockwork:disabled:#{job}", 1)
      true
    else
      false
    end
  end

  def self.enabled?(job)
    if redis
      !redis.exists("clockwork:disabled:#{job}")
    else
      true
    end
  end
end

module Clockwork
  on(:before_run) do |t|
    run = true
    safely do
      run = ClockworkWeb.enabled?(t.job)
      if run && ClockworkWeb.redis
        ClockworkWeb.redis.set("clockwork:last_run:#{t.job}", Time.now.to_i)
      end
    end
    run
  end
end
