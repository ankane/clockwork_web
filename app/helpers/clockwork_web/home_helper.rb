module ClockworkWeb
  module HomeHelper

    def friendly_period(period)
      if period % 1.day == 0
        pluralize(period / 1.day, "day")
      elsif period % 1.hour == 0
        pluralize(period / 1.hour, "hour")
      elsif period % 1.minute == 0
        "#{period / 1.minute} min"
      else
        "#{period} sec"
      end
    end

    def last_run(time)
      if time
        time_ago_in_words(time)
      end
    end

    def friendly_time_part(time_part)
      if time_part
        time_part.to_s.rjust(2, "0")
      else
        "**"
      end
    end

  end
end
