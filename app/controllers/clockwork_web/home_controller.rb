module ClockworkWeb
  class HomeController < ActionController::Base
    layout false
    helper ClockworkWeb::HomeHelper

    http_basic_authenticate_with name: ENV["CLOCKWORK_USERNAME"], password: ENV["CLOCKWORK_PASSWORD"] if ENV["CLOCKWORK_PASSWORD"]

    def index
      @events =
        Clockwork.manager.instance_variable_get(:@events).sort_by do |e|
          at = e.instance_variable_get(:@at)
          [
            e.instance_variable_get(:@period),
            (at && at.instance_variable_get(:@hour)) || -1,
            (at && at.instance_variable_get(:@min)) || -1,
            e.job.to_s
          ]
        end
      # TODO fetch all disabled jobs and last runs in one call
    end

    def job
      job = params[:job]
      if params[:enable] == "true"
        ClockworkWeb.enable(job)
      else
        ClockworkWeb.disable(job)
      end
      redirect_to root_path
    end

  end
end
