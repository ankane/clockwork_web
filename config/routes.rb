ClockworkWeb::Engine.routes.draw do
  post "home/job"
  post "home/execute"

  root to: "home#index"
end
