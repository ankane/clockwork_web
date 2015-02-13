module ClockworkWeb
  class HomeController < ActionController::Base
    layout false
    helper ClockworkWeb::HomeHelper

    http_basic_authenticate_with name: ENV["CLOCKWORK_USERNAME"], password: ENV["CLOCKWORK_PASSWORD"] if ENV["CLOCKWORK_PASSWORD"]

    def index
      @events = Clockwork.manager.instance_variable_get(:@events).sort_by{|e| [e.instance_variable_get(:@period), e.job.to_s] }
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
