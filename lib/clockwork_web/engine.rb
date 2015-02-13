module ClockworkWeb
  class Engine < ::Rails::Engine
    isolate_namespace ClockworkWeb

    initializer "clockwork_web" do |app|
      require Rails.root.join("clock") # hacky
    end
  end
end
