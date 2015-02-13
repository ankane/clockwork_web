ClockworkWeb::Engine.routes.draw do
  post "home/job"
  root to: "home#index"
end
