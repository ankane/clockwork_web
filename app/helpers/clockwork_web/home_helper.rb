module ClockworkWeb
  module HomeHelper

    def friendly_period(period)
      if period % 1.day == 0
        "#{period / 1.day} day"
      elsif period % 1.hour == 0
        "#{period / 1.hour} hour"
      elsif period % 1.minute == 0
        "#{period / 1.minute} min"
      else
        "#{period} sec"
      end
    end

    def last_run(event)
      if ClockworkWeb.redis
        # TODO get all events at once
        timestamp = ClockworkWeb.redis.get("clockwork:last_run:#{event.job}")
        if timestamp
          time_ago_in_words(Time.at(timestamp.to_i))
        end
      end
    end

  end
end
