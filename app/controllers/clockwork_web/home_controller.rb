module ClockworkWeb
  class HomeController < ActionController::Base
    layout false
    helper ClockworkWeb::HomeHelper

    protect_from_forgery with: :exception

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

      @last_runs = ClockworkWeb.last_runs
      @disabled = ClockworkWeb.disabled_jobs
      @last_heartbeat = ClockworkWeb.last_heartbeat
    end

    def job
      job = params[:job]
      enable = params[:enable] == "true"
      if enable
        ClockworkWeb.enable(job)
      else
        ClockworkWeb.disable(job)
      end
      ClockworkWeb.on_job_update.call(job: job, enable: enable, user: try(:current_user)) if ClockworkWeb.on_job_update
      redirect_to root_path
    end
  end
end
