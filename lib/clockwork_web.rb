require "clockwork_web/version"

# dependencies
require "clockwork"
require "robustly"

# engine
require "clockwork_web/engine"

module ClockworkWeb
  class << self
    attr_accessor :redis
  end

  def self.enable(job)
    ClockworkWeb.redis.del("clockwork:disabled:#{job}")
    true
  end

  def self.disable(job)
    ClockworkWeb.redis.set("clockwork:disabled:#{job}", 1)
    true
  end

  def self.enabled?(job)
    !ClockworkWeb.redis.exists("clockwork:disabled:#{job}")
  end
end

module Clockwork
  on(:before_run) do |t|
    run = true
    safely do
      if ClockworkWeb.redis
        run = ClockworkWeb.enabled?(t.job)
        if run
          ClockworkWeb.redis.set("clockwork:last_run:#{t.job}", Time.now.to_i)
        end
      end
    end
    run
  end
end
