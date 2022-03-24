require "clockwork"

module Clockwork
  handler do |job, time|
    puts "Running #{job}, at #{time}"
  end

  every(10.seconds, "frequent.job")
end
