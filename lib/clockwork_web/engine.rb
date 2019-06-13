module ClockworkWeb
  class Engine < ::Rails::Engine
    isolate_namespace ClockworkWeb

    initializer "clockwork_web" do
      ClockworkWeb.clock_path ||= Rails.root.join("clock")
      require ClockworkWeb.clock_path.to_s
    end
  end
end
