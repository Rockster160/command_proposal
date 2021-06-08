CommandProposal::Engine.routes.draw do
  root to: "tasks#index"

  resources :tasks, path: "/"
end
